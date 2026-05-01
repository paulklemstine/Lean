/-! # CatalogBuild.Bridges.AlgebraEMLBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 7
-/

import Mathlib

noncomputable section

/-- [Section: # Algebra-EML Bridge: Functional Equations
The EML function EML(a,b) = exp(a) - log(b) connects exponential growth
and logarithmic compression.] -/
def EML (a b : ℝ) : ℝ := Real.exp a - Real.log b


theorem eml_one_eq_exp (a : ℝ) : EML a 1 = Real.exp a := by
  unfold EML; simp only [Real.log_one, sub_zero]


theorem eml_zero_eq_shift_log (b : ℝ) (hb : 0 < b) : EML 0 b = 1 - Real.log b := by
  unfold EML; simp only [Real.exp_zero]


theorem eml_add_exp_bridge (a a' : ℝ) :
    EML (a + a') 1 = EML a 1 * EML a' 1 := by
  unfold EML; simp only [Real.log_one, sub_zero, Real.exp_add]


theorem eml_nsmul_eq_pow (a : ℝ) (n : ℕ) :
    EML (n • a) 1 = (EML a 1) ^ n := by
  unfold EML; simp only [Real.log_one, sub_zero, Real.exp_nsmul]


theorem eml_fixed_point_b (a : ℝ) : EML a (Real.exp (Real.exp a - a)) = a := by
  unfold EML; rw [Real.log_exp]; ring


theorem eml_monotone_first (a a' : ℝ) (h : a ≤ a') : EML a 1 ≤ EML a' 1 := by
  unfold EML; simp only [Real.log_one, sub_zero]
  exact Real.exp_monotone h


end
