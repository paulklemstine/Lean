# Computational evidence

The formal target is the fixed-point count for finite toric orbit models, plus the standard-simplex and product families.

## Small cases

For the standard `n`-simplex model, every maximal cone contributes one zero-dimensional orbit and hence one Euler unit.

| `n` | vertices / maximal cones | Euler count |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 2 | 2 |
| 2 | 3 | 3 |
| 3 | 4 | 4 |
| 4 | 5 | 5 |
| 5 | 6 | 6 |

For products, the predicted count is `(m+1)(n+1)`:

| `(m,n)` | product fixed points | product Euler count |
|---:|---:|---:|
| (1,1) | 4 | 4 |
| (1,2) | 6 | 6 |
| (2,2) | 9 | 9 |
| (2,3) | 12 | 12 |
| (3,3) | 16 | 16 |

These entire infinite families are proved in `Tropical/TropicalFOne/FixedPointEuler.lean`, rather than accepted from this table.

## OEIS

The simplex counts `1,2,3,4,5,…` are the positive integers (OEIS A000027). This identification is only contextual and is not used in the proof.

## Counterexample hunt

The unrestricted claim that the number of lattice points of a polytope equals the degree of its toric variety is false under standard conventions. For the interval `[0,d]`, the lattice-point count is `d+1`, while the degree of the corresponding polarized projective line is `d`. Thus the project focuses on the valid Euler-characteristic/vertex correspondence and does not formalize the false lattice-point/degree equality.

No counterexample exists to the finite-orbit theorem under its stated hypotheses: each positive-dimensional torus orbit contributes zero by definition of the Euler measure, and each zero-dimensional orbit contributes one. The Lean proof checks this for arbitrary finite cone types, not merely sampled cases.
