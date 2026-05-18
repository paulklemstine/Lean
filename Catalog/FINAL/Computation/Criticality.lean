/-
# Tropical Boundary and Criticality

We define residual ambiguity after propagation and prove structural
theorems about the tropical feasibility boundary.
-/
import Computation.TropicalSudoku.Propagation
import Computation.TropicalSudoku.Monotonicity

open Finset

/-! ## Residual Ambiguity -/

/-- Residual ambiguity: total candidate mass after full propagation
    minus the baseline of 81 (one digit per cell).
    We use n=81 iterations (a safe upper bound given grid size). -/
noncomputable def residualAmbiguity (clues : Finset Clue) : ℕ :=
  totalCandidateMass (Nat.iterate (propagateStep clues) 81 (initialCandidates clues)) - 81

/-
Every finite nonempty family of clue sets has a member
    that maximizes residual ambiguity.
-/
theorem exists_max_residualAmbiguity
    (F : Finset (Finset Clue))
    (hne : F.Nonempty) :
    ∃ clues ∈ F,
      ∀ clues' ∈ F, residualAmbiguity clues' ≤ residualAmbiguity clues := by
  exact Finset.exists_max_image _ _ hne

/-! ## Generic TropicalCSP Abstraction -/

/-- A generic tropical CSP over finite variable and value types.
    This abstraction captures the essential structure: a cost function
    that is zero exactly when the assignment is valid. -/
structure TropicalCSP (Var Val : Type) [Fintype Var] [Fintype Val]
    [DecidableEq Var] [DecidableEq Val] where
  /-- The cost function: number of violated constraints. -/
  cost : (Var → Val) → ℕ
  /-- The validity predicate. -/
  valid : (Var → Val) → Prop
  /-- Decidable validity. -/
  [decValid : DecidablePred valid]
  /-- **Exactness**: zero cost is equivalent to validity. -/
  exact_zero : ∀ a, cost a = 0 ↔ valid a

attribute [instance] TropicalCSP.decValid

/-- Sudoku is an instance of TropicalCSP. -/
noncomputable def sudokuTropicalCSP (clues : Finset Clue) :
    TropicalCSP Cell Digit where
  cost := fun A => tropicalSudokuCost clues A
  valid := fun A => SudokuValid clues A
  exact_zero := fun A => tropicalSudokuCost_eq_zero_iff clues A

/-- For any TropicalCSP, existence of a valid assignment is equivalent to
    existence of a zero-cost assignment. -/
theorem TropicalCSP.exists_valid_iff_zero_cost
    {Var Val : Type} [Fintype Var] [Fintype Val] [DecidableEq Var] [DecidableEq Val]
    (csp : TropicalCSP Var Val) :
    (∃ a, csp.valid a) ↔ (∃ a, csp.cost a = 0) := by
  constructor
  · rintro ⟨a, ha⟩; exact ⟨a, (csp.exact_zero a).mpr ha⟩
  · rintro ⟨a, ha⟩; exact ⟨a, (csp.exact_zero a).mp ha⟩