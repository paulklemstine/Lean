-- `Shared.NeuralCoding.LogisticSigmoid` already provides `softplus`, `one_plus_exp_pos`
-- and `logisticSigmoid`; importing `Shared.NeuralCoding.Softplus` as well would redefine
-- `softplus` and make this file fail to elaborate.
import Shared.NeuralCoding.LogisticSigmoid

/-! # CatalogBuild.Shared.Softplus theory

The softplus activation `σ(x) = log (1 + eˣ)` and its analytic properties:
the exponential identity `e^{σ(x)} = 1 + eˣ`, the reflection law
`σ(x) - x = σ(-x)`, the bound `σ(x) > x`, differentiability, strict monotonicity,
the derivative `σ' = logisticSigmoid`, convexity, and the value `σ(0) = log 2`.

This module collects the theorems that the auto-generated catalog files
`Softplus_mono`, `Softplus_deriv`, … each listed in an order in which they could
not be elaborated (uses before definitions); those files now re-export this one.
-/

noncomputable section

/-- e^σ(x) = 1 + eˣ -/
theorem softplus_exp_identity (x : ℝ) : Real.exp (softplus x) = 1 + Real.exp x := by
  unfold softplus
  rw [Real.exp_log (one_plus_exp_pos x)]

theorem softplus_reflection (x : ℝ) : softplus x - x = softplus (-x) := by
  unfold softplus
  rw [show (1 + Real.exp (-x)) = (1 + Real.exp x) / Real.exp x by
        rw [add_div, div_self <| ne_of_gt <| Real.exp_pos x, Real.exp_neg]; ring,
      Real.log_div (by positivity) <| by positivity, Real.log_exp]

/-- Softplus is greater than x for all x -/
theorem softplus_gt_id (x : ℝ) : softplus x > x := by
  unfold softplus
  have h1 : (1 : ℝ) + Real.exp x > Real.exp x := by linarith
  calc x = Real.log (Real.exp x) := (Real.log_exp x).symm
    _ < Real.log (1 + Real.exp x) := Real.log_lt_log (Real.exp_pos x) h1

/-- Softplus is differentiable -/
theorem softplus_differentiable : Differentiable ℝ softplus := by
  unfold softplus
  apply Differentiable.log
  · exact differentiable_const 1 |>.add Real.differentiable_exp
  · intro x; exact ne_of_gt (one_plus_exp_pos x)

/-- Softplus is strictly monotone increasing -/
theorem softplus_strictMono : StrictMono softplus := by
  intro a b hab
  unfold softplus
  apply Real.log_lt_log
  · exact one_plus_exp_pos a
  · linarith [Real.exp_lt_exp.mpr hab]

/-- Softplus is monotone increasing -/
theorem softplus_mono : Monotone softplus :=
  softplus_strictMono.monotone

/-- The derivative of softplus is the logistic sigmoid. -/
theorem softplus_deriv (x : ℝ) : deriv softplus x = logisticSigmoid x := by
  apply HasDerivAt.deriv
  convert HasDerivAt.log (HasDerivAt.add (hasDerivAt_const _ _) (Real.hasDerivAt_exp x)) _ using 1 <;>
    norm_num [logisticSigmoid]
  positivity

/-- Softplus is convex. -/
theorem softplus_convex : ConvexOn ℝ Set.univ softplus := by
  have h_hessian : ∀ x, deriv (deriv softplus) x > 0 := by
    rw [show deriv softplus = logisticSigmoid from funext fun x => softplus_deriv x]
    unfold logisticSigmoid
    exact fun x => by
      norm_num [Real.differentiableAt_exp, ne_of_gt (add_pos zero_lt_one (Real.exp_pos x))]
      ring_nf
      positivity
  apply_rules [convexOn_of_deriv2_nonneg, convex_univ]
  · exact ContinuousOn.log (continuousOn_const.add Real.continuousOn_exp) fun x _ => by positivity
  · exact fun x _ => DifferentiableAt.differentiableWithinAt softplus_differentiable.differentiableAt
  · exact fun x _ =>
      differentiableAt_of_deriv_ne_zero (ne_of_gt (h_hessian x)) |>.differentiableWithinAt
  · exact fun x _ => le_of_lt (h_hessian x)

/-- Softplus at zero equals log 2 -/
theorem softplus_zero : softplus 0 = Real.log 2 := by
  unfold softplus
  norm_num

end