/-
# SAT Non-Encodability via Tropical Sublevel Sets

This file defines CNF formulas, proves that certain CNF satisfying sets are
not downward closed, and combines this with the tropical monotonicity theorem
to show that no exact tropical sublevel encoding of CNF-SAT exists.

## Main Results

- `exists_cnf_not_downward_closed`: There exists a CNF formula whose
  satisfying assignment set (on Boolean vectors in ℕ) is not downward closed.
- `no_exact_tropical_sublevel_representation`: No uniform map from CNF
  formulas to tropical formulas can represent satisfiability as a sublevel
  condition on Boolean assignments.

These results establish a formal structural barrier: tropical min-plus
computation is order-theoretically rigid in a way incompatible with
encoding arbitrary Boolean satisfiability.
-/

import Tropical.TropicalFormula

open TropFormula

/-! ## CNF Formula Definitions -/

/-- A literal is a positive or negative occurrence of a variable. -/
inductive Lit (n : ℕ) where
  | pos : Fin n → Lit n
  | neg : Fin n → Lit n
  deriving Repr, DecidableEq

/-- A clause is a list of literals (representing their disjunction). -/
abbrev Clause (n : ℕ) := List (Lit n)

/-- A CNF formula is a list of clauses (representing their conjunction). -/
abbrev CNF (n : ℕ) := List (Clause n)

/-- Evaluate a literal on a Boolean assignment. -/
def Lit.eval (l : Lit n) (a : Fin n → Bool) : Bool :=
  match l with
  | .pos i => a i
  | .neg i => !(a i)

/-- A clause is satisfied if at least one literal evaluates to true. -/
def satisfiesClause (a : Fin n → Bool) (c : Clause n) : Prop :=
  ∃ l ∈ c, Lit.eval l a = true

/-- A CNF formula is satisfied if every clause is satisfied. -/
def satisfiesCNF (a : Fin n → Bool) (F : CNF n) : Prop :=
  ∀ c ∈ F, satisfiesClause a c

instance (a : Fin n → Bool) (c : Clause n) : Decidable (satisfiesClause a c) :=
  inferInstanceAs (Decidable (∃ l ∈ c, Lit.eval l a = true))

instance (a : Fin n → Bool) (F : CNF n) : Decidable (satisfiesCNF a F) :=
  inferInstanceAs (Decidable (∀ c ∈ F, satisfiesClause a c))

/-! ## ℕ-valued CNF evaluation (for interoperability with tropical formulas) -/

/-- Evaluate a literal on a ℕ-valued assignment (1 = true, 0 = false). -/
def Lit.evalNat (l : Lit n) (a : Fin n → ℕ) : Bool :=
  match l with
  | .pos i => a i != 0
  | .neg i => a i == 0

/-- A clause is satisfied (ℕ version) if at least one literal evaluates to true. -/
def satisfiesClauseNat (a : Fin n → ℕ) (c : Clause n) : Prop :=
  ∃ l ∈ c, Lit.evalNat l a = true

/-- A CNF formula is satisfied (ℕ version) if every clause is satisfied. -/
def satisfiesCNF_nat (a : Fin n → ℕ) (F : CNF n) : Prop :=
  ∀ c ∈ F, satisfiesClauseNat a c

/-! ## The CNF formula x₁ ∨ x₂ -/

/-- The CNF formula consisting of a single clause `x₁ ∨ x₂` (with 2 variables). -/
def cnf_or2 : CNF 2 := [[Lit.pos 0, Lit.pos 1]]

/-! ## Non-downward-closure of SAT -/

/-
The satisfying set of `x₁ ∨ x₂` is not downward closed on Boolean
    ℕ-vectors. Witness: `a = (1, 1)` satisfies it, `b = (0, 0) ≤ a`
    does not.
-/
theorem exists_cnf_not_downward_closed :
    ∃ (n : ℕ) (F : CNF n) (a b : Fin n → ℕ),
      IsBoolVec a ∧ IsBoolVec b ∧
      (∀ i, b i ≤ a i) ∧
      satisfiesCNF_nat a F ∧ ¬satisfiesCNF_nat b F := by
  -- Set n = 2, F = cnf_or2, a = fun _ => 1 (all ones), and b = fun _ => 0 (all zeros).
  use 2, cnf_or2, fun _ => 1, fun _ => 0;
  -- Let's unfold the definitions.
  unfold IsBoolVec satisfiesCNF_nat cnf_or2
  simp +decide;
  -- Let's unfold the definition of `satisfiesClauseNat`.
  unfold satisfiesClauseNat;
  simp +decide

/-! ## Main Barrier Theorem -/

/-
**Tropical Non-Encodability of SAT.**
    There is no map from CNF formulas to tropical formulas, together with a
    threshold `k`, such that satisfiability of a CNF on Boolean ℕ-vectors is
    equivalent to the tropical evaluation being at most `k`.

    The proof combines two facts:
    1. Tropical sublevel sets are downward closed (by `sublevel_isLowerSet`).
    2. Some CNF satisfying sets are not downward closed
       (by `exists_cnf_not_downward_closed`).
-/
theorem no_exact_tropical_sublevel_representation :
    ¬ ∃ (encode : ∀ {n : ℕ}, CNF n → TropFormula n) (k : ℕ),
        ∀ (n : ℕ) (F : CNF n) (a : Fin n → ℕ),
          IsBoolVec a →
          (satisfiesCNF_nat a F ↔ eval (encode F) a ≤ k) := by
  intro ⟨ encode, k, h ⟩;
  obtain ⟨ n, F, a, b, ha, hb, hab, h₁, h₂ ⟩ := exists_cnf_not_downward_closed;
  exact h₂ <| h n F b hb |>.2 <| le_trans ( eval_mono _ hab ) <| h n F a ha |>.1 h₁

/-! ## Specific witness: x₁ ∨ x₂ cannot be tropically encoded -/

/-
The satisfying set of `x₁ ∨ x₂` on Boolean vectors cannot be represented
    as a tropical sublevel set, because it is not downward closed.
-/
theorem not_represents_or2_by_tropical_sublevel :
    ¬ ∃ (φ : TropFormula 2) (k : ℕ),
        ∀ a : Fin 2 → ℕ,
          IsBoolVec a →
          (satisfiesCNF_nat a cnf_or2 ↔ eval φ a ≤ k) := by
  rintro ⟨ φ, k, hk ⟩;
  -- Consider the assignment `a = fun _ => 1`. It satisfies `x₁ ∨ x₂` and by assumption `eval φ a ≤ k`.
  have h_a : φ.eval (fun _ => 1) ≤ k := by
    specialize hk (fun _ => 1);
    exact hk ( fun _ => Or.inr rfl ) |>.1 ( by unfold satisfiesCNF_nat cnf_or2; simp +decide [ satisfiesClauseNat ] );
  -- Now consider `b = fun _ => 0`. It is pointwise ≤ `a`, so by monotonicity `eval φ b ≤ k`.
  have h_b : φ.eval (fun _ => 0) ≤ k := by
    exact le_trans ( eval_mono _ fun _ => by simp +decide ) h_a;
  -- But `b` does not satisfy `x₁ ∨ x₂`, so we have a contradiction.
  have h_contra : ¬satisfiesCNF_nat (fun _ => 0) cnf_or2 := by
    simp +decide [ satisfiesCNF_nat, cnf_or2 ];
    simp +decide [ satisfiesClauseNat ];
  exact h_contra <| hk _ ( fun _ => by simp +decide ) |>.2 h_b