/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Conjecture: Beyond Disjoint Supports

This file develops the mathematical infrastructure for the **Overlap Class
Conjecture**, extending tropical kernel rigidity theory from the disjoint
case to the general overlapping regime.

## Novel Definitions

* `OverlapGraph` — the simple graph on indices where edges connect overlapping supports
* `OverlapComplexity` — sum of all pairwise intersection sizes
* `SupportInteractionMatrix` — the matrix of pairwise intersection sizes
* `peelElement` — family obtained by removing a shared element

## Main Results

* `overlap_class_count_eq_of_disjoint` — disjoint + nonempty ⟹ class count = n
* `overlapComplexity_eq_zero_iff` — zero complexity ⟺ pairwise disjoint
* `tpe_preserves_var_overlap` — TPE preserves variation support overlap (iff)
* `tpe_overlap_graph_iso` — TPE induces overlap graph isomorphism
* `peeling_reduces_complexity` — peeling reduces overlap complexity
* `fully_connected_one_class` — all-overlapping family has 1 class
* `supportDistance_of_disjoint` — Hamming distance for disjoint supports

## Cross-Domain Connections

* Tropical geometry → Coding theory (support interaction matrix, Hamming distance)
* Graph theory → Matroid theory (overlap classes refine cycle matroid)
-/

import Mathlib

open Finset BigOperators Classical

attribute [local instance] Classical.propDecidable

/-! ## Section 1: Core Definitions -/

/-- Two finsets **overlap** if their intersection is nonempty. -/
def SupportOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

instance supportOverlapDecidable {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SupportOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

theorem supportOverlap_symm {α : Type*} [DecidableEq α]
    {A B : Finset α} : SupportOverlap A B ↔ SupportOverlap B A := by
  simp only [SupportOverlap, inter_comm]

theorem disjoint_of_not_supportOverlap {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : ¬SupportOverlap A B) : Disjoint A B := by
  rw [Finset.disjoint_iff_inter_eq_empty]
  by_contra h'; exact h (Finset.nonempty_of_ne_empty h')

/-! ## Section 2: The Overlap Graph (NOVEL DEFINITION) -/

/-- The **overlap graph** of a support family: a simple graph on `Fin n` where
    two indices are adjacent iff their supports overlap. -/
def OverlapGraph {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : SimpleGraph (Fin n) where
  Adj i j := i ≠ j ∧ SupportOverlap (F i) (F j)
  symm := by intro i j ⟨hne, ho⟩; exact ⟨hne.symm, supportOverlap_symm.mp ho⟩
  loopless := Std.Irrefl.mk (fun a h => h.1 rfl)

instance overlapGraphDecRel {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : DecidableRel (OverlapGraph F).Adj :=
  fun _ _ => inferInstanceAs (Decidable (_ ∧ _))

/-- A pairwise disjoint family has an edgeless overlap graph. -/
theorem overlapGraph_eq_bot_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j)) :
    OverlapGraph F = ⊥ := by
  ext i j; constructor
  · intro ⟨hne, ⟨x, hx⟩⟩
    exact absurd (Finset.mem_inter.mp hx).2
      (Finset.disjoint_left.mp (hF i j hne) (Finset.mem_inter.mp hx).1)
  · simp

/-! ## Section 3: Overlap Complexity (NOVEL DEFINITION) -/

/-- The **overlap complexity**: sum of all pairwise intersection sizes. -/
def OverlapComplexity {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ∑ p ∈ (univ ×ˢ univ).filter (fun p : Fin n × Fin n => p.1 < p.2),
    (F p.1 ∩ F p.2).card

/-- Overlap complexity is zero iff the family is pairwise disjoint. -/
theorem overlapComplexity_eq_zero_iff {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    OverlapComplexity F = 0 ↔ ∀ i j : Fin n, i < j → Disjoint (F i) (F j) := by
  simp only [OverlapComplexity, Finset.sum_eq_zero_iff, Finset.mem_filter,
    Finset.mem_product, Finset.mem_univ, true_and]
  constructor
  · intro h i j hij
    have := h ⟨i, j⟩ hij
    rwa [Finset.card_eq_zero, ← Finset.disjoint_iff_inter_eq_empty] at this
  · intro h ⟨i, j⟩ hij
    rw [Finset.card_eq_zero, ← Finset.disjoint_iff_inter_eq_empty]
    exact h i j hij

/-- Overlap complexity is monotone under support inclusion. -/
theorem overlapComplexity_mono {α : Type*} [DecidableEq α] {n : ℕ}
    (F G : Fin n → Finset α) (h : ∀ i, G i ⊆ F i) :
    OverlapComplexity G ≤ OverlapComplexity F := by
  apply Finset.sum_le_sum; intro p _
  exact Finset.card_le_card (Finset.inter_subset_inter (h p.1) (h p.2))

/-! ## Section 4: Overlap Equivalence Classes -/

/-- The overlap equivalence relation. -/
def OverlapEquivRel' {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Fin n → Fin n → Prop :=
  Relation.ReflTransGen (fun i j => SupportOverlap (F i) (F j))

theorem overlapEquivRel'_refl {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) : OverlapEquivRel' F i i :=
  Relation.ReflTransGen.refl

theorem overlapEquivRel'_symm {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) {i j : Fin n}
    (h : OverlapEquivRel' F i j) : OverlapEquivRel' F j i := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact Relation.ReflTransGen.head (supportOverlap_symm.mp hab) ih

theorem overlapEquivRel'_trans {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) {i j k : Fin n}
    (hij : OverlapEquivRel' F i j) (hjk : OverlapEquivRel' F j k) :
    OverlapEquivRel' F i k := hij.trans hjk

/-- The overlap setoid. -/
def overlapSetoid {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Setoid (Fin n) where
  r := OverlapEquivRel' F
  iseqv := ⟨overlapEquivRel'_refl F, overlapEquivRel'_symm F, overlapEquivRel'_trans F⟩

/-- Number of overlap classes. -/
noncomputable def overlapClassCount' {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  Fintype.card (Quotient (overlapSetoid F))

/-! ## Section 5: Overlap Class Count Bounds -/

/-- The number of overlap classes ≤ n. -/
theorem overlap_class_count_le {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    overlapClassCount' F ≤ n := by
  unfold overlapClassCount'
  calc Fintype.card (Quotient (overlapSetoid F))
      ≤ Fintype.card (Fin n) := Fintype.card_quotient_le _
    _ = n := Fintype.card_fin n

/-- A single-element family has exactly one overlap class. -/
theorem overlap_class_count_one {α : Type*} [DecidableEq α]
    (F : Fin 1 → Finset α) :
    overlapClassCount' F = 1 := by
  unfold overlapClassCount'
  have : Unique (Quotient (overlapSetoid F)) := by
    refine ⟨⟨⟦0⟧⟩, fun q => ?_⟩
    obtain ⟨a, rfl⟩ := Quotient.exists_rep q
    congr 1; exact Subsingleton.elim a 0
  exact Fintype.card_unique

/-- The empty family has zero overlap classes. -/
theorem overlap_class_count_zero {α : Type*} [DecidableEq α]
    (F : Fin 0 → Finset α) :
    overlapClassCount' F = 0 := by
  unfold overlapClassCount'
  have : IsEmpty (Quotient (overlapSetoid F)) := by
    constructor; intro q
    obtain ⟨i, _⟩ := Quotient.exists_rep q; exact Fin.elim0 i
  exact Fintype.card_eq_zero

/-! ## Section 6: Disjoint Families Have Maximal Class Count -/

/-
When all supports are pairwise disjoint and nonempty, class count = n.
-/
theorem overlap_class_count_eq_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j))
    (_hne : ∀ i : Fin n, (F i).Nonempty) :
    overlapClassCount' F = n := by
  refine' le_antisymm ( overlap_class_count_le F ) _;
  suffices h_inj : Function.Injective (Quotient.mk (overlapSetoid F)) by
    simpa using Fintype.card_le_of_injective _ h_inj;
  intro i j hij;
  rw [ Quotient.eq ] at hij;
  induction hij;
  · rfl;
  · rename_i i j hi hj hij;
    exact Classical.not_not.1 fun h => Finset.not_nonempty_iff_eq_empty.2 ( Finset.disjoint_iff_inter_eq_empty.1 ( hF _ _ ( by aesop ) ) ) hj

/-! ## Section 7: The Peeling Lemma -/

/-- Remove an element from a specific support. -/
def peelElement {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) (x : α) : Fin n → Finset α :=
  Function.update F i (F i \ {x})

/-- Peeling preserves other supports. -/
theorem peelElement_other {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) (x : α) (hij : i ≠ j) :
    peelElement F i x j = F j := by
  simp [peelElement, Function.update_of_ne hij.symm]

/-- Peeling reduces support size by 1. -/
theorem peelElement_card {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) (x : α) (hx : x ∈ F i) :
    (peelElement F i x i).card = (F i).card - 1 := by
  simp only [peelElement, Function.update_self]
  rw [Finset.card_sdiff]
  simp [Finset.singleton_inter_of_mem hx]

/-
**Peeling Lemma**: Removing a shared element strictly reduces overlap
    complexity. Key inductive step for the overlap class conjecture.
-/
theorem peeling_reduces_complexity {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) (x : α)
    (hx_in_i : x ∈ F i)
    (hx_shared : ∃ j : Fin n, j ≠ i ∧ x ∈ F j) :
    OverlapComplexity (peelElement F i x) < OverlapComplexity F := by
  refine' Finset.sum_lt_sum _ _;
  · intro p hp; by_cases hi : p.1 = i <;> by_cases hj : p.2 = i <;> simp_all +decide [ peelElement ] ;
    · exact Finset.card_mono fun y hy => by aesop;
    · exact Finset.card_le_card fun y hy => by aesop;
  · cases' hx_shared with j hj;
    cases lt_or_gt_of_ne hj.1 <;> [ refine' ⟨ ( j, i ), _, _ ⟩ ; refine' ⟨ ( i, j ), _, _ ⟩ ] <;> simp_all +decide [ Finset.inter_comm ];
    · refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff, peelElement ];
    · refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff, peelElement ]

/-! ## Section 8: Support Interaction Matrix (NOVEL DEFINITION) -/

/-- The **support interaction matrix**: M(i,j) = |F(i) ∩ F(j)| for i ≠ j,
    M(i,i) = |F(i)|. Connects overlap theory to matrix algebra. -/
def SupportInteractionMatrix {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Matrix (Fin n) (Fin n) ℕ :=
  fun i j => if i = j then (F i).card else (F i ∩ F j).card

/-- The interaction matrix is symmetric. -/
theorem supportInteractionMatrix_symm {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    (SupportInteractionMatrix F).transpose = SupportInteractionMatrix F := by
  ext i j
  simp only [Matrix.transpose_apply, SupportInteractionMatrix]
  by_cases h : i = j
  · subst h; simp
  · simp [h, Ne.symm h, Finset.inter_comm]

/-- For pairwise disjoint families, the interaction matrix is diagonal. -/
theorem supportInteractionMatrix_diagonal_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j)) :
    ∀ i j : Fin n, i ≠ j → SupportInteractionMatrix F i j = 0 := by
  intro i j hij
  simp only [SupportInteractionMatrix, hij, ↓reduceIte]
  rw [Finset.card_eq_zero, ← Finset.disjoint_iff_inter_eq_empty]
  exact hF i j hij

/-! ## Section 9: TPE Preserves Overlap Structure -/

/-- Tropical projective equivalence of indexed families. -/
def TropProjEquiv_occ {V : Type*} {n : ℕ} (F₁ F₂ : Fin n → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ),
    ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i

/-- Variation support: vertices where f differs from its basepoint value. -/
def VarSupport_occ {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (v₀ : V) : Finset V :=
  Finset.univ.filter (fun v => f v ≠ f v₀)

/-- Family of variation supports. -/
def VarSupportFamily_occ {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) (v₀ : V) : Fin n → Finset V :=
  fun i => VarSupport_occ (F i) v₀

/-- Adding a constant preserves variation support. -/
theorem varSupport_occ_add_const {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (c : ℤ) (v₀ : V) :
    VarSupport_occ (fun v => f v + c) v₀ = VarSupport_occ f v₀ := by
  ext v; simp only [VarSupport_occ, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h hfv; exact h (by rw [hfv])
  · intro h hfv; exact h (by linarith)

/-- **TPE preserves variation overlap** (iff). -/
theorem tpe_preserves_var_overlap {V : Type*} [Fintype V] [DecidableEq V]
    {n : ℕ} (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n) :
    SupportOverlap (VarSupportFamily_occ F₁ v₀ i) (VarSupportFamily_occ F₁ v₀ j) ↔
    SupportOverlap (VarSupportFamily_occ F₂ v₀ (σ i)) (VarSupportFamily_occ F₂ v₀ (σ j)) := by
  constructor <;> intro ⟨x, hx⟩ <;> rw [Finset.mem_inter] at hx <;>
    refine ⟨x, Finset.mem_inter.mpr ⟨?_, ?_⟩⟩ <;>
    simp only [VarSupportFamily_occ, VarSupport_occ, Finset.mem_filter,
      Finset.mem_univ, true_and] at hx ⊢
  · rw [hσ i x, hσ i v₀]; intro heq; exact hx.1 (by linarith)
  · rw [hσ j x, hσ j v₀]; intro heq; exact hx.2 (by linarith)
  · intro heq; have := hx.1; rw [hσ i x, hσ i v₀] at this; exact this (by linarith)
  · intro heq; have := hx.2; rw [hσ j x, hσ j v₀] at this; exact this (by linarith)

/-- **TPE induces overlap graph isomorphism.** -/
theorem tpe_overlap_graph_iso {V : Type*} [Fintype V] [DecidableEq V]
    {n : ℕ} (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n) :
    (OverlapGraph (VarSupportFamily_occ F₁ v₀)).Adj i j ↔
    (OverlapGraph (VarSupportFamily_occ F₂ v₀)).Adj (σ i) (σ j) := by
  simp only [OverlapGraph]
  constructor
  · exact fun ⟨hne, ho⟩ =>
      ⟨σ.injective.ne hne, (tpe_preserves_var_overlap F₁ F₂ σ c hσ v₀ i j).mp ho⟩
  · exact fun ⟨hne, ho⟩ =>
      ⟨fun h => hne (congrArg σ h),
       (tpe_preserves_var_overlap F₁ F₂ σ c hσ v₀ i j).mpr ho⟩

/-! ## Section 10: TPE Preserves Overlap Equivalence -/

/-- TPE preserves overlap equivalence classes (by induction on ReflTransGen). -/
theorem tpe_preserves_overlap_equiv {V : Type*} [Fintype V] [DecidableEq V]
    {n : ℕ} (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n)
    (heq : OverlapEquivRel' (VarSupportFamily_occ F₁ v₀) i j) :
    OverlapEquivRel' (VarSupportFamily_occ F₂ v₀) (σ i) (σ j) := by
  induction heq with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact ih.tail ((tpe_preserves_var_overlap F₁ F₂ σ c hσ v₀ _ _).mp hab)

/-
**TPE preserves overlap class count.**
-/
theorem tpe_preserves_overlap_class_count {V : Type*} [Fintype V] [DecidableEq V]
    {n : ℕ} (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) :
    overlapClassCount' (VarSupportFamily_occ F₁ v₀) =
    overlapClassCount' (VarSupportFamily_occ F₂ v₀) := by
  apply Fintype.card_congr;
  refine' Quotient.congr _ _;
  exact σ;
  intro i j;
  constructor <;> intro h;
  · convert tpe_preserves_overlap_equiv F₁ F₂ σ c hσ v₀ i j h using 1;
  · convert tpe_preserves_overlap_equiv F₂ F₁ σ.symm ( fun i => -c ( σ.symm i ) ) ( fun i v => ?_ ) v₀ ( σ i ) ( σ j ) h using 1;
    · rw [ Equiv.symm_apply_apply ];
    · simp +decide;
    · have := hσ ( σ.symm i ) v; aesop;

/-! ## Section 11: Overlap Rank — Cross-Domain Bridge to Matroid Theory -/

/-- The **overlap rank**: n - class count. Analogous to matroid rank. -/
noncomputable def overlapRank {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  n - overlapClassCount' F

/-- Overlap rank zero for disjoint families. -/
theorem overlapRank_zero_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j))
    (hne : ∀ i, (F i).Nonempty) :
    overlapRank F = 0 := by
  unfold overlapRank
  rw [overlap_class_count_eq_of_disjoint F hF hne]; omega

/-! ## Section 12: Fully Connected Families -/

/-
When every pair overlaps, there is exactly one overlap class.
-/
theorem fully_connected_one_class {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (hn : 0 < n)
    (h_all_overlap : ∀ i j : Fin n, i ≠ j → SupportOverlap (F i) (F j)) :
    overlapClassCount' F = 1 := by
  have h_quotient : ∀ i j : Fin n, i = j ∨ (OverlapEquivRel' F) i j := by
    exact fun i j => Classical.or_iff_not_imp_left.2 fun hij => Relation.ReflTransGen.single ( h_all_overlap i j hij );
  have h_quotient : ∀ i j : Fin n, (Quotient.mk (overlapSetoid F) i) = (Quotient.mk (overlapSetoid F) j) := by
    intro i j; specialize h_quotient i j; rcases h_quotient with rfl | heq
    · rfl
    · exact Quotient.sound heq
  exact Fintype.card_eq_one_iff.mpr ⟨ ⟦⟨ 0, hn ⟩⟧, fun x => by obtain ⟨ i, rfl ⟩ := Quotient.exists_rep x; exact h_quotient _ _ ⟩

/-! ## Section 13: Inclusion-Exclusion for Overlap -/

/-- Total support size. -/
def totalSupportSize {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ∑ i : Fin n, (F i).card

/-- Union ≤ total. -/
theorem union_le_total {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    (Finset.univ.biUnion F).card ≤ totalSupportSize F :=
  Finset.card_biUnion_le

/-- For pairwise disjoint families, union = total. -/
theorem union_eq_total_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j)) :
    (Finset.univ.biUnion F).card = totalSupportSize F :=
  Finset.card_biUnion (fun i _ j _ hij => hF i j hij)

/-! ## Section 14: Support Distance — Coding Theory Bridge -/

/-- Support distance = symmetric difference size = Hamming distance. -/
def supportDistance {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) : ℕ :=
  (F i \ F j).card + (F j \ F i).card

/-- Support distance is symmetric. -/
theorem supportDistance_symm {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    supportDistance F i j = supportDistance F j i := by
  simp [supportDistance, Nat.add_comm]

/-- For disjoint supports, distance = sum of sizes. -/
theorem supportDistance_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) (hdisj : Disjoint (F i) (F j)) :
    supportDistance F i j = (F i).card + (F j).card := by
  simp [supportDistance, Finset.sdiff_eq_self_of_disjoint hdisj,
        Finset.sdiff_eq_self_of_disjoint (Disjoint.symm hdisj)]

/-- Overlap deficit. -/
def overlapDeficit {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  totalSupportSize F - (Finset.univ.biUnion F).card

/-- Deficit zero for disjoint families. -/
theorem overlapDeficit_eq_zero_of_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : ∀ i j : Fin n, i ≠ j → Disjoint (F i) (F j)) :
    overlapDeficit F = 0 := by
  unfold overlapDeficit; rw [union_eq_total_of_disjoint F hF]; omega

/-! ## Section 15: Supports from Different Classes are Disjoint -/

/-- Supports in different overlap classes are disjoint. -/
theorem disjoint_of_different_class {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) {i j : Fin n}
    (h : ¬OverlapEquivRel' F i j) : Disjoint (F i) (F j) := by
  apply disjoint_of_not_supportOverlap
  intro hoverlap; exact h (Relation.ReflTransGen.single hoverlap)

/-! ## Section 16: Overlap Rank Bounds -/

/-- Overlap rank ≤ n - 1 when n > 0. -/
theorem overlapRank_le {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (hn : 0 < n) :
    overlapRank F ≤ n - 1 := by
  unfold overlapRank
  have : Nonempty (Quotient (overlapSetoid F)) := ⟨Quotient.mk _ ⟨0, hn⟩⟩
  have h1 : 0 < overlapClassCount' F := by
    unfold overlapClassCount'; exact Fintype.card_pos
  omega

/-! ## Section 17: Well-Foundedness -/

/-- Overlap complexity is well-founded for induction. -/
theorem overlap_complexity_wf {α : Type*} [DecidableEq α] {n : ℕ} :
    WellFounded (fun F G : Fin n → Finset α =>
      OverlapComplexity F < OverlapComplexity G) :=
  InvImage.wf OverlapComplexity Nat.lt_wfRel.wf