/-
# Monotonicity of Tropical Cost Under Adding Clues

Adding clues can only increase (or maintain) the tropical cost of any
assignment, because every new clue is a new potential violation.
-/
import Computation.TropicalSudoku.Cost

open Finset

/-- Adding clues increases the clue penalty for any fixed assignment. -/
theorem cluePenalty_mono
    {clues₁ clues₂ : Finset Clue}
    (hsub : clues₁ ⊆ clues₂)
    (A : SudokuAssignment) :
    cluePenalty clues₁ A ≤ cluePenalty clues₂ A := by
  unfold cluePenalty
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  exact hsub

/-- **Theorem B (pointwise)**: Adding clues can only increase the tropical cost. -/
theorem tropicalSudokuCost_mono_clues
    {clues₁ clues₂ : Finset Clue}
    (hsub : clues₁ ⊆ clues₂)
    (A : SudokuAssignment) :
    tropicalSudokuCost clues₁ A ≤ tropicalSudokuCost clues₂ A := by
  unfold tropicalSudokuCost
  exact Nat.add_le_add_right (cluePenalty_mono hsub A) _

/-! ## Global Monotonicity -/

/-- **Theorem B (global)**: If adding clues produces a zero-cost solution,
    then the original clue set also had a zero-cost solution.
    Equivalently: satisfiability is antitone in clue density. -/
theorem satisfiability_antitone
    {clues₁ clues₂ : Finset Clue}
    (hsub : clues₁ ⊆ clues₂) :
    (∃ A, SudokuValid clues₂ A) → (∃ A, SudokuValid clues₁ A) := by
  rintro ⟨A, hA⟩
  exact ⟨A, ⟨fun cl hcl => hA.1 cl (hsub hcl), hA.2⟩⟩

/-- If the minimum cost under clues₁ is at least k, then the minimum
    cost under clues₂ ⊇ clues₁ is also at least k. -/
theorem tropicalCost_lower_bound_mono
    {clues₁ clues₂ : Finset Clue}
    (hsub : clues₁ ⊆ clues₂)
    (k : ℕ)
    (hlb : ∀ A, k ≤ tropicalSudokuCost clues₁ A) :
    ∀ A, k ≤ tropicalSudokuCost clues₂ A := by
  intro A
  exact le_trans (hlb A) (tropicalSudokuCost_mono_clues hsub A)