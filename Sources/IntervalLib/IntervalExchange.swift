public typealias Q = GmpRational
public typealias k = Q

public class IntervalExchangeMap {
  public typealias SpanPoint = SpanEmbedding.Span.Point

  public let spanCount: Int
  // EToIEM: spanLengths = $\lambda$
  public let spanLengths: [k]
  // EToIEM:
  //   input.order.forwardMap = $\pi_0$
  //   input.spans[input.order[gamma]] = $\partial I_\gamma$
  public let input: SpanEmbedding
  // EToIEM: output.order.forwardMap = $\pi_1$
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

  // "Canonical involution" in EToIEM.
  public var inverse: IntervalExchangeMap {
    if _inverse == nil {
      _inverse = IntervalExchangeMap(
          spanLengths: spanLengths, input: output, output: input, inverse: self)
    }
    return _inverse!
  }

  // The "monodromy invariant" in EToIEM. Independent of spanLengths.
  public func canonicalPermutation() -> Permutation {
    return output.order[input.order.inverse]
  }

  public func domain() -> SpanEmbedding {
    return input
  }

  public func codomain() -> SpanEmbedding {
    return output
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
