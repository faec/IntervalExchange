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

/*public class AlternateTranslationMap {
  public let input: IntervalDomain
  public let output: IntervalDomain
  // The map from input components to output components.
  public let indexMap: Permutation

  public init(
      input: IntervalDomain, output: IntervalDomain, indexMap: Permutation) {
    self.input = input
    self.output = output
    self.indexMap = indexMap
  }

  public class func compose(
      inner f: AlternateTranslationMap, outer g: AlternateTranslationMap) {
    if let intersection = f.output.intersectionWith(g.input) {
      let fCover = intersection.coveredBy(f.output)!
      let gCover = intersection.coveredBy(g.input)!

      var inputOrder = [Int](repeating: -1, count: newLengths.count)
      var inputIndex = 0
      for (fOutputIndex, fInputIndex) in f.indexMap.inverse {
        let coveredRange = fCover.indexRangeCoveredBy(coverIndex: fOutputIndex)
        for index in coveredRange {
          inputOrder[index] = inputIndex
          inputIndex += 1
        }
      }
      var outputOrder = [Int](repeating: -1, count: newLengths.count)
      var outputIndex = 0
      for (gInputIndex, gOutput)
      for i in intersection.indices {
        let fOutputIndex = fCover.indexMap[i]
        let gInputIndex = gCover.indexMap[i]

      }
    }
    return nil

  }
}*/

// Invariants:
//   outputIntervals.lengths() ==
//       outputOrder[inputOrder.inverse[inputIntervals.lengths()]]
public class IntervalTranslationMap {
  public typealias IntervalPoint = IntervalDomain.IndexedPoint

  // The smallest interval containing the input and output ranges.
  public let bounds: Interval

  // EToIEM: $d$
  public let intervalCount: Int
  // EToIEM:
  //   inputOrder.forwardMap = $\pi_0$
  //   outputOrder.forwardMap = $\pi_1$
  //   [inputOrder.inverseMap, outputOrder.inverseMap] = $\pi$
  //   inputIntervals = $I$
  //   inputIntervals[i] = $I_\alpha$, where $\alpha = i$
  //   inputIntervals[inputOrder[i]] = $\partial I_\gamma$ where $\gamma$ = i
  public let inputIntervals: IntervalDomain
  public let inputOrder: Permutation
  public let outputIntervals: IntervalDomain
  public let outputOrder: Permutation

  // EToIEM: the "monodromy invariant". Maps indices of inputIntervals to their
  // corresponding index in outputIntervals. Independent of interval lengths
  // or position other than relative order.
  public lazy var indexMap = outputOrder[inputOrder.inverse]

  public init(
      inputIntervals: IntervalDomain,
      outputIntervals: IntervalDomain,
      inputOrder: Permutation,
      outputOrder: Permutation) {
    self.intervalCount = inputIntervals.count
    self.bounds = Interval(
        containing: [inputIntervals.bounds, outputIntervals.bounds])
    self.inputIntervals = inputIntervals
    self.outputIntervals = outputIntervals
    self.inputOrder = inputOrder
    self.outputOrder = outputOrder
  }

  public init(_ ie: IntervalTranslationMap) {
    self.intervalCount = ie.intervalCount
    self.bounds = ie.bounds
    self.inputIntervals = ie.inputIntervals
    self.outputIntervals = ie.outputIntervals
    self.inputOrder = ie.inputOrder
    self.outputOrder = ie.outputOrder
  }

  // EToIEM: the "canonical involution".
  public init(inverseOf itm: IntervalTranslationMap) {
    self.intervalCount = itm.intervalCount
    self.bounds = itm.bounds
    self.inputIntervals = itm.outputIntervals
    self.outputIntervals = itm.inputIntervals
    self.inputOrder = itm.outputOrder
    self.outputOrder = itm.inputOrder
  }

  public subscript(_ inputPoint: IntervalPoint) -> IntervalPoint {
    let inputIndex = inputPoint.interval.index
    let outputIndex = outputOrder[inputOrder.inverse[inputIndex]]
    return outputIntervals[outputIndex].indexedPoint(offset: inputPoint.offset)
  }

  public subscript(position: k) -> k? {
    if let point = inputIntervals.indexedPointAtPosition(position) {
      return self[point].position
    }
    return nil
  }

  public subscript(_ intervals: IntervalDomain) -> IntervalDomain? {
    if let inputs = intervals.intersectionWith(inputIntervals) {
      var outputs: [Interval] = []
      let cover = inputs.coveredBy(inputIntervals)!
      for interval in inputs {
        // Get the index in our inputIntervals of the interval containing this
        // one.
        let inputContainerIndex = cover.indexMap[interval.index]
        let inputContainer = inputIntervals[inputContainerIndex]
        let outputContainerIndex = indexMap[inputContainerIndex]
        let outputContainer = outputIntervals[outputContainerIndex]
        let inputOffset = interval.leftBoundary - inputContainer.leftBoundary
        outputs.append(
          Interval(
              leftBoundary: outputContainer.leftBoundary + inputOffset,
              length: interval.length))
      }
      return IntervalDomain(fromSortedIntervals: outputs)
    }
    return nil
  }


  // EToIEM: $w = \Omega_\pi(\lambda)$
  public func intervalOffsets() -> [k] {
    return (0..<intervalCount).map { (intervalIndex: Int) -> k in
      let inputIndex = inputOrder[intervalIndex]
      let outputIndex = outputOrder[intervalIndex]
      let inputPos = inputIntervals[inputIndex].leftBoundary
      let outputPos = outputIntervals[outputIndex].leftBoundary

      return outputPos - inputPos
    }
  }

  public func restrictToInputRange(
      _ inputRange: IntervalDomain) -> IntervalTranslationMap? {
    // TODO: implement this
    /*if let output = self[inputRange] {
    }*/
    return nil
  }

  public func restrictToOutputRange(
      _ outputRange: IntervalDomain) -> IntervalTranslationMap {
    return self
  }
}

// Unlike EToIEM, this class doesn't require that bounds.leftBoundary == 0
// Invariants:
//   inputIntervals.bounds == outputIntervals.bounds == bounds
//   inputIntervals.totalLength() = bounds.length
public class IntervalExchangeMap: IntervalTranslationMap {

  // EToIEM: $\lambda$
  // This is technically redundant, because it's generated by
  // inputOrder.inverse[inputIntervals.lengths()], but it's here to emphasize
  // that it is one of the fundamental parameters of an exchange map,
  public let intervalLengths: [k]

  public init(
      intervalLengths: [k], leftBoundary: k,
      inputOrder: Permutation, outputOrder: Permutation) {
    if intervalLengths.count != inputOrder.size() ||
        intervalLengths.count != outputOrder.size() {
      fatalError("IntervalTranslationMap.init arrays must be the same length")
    }
    self.intervalLengths = intervalLengths

    let inputIntervals = IntervalDomain(
        fromLengths: inputOrder[intervalLengths], leftBoundary: leftBoundary)
    let outputIntervals = IntervalDomain(
        fromLengths: outputOrder[intervalLengths], leftBoundary: leftBoundary)
    super.init(
        inputIntervals: inputIntervals,
        outputIntervals: outputIntervals,
        inputOrder: inputOrder,
        outputOrder: outputOrder)
  }

  public init(inverseOf iem: IntervalExchangeMap) {
    self.intervalLengths = iem.intervalLengths
    super.init(inverseOf: iem)
  }

  public subscript(_ f: IntervalExchangeMap) -> IntervalExchangeMap {
    return IntervalExchangeMap.compose(inner: f, outer: self)!
  }

  // The Rauzy-Veech induction of the map.
  // EToIEM:
  //   f.induction() = $\hat{R}(f)$
  //   f.induction().intervalLengths = $\lambda'$
  //   f.induction().{input, output}.order = $\pi'$
  public func induction() -> IntervalExchangeMap? {
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
          intervalLengths: newLengths, leftBoundary: bounds.leftBoundary,
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
          intervalLengths: newLengths, leftBoundary: bounds.leftBoundary,
          inputOrder: Permutation(forwardMap: newInputMap),
          outputOrder: Permutation(forwardMap: newOutputMap))
    }
    // Induction is not defined if the last intervals on the input and
    // output are the same length.
    return nil
  }

  // EToIEM:
  //   f.induction(count: n) = $\hat{R}^n(f)$
  public func induction(count: Int) -> IntervalExchangeMap? {
    var result: IntervalExchangeMap? = self
    for _ in 0..<count {
      result = result?.induction()
    }
    return result
  }

  public static func compose(
      inner f: IntervalExchangeMap,
      outer g: IntervalExchangeMap) -> IntervalExchangeMap? {
    if let intersection = f.outputIntervals.intersectionWith(g.inputIntervals) {
      guard intersection.totalLength() == f.inputIntervals.totalLength()
          else { return nil}
      let fCover = intersection.coveredBy(f.outputIntervals)!
      let gCover = intersection.coveredBy(g.inputIntervals)!

      let newLengths = intersection.lengths()
      var inputMap = [Int](repeating: -1, count: newLengths.count)
      var inputIndex = 0
      // Traverse f's intervals in input order
      for (_, fOutputIndex) in f.indexMap {
        let coveredRange = fCover.indexRangeCoveredBy(coverIndex: fOutputIndex)
        for index in coveredRange {
          inputMap[index] = inputIndex
          inputIndex += 1
        }
      }
      var outputMap = [Int](repeating: -1, count: newLengths.count)
      var outputIndex = 0
      // Traverse g's intervals in output order
      for (_, gInputIndex) in g.indexMap.inverse {
        let coveredRange = gCover.indexRangeCoveredBy(coverIndex: gInputIndex)
        for index in coveredRange {
          outputMap[index] = outputIndex
          outputIndex += 1
        }
      }
      return IntervalExchangeMap(
        intervalLengths: newLengths,
        leftBoundary: f.inputIntervals.first!.leftBoundary,
        inputOrder: Permutation(forwardMap: inputMap),
        outputOrder: Permutation(forwardMap: outputMap))
    }
    return nil
  }

  public func raisedToPower(_ n: Int) -> IntervalExchangeMap {
    if n == 0 {
      return IntervalExchangeMap.identity(length: inputIntervals.bounds.length)
    }
    let baseMap = (n > 0) ? self : IntervalExchangeMap(inverseOf: self)
    var cur = baseMap
    for _ in 1..<n {
      cur = baseMap[cur]
    }
    return cur
  }

  public func isIrreducible() -> Bool {
    let map = self.indexMap.forwardMap
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

  // An alternate implementation of intervalOffsets for exchange maps
  // that more closely resembles the formulas in EToIEM.
  public func alternateIntervalOffsets() -> [k] {
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

  //private func _firstReturnMap(
  //    range: IntervalDomain, acc: [(Int, [])])

  // Given boundaries within this map, returns the first-return map
  // for this subinterval as a new map with its input intervals equal to
  // the given range.
  /*public func firstReturnMap(range: IntervalDomain) -> ReturnMap {
    var intervals = range
    var returned: IntervalDomain? = nil
    while true {
      let outputs = self[intervals]!

      let returnedOutput = outputs.intersect()
    }
  }*/

  private class IntervalInclusion {
    var index: Int
    var length: Int
    init(index: Int, length: Int) {
      self.index = index
      self.length = length
    }
  }

  public class ReturnMap: IntervalTranslationMap {
    public let originalMap: IntervalTranslationMap
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
        ie: IntervalTranslationMap,
        originalMap: IntervalTranslationMap,
        powers: [Int]) {
      self.originalMap = originalMap
      self.powers = powers
      super.init(ie)
    }
  }
}

// Assorted convenience constructors
extension IntervalExchangeMap {
  public static func identity(
      length: k, leftBoundary: k = k.zero()) -> IntervalExchangeMap {
    let lengths = [length]
    return IntervalExchangeMap(
      intervalLengths: lengths, leftBoundary: leftBoundary,
      inputOrder: Permutation.identity(size: 1),
      outputOrder: Permutation.identity(size: 1))
  }

  public static func rotationOnInterval(
      _ interval: Interval, rotationOffset: k) -> IntervalExchangeMap {
    let offset =
        (rotationOffset < k.zero())
          ? rotationOffset + interval.length
          : rotationOffset
    let lengths = [interval.length - offset, offset]
    let inputOrder = Permutation.identity(size: 2)
    let outputOrder = Permutation(forwardMap: [1, 0])
    return IntervalExchangeMap(
        intervalLengths: lengths, leftBoundary: interval.leftBoundary,
        inputOrder: inputOrder, outputOrder: outputOrder)
  }

  public static func linearCycleOnInterval(
      _ interval: Interval, cycleLength: Int) -> IntervalExchangeMap {
    let offset = interval.length / k(cycleLength)
    return IntervalExchangeMap.rotationOnInterval(
        interval, rotationOffset: offset)
  }
}

/*public class IntervalExchangeRotationMap {
  public let bounds: Interval
  public let pivotPos: k

  public init(bounds: IntervalProtocol, pivotPos: k) {
    self.bounds = Interval(bounds)
    self.pivotPos = pivotPos
  }

  public class RaisedToPower: IntervalExchangeRotationMap {
    public let power: Int

  }
}*/
