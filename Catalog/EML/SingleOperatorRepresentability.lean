import EML.SingleOperatorClosure

/-!
# EML Single Operator Universality: Representability of Elementary Functions

We prove that standard elementary functions are EML-representable:
polynomials, rational functions, exp, log, hyperbolic functions,
and real powers via the `exp ∘ log` encoding.

## Main results

- `polynomial_EMLRepresentable`: Every polynomial is EML-representable
- `sinh_EMLRepresentable`: `sinh` is EML-representable
- `cosh_EMLRepresentable`: `cosh` is EML-representable
- `rpow_EMLRepresentable`: `x ↦ exp(q * log x)` for rational `q`
- `rational_function_EMLRepresentable`: Ratios of polynomials are representable
-/

noncomputable section
open Real Polynomial Set

/-! ## §1. Monomial and Polynomial Representability -/

/-- Any monomial `x ↦ x^k` is EML-representable as a unary function. -/
theorem monomial_EMLRepresentable (k : ℕ) :
    EMLRepresentable (fun x : Fin 1 → ℝ => (x 0) ^ k) :=
  (EMLRepresentable.var 0).pow k

/-- Every real polynomial is EML-representable as a unary function.
    This is proved by structural induction: constants and monomials are
    representable, and the class is closed under addition and scalar
    multiplication. -/
theorem polynomial_EMLRepresentable (p : Polynomial ℝ) :
    EMLRepresentable (fun x : Fin 1 → ℝ => p.eval (x 0)) := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq =>
    have : (fun x : Fin 1 → ℝ => (p + q).eval (x 0)) =
           (fun x => p.eval (x 0) + q.eval (x 0)) := by
      ext x; simp [Polynomial.eval_add]
    rw [this]; exact hp.add hq
  | monomial n c =>
    have : (fun x : Fin 1 → ℝ => (Polynomial.monomial n c).eval (x 0)) =
           (fun x => c * (x 0) ^ n) := by
      ext x; simp [Polynomial.eval_monomial]
    rw [this]; exact (EMLRepresentable.const c).mul (monomial_EMLRepresentable n)

/-! ## §2. Hyperbolic Function Representability

We prove that `sinh` and `cosh` are EML-representable using their
definitions as combinations of exponentials:
- `sinh(x) = (exp(x) - exp(-x)) / 2`
- `cosh(x) = (exp(x) + exp(-x)) / 2`
-/

/-- Hyperbolic sine is EML-representable:
    `sinh(x) = (exp(x) - exp(-x)) / 2`. -/
theorem sinh_EMLRepresentable :
    EMLRepresentable (fun x : Fin 1 → ℝ => Real.sinh (x 0)) := by
  have key : (fun x : Fin 1 → ℝ => Real.sinh (x 0)) =
             (fun x => (Real.exp (x 0) - Real.exp (-(x 0))) / 2) := by
    ext x; simp [Real.sinh_eq]
  rw [key]
  have h_var : EMLRepresentable (fun x : Fin 1 → ℝ => x 0) := EMLRepresentable.var 0
  have h_neg_var : EMLRepresentable (fun x : Fin 1 → ℝ => -(x 0)) := h_var.neg
  have h_exp : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (x 0)) := h_var.exp_comp
  have h_exp_neg : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (-(x 0))) := h_neg_var.exp_comp
  have h_diff : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (x 0) - Real.exp (-(x 0))) :=
    h_exp.sub h_exp_neg
  have h_two_inv : EMLRepresentable (fun _ : Fin 1 → ℝ => (2 : ℝ)⁻¹) :=
    (EMLRepresentable.const 2).inv
  have : (fun x : Fin 1 → ℝ => (Real.exp (x 0) - Real.exp (-(x 0))) / 2) =
         (fun x => (Real.exp (x 0) - Real.exp (-(x 0))) * (2 : ℝ)⁻¹) := by
    ext; ring
  rw [this]
  exact h_diff.mul h_two_inv

/-- Hyperbolic cosine is EML-representable:
    `cosh(x) = (exp(x) + exp(-x)) / 2`. -/
theorem cosh_EMLRepresentable :
    EMLRepresentable (fun x : Fin 1 → ℝ => Real.cosh (x 0)) := by
  have key : (fun x : Fin 1 → ℝ => Real.cosh (x 0)) =
             (fun x => (Real.exp (x 0) + Real.exp (-(x 0))) / 2) := by
    ext x; simp [Real.cosh_eq]
  rw [key]
  have h_var : EMLRepresentable (fun x : Fin 1 → ℝ => x 0) := EMLRepresentable.var 0
  have h_neg_var : EMLRepresentable (fun x : Fin 1 → ℝ => -(x 0)) := h_var.neg
  have h_exp : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (x 0)) := h_var.exp_comp
  have h_exp_neg : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (-(x 0))) := h_neg_var.exp_comp
  have h_sum : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (x 0) + Real.exp (-(x 0))) :=
    h_exp.add h_exp_neg
  have h_two_inv : EMLRepresentable (fun _ : Fin 1 → ℝ => (2 : ℝ)⁻¹) :=
    (EMLRepresentable.const 2).inv
  have : (fun x : Fin 1 → ℝ => (Real.exp (x 0) + Real.exp (-(x 0))) / 2) =
         (fun x => (Real.exp (x 0) + Real.exp (-(x 0))) * (2 : ℝ)⁻¹) := by
    ext; ring
  rw [this]
  exact h_sum.mul h_two_inv

/-! ## §3. Real Powers via Exp-Log Encoding -/

/-- Real powers `x ↦ exp(q * log(x))` are EML-representable for any rational `q`.
    On the positive domain, this computes `x^q`. This is the canonical
    encoding of fractional powers through the exp-log bridge. -/
theorem rpow_EMLRepresentable (q : ℚ) :
    EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp ((q : ℝ) * Real.log (x 0))) := by
  have h_var : EMLRepresentable (fun x : Fin 1 → ℝ => x 0) := EMLRepresentable.var 0
  have h_log : EMLRepresentable (fun x : Fin 1 → ℝ => Real.log (x 0)) := h_var.log_comp
  have h_scaled : EMLRepresentable (fun x : Fin 1 → ℝ => (q : ℝ) * Real.log (x 0)) :=
    (EMLRepresentable.const (q : ℝ)).mul h_log
  exact h_scaled.exp_comp

/-! ## §4. Rational Function Representability -/

/-- A ratio of two polynomials is EML-representable. -/
theorem rational_function_EMLRepresentable (p q : Polynomial ℝ) :
    EMLRepresentable (fun x : Fin 1 → ℝ => p.eval (x 0) / q.eval (x 0)) :=
  (polynomial_EMLRepresentable p).div (polynomial_EMLRepresentable q)

/-! ## §5. Composed Exponentials and Iterated Functions -/

/-- Double exponential `x ↦ exp(exp(x))` is EML-representable. -/
theorem exp_exp_EMLRepresentable :
    EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (Real.exp (x 0))) :=
  (EMLRepresentable.var 0).exp_comp.exp_comp

/-- Iterated logarithm `x ↦ log(log(x))` is EML-representable (with Mathlib's total `log`). -/
theorem log_log_EMLRepresentable :
    EMLRepresentable (fun x : Fin 1 → ℝ => Real.log (Real.log (x 0))) :=
  (EMLRepresentable.var 0).log_comp.log_comp

/-- The Gaussian `x ↦ exp(-x²)` is EML-representable. -/
theorem gaussian_EMLRepresentable :
    EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (-(x 0) ^ 2)) := by
  have h_var : EMLRepresentable (fun x : Fin 1 → ℝ => x 0) := EMLRepresentable.var 0
  have h_sq : EMLRepresentable (fun x : Fin 1 → ℝ => (x 0) ^ 2) := h_var.pow 2
  have h_neg_sq : EMLRepresentable (fun x : Fin 1 → ℝ => -((x 0) ^ 2)) := h_sq.neg
  exact h_neg_sq.exp_comp

/-- The logistic sigmoid `x ↦ 1 / (1 + exp(-x))` is EML-representable. -/
theorem sigmoid_EMLRepresentable :
    EMLRepresentable (fun x : Fin 1 → ℝ => 1 / (1 + Real.exp (-(x 0)))) := by
  have h_var : EMLRepresentable (fun x : Fin 1 → ℝ => x 0) := EMLRepresentable.var 0
  have h_one : EMLRepresentable (fun _ : Fin 1 → ℝ => (1 : ℝ)) := EMLRepresentable.const 1
  have h_neg : EMLRepresentable (fun x : Fin 1 → ℝ => -(x 0)) := h_var.neg
  have h_exp_neg : EMLRepresentable (fun x : Fin 1 → ℝ => Real.exp (-(x 0))) := h_neg.exp_comp
  have h_denom : EMLRepresentable (fun x : Fin 1 → ℝ => 1 + Real.exp (-(x 0))) :=
    h_one.add h_exp_neg
  exact h_one.div h_denom

end