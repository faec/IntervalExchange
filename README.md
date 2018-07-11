# IntervalExchange

To build:

```
swift build -Xlinker -L/usr/local/lib [-c release]
```

To test:

```
swift test -Xlinker -L/usr/local/lib
```

To generate documentation (requires sourcekitten and jazzy):

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
