import IntervalLib

let interval = Interval(
    leftBoundary: k.zero(), rightBoundary: k(3, over: 2))
let f = IntervalExchangeMap.linearCycleOnInterval(
    interval, cycleLength: 5)

let position = k(1, over: 3)
let output = f[position]
print("f(\(position)) = \(String(describing: output))")
