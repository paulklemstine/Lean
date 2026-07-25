/-
# Constraint Propagation as a Monotone Contracting Operator

We define a one-step propagation operator on candidate sets that:
1. Enforces clue constraints (if a cell has a clue, restrict to that digit).
2. Eliminates digits that conflict with forced cells in the same unit
   (naked singles elimination).

We prove:
- **Soundness**: propagation never removes digits used by a valid solution.
- **Antitonicity**: each step can only shrink candidate sets.
- **Bounded stabilization**: propagation reaches a fixed point in ≤ 729 steps.
-/
import Computation.TropicalSudoku.Cost

open Finset

/-! ## Initial Candidates -/

/-- The initial candidate set: every cell starts with all 9 digits,
    except cells with clues which are restricted to just their clue digit. -/
def initialCandidates (clues : Finset Clue) : Candidates := fun c =>
  let clueDigits := (clues.filter (fun cl => cl.1 = c)).image (fun cl => cl.2)
  if clueDigits.Nonempty then clueDigits else Finset.univ

/-! ## Neighbors -/

/-- The set of cells sharing a unit with a given cell (excluding itself). -/
def neighbors (c : Cell) : Finset Cell :=
  Finset.univ.filter fun c' => inSameUnit c c'

/-! ## Propagation Step -/

/-- One step of constraint propagation.
    For each cell, remove digits that are forced in a neighboring cell
    (i.e., the neighbor's candidate set is a singleton containing that digit).
    Also enforce clue constraints. -/
def propagateStep (clues : Finset Clue) (C : Candidates) : Candidates := fun c =>
  let clueRestriction :=
    let clueDigits := (clues.filter (fun cl => cl.1 = c)).image (fun cl => cl.2)
    if clueDigits.Nonempty then clueDigits else Finset.univ
  let forcedInNeighbors : Finset Digit :=
    (neighbors c).biUnion fun c' =>
      if (C c').card = 1 then C c' else ∅
  (C c ∩ clueRestriction) \ forcedInNeighbors

/-! ## Total Candidate Mass -/

/-- The total number of candidate entries across all cells. -/
def totalCandidateMass (C : Candidates) : ℕ :=
  ∑ c : Cell, (C c).card

/-! ## Antitonicity -/

/-- Each propagation step can only shrink candidate sets (pointwise). -/
theorem propagateStep_subset
    (clues : Finset Clue) (C : Candidates) (c : Cell) :
    propagateStep clues C c ⊆ C c := by
  intro d hd
  simp only [propagateStep, Finset.mem_sdiff, Finset.mem_inter] at hd
  exact hd.1.1

/-- Each propagation step cannot increase the candidate count at any cell. -/
theorem propagateStep_card_le
    (clues : Finset Clue) (C : Candidates) (c : Cell) :
    (propagateStep clues C c).card ≤ (C c).card :=
  Finset.card_le_card (propagateStep_subset clues C c)

/-- Each propagation step cannot increase the total candidate mass. -/
theorem propagateStep_mass_le
    (clues : Finset Clue) (C : Candidates) :
    totalCandidateMass (propagateStep clues C) ≤ totalCandidateMass C := by
  unfold totalCandidateMass
  apply Finset.sum_le_sum
  intro c _
  exact propagateStep_card_le clues C c

/-! ## Soundness -/

/-
**Theorem C (Soundness)**: Propagation never removes a digit used by a valid solution.
-/
theorem propagateStep_sound
    (clues : Finset Clue) (A : SudokuAssignment) (C : Candidates)
    (hA : SudokuValid clues A)
    (hmem : ∀ c, A c ∈ C c) :
    ∀ c, A c ∈ (propagateStep clues C) c := by
  intro c;
  refine' Finset.mem_sdiff.mpr ⟨ _, _ ⟩;
  · by_cases hc : ∃ cl ∈ clues, cl.1 = c <;> simp_all +decide;
    · obtain ⟨ x, hx ⟩ := hc; have := hA.1 ( c, x ) hx; aesop;
    · rw [ if_neg ] <;> aesop;
  · simp_all +decide [ neighbors ];
    intro a b hab split_ifs ; simp_all +decide [ Finset.card_eq_one ] ;
    split_ifs at split_ifs <;> simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
    have := hA.2 c ( a, b ) ; simp_all +decide [ inSameUnit ] ;
    grind

/-- Iterated soundness: valid solutions survive any number of propagation steps. -/
theorem iterateSound
    (clues : Finset Clue) (A : SudokuAssignment) (C : Candidates)
    (hA : SudokuValid clues A)
    (hmem : ∀ c, A c ∈ C c)
    (n : ℕ) :
    ∀ c, A c ∈ (Nat.iterate (propagateStep clues) n C) c := by
  induction n with
  | zero => exact hmem
  | succ n ih =>
    rw [Function.iterate_succ']
    exact propagateStep_sound clues A _ hA ih

/-! ## Bounded Stabilization -/

/-
**Theorem D**: Propagation stabilizes within 729 steps.
    Since each non-fixed step strictly reduces the total candidate mass
    (which is bounded by 81 × 9 = 729), a fixed point is reached
    in at most 729 iterations.
-/
theorem propagation_stabilizes_bounded
    (clues : Finset Clue) (C : Candidates) :
    ∃ n, n ≤ 729 ∧ Nat.iterate (propagateStep clues) n C =
                    Nat.iterate (propagateStep clues) (n + 1) C := by
  by_contra h_contra;
  -- By definition of `propagateStep`, the total candidate mass strictly decreases at each step.
  have h_decrease : ∀ n ≤ 729, totalCandidateMass (Nat.iterate (propagateStep clues) n C) > totalCandidateMass (Nat.iterate (propagateStep clues) (n + 1) C) := by
    intro n hn;
    refine' Finset.sum_lt_sum _ _;
    · exact fun i _ => by simpa only [ Function.iterate_succ_apply' ] using propagateStep_card_le clues _ _;
    · by_cases h_eq : ∀ c : Cell, (propagateStep clues)^[n + 1] C c = (propagateStep clues)^[n] C c;
      · exact False.elim <| h_contra ⟨ n, hn, funext fun c => h_eq c ▸ rfl ⟩;
      · simp_all +decide [ Function.iterate_succ_apply' ];
        obtain ⟨ a, b, h ⟩ := h_eq;
        exact ⟨ a, b, lt_of_le_of_ne ( Finset.card_le_card ( propagateStep_subset _ _ _ ) ) fun con => h <| Finset.eq_of_subset_of_card_le ( propagateStep_subset _ _ _ ) con.ge ⟩;
  -- By definition of `totalCandidateMass`, it is bounded above by 729.
  have h_bound : ∀ n ≤ 729, totalCandidateMass (Nat.iterate (propagateStep clues) n C) ≤ 729 - n := by
    intro n hn
    induction' n with n ih;
    · exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_le_univ _ ) ( by native_decide );
    · exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( h_decrease n ( Nat.le_of_succ_le hn ) ) ( ih ( Nat.le_of_succ_le hn ) ) );
  specialize h_bound 729 le_rfl;
  grind +splitIndPred