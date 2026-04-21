/-! # CatalogBuild.EML.WickRotation

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 2
-/

import Mathlib

noncomputable section

/-- The Wick rotation on SPB is a sign flip in the denominator.
spbCirc(x, -y) gives a "mixed" formula. -/
theorem wick_sign_flip (x y : ℝ) :
    spbCirc x (-y) = (x - y) / (1 + x * y) := by
  simp [spbCirc]; ring




/-- [Section: # CatalogBuild.EML.WickRotation
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 2] -/
theorem tan_add_is_spbCirc (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
    Real.tan (α + β) = spbCirc (Real.tan α) (Real.tan β) := by
  simp +decide [ *, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add, spbCirc ];
  grind




end
