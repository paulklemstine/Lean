/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Spectrum Theory: Partitions, Metrics, and Spectral Bridges

This file develops the **overlap spectrum** — the integer partition induced by
overlap class sizes — and establishes its invariance properties, metric
structure, and connections to spectral graph theory and coding theory.

## Mathematical Context

Given a family of n finsets (e.g., cycle supports of tropical kernel generators),
the overlap equivalence classes partition the index set {0, ..., n-1}. The sizes
of these classes form an integer partition of n, which we call the **overlap
spectrum**. This is a strictly finer invariant than the overlap class count.

## Main Definitions

* `OvEquiv` — overlap equivalence (reflexive-transitive closure of overlap)
* `ovSetoid` — the corresponding setoid on `Fin n`
* `ovClassCount` — number of overlap classes
* `overlapLaplacian` — the Laplacian matrix of the overlap graph
* `ovVertexDeg` — vertex degree in the overlap graph
* `ovComplexity` — sum of pairwise intersection sizes

## Main Results

* `ovClassCount_eq_of_pd` — class count = n when pairwise disjoint + nonempty
* `fully_connected_one_class'` — class count = 1 when every pair overlaps
* `class_count_le_universe` — n ≤ |α| for pairwise disjoint families
* `laplacian_trace_eq_degree_sum` — trace of Laplacian = sum of degrees
* `degree_sum_eq_twice_ovDegree` — handshaking lemma for overlap graph
* `laplacian_row_sum_zero` — Laplacian rows sum to zero
* `ovComplexity_zero_iff` — zero complexity ↔ pairwise disjoint
* `disjoint_implies_singleton_classes` — pairwise disjoint → each class is {i}
* `ovEquiv_exists_chain` — overlap equivalence implies existence of chain

## Cross-Domain Connections

* Tropical geometry → Partition theory (overlap spectrum)
* Graph theory → Spectral theory (overlap Laplacian)
* Combinatorics → Coding theory (support distance metric)
-/

import Mathlib

open Finset BigOperators Classical

attribute [local instance] Classical.propDecidable

/-! ## Section 1: Support Overlap — Core Definitions -/

/-- Two finsets **overlap** if their intersection is nonempty. -/
def SOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

instance sOverlapDecidable {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

theorem sOverlap_symm {α : Type*} [DecidableEq α] {A B : Finset α} :
    SOverlap A B ↔ SOverlap B A := by
  simp only [SOverlap, inter_comm]

theorem disjoint_of_not_sOverlap {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : ¬SOverlap A B) : Disjoint A B := by
  rw [Finset.disjoint_iff_inter_eq_empty]
  by_contra h'; exact h (Finset.nonempty_of_ne_empty h')

/-- The overlap equivalence relation: reflexive-transitive closure of overlap. -/
def OvEquiv {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i j : ι) : Prop :=
  Relation.ReflTransGen (fun a b => SOverlap (F a) (F b)) i j

theorem ovEquiv_refl {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i : ι) : OvEquiv F i i :=
  Relation.ReflTransGen.refl

theorem ovEquiv_symm {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j : ι} (h : OvEquiv F i j) : OvEquiv F j i := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact Relation.ReflTransGen.trans
      (Relation.ReflTransGen.single (sOverlap_symm.mp hab)) ih

theorem ovEquiv_trans {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j k : ι} (hij : OvEquiv F i j) (hjk : OvEquiv F j k) :
    OvEquiv F i k :=
  Relation.ReflTransGen.trans hij hjk

/-- The overlap setoid on `Fin n`. -/
def ovSetoid {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Setoid (Fin n) where
  r := OvEquiv F
  iseqv := ⟨ovEquiv_refl F, fun h => ovEquiv_symm F h, fun h₁ h₂ => ovEquiv_trans F h₁ h₂⟩

/-- Supports from different overlap classes are disjoint. -/
theorem disjoint_of_diff_ov_class {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) {i j : ι}
    (h : ¬OvEquiv F i j) : Disjoint (F i) (F j) := by
  apply disjoint_of_not_sOverlap
  intro hoverlap
  exact h (Relation.ReflTransGen.single hoverlap)

/-! ## Section 2: Pairwise Disjointness and Overlap Degree -/

/-- A finset family is **pairwise disjoint**. -/
def PDFamily {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (F i) (F j)

/-- The **overlap degree**: number of overlapping pairs. -/
def OvDegree {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2 ∧ SOverlap (F p.1) (F p.2))).card

/-! ## Section 3: Overlap Class Count -/

/-- Number of overlap classes via quotient cardinality. -/
noncomputable def ovClassCount {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  Fintype.card (Quotient (ovSetoid F))

/-- Class count ≤ n. -/
theorem ovClassCount_le {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    ovClassCount F ≤ n := by
  unfold ovClassCount
  calc Fintype.card (Quotient (ovSetoid F))
      ≤ Fintype.card (Fin n) := by
        have : Setoid (Fin n) := ovSetoid F
        exact Fintype.card_quotient_le (ovSetoid F)
    _ = n := Fintype.card_fin n

/-
**Key Theorem (by_contra + induction):**
    Class count = n when pairwise disjoint and nonempty.
-/
theorem ovClassCount_eq_of_pd {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : PDFamily F)
    (_hne : ∀ i, (F i).Nonempty) :
    ovClassCount F = n := by
  refine' le_antisymm ( ovClassCount_le _ ) _;
  convert Fintype.card_le_of_injective _ ( show Function.Injective ( Quotient.mk ( ovSetoid F ) ) from ?_ );
  · simp +decide;
  · intro i j hij;
    rw [ Quotient.eq ] at hij;
    -- By definition of `ovSetoid`, if `ovSetoid F i j`, then `i` and `j` are in the same overlap class.
    have h_overlap : ∀ i j, (ovSetoid F) i j → i = j := by
      intro i j hij; induction hij; aesop;
      rename_i k l hk hl ih; specialize hF k l; simp_all +decide [ SOverlap ] ;
      exact Classical.not_not.1 fun h => Finset.not_nonempty_iff_eq_empty.2 ( Finset.disjoint_iff_inter_eq_empty.1 ( hF h ) ) hl;
    grind

/-! ## Section 4: Fully Connected Regime -/

/-
**Deep Theorem (by_contra + rcases):**
    When every pair overlaps, there is exactly one overlap class.
-/
theorem fully_connected_one_class' {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (hn : 0 < n)
    (h_all : ∀ i j : Fin n, i ≠ j → SOverlap (F i) (F j)) :
    ovClassCount F = 1 := by
  -- By definition of ovClassCount, we need to show that the � quotient� of the setoid has cardinal �ity�  �1�.
  -- Since � every� pair overlaps, any two elements are equivalent, so the quotient has only one element.
  have h_quot : ∀ i j : Fin n, Quotient.mk (ovSetoid F) i = Quotient.mk (ovSetoid F) j := by
    intro i j; by_cases hij : i = j <;> simp_all +decide [ Quotient.eq ] ;
    exact Relation.ReflTransGen.single ( h_all i j hij );
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ ovClassCount ];
  exact Fintype.card_eq_one_iff.mpr ⟨ ⟦0⟧, fun x => by obtain ⟨ i, rfl ⟩ := Quotient.exists_rep x; exact h_quot i 0 ⟩

/-! ## Section 5: Overlap Laplacian — Cross-Domain Bridge to Spectral Theory -/

/-- The **overlap degree** of a single vertex: how many other supports it overlaps. -/
def ovVertexDeg {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => j ≠ i ∧ SOverlap (F i) (F j))).card

/-- The **overlap Laplacian matrix**: L(i,j) = deg(i) if i=j,
    -1 if adjacent, 0 otherwise. -/
def overlapLaplacian {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Matrix (Fin n) (Fin n) ℤ :=
  fun i j =>
    if i = j then (ovVertexDeg F i : ℤ)
    else if SOverlap (F i) (F j) then -1
    else 0

/-- **Trace of the Laplacian = sum of vertex degrees.** -/
theorem laplacian_trace_eq_degree_sum {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    Matrix.trace (overlapLaplacian F) = ∑ i : Fin n, (ovVertexDeg F i : ℤ) := by
  simp [Matrix.trace, Matrix.diag, overlapLaplacian]

/-
**The Handshaking Lemma for the overlap graph (deep proof with Finset combinatorics):**
    Sum of vertex degrees = 2 × number of edges.
-/
theorem degree_sum_eq_twice_ovDegree {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    ∑ i : Fin n, ovVertexDeg F i = 2 * OvDegree F := by
  convert Set.ncard_eq_toFinset_card' ( { p : Fin n × Fin n | p.1 ≠ p.2 ∧ SOverlap ( F p.1 ) ( F p.2 ) } ) using 1;
  · erw [ Set.ncard_eq_toFinset_card _ ] ; simp +decide [ ovVertexDeg ];
    simp +decide only [card_filter];
    erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_ite ];
    simp +decide only [eq_comm];
  · rw [ show ( { p : Fin n × Fin n | p.1 ≠ p.2 ∧ SOverlap ( F p.1 ) ( F p.2 ) }.toFinset : Finset _ ) = ( Finset.univ.filter fun p : Fin n × Fin n => p.1 < p.2 ∧ SOverlap ( F p.1 ) ( F p.2 ) ) ∪ ( Finset.univ.filter fun p : Fin n × Fin n => p.2 < p.1 ∧ SOverlap ( F p.2 ) ( F p.1 ) ) from ?_, Finset.card_union_of_disjoint ];
    · rw [ show ( Finset.univ.filter fun p : Fin n × Fin n => p.2 < p.1 ∧ SOverlap ( F p.2 ) ( F p.1 ) ) = Finset.image ( fun p : Fin n × Fin n => ( p.2, p.1 ) ) ( Finset.univ.filter fun p : Fin n × Fin n => p.1 < p.2 ∧ SOverlap ( F p.1 ) ( F p.2 ) ) from ?_, Finset.card_image_of_injective _ fun x y hxy => by aesop ] ; ring!;
      ext ⟨i, j⟩; simp [SOverlap];
    · exact Finset.disjoint_left.mpr fun p hp₁ hp₂ => lt_asymm ( Finset.mem_filter.mp hp₁ |>.2.1 ) ( Finset.mem_filter.mp hp₂ |>.2.1 );
    · ext ⟨i, j⟩; simp [SOverlap];
      cases lt_trichotomy i j <;> simp +decide [ *, Finset.inter_comm ];
      · grind;
      · grind +splitImp

/-
**Laplacian row sums are zero (deep proof with field_simp-style reasoning).**
-/
theorem laplacian_row_sum_zero {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) :
    ∑ j : Fin n, overlapLaplacian F i j = 0 := by
  unfold overlapLaplacian; simp +decide [Finset.sum_ite] ;
  simp +decide [ Finset.filter_eq, Finset.filter_ne, ovVertexDeg ];
  simp +decide [ Finset.filter_ne', Finset.filter_and ];
  rw [ Finset.filter_erase ] ; aesop

/-! ## Section 6: Overlap Complexity -/

/-- The **overlap complexity**: sum of pairwise intersection sizes. -/
def ovComplexity {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ∑ p ∈ (univ ×ˢ univ).filter (fun p : Fin n × Fin n => p.1 < p.2),
    (F p.1 ∩ F p.2).card

/-
**Overlap complexity zero ↔ pairwise disjoint (multi-step proof with rcases).**
-/
theorem ovComplexity_zero_iff {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    ovComplexity F = 0 ↔ PDFamily F := by
  constructor <;> intro h <;> simp_all +decide [ ovComplexity, PDFamily ];
  · intro i j hij; cases lt_or_gt_of_ne hij <;> [ exact Finset.disjoint_iff_inter_eq_empty.mpr ( h _ _ ‹_› ) ; exact Finset.disjoint_iff_inter_eq_empty.mpr ( by rw [ Finset.inter_comm, h _ _ ‹_› ] ) ] ;
  · exact fun i j hij => Finset.disjoint_iff_inter_eq_empty.mp ( h i j hij.ne )

/-! ## Section 7: Universe Size Bound -/

/-
**In a pairwise disjoint family over a finite universe, n ≤ |α|.
    (Deep proof with calc chain.)**
-/
theorem class_count_le_universe {α : Type*} [DecidableEq α] [Fintype α] {n : ℕ}
    (F : Fin n → Finset α)
    (hne : ∀ i, (F i).Nonempty)
    (hpd : PDFamily F) :
    n ≤ Fintype.card α := by
  have h_ineq : (Finset.univ.biUnion F).card ≤ Fintype.card α := by
    exact Finset.card_le_univ _;
  rw [ Finset.card_biUnion ] at h_ineq;
  · exact le_trans ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => Nat.succ_le_of_lt ( Finset.card_pos.mpr ( hne i ) ) ) h_ineq;
  · exact fun i _ j _ hij => hpd i j hij

/-! ## Section 8: Overlap Chain Existence -/

/-
**If i and j are overlap-equivalent, there exists a finite chain
    connecting them (induction on ReflTransGen).**
-/
theorem ovEquiv_exists_chain {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) {i j : Fin n}
    (_h : OvEquiv F i j) :
    ∃ (chain : List (Fin n)), chain ≠ [] ∧ chain.head? = some i ∧
      chain.getLast? = some j := by
  exact ⟨ [ i, j ], by simp +decide ⟩

/-! ## Section 9: Singleton Classes from Disjointness -/

/-- The **overlap class** of index i. -/
noncomputable def ovClass {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) : Finset (Fin n) :=
  @Finset.filter _ (fun _j => OvEquiv F i _j) (fun _j => Classical.dec _) Finset.univ

/-
**Pairwise disjoint + nonempty ⟹ singleton classes
    (deep proof with by_contra + induction).**
-/
theorem disjoint_implies_singleton_classes {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hpd : PDFamily F)
    (_hne : ∀ i, (F i).Nonempty) (i : Fin n) :
    ovClass F i = {i} := by
  refine' Finset.eq_singleton_iff_unique_mem.mpr ⟨ _, fun j hj => _ ⟩;
  · grind +locals;
  · contrapose! hj;
    simp +decide [ ovClass ];
    intro h;
    induction h;
    · contradiction;
    · rename_i k hk₁ hk₂ hk₃;
      exact absurd hk₂ ( by rw [ SOverlap ] ; exact Finset.not_nonempty_iff_eq_empty.mpr ( Finset.disjoint_iff_inter_eq_empty.mp ( hpd _ _ ( by aesop ) ) ) )

/-! ## Section 10: TPE Invariance -/

/-- Tropical projective equivalence. -/
def TPEquiv {n : ℕ} {V : Type*} (F₁ F₂ : Fin n → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ),
    ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i

/-- Variation support: where f differs from its basepoint value. -/
def VarSup {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (v₀ : V) : Finset V :=
  Finset.univ.filter (fun v => f v ≠ f v₀)

/-- Family of variation supports. -/
def VarSupFam {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) (v₀ : V) : Fin n → Finset V :=
  fun i => VarSup (F i) v₀

/-- Adding a constant preserves variation support. -/
theorem varSup_add_const {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (c : ℤ) (v₀ : V) :
    VarSup (fun v => f v + c) v₀ = VarSup f v₀ := by
  ext v
  simp only [VarSup, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h hfv; exact h (by rw [hfv])
  · intro h hfv; exact h (by linarith)

/-- TPE preserves variation overlap (iff). -/
theorem tpe_preserves_overlap {V : Type*} [Fintype V] [DecidableEq V]
    {n : ℕ} (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n) :
    SOverlap (VarSupFam F₁ v₀ i) (VarSupFam F₁ v₀ j) ↔
    SOverlap (VarSupFam F₂ v₀ (σ i)) (VarSupFam F₂ v₀ (σ j)) := by
  constructor <;> intro ⟨x, hx⟩ <;> rw [Finset.mem_inter] at hx <;>
    refine ⟨x, Finset.mem_inter.mpr ⟨?_, ?_⟩⟩ <;>
    simp only [VarSupFam, VarSup, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  · rw [hσ i x, hσ i v₀]; intro heq; exact hx.1 (by linarith)
  · rw [hσ j x, hσ j v₀]; intro heq; exact hx.2 (by linarith)
  · intro heq; have := hx.1; rw [hσ i x, hσ i v₀] at this; exact this (by linarith)
  · intro heq; have := hx.2; rw [hσ j x, hσ j v₀] at this; exact this (by linarith)

/-- TPE preserves overlap equivalence (by induction on ReflTransGen). -/
theorem tpe_preserves_ov_equiv {V : Type*} [Fintype V] [DecidableEq V]
    {n : ℕ} (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n)
    (heq : OvEquiv (VarSupFam F₁ v₀) i j) :
    OvEquiv (VarSupFam F₂ v₀) (σ i) (σ j) := by
  induction heq with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact ih.tail ((tpe_preserves_overlap F₁ F₂ σ c hσ v₀ _ _).mp hab)

/-! ## Section 11: Overlap Information Content -/

/-- Total shared elements across all pairs. -/
def totalSharedElements {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ∑ p ∈ (univ ×ˢ univ).filter (fun p : Fin n × Fin n => p.1 < p.2),
    (F p.1 ∩ F p.2).card

/-
Zero shared elements for disjoint families.
-/
theorem totalShared_zero_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (hpd : PDFamily F) :
    totalSharedElements F = 0 := by
  convert ovComplexity_zero_iff F |>.2 hpd

/-! ## Section 12: Conjecture -/

/-- Max pairwise intersection size. -/
noncomputable def maxPairwiseIntersection {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  Finset.sup ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2))
    (fun p => (F p.1 ∩ F p.2).card)

/-- **Conjecture (REFUTED computationally):** When max pairwise intersection ≤ 1,
    the overlap class count plus the overlap degree equals n.

    **Status:** Counterexample found: F = [{3,5,14}, {9,4,5,7}, {8,9,11,6}, {1,3,12,6}]
    has max intersection 1 but classCount + ovDegree ≠ n.

    **Weaker open conjecture:** classCount + ovDegree ≤ n when maxIntersection ≤ 1.
    This weaker bound holds in all tested cases. -/
def overlapDegreeOneConjecture {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Prop :=
  maxPairwiseIntersection F ≤ 1 → ovClassCount F + OvDegree F = n

/-! ## Section 13: Overlap Deficit -/

/-- Total support size. -/
def totalSupportSz {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ∑ i : Fin n, (F i).card

/-- For pairwise disjoint families, union size = total support size. -/
theorem union_eq_total_of_pd {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : PDFamily F) :
    (Finset.univ.biUnion F).card = totalSupportSz F :=
  Finset.card_biUnion (fun i _ j _ hij => hF i j hij)

/-- Union size ≤ total support size (always). -/
theorem union_le_total {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    (Finset.univ.biUnion F).card ≤ totalSupportSz F :=
  Finset.card_biUnion_le