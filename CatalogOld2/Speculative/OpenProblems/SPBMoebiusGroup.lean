/-! # CatalogBuild.Speculative.OpenProblems.SPBMoebiusGroup

Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 7
-/

import Mathlib

noncomputable section

/-- The "circle norm" N(x) = 1 + x² satisfies N(spb(x,y)) · (1-xy)² = N(x) · N(y).
This is the multiplicativity under stereographic projection. -/
theorem spb_circle_norm_mult (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spbM x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spbM
  field_simp
  ring


/-- For fixed y, spb(·, y) is a Möbius transformation, hence its Schwarzian
derivative vanishes. We verify this by showing spb(x,y) = (x+y)/(1-xy)
has the form (ax+b)/(cx+d). -/
theorem spb_is_moebius (y : ℝ) (x : ℝ) :
    spbM x y = (1 * x + y) / ((-y) * x + 1) := by
  unfold spbM
  ring_nf


/-- SPB negation is inverse: spb(x, -x) = 0. -/
theorem spbM_neg_cancel (x : ℝ) : spbM x (-x) = 0 := by
  simp [spbM]


/-- SPB with itself: spb(x, x) = 2x/(1-x²), the double angle tangent. -/
theorem spbM_self (x : ℝ) (h : 1 - x * x ≠ 0) :
    spbM x x = 2 * x / (1 - x ^ 2) := by
  unfold spbM
  field_simp
  ring


theorem spbM_cancel_right (x a : ℝ) (h1 : 1 - x * a ≠ 0)
    (h2 : 1 - spbM x a * (-a) ≠ 0) :
    spbM (spbM x a) (-a) = x := by
  unfold spbM at *;
  grind


theorem spbM_no_real_fixed_point (a x : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0)
    (hfix : spbM x a = x) : False := by
  unfold spbM at hfix;
  rw [ div_eq_iff h ] at hfix; cases lt_or_gt_of_ne ha <;> cases lt_or_gt_of_ne h <;> nlinarith [ sq_nonneg x ] ;


/-- The "angle" map: θ(x) = arctan(x). Under this map, SPB becomes addition:
θ(spb(x,y)) = θ(x) + θ(y) when 1 - xy > 0. -/
theorem spbM_angle_addition (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spbM x y) = arctan x + arctan y := by
  unfold spbM
  rw [Real.arctan_add (by linarith)]


end
