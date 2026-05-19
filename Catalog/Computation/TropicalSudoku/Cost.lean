/-
# Tropical Cost Function and Exactness Theorem

The tropical cost of a Sudoku assignment is the total number of
constraint violations: clue mismatches plus conflicting pairs in
rows, columns, and boxes. We prove that zero cost is equivalent
to Sudoku validity — the fundamental bridge between tropical
feasibility and combinatorial satisfaction.
-/
import Computation.TropicalSudoku.Defs

open Finset

/-! ## Penalty Definitions -/

/-- Number of clue violations: counts clues where the assignment disagrees. -/
noncomputable def cluePenalty (clues : Finset Clue) (A : SudokuAssignment) : ℕ :=
  (clues.filter fun cl => decide (A cl.1 ≠ cl.2)).card

/-- Number of unit conflicts: ordered pairs of cells in the same unit
    with identical digits. -/
noncomputable def unitViolationCount (A : SudokuAssignment) : ℕ :=
  (unitPairs.filter fun p => decide (A p.1 = A p.2)).card

/-- The tropical Sudoku cost: total constraint violations. -/
noncomputable def tropicalSudokuCost (clues : Finset Clue) (A : SudokuAssignment) : ℕ :=
  cluePenalty clues A + unitViolationCount A

/-! ## Exactness Theorem -/

theorem cluePenalty_eq_zero_iff (clues : Finset Clue) (A : SudokuAssignment) :
    cluePenalty clues A = 0 ↔ clueConsistent clues A := by
  constructor <;> intro h <;> simp_all +decide [ clueConsistent, cluePenalty ];
  · assumption;
  · assumption

theorem unitViolationCount_eq_zero_iff (A : SudokuAssignment) :
    unitViolationCount A = 0 ↔ unitConsistent A := by
  unfold unitViolationCount unitConsistent;
  simp +decide [ unitPairs ]

/-- **Tropical Exactness Theorem**: The tropical cost is zero if and only if
    the assignment is a valid Sudoku solution respecting all clues. -/
theorem tropicalSudokuCost_eq_zero_iff
    (clues : Finset Clue) (A : SudokuAssignment) :
    tropicalSudokuCost clues A = 0 ↔ SudokuValid clues A := by
  simp only [tropicalSudokuCost, Nat.add_eq_zero_iff, SudokuValid]
  exact ⟨fun ⟨h1, h2⟩ => ⟨(cluePenalty_eq_zero_iff clues A).mp h1,
                           (unitViolationCount_eq_zero_iff A).mp h2⟩,
         fun ⟨h1, h2⟩ => ⟨(cluePenalty_eq_zero_iff clues A).mpr h1,
                           (unitViolationCount_eq_zero_iff A).mpr h2⟩⟩

/-- **Theorem A**: Existence of a valid solution ↔ existence of a zero-cost assignment. -/
theorem exists_solution_iff_min_cost_zero
    (clues : Finset Clue) :
    (∃ A : SudokuAssignment, SudokuValid clues A) ↔
    (∃ A : SudokuAssignment, tropicalSudokuCost clues A = 0) := by
  constructor
  · rintro ⟨A, hA⟩
    exact ⟨A, (tropicalSudokuCost_eq_zero_iff clues A).mpr hA⟩
  · rintro ⟨A, hA⟩
    exact ⟨A, (tropicalSudokuCost_eq_zero_iff clues A).mp hA⟩