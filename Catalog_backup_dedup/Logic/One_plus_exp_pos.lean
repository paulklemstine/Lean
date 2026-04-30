import Mathlib

/-! # CatalogBuild.Shared.One_plus_exp_pos

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 2
-/

noncomputable section

/-- 1 + eˣ > 0 for all x -/
lemma one_plus_exp_pos (x : ℝ) : (1 : ℝ) + Real.exp x > 0 := by
  linarith [Real.exp_pos x]

/-- 1 + eˣ > 1 for all x -/
lemma one_plus_exp_gt_one (x : ℝ) : (1 : ℝ) + Real.exp x > 1 := by
  linarith [Real.exp_pos x]

end
