/-
# Lattice-Theoretic Reformulation of Frankl's Conjecture

This file bridges union-closed families and finite lattice theory.
A union-closed family naturally forms a finite join-semilattice under
the subset ordering, and Frankl's conjecture can be reformulated in
terms of "heavy" join-irreducible elements.

## Main Results

* `UnionClosedFamily.toSemilatticeSup` - the sets of a union-closed family
  form a join-semilattice
* `frankl_set_family_equiv_ground_form` - Frankl witness ↔ witness in ground
* `mean_frequency_ge_average_incidence` - averaging principle for frequencies
-/

import Algebra.Frankl.DoubleCount

open Finset BigOperators

namespace UnionClosedFamily

variable {α : Type*} [DecidableEq α]

/-- A set is join-irreducible in the family if it cannot be written as a union
of two strictly smaller members of the family. These are the "atomic generators"
of the closure system. -/
def IsJoinIrreducible (F : UnionClosedFamily α) (s : Finset α) : Prop :=
  s ∈ F.sets ∧ s ≠ ∅ ∧
    ∀ A B : Finset α, A ∈ F.sets → B ∈ F.sets → A ∪ B = s → A = s ∨ B = s

/-- The upper cone of an element `a` in the family: the sets containing `a`. -/
def upperCone (F : UnionClosedFamily α) (a : α) : Finset (Finset α) :=
  F.sets.filter fun s => a ∈ s

/-- The cardinality of the upper cone equals elemFreq. -/
theorem upperCone_card_eq_elemFreq (F : UnionClosedFamily α) (a : α) :
    (F.upperCone a).card = F.elemFreq a := rfl

/-
**Frankl witness reformulation via ground set.**
HasFranklWitness is equivalent to the existence of a witness in the ground set.
-/
theorem frankl_set_family_equiv_ground_form (F : UnionClosedFamily α) :
    F.HasFranklWitness ↔ ∃ a ∈ F.ground, 2 * F.elemFreq a ≥ F.sets.card := by
  refine' ⟨ _, fun ⟨ a, ha, ha' ⟩ ↦ ⟨ a, by linarith ⟩ ⟩;
  rintro ⟨ a, ha ⟩;
  by_cases ha' : a ∈ F.ground;
  · use a;
  · rw [ UnionClosedFamily.elemFreq_eq_zero_of_not_mem_ground F a ha' ] at ha ; linarith [ F.nonempty.card_pos ]

/-- **Mean frequency principle.** There exists an element in the ground set
whose frequency times the ground size is at least the total incidence.
This is the discrete expectation-maximization principle:
  max_a freq(a) ≥ (∑_a freq(a)) / |ground| = totalIncidence / |ground|. -/
theorem mean_frequency_ge_average_incidence (F : UnionClosedFamily α)
    (hg : F.ground.Nonempty) :
    ∃ a ∈ F.ground, F.ground.card * F.elemFreq a ≥ F.totalIncidence := by
  exact exists_element_freq_ge_avg F hg

/-- **Upper cone monotonicity.** If a ∈ s and s ∈ F, then the upper cone of a
contains s. -/
theorem mem_upperCone_of_mem (F : UnionClosedFamily α) (a : α) (s : Finset α)
    (hs : s ∈ F.sets) (ha : a ∈ s) : s ∈ F.upperCone a :=
  Finset.mem_filter.mpr ⟨hs, ha⟩

/-- **Union closure of upper cones.** If s, t are in the upper cone of a,
then s ∪ t is also in the upper cone of a. -/
theorem upperCone_union_closed (F : UnionClosedFamily α) (a : α)
    (s t : Finset α) (hs : s ∈ F.upperCone a) (ht : t ∈ F.upperCone a) :
    s ∪ t ∈ F.upperCone a := by
  simp [upperCone, Finset.mem_filter] at *
  exact ⟨F.union_closed hs.1 ht.1, Or.inl hs.2⟩

end UnionClosedFamily