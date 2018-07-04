public typealias Q = GmpRational
public typealias k = Q

public extension Array where Element: Ring {
  func dot(_ a: [Element]) -> Element? {
    if self.count == a.count {
      var total = Element.zero()
      for i in 0..<self.count {
        total += self[i] * a[i]
      }
      return total
    }
    return nil
  }
}

public class IntervalExchangeMap {
  public typealias SpanPoint = SpanEmbedding.Span.Point

  // EToIEM: $d$
  public let spanCount: Int
  // EToIEM: $\lambda$
  public let spanLengths: [k]
  // EToIEM:
  //   input.order.forwardMap = $\pi_0$
  //   output.order.forwardMap = $\pi_1$
  //   [input.order.inverseMap, output.order.inverseMap] = $\pi$
  //   input.spans = $I$
  //   input.spans[i] = $I_\alpha$, where $\alpha = i$
  //   input.spans[input.order[i]] = $\partial I_\gamma$ where $\gamma$ = i
  public let input: SpanEmbedding
  public let output: SpanEmbedding

  private var _inverse: IntervalExchangeMap?

  private init(
      spanLengths: [k],
      input: SpanEmbedding, output: SpanEmbedding,
      inverse: IntervalExchangeMap? = nil) {
    self.spanCount = spanLengths.count
    self.spanLengths = spanLengths
    self.input = input
    self.output = output
    self._inverse = inverse
  }

  public convenience init(
      spanLengths: [k],
      inputOrder: Permutation, outputOrder: Permutation) {
    if spanLengths.count != inputOrder.size() ||
        spanLengths.count != outputOrder.size() {
      fatalError("IntervalExchangeMap.init arrays must be the same length")
    }
    let input = SpanEmbedding(spanLengths: spanLengths, order: inputOrder)
    let output = SpanEmbedding(spanLengths: spanLengths, order: outputOrder)
    self.init(spanLengths: spanLengths, input: input, output: output)
  }

  public subscript(_ inputPoint: SpanPoint) -> SpanPoint {
    let outputIndex = output.order[input.order.inverse[inputPoint.spanIndex]]
    return output.spans[outputIndex].pointForOffset(inputPoint.offset)
  }

  public subscript(_ f: IntervalExchangeMap) -> IntervalExchangeMap {
    return IntervalExchangeMap.compose(inner: f, outer: self)
  }

  // EToIEM: the "canonical involution".
  public var inverse: IntervalExchangeMap {
    if _inverse == nil {
      _inverse = IntervalExchangeMap(
          spanLengths: spanLengths, input: output, output: input, inverse: self)
    }
    return _inverse!
  }

  // EToIEM: the "monodromy invariant". Independent of spanLengths.
  public func canonicalPermutation() -> Permutation {
    return output.order[input.order.inverse]
  }

  public func domain() -> SpanEmbedding {
    return input
  }

  public func codomain() -> SpanEmbedding {
    return output
  }

  // EToIEM: $w = \Omega_\pi(\lambda)$
  public func spanOffsets() -> [k] {
    return (0..<spanCount).map { (spanIndex: Int) -> k in
      var total = k.zero()
      for i in 0..<spanCount {
        if output.order[i] < output.order[spanIndex] {
          total += spanLengths[i]
        }
        if input.order[i] < input.order[spanIndex] {
          total -= spanLengths[i]
        }
      }
      return total
    }
  }

  public static func compose(
      inner f: IntervalExchangeMap,
      outer g: IntervalExchangeMap) -> IntervalExchangeMap {
    let fLengths = f.spanLengths
    let gLengths = g.spanLengths
    var fIndex = 0
    var gIndex = 0
    var fInclusion = SpanInclusion(index: 0, length: 0)
    var gInclusion = SpanInclusion(index: 0, length: 0)
    var fInclusions: [SpanInclusion] = []
    var gInclusions: [SpanInclusion] = []
    var newSpanLengths: [k] = []
    var nextPos = k.zero()
    var fPos = k.zero()
    var gPos = k.zero()

    while fIndex < fLengths.count || gIndex < gLengths.count {
      let index = newSpanLengths.count
      let pos: k = nextPos
      let fLength =
          (fIndex < f.spanCount)
        ? f.output.spans[fIndex].length
        : nil
      let gLength =
          (gIndex < gLengths.count)
        ? g.input.spans[gIndex].length
        : nil

      let fNextPos = (fLength != nil) ? fPos + fLength! : nil
      let gNextPos = (gLength != nil) ? gPos + gLength! : nil
      nextPos =
          (fNextPos == nil)
        ? gNextPos!
        : (gNextPos == nil)
        ? fNextPos!
        : min(fNextPos!, gNextPos!)

      fInclusion.length += 1
      gInclusion.length += 1

      let nextLength = nextPos - pos
      newSpanLengths.append(nextLength)
      if fNextPos != nil && fNextPos! == nextPos {
        fInclusions.append(fInclusion)
        fInclusion = SpanInclusion(index: index + 1, length: 0)
        fIndex += 1
        fPos = fNextPos!
      }
      if gNextPos != nil && gNextPos! == nextPos {
        gInclusions.append(gInclusion)
        gInclusion = SpanInclusion(index: index + 1, length: 0)
        gIndex += 1
        gPos = gNextPos!
      }
    }
    var newInputOrder = [Int](repeating: -1, count: newSpanLengths.count)
    var newInputIndex = 0
    for fInputIndex in f.input.order.domain() {
      let fOutputIndex = f.output.order[f.input.order.inverse[fInputIndex]]
      let fInc = fInclusions[fOutputIndex]
      for j in 0..<fInc.length {
        newInputOrder[fInc.index + j] = newInputIndex + j
      }
      newInputIndex += fInc.length
    }
    let input = Permutation(forwardMap: newInputOrder)
    var newOutputOrder = [Int](repeating: -1, count: newSpanLengths.count)
    var newOutputIndex = 0
    for gOutputIndex in g.output.order.codomain() {
      let gInputIndex = f.input.order[g.output.order.inverse[gOutputIndex]]
      let gInc = gInclusions[gInputIndex]
      for j in 0..<gInc.length {
        newOutputOrder[gInc.index + j] = newOutputIndex + j
      }
      newOutputIndex += gInc.length
    }
    let output = Permutation(forwardMap: newOutputOrder)
    return IntervalExchangeMap(
        spanLengths: newSpanLengths, inputOrder: input, outputOrder: output)
  }

  public func isIrreducible() -> Bool {
    let map = self.canonicalPermutation().forwardMap
    var highestSeen = -1
    for i in 0..<(map.count - 1) {
      if map[i] > highestSeen {
        highestSeen = map[i]
      }
      if highestSeen == i {
        return true
      }
    }
    return false
  }

  // "type" in the sense of EToIEM:
  // returns 0 if the final output span is shorter than the final
  // input span, 1 if the final input span is longer, and nil if the
  // two lengths are equal.
  public func type() -> Int? {
    let inputLength = input.lastSpan.length
    let outputLength = output.lastSpan.length
    if outputLength < inputLength {
      return 0
    }
    if inputLength < outputLength {
      return 1
    }
    return nil
  }

  // The Rauzy-Veech induction of the map.
  // EToIEM:
  //   f.recurse() = $\hat{R}(f)$
  //   f.recurse().spanLengths = $\lambda'$
  //   f.recurse().{input, output}.order = $\pi'$
  public func recurse() -> IntervalExchangeMap? {
    // EToIEM:
    //   lastInputIndex = $\alpha(0)$
    //   lastOutputIndex = $\alpha(1)$
    //   spanLengths[lastInputIndex] = $\lambda_{\alpha(0)}$
    //   spanLengths[lastOutputIndex] = $\lambda_{\alpha(1)}$
    let lastInputIndex = input.order.inverse[spanCount - 1]
    let lastOutputIndex = output.order.inverse[spanCount - 1]

    if spanLengths[lastOutputIndex] < spanLengths[lastInputIndex] {
      // type 0 in EToIEM.
      // Cut off the last output span, and trim the last input span to
      // match it.
      var newLengths = spanLengths
      newLengths[lastInputIndex] -= newLengths[lastOutputIndex]
      // Input permutation is unchanged, but in the output the former last
      // span now goes immediately after the trimmed span spans[lastInputIndex].
      let newInputMap = input.order.forwardMap
      var newOutputMap = output.order.forwardMap
      let trimmedCutoff = newOutputMap[lastInputIndex]
      for i in 0..<spanCount {
        if newOutputMap[i] == spanCount - 1 {
          newOutputMap[i] = trimmedCutoff + 1
        } else if newOutputMap[i] > trimmedCutoff {
          newOutputMap[i] += 1
        }
      }
      return IntervalExchangeMap(
          spanLengths: newLengths,
          inputOrder: Permutation(forwardMap: newInputMap),
          outputOrder: Permutation(forwardMap: newOutputMap))
    } else if spanLengths[lastInputIndex] < spanLengths[lastOutputIndex] {
      // type 1 in EToIEM
      // Remove the last span of the input, and cut its length
      // off the end of output.
      var newLengths = spanLengths
      newLengths[lastOutputIndex] -= newLengths[lastInputIndex]
      var newInputMap = input.order.forwardMap
      let newOutputMap = output.order.forwardMap
      let trimmedCutoff = newInputMap[lastOutputIndex]
      for i in 0..<spanCount {
        if newInputMap[i] == spanCount - 1 {
          newInputMap[i] = trimmedCutoff + 1
        } else if newInputMap[i] > trimmedCutoff {
          newInputMap[i] += 1
        }
      }
      return IntervalExchangeMap(
          spanLengths: newLengths,
          inputOrder: Permutation(forwardMap: newInputMap),
          outputOrder: Permutation(forwardMap: newOutputMap))
    }
    // Induction is not defined if the last spans on the input and
    // output are the same length.
    return nil
  }

  // EToIEM:
  //   f.recurse(count: n) = $\hat{R}^n(f)$
  public func recurse(count: Int) -> IntervalExchangeMap? {
    var result: IntervalExchangeMap? = self
    for _ in 0..<count {
      result = result?.recurse()
    }
    return result
  }

  private class SpanInclusion {
    var index: Int
    var length: Int
    init(index: Int, length: Int) {
      self.index = index
      self.length = length
    }
  }
}

// Assorted convenience constructors
extension IntervalExchangeMap {
  public static func identityOnLength(_ length: k) -> IntervalExchangeMap {
    let lengths = [length]
    return IntervalExchangeMap(
      spanLengths: lengths,
      inputOrder: Permutation.identity(size: 1),
      outputOrder: Permutation.identity(size: 1))
  }

  public static func rotationOnIntervalLength(
      _ intervalLength: k, rotationOffset: k) -> IntervalExchangeMap{
    let offset =
        (rotationOffset < k.zero())
          ? rotationOffset + intervalLength
          : rotationOffset
    let lengths = [intervalLength - offset, offset]
    let inputOrder = Permutation.identity(size: 2)
    let outputOrder = Permutation(forwardMap: [1, 0])
    return IntervalExchangeMap(
        spanLengths: lengths, inputOrder: inputOrder, outputOrder: outputOrder)
  }

  public static func linearCycle(
      intervalLength: k, cycleLength: Int) -> IntervalExchangeMap {
    let offset = intervalLength / k(cycleLength)
    return IntervalExchangeMap.rotationOnIntervalLength(
        intervalLength, rotationOffset: offset)
  }
}
