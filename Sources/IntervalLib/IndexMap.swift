// A set of protocols and utility classes for representing arbitrary(ish)
// maps between collections, by maintaining a direct lookup dictionary
// for every input / output index.
//
// In the special case that both the input and output indices are the integer
// range 0..<n, it is more efficient to use the Permutation class, which
// also conforms to IndexBijectionProtocol.

public protocol IndexMapProtocol {
  associatedtype InputIndexType: Hashable
  associatedtype OutputIndexType

  subscript(_ inputIndex: InputIndexType) -> OutputIndexType { get }
}

public protocol IndexBijectionProtocol : IndexMapProtocol {
  associatedtype InverseType: IndexMapProtocol where
      InverseType.InputIndexType == OutputIndexType,
      InverseType.OutputIndexType == InputIndexType

  var inverse: InverseType { get }
}

public class IndexMap<InputIndex, OutputIndex>: IndexMapProtocol
    where InputIndex: Hashable {

  public typealias InputIndexType = InputIndex
  public typealias OutputIndexType = OutputIndex

  public let forwardMap: [InputIndex: OutputIndex]

  public init(forwardMap: [InputIndex: OutputIndex]) {
    self.forwardMap = forwardMap
  }

  public subscript(_ inputIndex: InputIndex) -> OutputIndex {
    return forwardMap[inputIndex]!
  }
}

public class IndexBijection<InputIndex, OutputIndex>:
    IndexMap<InputIndex, OutputIndex>, IndexBijectionProtocol
    where InputIndex: Hashable, OutputIndex: Hashable {

  public let inverseMap: [OutputIndex: InputIndex]

  public typealias InverseType = IndexBijection<OutputIndex, InputIndex>
  public lazy var inverse =
      InverseType(forwardMap: inverseMap, inverseMap: forwardMap)

  public init(
      forwardMap: [InputIndex: OutputIndex], inverseMap: [OutputIndex: InputIndex]) {
    self.inverseMap = inverseMap
    super.init(forwardMap: forwardMap)
  }

  public override convenience init(forwardMap: [InputIndex: OutputIndex]) {
    var inverseMap: [OutputIndex: InputIndex] = [:]
    for (from, to) in forwardMap {
      // Should we throw an error here if there's a duplicate value?
      inverseMap[to] = from
    }
    self.init(forwardMap: forwardMap, inverseMap: inverseMap)
  }
}
