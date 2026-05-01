/-! # CatalogBuild.EML.EMLSPBBridge

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 11
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.EMLSPBBridge
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 12] -/
def spb_bridge (x y : ℝ) : ℝ := (x + y) / (1 - x * y)


/-- [Section: # CatalogBuild.EML.EMLSPBBridge
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 12] -/
def spbH_bridge (x y : ℝ) : ℝ := (x + y) / (1 + x * y)


/-- [Section: # CatalogBuild.EML.EMLSPBBridge
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 12] -/
theorem eml_generates_exp (x : ℝ) : eml x 1 = exp x := by
  simp [eml, Real.log_one]


theorem eml_generates_neg_log (y : ℝ) : eml 0 y = 1 - log y := by
  simp [eml]


theorem eml_identity : eml 0 1 = 1 := by simp [eml, Real.log_one]


theorem spb_identity_bridge (x : ℝ) : spb_bridge x 0 = x := by simp [spb_bridge]


theorem spb_inverse_bridge (x : ℝ) : spb_bridge x (-x) = 0 := by simp [spb_bridge]


/-- exp is a homomorphism from (ℝ,+) to (ℝ₊,×). -/
theorem exp_hom (x y : ℝ) : exp (x + y) = exp x * exp y := Real.exp_add x y


/-- tanh is a homomorphism from (ℝ,+) to ((-1,1), spbH). -/
theorem tanh_hom (a b : ℝ) :
    tanh (a + b) = spbH_bridge (tanh a) (tanh b) := by
  rw [spbH_bridge, tanh_eq_sinh_div_cosh, sinh_add, cosh_add,
      tanh_eq_sinh_div_cosh, tanh_eq_sinh_div_cosh]
  field_simp


theorem spb_assoc_bridge (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    spb_bridge (spb_bridge x y) z = spb_bridge x (spb_bridge y z) := by
  by_cases h3 : 1 - ( x + y ) / ( 1 - x * y ) * z = 0 <;> by_cases h4 : 1 - ( y + z ) / ( 1 - y * z ) * x = 0 <;> simp +decide [ *, spb_bridge ] at *;
  · grind;
  · grind;
  · grind;
  · grind


theorem spbH_double (x : ℝ) : spbH_bridge x x = 2 * x / (1 + x ^ 2) := by
  unfold spbH_bridge; ring


end
