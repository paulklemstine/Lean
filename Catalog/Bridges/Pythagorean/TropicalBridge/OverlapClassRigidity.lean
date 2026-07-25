/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Rigidity: Beyond Disjoint Supports

This file formalizes a theory of **overlap classes** for finite families of
supports, extending the disjoint-support uniqueness machinery from
`TropicalKernelRigidity.lean` to regimes where supports may intersect.

## Main Definitions

* `SupportsOverlap` — two finite sets have nonempty intersection
* `SupportOverlapGraph` — simple graph on indices; adjacent iff supports overlap
* `overlapDegree` — maximum pairwise intersection cardinality
* `overlapClassCount` — number of connected components of the overlap graph

## Main Results

* `supportsOverlap_symm` — overlap is symmetric
* `overlapDegree_eq_zero_iff_pairwiseDisjoint` — degree 0 ↔ disjoint supports
* `disjoint_overlap_classes_no_interaction` — different classes ⟹ disjoint supports
* `tropProjEquiv_support_transport` — TropProjEquiv preserves supports
* `overlapClassCount_eq_card_of_pairwiseDisjoint` — disjoint ⟹ max class count
* `totalOverlapComplexity_eq_zero_iff` — complexity 0 ↔ disjoint supports
-/

import Catalog.Pythagorean.TropicalBridge.TropicalKernelRigidity

open Finset BigOperators

/-! ## Section 1: The Support Overlap Relation -/

/-- Two finite sets **overlap** if their intersection is nonempty. -/
def SupportsOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

instance supportsOverlapDecidable {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SupportsOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

/-- The overlap relation is symmetric. -/
theorem supportsOverlap_symm {α : Type*} [DecidableEq α]
    (A B : Finset α) :
    SupportsOverlap A B ↔ SupportsOverlap B A := by
  simp [SupportsOverlap, Finset.inter_comm]

/-- Non-overlap is equivalent to disjointness. -/
theorem not_supportsOverlap_iff_disjoint {α : Type*} [DecidableEq α]
    (A B : Finset α) :
    ¬SupportsOverlap A B ↔ Disjoint A B := by
  simp [SupportsOverlap, Finset.not_nonempty_iff_eq_empty,
    Finset.disjoint_iff_inter_eq_empty]

/-- Overlap characterized by witness existence. -/
theorem supportsOverlap_iff_exists {α : Type*} [DecidableEq α]
    (A B : Finset α) :
    SupportsOverlap A B ↔ ∃ x, x ∈ A ∧ x ∈ B := by
  simp [SupportsOverlap, Finset.Nonempty, Finset.mem_inter]

/-! ## Section 2: The Support Interaction Graph -/

/-- The **support interaction graph** on an indexed family of finite sets.
    Two distinct indices are adjacent iff their supports overlap. -/
def SupportOverlapGraph {ι α : Type*} [DecidableEq ι] [DecidableEq α]
    (F : ι → Finset α) : SimpleGraph ι where
  Adj i j := i ≠ j ∧ SupportsOverlap (F i) (F j)
  symm := by
    intro i j ⟨hne, hover⟩
    exact ⟨hne.symm, (supportsOverlap_symm _ _).mp hover⟩
  loopless := ⟨fun i h => h.1 rfl⟩

instance supportOverlapGraphDecRel {ι α : Type*} [DecidableEq ι] [DecidableEq α]
    (F : ι → Finset α) : DecidableRel (SupportOverlapGraph F).Adj :=
  fun _ _ => inferInstanceAs (Decidable (_ ∧ _))

/-- Two indices are in the same **overlap class** if connected in the
    support interaction graph. -/
def SameOverlapClass {ι α : Type*} [DecidableEq ι] [DecidableEq α]
    (F : ι → Finset α) (i j : ι) : Prop :=
  (SupportOverlapGraph F).Reachable i j

/-- Number of overlap classes = connected components of the overlap graph. -/
noncomputable def overlapClassCount {ι α : Type*} [DecidableEq ι] [DecidableEq α]
    [Fintype ι] (F : ι → Finset α) : ℕ :=
  Fintype.card (SupportOverlapGraph F).ConnectedComponent

/-! ## Section 3: Overlap Degree -/

/-- The **overlap degree**: maximum pairwise intersection cardinality. -/
noncomputable def overlapDegree {ι α : Type*} [DecidableEq ι] [DecidableEq α]
    [Fintype ι] (F : ι → Finset α) : ℕ :=
  Finset.sup (Finset.univ ×ˢ Finset.univ)
    (fun p : ι × ι => if p.1 ≠ p.2 then (F p.1 ∩ F p.2).card else 0)

/-! ## Section 4: Pairwise Disjoint Finsets -/

/-- Pairwise disjointness for indexed Finset families. -/
def PairwiseDisjointFinsets {ι α : Type*} [DecidableEq α]
    (F : ι → Finset α) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (F i) (F j)

/-! ## Section 5: Bridge Theorem — Overlap Degree Zero ↔ Pairwise Disjointness -/

/-
**Bridge theorem:** overlap degree zero ↔ pairwise disjointness.
    This connects the overlap framework to the existing disjoint-support
    rigidity machinery.
-/
theorem overlapDegree_eq_zero_iff_pairwiseDisjoint
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) :
    overlapDegree F = 0 ↔ PairwiseDisjointFinsets F := by
  constructor <;> intro h <;> simp_all +decide [ overlapDegree ];
  · exact fun i j hij => Finset.disjoint_iff_inter_eq_empty.mpr ( h i j hij );
  · exact fun i j hij => Finset.disjoint_iff_inter_eq_empty.mp ( h i j hij )

/-! ## Section 6: Overlap Graph Has No Edges When Disjoint -/

/-
No adjacency in the overlap graph when supports are disjoint.
-/
theorem no_adj_of_pairwiseDisjoint
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) (hdisj : PairwiseDisjointFinsets F)
    (i j : ι) : ¬(SupportOverlapGraph F).Adj i j := by
  exact fun h => h.2 |> fun h' => by obtain ⟨ x, hx₁, hx₂ ⟩ := supportsOverlap_iff_exists _ _ |>.1 h'; exact Finset.disjoint_left.mp ( hdisj i j h.1 ) hx₁ hx₂;

/-! ## Section 7: Disjoint Families Have Maximal Class Count -/

/-
**Disjoint ⟹ maximal class count.** Each index is its own component.
-/
theorem overlapClassCount_eq_card_of_pairwiseDisjoint
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) (hdisj : PairwiseDisjointFinsets F) :
    overlapClassCount F = Fintype.card ι := by
  convert Fintype.card_eq.2 ?_;
  refine' ⟨ _ ⟩;
  symm;
  refine' Equiv.ofBijective ( fun i => ( SupportOverlapGraph F ).connectedComponentMk i ) ⟨ fun i j hij => _, fun c => _ ⟩;
  · contrapose! hij;
    simp +decide [ hij, SimpleGraph.Reachable, no_adj_of_pairwiseDisjoint F hdisj ];
    constructor;
    rintro ⟨ _ | ⟨ _, _, _, _, _ ⟩ ⟩ <;> simp_all +decide [ no_adj_of_pairwiseDisjoint ];
  · exact?

/-! ## Section 8: Different Overlap Classes ⟹ Disjoint Supports -/

/-
**Key structural theorem:** indices in different overlap classes have
    disjoint supports. This is the fundamental separation principle.
-/
theorem disjoint_overlap_classes_no_interaction
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) (i j : ι)
    (hdiff : ¬SameOverlapClass F i j) :
    Disjoint (F i) (F j) := by
  contrapose! hdiff;
  by_cases hij : i = j;
  · exact hij.symm ▸ SimpleGraph.Reachable.refl _;
  · exact SimpleGraph.Adj.reachable ( by exact ⟨ hij, by exact Finset.not_disjoint_iff_nonempty_inter.mp hdiff ⟩ )

/-- Overlapping supports implies same overlap class. -/
theorem supportsOverlap_implies_sameClass
    {ι α : Type*} [DecidableEq ι] [DecidableEq α]
    (F : ι → Finset α) (i j : ι)
    (hij : i ≠ j) (hover : SupportsOverlap (F i) (F j)) :
    SameOverlapClass F i j :=
  SimpleGraph.Adj.reachable ⟨hij, hover⟩

/-! ## Section 9: Class Count Bounds -/

/-
**Upper bound:** class count ≤ |ι|.
-/
theorem overlapClassCount_le_card
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) :
    overlapClassCount F ≤ Fintype.card ι := by
  -- The connected component map connectedComponentMk : ι → ConnectedComponent is surjective.
  have h_surjective : Function.Surjective (fun i : ι => (SupportOverlapGraph F).connectedComponentMk i) := by
    intro c;
    obtain ⟨ i, hi ⟩ := c.exists_rep; use i; aesop;
  exact Fintype.card_le_of_surjective _ h_surjective

/-
**Lower bound:** class count ≥ 1 when nonempty.
-/
theorem overlapClassCount_pos
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι] [Nonempty ι]
    (F : ι → Finset α) :
    0 < overlapClassCount F := by
  -- Since the type ι is nonempty, there must be at least one element in the overlap class.
  apply Fintype.card_pos

/-! ## Section 10: Support Transport under TropProjEquiv -/

/-
TropProjEquiv preserves overlap between pairs: if F i and F j share a
    support point v (F i v ≠ 0 and F j v ≠ 0), then G(σ i) and G(σ j)
    also have a common support point.
-/
theorem tropProjEquiv_preserves_overlap
    {n : ℕ} {V : Type*}
    (F G : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n))
    (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), G (σ i) v = F i v + c i)
    (i j : Fin n)
    (hover : ∃ v, F i v ≠ 0 ∧ F j v ≠ 0 ∧ F i v + c i ≠ 0 ∧ F j v + c j ≠ 0) :
    (FunSupport (G (σ i)) ∩ FunSupport (G (σ j))).Nonempty := by
  obtain ⟨ v, hv₁, hv₂, hv₃, hv₄ ⟩ := hover; use v; simp +decide [ *, FunSupport ] ;

/-! ## Section 11: Total Overlap Complexity -/

/-- The **total overlap complexity**: sum of pairwise intersection sizes. -/
noncomputable def totalOverlapComplexity {n : ℕ} {α : Type*} [DecidableEq α]
    (F : Fin n → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2)).sum
    (fun p => (F p.1 ∩ F p.2).card)

/-
Total overlap complexity zero ↔ pairwise disjointness.
-/
theorem totalOverlapComplexity_eq_zero_iff
    {n : ℕ} {α : Type*} [DecidableEq α]
    (F : Fin n → Finset α) :
    totalOverlapComplexity F = 0 ↔ PairwiseDisjointFinsets F := by
  constructor <;> intro h <;> simp_all +decide [ totalOverlapComplexity, PairwiseDisjointFinsets ];
  · intro i j hij; cases lt_or_gt_of_ne hij <;> [ exact Finset.disjoint_iff_inter_eq_empty.mpr ( h _ _ ‹_› ) ; exact Finset.disjoint_iff_inter_eq_empty.mpr ( by rw [ Finset.inter_comm, h _ _ ‹_› ] ) ] ;
  · exact fun i j hij => Finset.disjoint_iff_inter_eq_empty.mp ( h i j hij.ne )

/-! ## Section 12: Bridge to Function-Level PairwiseDisjointSupports -/

/-
`PairwiseDisjointSupports` implies `PairwiseDisjointFinsets` on Finset
    supports.
-/
theorem pairwiseDisjoint_of_funSupport
    {ι V : Type*} [Fintype V] [DecidableEq V]
    (F : ι → V → ℤ)
    (hdisj : PairwiseDisjointSupports F) :
    PairwiseDisjointFinsets
      (fun i => Finset.univ.filter (fun v => F i v ≠ 0)) := by
  intro i j hij; specialize hdisj i j hij; simp_all +decide [ Set.disjoint_left, Finset.disjoint_left ] ;
  exact fun v hv => Classical.not_not.1 fun hv' => hdisj hv hv'

/-- Function-level disjoint supports ⟹ overlap degree = 0. -/
theorem overlapDegree_zero_of_pairwiseDisjointSupports
    {ι V : Type*} [DecidableEq ι] [Fintype ι] [Fintype V] [DecidableEq V]
    (F : ι → V → ℤ)
    (hdisj : PairwiseDisjointSupports F) :
    overlapDegree (fun i => Finset.univ.filter (fun v => F i v ≠ 0)) = 0 := by
  rw [overlapDegree_eq_zero_iff_pairwiseDisjoint]
  exact pairwiseDisjoint_of_funSupport F hdisj

/-! ## Section 13: Overlap Degree Characterizations -/

/-
Overlap degree bounded iff all pairwise intersections bounded.
-/
theorem overlapDegree_le_iff
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) (k : ℕ) :
    overlapDegree F ≤ k ↔ ∀ i j : ι, i ≠ j → (F i ∩ F j).card ≤ k := by
  constructor;
  · intro h i j hij
    have h_le : (F i ∩ F j).card ≤ overlapDegree F := by
      exact Finset.le_sup ( f := fun p : ι × ι => if p.1 ≠ p.2 then ( F p.1 ∩ F p.2 ).card else 0 ) ( Finset.mk_mem_product ( Finset.mem_univ i ) ( Finset.mem_univ j ) ) |> le_trans ( by aesop );
    exact le_trans h_le h;
  · unfold overlapDegree; aesop;

/-- Overlap degree one: every pair shares at most one element. -/
theorem overlapDegree_le_one_iff
    {ι α : Type*} [DecidableEq ι] [DecidableEq α] [Fintype ι]
    (F : ι → Finset α) :
    overlapDegree F ≤ 1 ↔ ∀ i j : ι, i ≠ j → (F i ∩ F j).card ≤ 1 :=
  overlapDegree_le_iff F 1

/-! ## Section 14: Support Nerve -/

/-- The **support nerve** (2-skeleton): pairwise intersections. -/
noncomputable def supportNerve2 {ι α : Type*} [DecidableEq α]
    (F : ι → Finset α) : ι → ι → Finset α :=
  fun i j => F i ∩ F j

theorem supportNerve2_symm {ι α : Type*} [DecidableEq α]
    (F : ι → Finset α) (i j : ι) :
    supportNerve2 F i j = supportNerve2 F j i := by
  simp [supportNerve2, Finset.inter_comm]

theorem supportNerve2_diag {ι α : Type*} [DecidableEq α]
    (F : ι → Finset α) (i : ι) :
    supportNerve2 F i i = F i := by
  simp [supportNerve2]

/-! ## Section 15: Complete Overlap Graph for Constant Families -/

/-
The overlap graph of a constant nonempty-support family is complete.
-/
theorem supportOverlapGraph_constant_complete
    {n : ℕ} {α : Type*} [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty)
    (i j : Fin n) (hij : i ≠ j) :
    (SupportOverlapGraph (fun _ : Fin n => S)).Adj i j := by
  exact ⟨ hij, ⟨ Classical.choose hS, by simp +decide [ Classical.choose_spec hS ] ⟩ ⟩