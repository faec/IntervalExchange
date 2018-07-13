import XCTest
@testable import IntervalLib

final class IntervalExchangeTests: XCTestCase {
  func test2Cycle() {
    let f = IntervalExchangeMap.linearCycleOnInterval(
        Interval(leftBoundary: k.zero(), rightBoundary: k.one()),
        cycleLength: 2)
    XCTAssertEqual(
        f.inputIntervals.leftBoundaries(), [k.zero(), k(1, over: 2)])
    XCTAssertEqual(
        f.outputIntervals.leftBoundaries(), [k.zero(), k(1, over: 2)])

    let testValues = [
        k.zero(), k(1, over: 10), k(3, over: 7), k(1, over: 2),
        k(4, over: 7), k(3, over: 4), k(9, over: 10)]
    for inputPos in testValues {
      let inputPoint = f.inputIntervals.indexedPointAtPosition(inputPos)
      XCTAssertNotNil(inputPoint)
      if inputPoint != nil {
        let outputPos = f[inputPoint!].position
        XCTAssertEqual((inputPos - outputPos).abs(), k(1, over: 2))
        let inverse = IntervalExchangeMap(inverseOf: f)
        let doubleMapPos = inverse[f[inputPoint!]].position
        XCTAssertEqual(inputPos, doubleMapPos)
      }
    }
  }

  func test5Cycle() {
    let f = IntervalExchangeMap.linearCycleOnInterval(
        Interval(leftBoundary: k.zero(), rightBoundary: k.one()),
        cycleLength: 5)
    XCTAssertEqual(
        f.inputIntervals.leftBoundaries(), [k.zero(), k(4, over: 5)])
    XCTAssertEqual(
        f.outputIntervals.leftBoundaries(), [k.zero(), k(1, over: 5)])

    let noWrapValues = [
      k.zero(), k(1, over: 10), k(3, over: 7), k(1, over: 2),
      k(4, over: 7), k(3, over: 4)]
    let wrapValues = [ k(4, over: 5), k(9, over: 10) ]
    for inputPos in noWrapValues {
      let inputPoint = f.inputIntervals.indexedPointAtPosition(inputPos)
      XCTAssertNotNil(inputPoint)
      if inputPoint != nil {
        let outputPos = f[inputPoint!].position
        XCTAssertEqual(outputPos - inputPos, k(1, over: 5))
      }
    }
    for inputPos in wrapValues {
      let inputPoint = f.inputIntervals.indexedPointAtPosition(inputPos)
      XCTAssertNotNil(inputPoint)
      if inputPoint != nil {
        let outputPos = f[inputPoint!].position
        XCTAssertEqual(inputPos - outputPos, k(4, over: 5))
      }
    }
  }

  func testComposeSimpleCycle() {
    let f = IntervalExchangeMap.linearCycleOnInterval(
        Interval(leftBoundary: k.zero(), rightBoundary: k.one()),
        cycleLength: 5)
    let g = f[f]

    // Check the input / output positions.
    XCTAssertEqual(g.inputIntervals.leftBoundaries(),
        [k.zero(), k(3, over: 5), k(4, over: 5)])
    XCTAssertEqual(g.outputIntervals.leftBoundaries(),
        [k.zero(), k(1, over: 5), k(2, over: 5)])

    // Check that various input points map to the expected position.
    let testPositions = [
      k.zero(), k(1, over: 10), k(3, over: 7), k(1, over: 2),
      k(4, over: 7), k(3, over: 4), k(9, over: 10)]
    let cutoff = k(3, over: 5)
    for pos in testPositions {
      let input = g.inputIntervals.indexedPointAtPosition(pos)
      XCTAssertNotNil(input)
      if input != nil {
        let expected = (pos >= cutoff) ? pos - cutoff : pos + k(2, over: 5)
        let output = g[input!]
        let actual = output.position
        XCTAssertEqual(expected, actual, "\(pos) should map to \(expected)")
      }
    }

    // Check that the permutation from input to output is right.
    XCTAssertEqual(g.canonicalPermutation().forwardMap, [2, 0, 1])
  }

  func test3Compose() {
    let lengths =
        [k(1, over: 5), k(1, over: 3), k(7, over: 15)]
    let inputOrder = Permutation(forwardMap: [0, 1, 2])
    let outputOrder = Permutation(forwardMap: [1, 2, 0])
    let f = IntervalExchangeMap(
        intervalLengths: lengths, leftBoundary: k.zero(),
        inputOrder: inputOrder, outputOrder: outputOrder)
    let g = f[f]
    XCTAssertEqual(g.intervalLengths, [
        k(1, over: 5), k(4, over: 15), k(1, over: 15),
        k(2, over: 15), k(1, over: 3)])
    // TODO: Check the permutations and stuff too.
  }

  func test4Compose() {
    let lengths =
        [k(1, over: 10), k(1, over: 6), k(1, over: 4), k(29, over: 60)]
    let inputOrder = Permutation(forwardMap: [1, 3, 0, 2])
    let outputOrder = Permutation(forwardMap: [2, 0, 3, 1])
    let f = IntervalExchangeMap(
        intervalLengths: lengths, leftBoundary: k.zero(),
        inputOrder: inputOrder, outputOrder: outputOrder)
    let g = f[f]
    XCTAssertEqual(g.intervalLengths, [
        k(1, over: 6), k(1, over: 12), k(1, over: 10), k(3, over: 10),
        k(1, over: 10), k(1, over: 12), k(1, over: 6)])
  }

  func testRepeatedCompose() {
    let lengths = [k(1, over: 3), k(1, over: 5), k(1, over: 2)]
    let inputOrder = Permutation.identity(size: 3)
    let outputOrder = Permutation(forwardMap: [1, 2, 0])
    let f = IntervalExchangeMap(
        intervalLengths: lengths, leftBoundary: k.zero(),
        inputOrder: inputOrder, outputOrder: outputOrder)
    var g = f
    while g.intervalLengths.max()! != k(1, over: 30) {
      g = f[g]
    }
    XCTAssertEqual(g.intervalLengths.min()!, k(1, over: 30))
    XCTAssertEqual(
        g.canonicalPermutation().forwardMap,
        [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
         23, 24, 25, 26, 27, 28, 29, 30, 0, 1, 2, 3, 4, 5])
  }

  // TODO: add composition tests that aren't just exponentiation

  func testLemma1_5() {
    // "Test" EToIEM's Lemma 1.5: $\lambda \cdot w = 0$.
    let lengths =
        [k(1, over: 10), k(1, over: 6), k(1, over: 4), k(29, over: 60)]
    let inputOrder = Permutation.identity(size: 4)
    let outputOrder = Permutation(forwardMap: [3, 2, 1, 0])
    let f = IntervalExchangeMap(
        intervalLengths: lengths, leftBoundary: k.zero(),
        inputOrder: inputOrder, outputOrder: outputOrder)

    let λ: [k] = f.intervalLengths
    let w: [k] = f.intervalOffsets()
    XCTAssertEqual(λ.dot(w), k.zero())
  }

  func testIsIrreducible() {

  }

  func testRecurse() {
    // This test case is drawn from Example 2.2 of EToIEM.
    let A = 0, B = 1, C = 2, D = 3, E = 4
    // "inverseMap" because "pi" is the inverse of "pi_0" and "pi_1".
    let inputOrder = Permutation(inverseMap: [B, C, A, E, D])
    let outputOrder = Permutation(inverseMap: [A, E, B, D, C])
    let lengths = [k(1, over: 15), k(1, over: 12),
        k(1, over: 4), k(1, over: 10), k(1, over: 3)]
    let f = IntervalExchangeMap(
        intervalLengths: lengths, leftBoundary: k.zero(),
        inputOrder: inputOrder, outputOrder: outputOrder)

    XCTAssert(f.intervalLengths[D] < f.intervalLengths[C])
    XCTAssertEqual(f.type(), 1)
    let r = f.recurse()
    XCTAssertNotNil(r)
    if r != nil {
      XCTAssertEqual(r!.inputOrder.inverseMap, [B, C, D, A, E])
      XCTAssertEqual(r!.outputOrder.inverseMap, [A, E, B, D, C])
    }
  }
}
