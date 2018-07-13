
/**
 Represents a permutation on a fixed integer range starting from 0.
 Example use:

     // Create a permutation from the values it maps to.
     let p = Permutation(forwardMap: [2, 1, 3, 0])

     // To apply the permutation to a value or array, use
     // `Permutation.subscript(...)`.
     // To invert it use `inverse`.
     print("\(p[0])")           // 2
     print("\(p.inverse[2])")   // 0
     let strings = ["A", "B", "C", "D"]
     print("\(p[strings]")      // ["C", "B", "D", "A"]
 */
public class Permutation {
  /// This permutation maps `i` to `forwardMap[i]`.
  public let forwardMap: [Int]
  /// This permutation maps `inverseMap[i]` to `i`.
  public let inverseMap: [Int]

  private var _inverse: Permutation?

  private init(
      forwardMap: [Int], inverseMap: [Int], inverse: Permutation? = nil) {
    self.forwardMap = forwardMap
    self.inverseMap = inverseMap
    self._inverse = inverse
  }

  /**
   Creates a `Permutation` from its forward map. Testing?

   Let's add another line here just to make sure the documentation
   generator is getting something in the discussion section.

   ## Stuff

   Not really sure but [linkie linkie](https://www.github.com/), and
   here's a code listing:
   
       let a: Int = 5
       let p = Permutation.identity(length: 10)
       let b = p[a]

   - Parameters:
     - forwardMap: an array of the permutation's values (`i` maps to
       `forwardMap[i]`).
   */
  public convenience init(forwardMap: [Int]) {
    self.init(forwardMap: forwardMap, inverseMap: _invertMap(forwardMap))
  }

  public convenience init(inverseMap: [Int]) {
    self.init(forwardMap: _invertMap(inverseMap), inverseMap: inverseMap)
  }

  public subscript(_ inputIndex: Int) -> Int {
    return forwardMap[inputIndex]
  }

  public subscript(_ p: Permutation) -> Permutation {
    let newForwardMap = self.domain().map { self[p[$0]] }
    return Permutation(forwardMap: newForwardMap)
  }

  public subscript<T>(_ array: [T]) -> [T] {
    return self.domain().map { array[inverseMap[$0]] }
  }

  public func size() -> Int {
    return forwardMap.count
  }

  public var inverse: Permutation {
    if _inverse == nil {
      _inverse = Permutation(
          forwardMap: inverseMap, inverseMap: forwardMap, inverse: self)
    }
    return _inverse!
  }

  public func domain() -> CountableRange<Int> {
    return (0..<forwardMap.count)
  }

  public func codomain() -> CountableRange<Int> {
    return (0..<forwardMap.count)
  }
}

// Some convenience constructors
extension Permutation {
  public static func identity(size: Int) -> Permutation {
    return Permutation(forwardMap: Array(0..<size), inverseMap: Array(0..<size))
  }

  public static func rotation(size: Int, offset: Int) -> Permutation {
    let forwardMap = (0..<size).map({_absMod($0 + offset, size)})
    return Permutation(forwardMap: forwardMap)
  }
}

extension Permutation: CustomStringConvertible {
  public var description: String {
    return "Permutation(\(forwardMap))"
  }
}

extension Permutation: Equatable {
  public static func ==(p0: Permutation, p1: Permutation) -> Bool {
    return p0.forwardMap == p1.forwardMap
  }
}

fileprivate func _absMod(_ a: Int, _ b: Int) -> Int {
  return (a % b + b) % b
}

fileprivate func _invertMap(_ map: [Int]) -> [Int] {
  var inv = [Int](repeating: -1, count: map.count)
  for i in 0..<map.count {
    let j = map[i]
    // forward mapping is i -> j
    if j < 0 || j >= map.count || inv[j] != -1 {
      fatalError("Noninvertible mapping: \(map)")
    }
    inv[map[i]] = i
  }
  return inv
}
