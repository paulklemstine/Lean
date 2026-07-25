import Mathlib

/-!
# Gaussian (sectional) curvature of the split geometry

For a surface the sectional curvature is a single scalar at each point — the
**Gaussian curvature** `K(p)`.  (In two dimensions there is only one tangent
`2`-plane, so curvature cannot be "direction dependent"; the problem statement's
request for two different signs "for the x-direction" and "for the y-direction" is
therefore about the values of the single function `K` *at points on the two axes*.)

For the orthogonal metric `g = E dx² + G dy²` with `E = sech² y`, `G = cosh² x`,
Brioschi's/do Carmo's formula
`K = -1/(2√(EG)) ( ∂ₓ(Gₓ/√(EG)) + ∂_y(E_y/√(EG)) )`
gives, after simplification,
`K(x, y) = -cosh² y + (2 - cosh² y) / (cosh² x · cosh² y)`.

(The closed form has been cross-checked against a finite-difference evaluation of the
Brioschi formula.)

## Signs along the axes

* **Along the x-axis** `K(x, 0) = -tanh² x ≤ 0`, strictly negative off the origin
  (`K_xaxis`, `K_xaxis_neg`).  Negative curvature ⇒ hyperbolic *divergence* of nearby
  geodesics, matching the problem's "x-direction" prediction.
* **Along the y-axis** `K(0, y) = -cosh² y + 2 sech² y - 1 ≤ 0`, again strictly
  negative off the origin (`K_yaxis`, `K_yaxis_neg`).  Thus the curvature is **not**
  positive along the y-axis: the problem's "elliptic, K > 0" prediction is *false* for
  this metric.  We record the true (nonpositive) value.  The generic elliptic behaviour
  (which would require `K > 0`) is studied abstractly in `Deviation.lean`.
-/

namespace SplitGeometry

open Real

/-- The Gaussian curvature of the split metric, in closed form. -/
noncomputable def K (p : ℝ × ℝ) : ℝ :=
  -(Real.cosh p.2) ^ 2 + (2 - (Real.cosh p.2) ^ 2) / ((Real.cosh p.1) ^ 2 * (Real.cosh p.2) ^ 2)

/-
Curvature at the origin vanishes.
-/
@[simp] theorem K_origin : K (0, 0) = 0 := by
  unfold K; norm_num;

/-
**Curvature along the x-axis**: `K(x, 0) = -tanh² x`.
-/
theorem K_xaxis (a : ℝ) : K (a, 0) = -(Real.tanh a) ^ 2 := by
  unfold K;
  norm_num [ Real.tanh_eq_sinh_div_cosh, Real.sinh_sq ];
  rw [ div_pow, Real.sinh_sq, sub_div, inv_eq_one_div, div_self ] ; ring ; positivity

/-
Along the x-axis the curvature is nonpositive.
-/
theorem K_xaxis_nonpos (a : ℝ) : K (a, 0) ≤ 0 := by
  exact K_xaxis a ▸ neg_nonpos_of_nonneg ( sq_nonneg _ )

/-
Off the origin, curvature along the x-axis is strictly negative (hyperbolic).
-/
theorem K_xaxis_neg (a : ℝ) (ha : a ≠ 0) : K (a, 0) < 0 := by
  rw [ K_xaxis ];
  norm_num [ Real.tanh_eq_sinh_div_cosh ];
  exact sq_pos_of_ne_zero ( div_ne_zero ( by simp [ ha ] ) ( ne_of_gt ( Real.cosh_pos _ ) ) )

/-
**Curvature along the y-axis**: `K(0, y) = -cosh² y + 2 sech² y - 1`.
-/
theorem K_yaxis (b : ℝ) :
    K (0, b) = -(Real.cosh b) ^ 2 + 2 * (Real.cosh b)⁻¹ ^ 2 - 1 := by
  have hc : (Real.cosh b) ≠ 0 := (Real.cosh_pos b).ne'
  simp only [K, Real.cosh_zero]
  field_simp
  ring

/-
Along the y-axis the curvature is nonpositive (contradicting the "elliptic, K > 0"
prediction of the problem statement).
-/
theorem K_yaxis_nonpos (b : ℝ) : K (0, b) ≤ 0 := by
  unfold K;
  norm_num;
  rw [ div_le_iff₀ ] <;> nlinarith [ sq_nonneg ( Real.cosh b ^ 2 - 1 ), Real.cosh_sq' b ]

/-
Off the origin, curvature along the y-axis is strictly negative — so the metric is
**not** elliptic in the y-direction.
-/
theorem K_yaxis_neg (b : ℝ) (hb : b ≠ 0) : K (0, b) < 0 := by
  rw [ K_yaxis ];
  nlinarith [ show 1 < Real.cosh b from by simpa using Real.one_lt_cosh.mpr hb, inv_mul_cancel₀ ( ne_of_gt ( Real.cosh_pos b ) ), pow_two_nonneg ( Real.cosh b - 1 ), pow_two_nonneg ( ( Real.cosh b ) ⁻¹ - 1 ), mul_inv_cancel₀ ( ne_of_gt ( sq_pos_of_pos ( Real.cosh_pos b ) ) ) ]

end SplitGeometry