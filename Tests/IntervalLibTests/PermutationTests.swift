import XCTest
@testable import IntervalLib

final class PermutationTests: XCTestCase {
  func testIdentity() {
    let size = 5
    let id = Permutation.identity(size: size)
    XCTAssertEqual(id.size(), size)
    for i in 0..<size {
      XCTAssertEqual(i, id[i])
      XCTAssertEqual(i, id.inverse[i])
    }
  }

  func testDomain() {
    let size = 7
    var seen = [Bool](repeating: false, count: size)
    var seenCount = 0
    let id = Permutation.identity(size: size)
    for i in id.domain() {
      if !seen[i] {
        seen[i] = true
        seenCount += 1
      }
    }
    XCTAssertEqual(seenCount, size)
  }

  func testRotation() {
    let size = 7
    let offset = -3
    let p = Permutation.rotation(size: size, offset: offset)
    XCTAssertEqual(p.size(), size)
    for i in 0..<size {
      XCTAssertEqual(p[i], (i + size + offset) % size)
      XCTAssertEqual(p.inverse[i], (i + size - offset) % size)
    }
  }

  func testInverseCache() {
    let p = Permutation.rotation(size: 6, offset: 1)
    XCTAssertTrue(p.inverse.inverse === p)
  }
}
