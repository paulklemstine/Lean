# Computational Evidence

## Small-case calculations

The additive group of integers was viewed multiplicatively, so product sets coincide with ordinary sumsets. Direct finite calculations gave:

| Set `S` | `|S|` | `|S²|` | `3|S|-3` | Outcome |
|---|---:|---:|---:|---|
| `{0,1}` | 2 | 3 | 3 | threshold equality |
| `{0,1,2}` | 3 | 5 | 6 | below the threshold |
| `{0,1,3}` | 3 | 6 | 6 | threshold equality |

For the threshold examples, the collision-surplus formula predicts respectively
`2²-3 = 1` and `3²-6 = 3` excess ordered representations.

## OEIS search results

No sequence search was used: the investigated quantities depend on the chosen finite set rather than defining a canonical one-variable sequence.

## Counterexample hunt

The interval `{0,1,2}` shows that nonempty ordered-group sets need not satisfy the `3k-3` equality; it has smaller doubling. This rules out treating the paper's hypothesis as a universal growth law. The singleton boundary is also excluded: a singleton has product-set size one, whereas natural-number evaluation of `3|S|-3` is zero.

## Tables and interpretation

The table distinguishes rank-one progressions, which attain the smaller Cauchy–Davenport floor `2k-1`, from a sparse three-element set attaining `3k-3`. It supports studying `3k-3` through both the excess above `2k-1` and the representation-collision mass.
