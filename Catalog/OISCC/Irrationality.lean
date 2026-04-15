/-
# OISCC V9.1: Irrationality and Transcendence Results
-/

import Mathlib

noncomputable section

open Real

def EML_irr (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- e is irrational. -/
theorem e_irrational : Irrational (Real.exp 1) := by sorry

/-- EML(1, 1) = e is irrational (conditional on e being irrational). -/
theorem EML_one_one_irrational (h : Irrational (Real.exp 1)) :
    Irrational (EML_irr 1 1) := by
  convert h using 1; simp [EML_irr, Real.log_one]

/-- exp(n) is irrational for n ≥ 1 (Lindemann-Weierstrass). -/
theorem exp_nat_irrational (n : ℕ) (hn : 1 ≤ n) : Irrational (Real.exp n) := by sorry

/-- EML(0, 1) = 1 is rational. -/
theorem EML_zero_one_rational : ¬ Irrational (EML_irr 0 1) := by
  have : EML_irr 0 1 = 1 := by simp [EML_irr, Real.log_one]
  rw [this]; exact not_irrational_one

end
