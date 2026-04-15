/-
# The Analyticity Barrier: Every Sheffer Expression is Real Analytic

This file proves that every Sheffer expression defines a real analytic function,
upgrading the smoothness barrier from C∞ to Cω (real analytic).

This is strictly stronger than the C∞ barrier: there exist C∞ functions that
are not real analytic (e.g., e^{-1/x²}), and these are now excluded from
the Sheffer algebra.

## Main Results
- `softplus_analyticAt` : σ is analytic at every point
- `sheffer_expr_analyticAt` : Every Sheffer expression is analytic at every point
- `sheffer_algebra_analyticAt` : Every f ∈ ShefferAlg is analytic at every point

## The Three-Barrier System
With this result, we upgrade the structural characterization:
  ShefferAlg ⊆ Cω(ℝ) ∩ Lip(ℝ)
where Cω denotes real analytic functions. Since Cω ⊊ C∞, this is strictly
stronger than the previous ShefferAlg ⊆ C∞ ∩ Lip.
-/

import Mathlib
import ShefferAI.Lean.SoftplusBasic
import ShefferAI.Lean.ShefferAlgebra
import ShefferAI.Lean.OpenQuestions

open Real

noncomputable section

/-- Softplus is analytic at every point. -/
theorem softplus_analyticAt (x : ℝ) : AnalyticAt ℝ softplus x := by
  unfold softplus
  exact (analyticAt_const.add analyticAt_rexp).log (one_plus_exp_pos x)

/-- Helper: an affine map is analytic. -/
private def affineMap (a b : ℝ) : ℝ → ℝ := fun x => a * x + b

private theorem affineMap_analyticAt (a b x : ℝ) : AnalyticAt ℝ (affineMap a b) x := by
  unfold affineMap
  exact (analyticAt_const.mul analyticAt_id).add analyticAt_const

/-- Every Sheffer expression defines a function that is analytic at every point.
    This is the **Analyticity Barrier**: functions that are C∞ but not analytic
    (like e^{-1/x²}) are excluded from the Sheffer algebra. -/
theorem sheffer_expr_analyticAt (e : ShefferExpr) (x : ℝ) :
    AnalyticAt ℝ e.eval x := by
  induction e generalizing x with
  | base => exact softplus_analyticAt x
  | affine_pre a b e ih =>
    show AnalyticAt ℝ (e.eval ∘ affineMap a b) x
    exact (ih (affineMap a b x)).comp (affineMap_analyticAt a b x)
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ =>
    show AnalyticAt ℝ (fun x => α * e₁.eval x + β * e₂.eval x + γ) x
    exact ((analyticAt_const.mul (ih₁ x)).add (analyticAt_const.mul (ih₂ x))).add analyticAt_const
  | comp e₁ e₂ ih₁ ih₂ =>
    exact (ih₁ (e₂.eval x)).comp (ih₂ x)

/-- Corollary: every function in the Sheffer algebra is analytic at every point. -/
theorem sheffer_algebra_analyticAt {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (x : ℝ) :
    AnalyticAt ℝ f x := by
  obtain ⟨e, he⟩ := hf
  rw [he]
  exact sheffer_expr_analyticAt e x

/-- The upgraded Three-Barrier Characterization:
    ShefferAlg ⊆ Cω(ℝ) ∩ Lip(ℝ)
    Every Sheffer algebra function is both real analytic and Lipschitz. -/
theorem sheffer_algebra_analytic_and_lipschitz {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    (∀ x, AnalyticAt ℝ f x) ∧ (∃ C : ℝ, C ≥ 0 ∧ ∀ x y : ℝ, |f x - f y| ≤ C * |x - y|) := by
  exact ⟨sheffer_algebra_analyticAt hf, (sheffer_algebra_subset_smooth_lip hf).2⟩

/-- A function that is C∞ but not analytic at some point cannot be in ShefferAlg. -/
theorem not_sheffer_of_not_analyticAt {f : ℝ → ℝ} {x : ℝ}
    (h : ¬AnalyticAt ℝ f x) : f ∉ ShefferAlgebra := by
  intro hf
  exact h (sheffer_algebra_analyticAt hf x)

end
