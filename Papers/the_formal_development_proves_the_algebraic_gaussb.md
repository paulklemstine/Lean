# Computational evidence — ideal triangles in the upper half-plane

All numbers below were produced with Lean 4 `#eval` on `Float`, using midpoint
Riemann sums

```lean
def midsum (f : Float → Float) (a b : Float) (n : Nat) : Float := ...
def dens (a b : Float) (x : Float) : Float := 1.0 / Float.sqrt ((x - a) * (b - x))
```

`dens a b` is the reciprocal of the geodesic semicircle height, i.e. the
vertically-sliced hyperbolic area density of an ideal triangle at curvature
`-1`.  These computations are *evidence only*; every claim they support is
proved without `sorry` in `Catalog/Geometry/CosmicHorror/`.

## 1. The ideal-triangle integral `∫ₐᵇ dx/√((x-a)(b-x)) = π`

| chord `[a,b]` | subdivisions `n` | midpoint sum |
|---|---|---|
| `[0,1]` | 1 000 | 3.103337 |
| `[0,1]` | 100 000 | 3.137767 |
| `[0,1]` | 2 000 000 | 3.140737 |
| `[-3,5]` | 100 000 | 3.137767 |

Convergence to `π = 3.14159…` is slow (the integrand has inverse-square-root
singularities at both endpoints, so the midpoint rule converges like `√h`), but
unmistakable.  Note that `[-3,5]` gives *exactly* the same value as `[0,1]` at
the same `n`: the affine invariance of the density is visible numerically, and
is the numerical shadow of `idealTriangleArea_congr`.

Proved statement: `CosmicHorrorGeometry.integral_invSqrtChord`.

## 2. Gauss–Bonnet with one ideal vertex

Configuration: vertices `(cos θ, sin θ)`, `(cos φ, sin φ)` on the unit
semicircle and the ideal point `∞`; predicted area `θ - φ`.

| `θ` | `φ` | numeric area (`n = 200 000`) | predicted `θ - φ` |
|---|---|---|---|
| 2.5 | 0.4 | 2.100000 | 2.100000 |

Agreement to all displayed digits (this integral has no endpoint singularity,
so convergence is fast).  Equivalently, with the interior angles
`α = π - θ = 0.6416`, `β = φ = 0.4`, one has `π - α - β = 2.1`.

Proved statement: `CosmicHorrorGeometry.oneIdealVertex_gauss_bonnet`.

## 3. Ideal polygons: `(n - 2)π`

Ideal quadrilateral with boundary vertices `0 < 1 < 3` and `∞`, cut by the
vertical geodesic through `1` into two ideal triangles:

```
midsum (dens 0 1) 0 1 200000 + midsum (dens 1 3) 1 3 200000 = 6.277775
2π                                                          = 6.283185
```

Consistent with `(4 - 2)π`.  Proved statement:
`CosmicHorrorGeometry.idealPolygonArea_eq`.

## 4. Curvature pinching

Area of the ideal triangle over `[0,1]` for a *variable* curvature profile
`-K(x)`, i.e. `∫₀¹ dx / (K(x) √(x - x²))`:

| profile `K` | range of `K` | numeric area | predicted window `[π/max K, π/min K]` |
|---|---|---|---|
| `K(x) = 2 + x` | `[2,3]` | 1.281837 | `[1.047198, 1.570796]` |
| `K(x) = 1 + 4x(1-x)` | `[1,2]` | 2.219731 | `[1.570796, 3.141593]` |

Both lie strictly inside their predicted windows, as they must.  Proved
statement: `CosmicHorrorGeometry.variableSlicedArea_pinched` (sharpness at
constant `K`: `variableSlicedArea_const`).

## 5. Counterexample hunt: positivity of the cross-ratio determinant

For the normalising Möbius map attached to `p < q < r` the coefficient
determinant is `(q-r)(-(r(q-p))) - (-(p(q-r)))(q-p)`.  Exhaustive scan over a
`12 × 12 × 12` grid of rational triples with `p ∈ [-6,5]`, `q ∈ [-3,2.5]`,
`r ∈ [0,11]`, keeping only ordered triples:

```
number of ordered triples with determinant ≤ 0  :  0
```

No counterexample; the identity `det = (r-q)(q-p)(r-p)` proved in
`crossRatio_det_pos` explains why none can exist.

## 6. OEIS

Not applicable.  Every invariant studied here is a continuous real number
(`π/κ`, `(n-2)π/κ`, `θ - φ`), not an integer sequence.  The one integral
parameter, the number of ideal vertices `n`, produces the trivially linear
sequence of areas `0, π, 2π, 3π, …` in units of `1/κ`.
