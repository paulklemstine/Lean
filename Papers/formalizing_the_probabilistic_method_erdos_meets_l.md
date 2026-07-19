# Computational Evidence

## Small-case calculations

For the Ramsey first-moment criterion

`2 · C(n,k) < 2^{C(k,2)}`,

the verified concrete instance used in the development is `n = 16`, `k = 10`:

| quantity | value |
|---|---:|
| `C(16,10)` | 8008 |
| `2 · C(16,10)` | 16016 |
| `C(10,2)` | 45 |
| `2^45` | 35184372088832 |

Thus the bad-coloring union bound is far below the total coloring count.

For balanced two-part Turán graphs on `2m` vertices, the first cases are:

| `m` | vertices | edges | `4 · edges` | vertices² |
|---:|---:|---:|---:|---:|
| 1 | 2 | 1 | 4 | 4 |
| 2 | 4 | 4 | 16 | 16 |
| 3 | 6 | 9 | 36 | 36 |
| 4 | 8 | 16 | 64 | 64 |

These cases exhibit exact equality in Mantel’s bound.

## OEIS search results

The balanced bipartite edge counts are the squares `1, 4, 9, 16, 25, …`, OEIS A000290. No sequence identification is needed for the Ramsey inequality, which compares binomial and exponential expressions directly.

## Counterexample hunt

The unconditional finite conditional-avoidance statement fails if the outcome type is empty: no avoiding outcome can exist even when the index type is also empty. The corrected theorem explicitly assumes that the finite outcome space is nonempty.

The proposed Moser–Tardos runtime `O(n d log(1/p))` was not used: its exact scope depends on the variable model, event representation, and cost model. The present results therefore make no runtime claim.

## Tables and interpretation

The two tables display opposite extremal uses of counting. In Ramsey theory, the forbidden colorings occupy fewer than all colorings, leaving an avoiding witness. In Turán theory, balanced bipartition attains the maximum edge count permitted by triangle-freeness.
