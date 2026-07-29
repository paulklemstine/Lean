# Computational evidence

The principal result is symbolic rather than a conjecture inferred from data: it follows from the theorem that a nonzero polynomial has at most its degree many distinct roots. Small parameter checks nevertheless match the bound.

| field | length `n` | message bound `k` | proved designed distance `n-k+1` |
|---|---:|---:|---:|
| `GF(7)` | 5 | 3 | 3 |
| `GF(11)` | 8 | 4 | 5 |
| `GF(13)` | 12 | 7 | 6 |

For each row, any two distinct polynomials of degree below `k` can agree at no more than `k-1` distinct evaluation points, hence differ in at least the displayed number of positions. No counterexample exists under the formal hypotheses (distinct points and `k ≤ n`), as proved in `Catalog/Cryptography/AlgebraicCodingTheory.lean`.

No OEIS search is applicable: the quantity is the elementary parameter formula `n-k+1`, not a newly observed one-variable integer sequence. Plots are likewise not informative for this linear formula.
