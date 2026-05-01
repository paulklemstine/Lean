import Mathlib

/-! # CatalogBuild.EML.V12.OperatorAlgebra

Auto-generated from theorem catalog database.
Domain: EML/V12
Declarations: 25
-/

noncomputable section

/-- eml(0, exp(−y)) = 1 + y, so EML generates affine translations. -/
theorem eml_generates_translation (y : ℝ) :
    eml 0 (Real.exp (-y)) = 1 + y := by
  simp [eml, Real.log_exp]

/-- Composing EML with itself via y=1: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem eml_double_composition (x : ℝ) :
    eml (eml x 1) 1 = Real.exp (Real.exp x) := by
  simp [eml, Real.log_one]

/-- EML separates exp and log: eml = exp ∘ π₁ − log ∘ π₂. -/
theorem eml_as_difference (x y : ℝ) :
    eml x y = (Real.exp ∘ Prod.fst) (x, y) - (Real.log ∘ Prod.snd) (x, y) := rfl

/-- Conjugation: exp(eml(x,y)) = exp(exp(x))/y for y > 0. -/
theorem exp_of_eml (x y : ℝ) (hy : 0 < y) :
    Real.exp (eml x y) = Real.exp (Real.exp x) / y := by
  unfold eml; rw [Real.exp_sub, Real.exp_log hy]

/-- Log of exp of eml = eml itself. -/
theorem log_exp_eml (x y : ℝ) :
    Real.log (Real.exp (eml x y)) = eml x y :=
  Real.log_exp (eml x y)

/-- Sum of two EML values. -/
theorem eml_sum_formula (x x' y y' : ℝ) :
    eml x y + eml x' y' = Real.exp x + Real.exp x' - Real.log y - Real.log y' := by
  unfold eml; ring

/-- Product expansion. -/
theorem eml_prod_expand (x x' y y' : ℝ) :
    eml x y * eml x' y' =
    Real.exp x * Real.exp x' - Real.exp x * Real.log y'
    - Real.log y * Real.exp x' + Real.log y * Real.log y' := by
  unfold eml; ring

/-- Sum at same x. -/
theorem eml_sum_same_x (x y z : ℝ) :
    eml x y + eml x z = 2 * Real.exp x - Real.log y - Real.log z := by
  unfold eml; ring

/-- Sum at same y. -/
theorem eml_sum_same_y (x x' y : ℝ) :
    eml x y + eml x' y = Real.exp x + Real.exp x' - 2 * Real.log y := by
  unfold eml; ring

/-- eml(x+y, exp(z)) = exp(x)·exp(y) − z. -/
theorem eml_add_exp (x y z : ℝ) :
    eml (x + y) (Real.exp z) = Real.exp x * Real.exp y - z := by
  simp [eml, Real.exp_add, Real.log_exp]

/-- eml(0, exp(1)) = 0, since exp(0) − log(exp(1)) = 1 − 1 = 0. -/
theorem eml_zero_exp1 : eml 0 (Real.exp 1) = 0 := by
  simp [eml, Real.log_exp]

/-- eml(x, exp(exp(x))) = 0 (the kernel equation). -/
theorem eml_kernel (x : ℝ) : eml x (Real.exp (Real.exp x)) = 0 := by
  simp [eml, Real.log_exp]

/-- [Section: ## Section 4: EML Kernel and Zeros] -/
theorem eml_eq_zero_iff (x y : ℝ) (hy : 0 < y) :
    eml x y = 0 ↔ y = Real.exp (Real.exp x) := by
      unfold eml;
      rw [ sub_eq_zero, eq_comm, ← Real.exp_log hy ];
      norm_num

/-- eml(eml(x,y), y) = exp(exp(x) − log(y)) − log(y). -/
theorem eml_feedback (x y : ℝ) :
    eml (eml x y) y = Real.exp (Real.exp x - Real.log y) - Real.log y := rfl

/-- Self-feedback at y=1: eml(eml(x,1),1) = exp(exp(x)). -/
theorem eml_self_feedback (x : ℝ) :
    eml (eml x 1) 1 = Real.exp (Real.exp x) := by
  simp [eml, Real.log_one]

/-- The "spiral" map S(x) = eml(x, exp(x)) = emlSelfPair(x). -/
theorem eml_spiral (x : ℝ) : eml x (Real.exp x) = emlSelfPair x := by
  simp [eml, emlSelfPair, Real.log_exp]

/-- S(S(x)) = σ(σ(x)). -/
theorem eml_double_spiral (x : ℝ) :
    eml (emlSelfPair x) (Real.exp (emlSelfPair x)) = emlSelfPair (emlSelfPair x) := by
  simp [eml, emlSelfPair, Real.log_exp]

/-- eml(−x, y) = exp(−x) − log(y). -/
theorem eml_neg_x (x y : ℝ) :
    eml (-x) y = Real.exp (-x) - Real.log y := rfl

/-- eml(−x, y) = 1/exp(x) − log(y). -/
theorem eml_neg_x_inv (x y : ℝ) :
    eml (-x) y = (Real.exp x)⁻¹ - Real.log y := by
  simp [eml, Real.exp_neg]

/-- σ(−x) = exp(−x) + x. -/
theorem emlSelfPair_neg (x : ℝ) :
    emlSelfPair (-x) = Real.exp (-x) + x := by
  unfold emlSelfPair; ring

/-- σ(x) + σ(−x) = exp(x) + exp(−x) = 2·cosh(x). -/
theorem emlSelfPair_sum_sym (x : ℝ) :
    emlSelfPair x + emlSelfPair (-x) = Real.exp x + Real.exp (-x) := by
  unfold emlSelfPair; ring

/-- σ(x) − σ(−x) = exp(x) − exp(−x) − 2x = 2·sinh(x) − 2x. -/
theorem emlSelfPair_diff_sym (x : ℝ) :
    emlSelfPair x - emlSelfPair (-x) = Real.exp x - Real.exp (-x) - 2 * x := by
  unfold emlSelfPair; ring

/-- Three-variable EML chain: eml(eml(x,y), z). -/
theorem eml_chain_3 (x y z : ℝ) :
    eml (eml x y) z = Real.exp (Real.exp x - Real.log y) - Real.log z := rfl

/-- Four-fold composition with y=1: generates tetration. -/
theorem eml_tetration_4 (x : ℝ) :
    eml (eml (eml (eml x 1) 1) 1) 1 =
    Real.exp (Real.exp (Real.exp (Real.exp x))) := by
  simp [eml, Real.log_one]

/-- eml average: (eml(x,y) + eml(y,x))/2 = (exp(x)+exp(y))/2 − (log(x)+log(y))/2. -/
theorem eml_symmetrized (x y : ℝ) :
    (eml x y + eml y x) / 2 =
    (Real.exp x + Real.exp y) / 2 - (Real.log x + Real.log y) / 2 := by
  unfold eml; ring

end
