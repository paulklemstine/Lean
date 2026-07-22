# Computational Evidence

## Small-case calculations

For an `n`-bit Boolean register, the input state count is `2^n`; a total reset has one reachable output. Thus the discarded information is `log₂(2^n) - log₂(1) = n`.

| `n` | input states `2^n` | output states | discarded bits | Landauer threshold |
|---:|---:|---:|---:|---:|
| 0 | 1 | 1 | 0 | `0` |
| 1 | 2 | 1 | 1 | `k T log 2` |
| 2 | 4 | 1 | 2 | `2 k T log 2` |
| 3 | 8 | 1 | 3 | `3 k T log 2` |
| 4 | 16 | 1 | 4 | `4 k T log 2` |
| 5 | 32 | 1 | 5 | `5 k T log 2` |
| 6 | 64 | 1 | 6 | `6 k T log 2` |
| 7 | 128 | 1 | 7 | `7 k T log 2` |
| 8 | 256 | 1 | 8 | `8 k T log 2` |

## OEIS search result

The state-count sequence `1, 2, 4, 8, 16, 32, ...` is OEIS A000079 (powers of two). The discarded-bit sequence `0, 1, 2, 3, ...` is the sequence of nonnegative integers (OEIS A001477). These identifications are contextual; the Lean theorem proves the symbolic identity for every `n` and does not rely on OEIS.

## Counterexample hunt

The boundary case `n = 0` is consistent: the singleton empty register resets to a singleton and loses zero bits. Positive `n` gives strictly positive information loss. No small case contradicts the exact count.

The work claim is conditional on positive `k`, positive `T`, a normalized finite probability mass function, and the stated input-wise Jarzynski relation. Dropping positive temperature or the fluctuation relation is outside the theorem and can invalidate the lower bound; these are explicit hypotheses rather than conclusions inferred from runtime.

## Tail-bound table

The formal tail bound has the dimensionless form `P[W < threshold - ξ] ≤ exp(-ξ/(kT))`. Writing `r = ξ/(kT)`, representative upper bounds are:

| `r` | upper bound `e^{-r}` (approx.) |
|---:|---:|
| 0 | 1.0000 |
| 1 | 0.3679 |
| 2 | 0.1353 |
| 3 | 0.0498 |
| 4 | 0.0183 |

The decimal values are explanatory approximations only; the verified Lean result retains the exact exponential expression.
