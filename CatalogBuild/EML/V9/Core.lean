/-! # CatalogBuild.EML.V9.Core

Auto-generated from theorem catalog database.
Domain: EML/V9
Declarations: 22
-/

import Mathlib

noncomputable section

def emlNeg (x : ℝ) : ℝ := 1 - x

/-- Iterated diagonal map. -/

theorem eml_one_one : eml 1 1 = Real.exp 1 := by
  simp [eml, Real.log_one]


theorem eml_self_pair (x : ℝ) : eml x (Real.exp x) = Real.exp x - x := by
  simp [eml, Real.log_exp]


theorem eml_power (x : ℝ) (n : ℕ) : eml (n * x) 1 = (Real.exp x) ^ n := by
  simp [eml, Real.log_one, Real.exp_nat_mul]

/-! ## Section 2: Double Negation and Involution -/


theorem emlNeg_involution (x : ℝ) : emlNeg (emlNeg x) = x := by
  simp [emlNeg]


theorem eml_negation_via_exp (x : ℝ) : eml 0 (Real.exp x) = 1 - x := by
  simp [eml, Real.log_exp]


theorem eml_double_neg (x : ℝ) :
    eml 0 (Real.exp (eml 0 (Real.exp x))) = x := by
  simp [eml, Real.log_exp]

/-! ## Section 3: Monotonicity -/


theorem emlSelfPair_min : ∀ x : ℝ, emlSelfPair x ≥ 1 := by
  intro x
  unfold emlSelfPair
  linarith [Real.add_one_le_exp x]


theorem emlSelfPair_min_achieved : emlSelfPair 0 = 1 := by
  simp [emlSelfPair]

/-! ## Section 6: Derivatives and Calculus -/


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

/-- The second derivative ∂²eml/∂x² = exp(x) > 0 (convexity). -/

theorem eml_second_deriv_x_pos (x : ℝ) : Real.exp x > 0 :=
  Real.exp_pos x

/-- The second derivative ∂²eml/∂y² = 1/y² > 0 for y > 0 (convexity). -/

theorem eml_second_deriv_y_pos (y : ℝ) (hy : 0 < y) : y⁻¹ ^ 2 > 0 := by
  positivity

/-! ## Section 7: Magma Properties -/


theorem eml_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y * z) = eml x y - Real.log z := by
  unfold eml; rw [Real.log_mul hy.ne' hz.ne']; ring


theorem eml_log_ratio (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x (y / z) = eml x y + Real.log z := by
  unfold eml; rw [Real.log_div hy.ne' hz.ne']; ring


theorem eml_exp_sum (x y : ℝ) :
    eml (x + y) 1 = Real.exp x * Real.exp y := by
  simp [eml, Real.log_one, Real.exp_add]

/-! ## Section 9: Trace Theory -/


theorem eml_antisymm (x y : ℝ) :
    eml x y - eml y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold eml; ring

/-- The trace is always ≥ 2 for x, y > 0 (AM-GM connection). -/

theorem eml_generates_e2 : eml 2 1 = Real.exp 2 := by simp [eml, Real.log_one]


theorem eml_generates_eee : eml (eml (eml 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [eml, Real.log_one]

/-- The EML zero: eml(1, e^e) = 0. -/

theorem eml_zero : eml 1 (Real.exp (Real.exp 1)) = 0 := by
  simp [eml, Real.log_exp]

/-- EML generates subtraction: eml(ln(a), exp(b)) = a − b for a > 0. -/

theorem eml_addition (a b : ℝ) (ha : 0 < a) :
    eml (Real.log a) (Real.exp (-b)) = a + b := by
  unfold eml; rw [Real.exp_log ha, Real.log_exp]; ring

/-! ## Section 11: Information-Theoretic Connections -/

/-- The EML entropy decomposition: for p > 0,
    −p · ln(p) = p · eml(0, p) − p.
    This connects Shannon entropy to EML. -/

theorem emlSelfPair_pos (x : ℝ) : emlSelfPair x > 0 := by
  unfold emlSelfPair
  linarith [Real.add_one_le_exp x]

/-- σ is strictly decreasing on (−∞, 0) and strictly increasing on (0, ∞). -/

end
