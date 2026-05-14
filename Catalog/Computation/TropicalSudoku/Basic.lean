/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Sudoku: Min-Plus Constraint Satisfaction and Phase Transitions

## Overview

This file establishes a rigorous bridge between tropical algebra, finite
constraint satisfaction, and Sudoku solving. We formalize Sudoku as a
tropical (min-plus) feasibility problem, define a propagation operator on
candidate states, and prove the fundamental theorems connecting them.

## Main Results

### Theorem A: Zero Tropical Cost ↔ Valid Sudoku
* `TropicalSudoku.violationCost_eq_zero_iff` — the tropical violation cost
  is zero iff the assignment is a valid Sudoku solution

### Theorem B: Propagation Soundness and Termination
* `TropicalSudoku.propagateOnce_sound` — propagation preserves valid solutions
* `TropicalSudoku.propagateOnce_deflationary` — propagation only removes candidates
* `TropicalSudoku.candidateVolume_nonincreasing` — volume decreases monotonically
* `TropicalSudoku.propagation_terminates` — fixed point is reached

### Theorem C: Contradiction Detection
* `TropicalSudoku.contradiction_implies_unsat` — propagation contradiction ⟹ unsatisfiability

### Theorem D: Monotonicity in Clue Density
* `TropicalSudoku.applyGivens_monotone_in_givens` — more clues ⟹ fewer candidates

## References

* Tropical semiring theory (min-plus algebra)
* Constraint propagation / arc consistency in CSP
* Phase transition phenomena in random constraint satisfaction
-/
import Mathlib

namespace TropicalSudoku

/-! ## Core Types -/

/-- The digit type for a Sudoku of box size `n`. Standard Sudoku has `n = 3`,
    giving `n² = 9` digits (indexed `0, …, 8`). -/
abbrev Digit (n : ℕ) := Fin (n ^ 2)

/-- A cell on the Sudoku grid, identified by `(row, column)` where each
    coordinate ranges over `Fin (n²)`. -/
abbrev Cell (n : ℕ) := Fin (n ^ 2) × Fin (n ^ 2)

/-- A complete assignment of digits to all cells. -/
def Assignment (n : ℕ) := Cell n → Digit n

/-- A Sudoku instance (puzzle): a partial assignment of digit clues. -/
structure Instance (n : ℕ) where
  givens : Cell n → Option (Digit n)

/-! ## Structural Predicates -/

/-- Two cells are in the same box of the `n × n` box grid. -/
def sameBox (n : ℕ) (a b : Cell n) : Prop :=
  a.1.val / n = b.1.val / n ∧ a.2.val / n = b.2.val / n

instance sameBox_decidable (n : ℕ) (a b : Cell n) : Decidable (sameBox n a b) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-! ## Validity -/

/-- A valid assignment: no two distinct cells sharing a row, column, or box
    have the same digit. -/
def ValidAssignment (n : ℕ) (x : Assignment n) : Prop :=
  (∀ a b : Cell n, a ≠ b → a.1 = b.1 → x a ≠ x b) ∧
  (∀ a b : Cell n, a ≠ b → a.2 = b.2 → x a ≠ x b) ∧
  (∀ a b : Cell n, a ≠ b → sameBox n a b → x a ≠ x b)

/-- An assignment respects the given clues. -/
def RespectsGivens (n : ℕ) (I : Instance n) (x : Assignment n) : Prop :=
  ∀ c v, I.givens c = some v → x c = v

/-- A valid Sudoku solution: satisfies all constraints and respects clues. -/
def ValidSudoku (n : ℕ) (I : Instance n) (x : Assignment n) : Prop :=
  ValidAssignment n x ∧ RespectsGivens n I x

/-! ## Tropical Violation Cost -/

/-- Boolean penalty: `1` if the proposition holds, `0` otherwise. -/
def boolPenalty (P : Prop) [Decidable P] : ℕ := if P then 1 else 0

@[simp]
theorem boolPenalty_eq_zero_iff {P : Prop} [Decidable P] :
    boolPenalty P = 0 ↔ ¬P := by
  unfold boolPenalty; split <;> simp_all

/-- Row violation cost. -/
noncomputable def rowViolationCost (n : ℕ) (x : Assignment n) : ℕ :=
  ∑ a : Cell n, ∑ b : Cell n, boolPenalty (a ≠ b ∧ a.1 = b.1 ∧ x a = x b)

/-- Column violation cost. -/
noncomputable def colViolationCost (n : ℕ) (x : Assignment n) : ℕ :=
  ∑ a : Cell n, ∑ b : Cell n, boolPenalty (a ≠ b ∧ a.2 = b.2 ∧ x a = x b)

/-- Box violation cost. -/
noncomputable def boxViolationCost (n : ℕ) (x : Assignment n) : ℕ :=
  ∑ a : Cell n, ∑ b : Cell n, boolPenalty (a ≠ b ∧ sameBox n a b ∧ x a = x b)

/-- Given (clue) violation cost. -/
noncomputable def givenViolationCost (n : ℕ) (I : Instance n) (x : Assignment n) : ℕ :=
  ∑ c : Cell n, match I.givens c with
    | some v => boolPenalty (x c ≠ v)
    | none => 0

/-- Total tropical violation cost. -/
noncomputable def violationCost (n : ℕ) (I : Instance n) (x : Assignment n) : ℕ :=
  rowViolationCost n x + colViolationCost n x +
  boxViolationCost n x + givenViolationCost n I x

/-! ## Helper lemmas for Theorem A -/

private theorem sum_boolPenalty_eq_zero_iff {ι : Type*} [Fintype ι]
    {P : ι → Prop} [∀ i, Decidable (P i)] :
    (∑ i : ι, boolPenalty (P i)) = 0 ↔ ∀ i, ¬P i := by
  simp [Finset.sum_eq_zero_iff, boolPenalty_eq_zero_iff]

private theorem double_sum_boolPenalty_eq_zero_iff {ι₁ ι₂ : Type*}
    [Fintype ι₁] [Fintype ι₂]
    {P : ι₁ → ι₂ → Prop} [∀ i j, Decidable (P i j)] :
    (∑ i : ι₁, ∑ j : ι₂, boolPenalty (P i j)) = 0 ↔
    ∀ i j, ¬P i j := by
  simp [Finset.sum_eq_zero_iff, boolPenalty_eq_zero_iff]

/-! ## Theorem A: Zero Cost ↔ Valid Sudoku -/

theorem rowViolationCost_eq_zero (n : ℕ) (x : Assignment n) :
    rowViolationCost n x = 0 ↔
    ∀ a b : Cell n, a ≠ b → a.1 = b.1 → x a ≠ x b := by
  simp [rowViolationCost]

theorem colViolationCost_eq_zero (n : ℕ) (x : Assignment n) :
    colViolationCost n x = 0 ↔
    ∀ a b : Cell n, a ≠ b → a.2 = b.2 → x a ≠ x b := by
  unfold colViolationCost;
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ Finset.sum_eq_zero_iff, Nat.succ_ne_zero ]

theorem boxViolationCost_eq_zero (n : ℕ) (x : Assignment n) :
    boxViolationCost n x = 0 ↔
    ∀ a b : Cell n, a ≠ b → sameBox n a b → x a ≠ x b := by
  convert double_sum_boolPenalty_eq_zero_iff using 1;
  grind

theorem givenViolationCost_eq_zero (n : ℕ) (I : Instance n) (x : Assignment n) :
    givenViolationCost n I x = 0 ↔ RespectsGivens n I x := by
  constructor;
  · intro h;
    intro c v hv;
    contrapose! h;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.single_le_sum ( fun a _ => Nat.zero_le ( match I.givens a with | some v => if x a ≠ v then 1 else 0 | none => 0 ) ) ( Finset.mem_univ c ) ) ) ; aesop;
  · intro h;
    exact Finset.sum_eq_zero fun c _ => by cases h' : I.givens c <;> simp +decide [ h' ] ; specialize h c ; aesop;

/-
**Theorem A (Zero Cost ↔ Valid Sudoku).**
-/
theorem violationCost_eq_zero_iff (n : ℕ) (I : Instance n) (x : Assignment n) :
    violationCost n I x = 0 ↔ ValidSudoku n I x := by
  unfold violationCost;
  simp +decide [ ValidSudoku, ValidAssignment, RespectsGivens ];
  simp +decide [ rowViolationCost_eq_zero, colViolationCost_eq_zero, boxViolationCost_eq_zero, givenViolationCost_eq_zero ];
  tauto

/-! ## Candidate States and Propagation -/

/-- A candidate state assigns to each cell a set of possible digits. -/
def CandidateState (n : ℕ) := Cell n → Finset (Digit n)

/-- Full candidate state: every digit is a candidate for every cell. -/
def fullState (n : ℕ) : CandidateState n := fun _ => Finset.univ

/-- An assignment respects a candidate state. -/
def Respects (n : ℕ) (x : Assignment n) (S : CandidateState n) : Prop :=
  ∀ c, x c ∈ S c

/-- Candidate state ordering: pointwise subset. -/
def StateLe (n : ℕ) (S T : CandidateState n) : Prop :=
  ∀ c, S c ⊆ T c

/-- Total candidate volume. -/
noncomputable def candidateVolume (n : ℕ) (S : CandidateState n) : ℕ :=
  ∑ c : Cell n, (S c).card

/-- A candidate state is contradictory. -/
def Contradictory (n : ℕ) (S : CandidateState n) : Prop :=
  ∃ c, S c = ∅

/-- One-step constraint propagation (naked single elimination). -/
noncomputable def propagateOnce (n : ℕ) (I : Instance n) (S : CandidateState n) :
    CandidateState n :=
  fun c =>
    let givenRestr : Finset (Digit n) := match I.givens c with
      | some v => {v}
      | none => Finset.univ
    let singletonRow : Finset (Digit n) :=
      Finset.biUnion
        (Finset.univ.filter (fun c₂ : Fin (n ^ 2) =>
          c₂ ≠ c.2 ∧ (S (c.1, c₂)).card = 1))
        (fun c₂ => S (c.1, c₂))
    let singletonCol : Finset (Digit n) :=
      Finset.biUnion
        (Finset.univ.filter (fun r₂ : Fin (n ^ 2) =>
          r₂ ≠ c.1 ∧ (S (r₂, c.2)).card = 1))
        (fun r₂ => S (r₂, c.2))
    let singletonBox : Finset (Digit n) :=
      Finset.biUnion
        (Finset.univ.filter (fun c' : Cell n =>
          c' ≠ c ∧ sameBox n c c' ∧ (S c').card = 1))
        (fun c' => S c')
    (S c ∩ givenRestr) \ (singletonRow ∪ singletonCol ∪ singletonBox)

/-- Iterated propagation. -/
noncomputable def iterPropagate (n : ℕ) (I : Instance n) (S : CandidateState n)
    (k : ℕ) : CandidateState n :=
  Nat.iterate (propagateOnce n I) k S

/-! ## Theorem B1: Soundness -/

/-
**Theorem B1.** Propagation preserves valid solutions.
-/
theorem propagateOnce_sound (n : ℕ) (I : Instance n) (S : CandidateState n)
    (x : Assignment n) (hvalid : ValidSudoku n I x) (hresp : Respects n x S) :
    Respects n x (propagateOnce n I S) := by
  intro c; simp [propagateOnce];
  refine' ⟨ ⟨ hresp c, _ ⟩, _, _, _ ⟩;
  · cases h : I.givens c <;> simp_all +decide [ ValidSudoku ];
    exact hvalid.2 _ _ h;
  · intro c₂ hc₂ hc₂' hx₂;
    have := hvalid.1.1 ( c.1, c₂ ) ( c.1, c.2 ) ; simp_all +decide [ Finset.card_eq_one ];
    exact this ( by aesop ) ( by have := hresp ( c.1, c₂ ) ; aesop );
  · intro r hr₁ hr₂ hr₃; have := Finset.card_eq_one.mp hr₂; obtain ⟨ v, hv ⟩ := this; simp_all +decide [ Finset.eq_singleton_iff_unique_mem ] ;
    have := hvalid.1.2.1 ( r, c.2 ) c; simp_all +decide [ ValidAssignment ] ;
    exact this ( by aesop ) ( hv.2 _ ( hresp _ ) );
  · intro a b hab h₁ h₂; have := Finset.card_eq_one.mp h₂; obtain ⟨ y, hy ⟩ := this; specialize hvalid; have := hvalid.1; simp_all +decide [ ValidSudoku ] ;
    have := this.2.2 c ( a, b ) ; simp_all +decide [ ValidAssignment ] ;
    have := hresp ( a, b ) ; simp_all +decide [ Respects ] ;
    tauto

/-! ## Theorem B3: Deflationary Property and Termination -/

/-
Propagation is deflationary: output ⊆ input at each cell.
-/
theorem propagateOnce_deflationary (n : ℕ) (I : Instance n) (S : CandidateState n) :
    StateLe n (propagateOnce n I S) S := by
  unfold StateLe propagateOnce;
  grind

/-
Candidate volume is nonincreasing.
-/
theorem candidateVolume_nonincreasing (n : ℕ) (I : Instance n)
    (S : CandidateState n) :
    candidateVolume n (propagateOnce n I S) ≤ candidateVolume n S := by
  exact Finset.sum_le_sum fun c _ => Finset.card_le_card <| propagateOnce_deflationary n I S c

/-
Volume strictly decreases when state changes.
-/
theorem candidateVolume_strict_of_change (n : ℕ) (I : Instance n)
    (S : CandidateState n) (hchange : propagateOnce n I S ≠ S) :
    candidateVolume n (propagateOnce n I S) < candidateVolume n S := by
  apply Finset.sum_lt_sum;
  · exact fun c _ => Finset.card_le_card ( propagateOnce_deflationary n I S c );
  · -- By definition of propagateOnce, if propagateOnce n I S ≠ S, then there exists some cell c where propagateOnce n I S c ≠ S c.
    obtain ⟨c, hc⟩ : ∃ c, propagateOnce n I S c ≠ S c := by
      exact Function.ne_iff.mp hchange;
    exact ⟨ c, Finset.mem_univ _, Finset.card_lt_card <| lt_of_le_of_ne ( propagateOnce_deflationary n I S c ) hc ⟩

/-
**Theorem B3.** Iterated propagation reaches a fixed point.
-/
theorem propagation_terminates (n : ℕ) (I : Instance n) (S : CandidateState n) :
    ∃ k, propagateOnce n I (iterPropagate n I S k) = iterPropagate n I S k := by
  by_contra h;
  -- Applying the definition of `iterPropagate` and the assumption `h`, we get an infinite strictly decreasing sequence of candidate volumes.
  have h_seq : StrictAnti (fun k => candidateVolume n (iterPropagate n I S k)) := by
    refine' strictAnti_nat_of_succ_lt _;
    intro k;
    convert candidateVolume_strict_of_change n I ( iterPropagate n I S k ) _;
    · exact Function.iterate_succ_apply' _ _ _;
    · grind;
  exact absurd ( Set.infinite_range_of_injective h_seq.injective ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ _, Set.forall_mem_range.mpr fun k => h_seq.antitone k.zero_le ⟩ )

/-! ## Theorem C: Contradiction Detection -/

/-
Soundness extends to iterated propagation.
-/
theorem iterPropagate_sound (n : ℕ) (I : Instance n) (S : CandidateState n)
    (x : Assignment n) (hvalid : ValidSudoku n I x) (hresp : Respects n x S)
    (k : ℕ) :
    Respects n x (iterPropagate n I S k) := by
  induction' k with k ih;
  · exact hresp;
  · convert propagateOnce_sound n I ( iterPropagate n I S k ) x hvalid ih using 1;
    exact Function.iterate_succ_apply' _ _ _

/-
Every valid solution respects the full state.
-/
theorem valid_respects_fullState (n : ℕ) (_I : Instance n) (x : Assignment n) :
    Respects n x (fullState n) := by
  exact fun c => Finset.mem_univ _

/-
**Theorem C.** Contradiction at any step ⟹ unsatisfiability.
-/
theorem contradiction_implies_unsat (n : ℕ) (I : Instance n) (k : ℕ)
    (hcontra : Contradictory n (iterPropagate n I (fullState n) k)) :
    ¬∃ x, ValidSudoku n I x := by
  exact fun h => by obtain ⟨ x, hx ⟩ := h; exact absurd ( iterPropagate_sound n I _ x hx ( valid_respects_fullState n I x ) k hcontra.choose ) ( by simp +decide [ hcontra.choose_spec ] ) ;

/-! ## Theorem D: Monotonicity in Clue Density -/

/-- Instance `J` extends `I`. -/
def InstanceExtends (n : ℕ) (I J : Instance n) : Prop :=
  ∀ c v, I.givens c = some v → J.givens c = some v

/-- Simple given-constraint propagation. -/
noncomputable def applyGivens (n : ℕ) (I : Instance n)
    (S : CandidateState n) : CandidateState n :=
  fun c => match I.givens c with
    | some v => S c ∩ {v}
    | none => S c

/-
Given-only propagation preserves solutions.
-/
theorem applyGivens_sound (n : ℕ) (I : Instance n) (S : CandidateState n)
    (x : Assignment n) (hvalid : ValidSudoku n I x) (hresp : Respects n x S) :
    Respects n x (applyGivens n I S) := by
  intro c;
  unfold applyGivens;
  cases h : I.givens c <;> simp_all +decide [ RespectsGivens ];
  · exact hresp c;
  · exact ⟨ hresp c, hvalid.2 c _ h ⟩

/-
Given-only propagation is deflationary.
-/
theorem applyGivens_deflationary (n : ℕ) (I : Instance n) (S : CandidateState n) :
    StateLe n (applyGivens n I S) S := by
  unfold StateLe applyGivens; aesop;

/-
**Theorem D.** More clues ⟹ fewer candidates after given propagation.
-/
theorem applyGivens_monotone_in_givens (n : ℕ) (I J : Instance n)
    (S : CandidateState n) (hext : InstanceExtends n I J) :
    StateLe n (applyGivens n J S) (applyGivens n I S) := by
  -- For each cell c, we need applyGivens J S c ⊆ applyGivens I S c. Split on I.givens c:
  intro c
  by_cases h : I.givens c = none;
  · -- Since I.givens c = none, applyGivens I S c = S c.
    simp [applyGivens, h];
    cases J.givens c <;> simp +decide [ * ];
  · cases h' : I.givens c <;> cases h'' : J.givens c <;> simp_all +decide [ InstanceExtends ];
    unfold applyGivens; aesop;

end TropicalSudoku