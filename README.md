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
