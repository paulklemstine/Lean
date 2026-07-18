# Computational Evidence

## Small-case calculations

The proved rank identity gives

| `dim C¹` | `rank δ⁰` | `rank δ¹` | `dim H¹` |
|---:|---:|---:|---:|
| 1 | 0 | 0 | 1 |
| 2 | 0 | 0 | 2 |
| 2 | 1 | 0 | 1 |
| 3 | 1 | 1 | 1 |
| 3 | 3 | 0 | 0 |
| 4 | 2 | 2 | 0 |

These cases obey `dim H¹ + rank δ⁰ + rank δ¹ = dim C¹`. They exhibit the full range from maximal obstruction to vanishing obstruction while holding the overlap-space dimension fixed.

## Sequence-database search

No integer sequence is intrinsic to the deterministic formulation: the dimensions depend on the chosen incidence pattern and linear restriction maps. Consequently an OEIS identifier would be misleading without first fixing a parametrized family or random model.

## Counterexample hunt

The proposed dependence on missing rate alone does not survive the deterministic boundary cases. With the same positive overlap-space dimension, zero coboundaries yield `dim H¹ = dim C¹`, whereas a surjective first coboundary yields `dim H¹ = 0`. Thus a scalar missing rate, or even the overlap-space dimension, cannot determine first cohomology without further assumptions on the overlap nerve and restriction maps.

## Numerical landscape

For fixed `dim C¹ = m`, admissible rank pairs satisfy `rank δ⁰ + rank δ¹ ≤ m`, and the obstruction dimension is the vertical deficit from the line `rank δ⁰ + rank δ¹ = m`. The resulting table is triangular rather than a single curve in the missing rate. This motivated replacing the one-parameter scaling conjecture by a two-parameter program tracking combinatorial incidence and algebraic rank defect.
