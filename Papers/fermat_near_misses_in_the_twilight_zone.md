# Computational Evidence

## Small cases

The formal development includes the exact cubic calculation

| exponent `n` | `a` | `b` | `c` | `|a^n+b^n-c^n|` |
|---:|---:|---:|---:|---:|
| 3 | 6 | 8 | 9 | 1 |

For the ordered family `(t,1,t+1)`, direct expansion gives:

| `n` | `t` | error |
|---:|---:|---:|
| 2 | 1 | 2 |
| 2 | 2 | 4 |
| 2 | 3 | 6 |
| 3 | 1 | 6 |
| 3 | 2 | 18 |
| 3 | 3 | 36 |
| 4 | 1 | 14 |
| 4 | 2 | 64 |
| 4 | 3 | 174 |

These values agree with the proved upper bound `n (t+1)^(n-1) + 1`.

## OEIS search

No OEIS identifier is asserted.  The displayed ordered-family values come from the elementary polynomial `(t+1)^n - t^n - 1`, so an OEIS identification is not needed for the proof.

## Counterexample hunt

The broad claim that normalized near-miss density decreases super-exponentially depends on the normalization, height region, positivity, ordering, and primitivity conditions. Without those choices it is not a well-posed universal statement. In particular, the proved cancellation family `(t,1,t)` has error one for every exponent and every `t`, so any formulation allowing `a=c` has an abundant exceptional family rather than super-exponential scarcity.

## Table interpretation

For fixed `n`, the ordered-family error has degree `n-1` in `t`, whereas the ambient powers have degree `n`. This one-degree saving is formalized in `ordered_adjacent_error_bound`.
