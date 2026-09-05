/-
# Universal Approximation via Softplus

This file proves key lemmas supporting the universal approximation
property of softplus networks: the family {σ(ax + b)} separates points
and vanishes nowhere, which are the hypotheses needed for Stone-Weierstrass.
-/

import Mathlib
import Bridges.NeuralCoding.Softplus_strictMono

open Real

noncomputable section

/-- Softplus is strictly positive: `log (1 + eˣ) > log 1 = 0`. -/
theorem softplus_pos (x : ℝ) : 0 < softplus x := by
  have h : (1 : ℝ) < 1 + Real.exp x := by nlinarith [Real.exp_pos x]
  simpa [softplus] using Real.log_pos h

/-! ## Depth-1 Sheffer Expressions -/

/-- A depth-1 Sheffer expression: Σᵢ wᵢ σ(aᵢx + bᵢ) + c -/
structure Depth1ShefferExpr where
  n : ℕ
  weights : Fin n → ℝ
  slopes : Fin n → ℝ
  biases : Fin n → ℝ
  offset : ℝ

/-- Evaluate a depth-1 Sheffer expression -/
def Depth1ShefferExpr.eval (e : Depth1ShefferExpr) (x : ℝ) : ℝ :=
  (∑ i : Fin e.n, e.weights i * softplus (e.slopes i * x + e.biases i)) + e.offset

/-! ## Separation Properties -/

/-- Softplus separates points: if x₁ ≠ x₂, there exist a, b such that
    σ(ax₁ + b) ≠ σ(ax₂ + b) -/
theorem softplus_separates_points {x₁ x₂ : ℝ} (hne : x₁ ≠ x₂) :
    ∃ a b : ℝ, softplus (a * x₁ + b) ≠ softplus (a * x₂ + b) := by
  exact ⟨1, 0, by simp; exact fun h => hne (softplus_strictMono.injective h)⟩

/-- The softplus family does not vanish: for every x, there exist a, b with σ(ax + b) ≠ 0 -/
theorem softplus_nonvanishing (x : ℝ) : ∃ a b : ℝ, softplus (a * x + b) ≠ 0 := by
  exact ⟨1, 0, ne_of_gt (softplus_pos (1 * x + 0))⟩

/-- Softplus is continuous -/
theorem softplus_continuous : Continuous softplus :=
  softplus_differentiable.continuous

/-- Each member of the softplus family σ(ax + b) is continuous -/
theorem softplus_family_continuous (a b : ℝ) :
    Continuous (fun x => softplus (a * x + b)) :=
  softplus_continuous.comp ((continuous_const.mul continuous_id).add continuous_const)

end