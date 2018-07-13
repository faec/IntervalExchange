# qmc ergodicity exercises 1

These are some example tasks to help you get familiar with the language / API, and also hint at some of the later theory. They vary a lot in difficulty, and some involve skills you might not yet have: don’t worry. Do the ones at your level, and ask on the Discord if you want help pushing beyond that. If you aren’t sure where to get started, try looking at the examples in `IntervalLibTests.swift`.

## Permutations

- Create a `Permutation` object corresponding to the permutation `[A B C D] -> [B C D A]`. What is its inverse? What permutation do you get if you apply this one twice?
- The _period_ of a permutation `p` is the number of times you need to apply it before it maps every value back to where it started, that is, the smallest positive `n: Int` where for any `i: Int`, `p[p[...n times...[i]]] == i`.

    Implement the function:
    ```
    func periodForPermutation(_ p: Permutation) -> Int {
      ...
    }
    ```

    that returns the period of `p`. Test your function by confirming that:
    ```
    periodForPermutation(Permutation(forwardMap: [1, 2, 0, 4, 5, 6, 3]))
    ```

    returns `12`.

    Note: The underscore in the parameter list is how to implement unnamed
    function parameters in Swift. If we had instead written:
    ```
    func periodForPermutation(p: Permutation) -> Int {
      ...
    }
    ```

    then we'd have to call it as `periodForPermutation(p: myPermutation)`. With
    the syntax above, we can just use `periodForPermutation(myPermutation)`.
    Usually it's a good habit to keep the parameter names, but for simple
    functions where there's no ambiguity we can reduce clutter this way.

## Intervals

As in EToIEM all intervals include their left boundary point and exclude their right boundary point.

- Implement the function:
    ```
    func intersectIntervals(_ i0: Interval, _ i1: Interval) -> Interval? {
      ...
    }
    ```

    which returns the `Interval` of overlap between `i0` and `i1` if it isn't empty, and `nil` otherwise.


## Interval Exchange Maps

- Create an interval exchange map `f` with interval lengths `1/3`, `1/5`, and `1/2`, and permutation `[A B C] -> [C A B]`. Evaluate it on some test positions.
- How many times do you need to compose `f` with itself (`f[f[f[f[...]]]]`) before all its intervals are length `1/30`?
    * Why don’t they get shorter than `1/30`?
    * If you know the interval lengths for a map, how can you compute the minimum possible interval length for all its compositions with itself? (This is hinting at the fact that we will eventually need to use irrational numbers.)

- Implement the function:
    ```
    func approximateReturnPeriod(
        f: IntervalExchangeMap, position: k, radius: k) -> Int {
      ...
    }
    ```

    which counts how many times `f` must be applied to `position` to get a result that is within `radius` of its starting point.

    * Should we worry about the result being infinite on some inputs?
    * Project: graph the outputs of this function visually. Given `f` and `radius`, compute the return period on many input positions, and visualize it however is easiest for you. (If you don’t know a way to generate a visualization, ask on the Discord for pointers.)

- Implement the function:

    ```
    func positionSimilarity(
        f: IntervalExchangeMap, p0: k, p1: k, maxDepth: Int)
        -> Int? {
      ...
    }
    ```

    The _similarity_ here means the number of times `f` must be applied to `p0` and `p1` for them to end up in different input intervals. E.g. in the `f` defined above, the similarity of `0` and `1/2` is `0`, because they already start in different intervals. The similarity of `8/15` and `11/15` is `1`, because they both start in the last input interval, but after the first map they are split between input intervals `0` and `1`. Moving points closer together increases their similarity.

    If the similarity exceeds `maxDepth`, the function should return `nil`.

    * There is a `maxDepth` parameter because similarity can be infinite (for example if `p0 == p1`). If there was no `maxDepth` parameter, could we still avoid infinite loops?
    * Project: graph the outputs of this function visually. Given `f` and `maxDepth`, plot the position similarity on a 2-d grid with `p0` on one axis and `p1` on the other.
