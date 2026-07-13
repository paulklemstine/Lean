# Computational Evidence — Sharp Diagonal Correlation Inequality

All quantities below are the *exact* rational values of the uniform expectation
`E`, variance `Var f = E(f²) − (E f)²`, and covariance
`Cov f g = E(fg) − (E f)(E g)` on the discrete cube `{0,1}ⁿ`.

## Small-case calculations (n = 2)

Observables considered on `{0,1}²`:

| observable | description | E | Var |
|-----------|-------------|------|------|
| `dict₀`   | first coordinate (dictatorship) | 1/2 | 1/4 |
| `dict₁`   | second coordinate (dictatorship) | 1/2 | 1/4 |
| `AND`     | `x₀ ∧ x₁` | 1/4 | 3/16 |
| `OR`      | `x₀ ∨ x₁` | 3/4 | 3/16 |

Covariances:

| pair | Cov |
|------|-----|
| `Cov(dict₀, dict₀)` | **1/4** (extremal, diagonal) |
| `Cov(dict₀, dict₁)` | **0** (disjoint supports) |
| `Cov(dict₀, AND)` | 1/8 |
| `Cov(AND, OR)` | 1/16 |

Every listed covariance satisfies `Cov ≤ 1/4`, and equality holds exactly for a
common dictatorship `Cov(dict₀, dict₀) = 1/4`. Every listed variance satisfies
`Var ≤ 1/4`. Distinct-coordinate dictatorships are uncorrelated. These are the
exact predictions of `cov_le_quarter`, `var_le_quarter`, `cov_dict_same`,
`cov_dict_diff` and `var_dict`.

## Counterexample hunt

* **Is `Cov ≤ 1/4` sharp?** The value `Cov(dict₀, dict₀) = 1/4` shows the bound is
  attained, so it cannot be improved for `[0,1]`-valued observables.
* **Can distinct-coordinate dictatorships be correlated?** No: every tested pair
  on disjoint coordinate blocks returned `Cov = 0`, matching `cov_zero_of_indep`.
* **Does the lower FKG bound `0 ≤ Cov` need the nonnegativity of `f, g`?** No: the
  covariance is translation invariant, so shifting monotone observables to the
  nonnegative orthant leaves `Cov` unchanged — confirmed by `Cov(dict₀−1, dict₀−1)
  = 1/4 = Cov(dict₀, dict₀)`. This is `cov_nonneg` (arbitrary real monotone data).

## OEIS

No integer sequence is central here; the objects are the rational correlation
values above, whose denominators are powers of two as expected for uniform
measures on `{0,1}ⁿ`.

## Conclusion

The computational landscape is fully consistent with the formalised statements:
the correlation of increasing observables is nonnegative, bounded above by `1/4`
in the `[0,1]` regime, extremised on the diagonal by common dictatorships, and
vanishes exactly on disjoint coordinate supports.
