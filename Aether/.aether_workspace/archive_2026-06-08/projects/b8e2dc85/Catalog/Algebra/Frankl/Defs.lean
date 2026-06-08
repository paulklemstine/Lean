/-
# Frankl's Union-Closed Conjecture: Core Definitions

This file introduces the fundamental structures and definitions for studying
Frankl's union-closed families conjecture.

## Main Definitions

* `UnionClosedFamily` - A nonempty finite family of finite sets closed under union
* `elemFreq` - The number of sets in a family containing a given element
* `ground` - The union of all sets in the family (the ground set)
* `totalIncidence` - The sum of cardinalities of all sets in the family
* `HasFranklWitness` - Predicate asserting some element appears in ≥ half the sets
* `heavyElements` - The finset of elements appearing in ≥ half the sets
-/

import Mathlib

open Finset BigOperators

/-- A union-closed family is a nonempty finite family of finite sets that is
closed under pairwise union. This is the central object in Frankl's conjecture. -/
structure UnionClosedFamily (α : Type*) [DecidableEq α] where
  /-- The underlying collection of finite sets. -/
  sets : Finset (Finset α)
  /-- The family must be nonempty. -/
  nonempty : sets.Nonempty
  /-- Closure under pairwise union. -/
  union_closed : ∀ {A B : Finset α}, A ∈ sets → B ∈ sets → A ∪ B ∈ sets

namespace UnionClosedFamily

variable {α : Type*} [DecidableEq α]

/-- The frequency of an element `a` in a union-closed family `F` is the number
of sets in `F` that contain `a`. -/
def elemFreq (F : UnionClosedFamily α) (a : α) : ℕ :=
  (F.sets.filter fun s => a ∈ s).card

/-- The ground set of a union-closed family is the union of all its member sets. -/
def ground (F : UnionClosedFamily α) : Finset α :=
  F.sets.biUnion id

/-- Total incidence counts the sum of cardinalities across all sets in the family. -/
def totalIncidence (F : UnionClosedFamily α) : ℕ :=
  ∑ s ∈ F.sets, s.card

/-- A union-closed family has a Frankl witness if some element appears in at
least half of the sets. Frankl's conjecture asserts this always holds. -/
def HasFranklWitness (F : UnionClosedFamily α) : Prop :=
  ∃ a, 2 * F.elemFreq a ≥ F.sets.card

/-- The set of all elements that appear in at least half the sets of the family. -/
def heavyElements (F : UnionClosedFamily α) : Finset α :=
  F.ground.filter fun a => 2 * F.elemFreq a ≥ F.sets.card

/-- An element is in the ground set iff it belongs to some set in the family. -/
theorem mem_ground_iff (F : UnionClosedFamily α) (a : α) :
    a ∈ F.ground ↔ ∃ s ∈ F.sets, a ∈ s := by
  simp [ground, Finset.mem_biUnion]

/-- The frequency of an element outside the ground set is zero. -/
theorem elemFreq_eq_zero_of_not_mem_ground (F : UnionClosedFamily α) (a : α)
    (ha : a ∉ F.ground) : F.elemFreq a = 0 := by
  simp only [elemFreq]
  apply Finset.card_eq_zero.mpr
  rw [Finset.filter_eq_empty_iff]
  intro s hs hmem
  exact ha ((F.mem_ground_iff a).mpr ⟨s, hs, hmem⟩)

/-- Membership characterization for heavy elements. -/
theorem mem_heavyElements_iff (F : UnionClosedFamily α) (a : α) :
    a ∈ F.heavyElements ↔ a ∈ F.ground ∧ 2 * F.elemFreq a ≥ F.sets.card := by
  simp [heavyElements, Finset.mem_filter]

/-- The frequency of any element is at most the number of sets in the family. -/
theorem elemFreq_le_card (F : UnionClosedFamily α) (a : α) :
    F.elemFreq a ≤ F.sets.card :=
  Finset.card_filter_le _ _

/-- If `a` is in ground and in set `s ∈ F.sets`, then `s` is counted in `elemFreq`. -/
theorem mem_filter_of_mem (F : UnionClosedFamily α) (a : α) (s : Finset α)
    (hs : s ∈ F.sets) (ha : a ∈ s) :
    s ∈ F.sets.filter (fun t => a ∈ t) := by
  exact Finset.mem_filter.mpr ⟨hs, ha⟩

/-- The ground set contains any set that is a member of the family. -/
theorem subset_ground (F : UnionClosedFamily α) (s : Finset α) (hs : s ∈ F.sets) :
    s ⊆ F.ground := by
  intro a ha
  exact (F.mem_ground_iff a).mpr ⟨s, hs, ha⟩

end UnionClosedFamily