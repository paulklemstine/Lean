/-! # CatalogBuild.Bridges.EMLTropicalBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 7
-/

import Mathlib

/-- log(exp(a) + exp(a)) = a + log 2
When both inputs to LogSumExp are equal, the result is
the value plus the constant log 2. The gap between max(a,a) = a
and this LSE value is exactly log 2. -/
theorem logsumexp_same (a : ℝ) :
    Real.log (Real.exp a + Real.exp a) = a + Real.log 2 := by
  have h2x : Real.exp a + Real.exp a = 2 * Real.exp a := by ring
  rw [h2x]
  have h1 : (2 : ℝ) ≠ 0 := two_ne_zero
  have h2 : Real.exp a ≠ 0 := ne_of_gt (Real.exp_pos a)
  rw [Real.log_mul h1 h2, Real.log_exp]
  ring


/-- EML(0, 1) = 1: "true" maps to 1 under EML -/
theorem eml_true : (1 : ℝ) - Real.log 1 = 1 := by
  simp only [Real.log_one, sub_zero]


/-- EML(0, e) = 0: "false" maps to 0 under EML -/
theorem eml_false : Real.exp 0 - Real.log (Real.exp 1) = 0 := by
  simp only [Real.exp_zero, Real.log_exp, sub_self]


/-- Truth + False = 1: EML truth values sum to 1 (probability) -/
theorem eml_truth_sum :
    (1 - Real.log 1) + (Real.exp 0 - Real.log (Real.exp 1)) = 1 := by
  simp [Real.log_one, Real.exp_zero, Real.log_exp]


/-- exp(a) · exp(b) = exp(a + b)
The exponential function is a semiring homomorphism from (ℝ, max, +)
to (ℝ, ×, +): max maps to addition, and addition maps to multiplication.
This is the fundamental algebraic bridge between tropical and classical. -/
theorem exp_mul_truth (a a' : ℝ) :
    Real.exp a * Real.exp a' = Real.exp (a + a') :=
  (Real.exp_add a a').symm


/-- log(2 · exp(a)) = log 2 + a: scaled LogSumExp identity -/
theorem log_scaled (a : ℝ) :
    Real.log (2 * Real.exp a) = Real.log 2 + a := by
  have h1 : (2 : ℝ) ≠ 0 := two_ne_zero
  have h2 : Real.exp a ≠ 0 := ne_of_gt (Real.exp_pos a)
  rw [Real.log_mul h1 h2, Real.log_exp]


/-- log(exp(0) + exp(0)) = log 2: base case for LogSumExp -/
theorem logsumexp_at_zero :
    Real.log (Real.exp 0 + Real.exp 0) = Real.log 2 := by
  have h2x : Real.exp 0 + Real.exp 0 = 2 * Real.exp 0 := by ring
  rw [h2x]
  have h1 : (2 : ℝ) ≠ 0 := two_ne_zero
  have h2 : Real.exp (0 : ℝ) ≠ 0 := ne_of_gt (Real.exp_pos 0)
  rw [Real.log_mul h1 h2, Real.log_exp]
  ring

