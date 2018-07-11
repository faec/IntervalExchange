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
  public typealias IntervalPoint = SortedIntervals.IndexedPoint

  // EToIEM: $d$
  public let intervalCount: Int
  // EToIEM: $\lambda$
  public let intervalLengths: [k]
  // EToIEM:
  //   inputOrder.forwardMap = $\pi_0$
  //   outputOrder.forwardMap = $\pi_1$
  //   [inputOrder.inverseMap, outputOrder.inverseMap] = $\pi$
  //   inputIntervals = $I$
  //   inputIntervals[i] = $I_\alpha$, where $\alpha = i$
  //   inputIntervals[inputOrder[i]] = $\partial I_\gamma$ where $\gamma$ = i
  public let inputIntervals: SortedIntervals
  public let inputOrder: Permutation
  public let outputIntervals: SortedIntervals
  public let outputOrder: Permutation

  private var _inverse: IntervalExchangeMap?

  private init(
      intervalLengths: [k],
      inputIntervals: SortedIntervals,
      outputIntervals: SortedIntervals,
      inputOrder: Permutation,
      outputOrder: Permutation,
      inverse: IntervalExchangeMap? = nil) {
    self.intervalCount = intervalLengths.count
    self.intervalLengths = intervalLengths
    self.inputIntervals = inputIntervals
    self.outputIntervals = outputIntervals
    self.inputOrder = inputOrder
    self.outputOrder = outputOrder
    self._inverse = inverse
  }

  public init(_ ie: IntervalExchangeMap) {
    self.intervalCount = ie.intervalLengths.count
    self.intervalLengths = ie.intervalLengths
    self.inputIntervals = ie.inputIntervals
    self.outputIntervals = ie.outputIntervals
    self.inputOrder = ie.inputOrder
    self.outputOrder = ie.outputOrder
    self._inverse = ie.inverse
  }

  public convenience init(
      intervalLengths: [k],
      inputOrder: Permutation, outputOrder: Permutation) {
    if intervalLengths.count != inputOrder.size() ||
        intervalLengths.count != outputOrder.size() {
      fatalError("IntervalExchangeMap.init arrays must be the same length")
    }

    let inputIntervals = SortedIntervals(
        fromLengths: inputOrder[intervalLengths])
    let outputIntervals = SortedIntervals(
        fromLengths: outputOrder[intervalLengths])
    self.init(intervalLengths: intervalLengths,
        inputIntervals: inputIntervals,
        outputIntervals: outputIntervals,
        inputOrder: inputOrder,
        outputOrder: outputOrder)
  }

  public subscript(_ inputPoint: IntervalPoint) -> IntervalPoint {
    let inputIndex = inputPoint.interval.index
    let outputIndex = outputOrder[inputOrder.inverse[inputIndex]]
    return outputIntervals[outputIndex].indexedPoint(offset: inputPoint.offset)
  }

  public subscript(_ f: IntervalExchangeMap) -> IntervalExchangeMap {
    return IntervalExchangeMap.compose(inner: f, outer: self)
  }

  // EToIEM: the "canonical involution".
  // TODO: this leaks memory through a ref cycle, find a better design.
  public var inverse: IntervalExchangeMap {
    if _inverse == nil {
      _inverse = IntervalExchangeMap(
          intervalLengths: intervalLengths,
          inputIntervals: outputIntervals,
          outputIntervals: inputIntervals,
          inputOrder: outputOrder, outputOrder: inputOrder,
          inverse: self)
    }
    return _inverse!
  }

  // EToIEM: the "monodromy invariant". Independent of intervalLengths.
  public func canonicalPermutation() -> Permutation {
    return outputOrder[inputOrder.inverse]
  }

  // EToIEM: $w = \Omega_\pi(\lambda)$
  public func intervalOffsets() -> [k] {
    return (0..<intervalCount).map { (intervalIndex: Int) -> k in
      var total = k.zero()
      for i in 0..<intervalCount {
        if outputOrder[i] < outputOrder[intervalIndex] {
          total += intervalLengths[i]
        }
        if inputOrder[i] < inputOrder[intervalIndex] {
          total -= intervalLengths[i]
        }
      }
      return total
    }
  }

  public static func compose(
      inner f: IntervalExchangeMap,
      outer g: IntervalExchangeMap) -> IntervalExchangeMap {
    let fLengths = f.intervalLengths
    let gLengths = g.intervalLengths
    var fIndex = 0
    var gIndex = 0
    var fInclusion = IntervalInclusion(index: 0, length: 0)
    var gInclusion = IntervalInclusion(index: 0, length: 0)
    var fInclusions: [IntervalInclusion] = []
    var gInclusions: [IntervalInclusion] = []
    var newIntervalLengths: [k] = []
    var nextPos = k.zero()
    var fPos = k.zero()
    var gPos = k.zero()

    while fIndex < fLengths.count || gIndex < gLengths.count {
      let index = newIntervalLengths.count
      let pos: k = nextPos
      let fLength =
          (fIndex < f.intervalCount)
        ? f.outputIntervals[fIndex].length
        : nil
      let gLength =
          (gIndex < gLengths.count)
        ? g.inputIntervals[gIndex].length
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
      newIntervalLengths.append(nextLength)
      if fNextPos != nil && fNextPos! == nextPos {
        fInclusions.append(fInclusion)
        fInclusion = IntervalInclusion(index: index + 1, length: 0)
        fIndex += 1
        fPos = fNextPos!
      }
      if gNextPos != nil && gNextPos! == nextPos {
        gInclusions.append(gInclusion)
        gInclusion = IntervalInclusion(index: index + 1, length: 0)
        gIndex += 1
        gPos = gNextPos!
      }
    }
    var newInputOrder = [Int](repeating: -1, count: newIntervalLengths.count)
    var newInputIndex = 0
    for fInputIndex in f.inputOrder.domain() {
      let fOutputIndex = f.outputOrder[f.inputOrder.inverse[fInputIndex]]
      let fInc = fInclusions[fOutputIndex]
      for j in 0..<fInc.length {
        newInputOrder[fInc.index + j] = newInputIndex + j
      }
      newInputIndex += fInc.length
    }
    let input = Permutation(forwardMap: newInputOrder)
    var newOutputOrder = [Int](repeating: -1, count: newIntervalLengths.count)
    var newOutputIndex = 0
    for gOutputIndex in g.outputOrder.codomain() {
      let gInputIndex = f.inputOrder[g.outputOrder.inverse[gOutputIndex]]
      let gInc = gInclusions[gInputIndex]
      for j in 0..<gInc.length {
        newOutputOrder[gInc.index + j] = newOutputIndex + j
      }
      newOutputIndex += gInc.length
    }
    let output = Permutation(forwardMap: newOutputOrder)
    return IntervalExchangeMap(
        intervalLengths: newIntervalLengths,
        inputOrder: input, outputOrder: output)
  }

  public func raisedToPower(_ n: Int) -> IntervalExchangeMap {
    if n == 0 {
      return IntervalExchangeMap.identity(length: inputIntervals.bounds.length)
    }
    let baseMap = (n > 0) ? self : self.inverse
    var cur = baseMap
    for _ in 1..<n {
      cur = baseMap[cur]
    }
    return cur
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
  // returns 0 if the final output interval is shorter than the final
  // input interval, 1 if the final input interval is longer, and nil if the
  // two lengths are equal.
  public func type() -> Int? {
    let inputLength = inputIntervals.last!.length
    let outputLength = outputIntervals.last!.length
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
  //   f.recurse().intervalLengths = $\lambda'$
  //   f.recurse().{input, output}.order = $\pi'$
  public func recurse() -> IntervalExchangeMap? {
    // EToIEM:
    //   lastInputIndex = $\alpha(0)$
    //   lastOutputIndex = $\alpha(1)$
    //   intervalLengths[lastInputIndex] = $\lambda_{\alpha(0)}$
    //   intervalLengths[lastOutputIndex] = $\lambda_{\alpha(1)}$
    let lastInputIndex = inputOrder.inverse[intervalCount - 1]
    let lastOutputIndex = outputOrder.inverse[intervalCount - 1]

    if intervalLengths[lastOutputIndex] < intervalLengths[lastInputIndex] {
      // type 0 in EToIEM.
      // Cut off the last output interval, and trim the last input interval to
      // match it.
      var newLengths = intervalLengths
      newLengths[lastInputIndex] -= newLengths[lastOutputIndex]
      // Input permutation is unchanged, but in the output the former last
      // interval now goes immediately after the trimmed interval
      // outputIntervals[outputOrder[lastInputIndex]].
      let newInputMap = inputOrder.forwardMap
      var newOutputMap = outputOrder.forwardMap
      let trimmedCutoff = newOutputMap[lastInputIndex]
      for i in 0..<intervalCount {
        if newOutputMap[i] == intervalCount - 1 {
          newOutputMap[i] = trimmedCutoff + 1
        } else if newOutputMap[i] > trimmedCutoff {
          newOutputMap[i] += 1
        }
      }
      return IntervalExchangeMap(
          intervalLengths: newLengths,
          inputOrder: Permutation(forwardMap: newInputMap),
          outputOrder: Permutation(forwardMap: newOutputMap))
    } else if
        intervalLengths[lastInputIndex] < intervalLengths[lastOutputIndex] {
      // type 1 in EToIEM
      // Remove the last interval of the input, and cut its length
      // off the end of output.
      var newLengths = intervalLengths
      newLengths[lastOutputIndex] -= newLengths[lastInputIndex]
      var newInputMap = inputOrder.forwardMap
      let newOutputMap = outputOrder.forwardMap
      let trimmedCutoff = newInputMap[lastOutputIndex]
      for i in 0..<intervalCount {
        if newInputMap[i] == intervalCount - 1 {
          newInputMap[i] = trimmedCutoff + 1
        } else if newInputMap[i] > trimmedCutoff {
          newInputMap[i] += 1
        }
      }
      return IntervalExchangeMap(
          intervalLengths: newLengths,
          inputOrder: Permutation(forwardMap: newInputMap),
          outputOrder: Permutation(forwardMap: newOutputMap))
    }
    // Induction is not defined if the last intervals on the input and
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

  public class ReturnMap: IntervalExchangeMap {
    public let originalMap: IntervalExchangeMap
    // The power that the original map had to be raised to on each input
    // segment to generate this map:
    // for interval in map.inputIntervals {
    //   let power = originalMap.raisedToPower(powers[interval.index])
    //   invariant: if x: k is in interval (interval.containsPosition(x)) then
    //     power[x] == map[x].
    // }
    // EToIEM: powers[k] = $n_{k+1}$ in Lemma 4.2
    public let powers: [Int]

    fileprivate init(
        ie: IntervalExchangeMap,
        originalMap: IntervalExchangeMap,
        powers: [Int]) {
      self.originalMap = originalMap
      self.powers = powers
      super.init(ie)
    }
  }

  public subscript(_ intervals: SortedIntervals) -> SortedIntervals {
    let inputs = intervals.asRefinementOf(inputIntervals)
    var outputs: [Interval] = []
    for input in inputs {
      let inputContainer = input.containingInterval
      let outputIndex = outputOrder[inputOrder.inverse[inputContainer.index]]
      let outputContainer = outputIntervals[outputIndex]
      let inputOffset = input.leftBoundary - inputContainer.leftBoundary
      outputs.append(
        Interval(
            leftBoundary: outputContainer.leftBoundary + inputOffset,
            length: input.length))
    }
    return SortedIntervals(fromSortedList: outputs)
  }

  // Given boundaries within this map, returns the first-return map
  // for this subinterval as a new map with domain length
  // (rightBoundary - leftBoundary).
  public func firstReturnMap(bounds: Interval) -> ReturnMap {
    var intervals = SortedIntervals(fromSortedList: [bounds])
    while true {
      //let outputs = self[inputs]
    }
  }

  private class IntervalInclusion {
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
  public static func identity(length: k) -> IntervalExchangeMap {
    let lengths = [length]
    return IntervalExchangeMap(
      intervalLengths: lengths,
      inputOrder: Permutation.identity(size: 1),
      outputOrder: Permutation.identity(size: 1))
  }

  public static func rotationOnIntervalLength(
      _ intervalLength: k, rotationOffset: k) -> IntervalExchangeMap {
    let offset =
        (rotationOffset < k.zero())
          ? rotationOffset + intervalLength
          : rotationOffset
    let lengths = [intervalLength - offset, offset]
    let inputOrder = Permutation.identity(size: 2)
    let outputOrder = Permutation(forwardMap: [1, 0])
    return IntervalExchangeMap(
    intervalLengths: lengths, inputOrder: inputOrder, outputOrder: outputOrder)
  }

  public static func linearCycle(
      intervalLength: k, cycleLength: Int) -> IntervalExchangeMap {
    let offset = intervalLength / k(cycleLength)
    return IntervalExchangeMap.rotationOnIntervalLength(
        intervalLength, rotationOffset: offset)
  }
}
