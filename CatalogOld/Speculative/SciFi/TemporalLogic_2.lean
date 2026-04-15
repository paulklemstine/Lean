/-
  Mathematics of Science Fiction — Chapter 11: Temporal Logic and Causality
  Causal structures, partial orders, branching time.
  Author: Paul Klemstine | Soli Deo Gloria
-/
import Mathlib

open Order

/-! ## Causal Ordering

  A causal structure is a partial order on events.
  Time travel (causal loops) is incompatible with strict partial orders. -/

/-- A cycle in a partial order implies all elements in the cycle are equal. -/
theorem partial_order_cycle {E : Type*} [PartialOrder E]
    {a b : E} (hab : a ≤ b) (hba : b ≤ a) : a = b :=
  le_antisymm hab hba

/-- Time travel is incompatible with a strict partial order on distinct events. -/
theorem no_time_travel_strict_order {E : Type*} [PartialOrder E]
    {a b : E} (hab : a < b) : ¬(b ≤ a) := by
  intro h
  exact absurd (le_antisymm (le_of_lt hab) h) (ne_of_lt hab)

/-! ## Branching Time Structure

  The past is linear (totally ordered) but the future may branch. -/

/-- In a linear order (modeling the past), any two elements are comparable. -/
theorem past_is_linear {T : Type*} [LinearOrder T] (a b : T) :
    a ≤ b ∨ b ≤ a :=
  le_total a b

/-
Greatest lower bound exists in a conditionally complete lattice.
-/
theorem past_glb_exists {T : Type*} [ConditionallyCompleteLattice T]
    (a b : T) (h : BddBelow ({a, b} : Set T)) :
    ∃ c, c ≤ a ∧ c ≤ b ∧ ∀ d, d ≤ a → d ≤ b → d ≤ c := by
  refine' ⟨ InfSet.sInf { a, b }, _, _, _ ⟩;
  · exact csInf_le h ( Set.mem_insert _ _ );
  · exact csInf_le h ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) );
  · exact fun d ha hb => le_csInf ⟨ a, by simp +decide ⟩ fun x hx => by aesop;

/-! ## Preorders and Time Travel

  To accommodate time travel, weaken the causal structure to a preorder. -/

/-- In a preorder, causal loops are possible between distinct but equivalent events. -/
theorem preorder_allows_loops {E : Type*} [Preorder E]
    {a b : E} (hab : a ≤ b) (hba : b ≤ a) :
    a ≤ b ∧ b ≤ a :=
  ⟨hab, hba⟩