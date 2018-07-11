import Foundation

public class Interval {
  public let length: k
  public let leftBoundary: k
  public let rightBoundary: k

  public init(leftBoundary: k, length: k) {
    if length <= k.zero() {
      fatalError("Intervals must have positive length")
    }
    self.length = length
    self.leftBoundary = leftBoundary
    self.rightBoundary = leftBoundary + length
  }

  public init(leftBoundary: k, rightBoundary: k) {
    if rightBoundary <= leftBoundary {
      fatalError("Intervals must have positive length")
    }
    self.length = rightBoundary - leftBoundary
    self.leftBoundary = leftBoundary
    self.rightBoundary = rightBoundary
  }

  public func containsPosition(_ position: k) -> Bool {
    return (position >= leftBoundary && position < rightBoundary)
  }
}
