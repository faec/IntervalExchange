public class SpanEmbedding {
  public let order: Permutation
  public let spans: [Span]
  public let length: k

  public init(spanLengths: [k], order: Permutation) {
    self.order = order
    var pos = k.zero()
    var spans: [Span] = []
    for i in 0..<spanLengths.count {
      let length = spanLengths[order.inverse[i]]
      let span = Span(index: i, leftBoundary: pos, length: length)
      spans.append(span)
      pos = span.rightBoundary
    }
    self.spans = spans
    self.length = pos
  }

  public func leftBoundaries() -> [k] {
    return spans.map { $0.leftBoundary }
  }

  public func rightBoundaries() -> [k] {
    return spans.map { $0.rightBoundary }
  }

  public func pointForPosition(_ position: k) -> Span.Point? {
    for span in spans {
      if span.containsPosition(position) {
        return span.pointForPosition(position)
      }
    }
    return nil
  }

  public class Span {
    public let index: Int
    public let length: k
    public let leftBoundary: k
    public let rightBoundary: k
    init(index: Int, leftBoundary: k, length: k) {
      self.index = index
      self.length = length
      self.leftBoundary = leftBoundary
      self.rightBoundary = leftBoundary + length
    }

    public func containsPosition(_ position: k) -> Bool {
      return (position >= leftBoundary && position < rightBoundary)
    }

    public func pointForPosition(_ position: k) -> Point {
      return Point(
          spanIndex: index, position: position, offset: position - leftBoundary)
    }

    public func pointForOffset(_ offset: k) -> Point {
      return Point(
          spanIndex: index, position: leftBoundary + offset, offset: offset)
    }

    public class Point {
      // Index in the current SpanEmbedding (defined contextually). This is
      // redundant with position, but is used frequently enough that it's
      // easier to work with this tuple than the position alone.
      public let spanIndex: Int
      // Absolute position in the containing interval.
      public let position: k
      // Offset from the leftBoundary of the containing span.
      public let offset: k

      fileprivate init(spanIndex: Int, position: k, offset: k) {
        self.spanIndex = spanIndex
        self.position = position
        self.offset = offset
      }
    }
  }
}
