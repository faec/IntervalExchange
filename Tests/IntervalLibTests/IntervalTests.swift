import XCTest
@testable import IntervalLib

final class IntervalTests: XCTestCase {
  func testDescriptions() {
    let interval = Interval(
        leftBoundary: k(3, over: 2), rightBoundary: k(6))
    XCTAssertEqual(
        interval.description,
        "Interval(leftBoundary: 3/2, rightBoundary: 6, length: 9/2)")
    XCTAssertEqual(interval.shortDescription, "[3/2, 6)")
  }
}
