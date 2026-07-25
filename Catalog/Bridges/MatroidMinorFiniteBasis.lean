/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Well-quasi-orders and finite excluded-minor bases

This file formalizes the order-theoretic implication at the heart of the proposed
Robertson--Seymour theorem for finite-field-representable matroids.  It does not
assert that representable matroids are well-quasi-ordered.  Instead, it proves
that any such well-quasi-order theorem would yield a finite excluded-minor
characterization.

The development applies to an arbitrary partial order, and is then stated in the
language of the matroid minor order.  The finite obstruction set is canonical:
it consists of the minimal objects outside the minor-closed class.
-/

open Set

namespace MatroidMinorFiniteBasis

section OrderTheory

variable {α : Type*} [PartialOrder α]

/-- The minimal members of a set in a partial order. -/
def minimalMembers (U : Set α) : Set α :=
  {x | x ∈ U ∧ ∀ y, y < x → y ∉ U}

/-- Minimal members of a set are pairwise incomparable.
-/
theorem minimalMembers_isAntichain (U : Set α) :
    IsAntichain (· ≤ ·) (minimalMembers U) := by
  intro x hx y hy hxy;
  exact fun h => hy.2 x ( lt_of_le_of_ne h hxy ) hx.1

/-- A well-quasi-order has only finitely many minimal members in every set.
-/
theorem minimalMembers_finite
    (hwqo : WellQuasiOrdered ((· ≤ ·) : α → α → Prop)) (U : Set α) :
    (minimalMembers U).Finite := by
  -- By definition of a well-quasi-order, an antichain must be finite.
  have : IsAntichain (· ≤ ·) (minimalMembers U) := by
    apply minimalMembers_isAntichain;
  convert this.finite_of_wellQuasiOrdered hwqo

/-- Every member of a set in a well-quasi-order lies above a minimal member.
-/
theorem exists_minimalMember_le
    (hwqo : WellQuasiOrdered ((· ≤ ·) : α → α → Prop))
    (U : Set α) {x : α} (hx : x ∈ U) :
    ∃ b ∈ minimalMembers U, b ≤ x := by
  -- By the well-foundedness of <, there exists a minimal element g in the set {y | y ∈ U ∧ y ≤ x}.
  obtain ⟨g, hg⟩ : ∃ g ∈ {y | y ∈ U ∧ y ≤ x}, ∀ z ∈ {y | y ∈ U ∧ y ≤ x}, ¬z < g := by
    convert hwqo.wellFounded.has_min _ ?_;
    · simp +decide [lt_iff_le_and_ne];
      grind +qlia;
    · exact ⟨ x, hx, le_rfl ⟩;
  exact ⟨ g, ⟨ hg.1.1, fun z hz hz' => hg.2 z ⟨ hz', hz.le.trans hg.1.2 ⟩ hz ⟩, hg.1.2 ⟩

/-- A lower set in a well-quasi-order is characterized by finitely many canonical
minimal forbidden objects.
-/
theorem finite_canonical_forbidden_basis
    (hwqo : WellQuasiOrdered ((· ≤ ·) : α → α → Prop))
    (C : Set α) (hC : IsLowerSet C) :
    (minimalMembers Cᶜ).Finite ∧
      ∀ x, x ∈ C ↔ ∀ b ∈ minimalMembers Cᶜ, ¬ b ≤ x := by
  refine' ⟨ _, fun x => ⟨ fun hx b hb hb' => hb.1 <| hC hb' hx, _ ⟩ ⟩;
  · exact minimalMembers_finite hwqo Cᶜ
  · contrapose!;
    exact fun hx => exists_minimalMember_le hwqo ( Cᶜ ) hx

/-- Every minor-closed class in a well-quasi-order has a finite forbidden basis.
-/
theorem exists_finite_forbidden_basis
    (hwqo : WellQuasiOrdered ((· ≤ ·) : α → α → Prop))
    (C : Set α) (hC : IsLowerSet C) :
    ∃ B : Set α, B.Finite ∧ B ⊆ Cᶜ ∧
      ∀ x, x ∈ C ↔ ∀ b ∈ B, ¬ b ≤ x := by
  refine' ⟨ _, _, _, _ ⟩;
  exact minimalMembers Cᶜ;
  · exact minimalMembers_finite hwqo Cᶜ
  · exact fun x hx => hx.1;
  · exact ( finite_canonical_forbidden_basis hwqo C hC ).2

/-- The canonical excluded objects of a lower set form an antichain.
-/
theorem canonical_forbidden_isAntichain (C : Set α) :
    IsAntichain (· ≤ ·) (minimalMembers Cᶜ) := by
  exact minimalMembers_isAntichain _

/-- Every canonical obstruction to an intersection of two lower classes is
already a canonical obstruction to one of the two classes.
-/
theorem minimalMembers_compl_inter_subset_union (C D : Set α) :
    minimalMembers (C ∩ D)ᶜ ⊆ minimalMembers Cᶜ ∪ minimalMembers Dᶜ := by
  intro x hx;
  cases' em ( x ∈ C ) with hC hC <;> cases' em ( x ∈ D ) with hD hD <;> simp_all +decide [ minimalMembers ]

/-- Intersections of classes with finite canonical obstruction sets again have
finitely many canonical obstructions, without any ambient WQO assumption.
-/
theorem finite_minimalMembers_compl_inter
    {C D : Set α} (hC : (minimalMembers Cᶜ).Finite)
    (hD : (minimalMembers Dᶜ).Finite) :
    (minimalMembers (C ∩ D)ᶜ).Finite := by
  refine' Set.Finite.subset ( hC.union hD ) _;
  grind +suggestions

end OrderTheory

section Matroids

open Matroid

variable {α : Type*}

/-- A class of matroids is minor-closed when it contains every minor of each of
its members. -/
def IsMatroidMinorClosed (C : Set (Matroid α)) : Prop :=
  ∀ ⦃M N : Matroid α⦄, M ∈ C → N ≤m M → N ∈ C

/-- A matroid is an excluded minor for `C` when it is outside `C` and every
strictly smaller minor belongs to `C`. -/
def IsExcludedMinor (C : Set (Matroid α)) (M : Matroid α) : Prop :=
  M ∉ C ∧ ∀ ⦃N : Matroid α⦄, N <m M → N ∈ C

/-- Excluded minors are exactly the order-theoretic minimal members of the
complement.
-/
theorem isExcludedMinor_iff_minimalMember (C : Set (Matroid α)) (M : Matroid α) :
    IsExcludedMinor C M ↔ M ∈ minimalMembers Cᶜ := by
  -- By definition of `IsExcludedMinor`, we have that `M ∉ C` and `∀ ⦃N : Matroid α⦄, N <m M → N ∈ C`.
  simp [IsExcludedMinor, minimalMembers]

/-- Distinct excluded minors of a class are incomparable by the minor relation.
-/
theorem excludedMinors_isAntichain (C : Set (Matroid α)) :
    IsAntichain (· ≤m ·) {M | IsExcludedMinor C M} := by
  intro M hM N hN hMN; have := minimalMembers_isAntichain Cᶜ; simp_all +decide [ IsAntichain ] ;
  exact this ( isExcludedMinor_iff_minimalMember C M |>.1 hM ) ( isExcludedMinor_iff_minimalMember C N |>.1 hN ) hMN

/-- An excluded minor for the intersection of two matroid classes is an
excluded minor for at least one constituent class.
-/
theorem excludedMinor_inter (C D : Set (Matroid α)) {M : Matroid α}
    (hM : IsExcludedMinor (C ∩ D) M) :
    IsExcludedMinor C M ∨ IsExcludedMinor D M := by
  convert minimalMembers_compl_inter_subset_union C D ( show M ∈ minimalMembers ( C ∩ D ) ᶜ from ( isExcludedMinor_iff_minimalMember _ _ ).mp hM ) using 1;
  simp +decide [ ← isExcludedMinor_iff_minimalMember ]

/-- If two matroid classes each have finitely many excluded minors, then their
intersection has finitely many excluded minors.  This conclusion does not
require a global well-quasi-order hypothesis.
-/
theorem finite_excludedMinors_inter {C D : Set (Matroid α)}
    (hC : {M | IsExcludedMinor C M}.Finite)
    (hD : {M | IsExcludedMinor D M}.Finite) :
    {M | IsExcludedMinor (C ∩ D) M}.Finite := by
  exact Set.Finite.subset ( hC.union hD ) fun x hx => by have := excludedMinor_inter C D hx; tauto;

/-- Conditional Robertson--Seymour consequence for matroids: if the matroid
minor order is a well-quasi-order, every minor-closed class has finitely many
excluded minors, and membership is equivalent to avoiding all of them.
-/
theorem matroid_wqo_gives_finite_excluded_minors
    (hwqo : WellQuasiOrdered ((· ≤m ·) : Matroid α → Matroid α → Prop))
    (C : Set (Matroid α)) (hC : IsMatroidMinorClosed C) :
    {M | IsExcludedMinor C M}.Finite ∧
      ∀ M, M ∈ C ↔ ∀ N, IsExcludedMinor C N → ¬ N ≤m M := by
  have h_lower_set : IsLowerSet C :=
    isLowerSet_iff_Iic_subset.mpr fun _ hM _ hNM => hC hM hNM
  convert finite_canonical_forbidden_basis hwqo C h_lower_set using 1;
  · rw [ show { M | IsExcludedMinor C M } = minimalMembers Cᶜ from ?_ ];
    exact Set.ext fun M => isExcludedMinor_iff_minimalMember C M;
  · simp +decide [ isExcludedMinor_iff_minimalMember ]

end Matroids

end MatroidMinorFiniteBasis