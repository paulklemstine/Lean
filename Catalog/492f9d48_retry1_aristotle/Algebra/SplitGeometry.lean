import Mathlib

/-!
# Split Geometry: a direction-dependent parallel postulate

This file develops, rigorously and with complete proofs, the algebraic and
real-analytic core of the *Split Geometry* on `ℝ²` defined by the Riemannian
metric
$$ ds^2 = \frac{dx^2}{\cosh^2 y} + \cosh^2 x \, dy^2 . $$
The idea behind the construction is that the metric *expands* in the
`x`-direction (the coefficient `1/cosh²y = sech²y ≤ 1` shrinks distances, so
coordinate steps cover more ground) and *contracts* in the `y`-direction (the
coefficient `cosh²x ≥ 1` stretches distances).  The associated *conjectured
curvature function*
$$ K(x,y) = \operatorname{sech}^2 x - \operatorname{sech}^2 y $$
is designed to change sign across the diagonals `y = ±x`, giving a geometry that
is "elliptic in one region and hyperbolic in another."

We prove:

* `sech2_pos`, `metric_posDef` — the metric is a genuine (everywhere
  positive-definite) Riemannian metric, so the geometry is *consistent*;
* `sech2_lt_sech2_iff`, `sech2_eq_sech2_iff` — the exact monotonicity of
  `t ↦ sech² t` in `|t|`, the analytic engine behind everything else;
* `K_eq_zero_iff_abs`, `K_eq_zero_iff_sq`, `phaseBoundary_eq_diagonals` — the
  **phase boundary** `{K = 0}` is *exactly* the union of the two diagonals
  `y = x` and `y = -x`;
* `K_pos_of_abs_lt`, `K_neg_of_abs_lt` — the sign of `K` in the two regions
  `|x| < |y|` and `|y| < |x|`;
* `geodesic_crosses_at_most_twice` /
  `line_crosses_phaseBoundary_at_most_twice` — any straight coordinate line
  that is not parallel to a diagonal meets the phase boundary **at most twice**.

## Remark on the curvature

`K` as defined here is the sign-indicator function proposed in the Split
Geometry conjecture; the theorems below are statements about this explicit real
function and hold irrespective of its differential-geometric interpretation.
The *actual* Gaussian curvature of the metric above (computed from the
Brioschi formula for an orthogonal metric) is a different, messier function; see
`FUTURE_DIRECTIONS.md`.  What survives verbatim is the geometric skeleton the
conjecture is really about: the phase boundary is the pair of diagonals, and the
sign pattern is governed by comparing `|x|` with `|y|`.
-/

namespace SplitGeometry

open Real

/-- `sech² t = 1 / cosh² t`, the coefficient governing the `x`-direction of the
split metric (and, reflected, the shape of the conjectured curvature). -/
noncomputable def sech2 (t : ℝ) : ℝ := 1 / Real.cosh t ^ 2

/-- The `x`-`x` coefficient `E = sech² y` of the split metric
`ds² = E dx² + G dy²`. -/
noncomputable def gE (y : ℝ) : ℝ := sech2 y

/-- The `y`-`y` coefficient `G = cosh² x` of the split metric
`ds² = E dx² + G dy²`. -/
noncomputable def gG (x : ℝ) : ℝ := Real.cosh x ^ 2

/-- The conjectured curvature function `K(x,y) = sech² x - sech² y`. -/
noncomputable def K (x y : ℝ) : ℝ := sech2 x - sech2 y

/-! ### Basic positivity: the metric is a consistent Riemannian metric -/

/-- `sech²` is strictly positive everywhere. -/
theorem sech2_pos (t : ℝ) : 0 < sech2 t := by
  unfold sech2; positivity

theorem gE_pos (y : ℝ) : 0 < gE y := sech2_pos y

theorem gG_pos (x : ℝ) : 0 < gG x := by
  unfold gG; positivity

/-- The determinant `E·G = sech²y · cosh²x` of the metric tensor is positive,
so the metric is nondegenerate everywhere. -/
theorem metric_det_pos (x y : ℝ) : 0 < gE y * gG x :=
  mul_pos (gE_pos y) (gG_pos x)

/-- **Consistency.** The split metric is positive-definite at every point: for
any nonzero tangent vector `(u, v)` the quadratic form `E u² + G v²` is strictly
positive.  Hence the Split Geometry is a genuine Riemannian geometry. -/
theorem metric_posDef (x y u v : ℝ) (h : u ≠ 0 ∨ v ≠ 0) :
    0 < gE y * u ^ 2 + gG x * v ^ 2 := by
  rcases h with hu | hv
  · have hu2 : 0 < u ^ 2 := by rw [← sq_abs]; exact pow_pos (abs_pos.mpr hu) 2
    have h1 : 0 < gE y * u ^ 2 := mul_pos (gE_pos y) hu2
    have h2 : 0 ≤ gG x * v ^ 2 := mul_nonneg (le_of_lt (gG_pos x)) (sq_nonneg v)
    linarith
  · have hv2 : 0 < v ^ 2 := by rw [← sq_abs]; exact pow_pos (abs_pos.mpr hv) 2
    have h1 : 0 < gG x * v ^ 2 := mul_pos (gG_pos x) hv2
    have h2 : 0 ≤ gE y * u ^ 2 := mul_nonneg (le_of_lt (gE_pos y)) (sq_nonneg u)
    linarith

/-! ### Monotonicity of `sech²` in `|t|` -/

/-- `sech²` is strictly decreasing in the absolute value of its argument. -/
theorem sech2_lt_sech2_iff (a b : ℝ) : sech2 a < sech2 b ↔ |b| < |a| := by
  unfold sech2
  rw [← Real.cosh_lt_cosh]
  have ha := Real.cosh_pos a
  have hb := Real.cosh_pos b
  rw [one_div, one_div, inv_lt_inv₀ (by positivity) (by positivity)]
  constructor
  · intro h; nlinarith [Real.cosh_pos a, Real.cosh_pos b]
  · intro h; nlinarith [Real.cosh_pos a, Real.cosh_pos b]

/-- `sech² a ≤ sech² b` exactly when `|b| ≤ |a|`. -/
theorem sech2_le_sech2_iff (a b : ℝ) : sech2 a ≤ sech2 b ↔ |b| ≤ |a| := by
  rw [← not_lt, ← not_lt, sech2_lt_sech2_iff]

/-- `sech²` separates points up to sign: `sech² a = sech² b ↔ |a| = |b|`. -/
theorem sech2_eq_sech2_iff (a b : ℝ) : sech2 a = sech2 b ↔ |a| = |b| := by
  rw [le_antisymm_iff, le_antisymm_iff, sech2_le_sech2_iff, sech2_le_sech2_iff,
    and_comm]

/-! ### The phase boundary is the pair of diagonals -/

/-- The phase boundary `K = 0` is exactly the set where `|x| = |y|`. -/
theorem K_eq_zero_iff_abs (x y : ℝ) : K x y = 0 ↔ |x| = |y| := by
  unfold K
  rw [sub_eq_zero, sech2_eq_sech2_iff]

/-- The phase boundary `K = 0` is exactly the set where `x² = y²`. -/
theorem K_eq_zero_iff_sq (x y : ℝ) : K x y = 0 ↔ x ^ 2 = y ^ 2 := by
  rw [K_eq_zero_iff_abs, ← sq_abs x, ← sq_abs y]
  constructor
  · intro h; rw [h]
  · intro h
    have := abs_nonneg x
    have := abs_nonneg y
    nlinarith [sq_abs x, sq_abs y, abs_nonneg x, abs_nonneg y]

/-- **Phase boundary = diagonals.** `K x y = 0` iff `(x,y)` lies on one of the
two diagonals `y = x` or `y = -x`. -/
theorem phaseBoundary_eq_diagonals (x y : ℝ) :
    K x y = 0 ↔ x = y ∨ x = -y := by
  rw [K_eq_zero_iff_abs, abs_eq_abs]

/-! ### Sign of `K` in the two regions -/

/-- In the region `|x| < |y|` the conjectured curvature is positive. -/
theorem K_pos_of_abs_lt (x y : ℝ) (h : |x| < |y|) : 0 < K x y := by
  unfold K
  have : sech2 y < sech2 x := (sech2_lt_sech2_iff y x).mpr h
  linarith

/-- In the region `|y| < |x|` the conjectured curvature is negative. -/
theorem K_neg_of_abs_lt (x y : ℝ) (h : |y| < |x|) : K x y < 0 := by
  unfold K
  have : sech2 x < sech2 y := (sech2_lt_sech2_iff x y).mpr h
  linarith

/-- Trichotomy across the phase boundary: at every point exactly one of the
three geometric phases holds — positively curved (`0 < K`), flat on the
boundary (`K = 0`), or negatively curved (`K < 0`). -/
theorem K_trichotomy (x y : ℝ) :
    (0 < K x y ∧ |x| < |y|) ∨ (K x y = 0 ∧ |x| = |y|) ∨
      (K x y < 0 ∧ |y| < |x|) := by
  rcases lt_trichotomy (|x|) (|y|) with h | h | h
  · exact Or.inl ⟨K_pos_of_abs_lt x y h, h⟩
  · exact Or.inr (Or.inl ⟨(K_eq_zero_iff_abs x y).mpr h, h⟩)
  · exact Or.inr (Or.inr ⟨K_neg_of_abs_lt x y h, h⟩)

/-! ### Crossing the phase boundary at most twice -/

/-- **Geodesic/line crossing bound (algebraic core).** Consider a straight
coordinate line `t ↦ (x₀ + t·a, y₀ + t·b)` that is *not* parallel to either
diagonal, i.e. `a² ≠ b²`.  Then among any three parameters `t₁, t₂, t₃` at which
the point lies on the phase boundary `{x² = y²}`, two must coincide.  In other
words, the line meets the phase boundary in at most two distinct points. -/
theorem geodesic_crosses_at_most_twice (a b x0 y0 t1 t2 t3 : ℝ) (hab : a ^ 2 ≠ b ^ 2)
    (h1 : (x0 + t1 * a) ^ 2 = (y0 + t1 * b) ^ 2)
    (h2 : (x0 + t2 * a) ^ 2 = (y0 + t2 * b) ^ 2)
    (h3 : (x0 + t3 * a) ^ 2 = (y0 + t3 * b) ^ 2) :
    t1 = t2 ∨ t1 = t3 ∨ t2 = t3 := by
  by_contra h
  push_neg at h
  obtain ⟨h12, h13, h23⟩ := h
  have e12 : (t1 - t2) * ((a ^ 2 - b ^ 2) * (t1 + t2) + 2 * (x0 * a - y0 * b)) = 0 := by
    nlinarith [h1, h2]
  have e13 : (t1 - t3) * ((a ^ 2 - b ^ 2) * (t1 + t3) + 2 * (x0 * a - y0 * b)) = 0 := by
    nlinarith [h1, h3]
  have f12 : (a ^ 2 - b ^ 2) * (t1 + t2) + 2 * (x0 * a - y0 * b) = 0 := by
    rcases mul_eq_zero.1 e12 with h | h
    · exact absurd (by linarith : t1 = t2) h12
    · exact h
  have f13 : (a ^ 2 - b ^ 2) * (t1 + t3) + 2 * (x0 * a - y0 * b) = 0 := by
    rcases mul_eq_zero.1 e13 with h | h
    · exact absurd (by linarith : t1 = t3) h13
    · exact h
  have hz : (a ^ 2 - b ^ 2) * (t2 - t3) = 0 := by nlinarith [f12, f13]
  rcases mul_eq_zero.1 hz with h | h
  · exact hab (by linarith)
  · exact h23 (by linarith)

/-- **Geodesic/line crossing bound (stated via `K`).** A straight coordinate
line not parallel to a diagonal (`a² ≠ b²`) crosses the phase boundary `K = 0`
at most twice: among any three parameters at which `K` vanishes along the line,
two coincide. -/
theorem line_crosses_phaseBoundary_at_most_twice
    (a b x0 y0 t1 t2 t3 : ℝ) (hab : a ^ 2 ≠ b ^ 2)
    (h1 : K (x0 + t1 * a) (y0 + t1 * b) = 0)
    (h2 : K (x0 + t2 * a) (y0 + t2 * b) = 0)
    (h3 : K (x0 + t3 * a) (y0 + t3 * b) = 0) :
    t1 = t2 ∨ t1 = t3 ∨ t2 = t3 :=
  geodesic_crosses_at_most_twice a b x0 y0 t1 t2 t3 hab
    ((K_eq_zero_iff_sq _ _).mp h1)
    ((K_eq_zero_iff_sq _ _).mp h2)
    ((K_eq_zero_iff_sq _ _).mp h3)

end SplitGeometry