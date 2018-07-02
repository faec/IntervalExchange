import XCTest
@testable import IntervalLib

final class IntervalExchangeTests: XCTestCase {
  func test2Cycle() {
    let f = IntervalExchangeMap.linearCycle(
        intervalLength: k.one(), cycleLength: 2)
    XCTAssertEqual(f.input.leftBoundaries(), [k.zero(), k(1, over: 2)])
    XCTAssertEqual(f.output.leftBoundaries(), [k.zero(), k(1, over: 2)])

    let testValues = [
      k.zero(), k(1, over: 10), k(3, over: 7), k(1, over: 2),
      k(4, over: 7), k(3, over: 4), k(9, over: 10)]
    for inputPos in testValues {
      let inputPoint = f.input.pointForPosition(inputPos)
      XCTAssertNotNil(inputPoint)
      if inputPoint != nil {
        let outputPos = f[inputPoint!].position
        XCTAssertEqual((inputPos - outputPos).abs(), k(1, over: 2))
        let doubleMapPos = f.inverse[f[inputPoint!]].position
        XCTAssertEqual(inputPos, doubleMapPos)
      }
    }
  }

  func test5Cycle() {
    let f = IntervalExchangeMap.linearCycle(
        intervalLength: k.one(), cycleLength: 5)
    XCTAssertEqual(f.input.leftBoundaries(), [k.zero(), k(4, over: 5)])
    XCTAssertEqual(f.output.leftBoundaries(), [k.zero(), k(1, over: 5)])

    let noWrapValues = [
      k.zero(), k(1, over: 10), k(3, over: 7), k(1, over: 2),
      k(4, over: 7), k(3, over: 4)]
    let wrapValues = [ k(4, over: 5), k(9, over: 10) ]
    for inputPos in noWrapValues {
      let inputPoint = f.input.pointForPosition(inputPos)
      XCTAssertNotNil(inputPoint)
      if inputPoint != nil {
        let outputPos = f[inputPoint!].position
        XCTAssertEqual(outputPos - inputPos, k(1, over: 5))
      }
    }
    for inputPos in wrapValues {
      let inputPoint = f.input.pointForPosition(inputPos)
      XCTAssertNotNil(inputPoint)
      if inputPoint != nil {
        let outputPos = f[inputPoint!].position
        XCTAssertEqual(inputPos - outputPos, k(4, over: 5))
      }
    }
  }

  func testComposeSimpleCycle() {
    let f = IntervalExchangeMap.linearCycle(
        intervalLength: k.one(), cycleLength: 5)
    let g = f[f]

    // Check the input / output positions.
    XCTAssertEqual(g.input.leftBoundaries(),
        [k.zero(), k(3, over: 5), k(4, over: 5)])
    XCTAssertEqual(g.output.leftBoundaries(),
        [k.zero(), k(1, over: 5), k(2, over: 5)])

    // Check that various input points map to the expected position.
    let testPositions = [
      k.zero(), k(1, over: 10), k(3, over: 7), k(1, over: 2),
      k(4, over: 7), k(3, over: 4), k(9, over: 10)]
    let cutoff = k(3, over: 5)
    for pos in testPositions {
      let input = g.input.pointForPosition(pos)
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

  func testCompose() {
    let lengths =
        [k(1, over: 5), k(1, over: 3), k(7, over: 15)]
    let inputOrder = Permutation(forwardMap: [0, 1, 2])
    let outputOrder = Permutation(forwardMap: [1, 2, 0])
    let f = IntervalExchangeMap(
        spanLengths: lengths, inputOrder: inputOrder, outputOrder: outputOrder)
    let g = f[f]
    XCTAssertEqual(g.spanLengths, [
        k(1, over: 6), k(1, over: 12), k(1, over: 6), k(7, over: 30),
        k(1, over: 10), k(3, over: 20), k(1, over: 10)])
  }

  /*func testCompose() {
    let lengths =
        [k(1, over: 10), k(1, over: 6), k(1, over: 4), k(29, over: 60)]
    let inputOrder = Permutation(forwardMap: [1, 3, 0, 2])
    let outputOrder = Permutation(forwardMap: [2, 0, 3, 1])
    let f = IntervalExchangeMap(
        inputOrder: inputOrder, outputOrder: outputOrder,
        spanLengths: lengths)
    let g = f[f]
    XCTAssertEqual(g.spanLengths, [
        k(1, over: 6), k(1, over: 12), k(1, over: 6), k(7, over: 30),
        k(1, over: 10), k(3, over: 20), k(1, over: 10)])
  }*/

  // TODO: add composition tests that aren't just exponentiation
}
