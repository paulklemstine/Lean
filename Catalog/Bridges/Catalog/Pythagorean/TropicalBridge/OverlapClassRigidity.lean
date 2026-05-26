/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Rigidity for Cycle Support Families

This file develops the theory of **overlap classes** for finite families of
vertex supports, going beyond the disjoint-support regime to analyze how
cycle support interactions control tropical kernel structure.

## Main Definitions

* `SupportsOverlap` — two supports overlap if their intersection is nonempty
* `SupportOverlapGraph` — simple graph on indices, edges from nonempty intersection
* `overlapClassCount` — number of connected components of the overlap graph
* `PairwiseDisjointSupports` — all distinct pairs have empty intersection
* `maxIntersectionSize` — the maximum pairwise intersection cardinality
* `totalOverlapComplexity` — sum of all pairwise intersection cardinalities
* `elementNerve` — for each ground-set element, the set of indices whose support contains it

## Main Results

* `support_overlap_symmetric` — overlap is symmetric
* `overlap_iff_not_disjoint` — overlap characterization via disjointness
* `overlapGraph_edgeless_iff_pairwiseDisjoint` — no edges ↔ pairwise disjoint
* `overlapClassCount_le_card` — overlap class count ≤ family size
* `overlapClassCount_eq_card_of_pairwiseDisjoint` — equality when pairwise disjoint
* `maxIntersectionSize_eq_zero_iff` — zero max intersection ↔ pairwise disjoint
* `totalOverlapComplexity_eq_zero_iff` — zero total complexity ↔ pairwise disjoint
* `overlap_iff_nerve` — overlap characterized via the element nerve

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Develin, Santos, Sturmfels, "On the rank of a tropical matrix" (2005)
-/

import Mathlib

open Finset

namespace OverlapClass

/-! ## Core Definitions -/

/-- Two finite sets overlap if their intersection is nonempty. -/
def SupportsOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

instance {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SupportsOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

/-- A family of supports has pairwise disjoint supports if no two distinct
    members have overlapping supports. -/
def PairwiseDisjointSupports {α ι : Type*} [DecidableEq α]
    (F : ι → Finset α) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (F i) (F j)

/-- The overlap graph on a finite index type: i and j are adjacent iff
    i ≠ j and F(i) ∩ F(j) is nonempty. -/
def SupportOverlapGraph {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) : SimpleGraph ι where
  Adj i j := i ≠ j ∧ (F i ∩ F j).Nonempty
  symm := by
    intro i j ⟨hne, hov⟩
    exact ⟨hne.symm, by rwa [Finset.inter_comm]⟩
  loopless := Std.Irrefl.mk (fun _ ⟨h, _⟩ => h rfl)

instance {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) : DecidableRel (SupportOverlapGraph F).Adj :=
  fun _ _ => inferInstanceAs (Decidable (_ ∧ _))

/-- Two indices are in the same overlap class if they are connected in the
    overlap graph. -/
def SameOverlapClass {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) (i j : ι) : Prop :=
  (SupportOverlapGraph F).Reachable i j

open Classical in
noncomputable instance {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) (i j : ι) : Decidable (SameOverlapClass F i j) :=
  inferInstanceAs (Decidable ((SupportOverlapGraph F).Reachable i j))

/-- The number of connected components (overlap classes) in the support family. -/
noncomputable def overlapClassCount {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) : ℕ :=
  Fintype.card (SupportOverlapGraph F).ConnectedComponent

/-- The maximum pairwise intersection cardinality in a family. -/
noncomputable def maxIntersectionSize {α ι : Type*} [DecidableEq α]
    [Fintype ι] [DecidableEq ι] (F : ι → Finset α) : ℕ :=
  Finset.sup (Finset.univ ×ˢ Finset.univ)
    (fun p : ι × ι => if p.1 ≠ p.2 then (F p.1 ∩ F p.2).card else 0)

/-- The total overlap complexity: sum of all pairwise intersection sizes
    (counting each unordered pair once). -/
noncomputable def totalOverlapComplexity {α ι : Type*} [DecidableEq α]
    [Fintype ι] [DecidableEq ι] [LinearOrder ι] (F : ι → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : ι × ι => p.1 < p.2)).sum
    (fun p => (F p.1 ∩ F p.2).card)

/-- For each element x, the set of indices whose support contains x. -/
noncomputable def elementNerve {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) (x : α) : Finset ι :=
  Finset.univ.filter (fun i => x ∈ F i)

/-- The support union within an overlap class. -/
noncomputable def overlapClassSupport {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) (i : ι) : Finset α :=
  (Finset.univ.filter (fun j => SameOverlapClass F i j)).biUnion F

/-- The overlap pair count: number of ordered overlapping pairs, divided by 2. -/
noncomputable def overlapPairCount {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : ι × ι => p.1 ≠ p.2 ∧ (F p.1 ∩ F p.2).Nonempty)).card / 2

/-! ## Basic Properties of Overlap -/

/-- Overlap is symmetric. -/
theorem support_overlap_symmetric {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ SupportsOverlap B A := by
  simp [SupportsOverlap, Finset.inter_comm]

/-- Overlap with self is equivalent to nonemptiness. -/
theorem support_overlap_self_iff {α : Type*} [DecidableEq α]
    {A : Finset α} :
    SupportsOverlap A A ↔ A.Nonempty := by
  simp [SupportsOverlap, Finset.inter_self]

/-- The empty set does not overlap with anything. -/
theorem support_overlap_empty_left {α : Type*} [DecidableEq α]
    {B : Finset α} :
    ¬SupportsOverlap (∅ : Finset α) B := by
  simp [SupportsOverlap]

/-- Overlap is monotone in both arguments. -/
theorem support_overlap_mono {α : Type*} [DecidableEq α]
    {A B A' B' : Finset α} (hA : A ⊆ A') (hB : B ⊆ B')
    (h : SupportsOverlap A B) :
    SupportsOverlap A' B' := by
  obtain ⟨x, hx⟩ := h
  simp only [Finset.mem_inter] at hx
  exact ⟨x, Finset.mem_inter.mpr ⟨hA hx.1, hB hx.2⟩⟩

/-- Overlap is the negation of disjointness (for Finsets). -/
theorem overlap_iff_not_disjoint {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ ¬Disjoint A B := by
  rw [Finset.not_disjoint_iff]
  simp [SupportsOverlap, Finset.Nonempty, Finset.mem_inter]

/-- If A and B are disjoint, they do not overlap. -/
theorem not_overlap_of_disjoint {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : Disjoint A B) :
    ¬SupportsOverlap A B := by
  rw [overlap_iff_not_disjoint]
  exact not_not.mpr h

/-! ## Overlap Graph vs Disjointness -/

/-- In the pairwise disjoint case, the overlap graph has no edges. -/
theorem overlapGraph_edgeless_of_pairwiseDisjoint {α ι : Type*}
    [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) (h : PairwiseDisjointSupports F) :
    ∀ i j : ι, ¬(SupportOverlapGraph F).Adj i j := by
  intro i j ⟨hne, hov⟩
  exact not_overlap_of_disjoint (h i j hne) hov

/-- If the overlap graph has no edges, supports are pairwise disjoint. -/
theorem pairwiseDisjoint_of_overlapGraph_edgeless {α ι : Type*}
    [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) (h : ∀ i j : ι, ¬(SupportOverlapGraph F).Adj i j) :
    PairwiseDisjointSupports F := by
  intro i j hne
  by_contra hnd
  exact h i j ⟨hne, overlap_iff_not_disjoint.mpr hnd⟩

/-- The overlap graph has no edges iff supports are pairwise disjoint. -/
theorem overlapGraph_edgeless_iff_pairwiseDisjoint {α ι : Type*}
    [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) :
    (∀ i j : ι, ¬(SupportOverlapGraph F).Adj i j) ↔
      PairwiseDisjointSupports F :=
  ⟨pairwiseDisjoint_of_overlapGraph_edgeless F,
   overlapGraph_edgeless_of_pairwiseDisjoint F⟩

/-! ## SameOverlapClass is an equivalence relation -/

theorem sameOverlapClass_refl {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) (i : ι) :
    SameOverlapClass F i i :=
  .refl i

theorem sameOverlapClass_symm {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) {i j : ι} (h : SameOverlapClass F i j) :
    SameOverlapClass F j i :=
  h.symm

theorem sameOverlapClass_trans {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) {i j k : ι}
    (h1 : SameOverlapClass F i j) (h2 : SameOverlapClass F j k) :
    SameOverlapClass F i k :=
  h1.trans h2

/-! ## Overlap Class Count Bounds -/

/-- The number of overlap classes is at most the number of indices. -/
theorem overlapClassCount_le_card {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) :
    overlapClassCount F ≤ Fintype.card ι := by
  unfold overlapClassCount
  exact Fintype.card_le_of_surjective _
    (fun c => c.ind (fun v => ⟨v, rfl⟩))

/-- The overlap class count is at least 1 when the index type is nonempty. -/
theorem overlapClassCount_pos {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] [Nonempty ι] (F : ι → Finset α) :
    0 < overlapClassCount F := by
  unfold overlapClassCount
  exact Fintype.card_pos

/-
In a pairwise disjoint family, distinct indices are NOT in the same overlap class.
    This is the key fact: in an edgeless graph, reachability implies equality.
-/
theorem not_sameOverlapClass_of_pairwiseDisjoint_ne {α ι : Type*}
    [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) (h : PairwiseDisjointSupports F)
    {i j : ι} (hne : i ≠ j) :
    ¬SameOverlapClass F i j := by
  intro h;
  obtain ⟨ p ⟩ := h;
  induction p <;> simp_all +decide [ SameOverlapClass ];
  rename_i u v w p hp huv;
  exact absurd ( h u w hne ) ( Finset.not_disjoint_iff.mpr ⟨ Classical.choose ( hp.2 ), Finset.mem_inter.mp ( Classical.choose_spec ( hp.2 ) ) ⟩ )

/-
When supports are pairwise disjoint, each index is its own overlap class.
-/
theorem overlapClassCount_eq_card_of_pairwiseDisjoint {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) (h : PairwiseDisjointSupports F) :
    overlapClassCount F = Fintype.card ι := by
  refine' Fintype.card_congr _;
  symm;
  refine' Equiv.ofBijective ( fun i => ( SupportOverlapGraph F ).connectedComponentMk i ) ⟨ fun i j hij => _, fun c => _ ⟩;
  · contrapose! hij;
    exact fun h' => not_sameOverlapClass_of_pairwiseDisjoint_ne F h hij ( by simpa [ SameOverlapClass ] using h' );
  · obtain ⟨ i, hi ⟩ := c.exists_rep; use i;
    exact hi

/-- An overlap pair gives a witness element in the intersection. -/
theorem overlap_adj_witness {α ι : Type*} [DecidableEq α] [DecidableEq ι]
    (F : ι → Finset α) {i j : ι}
    (h : (SupportOverlapGraph F).Adj i j) :
    ∃ x : α, x ∈ F i ∧ x ∈ F j := by
  obtain ⟨_, ⟨x, hx⟩⟩ := h
  exact ⟨x, Finset.mem_inter.mp hx⟩

/-! ## maxIntersectionSize characterizes disjointness -/

/-
In a pairwise disjoint family, the max intersection size is zero.
-/
theorem maxIntersectionSize_eq_zero_of_pairwiseDisjoint {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) (h : PairwiseDisjointSupports F) :
    maxIntersectionSize F = 0 := by
  refine' le_antisymm _ _;
  · refine' Finset.sup_le _;
    intro p hp; split_ifs <;> simp_all +decide [ Finset.disjoint_iff_inter_eq_empty ] ;
    exact Finset.disjoint_iff_inter_eq_empty.mp ( h _ _ ‹_› );
  · exact Nat.zero_le _

/-
If maxIntersectionSize is zero, supports are pairwise disjoint.
-/
theorem pairwiseDisjoint_of_maxIntersectionSize_zero {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) (h : maxIntersectionSize F = 0) :
    PairwiseDisjointSupports F := by
  intro i j hij;
  contrapose! h;
  refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.le_sup ( f := fun p : ι × ι => if p.1 ≠ p.2 then ( F p.1 ∩ F p.2 ).card else 0 ) ( Finset.mk_mem_product ( Finset.mem_univ i ) ( Finset.mem_univ j ) ) ) ) ; simp +decide [ hij, h ];
  exact Finset.not_disjoint_iff_nonempty_inter.mp h

/-- maxIntersectionSize is zero iff the family is pairwise disjoint. -/
theorem maxIntersectionSize_eq_zero_iff {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) :
    maxIntersectionSize F = 0 ↔ PairwiseDisjointSupports F :=
  ⟨pairwiseDisjoint_of_maxIntersectionSize_zero F,
   maxIntersectionSize_eq_zero_of_pairwiseDisjoint F⟩

/-! ## Total Overlap Complexity -/

/-
Total overlap complexity is zero iff the family is pairwise disjoint.
-/
theorem totalOverlapComplexity_eq_zero_iff {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι] [LinearOrder ι]
    (F : ι → Finset α) :
    totalOverlapComplexity F = 0 ↔ PairwiseDisjointSupports F := by
  constructor <;> intro h;
  · intro i j hij;
    cases lt_or_gt_of_ne hij <;> simp_all +decide [ totalOverlapComplexity ];
    · exact Finset.disjoint_iff_inter_eq_empty.mpr ( h i j ‹_› );
    · exact Finset.disjoint_iff_inter_eq_empty.mpr ( by rw [ Finset.inter_comm, h _ _ ‹_› ] );
  · refine' Finset.sum_eq_zero fun p hp => _;
    simp_all +decide [ Finset.ext_iff, PairwiseDisjointSupports ];
    exact fun x hx₁ hx₂ => Finset.disjoint_left.mp ( h _ _ hp.ne ) hx₁ hx₂

/-! ## Element Nerve characterizes overlap -/

/-- Two supports overlap iff there exists an element whose nerve contains both. -/
theorem overlap_iff_nerve {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) (i j : ι) :
    (F i ∩ F j).Nonempty ↔
      ∃ x : α, i ∈ elementNerve F x ∧ j ∈ elementNerve F x := by
  simp [elementNerve, Finset.Nonempty, Finset.mem_inter, Finset.mem_filter]

/-- The overlap graph adjacency can be characterized via the nerve. -/
theorem overlapGraph_adj_iff_nerve {α ι : Type*} [DecidableEq α] [Fintype ι]
    [DecidableEq ι] (F : ι → Finset α) (i j : ι) :
    (SupportOverlapGraph F).Adj i j ↔
      i ≠ j ∧ ∃ x : α, i ∈ elementNerve F x ∧ j ∈ elementNerve F x := by
  simp [SupportOverlapGraph, overlap_iff_nerve]

/-
The overlap pair count of a pairwise-disjoint family is zero.
-/
theorem overlapPairCount_eq_zero_of_pairwiseDisjoint {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) (h : PairwiseDisjointSupports F) :
    overlapPairCount F = 0 := by
  convert Nat.div_eq_of_lt _;
  rw [ Finset.card_eq_zero.mpr ] <;> norm_num;
  exact fun a b hab => Finset.disjoint_iff_inter_eq_empty.mp ( h a b hab )

/-! ## Overlap Class Support Properties -/

/-- The support of an index is contained in its class support. -/
theorem support_subset_overlapClassSupport {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) (i : ι) :
    F i ⊆ overlapClassSupport F i := by
  intro x hx
  simp only [overlapClassSupport]
  exact Finset.mem_biUnion.mpr ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, .refl i⟩, hx⟩

/-! ## Intersection cardinality bound -/

/-
The maxIntersectionSize bounds any particular pairwise intersection.
-/
theorem intersection_card_le_maxIntersectionSize {α ι : Type*}
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (F : ι → Finset α) (i j : ι) (hne : i ≠ j) :
    (F i ∩ F j).card ≤ maxIntersectionSize F := by
  exact Finset.le_sup ( f := fun p : ι × ι => if p.1 ≠ p.2 then # ( F p.1 ∩ F p.2 ) else 0 ) ( Finset.mk_mem_product ( Finset.mem_univ i ) ( Finset.mem_univ j ) ) |> le_trans ( by aesop )

end OverlapClass