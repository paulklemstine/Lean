# Computational Evidence — `L¹` ≤ Fisher–Rao length

All numbers below were produced by `Catalog/Algebra/FisherRaoLength/Evidence.lean`
(`Float` arithmetic, midpoint Riemann sums with `N = 20000` subintervals).
These are exploratory computations, **not** verified facts; the verified
statements are the `sorry`-free theorems in `Catalog/Algebra/FisherRaoLength/Core.lean`.

## 1. A 3-point curve in the interior of the simplex

Curve on `Δ₂`:

```
p(t) = (0.5 + 0.20 sin t,  0.3 − 0.05 sin t,  0.2 − 0.15 sin t)
v(t) = (0.20 cos t,       −0.05 cos t,       −0.15 cos t)
```

(coordinates sum to 1 for every `t`, strictly positive for `t ∈ [0, 1.5]`).

| interval `[a,b]` | `‖p b − p a‖₁` | Fisher–Rao length | ratio L/‖·‖₁ |
|---|---|---|---|
| `[0, 0.5]` | 0.191770 | 0.225410 | 1.175 |
| `[0, 1.5]` | 0.398998 | 0.526623 | 1.320 |
| `[0.3, 1.2]` | 0.254608 | 0.345649 | 1.358 |

No violation of `l1Dist ≤ fisherRaoLength` was found in any sampled interval.

**Counterexample hunt / boundary behaviour.**  Replacing the third coordinate by
`0.2 − 0.3 sin t` makes it negative near `t = 1.5`; the Fisher–Rao integrand
then evaluates to `NaN` (`√` of a negative number).  This is exactly the
degeneration that the strict-positivity hypothesis `hpos` in
`l1_le_fisherRao_length` excludes: on the boundary of the simplex the
Fisher–Rao metric blows up, and the length functional is no longer given by a
finite Riemann integral of a continuous integrand.

## 2. The two-point family (exactly solvable, used for sharpness)

```
p_r(t) = ((1 + r sin t)/2, (1 − r sin t)/2),   t ∈ [0, π/2]
```

Predicted: `‖p_r(π/2) − p_r(0)‖₁ = r` and `length = arcsin r`.

| `r` | Riemann length (N = 20000) | `arcsin r` | `arcsin r / r` |
|---|---|---|---|
| 0.01 | 0.0100000 | 0.0100002 | 1.000017 |
| 0.1  | 0.100167  | 0.100167   | 1.001674 |
| 0.5  | 0.523599  | 0.523599   | 1.047198 |
| 0.9  | 1.119770  | 1.119770   | 1.244188 |

The numerics agree with the closed form `arcsin r` to six digits, confirming
`TwoPoint.fisherRaoLength_eq_arcsin`, and the ratio `arcsin r / r → 1` as
`r → 0` is the numerical shadow of `TwoPoint.sharp`: the constant `1` in the
main inequality is optimal.  (No new integer sequence arises
here — the expansion is the classical Taylor series of `arcsin` — so no OEIS
identification is claimed.)

## 3. The chord bound

For the 3-point curve above, `‖√p b − √p a‖₂` versus `½ · length`:

| interval | chord | ½ · length |
|---|---|---|
| `[0, 0.5]` | 0.112607 | 0.112705 |
| `[0, 1.5]` | 0.261912 | 0.263311 |

The chord bound `sqrt_chord_le_half_fisherRao_length` is numerically *very*
tight (relative gap `< 10⁻³` here), consistent with its interpretation as the
"chord ≤ arc" inequality on the unit sphere: the square-root embedding turns
the Fisher–Rao geometry into spherical geometry, and this curve is nearly a
great-circle arc.
