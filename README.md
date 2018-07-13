# IntervalExchange

This code requires some modules in order to link to external libraries
(`libgmp` and `libbsd`). Follow the instructions on setting up `Modules` in
[the BilliardSearch project](https://github.com/faec/BilliardSearch).

Connecting to external libs in swift can be a little cumbersome as it requires
setting up a separate local git repo. First, copy `ModuleTemplates` to a
new directory alongside `IntervalExchange` (The `Modules` directory should be a
sibling of `IntervalExchange`, although you can relocate it if needed by editing
`IntervalExchange/Package.swift`):

```
mkdir Modules
cp -r IntervalExchange/ModuleTemplates/* Modules/
```

Edit the `header` line in `Modules/CGmp/module.modulemap` to point to
your system's `gmp.h` (common locations: `/usr/include/x86_64-linux-gnu/gmp.h`
on Linux, `/usr/local/include/gmp.h` on Mac).

Then set the module up as a local git repository:

```
cd Modules/CGmp
git init
git add .
git commit -m "Initial checkin"
git tag v1.0.0
```

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
./gendoc
```
