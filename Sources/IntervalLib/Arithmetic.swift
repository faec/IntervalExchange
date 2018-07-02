import Foundation

public protocol Ring: CustomStringConvertible & Codable {
  init(_: Int)
  static func zero() -> Self
  static func one() -> Self
  func copy() -> Self
  static prefix func -(_ : Self) -> Self
  static func +(_ : Self, _ : Self) -> Self
  static func +=(_ : inout Self, _ : Self)
  static func -(_ : Self, _ : Self) -> Self
  static func -=(_ : inout Self, _ : Self)
  static func *(_ : Self, _ : Self) -> Self
  static func *=(_ : inout Self, _ : Self)
  //static func ==(_ : Self, _ : Self) -> Bool
  func equals(_ : Self) -> Bool
}

extension Ring {
  public static func +=(_ left: inout Self, _ right: Self) {
    left = left + right
  }
  public static func -=(_ left: inout Self, _ right: Self) {
    left = left - right
  }
  public static func *=(_ left: inout Self, _ right: Self) {
    left = left * right
  }
  public func isZero() -> Bool {
    return self.equals(Self.zero())
  }
}

public protocol Field : Ring {
  static func /(_ : Self, _ : Self) -> Self
  func inverse() -> Self
  init(_: Int, over: UInt)
  init(_: UInt, over: UInt)
}

public protocol Algebra: Ring {
  associatedtype BaseRing: Ring

  func times(_ : BaseRing) -> Self
}

public protocol Numeric {
  func asDouble() -> Double
}

public extension Numeric {
  func asCGFloat() -> CGFloat {
    return CGFloat(self.asDouble())
  }
}

extension Double: Ring {
  public static func zero() -> Double {
    return 0.0
  }
  public static func one() -> Double {
    return 1.0
  }
  public func copy() -> Double {
    return Double(self)
  }
  public func equals(_ value: Double) -> Bool {
    return self == value
  }
}

extension Double: Field {
  public func inverse() -> Double {
    return 1.0 / self
  }
  public init(_ value: Int, over: UInt) {
    self.init(Double(value)/Double(over))
  }
  public init(_ value: UInt, over: UInt) {
    self.init(Double(value)/Double(over))
  }
}

extension Double: Numeric {
  public func asDouble() -> Double {
    return self
  }
}
