/-
# Softplus Convexity and Higher-Order Properties

This file proves convexity of softplus and properties of its derivatives,
establishing that softplus is a smooth convex function whose derivative
is the sigmoid function, and whose second derivative is always positive.
-/

import Mathlib

open Real

namespace ShefferFunction

/-- The softplus function: σ(x) = log(1 + exp(x)) -/
noncomputable def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-- The logistic sigmoid function. -/
noncomputable def logisticSigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)

theorem one_plus_exp_pos (x : ℝ) : (1 : ℝ) + Real.exp x > 0 := by positivity

/-- Logistic sigmoid is always positive. -/
theorem logisticSigmoid_pos (x : ℝ) : logisticSigmoid x > 0 := by
  unfold logisticSigmoid; positivity

/-- Logistic sigmoid is strictly less than 1. -/
theorem logisticSigmoid_lt_one (x : ℝ) : logisticSigmoid x < 1 := by
  unfold logisticSigmoid
  rw [div_lt_one (by positivity : (1 : ℝ) + exp x > 0)]
  linarith [exp_pos x]

/-- Logistic sigmoid is bounded: 0 ≤ S(x) ≤ 1. -/
theorem logisticSigmoid_nonneg (x : ℝ) : logisticSigmoid x ≥ 0 :=
  le_of_lt (logisticSigmoid_pos x)

theorem logisticSigmoid_le_one (x : ℝ) : logisticSigmoid x ≤ 1 :=
  le_of_lt (logisticSigmoid_lt_one x)

/-- The complementary identity: S(x) + S(-x) = 1. -/
theorem logisticSigmoid_complement (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
  unfold logisticSigmoid
  rw [exp_neg]
  field_simp
  ring

/-- logisticSigmoid(0) = 1/2. -/
theorem logisticSigmoid_zero : logisticSigmoid 0 = 1 / 2 := by
  unfold logisticSigmoid; simp; ring

/-- Sigmoid is the derivative of softplus. -/
theorem softplus_hasDerivAt (x : ℝ) :
    HasDerivAt softplus (logisticSigmoid x) x := by
  unfold softplus logisticSigmoid
  convert HasDerivAt.log
    (HasDerivAt.add (hasDerivAt_const x 1) (Real.hasDerivAt_exp x))
    (by positivity : (1 : ℝ) + exp x ≠ 0) using 1
  norm_num

/-- Softplus is strictly positive. -/
theorem softplus_pos (x : ℝ) : softplus x > 0 := by
  exact Real.log_pos (by linarith [Real.exp_pos x])

/-- Softplus is nonneg. -/
theorem softplus_nonneg (x : ℝ) : softplus x ≥ 0 := le_of_lt (softplus_pos x)

/-- Softplus is differentiable. -/
theorem softplus_differentiable : Differentiable ℝ softplus := by
  intro x; exact (softplus_hasDerivAt x).differentiableAt

/-
Softplus is convex.
-/
theorem softplus_convex : ConvexOn ℝ Set.univ softplus := by
  fapply convexOn_of_deriv2_nonneg;
  · exact convex_univ;
  · exact ContinuousOn.log ( continuousOn_const.add ( Real.continuous_exp.continuousOn ) ) fun x hx => by positivity;
  · exact Differentiable.differentiableOn ( by exact differentiable_id.exp.const_add 1 |> Differentiable.log <| by intro x; positivity );
  · refine' Differentiable.differentiableOn ( by rw [ show deriv softplus = logisticSigmoid from funext fun x => HasDerivAt.deriv ( softplus_hasDerivAt x ) ] ; exact by exact Differentiable.div ( Real.differentiable_exp ) ( by norm_num [ Real.differentiable_exp ] ) fun x => by positivity );
  · -- The second derivative of softplus is given by the derivative of the logistic sigmoid function.
    have h_second_deriv : ∀ x : ℝ, deriv^[2] softplus x = deriv (fun x => logisticSigmoid x) x := by
      exact fun x => by rw [ ← funext fun x => HasDerivAt.deriv ( ShefferFunction.softplus_hasDerivAt x ) ] ; rfl;
    unfold logisticSigmoid at *; norm_num [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos _ ) ) ] at *;
    exact fun x => h_second_deriv x ▸ div_nonneg ( by nlinarith [ Real.exp_pos x ] ) ( sq_nonneg _ )

/-- The product S(x)(1 - S(x)) is positive, reflecting strict convexity. -/
theorem logisticSigmoid_variance_pos (x : ℝ) :
    logisticSigmoid x * (1 - logisticSigmoid x) > 0 := by
  exact mul_pos (logisticSigmoid_pos x) (by linarith [logisticSigmoid_lt_one x])

/-- Softplus is strictly monotone. -/
theorem softplus_strictMono : StrictMono softplus := by
  intro x y hxy
  exact Real.log_lt_log (by positivity) (by linarith [Real.exp_lt_exp.2 hxy])

end ShefferFunction