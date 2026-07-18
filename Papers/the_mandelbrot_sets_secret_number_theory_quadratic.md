# Computational evidence

## Small cases

For the critical orbit `z₀ = 0`, `zₙ₊₁ = zₙ² + c`:

| parameter `c` | initial orbit | primitive period |
|---|---|---:|
| `0` | `0, 0, ...` | 1 |
| `-1` | `0, -1, 0, -1, ...` | 2 |

The second row is proved exactly in Lean by `basilica_center_exactPeriod`; its two distinct pre-return points are counted by `basilica_center_orbit_card`.

The generic exact-period point counts from the Möbius formula begin `2, 2, 6` for periods `1, 2, 3`; these three evaluations are proved in Lean as `dynatomic_one`, `dynatomic_two`, and `dynatomic_three`.

## Counterexample hunt and correction of the motivating claim

At a center whose critical orbit has positive period, its multiplier is zero because the derivative of `z ↦ z²+c` at the critical point `0` is zero. The Lean theorem `criticalOrbit_multiplier_zero` proves this for every parameter and every positive iterate. Consequently the proposed center formula

`λ(c) = log(2) cos(π p/q)`

cannot describe the usual cycle multiplier/Lyapunov exponent at bulb centers: the multiplier is zero there (and the usual logarithmic cycle exponent is `-∞`), while the displayed expression is generally finite and nonzero. For example, for `p/q = 1/3` its right side is `log(2)/2`.

The claims about dihedral symmetry and topological products were not encoded because no precise definitions of the relevant bulb, symmetry action, or product decomposition were supplied, and the informal assertions are not standard consequences of quadratic dynamics.

## OEIS

The generic exact-period counts are necklace/dynatomic counts obtained by Möbius inversion of `2^n`. No OEIS identifier is asserted here because an external OEIS lookup was not performed.

## Plot/table scope

No floating-point Mandelbrot rendering was used: the selected results are exact algebraic and arithmetic statements, and all reported numerical cases are kernel-checked in Lean.