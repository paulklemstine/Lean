import Mathlib

/-! # CatalogBuild.Speculative.SciFi.TemporalLogic

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 8
-/

/-- [Section: # CatalogBuild.Speculative.SciFi.TemporalLogic
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 8] -/
theorem no_cycles_in_partial_order {α : Type*} [PartialOrder α]
    (a b : α) (hab : a ≤ b) (hba : b ≤ a) : a = b := by
  grind +extAll

/-- [Section: # CatalogBuild.Speculative.SciFi.TemporalLogic
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 8] -/
theorem no_self_causation {α : Type*} [Preorder α] (a : α) :
    ¬ (a < a) := by
  by_contra h_contra; have h_le : a ≤ a := le_rfl; simp_all +decide [ lt_iff_le_and_ne ] ;

theorem timeline_total {α : Type*} [LinearOrder α] (a b : α) :
    a ≤ b ∨ b ≤ a := by
  exact?

theorem past_is_linear {α : Type*} [Preorder α]
    (h_tree : ∀ a b c : α, a ≤ c → b ≤ c → (a ≤ b ∨ b ≤ a))
    (c : α) (a b : α) (ha : a ≤ c) (hb : b ≤ c) :
    a ≤ b ∨ b ≤ a := by
  exact h_tree a b c ha hb

theorem causal_diamond_between {α : Type*} [PartialOrder α]
    (a b c : α) (h1 : a ≤ c) (h2 : c ≤ b) : a ≤ b := by
  exact le_trans h1 h2

/-- Two events are in "parallel timelines" if neither can causally
influence the other. -/
def parallel_timelines {α : Type*} [PartialOrder α] (a b : α) : Prop :=
  ¬(a ≤ b) ∧ ¬(b ≤ a)

theorem parallel_symmetric {α : Type*} [PartialOrder α] (a b : α) :
    parallel_timelines a b ↔ parallel_timelines b a := by
  exact ⟨ fun h ↦ ⟨ h.2, h.1 ⟩, fun h ↦ ⟨ h.2, h.1 ⟩ ⟩

theorem no_parallel_in_linear_order {α : Type*} [LinearOrder α] (a b : α) :
    ¬ parallel_timelines a b := by
  exact fun h => h.1 ( le_total a b |> Or.resolve_right <| h.2 )

