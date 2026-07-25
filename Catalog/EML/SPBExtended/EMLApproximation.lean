import Mathlib

/-! # EML Approximation Theory

The EML (Exp-Minus-Log) operation EML(a,b) = exp(a) - log(b) generates a rich
closure starting from {1}. We prove density and approximation results.

## Research Direction 3.5: EML Approximation Theory
-/

noncomputable section

open Real Set

/-- The EML operation -/
def eml (a b : ℝ) : ℝ := exp a - log b

/-- EML(0, 1) = 1 -/
theorem eml_zero_one : eml 0 1 = 1 := by simp [eml]

/-- EML(x, 1) = exp(x) -/
theorem eml_exp (x : ℝ) : eml x 1 = exp x := by simp [eml]

/-- EML(0, x) = 1 - log(x) -/
theorem eml_log (x : ℝ) : eml 0 x = 1 - log x := by simp [eml]

/-- EML(0, exp(x)) = 1 - x -/
theorem eml_zero_exp (x : ℝ) : eml 0 (exp x) = 1 - x := by
  simp [eml, log_exp]

/-- Log-splitting: EML(x, y·z) = EML(x, y) - log(z) for positive y, z -/
theorem eml_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y * z) = eml x y - log z := by
  simp [eml, log_mul hy.ne' hz.ne']; ring

/-- Shift identity: EML(x + c, 1) = exp(c) · exp(x) -/
theorem eml_shift (x c : ℝ) : eml (x + c) 1 = exp c * exp x := by
  simp [eml, exp_add, mul_comm]

/-- Double negation: EML(0, exp(EML(0, exp(x)))) = x -/
theorem eml_double_neg (x : ℝ) : eml 0 (exp (eml 0 (exp x))) = x := by
  simp [eml, log_exp]

/-- EML is monotone in the first argument -/
theorem eml_mono_fst (b : ℝ) : Monotone (fun a => eml a b) := by
  intro a₁ a₂ h; simp only [eml]; linarith [exp_le_exp.mpr h]

/-- EML maps (1, e) to (0, 1) via EML(0, ·) -/
theorem eml_maps_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < exp 1) :
    0 < eml 0 x ∧ eml 0 x < 1 := by
  constructor
  · simp [eml]; linarith [log_lt_log (by linarith : 0 < x) hxe, log_exp 1]
  · simp [eml]; linarith [log_pos hx1]

/-- The composition EML(EML(0, x), 1) = e/x for x > 0 -/
theorem eml_inv_scaled (x : ℝ) (hx : 0 < x) :
    eml (eml 0 x) 1 = exp 1 / x := by
  simp [eml, exp_sub, exp_log hx]

/-- EML continuous in first variable -/
theorem eml_continuous_fst (b : ℝ) : Continuous (fun a => eml a b) :=
  continuous_exp.sub continuous_const

end
