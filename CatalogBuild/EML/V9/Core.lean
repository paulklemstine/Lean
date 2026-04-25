/-! # CatalogBuild.EML.V9.Core

Auto-generated from theorem catalog database.
Domain: EML/V9
Declarations: 15
-/

import Mathlib

noncomputable section

/-- The negation involution: N(x) = 1 − x (via eml(0, exp(x))). -/
def emlNeg (x : ℝ) : ℝ := 1 - x


/-- [Section: # CatalogBuild.EML.V9.Core
Auto-generated from theorem catalog database.
Domain: EML/V9
Declarations: 18] -/
theorem eml_one_one : eml 1 1 = Real.exp 1 := by
  simp [eml, Real.log_one]


/-- [Section: # CatalogBuild.EML.V9.Core
Auto-generated from theorem catalog database.
Domain: EML/V9
Declarations: 18] -/
theorem eml_self_pair (x : ℝ) : eml x (Real.exp x) = Real.exp x - x := by
  simp [eml, Real.log_exp]


/-- [Section: # CatalogBuild.EML.V9.Core
Auto-generated from theorem catalog database.
Domain: EML/V9
Declarations: 15] -/
theorem emlNeg_involution (x : ℝ) : emlNeg (emlNeg x) = x := by
  simp [emlNeg]


theorem eml_negation_via_exp (x : ℝ) : eml 0 (Real.exp x) = 1 - x := by
  simp [eml, Real.log_exp]


theorem emlSelfPair_min_achieved : emlSelfPair 0 = 1 := by
  simp [emlSelfPair]


theorem eml_hasDerivAt_x (x y : ℝ) :
    HasDerivAt (fun x' => eml x' y) (Real.exp x) x := by
  unfold eml
  have h := (Real.hasDerivAt_exp x).sub (hasDerivAt_const x (Real.log y))
  simp only [sub_zero] at h; exact h


theorem eml_hasDerivAt_y (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun y' => eml x y') (-y⁻¹) y := by
  unfold eml
  have h := (hasDerivAt_const y (Real.exp x)).sub (Real.hasDerivAt_log hy.ne')
  simp only [zero_sub] at h; exact h


theorem eml_log_ratio (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y / z) = eml x y + Real.log z := by
  unfold eml; rw [Real.log_div hy.ne' hz.ne']; ring


theorem eml_exp_sum (x y : ℝ) :
    eml (x + y) 1 = Real.exp x * Real.exp y := by
  simp [eml, Real.log_one, Real.exp_add]


theorem eml_antisymm (x y : ℝ) :
    eml x y - eml y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold eml; ring


theorem eml_generates_e2 : eml 2 1 = Real.exp 2 := by simp [eml, Real.log_one]


theorem eml_generates_eee : eml (eml (eml 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [eml, Real.log_one]


/-- EML generates addition via double application. -/
theorem eml_addition (a b : ℝ) (ha : 0 < a) :
    eml (Real.log a) (Real.exp (-b)) = a + b := by
  unfold eml; rw [Real.exp_log ha, Real.log_exp]; ring


/-- σ(x) = eˣ − x is always positive. -/
theorem emlSelfPair_pos (x : ℝ) : emlSelfPair x > 0 := by
  unfold emlSelfPair
  linarith [Real.add_one_le_exp x]


end
