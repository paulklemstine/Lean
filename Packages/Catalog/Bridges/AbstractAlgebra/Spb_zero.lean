import Mathlib

/-! # CatalogBuild.Shared.Spb_zero

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5
-/

noncomputable section

open Real

/-- The speed-addition law `spb x y = (x + y) / (1 - x y)`.  (Supplied here.) -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- [Section: # CatalogBuild.Shared.Spb_zero
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem spb_zero (x : ℝ) : spb x 0 = x := by simp [spb]

/-- [Section: # CatalogBuild.Shared.Spb_zero
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5] -/
theorem spb_norm_identity (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + (spb x y) ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

theorem spb_eml_decomposition (x y : ℝ) (hden : 0 < 1 - x * y) :
    spb x y = (x + y) * exp (-log (1 - x * y)) := by
  unfold spb
  rw [Real.exp_neg, Real.exp_log hden]
  simp [spb, div_eq_mul_inv]

theorem spb_norm_ratio (x y : ℝ) (h : 1 - x * y ≠ 0) :
    1 + (spb x y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  have h2 : (1 - x * y) ^ 2 ≠ 0 := pow_ne_zero 2 h
  field_simp
  have := spb_norm_identity x y h
  linarith

theorem spb_neg (x : ℝ) : spb x (-x) = 0 := by simp [spb]

end