import Mathlib

/-!
# Elementary cellular automata over the Boolean state space

This file isolates two mathematically distinct facts behind the proposed geometric
interpretation.  First, ternary Boolean local rules form a 256-element space and
have algebraic normal forms of degree at most three.  Second, fixed-point counts
already contradict the proposed assignment of maximal fixed-point dimension to
Rule 110: on every nonempty finite array its all-one state is not fixed, whereas
Rule 204 fixes every state.
-/

namespace CellularAutomata

/-- A Boolean configuration on `n` sites. -/
abbrev State (n : ℕ) := Fin n → Bool

/-- A local elementary cellular-automaton rule. -/
abbrev LocalRule := Bool × Bool × Bool → Bool

/-- Synchronous update with abstract left and right boundary maps. -/
def update {n : ℕ} (rule : LocalRule) (left right : Fin n → Fin n)
    (state : State n) : State n :=
  fun i => rule (state (left i), state i, state (right i))

/-- The finite set of configurations fixed by an update map. -/
def fixedPoints {n : ℕ} (rule : LocalRule) (left right : Fin n → Fin n) : Finset (State n) :=
  Finset.univ.filter fun state => update rule left right state = state

/-- Rule 0 sends every neighborhood to zero. -/
def rule0 : LocalRule := fun _ => false

/-- Rule 204 copies the center cell. -/
def rule204 : LocalRule := fun x => x.2.1

/-- Wolfram's Rule 110, listed in increasing neighborhood order `000,...,111`. -/
def rule110 : LocalRule
  | (false, false, false) => false
  | (false, false, true) => true
  | (false, true, false) => true
  | (false, true, true) => true
  | (true, false, false) => false
  | (true, false, true) => true
  | (true, true, false) => true
  | (true, true, true) => false

/-- There are exactly 256 elementary local rules. -/
theorem card_localRule : Fintype.card LocalRule = 256 := by
  simp [LocalRule]

/-- Rule 0 has exactly one fixed configuration, independently of boundary conditions. -/
theorem rule0_fixedPoints_card {n : ℕ} (left right : Fin n → Fin n) :
    (fixedPoints rule0 left right).card = 1 := by
  rw [ Finset.card_eq_one ];
  unfold fixedPoints;
  unfold update rule0; aesop

/-- Rule 204 fixes every Boolean configuration. -/
theorem rule204_fixedPoints_eq_univ {n : ℕ} (left right : Fin n → Fin n) :
    fixedPoints rule204 left right = Finset.univ := by
  exact Finset.eq_univ_of_forall fun x => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, funext fun i => by unfold rule204; rfl ⟩

/-- Consequently Rule 204 has the maximum possible number, `2^n`, of fixed states. -/
theorem rule204_fixedPoints_card {n : ℕ} (left right : Fin n → Fin n) :
    (fixedPoints rule204 left right).card = 2 ^ n := by
  rw [ rule204_fixedPoints_eq_univ ];
  norm_num [ Finset.card_univ ]

/-- On a nonempty array, Rule 110 does not fix the all-one configuration. -/
theorem rule110_allTrue_not_fixed {n : ℕ} [NeZero n] (left right : Fin n → Fin n) :
    update rule110 left right (fun _ => true) ≠ (fun _ => true) := by
  simp +decide [ funext_iff, update ]

/-- Rule 110 has strictly fewer fixed states than the ambient Boolean state space. -/
theorem rule110_fixedPoints_card_lt {n : ℕ} [NeZero n] (left right : Fin n → Fin n) :
    (fixedPoints rule110 left right).card < 2 ^ n := by
  convert Finset.card_lt_card ( Finset.filter_ssubset.mpr _ ) using 1;
  · norm_num [ Finset.card_univ ];
  · exact ⟨ fun _ => true, Finset.mem_univ _, rule110_allTrue_not_fixed left right ⟩

/-- Rule 110 nevertheless always fixes the all-zero configuration. -/
theorem rule110_allFalse_fixed {n : ℕ} (left right : Fin n → Fin n) :
    update rule110 left right (fun _ => false) = (fun _ => false) := by
  exact funext fun x => by unfold update rule110; aesop;

/-- In a Rule 110 fixed state, a zero forces the cell on its right to be zero. -/
theorem rule110_fixed_zero_propagates {n : ℕ} (left right : Fin n → Fin n)
    (state : State n) (hfixed : update rule110 left right state = state)
    (i : Fin n) (hi : state i = false) : state (right i) = false := by
  have := congr_fun hfixed i; ( unfold update at this; ( unfold rule110 at this; aesop; ) )

/-- If the right-neighbor map has one forward orbit, Rule 110's only fixed state is zero. -/
theorem rule110_fixed_iff_allFalse_of_right_transitive {n : ℕ} [NeZero n]
    (left right : Fin n → Fin n)
    (htrans : ∀ i j, ∃ k : ℕ, right^[k] i = j)
    (state : State n) :
    update rule110 left right state = state ↔ state = (fun _ => false) := by
  constructor <;> intro h;
  · by_contra h_contra;
    obtain ⟨i, hi⟩ : ∃ i : Fin n, state i = false := by
      contrapose! h_contra;
      simp_all +decide [ funext_iff, update ];
    have h_ind : ∀ k : ℕ, state (right^[k] i) = false := by
      intro k; induction k <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      exact CellularAutomata.rule110_fixed_zero_propagates left right state h _ ‹_›;
    exact h_contra <| funext fun j => by obtain ⟨ k, rfl ⟩ := htrans i j; exact h_ind k;
  · exact h ▸ rule110_allFalse_fixed left right

/-- Under the same orbit condition, Rule 110 has exactly one fixed configuration. -/
theorem rule110_fixedPoints_card_of_right_transitive {n : ℕ} [NeZero n]
    (left right : Fin n → Fin n)
    (htrans : ∀ i j, ∃ k : ℕ, right^[k] i = j) :
    (fixedPoints rule110 left right).card = 1 := by
  rw [ Finset.card_eq_one ];
  use fun _ => false; ext; simp +decide [ CellularAutomata.fixedPoints, CellularAutomata.rule110_fixed_iff_allFalse_of_right_transitive _ _ htrans ] ;

/-- Rule 110's fixed-point set is nonempty but not maximal on every nonempty array. -/
theorem rule110_fixedPoints_card_bounds {n : ℕ} [NeZero n] (left right : Fin n → Fin n) :
    0 < (fixedPoints rule110 left right).card ∧
      (fixedPoints rule110 left right).card < 2 ^ n := by
  refine' ⟨ Finset.card_pos.mpr _, rule110_fixedPoints_card_lt left right ⟩;
  exact ⟨ fun _ => false, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rule110_allFalse_fixed left right ⟩ ⟩

/-- Boolean conjunction, used as multiplication in algebraic normal forms. -/
def band (x y : Bool) : Bool := x && y

/-- Boolean exclusive-or, used as addition in algebraic normal forms. -/
def bxor (x y : Bool) : Bool := x != y

/-- The eight coefficients of the algebraic normal form of a ternary Boolean rule. -/
def anfCoefficients (f : LocalRule) : Fin 8 → Bool
  | 0 => f (false, false, false)
  | 1 => bxor (f (true, false, false)) (f (false, false, false))
  | 2 => bxor (f (false, true, false)) (f (false, false, false))
  | 3 => bxor (bxor (bxor (f (true, true, false)) (f (true, false, false)))
      (f (false, true, false))) (f (false, false, false))
  | 4 => bxor (f (false, false, true)) (f (false, false, false))
  | 5 => bxor (bxor (bxor (f (true, false, true)) (f (true, false, false)))
      (f (false, false, true))) (f (false, false, false))
  | 6 => bxor (bxor (bxor (f (false, true, true)) (f (false, true, false)))
      (f (false, false, true))) (f (false, false, false))
  | 7 => bxor (bxor (bxor (bxor (bxor (bxor (bxor
      (f (true, true, true)) (f (true, true, false))) (f (true, false, true)))
      (f (true, false, false))) (f (false, true, true))) (f (false, true, false)))
      (f (false, false, true))) (f (false, false, false))

/-- Evaluation of a ternary Boolean algebraic normal form. -/
def evalANF (a : Fin 8 → Bool) (l c r : Bool) : Bool :=
  bxor (bxor (bxor (bxor (bxor (bxor (bxor (a 0)
    (band (a 1) l)) (band (a 2) c)) (band (a 3) (band l c)))
    (band (a 4) r)) (band (a 5) (band l r)))
    (band (a 6) (band c r))) (band (a 7) (band l (band c r)))

set_option maxHeartbeats 2000000 in
/-- Every elementary local rule is a polynomial over `GF(2)` of degree at most three. -/
theorem eval_anfCoefficients (f : LocalRule) (l c r : Bool) :
    evalANF (anfCoefficients f) l c r = f (l, c, r) := by
  cases h000 : f (false, false, false) <;>
    cases h001 : f (false, false, true) <;>
    cases h010 : f (false, true, false) <;>
    cases h011 : f (false, true, true) <;>
    cases h100 : f (true, false, false) <;>
    cases h101 : f (true, false, true) <;>
    cases h110 : f (true, true, false) <;>
    cases h111 : f (true, true, true) <;>
    cases l <;> cases c <;> cases r <;>
    simp [evalANF, anfCoefficients, band, bxor, *]

end CellularAutomata