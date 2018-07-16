import Foundation

public protocol IntervalProtocol {
  var leftBoundary: k { get }
  var rightBoundary: k { get }
  var length: k { get }
}

public extension IntervalProtocol {
  public var shortDescription: String {
    return "[\(leftBoundary), \(rightBoundary))"
  }
}

public extension IntervalProtocol {
  public func containsPosition(_ position: k) -> Bool {
    return (position >= leftBoundary && position < rightBoundary)
  }
}

public protocol IntervalCollectionProtocol: Collection
    where Element: IntervalProtocol, Index: Hashable {

}

public protocol IntervalMapProtocol {
  associatedtype FromType: IntervalCollectionProtocol
  associatedtype ToType: IntervalCollectionProtocol

  associatedtype IndexMapType: IndexMapProtocol where
      IndexMapType.FromIndexType == FromType.Index,
      IndexMapType.ToIndexType == ToType.Index

  var fromIntervals: FromType { get }
  var toIntervals: ToType { get }
  var indexMap: IndexMapType { get }
}

public protocol IntervalBijectionProtocol: IntervalMapProtocol
    where IndexMapType: IndexBijectionProtocol {
  associatedtype Inverse: IntervalBijectionProtocol
      where Inverse.FromType == ToType, Inverse.ToType == FromType

  var inverse: Inverse { get }
}

extension Array: IntervalCollectionProtocol
    where Element: IntervalProtocol {
}


public class Interval: IntervalProtocol, CustomStringConvertible {
  public let length: k
  public let leftBoundary: k
  public let rightBoundary: k

  public init(_ interval: IntervalProtocol) {
    self.length = interval.length
    self.leftBoundary = interval.leftBoundary
    self.rightBoundary = interval.rightBoundary
  }

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

  public convenience init(containing intervals: [Interval]) {
    var left: k = intervals.first!.leftBoundary
    var right: k = intervals.first!.rightBoundary
    for interval in intervals {
      left = min(left, interval.leftBoundary)
      right = max(right, interval.rightBoundary)
    }
    self.init(leftBoundary: left, rightBoundary: right)
  }

  public var description: String {
    return "Interval(leftBoundary: \(leftBoundary), " +
        "rightBoundary: \(rightBoundary), length: \(length))"
  }
}
