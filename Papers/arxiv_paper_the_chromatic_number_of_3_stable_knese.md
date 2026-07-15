# Computational evidence

## Small cases

For the canonical upper coloring, write `n = r + s(k-1)`.  The extremal final
fiber consists of stable `k`-sets contained in the interval
`[r-1, r-1+s(k-1)]`. Direct gap counting predicts that this fiber has exactly
one member:

| s | k | interval (with r=3) | forced set |
|---:|---:|---|---|
| 2 | 2 | [2,4] | {2,4} |
| 2 | 3 | [2,6] | {2,4,6} |
| 3 | 2 | [2,5] | {2,5} |
| 3 | 3 | [2,8] | {2,5,8} |
| 4 | 3 | [2,10] | {2,6,10} |

These examples support the rigidity theorem: `k-1` gaps, each at least `s`,
fit into total span `s(k-1)` only when all gaps equal `s`.

For `s=3, k=3`, the predicted color count is `n-6`.  Thus `n=9,10,11,12`
give respectively `3,4,5,6` canonical colors.

## OEIS search

No OEIS search is relevant: the formal target is a structural packing and
coloring theorem, not identification of a new integer sequence. The color-count
sequence for fixed `s,k` is simply affine in `n`.

## Counterexample hunt

The equality `n - s*k + s = r` from `n = r+s(k-1)` is sensitive to truncated
natural-number subtraction.  A counterexample to the equality without an
additional lower bound is `(n,s,k,r)=(3,3,2,0)`.  The formal theorem therefore
includes `s ≤ r`, which is enough to prevent truncation and matches the
large-`n` regime relevant to the paper.

No counterexample occurs in the displayed extremal intervals: enumerating by
hand, any increase in one selected point forces either a gap below `s` or the
last point beyond the interval.

## Table interpretation

The table records the final color fiber of the canonical map. Ordinary fibers
have a common minimum; the final fiber is intersecting because its unique
possible stable set is the displayed arithmetic progression. This is exactly
the dichotomy formalized in `canonicalColor_fiber_intersect`.
