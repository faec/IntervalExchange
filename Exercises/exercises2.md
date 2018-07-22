# qmc ergodicity exercises 2

As before, there's a considerable range of difficulty, and you shouldn't worry if you can't do some of them (because some are quite hard), _or_ if you can't finish _all_ of them (because time is finite). But all of them are useful to look at and think about, and you can get help on the Discord.

## Rauzy-Veech induction

- Let `f` be an interval exchange map. In the Swift library, `f.induction(n)` applies Rauzy-Veech induction `n` times and returns the resulting interval exchange map, or `nil` if it is undefined (i.e. the final intervals in one of the maps were the same length).

    Each time induction is applied, it shrinks the size of the map by cutting off its rightmost interval. We can measure the size of a map with its `bounds` property: `f.bounds.length` gives the total size of the range on which it's defined.

    Implement the function:
    ```
    func inductionSizes(_ f: IntervalExchangeMap, maxDepth: Int) -> [k] {
      ...
    }
    ```

    that returns the size of `f` followed by the size of each of its inductions up to `maxDepth`.
- Consider the interval exchange map with two intervals of length `2^m` and `3^m`. Choose a reasonable maxDepth and compute `inductionSizes` for `m in 1...10`.
- Show that if `f.intervalLengths` (λ) are all rational, then `f.induction(n)` is `nil` for some `n`.
- Show that for any position `x` and integer `n`, `f.induction(n)?[x]` maps to `f^m[x]` for some integer `m`. That is, induction will always map points to places they would eventually be mapped by repeatedly applying `f`.
- Recall that `f` is called _irreducible_ if it cannot be broken into smaller interval exchange maps. Equivalently, if `interval != f.bounds` then `f[interval] != interval`.

    If `f.induction(n) != nil` for all `n`, and `f` is irreducible, show that the induction sizes (`f.induction(n)?.bounds.length`) approach `0` as `n` goes to infinity.
- A function `g: k -> k` is _invariant_ under `f` if its value doesn't change when its input is mapped through `f`, i.e. `g(f(x)) == g(x)` for all `x`. An important use of Rauzy-Veech induction is to show that the invariants of most maps are very simple.

    Suppose `f` is irreducible and induction is always defined. From the previous exercise, we know that its induction maps become arbitrarily small. Let `g` be an invariant of `f`.

    * Show that for any `epsilon > 0`, `g([0, epsilon))` contains every possible output value of `g`. That is, any values `g` takes on the full input of `f`, it must also take within a distance `epsilon` of the origin.

    * From this, show that if `g` is continuous then it must be constant.
