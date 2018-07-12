# IntervalExchange

This code requires some modules in order to link to external libraries
(`libgmp` and `libbsd`). Follow the instructions on setting up `Modules` in
[the BilliardSearch project](https://github.com/faec/BilliardSearch).

## To build

Once `Modules` is set up:

```
swift build -Xlinker -L/usr/local/lib [-c release]
```

## To test

```
swift test -Xlinker -L/usr/local/lib
```

## To run interactively in the swift repl

Use `repl-debug` or `repl-release` to run a swift repl linking to the
specified configuration after building the library as above:

    $ ./repl-debug
    Welcome to Apple Swift version 4.1.2 (swiftlang-902.0.54 clang-902.0.39.2). Type :help for assistance.
    > import IntervalLib
    > let interval = Interval(
          leftBoundary: k.zero(), rightBoundary: k(3, over: 2))
    interval: IntervalLib.Interval = { ... }
    > let f = IntervalExchangeMap.linearCycleOnInterval(
          interval, cycleLength: 5)
    f: IntervalLib.IntervalExchangeMap = { ... }
    > let position = k(1, over: 3)
    > let output = f[position]
    > print("f(\(position)) = \(output)")
    f(1/3) = Optional(19/30)

## To generate documentation
(requires sourcekitten and jazzy):

```
sourcekitten doc --spm-module IntervalLib > intervallib.json
jazzy \
  --clean \
  --sourcekitten-sourcefile intervallib.json \
  --author fae \
  --author_url http://faec.me \
  --github_url https://github.com/faec/IntervalExchange \
  --module-version 1.3.8 \
  --module IntervalLib \
  --root-url https://faec.me/files/IntervalExchange

  # --github-file-prefix https://github.com/qutheory/vapor/tree/1.3.8
```
