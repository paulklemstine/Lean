# Computational Evidence

## Small cases

For `n = 0, …, 8`, the number of possible input permutations, its binary ceiling, and the standard bubble-sort comparison count are:

| `n` | `n!` | `⌈log₂(n!)⌉` | `n(n-1)/2` |
|---:|---:|---:|---:|
| 0 | 1 | 0 | 0 |
| 1 | 1 | 0 | 0 |
| 2 | 2 | 1 | 1 |
| 3 | 6 | 3 | 3 |
| 4 | 24 | 5 | 6 |
| 5 | 120 | 7 | 10 |
| 6 | 720 | 10 | 15 |
| 7 | 5040 | 13 | 21 |
| 8 | 40320 | 16 | 28 |

These values support the two distinct scales formalized in Lean: the decision-tree lower bound is the binary ceiling of the factorial entropy, while bubble sort uses a larger quadratic number of comparisons.

## Sequence identification

The factorial sequence is OEIS A000142: `1, 1, 2, 6, 24, 120, 720, 5040, 40320, …`.
The triangular comparison counts are OEIS A000217 (with the index shifted to `n-1`): `0, 0, 1, 3, 6, 10, 15, 21, 28, …`.

## Counterexample hunt

The naive claim that standard bubble sort performs exactly `n²` comparisons already fails at `n = 1` (`0 ≠ 1`) and at every positive tested value. The formal correction is

`2 * bubbleComparisons n + n = n²`,

so the exact count is `n(n-1)/2`.

Likewise, inserting redundant comparison levels changes decision-tree height without changing the visible sorting map or its information loss. This is computationally consistent with the formal conclusion that raw comparison count cannot by itself determine Landauer work.
