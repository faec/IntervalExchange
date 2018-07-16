// A set of protocols and utility classes for representing arbitrary(ish)
// maps between collections, by maintaining a direct lookup dictionary
// for every input / output index.
//
// In the special case that both the input and output indices are the integer
// range 0..<n, it is more efficient to use the Permutation class, which
// also conforms to IndexBijectionProtocol.

public protocol IndexMapProtocol {
  associatedtype FromIndexType: Hashable
  associatedtype ToIndexType

  subscript(_ inputIndex: FromIndexType) -> ToIndexType { get }
}

public protocol IndexBijectionProtocol : IndexMapProtocol {
  associatedtype InverseType: IndexMapProtocol where
      InverseType.FromIndexType == ToIndexType,
      InverseType.ToIndexType == FromIndexType

  var inverse: InverseType { get }
}

public class IndexMap<FromIndex, ToIndex>: IndexMapProtocol
    where FromIndex: Hashable {

  public typealias FromIndexType = FromIndex
  public typealias ToIndexType = ToIndex

  public let forwardMap: [FromIndex: ToIndex]

  public init(forwardMap: [FromIndex: ToIndex]) {
    self.forwardMap = forwardMap
  }

  public subscript(_ inputIndex: FromIndex) -> ToIndex {
    return forwardMap[inputIndex]!
  }
}

public class IndexBijection<FromIndex, ToIndex>:
    IndexMap<FromIndex, ToIndex>, IndexBijectionProtocol
    where FromIndex: Hashable, ToIndex: Hashable {

  public let inverseMap: [ToIndex: FromIndex]

  public typealias InverseType = IndexBijection<ToIndex, FromIndex>
  public lazy var inverse =
      InverseType(forwardMap: inverseMap, inverseMap: forwardMap)

  public init(
      forwardMap: [FromIndex: ToIndex], inverseMap: [ToIndex: FromIndex]) {
    self.inverseMap = inverseMap
    super.init(forwardMap: forwardMap)
  }

  public override convenience init(forwardMap: [FromIndex: ToIndex]) {
    var inverseMap: [ToIndex: FromIndex] = [:]
    for (from, to) in forwardMap {
      // Should we throw an error here if there's a duplicate value?
      inverseMap[to] = from
    }
    self.init(forwardMap: forwardMap, inverseMap: inverseMap)
  }
}
