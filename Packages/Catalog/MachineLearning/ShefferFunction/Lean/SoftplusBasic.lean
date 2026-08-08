import Mathlib

/-!
# Softplus and the logistic sigmoid: the analytic base of the Sheffer program

`ShefferAlgebra.lean` and `ExtendedTheorems.lean` are written against a module of basic
softplus facts that was not present in this repository, so neither of them compiled.  This
file supplies exactly that base layer:

* `softplus x = log (1 + eˣ)` with its value at `0`, strict monotonicity, continuity,
  differentiability (with the explicit derivative `eˣ/(1+eˣ)`, the logistic sigmoid),
  the reflection identity `σ(x) − σ(−x) = x`, subadditivity and `1`-Lipschitz continuity;
* `logisticSigmoid x = eˣ/(1+eˣ)` with the complement identity `S(x) + S(−x) = 1`.

The reflection identity is what puts the identity function into the Sheffer algebra, and
the Lipschitz bound is the "Lipschitz barrier" that keeps `x²` out of it.
-/

open Real

noncomputable section

/-- The softplus activation `σ(x) = log(1 + eˣ)`. -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-- The logistic sigmoid `S(x) = eˣ/(1 + eˣ)`, the derivative of softplus. -/
def logisticSigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)

theorem one_add_exp_pos (x : ℝ) : 0 < 1 + Real.exp x := by positivity

@[simp] theorem softplus_zero : softplus 0 = Real.log 2 := by
  norm_num [softplus]

theorem softplus_continuous : Continuous softplus :=
  (continuous_const.add Real.continuous_exp).log fun x => (one_add_exp_pos x).ne'

/-- The derivative of softplus is the logistic sigmoid. -/
theorem softplus_hasDerivAt (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x :=
  ((Real.hasDerivAt_exp x).const_add 1).log (one_add_exp_pos x).ne'

theorem softplus_differentiable : Differentiable ℝ softplus :=
  fun x => (softplus_hasDerivAt x).differentiableAt

theorem deriv_softplus (x : ℝ) : deriv softplus x = logisticSigmoid x :=
  (softplus_hasDerivAt x).deriv

theorem softplus_strictMono : StrictMono softplus := fun a b hab =>
  Real.log_lt_log (one_add_exp_pos a) (by simpa using Real.exp_lt_exp.mpr hab)

/-- The reflection identity `σ(x) − σ(−x) = x`. -/
theorem softplus_reflection (x : ℝ) : softplus x - softplus (-x) = x := by
  have h : 1 + Real.exp x = Real.exp x * (1 + Real.exp (-x)) := by
    rw [mul_add, mul_one, ← Real.exp_add, add_neg_cancel, Real.exp_zero]
    ring
  rw [softplus, softplus, h, Real.log_mul (Real.exp_ne_zero x) (one_add_exp_pos (-x)).ne',
    Real.log_exp]
  ring

theorem softplus_subadditive (x y : ℝ) : softplus (x + y) ≤ softplus x + softplus y := by
  rw [softplus, softplus, softplus, ← Real.log_mul (one_add_exp_pos x).ne' (one_add_exp_pos y).ne']
  refine Real.log_le_log (one_add_exp_pos _) ?_
  have hx := Real.exp_pos x
  have hy := Real.exp_pos y
  rw [Real.exp_add]
  nlinarith

/-- Softplus is `1`-Lipschitz, because its derivative is the sigmoid, which lies in `(0,1)`. -/
theorem softplus_lipschitz : LipschitzWith 1 softplus := by
  refine lipschitzWith_of_nnnorm_deriv_le softplus_differentiable fun x => ?_
  rw [← NNReal.coe_le_coe]
  simp only [coe_nnnorm, NNReal.coe_one, deriv_softplus, logisticSigmoid, Real.norm_eq_abs]
  rw [abs_of_pos (by positivity), div_le_one (one_add_exp_pos x)]
  linarith [Real.exp_pos x]

theorem softplus_abs_sub_le (x y : ℝ) : |softplus x - softplus y| ≤ |x - y| := by
  have h := softplus_lipschitz.dist_le_mul x y
  simpa [Real.dist_eq] using h

/-- The sigmoid complement identity `S(x) + S(−x) = 1`. -/
theorem sigmoid_complement (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
  have h3 : Real.exp (-x) = 1 / Real.exp x := by rw [Real.exp_neg]; ring
  have hx : (0 : ℝ) < Real.exp x := Real.exp_pos x
  simp only [logisticSigmoid, h3]
  field_simp
  ring

end