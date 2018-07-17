import XCTest
@testable import IntervalLib

final class IntervalDomainTests: XCTestCase {
  override func setUp() {
      super.setUp()
      continueAfterFailure = true
  }

  func testIntersection() {
    continueAfterFailure = false
    let domain0 = IntervalDomain(fromSortedIntervals: [
      Interval(leftBoundary: k.zero(), rightBoundary: k(1, over: 3)),
      Interval(leftBoundary: k(1, over: 3), rightBoundary: k(2, over: 5)),
      Interval(leftBoundary: k(2, over: 3), rightBoundary: k.one())])
    let domain1 = IntervalDomain(fromSortedIntervals: [
      Interval(leftBoundary: k(1, over: 4), rightBoundary: k(1, over: 2)),
      Interval(leftBoundary: k(2, over: 3), rightBoundary: k(2))])
    let domain2 = IntervalDomain(
        fromInterval: Interval(leftBoundary: k.zero(), rightBoundary: k.one()))
    if let intersection = domain0.intersectionWith(domain1) {
      XCTAssertEqual(intersection.count, 3)
      let int0 = intersection[0]
      XCTAssertEqual(int0.leftBoundary, k(1, over: 4))
      XCTAssertEqual(int0.rightBoundary, k(1, over: 3))
      let int1 = intersection[1]
      XCTAssertEqual(int1.leftBoundary, k(1, over: 3))
      XCTAssertEqual(int1.rightBoundary, k(2, over: 5))
      let int2 = intersection[2]
      XCTAssertEqual(int2.leftBoundary, k(2, over: 3))
      XCTAssertEqual(int2.rightBoundary, k.one())

      let cover0 = intersection.coveredBy(domain0)
      XCTAssertNotNil(cover0)
      XCTAssertEqual(cover0!.indexMap[0], 0)
      XCTAssertEqual(cover0!.indexMap[1], 1)
      XCTAssertEqual(cover0!.indexMap[2], 2)

      let cover1 = intersection.coveredBy(domain1)
      XCTAssertNotNil(cover1)
      XCTAssertEqual(cover1!.indexMap[0], 0)
      XCTAssertEqual(cover1!.indexMap[1], 0)
      XCTAssertEqual(cover1!.indexMap[2], 1)

      // domain2 was not part of the intersection, so we should not get
      // a cover back.
      let cover2 = intersection.coveredBy(domain2)
      XCTAssertNil(cover2)

    } else {
      XCTFail("Intersection should not be nil")
    }
  }

}
