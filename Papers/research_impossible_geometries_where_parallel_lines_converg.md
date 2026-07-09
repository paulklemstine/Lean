# Split Geometry on the Plane: a Lean 4 Formalization

## Abstract

We formalize, in Lean 4 with Mathlib, a Riemannian metric on the plane `ℝ²` whose
coefficients mix hyperbolic factors in the two coordinate directions:
```
g = (dx ⊗ dx) / cosh²(y) + cosh²(x) · (dy ⊗ dy).
```
We set up the manifold and the metric tensor, prove that the metric is smooth and
positive definite, derive the geodesic equations (Christoffel symbols), exhibit the
genuine coordinate-axis geodesics, and compute the Gaussian (sectional) curvature in
closed form, determining its sign along the coordinate axes. The development also
records — and formally corrects — several inaccurate claims in the original informal
problem statement.

All results are machine-checked and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## 1. Problem statement

Let `M := ℝ²` with its standard smooth structure and the metric `g` above, i.e. the
diagonal metric with components
```
E(x, y) = g₁₁ = sech²(y),      G(x, y) = g₂₂ = cosh²(x),      g₁₂ = 0.
```
The original task asked to:

1. formalize the manifold, the metric tensor, and prove smoothness and positive
   definiteness;
2. derive the geodesic equations and solve those tangent to the coordinate axes;
3. establish exponential *divergence* of geodesics along the x-axis (hyperbolic
   behaviour) and exponential *convergence* along the y-axis (elliptic behaviour);
4. compute the sectional curvature `K` along the coordinate directions and show
   `K < 0` for the x-direction and `K > 0` for the y-direction.

## 2. Mathematical context

For an orthogonal ("diagonal") surface metric `g = E dx² + G dy²`, the non-vanishing
Christoffel symbols are computed from
`Γᵏᵢⱼ = ½ gᵏˡ (∂ᵢ gⱼˡ + ∂ⱼ gᵢˡ − ∂ˡ gᵢⱼ)`, and the Gaussian curvature by the
Brioschi/do Carmo formula
```
K = −1 / (2 √(EG)) · [ ∂ₓ( Gₓ / √(EG) ) + ∂_y( E_y / √(EG) ) ].
```
For a surface the *sectional* curvature is a single scalar at each point (the Gaussian
curvature): there is only one tangent 2-plane, so curvature cannot be
"direction dependent". Geodesic deviation of neighbouring geodesics is governed by the
Jacobi equation `J'' + K · J = 0`; the sign of `K` dictates hyperbolic divergence
(`K < 0`, growth `~ sinh`) versus elliptic reconvergence (`K > 0`, oscillation
`~ sin`). This is where the exponential factors `e^{±t}` genuinely appear.

## 3. Computed quantities

For our metric `E = sech²(y)`, `G = cosh²(x)`, `√(EG) = cosh(x)/cosh(y)`. The nonzero
Christoffel symbols (coordinates `(x, y)`) are:
```
Γ¹₁₂ = Γ¹₂₁ = −tanh y,                 Γ¹₂₂ = −cosh x · sinh x · cosh² y,
Γ²₁₁ = sech² y · tanh y / cosh² x,     Γ²₁₂ = Γ²₂₁ = tanh x,       (Γ¹₁₁ = Γ²₂₂ = 0).
```
The Gaussian curvature simplifies to the closed form
```
K(x, y) = −cosh² y + (2 − cosh² y) / (cosh² x · cosh² y).
```
(The closed form was cross-checked against a finite-difference evaluation of the
Brioschi formula at several points; the two agree to numerical precision.)

Along the axes:
```
K(x, 0) = −tanh² x          (≤ 0, strictly < 0 for x ≠ 0),
K(0, y) = −cosh² y + 2 sech² y − 1   (≤ 0, strictly < 0 for y ≠ 0),
K(0, 0) = 0.
```

## 4. Main results (Lean)

The development lives in `Catalog/Novelty/SplitGeometry/`, four self-contained files:

### `Metric.lean` — manifold and metric tensor
* `M := ℝ × ℝ` is a `C^∞` manifold (`IsManifold (𝓘(ℝ, M)) ⊤ M`, from the standard
  instance for a finite-dimensional real normed space).
* `Emet`, `Gmet` are the coefficients; `gForm p v w` is the metric as a bilinear form
  on tangent vectors (tangent vectors to `ℝ²` are again elements of `ℝ²`).
* `Emet_pos`, `Gmet_pos`: the coefficients are positive.
* `gForm_symm`, `gForm_add_right`, `gForm_smul_right`: `g` is a symmetric bilinear form.
* `gForm_self_nonneg`, `gForm_self_eq_zero`, `gForm_self_pos`: **positive
  definiteness** — `g_p(v, v) ≥ 0`, and `= 0` iff `v = 0`.
* `Emet_smooth`, `Gmet_smooth`, `gForm_smooth`: **smoothness** (`ContDiff ℝ ⊤`) of the
  coefficients and of `p ↦ g_p(v, w)`.

*Proof sketches.* Positivity is `pow_pos` applied to `0 < cosh`. Positive definiteness
follows because `g_p(v,v)` is a sum of two nonnegative squares with positive
coefficients, zero only when both components vanish. Smoothness is by the closure of
`ContDiff` under composition, `inv` (valid since `cosh ≠ 0`), and `pow`.

### `Geodesic.lean` — Christoffel symbols, geodesic equations, axis geodesics
* `Chr1_12, Chr1_22, Chr2_11, Chr2_12`: the closed-form Christoffel symbols.
* `IsGeodesic x y`: the geodesic ODE system for a coordinate curve `t ↦ (x t, y t)`.
* `xAxis_geodesic`: `t ↦ (x₀ + a t, 0)` is a geodesic.
* `yAxis_geodesic`: `t ↦ (0, y₀ + b t)` is a geodesic.
* `claimed_x_curve_not_geodesic`: the proposed curve `x t = t, y t = eᵗ` is **not** a
  geodesic (it violates a geodesic equation at `t = 0`).

*Proof sketches.* For an axis line one coordinate is constant and the other affine, so
the second derivatives vanish; every surviving Christoffel term carries a factor
`tanh 0 = 0` or `sinh 0 = 0`, killing it. For the refutation, evaluating the second
geodesic equation of `(t, eᵗ)` at `t = 0` gives `1 + sech²(1)·tanh(1) > 0 ≠ 0`.

### `Curvature.lean` — Gaussian (sectional) curvature
* `K`: the closed-form Gaussian curvature.
* `K_origin`: `K(0,0) = 0`.
* `K_xaxis`, `K_xaxis_nonpos`, `K_xaxis_neg`: `K(x,0) = −tanh² x ≤ 0`, strictly
  negative off the origin.
* `K_yaxis`, `K_yaxis_nonpos`, `K_yaxis_neg`: `K(0,y) = −cosh² y + 2 sech² y − 1 ≤ 0`,
  strictly negative off the origin.

*Proof sketches.* Substitute `cosh 0 = 1`; the x-axis identity uses
`cosh² − sinh² = 1`; the y-axis signs reduce, after clearing denominators, to
`(c−1)(c+2) ≥ 0` with `c = cosh² y ≥ 1` (`Real.one_lt_cosh`).

### `Deviation.lean` — geodesic deviation (Jacobi fields)
* `jacobiHyp k t = sinh(√k t)`, `jacobiEll k t = sin(√k t)`.
* `jacobiHyp_solves`: solves `J'' − k J = 0` (i.e. `J'' + K J = 0` with `K = −k`).
* `jacobiHyp_diverges`: for `k > 0` the field `→ ∞` — **hyperbolic divergence**.
* `jacobiEll_solves`: solves `J'' + k J = 0` (curvature `K = +k`).
* `jacobiEll_bounded`, `jacobiEll_refocus`: `|J| ≤ 1` and `J(π/√k) = 0` —
  **elliptic reconvergence**.

*Proof sketches.* Differentiate twice with `HasDerivAt.sinh/cosh` (resp. `sin/cos`)
and the chain rule for `t ↦ √k · t`; use `√k·√k = k`. Divergence follows from
`sinh x = (eˣ − e⁻ˣ)/2` and `exp → ∞`.

## 5. Corrections to the informal problem statement

The formalization is faithful to the metric as literally written, and this exposes
three mathematical inaccuracies in the informal task, which we record honestly:

1. **The proposed geodesics are wrong.** `x = x₀ + a t, y = y₀ eᵗ` (and its y-analogue
   `x = x₀ e⁻ᵗ`) do not satisfy the geodesic equations of this metric; moreover a
   curve "tangent to the x-axis" has `ẏ(0) = 0`, incompatible with `y = y₀ eᵗ`. The
   genuine axis geodesics are the coordinate straight lines
   `(x₀ + a t, 0)` and `(0, y₀ + b t)` (formalized). This is proved in
   `claimed_x_curve_not_geodesic` and `xAxis_geodesic` / `yAxis_geodesic`.
2. **Sectional curvature is not direction dependent in 2D.** A surface has a single
   Gaussian curvature `K(p)` at each point; "`K < 0` for the x-direction and `K > 0`
   for the y-direction" cannot hold pointwise. We interpret the request as the value
   of `K` at points on the two axes.
3. **The y-axis is not elliptic.** For this metric `K(0, y) < 0` for `y ≠ 0`, so the
   metric is (non-strictly) hyperbolic along *both* axes; the "`K > 0`, elliptic
   convergence" prediction is false. The x-axis prediction (`K ≤ 0`, hyperbolic
   divergence) is correct. The generic elliptic behaviour (which requires `K > 0`) is
   still recorded abstractly via the Jacobi normal form in `Deviation.lean`.

The exponential factors `e^{±t}` of the informal statement are real, but they describe
the *geodesic deviation* (Jacobi fields), not the geodesics themselves.

## 6. Significance

The example illustrates, concretely and verifiably, how a coordinate-anisotropic
conformal-type factor shapes geodesic flow and curvature: it produces a metric that is
flat at the origin and hyperbolic away from it, with the coordinate axes as exact
geodesics. The Jacobi-field lemmas give a clean, reusable formal statement of the
divergence/convergence dichotomy driven by the sign of curvature, independent of this
particular metric.

## 7. Open questions

* **Higher dimensions.** Extend to `ℝⁿ` with direction-dependent conformal factors and
  study when genuinely mixed-sign sectional curvature (only possible for `n ≥ 3`) can be
  realised; formalize the sectional curvature of coordinate 2-planes.
* **Completeness.** Decide geodesic completeness of `(ℝ², g)` and formalize it; the
  affine axis geodesics are complete, but off-axis behaviour is open.
* **Non-coordinate geodesics.** Characterize and (numerically or symbolically) integrate
  geodesics with generic initial directions, and formalize a global divergence bound via
  Grönwall's inequality using the sign of `K`.
* **A genuinely split metric.** Search for and formalize a plane metric whose curvature
  is negative along one axis and positive along another (necessarily changing sign in
  between), realising the "split" behaviour the original problem envisioned.
```
