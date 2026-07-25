/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Theory: Beyond Disjoint Supports in Tropical Kernel Rigidity

This file develops a combinatorial theory of **overlap classes** for families
of finite supports, extending disjoint-support uniqueness results to the
interacting regime.

## Mathematical Context

In the disjoint-support regime, tropical kernel generators are unique up to
tropical projective equivalence (permutation + constant shifts). When supports
overlap, generators interact, and uniqueness breaks into components governed
by the connected components of the support overlap graph.

## Main Definitions

* `TropProjEquiv` — tropical projective equivalence of function families
* `SupportsOverlap` — two finsets have nonempty intersection
* `OverlapDegree` — number of overlapping pairs
* `OverlapEquivRel` — equivalence relation from reflexive-transitive closure
* `overlapClassCount` — number of connected components of the overlap graph
* `CrossOverlapCount` — intersection cardinality between supports
* `OverlapSignature` — multiset of intersection sizes
* `VarSupport` — variation support (TPE-invariant)

## Main Results

* `support_overlap_symmetric` — overlap is symmetric
* `overlapDegree_eq_zero_iff_pairwiseDisjoint` — zero overlap ↔ pairwise disjoint
* `disjoint_of_different_overlap_class` — different classes ⟹ disjoint
* `overlapDegree_zero_recovers_uniqueness` — bridge to existing theory
* `varSupport_tpe_invariant` — variation support is TPE-invariant
* `tropProjEquiv_preserves_varOverlap` — TPE preserves variation overlap
* `overlap_class_unions_disjoint` — componentwise factorization
* `overlapClassCount_eq_of_pairwiseDisjoint_nonempty` — class count = n when disjoint

## References

* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Develin–Santos–Sturmfels, "On the rank of a tropical matrix"
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Tropical Projective Equivalence -/

/-- **Tropical projective equivalence** of two indexed families of ℤ-valued
    functions. Two families are TPE if there exists a permutation σ and
    constants c such that F₂(σ(i), v) = F₁(i, v) + c(i). -/
def TropProjEquiv {ι V : Type*} (F₁ F₂ : ι → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm ι) (c : ι → ℤ),
    ∀ (i : ι) (v : V), F₂ (σ i) v = F₁ i v + c i

theorem tropProjEquiv_refl {ι V : Type*} (F : ι → V → ℤ) :
    TropProjEquiv F F :=
  ⟨Equiv.refl ι, fun _ => 0, fun i v => by simp⟩

theorem tropProjEquiv_symm {ι V : Type*} {F₁ F₂ : ι → V → ℤ}
    (h : TropProjEquiv F₁ F₂) : TropProjEquiv F₂ F₁ := by
  obtain ⟨σ, c, hσ⟩ := h
  exact ⟨σ.symm, fun i => -(c (σ.symm i)), fun i v => by
    have := hσ (σ.symm i) v; simp [Equiv.apply_symm_apply] at this; linarith⟩

theorem tropProjEquiv_trans {ι V : Type*} {F₁ F₂ F₃ : ι → V → ℤ}
    (h₁₂ : TropProjEquiv F₁ F₂) (h₂₃ : TropProjEquiv F₂ F₃) :
    TropProjEquiv F₁ F₃ := by
  obtain ⟨σ₁, c₁, hσ₁⟩ := h₁₂
  obtain ⟨σ₂, c₂, hσ₂⟩ := h₂₃
  exact ⟨σ₁.trans σ₂, fun i => c₁ i + c₂ (σ₁ i), fun i v => by
    simp only [Equiv.trans_apply]; rw [hσ₂ (σ₁ i) v, hσ₁ i v]; ring⟩

/-! ## Section 2: Function Support and Separation -/

/-- The support of an integer-valued function. -/
def FunSupport {V : Type*} (f : V → ℤ) : Set V := {v | f v ≠ 0}

/-- Pairwise disjoint supports for a family of functions. -/
def PairwiseDisjointSupports {ι V : Type*} (F : ι → V → ℤ) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (FunSupport (F i)) (FunSupport (F j))

/-- Finset support on a fintype. -/
def FinFunSupport {V : Type*} [Fintype V] [DecidableEq V] (f : V → ℤ) : Finset V :=
  Finset.univ.filter (fun v => f v ≠ 0)

/-- The family of finset supports. -/
def FunSupportFamily {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) : Fin n → Finset V :=
  fun i => FinFunSupport (F i)

/-! ## Section 3: Variation Support (TPE-invariant)

The **variation support** of a function is the set of vertices where it
differs from its value at some reference point. Unlike `FunSupport`, this
is invariant under adding a constant, making it the correct support notion
for tropical projective equivalence. For finite nonempty types, we define
it as the set of v where f(v) ≠ f(v₀) for a chosen basepoint v₀. -/

/-- The **variation support** of f relative to a basepoint v₀: the set of
    vertices where f differs from f(v₀). This is TPE-invariant. -/
def VarSupport {V : Type*} [DecidableEq V] (f : V → ℤ) (v₀ : V) : Set V :=
  {v | f v ≠ f v₀}

/-- Finset version of variation support. -/
def FinVarSupport {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (v₀ : V) : Finset V :=
  Finset.univ.filter (fun v => f v ≠ f v₀)

/-- The family of variation supports. -/
def VarSupportFamily {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) (v₀ : V) : Fin n → Finset V :=
  fun i => FinVarSupport (F i) v₀

/-- **Variation support is TPE-invariant:** adding a constant doesn't change
    the set of vertices where f differs from its basepoint value. -/
theorem varSupport_add_const {V : Type*} [DecidableEq V]
    (f : V → ℤ) (c : ℤ) (v₀ : V) :
    VarSupport (fun v => f v + c) v₀ = VarSupport f v₀ := by
  ext v
  simp only [VarSupport, Set.mem_setOf_eq]
  constructor
  · intro h hfv; exact h (by rw [hfv])
  · intro h hfv; exact h (by linarith)

/-- Finset version: adding a constant preserves variation support. -/
theorem finVarSupport_add_const {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (c : ℤ) (v₀ : V) :
    FinVarSupport (fun v => f v + c) v₀ = FinVarSupport f v₀ := by
  ext v
  simp only [FinVarSupport, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h hfv; exact h (by rw [hfv])
  · intro h hfv; exact h (by linarith)

/-! ## Section 4: Support Overlap Relation -/

/-- Two finsets **overlap** if their intersection is nonempty. -/
def SupportsOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

instance {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SupportsOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

/-- The overlap relation is symmetric. -/
theorem support_overlap_symmetric {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    A ∩ B ≠ ∅ ↔ B ∩ A ≠ ∅ := by
  simp [inter_comm]

theorem supportsOverlap_symm {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ SupportsOverlap B A := by
  simp only [SupportsOverlap, inter_comm]

theorem supportsOverlap_iff_exists {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ ∃ x, x ∈ A ∧ x ∈ B := by
  simp [SupportsOverlap, Finset.Nonempty]

theorem disjoint_of_not_overlap {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : ¬SupportsOverlap A B) :
    Disjoint A B := by
  rw [Finset.disjoint_iff_inter_eq_empty]
  by_contra h'
  exact h (Finset.nonempty_of_ne_empty h')

theorem not_overlap_of_disjoint {α : Type*} [DecidableEq α]
    {A B : Finset α} (h : Disjoint A B) :
    ¬SupportsOverlap A B := by
  intro ⟨x, hx⟩
  exact absurd ((Finset.mem_inter.mp hx).2)
    (Finset.disjoint_left.mp h (Finset.mem_inter.mp hx).1)

/-! ## Section 5: Pairwise Disjoint Finset Families -/

/-- A finset family is pairwise disjoint. -/
def PairwiseDisjointFamily {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (F i) (F j)

/-! ## Section 6: Overlap Degree -/

/-- The **overlap degree**: number of overlapping pairs. -/
def OverlapDegree {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (F p.1) (F p.2))).card

/-- **Overlap degree zero ↔ pairwise disjoint.** -/
theorem overlapDegree_eq_zero_iff_pairwiseDisjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    OverlapDegree F = 0 ↔ PairwiseDisjointFamily F := by
  constructor
  · intro h i j hij
    by_contra h_not_disj
    rw [not_disjoint_iff] at h_not_disj
    obtain ⟨x, hxi, hxj⟩ := h_not_disj
    have hlt : min i j < max i j := by
      rcases lt_or_gt_of_ne hij with h | h
      · simp [min_eq_left h.le, max_eq_right h.le, h]
      · simp [min_eq_right h.le, max_eq_left h.le, h]
    have hoverlap : SupportsOverlap (F (min i j)) (F (max i j)) := by
      rcases le_total i j with h | h
      · simp [min_eq_left h, max_eq_right h]
        exact ⟨x, Finset.mem_inter.mpr ⟨hxi, hxj⟩⟩
      · simp [min_eq_right h, max_eq_left h]
        exact ⟨x, Finset.mem_inter.mpr ⟨hxj, hxi⟩⟩
    have : ((Finset.univ ×ˢ Finset.univ).filter
        (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (F p.1) (F p.2))).Nonempty :=
      ⟨(min i j, max i j), by simp [hlt, hoverlap]⟩
    rw [OverlapDegree, Finset.card_eq_zero] at h
    exact this.ne_empty h
  · intro h
    rw [OverlapDegree, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    intro ⟨i, j⟩ _
    simp only [not_and]
    intro hij
    exact not_overlap_of_disjoint (h i j hij.ne)

/-! ## Section 7: Overlap Equivalence Relation -/

/-- Reflexive-transitive closure of overlap gives an equivalence relation. -/
def OverlapEquivRel {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i j : ι) : Prop :=
  Relation.ReflTransGen (fun a b => SupportsOverlap (F a) (F b)) i j

theorem overlapEquivRel_refl {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i : ι) :
    OverlapEquivRel F i i :=
  Relation.ReflTransGen.refl

theorem overlapEquivRel_trans {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j k : ι}
    (hij : OverlapEquivRel F i j) (hjk : OverlapEquivRel F j k) :
    OverlapEquivRel F i k :=
  Relation.ReflTransGen.trans hij hjk

theorem overlapEquivRel_symm {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j : ι}
    (h : OverlapEquivRel F i j) :
    OverlapEquivRel F j i := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact Relation.ReflTransGen.trans
      (Relation.ReflTransGen.single (supportsOverlap_symm.mp hab)) ih

/-! ## Section 8: Disjointness Across Overlap Classes -/

/-- **Key theorem:** supports in different overlap classes are disjoint. -/
theorem disjoint_of_different_overlap_class {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) {i j : ι}
    (h : ¬OverlapEquivRel F i j) :
    Disjoint (F i) (F j) := by
  apply disjoint_of_not_overlap
  intro hoverlap
  exact h (Relation.ReflTransGen.single hoverlap)

/-- Elements in supports from different classes are distinct. -/
theorem overlap_class_element_separation {α : Type*} [DecidableEq α]
    {ι : Type*} (F : ι → Finset α) {i j : ι}
    (h : ¬OverlapEquivRel F i j) {x : α}
    (hx : x ∈ F i) : x ∉ F j :=
  Finset.disjoint_left.mp (disjoint_of_different_overlap_class F h) hx

/-! ## Section 9: Cross-Overlap Count -/

/-- Intersection cardinality between two supports. -/
def CrossOverlapCount {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) : ℕ :=
  (F i ∩ F j).card

theorem crossOverlapCount_comm {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    CrossOverlapCount F i j = CrossOverlapCount F j i := by
  simp [CrossOverlapCount, inter_comm]

theorem crossOverlapCount_eq_zero_iff_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    CrossOverlapCount F i j = 0 ↔ Disjoint (F i) (F j) := by
  simp [CrossOverlapCount, Finset.disjoint_iff_inter_eq_empty]

theorem crossOverlapCount_pos_iff_overlap {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i j : Fin n) :
    0 < CrossOverlapCount F i j ↔ SupportsOverlap (F i) (F j) :=
  ⟨fun h => Finset.card_pos.mp h, fun h => Finset.card_pos.mpr h⟩

/-! ## Section 10: Overlap Signature -/

/-- Multiset of intersection sizes for overlapping pairs. -/
def OverlapSignature {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Multiset ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (F p.1) (F p.2))).val.map
    (fun p => CrossOverlapCount F p.1 p.2)

theorem overlapSignature_pos {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    ∀ x ∈ OverlapSignature F, 0 < x := by
  intro x hx
  simp only [OverlapSignature, Multiset.mem_map, Finset.mem_val, Finset.mem_filter,
    Finset.mem_product, Finset.mem_univ, true_and] at hx
  obtain ⟨⟨i, j⟩, ⟨_, hoverlap⟩, rfl⟩ := hx
  exact (crossOverlapCount_pos_iff_overlap F i j).mpr hoverlap

/-! ## Section 11: Family Union -/

def FamilyUnion {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Finset α :=
  Finset.univ.biUnion F

theorem subset_familyUnion {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) (i : Fin n) :
    F i ⊆ FamilyUnion F :=
  Finset.subset_biUnion_of_mem F (Finset.mem_univ i)

theorem familyUnion_card_of_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α)
    (hF : PairwiseDisjointFamily F) :
    (FamilyUnion F).card = ∑ i : Fin n, (F i).card := by
  simp only [FamilyUnion]
  exact Finset.card_biUnion fun i _ j _ hij => hF i j hij

/-! ## Section 12: Overlap Degree Monotonicity -/

theorem overlapDegree_mono_of_subset {α : Type*} [DecidableEq α] {n : ℕ}
    (F G : Fin n → Finset α)
    (h : ∀ i, G i ⊆ F i) :
    OverlapDegree G ≤ OverlapDegree F := by
  apply Finset.card_le_card
  intro p hp
  simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_univ, true_and] at hp ⊢
  refine ⟨hp.1, ?_⟩
  obtain ⟨x, hx⟩ := hp.2
  exact ⟨x, Finset.mem_inter.mpr
    ⟨h _ (Finset.mem_inter.mp hx).1, h _ (Finset.mem_inter.mp hx).2⟩⟩

/-! ## Section 13: Support Separation Engine -/

theorem disjoint_support_forces_zero {ι V : Type*}
    (F : ι → V → ℤ) (hdisjoint : PairwiseDisjointSupports F)
    (i j : ι) (hij : i ≠ j) (v : V) (hv : v ∈ FunSupport (F i)) :
    F j v = 0 := by
  by_contra h
  exact Set.disjoint_left.mp (hdisjoint i j hij) hv h

theorem support_matching_injective
    {n : ℕ} {V : Type*}
    (F G : Fin n → V → ℤ)
    (hFdisjoint : PairwiseDisjointSupports F)
    (hFnonempty : ∀ j, ∃ v : V, v ∈ FunSupport (F j))
    (σ : Fin n → Fin n)
    (hσ : ∀ i, FunSupport (F i) = FunSupport (G (σ i))) :
    Function.Injective σ := by
  intro i j hij
  by_contra h_ne
  obtain ⟨v, hv⟩ := hFnonempty j
  have hv_i : v ∈ FunSupport (F i) := by rw [hσ i, hij, ← hσ j]; exact hv
  exact Set.disjoint_left.mp (hFdisjoint i j h_ne) hv_i hv

theorem disjoint_support_unique_up_to_tropProjEquiv
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F G : Fin n → V → ℤ)
    (hFdisjoint : PairwiseDisjointSupports F)
    (_hGdisjoint : PairwiseDisjointSupports G)
    (hFnonempty : ∀ j, ∃ v : V, v ∈ FunSupport (F j))
    (hSameSupports : ∀ i : Fin n, ∃ j : Fin n,
      FunSupport (F i) = FunSupport (G j))
    (_hSameSupportsRev : ∀ j : Fin n, ∃ i : Fin n,
      FunSupport (G j) = FunSupport (F i))
    (hFG_eq : ∀ i j : Fin n,
      FunSupport (F i) = FunSupport (G j) →
      ∃ c : ℤ, ∀ v, G j v = F i v + c) :
    TropProjEquiv F G := by
  choose σ hσ using hSameSupports
  have hσ_inj := support_matching_injective F G hFdisjoint hFnonempty σ hσ
  have hσ_bij : Function.Bijective σ :=
    ⟨hσ_inj, Finite.injective_iff_surjective.mp hσ_inj⟩
  choose c hc using fun i => hFG_eq i (σ i) (hσ i)
  exact ⟨Equiv.ofBijective σ hσ_bij, c, fun i v => by
    simp only [Equiv.ofBijective_apply]; exact hc i v⟩

/-! ## Section 14: Bridge — Overlap Degree Zero Recovers Uniqueness -/

theorem pairwiseDisjointSupports_of_pairwiseDisjointFamily
    {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ)
    (h : PairwiseDisjointFamily (FunSupportFamily F)) :
    PairwiseDisjointSupports F := by
  intro i j hij
  rw [Set.disjoint_left]
  intro v hv_i hv_j
  have hdisj := h i j hij
  have hi : v ∈ FunSupportFamily F i := by
    simp [FunSupportFamily, FinFunSupport]; exact hv_i
  have hj : v ∈ FunSupportFamily F j := by
    simp [FunSupportFamily, FinFunSupport]; exact hv_j
  exact absurd hj (Finset.disjoint_left.mp hdisj hi)

/-- **Theorem A: Overlap-degree zero recovers disjoint-support uniqueness.** -/
theorem overlapDegree_zero_recovers_uniqueness
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F G : Fin n → V → ℤ)
    (h0 : OverlapDegree (FunSupportFamily F) = 0)
    (hGdisjoint : PairwiseDisjointSupports G)
    (hFnonempty : ∀ j, ∃ v : V, v ∈ FunSupport (F j))
    (hSameSupports : ∀ i : Fin n, ∃ j : Fin n,
      FunSupport (F i) = FunSupport (G j))
    (hSameSupportsRev : ∀ j : Fin n, ∃ i : Fin n,
      FunSupport (G j) = FunSupport (F i))
    (hFG_eq : ∀ i j : Fin n,
      FunSupport (F i) = FunSupport (G j) →
      ∃ c : ℤ, ∀ v, G j v = F i v + c) :
    TropProjEquiv F G := by
  exact disjoint_support_unique_up_to_tropProjEquiv F G
    (pairwiseDisjointSupports_of_pairwiseDisjointFamily F
      ((overlapDegree_eq_zero_iff_pairwiseDisjoint _).mp h0))
    hGdisjoint hFnonempty hSameSupports hSameSupportsRev hFG_eq

/-! ## Section 15: TPE Preserves Variation Overlap

The zero-set support `{v | f(v) ≠ 0}` is NOT TPE-invariant (adding a constant
changes which values are zero). However, the **variation support**
`{v | f(v) ≠ f(v₀)}` IS TPE-invariant. We prove that TPE preserves overlap
structure of variation supports. -/

/-- **Theorem B: TPE preserves variation support overlap.**
    If F₁ and F₂ are TPE via (σ, c), then variation supports of F₁(i) and
    F₁(j) overlap iff variation supports of F₂(σ(i)) and F₂(σ(j)) overlap. -/
theorem tropProjEquiv_preserves_varOverlap
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n)
    (hoverlap : SupportsOverlap (VarSupportFamily F₁ v₀ i) (VarSupportFamily F₁ v₀ j)) :
    SupportsOverlap (VarSupportFamily F₂ v₀ (σ i)) (VarSupportFamily F₂ v₀ (σ j)) := by
  obtain ⟨x, hx⟩ := hoverlap
  rw [Finset.mem_inter] at hx
  simp only [VarSupportFamily, FinVarSupport, Finset.mem_filter, Finset.mem_univ,
    true_and] at hx ⊢
  refine ⟨x, Finset.mem_inter.mpr ⟨?_, ?_⟩⟩
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    rw [hσ i x, hσ i v₀]
    intro heq; exact hx.1 (by linarith)
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    rw [hσ j x, hσ j v₀]
    intro heq; exact hx.2 (by linarith)

/-- **Theorem C: TPE preserves variation overlap equivalence classes.** -/
theorem tropProjEquiv_preserves_varOverlapEquiv
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n)
    (heq : OverlapEquivRel (VarSupportFamily F₁ v₀) i j) :
    OverlapEquivRel (VarSupportFamily F₂ v₀) (σ i) (σ j) := by
  induction heq with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact Relation.ReflTransGen.tail ih
      (tropProjEquiv_preserves_varOverlap F₁ F₂ σ c hσ v₀ _ _ hab)

/-! ## Section 16: Overlap Degree Bounds -/

/-
The overlap degree is bounded by n choose 2.
-/
theorem overlapDegree_le_pairs {n : ℕ} {α : Type*} [DecidableEq α]
    (F : Fin n → Finset α) :
    OverlapDegree F ≤ n * (n - 1) / 2 := by
      refine' le_trans ( Finset.card_le_card _ ) _;
      exact Finset.filter ( fun p => p.1 < p.2 ) ( Finset.univ ×ˢ Finset.univ );
      · grind;
      · rw [ show ( { p ∈ Finset.univ ×ˢ Finset.univ | p.1 < p.2 } : Finset ( Fin n × Fin n ) ) = Finset.biUnion ( Finset.univ : Finset ( Fin n ) ) fun i => Finset.image ( fun j => ( i, j ) ) ( Finset.Ioi i ) from ?_, Finset.card_biUnion ];
        · simp +decide [ Finset.card_image_of_injective, Function.Injective ];
          rw [ ← Finset.sum_range_id ];
          rw [ ← Finset.sum_range_reflect, Finset.sum_range ];
        · exact fun i _ j _ hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by aesop;
        · grind

/-! ## Section 17: Overlap Class Count -/

/-- Number of overlap classes. -/
noncomputable def overlapClassCount {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  @Finset.card _ (@Finset.image _ _ (Classical.decEq _) (fun i =>
    @Finset.filter _ (fun j => OverlapEquivRel F i j)
      (fun j => Classical.dec _) Finset.univ) Finset.univ)

/-
When all supports are pairwise disjoint and nonempty,
    each index is its own overlap class, so class count = n.
-/
theorem overlapClassCount_eq_of_pairwiseDisjoint_nonempty
    {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : PairwiseDisjointFamily F)
    (_hne : ∀ i, (F i).Nonempty) :
    overlapClassCount F = n := by
      unfold overlapClassCount;
      -- Since the supports are pairwise disjoint and nonempty, the overlap equivalence classes are just the individual supports.
      have h_overlap_classes : ∀ i j : Fin n, OverlapEquivRel F i j ↔ i = j := by
        intro i j;
        constructor;
        · intro h;
          contrapose! h;
          intro H;
          induction H;
          · contradiction;
          · rename_i k hk₁ hk₂ hk;
            exact hk₂.elim fun x hx => Finset.disjoint_left.mp ( hF _ _ <| by aesop ) ( Finset.mem_filter.mp hx |>.1 ) ( Finset.mem_filter.mp hx |>.2 );
        · exact fun h => h ▸ overlapEquivRel_refl F i;
      convert Finset.card_image_of_injective _ ( show Function.Injective ( fun i : Fin n => ( Finset.univ.filter fun j => i = j ) ) from fun i j h => ?_ );
      · exact funext fun i => funext fun j => by simp +decide [ h_overlap_classes ] ;
      · simp +decide;
      · simp_all +decide [ Finset.ext_iff ]

/-! ## Section 18: Total Support Size Invariant -/

/-
**Theorem D: Total variation support size is a TPE invariant.**
-/
theorem total_varSupport_size_invariant
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) :
    ∑ i, (VarSupportFamily F₁ v₀ i).card =
    ∑ i, (VarSupportFamily F₂ v₀ i).card := by
      conv_rhs => rw [ ← Equiv.sum_comp σ ] ;
      simp +decide [ VarSupportFamily ];
      unfold FinVarSupport; aesop;

/-! ## Section 19: Max Overlap Degree -/

noncomputable def MaxOverlapDeg {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  Finset.sup ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2))
    (fun p => CrossOverlapCount F p.1 p.2)

theorem maxOverlapDeg_eq_zero_of_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α)
    (hF : PairwiseDisjointFamily F) :
    MaxOverlapDeg F = 0 := by
      refine' le_antisymm _ _ <;> simp_all +decide [ MaxOverlapDeg ];
      exact fun i j hij => crossOverlapCount_eq_zero_iff_disjoint F i j |>.2 ( hF i j hij.ne )

/-! ## Section 20: Overlap Class Disjoint Union Theorem -/

/-
**Theorem E: Supports from different overlap classes have disjoint unions.**
    This is the componentwise factorization at the support level:
    overlap classes are independent interaction sectors.
-/
theorem overlap_class_unions_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (C₁ C₂ : Finset (Fin n))
    (_hC₁ : ∀ i ∈ C₁, ∀ j ∈ C₁, OverlapEquivRel F i j)
    (_hC₂ : ∀ i ∈ C₂, ∀ j ∈ C₂, OverlapEquivRel F i j)
    (hsep : ∀ i ∈ C₁, ∀ j ∈ C₂, ¬OverlapEquivRel F i j) :
    Disjoint (C₁.biUnion F) (C₂.biUnion F) := by
      grind +suggestions

/-! ## Section 21: Overlap Degree as Complexity Measure -/

/-
The overlap degree is zero for singleton families.
-/
theorem overlapDegree_singleton {α : Type*} [DecidableEq α]
    (A : Finset α) :
    OverlapDegree (fun _ : Fin 1 => A) = 0 := by
      convert overlapDegree_eq_zero_iff_pairwiseDisjoint _ |>.2 _;
      exact fun i j hij => by fin_cases i; fin_cases j; contradiction;

/-- Empty family has overlap degree zero. -/
theorem overlapDegree_empty {α : Type*} [DecidableEq α]
    (F : Fin 0 → Finset α) :
    OverlapDegree F = 0 := by
  simp [OverlapDegree]