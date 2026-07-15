# Computational Evidence — Primitive Parts and Mixed-Radix Bridges

## Small-case calculations

For the Fibonacci primitive-part construction, the finite evaluation covers every
index from 13 through 10000. At the first few indices, the relevant Fibonacci
numbers are

| `n` | `F(n)` | a primitive prime factor |
|---:|---:|---:|
| 13 | 233 | 233 |
| 14 | 377 | 13 |
| 15 | 610 | 61 |
| 16 | 987 | 47 |
| 17 | 1597 | 1597 |
| 18 | 2584 | 17 |

Each displayed prime divides `F(n)` and does not divide a positive earlier
Fibonacci number.

For the factorial/mixed-radix bridge, the running products for bases
`b(i) = i + 1` begin

| `k` | running product `∏_{i<k}(i+1)` | `k!` |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 1 | 1 |
| 2 | 2 | 2 |
| 3 | 6 | 6 |
| 4 | 24 | 24 |
| 5 | 120 | 120 |

Thus the two value maps use the same place values term by term.

## OEIS search results

The Fibonacci sequence is OEIS A000045, beginning
`0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, ...`.
The factorial place-value sequence is OEIS A000142, beginning
`1, 1, 2, 6, 24, 120, ...`.

## Counterexample hunt

No counterexample occurs in the exhaustively evaluated interval
`13 ≤ n ≤ 10000`: for every composite `n` in that interval, the computed
primitive part exceeds one. The statement deliberately retains this upper bound;
the computation provides no evidence beyond it that is used as a proof.

The mixed-radix bridge is symbolic rather than sample-dependent: its running
product, validity, value, and uniqueness identities are established for arbitrary
digit functions and lengths. The table above is only a sanity check.

## Tables and scope

The tables record representative small values. The finite Fibonacci claim is
backed by the exhaustive evaluation encoded in `primPart_check`; the unbounded
classical tail is not claimed as a completed result in this cycle.
