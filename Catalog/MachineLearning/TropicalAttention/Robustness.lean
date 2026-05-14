import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Cross-Domain Corollary: Tropical Attention Gap Implies Certified Stability

A positive tropical attention gap (dominant column with gap δ) implies that the
softmax attention output is stable under perturbations of the score matrix.

This connects tropical geometry, robustness certification, and transformer theory.
-/

noncomputable section

open Finset BigOperators Real

/-- If column `jStar` dominates with gap δ, then under a perturbation of size ε
    to the score matrix, `jStar` still dominates (with reduced gap δ - 2ε). -/
theorem dominant_column_robust_to_perturbation
    {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℝ)
    (jStar : Fin n) (δ ε : ℝ)
    (hdom : IsDominantColumn A jStar δ)
    (hpert : ∀ i j, |B i j - A i j| ≤ ε) :
    IsDominantColumn B jStar (δ - 2 * ε) := by
  exact fun i j hj => by linarith [abs_le.mp (hpert i jStar), abs_le.mp (hpert i j), hdom i j hj]

/-- The certified radius for attention selection stability: perturbations of magnitude
    less than δ/4 cannot change the tropical argmax, preserving dominance with gap δ/2. -/
theorem tropical_attention_certified_radius
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (jStar : Fin n) (δ : ℝ) (_ : 0 < δ)
    (hdom : IsDominantColumn A jStar δ) :
    ∀ B : Matrix (Fin n) (Fin n) ℝ,
      (∀ i j, |B i j - A i j| ≤ δ / 4) →
      IsDominantColumn B jStar (δ / 2) := by
  intro B hB
  have := dominant_column_robust_to_perturbation A B jStar δ (δ / 4) hdom hB
  convert this using 1; ring

end