# Computational Evidence

## Small-case calculations

For the normalized `T(2,2k+1)` Alexander family

`Δ_k(t) = Σ_{i=-k}^{k} (-1)^{i+k} t^i`,

the first cases are:

| `k` | Knot | Normalized Alexander polynomial |
|---:|---|---|
| 0 | unknot | `1` |
| 1 | trefoil `T(2,3)` | `t - 1 + t⁻¹` |
| 2 | `T(2,5)` | `t² - t + 1 - t⁻¹ + t⁻²` |
| 3 | `T(2,7)` | `t³ - t² + t - 1 + t⁻¹ - t⁻² + t⁻³` |
| 4 | `T(2,9)` | `t⁴ - t³ + t² - t + 1 - t⁻¹ + t⁻² - t⁻³ + t⁻⁴` |

For every `k ≥ 1`, the coefficient in degree `k-1` is `-1`.

## Counterexample hunt

An unsigned lattice-path generating function has coefficient at degree `a`
equal to the cardinality of the set of allowed paths of area `a`; hence every
coefficient is nonnegative. The trefoil already contradicts the universal
claim because its degree-zero coefficient is `-1`. The same test gives an
infinite counterexample family `T(2,2k+1)` for all `k ≥ 1`.

The test is stronger than a search over geometric forbidden regions: even if an
arbitrary predicate is allowed to delete any subset of balanced paths, the
remaining area-fibre cardinalities cannot be negative.

## OEIS search

The obstruction uses the constant sequence of witness coefficients
`-1, -1, -1, ...`, rather than a nonnegative counting sequence, so an OEIS
identification is not relevant to the decisive test. The corresponding
absolute coefficient rows are strings of `2k+1` ones.

## Table of diagnostic invariants

| `k` | Sum of coefficients `Δ_k(1)` | Absolute alternating evaluation `|Δ_k(-1)|` | Unsigned path model? |
|---:|---:|---:|---|
| 0 | 1 | 1 | not obstructed |
| 1 | 1 | 3 | no |
| 2 | 1 | 5 | no |
| 3 | 1 | 7 | no |
| 4 | 1 | 9 | no |

The symbolic proofs establish these patterns for every natural `k`; the table
only illustrates the first cases.
