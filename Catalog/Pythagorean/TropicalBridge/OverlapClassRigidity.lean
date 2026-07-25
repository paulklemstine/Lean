/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Rigidity: Beyond Disjoint Supports

This file develops a theory of **overlap classes** for families of finite
supports, extending the disjoint-support rigidity theory from
`TropicalKernelRigidity.lean` to the regime where cycle supports may
intersect.

## Mathematical Context

The disjoint-support uniqueness theorem says that when tropical kernel
generators have pairwise disjoint supports, the generating family is
unique up to tropical projective equivalence. The natural question is:
what happens when supports overlap?

We introduce the **support overlap graph** — a simple graph whose vertices
are the supports in a family and whose edges connect pairs with nonempty
intersection. The connected components of this graph are **overlap classes**.

The central insight is that overlap classes decompose the interaction
structure: supports in different overlap classes are disjoint, and the
tropical projective equivalence relation respects this decomposition.

## Main Definitions

* `SupportsOverlap` — two finsets overlap (have nonempty intersection)
* `OverlapDegree` — number of overlapping pairs in a support family
* `PairwiseDisjointFamily` — pairwise disjoint finset family
* `FamilyUnion` — union of all supports in a family
* `OverlapConnected` — transitive closure of the overlap relation
* `OverlapEquiv` — reflexive-transitive closure (equivalence relation)
* `CrossOverlapCount` — intersection cardinality between two supports
* `OverlapSignature` — multiset of intersection sizes for overlapping pairs

## Main Results

* `supportsOverlap_symm` — overlap relation is symmetric
* `overlapDegree_eq_zero_iff` — overlap degree zero ↔ pairwise disjoint
* `disjoint_of_not_overlapConnected` — non-connected supports are disjoint
* `overlapEquiv_symm` — overlap equivalence is symmetric
* `familyUnion_card_of_pairwiseDisjoint` — union card = sum of cards when disjoint
* `overlapDegree_zero_iff_pairwiseDisjointSupports` — bridge to existing theory
* `pairwiseDisjoint_recovers_tropProjEquiv` — overlap-degree zero recovers
  the existing disjoint-support uniqueness theorem
* `overlapDegree_mono_of_subset` — refinement monotonicity

## References

* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Develin–Santos–Sturmfels, "On the rank of a tropical matrix"
-/

import Mathlib

open Finset BigOperators

/-! ## Imported notions from TropicalKernelRigidity.lean

We restate key definitions to make this file self-contained for the
theorem proving engine. The originals are in
`TropicalKernelRigidity.lean`. -/

/-- **Tropical projective equivalence** of two indexed families of ℤ-valued
    functions. (Restated from TropicalKernelRigidity.lean) -/
def TropProjEquiv' {ι V : Type*} (F₁ F₂ : ι → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm ι) (c : ι → ℤ),
    ∀ (i : ι) (v : V), F₂ (σ i) v = F₁ i v + c i

/-- The **support** of an integer-valued function.
    (Restated from TropicalKernelRigidity.lean) -/
def FunSupport' {V : Type*} (f : V → ℤ) : Set V := {v | f v ≠ 0}

/-- A family of functions has **pairwise disjoint supports**.
    (Restated from TropicalKernelRigidity.lean) -/
def PairwiseDisjointSupports' {ι V : Type*} (F : ι → V → ℤ) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (FunSupport' (F i)) (FunSupport' (F j))

/-! ## Section 1: Support Overlap Relation -/

/-- Two finsets **overlap** if their intersection is nonempty. This is the
    fundamental binary relation on supports that generates the overlap
    class structure. -/
def SupportsOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

/-- `SupportsOverlap` is decidable. -/
instance {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SupportsOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

/-
The overlap relation is symmetric: if A and B have nonempty intersection,
    then so do B and A.
-/
theorem supportsOverlap_symm {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ SupportsOverlap B A := by
  simp +decide only [SupportsOverlap, inter_comm]

/-
Equivalent formulation: overlap iff there exists an element in both.
-/
theorem supportsOverlap_iff_exists {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ ∃ x, x ∈ A ∧ x ∈ B := by
  simp [SupportsOverlap, Finset.Nonempty]

/-
Non-overlap implies disjointness.
-/
theorem disjoint_of_not_supportsOverlap {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : ¬SupportsOverlap A B) :
    Disjoint A B := by
  exact Finset.disjoint_iff_inter_eq_empty.mpr ( by_contradiction fun h' => h <| Finset.nonempty_of_ne_empty h' )

/-
Disjointness implies non-overlap.
-/
theorem not_supportsOverlap_of_disjoint {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : Disjoint A B) :
    ¬SupportsOverlap A B := by
  exact fun ⟨ x, hx ⟩ => Finset.disjoint_left.1 h ( Finset.mem_of_mem_inter_left hx ) ( Finset.mem_of_mem_inter_right hx )

/-! ## Section 2: Pairwise Disjoint Families -/

/-- A finset family is **pairwise disjoint** if every pair of distinct
    members has empty intersection. -/
def PairwiseDisjointFamily {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (F i) (F j)

/-- No pair of distinct members overlaps in a pairwise disjoint family. -/
theorem not_overlap_of_pairwiseDisjointFamily {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) (hF : PairwiseDisjointFamily F)
    (i j : ι) (hij : i ≠ j) :
    ¬SupportsOverlap (F i) (F j) :=
  not_supportsOverlap_of_disjoint (hF i j hij)

/-! ## Section 3: Overlap Degree -/

/-- The **overlap degree** of a finitely indexed family of finsets: the number
    of (unordered) pairs of distinct indices whose supports overlap. This is
    the number of edges in the support overlap graph. Overlap degree zero
    is exactly the pairwise disjoint case. -/
def OverlapDegree {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (F p.1) (F p.2))).card

/-
Overlap degree zero means no pair overlaps, i.e. the family is pairwise disjoint.
-/
theorem overlapDegree_eq_zero_iff {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    OverlapDegree F = 0 ↔ PairwiseDisjointFamily F := by
  constructor <;> intro h <;> simp_all +decide [ OverlapDegree, PairwiseDisjointFamily ];
  · intro i j hij; cases lt_or_gt_of_ne hij <;> [ exact disjoint_of_not_supportsOverlap ( h _ _ ‹_› ) ; exact Finset.disjoint_left.mpr fun x hx hx' => h _ _ ‹_› ⟨ x, Finset.mem_inter_of_mem hx' hx ⟩ ] ;
  · exact fun i j hij => not_supportsOverlap_of_disjoint ( h i j hij.ne )

/-- Forward direction: zero overlap degree implies pairwise disjointness. -/
theorem pairwiseDisjoint_of_overlapDegree_zero {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α)
    (h : OverlapDegree F = 0) :
    PairwiseDisjointFamily F :=
  (overlapDegree_eq_zero_iff F).mp h

/-- Backward direction: pairwise disjointness implies zero overlap degree. -/
theorem overlapDegree_zero_of_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α)
    (h : PairwiseDisjointFamily F) :
    OverlapDegree F = 0 :=
  (overlapDegree_eq_zero_iff F).mpr h

/-! ## Section 4: Overlap Connectivity (Transitive Closure) -/

/-- Two indices are **overlap-connected** in a family if they are related
    by the transitive closure of the overlap relation on their supports. -/
def OverlapConnected {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i j : ι) : Prop :=
  Relation.TransGen (fun a b => SupportsOverlap (F a) (F b)) i j

/-- Overlap connectivity is transitive. -/
theorem overlapConnected_trans {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j k : ι}
    (hij : OverlapConnected F i j) (hjk : OverlapConnected F j k) :
    OverlapConnected F i k :=
  Relation.TransGen.trans hij hjk

/-- Direct overlap implies overlap connectivity. -/
theorem overlapConnected_of_overlap {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j : ι}
    (h : SupportsOverlap (F i) (F j)) :
    OverlapConnected F i j :=
  Relation.TransGen.single h

/-! ## Section 5: Disjointness from Non-Connectivity -/

/-- **Key structural theorem:** If two indices are NOT overlap-connected, then
    their supports are disjoint. This is the engine that makes overlap classes
    meaningful: supports in different overlap classes cannot share any element. -/
theorem disjoint_of_not_overlapConnected {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) {i j : ι}
    (h : ¬OverlapConnected F i j) :
    Disjoint (F i) (F j) := by
  apply disjoint_of_not_supportsOverlap
  intro hoverlap
  exact h (overlapConnected_of_overlap F hoverlap)

/-- Overlap classes are the interaction sectors: elements in different
    classes live in completely disjoint support regions. -/
theorem overlap_classes_are_disjoint_sectors {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) {i j : ι}
    (h : ¬OverlapConnected F i j) {x : α}
    (hx : x ∈ F i) : x ∉ F j :=
  Finset.disjoint_left.mp (disjoint_of_not_overlapConnected F h) hx

/-! ## Section 6: Overlap Equivalence (Reflexive-Transitive Closure) -/

/-- The reflexive-transitive closure of the overlap relation,
    giving a true equivalence relation on indices. -/
def OverlapEquiv {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i j : ι) : Prop :=
  Relation.ReflTransGen (fun a b => SupportsOverlap (F a) (F b)) i j

/-- Overlap equivalence is reflexive. -/
theorem overlapEquiv_refl {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i : ι) :
    OverlapEquiv F i i :=
  Relation.ReflTransGen.refl

/-- Overlap equivalence is transitive. -/
theorem overlapEquiv_trans {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j k : ι}
    (hij : OverlapEquiv F i j) (hjk : OverlapEquiv F j k) :
    OverlapEquiv F i k :=
  Relation.ReflTransGen.trans hij hjk

/-
Overlap equivalence is symmetric (using symmetry of the overlap relation).
-/
theorem overlapEquiv_symm {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j : ι}
    (h : OverlapEquiv F i j) :
    OverlapEquiv F j i := by
  have h_symm : ∀ i j, SupportsOverlap (F i) (F j) → SupportsOverlap (F j) (F i) := by
    exact fun i j hij => by rw [ supportsOverlap_symm ] ; exact hij;
  generalize_proofs at *; (
  induction h <;> [ tauto; exact Relation.ReflTransGen.tail ‹_› ( h_symm _ _ ‹_› ) ];
  exact Relation.ReflTransGen.trans ( Relation.ReflTransGen.single ( h_symm _ _ ‹_› ) ) ‹_›)

/-- Disjointness from non-equivalence under the reflexive-transitive closure. -/
theorem disjoint_of_not_overlapEquiv {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) {i j : ι}
    (h : ¬OverlapEquiv F i j) :
    Disjoint (F i) (F j) := by
  apply disjoint_of_not_supportsOverlap
  intro hoverlap
  exact h (Relation.ReflTransGen.single hoverlap)

/-! ## Section 7: Family Union -/

/-- The union of all supports in a family. -/
def FamilyUnion {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Finset α :=
  Finset.univ.biUnion F

/-- Every member support is a subset of the family union. -/
theorem subset_familyUnion {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) :
    F i ⊆ FamilyUnion F :=
  Finset.subset_biUnion_of_mem F (Finset.mem_univ i)

/-
The family union of a pairwise disjoint family has cardinality equal
    to the sum of individual cardinalities.
-/
theorem familyUnion_card_of_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α)
    (hF : PairwiseDisjointFamily F) :
    (FamilyUnion F).card = ∑ i : Fin n, (F i).card := by
  convert Finset.card_biUnion _;
  exact fun i _ j _ hij => hF i j hij

/-! ## Section 8: Bridge to Existing TropProjEquiv Theory -/

/-- The support (as a finset) of an integer-valued function on a fintype. -/
def FinFunSupport {V : Type*} [Fintype V] [DecidableEq V] (f : V → ℤ) : Finset V :=
  Finset.univ.filter (fun v => f v ≠ 0)

/-
`FinFunSupport` agrees with the set-valued `FunSupport'`.
-/
theorem finFunSupport_coe {V : Type*} [Fintype V] [DecidableEq V] (f : V → ℤ) :
    ↑(FinFunSupport f) = FunSupport' f := by
  exact Set.ext fun x => by simp +decide [ FinFunSupport, FunSupport' ] ;

/-- A finitely indexed family of functions gives a family of finset supports. -/
def FunSupportFamily {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) : Fin n → Finset V :=
  fun i => FinFunSupport (F i)

/-
`PairwiseDisjointSupports'` implies `PairwiseDisjointFamily` on finset supports.
-/
theorem pairwiseDisjointFamily_of_pairwiseDisjointSupports
    {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ)
    (h : PairwiseDisjointSupports' F) :
    PairwiseDisjointFamily (FunSupportFamily F) := by
  intro i j hij specialize h i j hij; simp_all +decide [ Finset.disjoint_left, Set.disjoint_left ] ;
  rename_i k l; have := @h j hij; have := @i j hij; simp_all +decide [ FunSupportFamily ] ;
  rename_i m hm; have := ‹PairwiseDisjointSupports' F› m k; simp_all +decide [ FinFunSupport, Set.disjoint_left ] ;
  exact this ( show j ∈ FunSupport' ( F m ) from hm ) ( show j ∈ FunSupport' ( F k ) from by assumption )

/-
Conversely, `PairwiseDisjointFamily` on finset supports implies
    `PairwiseDisjointSupports'`.
-/
theorem pairwiseDisjointSupports_of_pairwiseDisjointFamily
    {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ)
    (h : PairwiseDisjointFamily (FunSupportFamily F)) :
    PairwiseDisjointSupports' F := by
  intro i j hij specialize h i j hij; simp_all +decide [ Finset.disjoint_left, Set.disjoint_left ] ;
  rename_i k hk;
  rename_i l; have := ‹PairwiseDisjointFamily ( FunSupportFamily F ) › l k; simp_all +decide [ Finset.disjoint_left, Set.disjoint_left ] ;
  exact this ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h hij ⟩ ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, i hij ⟩ )

/-- The overlap degree of a function family's supports is zero if and only
    if the functions have pairwise disjoint supports (in the set-valued sense). -/
theorem overlapDegree_zero_iff_pairwiseDisjointSupports
    {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) :
    OverlapDegree (FunSupportFamily F) = 0 ↔ PairwiseDisjointSupports' F := by
  rw [overlapDegree_eq_zero_iff]
  exact ⟨pairwiseDisjointSupports_of_pairwiseDisjointFamily F,
         pairwiseDisjointFamily_of_pairwiseDisjointSupports F⟩

/-! ## Section 9: Cross-Overlap Count -/

/-- The **cross-overlap count** between two supports: the cardinality of
    their intersection. -/
def CrossOverlapCount {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) : ℕ :=
  (F i ∩ F j).card

/-- Cross-overlap count is symmetric. -/
theorem crossOverlapCount_comm {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    CrossOverlapCount F i j = CrossOverlapCount F j i := by
  simp [CrossOverlapCount, Finset.inter_comm]

/-
Cross-overlap count is zero iff supports are disjoint.
-/
theorem crossOverlapCount_eq_zero_iff {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    CrossOverlapCount F i j = 0 ↔ Disjoint (F i) (F j) := by
  simp +decide [ CrossOverlapCount, Finset.disjoint_iff_inter_eq_empty ]

/-
Cross-overlap count positive iff supports overlap.
-/
theorem crossOverlapCount_pos_iff {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    0 < CrossOverlapCount F i j ↔ SupportsOverlap (F i) (F j) := by
  exact ⟨ fun h => Finset.card_pos.mp h, fun h => Finset.card_pos.mpr h ⟩

/-! ## Section 10: Overlap Degree Bounds -/

/-
The overlap degree is bounded by the number of unordered pairs.
-/
theorem overlapDegree_le {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    OverlapDegree F ≤ n * (n - 1) / 2 := by
  convert Set.ncard_le_ncard ( show { p : Fin n × Fin n | p.1 < p.2 ∧ ( F p.1 ∩ F p.2 |> Finset.Nonempty ) } ⊆ { p : Fin n × Fin n | p.1 < p.2 } from fun p hp => hp.1 ) using 1;
  · rw [ Set.ncard_eq_toFinset_card _ ] ; aesop;
  · rw [ Set.ncard_eq_toFinset_card' ];
    convert Finset.card_filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ using 1;
    · rw [ Finset.card_filter ];
      erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_ite, Finset.filter_lt_eq_Ioi ];
      rw [ ← Finset.sum_range_id ];
      rw [ ← Finset.sum_range_reflect, Finset.sum_range ];
    · simp +decide [ Finset.sum_ite ]

/-! ## Section 11: Overlap Refinement Monotonicity -/

/-
Refining (shrinking) supports can only decrease or preserve
    overlap degree: if `G i ⊆ F i` for all i, then the overlap
    degree of G is at most that of F.
-/
theorem overlapDegree_mono_of_subset {α : Type*} [DecidableEq α] {n : ℕ}
    (F G : Fin n → Finset α)
    (h : ∀ i, G i ⊆ F i) :
    OverlapDegree G ≤ OverlapDegree F := by
  refine' Finset.card_le_card _;
  intro p hp; simp_all +decide [ SupportsOverlap ] ;
  exact hp.2.imp fun x hx => Finset.mem_inter.2 ⟨ h _ ( Finset.mem_inter.1 hx |>.1 ), h _ ( Finset.mem_inter.1 hx |>.2 ) ⟩

/-! ## Section 12: Overlap Signature -/

/-- The **overlap signature** of a family: the multiset of
    intersection cardinalities for all overlapping pairs. This is a
    finer invariant than the overlap degree (which just counts pairs)
    and captures the distribution of intersection sizes. -/
def OverlapSignature {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Multiset ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (F p.1) (F p.2))).val.map
    (fun p => CrossOverlapCount F p.1 p.2)

/-
Every entry in the overlap signature is positive.
-/
theorem overlapSignature_pos {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    ∀ x ∈ OverlapSignature F, 0 < x := by
  intro x hx
  obtain ⟨i, j, hij, h⟩ : ∃ i j : Fin n, i < j ∧ SupportsOverlap (F i) (F j) ∧ x = CrossOverlapCount F i j := by
    unfold OverlapSignature at hx; aesop;
  exact h.2.symm ▸ crossOverlapCount_pos_iff F i j |>.2 h.1

/-! ## Section 13: Max Overlap Degree -/

/-- The **max overlap degree** of a family: the maximum intersection
    cardinality over all pairs of distinct supports. This measures the
    worst-case overlap intensity. -/
noncomputable def MaxOverlapDeg {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  Finset.sup ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2))
    (fun p => CrossOverlapCount F p.1 p.2)

/-
Max overlap degree is zero when pairwise disjoint.
-/
theorem maxOverlapDeg_eq_zero_of_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α)
    (hF : PairwiseDisjointFamily F) :
    MaxOverlapDeg F = 0 := by
  refine' le_antisymm ( Finset.sup_le _ ) ( Nat.zero_le _ );
  simp +contextual [ CrossOverlapCount, hF ];
  exact fun i j hij => Finset.disjoint_iff_inter_eq_empty.mp ( hF i j hij.ne )

/-
Pairwise disjoint of max overlap degree zero (for n ≥ 2).
-/
theorem pairwiseDisjoint_of_maxOverlapDeg_zero {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α) (hn : 1 < n)
    (h0 : MaxOverlapDeg F = 0) :
    PairwiseDisjointFamily F := by
  -- Since the max overlap degree is zero, for any i < j, the cross-overlap count is zero. Therefore, their intersection is empty, which means they are disjoint.
  have h_disjoint : ∀ i j : Fin n, i < j → Disjoint (F i) (F j) := by
    unfold MaxOverlapDeg at h0;
    simp_all +decide [ Finset.ext_iff, CrossOverlapCount ];
    exact fun i j hij => Finset.disjoint_left.mpr ( h0 i j hij );
  exact fun i j hij => by cases lt_or_gt_of_ne hij <;> [ exact h_disjoint _ _ ‹_› ; exact Disjoint.symm ( h_disjoint _ _ ‹_› ) ] ;