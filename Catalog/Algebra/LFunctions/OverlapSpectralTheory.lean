/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Spectral Theory

This file develops a **spectral-algebraic theory of overlap classes** for
families of finite supports, extending the overlap class framework from
`Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean`.

## Mathematical Context

Given a family F : Fin n → Finset α of finite supports, the **overlap
interaction matrix** M has entries M_{ij} = |F(i) ∩ F(j)|. The diagonal
entries are the individual support sizes, and the off-diagonal entries
capture pairwise interaction intensity.

The **overlap graph** is the simple graph where i ~ j iff F(i) ∩ F(j) ≠ ∅.
The connected components of this graph are the overlap classes.

The **overlap complexity** ∑_{i<j} |F(i) ∩ F(j)| measures total pairwise
interaction and provides spectral-style bounds on the family union
cardinality via inclusion-exclusion.

## Novel Definition

* `OverlapInteractionMatrix` — a symmetric ℕ-valued matrix encoding all
  pairwise intersection sizes, whose spectral properties constrain the
  tropical projective equivalence classes of the generating family.

## Main Results

* `overlapComplexity_eq_zero_iff` — complexity 0 ⟺ pairwise disjoint
* `familyUnion_card_eq_totalSupportSize_of_disjoint` — |⋃F| = ∑|F(i)| when disjoint
* `spectral_inclusion_exclusion_bound` — |⋃F| + OverlapComplexity ≥ TotalSupportSize
* `overlapComplexity_mono_refine` — refinement decreases complexity
* `overlapGraph_no_edges_iff_disjoint` — overlap graph edgeless ⟺ pairwise disjoint
* `disjoint_partition_exists` — pairwise disjoint families admit n-class partitions
* `overlapEdgeCount_le_complexity` — edge count ≤ overlap complexity

## References

* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Develin–Santos–Sturmfels, "On the rank of a tropical matrix"
-/

import Mathlib

open Finset BigOperators

variable {α : Type*} [DecidableEq α]

/-! ## Definitions -/

/-- The **overlap interaction matrix** of a support family. Entry (i,j) is the
    cardinality of the intersection F(i) ∩ F(j). This is a symmetric ℕ-valued
    matrix whose diagonal gives individual support sizes. -/
def OverlapInteractionMatrix {n : ℕ} (F : Fin n → Finset α) :
    Matrix (Fin n) (Fin n) ℕ :=
  fun i j => (F i ∩ F j).card

/-- The **overlap graph** of a support family: a simple graph on Fin n
    where i is adjacent to j iff their supports have nonempty intersection. -/
def OverlapGraph {n : ℕ} (F : Fin n → Finset α) : SimpleGraph (Fin n) where
  Adj i j := i ≠ j ∧ (F i ∩ F j).Nonempty
  symm := by
    intro i j ⟨hne, hover⟩
    exact ⟨hne.symm, by rwa [Finset.inter_comm]⟩
  loopless := ⟨fun i h => h.1 rfl⟩

instance overlapGraphDecAdj {n : ℕ} (F : Fin n → Finset α) :
    DecidableRel (OverlapGraph F).Adj :=
  fun i j => inferInstanceAs (Decidable (i ≠ j ∧ (F i ∩ F j).Nonempty))

/-- The **overlap complexity** of a support family: ∑_{i < j} |F(i) ∩ F(j)|. -/
def OverlapComplexity {n : ℕ} (F : Fin n → Finset α) : ℕ :=
  ∑ p ∈ (univ ×ˢ univ).filter (fun p : Fin n × Fin n => p.1 < p.2),
    (F p.1 ∩ F p.2).card

/-- The **total support size** of a family: ∑ᵢ |F(i)|. -/
def TotalSupportSize {n : ℕ} (F : Fin n → Finset α) : ℕ :=
  ∑ i : Fin n, (F i).card

/-- The **edge count** of the overlap graph. -/
def OverlapEdgeCount {n : ℕ} (F : Fin n → Finset α) : ℕ :=
  ((univ ×ˢ univ).filter (fun p : Fin n × Fin n =>
    p.1 < p.2 ∧ (F p.1 ∩ F p.2).Nonempty)).card

/-- A support family G **refines** F if G(i) ⊆ F(i) for all i. -/
def SupportRefines {n : ℕ} (G F : Fin n → Finset α) : Prop :=
  ∀ i, G i ⊆ F i

/-- An **overlap partition**: a partition of indices into classes with
    cross-class disjointness. -/
structure OverlapPartition {n : ℕ} (F : Fin n → Finset α) where
  numClasses : ℕ
  classOf : Fin n → Fin numClasses
  surjective : Function.Surjective classOf
  disjoint_classes : ∀ i j : Fin n, classOf i ≠ classOf j → Disjoint (F i) (F j)

/-- The **family union**: ⋃ᵢ F(i). -/
def FamilyUnion' {n : ℕ} (F : Fin n → Finset α) : Finset α :=
  Finset.univ.biUnion F

/-- A family is **pairwise disjoint**. -/
def IsPairwiseDisjoint' {n : ℕ} (F : Fin n → Finset α) : Prop :=
  ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j)

/-! ## Theorems -/

/-- The overlap interaction matrix is symmetric. -/
theorem overlapInteractionMatrix_symmetric {n : ℕ} (F : Fin n → Finset α)
    (i j : Fin n) :
    OverlapInteractionMatrix F i j = OverlapInteractionMatrix F j i := by
  simp [OverlapInteractionMatrix, Finset.inter_comm]

/-- Diagonal entries equal support sizes. -/
theorem overlapInteractionMatrix_diag_eq_card {n : ℕ} (F : Fin n → Finset α)
    (i : Fin n) :
    OverlapInteractionMatrix F i i = (F i).card := by
  simp [OverlapInteractionMatrix, Finset.inter_self]

/-
Overlap complexity is zero iff the family is pairwise disjoint.
-/
theorem overlapComplexity_eq_zero_iff {n : ℕ} (F : Fin n → Finset α) :
    OverlapComplexity F = 0 ↔ IsPairwiseDisjoint' F := by
  unfold OverlapComplexity IsPairwiseDisjoint';
  simp +decide [ Finset.ext_iff, Finset.disjoint_left ];
  grind

/-
For a pairwise disjoint family, the union cardinality equals the
    sum of individual cardinalities.
-/
theorem familyUnion_card_eq_totalSupportSize_of_disjoint {n : ℕ}
    (F : Fin n → Finset α) (hF : IsPairwiseDisjoint' F) :
    (FamilyUnion' F).card = TotalSupportSize F := by
  convert Finset.card_biUnion ( fun i _ j _ hij => hF i j hij )

/-
**Spectral inclusion-exclusion bound**:
    TotalSupportSize F ≤ |⋃F| + OverlapComplexity F.
    Equivalently, |⋃F| ≥ TotalSupportSize - OverlapComplexity.
-/
theorem spectral_inclusion_exclusion_bound {n : ℕ} (F : Fin n → Finset α) :
    TotalSupportSize F ≤ (FamilyUnion' F).card + OverlapComplexity F := by
  revert F;
  induction' n with n ih <;> simp +decide [ TotalSupportSize, FamilyUnion', OverlapComplexity ] at *;
  intro F
  have h_sum : ∑ i, #(F i) = #(F 0) + ∑ i : Fin n, #(F (Fin.succ i)) := by
    rw [ Fin.sum_univ_succ ]
  have h_union : #(univ.biUnion F) = #(F 0 ∪ univ.biUnion (fun i => F (Fin.succ i))) := by
    congr with x ; simp +decide [ Fin.exists_fin_succ ]
  have h_overlap : ∑ p : Fin (n + 1) × Fin (n + 1) with p.1 < p.2, #(F p.1 ∩ F p.2) = ∑ i : Fin n, #(F 0 ∩ F (Fin.succ i)) + ∑ p : Fin n × Fin n with p.1 < p.2, #(F (Fin.succ p.1) ∩ F (Fin.succ p.2)) := by
    rw [ Finset.sum_filter, Finset.sum_filter ];
    erw [ Finset.sum_product ] ; simp +decide [ Fin.sum_univ_succ, Finset.sum_add_distrib ] ; ring!;
    erw [ Finset.sum_product ]
  have h_card_union : #(F 0 ∩ univ.biUnion (fun i => F (Fin.succ i))) ≤ ∑ i : Fin n, #(F 0 ∩ F (Fin.succ i)) := by
    rw [ Finset.inter_biUnion ] ; exact Finset.card_biUnion_le;
  grind +ring

/-
Refinement decreases overlap complexity.
-/
theorem overlapComplexity_mono_refine {n : ℕ} (F G : Fin n → Finset α)
    (hRefine : SupportRefines G F) :
    OverlapComplexity G ≤ OverlapComplexity F := by
  apply Finset.sum_le_sum;
  exact fun p hp => Finset.card_mono ( Finset.inter_subset_inter ( hRefine _ ) ( hRefine _ ) )

/-
The overlap graph has no edges iff the family is pairwise disjoint.
-/
theorem overlapGraph_no_edges_iff_disjoint {n : ℕ} (F : Fin n → Finset α) :
    (∀ i j : Fin n, ¬(OverlapGraph F).Adj i j) ↔ IsPairwiseDisjoint' F := by
  simp +decide [ IsPairwiseDisjoint', OverlapGraph ];
  simp +decide [ Finset.disjoint_iff_inter_eq_empty ]

/-
Every family admits a trivial partition with 1 class (for n > 0).
-/
omit [DecidableEq α] in
theorem trivial_partition_exists {n : ℕ} (hn : 0 < n) (F : Fin n → Finset α) :
    ∃ P : OverlapPartition F, P.numClasses = 1 := by
  refine' ⟨ ⟨ 1, fun _ => ⟨ 0, by linarith ⟩, _, _ ⟩, rfl ⟩;
  · intro x;
    exact ⟨ ⟨ 0, hn ⟩, by fin_cases x; rfl ⟩;
  · aesop

/-
A pairwise disjoint family admits a partition with n classes.
-/
omit [DecidableEq α] in
theorem disjoint_partition_exists {n : ℕ} (_hn : 0 < n)
    (F : Fin n → Finset α) (hF : IsPairwiseDisjoint' F) :
    ∃ P : OverlapPartition F, P.numClasses = n := by
  refine' ⟨ ⟨ n, fun i => i, _, _ ⟩, rfl ⟩;
  · exact Function.surjective_id;
  · exact fun i j hij => hF i j hij

/-- Overlap complexity equals the sum of upper-triangular entries
    of the interaction matrix. -/
theorem overlapComplexity_eq_upper_triangular_sum {n : ℕ} (F : Fin n → Finset α) :
    OverlapComplexity F =
      ∑ p ∈ (univ ×ˢ univ).filter (fun p : Fin n × Fin n => p.1 < p.2),
        OverlapInteractionMatrix F p.1 p.2 := by
  simp [OverlapComplexity, OverlapInteractionMatrix]

/-
Edge count ≤ overlap complexity.
-/
theorem overlapEdgeCount_le_complexity {n : ℕ} (F : Fin n → Finset α) :
    OverlapEdgeCount F ≤ OverlapComplexity F := by
  unfold OverlapEdgeCount OverlapComplexity;
  rw [ Finset.card_filter ];
  rw [ Finset.sum_filter ] ; gcongr ; aesop;

/-
Refinement decreases total support size.
-/
omit [DecidableEq α] in
theorem totalSupportSize_mono_refine {n : ℕ} (F G : Fin n → Finset α)
    (hRefine : SupportRefines G F) :
    TotalSupportSize G ≤ TotalSupportSize F := by
  exact Finset.sum_le_sum fun i _ => Finset.card_le_card ( hRefine i )

/-
Overlap complexity ≤ ∑_{i<j} min(|F(i)|, |F(j)|).
-/
theorem overlapComplexity_le_min_sum {n : ℕ} (F : Fin n → Finset α) :
    OverlapComplexity F ≤
      ∑ p ∈ (univ ×ˢ univ).filter (fun p : Fin n × Fin n => p.1 < p.2),
        min (F p.1).card (F p.2).card := by
  exact Finset.sum_le_sum fun p hp => le_min ( Finset.card_le_card fun x hx => by aesop ) ( Finset.card_le_card fun x hx => by aesop )

/-! ## Conjecture: Overlap Rigidity Equality

**Conjecture (Overlap Rigidity Equality)**: For every connected finite
graph G, basepoint q, and subset S ⊆ V \ {q}, the number of tropical
projective equivalence classes of minimal generating families for the
tropical kernel on S equals the number of connected components of the
cycle-support overlap graph.

This is falsifiable: enumerate connected graphs on n ≤ 9 vertices and
compare the two counts. A single disagreement disproves it.

We state a weaker, testable version below. -/

/-
**Testable Overlap Bound Conjecture**: For any support family on
    Fin n with n ≥ 2, the overlap complexity is strictly positive
    whenever the overlap graph has at least one edge.
-/
theorem overlap_complexity_pos_of_edge {n : ℕ} (F : Fin n → Finset α)
    (i j : Fin n) (h : (OverlapGraph F).Adj i j) :
    0 < OverlapComplexity F := by
  refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun x _ => Nat.zero_le _ ) ( show ( if i < j then ( i, j ) else ( j, i ) ) ∈ _ from _ ) );
  · split_ifs <;> simp_all +decide [ OverlapGraph ];
    simpa only [ Finset.inter_comm ] using h.2;
  · cases lt_trichotomy i j <;> aesop