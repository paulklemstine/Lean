import Mathlib

/-! Entropy definitions used by the reversible-computation developments. -/

noncomputable section

open Finset BigOperators

/-- A finite real-valued probability distribution. -/
def IsDistribution {α : Type*} [Fintype α] (p : α → ℝ) : Prop :=
  (∀ x, 0 ≤ p x) ∧ ∑ x, p x = 1

/-- Shannon entropy, with the standard continuous convention at probability zero. -/
def shannonEntropy {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  -∑ x, p x * Real.log (p x)

end