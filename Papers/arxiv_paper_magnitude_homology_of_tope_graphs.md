# Computational Evidence

## Small-case calculations

For the coordinate arrangements of ranks zero through six, the cardinalities of the metric spheres about any chamber are:

| rank | sphere cardinalities |
|---:|:---|
| 0 | 1 |
| 1 | 1, 1 |
| 2 | 1, 2, 1 |
| 3 | 1, 3, 3, 1 |
| 4 | 1, 4, 6, 4, 1 |
| 5 | 1, 5, 10, 10, 5, 1 |
| 6 | 1, 6, 15, 20, 15, 6, 1 |

These rows arise by enumerating subsets of the separating coordinate hyperplanes.  Their row sums are respectively `1, 2, 4, 8, 16, 32, 64`, matching the chamber counts.

## Sequence identification

The triangular array is Pascal's triangle, OEIS A007318.  For fixed rank `n`, its entries are the coefficients of `(1 + t)^n`.  This identifies the candidate Stanley--Reisner numerator as the face enumerator of the full simplex on the wall set.

## Counterexample hunt

Three universal claims were tested on every pair or triple of Boolean sign vectors through rank six:

1. the separating-wall count is symmetric;
2. it satisfies the triangle inequality;
3. the number of sign vectors at distance `k` is independent of the base sign vector.

No counterexample occurs.  The corresponding unrestricted statements are established in `Hypercube.lean`.  The unguarded reciprocity formula at indices `k > n` is not adopted: natural-number subtraction would send `n-k` to zero, whereas the coefficient at `k` vanishes, so the claim would fail.  The formal reciprocity theorem therefore requires `k ≤ n`.

## Polynomial table

| rank | wall-simplex face enumerator |
|---:|:---|
| 0 | `1` |
| 1 | `1 + t` |
| 2 | `1 + 2t + t²` |
| 3 | `1 + 3t + 3t² + t³` |
| 4 | `1 + 4t + 6t² + 4t³ + t⁴` |
| 5 | `1 + 5t + 10t² + 10t³ + 5t⁴ + t⁵` |

The coefficient symmetry suggests complement duality on wall subsets.  `HilbertBridge.lean` proves that these coefficients equal metric-sphere cardinalities in every rank and proves the guarded reciprocal symmetry.
