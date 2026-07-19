# Computational evidence

## Small cases

For the classical quadratic labels `c(n) = n(n+1)`, the first values and gaps are:

| `n` | `c(n)` | next gap `c(n+1)-c(n)` |
|---:|---:|---:|
| 0 | 0 | 2 |
| 1 | 2 | 4 |
| 2 | 6 | 6 |
| 3 | 12 | 8 |
| 4 | 20 | 10 |
| 5 | 30 | 12 |
| 6 | 42 | 14 |
| 7 | 56 | 16 |

The Lean theorem `casimirEigenvalue_gap` proves the general formula `2(n+1)`, and
`casimirEigenvalue_secondDifference` proves constant second difference `2`.

## Sequence identification

The integer sequence `0, 2, 6, 12, 20, 30, 42, 56, ...` consists of the pronic
(oblong) numbers, OEIS A002378, with formula `n(n+1)`.

## Counterexample and obstruction hunt

* An affine transform does **not** make these labels evenly spaced: adjacent gaps
  differ whenever its slope is nonzero. This is proved for every index by
  `affine_transform_adjacent_gaps_ne`.
* The literal logarithmic transform has size approximately `2 log n`, not
  `π n / log n`. The rigorous bounds are proved by
  `log_casimirEigenvalue_bounds`.
* A completely unrestricted function `f` can interpolate any prescribed real
  sequence on these labels. The theorem `arbitrary_sequence_has_spectral_map`
  proves this exactly, so the existence of an unspecified `f` is not a testable
  spectral prediction.

No numerical Riemann-zero comparison is asserted here: finite decimal data would
not establish RH, pair correlation, or a quantum-group representation theorem.
The description's phrase “Poisson-like spacings” also conflicts with its proposed
GUE comparison; Poisson and GUE local statistics are different models.
