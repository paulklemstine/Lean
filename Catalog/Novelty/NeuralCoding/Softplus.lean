import Mathlib

/-! # CatalogBuild.Shared.Softplus

Softplus `σ(x) = log (1 + eˣ)`, the smooth approximation to ReLU used as an EML
neuron.  This module is the canonical home of the softplus theory: the
auto-generated sibling files `Softplus_zero.lean`, `Softplus_mono.lean`, … each
contained a scrambled copy of the same declarations (in an order in which they
did not elaborate, and missing the positivity helper `one_plus_exp_pos`); they
now re-export this module instead.

Domain: Shared
-/

noncomputable section

/-- `1 + eˣ` is positive; the basic side condition for every `log` below. -/
theorem one_plus_exp_pos (x : ℝ) : (0 : ℝ) < 1 + Real.exp x := by
  have := Real.exp_pos x
  linarith

/-- ReLU is not directly an EML neuron, but can be approximated.
Softplus(x) = ln(1 + exp(x)) ≈ ReLU(x) is expressible via EML components. -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-- Softplus is always positive. -/
theorem softplus_pos (x : ℝ) : 0 < softplus x := by
  unfold softplus
  exact Real.log_pos (by linarith [Real.exp_pos x])

/-- Softplus at zero equals log 2 -/
theorem softplus_zero : softplus 0 = Real.log 2 := by
  unfold softplus
  norm_num

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

end