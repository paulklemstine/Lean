# Computational Evidence

## Small cases

For the modular Cayley orbit `z_n = n/(n+2i)`, clearing the horocycle equation gives

| `n` | `n² - 4` | `4n` | `n² + 4` | check |
|---:|---:|---:|---:|:---|
| 0 | -4 | 0 | 4 | 16 + 0 = 16 |
| 1 | -3 | 4 | 5 | 9 + 16 = 25 |
| 2 | 0 | 8 | 8 | 0 + 64 = 64 |
| 3 | 5 | 12 | 13 | 25 + 144 = 169 |
| 4 | 12 | 16 | 20 | 144 + 256 = 400 |
| 5 | 21 | 20 | 29 | 441 + 400 = 841 |
| 6 | 32 | 24 | 40 | 1024 + 576 = 1600 |

The instances for `n = 3,4,5` are encoded in the Lean theorem
`first_pythagorean_instances`. The universal identity is proved by
`modular_pythagorean_identity`, so the table is illustrative rather than the basis of the result.

The exact disk coordinates are

\[
\operatorname{Re}(z_n)=\frac{n^2}{n^2+4},\qquad
\operatorname{Im}(z_n)=\frac{-2n}{n^2+4}.
\]

Substitution gives `|2z_n-1|² = 1`; this universal calculation is formally proved by
`cayleyModularOrbit_horocycle`.

## OEIS search

No external OEIS query was available during this work, so no OEIS identifier is asserted. The coordinate families are the classical Euclidean parametrization specialized at `(m,k)=(n,2)`; assigning an unverified sequence identifier would add no evidence.

## Counterexample hunt

The potentially problematic cases `n = 0, ±1, ±2` were included conceptually: one leg may be zero or negative before taking absolute values, but the integer square identity remains valid. Thus the formal theorem correctly states an identity for every integer rather than claiming every parameter gives a nondegenerate primitive triangle. No counterexample exists to the universal polynomial identity because Lean proves it symbolically.

## Geometry table

The squared Euclidean radius is `|z_n|² = n²/(n²+4)`:

| `n` | `|z_n|²` |
|---:|:---|
| 0 | 0 |
| 1 | 1/5 |
| 2 | 1/2 |
| 3 | 9/13 |
| 4 | 4/5 |
| 5 | 25/29 |

These values stay below `1`, while increasing toward the ideal boundary along positive indices, consistent with the proved disk-membership formula.
