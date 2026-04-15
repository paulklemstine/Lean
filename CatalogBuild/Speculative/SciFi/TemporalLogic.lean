/-! # CatalogBuild.Speculative.SciFi.TemporalLogic

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 8
-/

import Mathlib

theorem no_cycles_in_partial_order {α : Type*} [PartialOrder α]
    (a b : α) (hab : a ≤ b) (hba : b ≤ a) : a = b := by
  grind +extAll

/-
A strict partial order (modeling strict causality) has no self-loops.
    No event can strictly cause itself.
-/

theorem no_self_causation {α : Type*} [Preorder α] (a : α) :
    ¬ (a < a) := by
  by_contra h_contra; have h_le : a ≤ a := le_rfl; simp_all +decide [ lt_iff_le_and_ne ] ;

/-! ## Section 11.2: Branching Time

In a branching time structure, the past is linear but the future may branch.
This is the mathematical model for the many-worlds interpretation. -/

/-
In a linear order (representing a single timeline), any two events
    are comparable: either a causes b or b causes a.
-/

theorem timeline_total {α : Type*} [LinearOrder α] (a b : α) :
    a ≤ b ∨ b ≤ a := by
  exact?

/-
The past of any event in a branching time structure is totally ordered.
    We model this as: in a tree-like partial order, the downward closure
    of any element is a chain.
-/

theorem past_is_linear {α : Type*} [Preorder α]
    (h_tree : ∀ a b c : α, a ≤ c → b ≤ c → (a ≤ b ∨ b ≤ a))
    (c : α) (a b : α) (ha : a ≤ c) (hb : b ≤ c) :
    a ≤ b ∨ b ≤ a := by
  exact h_tree a b c ha hb

/-! ## Causal Diamonds and Light Cones

In special relativity, the causal structure is determined by light cones.
The "causal diamond" between two events p, q is the set of events that
are in the causal future of p and the causal past of q. -/

/-
The causal diamond (intersection of future and past light cones)
    is contained in the "past" cone: if c is in the future of a and
    the past of b, then c is between a and b.
-/

theorem causal_diamond_between {α : Type*} [PartialOrder α]
    (a b c : α) (h1 : a ≤ c) (h2 : c ≤ b) : a ≤ b := by
  exact le_trans h1 h2

/-! ## Parallel Timelines

In the many-worlds interpretation, timelines that have diverged can
never reconverge. We model this with incomparable elements. -/

/-- Two events are in "parallel timelines" if neither can causally
    influence the other. -/

def parallel_timelines {α : Type*} [PartialOrder α] (a b : α) : Prop :=
  ¬(a ≤ b) ∧ ¬(b ≤ a)

/-
Parallel timelines are symmetric.
-/

theorem parallel_symmetric {α : Type*} [PartialOrder α] (a b : α) :
    parallel_timelines a b ↔ parallel_timelines b a := by
  exact ⟨ fun h ↦ ⟨ h.2, h.1 ⟩, fun h ↦ ⟨ h.2, h.1 ⟩ ⟩

/-
In a linear order (single timeline), no two distinct comparable
    events can be in parallel timelines. Actually, no events at all
    can be in parallel timelines in a linear order.
-/

theorem no_parallel_in_linear_order {α : Type*} [LinearOrder α] (a b : α) :
    ¬ parallel_timelines a b := by
  exact fun h => h.1 ( le_total a b |> Or.resolve_right <| h.2 )

