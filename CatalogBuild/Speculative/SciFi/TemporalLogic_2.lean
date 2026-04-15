/-! # CatalogBuild.Speculative.SciFi.TemporalLogic_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

/-- A cycle in a partial order implies all elements in the cycle are equal. -/
theorem partial_order_cycle {E : Type*} [PartialOrder E]
    {a b : E} (hab : a ≤ b) (hba : b ≤ a) : a = b :=
  le_antisymm hab hba


/-- Time travel is incompatible with a strict partial order on distinct events. -/
theorem no_time_travel_strict_order {E : Type*} [PartialOrder E]
    {a b : E} (hab : a < b) : ¬(b ≤ a) := by
  intro h
  exact absurd (le_antisymm (le_of_lt hab) h) (ne_of_lt hab)


theorem past_glb_exists {T : Type*} [ConditionallyCompleteLattice T]
    (a b : T) (h : BddBelow ({a, b} : Set T)) :
    ∃ c, c ≤ a ∧ c ≤ b ∧ ∀ d, d ≤ a → d ≤ b → d ≤ c := by
  refine' ⟨ InfSet.sInf { a, b }, _, _, _ ⟩;
  · exact csInf_le h ( Set.mem_insert _ _ );
  · exact csInf_le h ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) );
  · exact fun d ha hb => le_csInf ⟨ a, by simp +decide ⟩ fun x hx => by aesop;


/-- In a preorder, causal loops are possible between distinct but equivalent events. -/
theorem preorder_allows_loops {E : Type*} [Preorder E]
    {a b : E} (hab : a ≤ b) (hba : b ≤ a) :
    a ≤ b ∧ b ≤ a :=
  ⟨hab, hba⟩
