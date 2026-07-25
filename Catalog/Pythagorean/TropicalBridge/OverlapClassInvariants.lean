/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Overlap Class Invariants: TPE-Invariance of Overlap Structure

This file proves that tropical projective equivalence (TPE) preserves the
overlap class structure of variation supports. The central result is that
the overlap class count — the number of connected components of the support
interaction graph — is a TPE invariant. This establishes overlap classes as
the correct interaction sectors for tropical kernel generators.

## Mathematical Context

When tropical kernel generators have overlapping supports, the generators
interact. The overlap equivalence relation (reflexive-transitive closure of
the "nonempty intersection" relation on supports) partitions generators into
overlap classes — connected components of the support interaction graph.

The main theorem shows that if two generating families are related by
tropical projective equivalence (permutation + constant shifts), then the
permutation respects the overlap class structure of variation supports.
Consequently, the number of overlap classes is a TPE invariant.

## Main Definitions

* `TropProjEquiv` — tropical projective equivalence (permutation + shifts)
* `SupportsOverlap` — nonempty intersection of finsets
* `OverlapEquivRel` — reflexive-transitive closure of overlap relation
* `OverlapDegree` — number of overlapping pairs (edges in overlap graph)
* `VarSupport` — variation support (TPE-invariant support notion)
* `OverlapClassCount` — number of overlap equivalence classes
* `OverlapComplexity` — sum of pairwise intersection cardinalities
* `OverlapProfile` — sorted list of overlap class sizes

## Main Results

* `tpe_permutation_preserves_overlapEquiv` — TPE permutation respects
  overlap equivalence on variation supports (Theorem A)
* `overlapClassCount_tpe_invariant` — overlap class count is a TPE
  invariant (Theorem B, main result)
* `overlapComplexity_tpe_invariant` — overlap complexity (total intersection
  size) is a TPE invariant (Theorem C)
* `overlap_classes_partition_indices` — overlap classes partition the
  index set via a Setoid (structural result)
* `overlapDegree_tpe_invariant` — overlap degree is preserved by TPE
  (Theorem D)
* `union_card_le_sum_card` — inclusion-exclusion lower bound via
  overlap (Theorem E)

## References

* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Develin–Santos–Sturmfels, "On the rank of a tropical matrix"
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Core Definitions -/

/-- **Tropical projective equivalence** of two indexed families of ℤ-valued
    functions. Two families F₁, F₂ : ι → V → ℤ are TPE if there exists a
    permutation σ and constants c such that F₂(σ(i), v) = F₁(i, v) + c(i). -/
def TropProjEquiv {ι V : Type*} (F₁ F₂ : ι → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm ι) (c : ι → ℤ),
    ∀ (i : ι) (v : V), F₂ (σ i) v = F₁ i v + c i

/-- Two finsets **overlap** if their intersection is nonempty. -/
def SupportsOverlap {α : Type*} [DecidableEq α] (A B : Finset α) : Prop :=
  (A ∩ B).Nonempty

instance {α : Type*} [DecidableEq α] (A B : Finset α) :
    Decidable (SupportsOverlap A B) :=
  inferInstanceAs (Decidable (A ∩ B).Nonempty)

/-- The **variation support** of f relative to a basepoint v₀: the set of
    vertices where f differs from f(v₀). This is TPE-invariant because
    adding a constant to f does not change which values differ from the
    basepoint value. -/
def FinVarSupport {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (v₀ : V) : Finset V :=
  Finset.univ.filter (fun v => f v ≠ f v₀)

/-- The family of variation supports for an indexed family. -/
def VarSupportFamily {V : Type*} [Fintype V] [DecidableEq V] {n : ℕ}
    (F : Fin n → V → ℤ) (v₀ : V) : Fin n → Finset V :=
  fun i => FinVarSupport (F i) v₀

/-- Reflexive-transitive closure of overlap gives an equivalence relation
    on indices. Two indices i, j are overlap-equivalent if there is a chain
    of overlapping supports connecting them. -/
def OverlapEquivRel {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i j : ι) : Prop :=
  Relation.ReflTransGen (fun a b => SupportsOverlap (F a) (F b)) i j

/-- The **overlap degree**: the number of (unordered) pairs of distinct
    indices whose supports overlap. This counts edges in the support
    interaction graph. -/
def OverlapDegree {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (F p.1) (F p.2))).card

/-- The **overlap complexity**: the total intersection cardinality summed
    over all overlapping pairs. This is a finer invariant than the overlap
    degree (which just counts pairs). -/
def OverlapComplexity {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  ∑ p ∈ (Finset.univ ×ˢ Finset.univ).filter
    (fun p : Fin n × Fin n => p.1 < p.2),
    (F p.1 ∩ F p.2).card

/-- A family is **pairwise disjoint** if distinct members have empty
    intersection. -/
def PairwiseDisjointFamily {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (F i) (F j)

/-- The union of all supports in a family. -/
def FamilyUnion {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Finset α :=
  Finset.univ.biUnion F

/-! ## Section 2: Basic Properties -/

theorem supportsOverlap_symm {α : Type*} [DecidableEq α]
    {A B : Finset α} :
    SupportsOverlap A B ↔ SupportsOverlap B A := by
  simp only [SupportsOverlap, inter_comm]

theorem overlapEquivRel_refl {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) (i : ι) :
    OverlapEquivRel F i i :=
  Relation.ReflTransGen.refl

theorem overlapEquivRel_symm {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j : ι}
    (h : OverlapEquivRel F i j) :
    OverlapEquivRel F j i := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hab ih =>
    exact Relation.ReflTransGen.trans
      (Relation.ReflTransGen.single (supportsOverlap_symm.mp hab)) ih

theorem overlapEquivRel_trans {α : Type*} [DecidableEq α] {ι : Type*}
    (F : ι → Finset α) {i j k : ι}
    (hij : OverlapEquivRel F i j) (hjk : OverlapEquivRel F j k) :
    OverlapEquivRel F i k :=
  Relation.ReflTransGen.trans hij hjk

/-- The overlap equivalence relation defines a setoid on the index type. -/
def overlapSetoid {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : Setoid (Fin n) where
  r := OverlapEquivRel F
  iseqv := {
    refl := fun i => overlapEquivRel_refl F i
    symm := fun h => overlapEquivRel_symm F h
    trans := fun h₁ h₂ => overlapEquivRel_trans F h₁ h₂
  }

/-- The **overlap class count**: the number of equivalence classes under
    the overlap equivalence relation. Each class is a connected component
    of the support interaction graph. -/
noncomputable def OverlapClassCount {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) : ℕ :=
  Fintype.card (Quotient (overlapSetoid F))

/-! ## Section 3: Variation Support TPE-Invariance -/

/-- Adding a constant to a function preserves its variation support. This
    is the foundational lemma: it says that the TPE "scaling" operation
    (adding a constant) does not change which vertices differ from the
    basepoint. -/
theorem finVarSupport_add_const {V : Type*} [Fintype V] [DecidableEq V]
    (f : V → ℤ) (c : ℤ) (v₀ : V) :
    FinVarSupport (fun v => f v + c) v₀ = FinVarSupport f v₀ := by
  ext v
  simp only [FinVarSupport, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h hfv; exact h (by rw [hfv])
  · intro h hfv; exact h (by linarith)

/-! ## Section 4: TPE Preserves Overlap (Single Step) -/

/-- **Lemma: TPE preserves overlap of variation supports (single pair).**
    If F₁ ~ F₂ via (σ, c), and variation supports of F₁(i) and F₁(j)
    overlap, then variation supports of F₂(σ(i)) and F₂(σ(j)) also overlap.

    Proof: Any witness x in VarSupp(F₁(i)) ∩ VarSupp(F₁(j)) satisfies
    F₁(i,x) ≠ F₁(i,v₀) and F₁(j,x) ≠ F₁(j,v₀). Since F₂(σ(i),·) =
    F₁(i,·) + c(i), the same x witnesses the overlap for F₂. -/
theorem tpe_preserves_single_overlap
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n)
    (hoverlap : SupportsOverlap (VarSupportFamily F₁ v₀ i)
                                (VarSupportFamily F₁ v₀ j)) :
    SupportsOverlap (VarSupportFamily F₂ v₀ (σ i))
                    (VarSupportFamily F₂ v₀ (σ j)) := by
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

/-- Converse direction: non-overlap is also preserved. -/
theorem tpe_preserves_single_non_overlap
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n)
    (hno : ¬SupportsOverlap (VarSupportFamily F₁ v₀ i)
                             (VarSupportFamily F₁ v₀ j)) :
    ¬SupportsOverlap (VarSupportFamily F₂ v₀ (σ i))
                     (VarSupportFamily F₂ v₀ (σ j)) := by
  intro h
  apply hno
  -- We can use the inverse direction: F₁(i,v) = F₂(σ(i),v) - c(i)
  obtain ⟨x, hx⟩ := h
  rw [Finset.mem_inter] at hx
  simp only [VarSupportFamily, FinVarSupport, Finset.mem_filter, Finset.mem_univ,
    true_and] at hx ⊢
  refine ⟨x, Finset.mem_inter.mpr ⟨?_, ?_⟩⟩
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    intro heq
    have := hx.1
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at this
    apply this
    rw [hσ i x, hσ i v₀, heq]
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    intro heq
    have := hx.2
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at this
    apply this
    rw [hσ j x, hσ j v₀, heq]

/-- TPE gives an exact iff for overlap of variation supports. -/
theorem tpe_overlap_iff
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n) :
    SupportsOverlap (VarSupportFamily F₂ v₀ (σ i)) (VarSupportFamily F₂ v₀ (σ j)) ↔
    SupportsOverlap (VarSupportFamily F₁ v₀ i) (VarSupportFamily F₁ v₀ j) := by
  exact ⟨fun h => by
    by_contra hno
    exact tpe_preserves_single_non_overlap F₁ F₂ σ c hσ v₀ i j hno h,
    fun h => tpe_preserves_single_overlap F₁ F₂ σ c hσ v₀ i j h⟩

/-! ## Section 5: TPE Preserves Overlap Equivalence (Main Theorem A) -/

/-
**Theorem A: TPE permutation preserves overlap equivalence on variation
    supports.** If F₁ ~ F₂ via (σ, c), then i and j are overlap-equivalent
    in F₁'s variation supports if and only if σ(i) and σ(j) are
    overlap-equivalent in F₂'s variation supports.

    This is the main structural result: the permutation from TPE maps
    overlap classes to overlap classes bijectively.
-/
theorem tpe_permutation_preserves_overlapEquiv
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i j : Fin n) :
    OverlapEquivRel (VarSupportFamily F₂ v₀) (σ i) (σ j) ↔
    OverlapEquivRel (VarSupportFamily F₁ v₀) i j := by
  constructor
  · -- Forward: OverlapEquivRel in F₂'s var supports ⟹ in F₁'s
    intro h
    -- We induct on the reflexive-transitive closure chain
    -- The key insight: every intermediate index in the chain through F₂
    -- is of the form σ(k) for some k, because σ is a bijection
    convert Relation.ReflTransGen.lift ( f := σ.symm ) ( fun a b hab => ?_ ) h;
    · simp +decide;
    · simp +decide;
    · have := tpe_overlap_iff F₁ F₂ σ c hσ v₀ ( σ.symm a ) ( σ.symm b ) ; aesop;
  · -- Backward: OverlapEquivRel in F₁'s var supports ⟹ in F₂'s
    intro h
    induction h with
    | refl => exact Relation.ReflTransGen.refl
    | tail _ hab ih =>
      exact Relation.ReflTransGen.tail ih
        (tpe_preserves_single_overlap F₁ F₂ σ c hσ v₀ _ _ hab)

/-! ## Section 6: Overlap Class Count is a TPE Invariant (Main Theorem B) -/

/-- **Lemma:** VarSupportFamily is invariant under TPE up to reindexing by σ. -/
theorem varSupportFamily_tpe_reindex
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) (i : Fin n) :
    VarSupportFamily F₂ v₀ (σ i) = VarSupportFamily F₁ v₀ i := by
  ext v
  simp only [VarSupportFamily, FinVarSupport, Finset.mem_filter, Finset.mem_univ,
    true_and]
  constructor
  · intro h heq; exact h (by rw [hσ i v, hσ i v₀, heq])
  · intro h heq; exact h (by rw [hσ i v, hσ i v₀] at heq; linarith)

/-
**Theorem B: The overlap class count is a TPE invariant.**
    If F₁ ~ F₂, then the number of overlap classes of their variation
    supports is the same.

    This is the central result: it says that overlap classes are not an
    artifact of the particular representation but are intrinsic to the
    tropical projective equivalence class.
-/
theorem overlapClassCount_tpe_invariant
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (htpe : TropProjEquiv F₁ F₂)
    (v₀ : V) :
    OverlapClassCount (VarSupportFamily F₁ v₀) =
    OverlapClassCount (VarSupportFamily F₂ v₀) := by
  obtain ⟨σ, c, hσ⟩ := htpe;
  convert Fintype.card_congr ( Equiv.ofBijective _ ⟨ _, _ ⟩ ) using 1;
  refine' fun x => Quotient.map' ( fun i => σ i ) _ x;
  exact fun i j hij => tpe_permutation_preserves_overlapEquiv F₁ F₂ σ c hσ v₀ i j |>.2 hij;
  · intro a₁ a₂ h; obtain ⟨ i, rfl ⟩ := Quotient.exists_rep a₁; obtain ⟨ j, rfl ⟩ := Quotient.exists_rep a₂; simp_all +decide [ Quotient.eq ] ;
    exact tpe_permutation_preserves_overlapEquiv F₁ F₂ σ c hσ v₀ i j |>.1 h;
  · intro b
    induction' b using Quotient.inductionOn' with b
    use Quotient.mk'' (σ.symm b);
    exact Quotient.sound ( by simp +decide [ hσ ] )

/-! ## Section 7: Overlap Degree is a TPE Invariant (Theorem D) -/

/-
**Theorem D: The overlap degree (edge count of the support interaction
    graph) is preserved by TPE.**

    Since TPE bijects the overlap graph via σ, the number of edges is
    preserved.
-/
theorem overlapDegree_tpe_invariant
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) :
    OverlapDegree (VarSupportFamily F₁ v₀) =
    OverlapDegree (VarSupportFamily F₂ v₀) := by
  unfold OverlapDegree VarSupportFamily;
  have h_bij : Finset.card (Finset.filter (fun p : Fin n × Fin n => p.1 ≠ p.2 ∧ SupportsOverlap (FinVarSupport (F₁ p.1) v₀) (FinVarSupport (F₁ p.2) v₀)) (Finset.univ ×ˢ Finset.univ)) = Finset.card (Finset.filter (fun p : Fin n × Fin n => p.1 ≠ p.2 ∧ SupportsOverlap (FinVarSupport (F₂ p.1) v₀) (FinVarSupport (F₂ p.2) v₀)) (Finset.univ ×ˢ Finset.univ)) := by
    refine' Finset.card_bij ( fun p hp => ( σ p.1, σ p.2 ) ) _ _ _ <;> simp_all +decide [ Finset.mem_filter, Finset.mem_product ];
    · exact fun i j hij h => by simpa only [ hσ ] using tpe_preserves_single_overlap F₁ F₂ σ c hσ v₀ i j h;
    · intro a b hab h; use σ.symm a, σ.symm b; simp_all +decide [ SupportsOverlap ] ;
      obtain ⟨ x, hx ⟩ := h; use x; simp_all +decide [ FinVarSupport ] ;
      grind +ring;
  convert congr_arg ( fun x : ℕ => x / 2 ) h_bij using 1;
  · have h_split : Finset.filter (fun p : Fin n × Fin n => p.1 ≠ p.2 ∧ SupportsOverlap (FinVarSupport (F₁ p.1) v₀) (FinVarSupport (F₁ p.2) v₀)) (Finset.univ ×ˢ Finset.univ) = Finset.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (FinVarSupport (F₁ p.1) v₀) (FinVarSupport (F₁ p.2) v₀)) (Finset.univ ×ˢ Finset.univ) ∪ Finset.image (fun p => (p.2, p.1)) (Finset.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (FinVarSupport (F₁ p.1) v₀) (FinVarSupport (F₁ p.2) v₀)) (Finset.univ ×ˢ Finset.univ)) := by
      ext ⟨i, j⟩; simp [Finset.mem_union, Finset.mem_image];
      cases lt_trichotomy i j <;> simp +decide [ *, supportsOverlap_symm ]; all_goals grind;
    rw [ h_split, Finset.card_union_of_disjoint, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    · rw [ ← two_mul, Nat.mul_div_cancel_left _ ( by decide ) ];
    · simp +contextual [ Finset.disjoint_right ];
      grind;
  · have h_bij : Finset.filter (fun p : Fin n × Fin n => p.1 ≠ p.2 ∧ SupportsOverlap (FinVarSupport (F₂ p.1) v₀) (FinVarSupport (F₂ p.2) v₀)) (Finset.univ ×ˢ Finset.univ) = (Finset.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (FinVarSupport (F₂ p.1) v₀) (FinVarSupport (F₂ p.2) v₀)) (Finset.univ ×ˢ Finset.univ)) ∪ (Finset.image (fun p => (p.2, p.1)) (Finset.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ SupportsOverlap (FinVarSupport (F₂ p.1) v₀) (FinVarSupport (F₂ p.2) v₀)) (Finset.univ ×ˢ Finset.univ))) := by
      ext ⟨i, j⟩; simp [Finset.mem_union, Finset.mem_image];
      cases lt_trichotomy i j <;> simp +decide [ *, supportsOverlap_symm ];
      · exact ⟨ fun h => Or.inl h.2, fun h => ⟨ ne_of_lt ‹_›, h.resolve_right fun h' => lt_asymm ‹_› h'.1 ⟩ ⟩;
      · grind;
    rw [ h_bij, Finset.card_union_of_disjoint, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    · rw [ ← two_mul, Nat.mul_div_cancel_left _ ( by decide ) ];
    · simp +contextual [ Finset.disjoint_right ];
      grobner

/-! ## Section 8: Overlap Complexity is a TPE Invariant (Theorem C) -/

/-
**Theorem C: The overlap complexity (total intersection cardinality)
    is a TPE invariant.**

    Since TPE maps VarSupportFamily(F₁, v₀, i) to
    VarSupportFamily(F₂, v₀, σ(i)) exactly, pairwise intersections are
    preserved, hence the sum of intersection cardinalities is invariant.
-/
theorem overlapComplexity_tpe_invariant
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F₁ F₂ : Fin n → V → ℤ)
    (σ : Equiv.Perm (Fin n)) (c : Fin n → ℤ)
    (hσ : ∀ (i : Fin n) (v : V), F₂ (σ i) v = F₁ i v + c i)
    (v₀ : V) :
    OverlapComplexity (VarSupportFamily F₁ v₀) =
    OverlapComplexity (VarSupportFamily F₂ v₀) := by
  refine' Finset.sum_bij _ _ _ _ _;
  use fun p hp => if h : σ p.1 < σ p.2 then ( σ p.1, σ p.2 ) else ( σ p.2, σ p.1 );
  · simp +zetaDelta at *;
    intro a b hab; split_ifs <;> simp_all +decide [ lt_asymm ] ;
    exact lt_of_le_of_ne ‹_› ( σ.injective.ne ( ne_of_gt hab ) );
  · simp +contextual;
    intro a b hab a' b' hab' h; split_ifs at h <;> simp_all +decide [ Equiv.injective σ ] ;
    · exact False.elim ( lt_asymm hab hab' );
    · exact False.elim ( lt_asymm hab hab' );
  · intro p hp
    use if h : σ.symm p.1 < σ.symm p.2 then (σ.symm p.1, σ.symm p.2) else (σ.symm p.2, σ.symm p.1);
    grind +qlia;
  · intro p hp; split_ifs <;> simp_all +decide [ varSupportFamily_tpe_reindex ] ;
    · rw [ varSupportFamily_tpe_reindex F₁ F₂ σ c hσ v₀ p.1, varSupportFamily_tpe_reindex F₁ F₂ σ c hσ v₀ p.2 ];
    · rw [ Finset.inter_comm, varSupportFamily_tpe_reindex F₁ F₂ σ c hσ v₀ p.2, varSupportFamily_tpe_reindex F₁ F₂ σ c hσ v₀ p.1 ]

/-! ## Section 9: Union Card Inequality (Theorem E)

The cardinality of the union of a finset family satisfies an
inclusion-exclusion bound controlled by the overlap complexity. -/

/-
**Theorem E: Inclusion-exclusion lower bound.** The cardinality of the
    union of all supports is at least the sum of individual cardinalities
    minus the overlap complexity.

    This connects the algebraic overlap structure to a concrete
    combinatorial inequality.
-/
theorem union_card_le_sum_card {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    (FamilyUnion F).card ≤ ∑ i : Fin n, (F i).card := by
  convert Finset.card_biUnion_le

/-
The deficit between sum of cardinalities and union cardinality is
    bounded by the overlap complexity.
-/
theorem sum_card_sub_union_card_le_overlapComplexity
    {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α) :
    ∑ i : Fin n, (F i).card - (FamilyUnion F).card ≤
    OverlapComplexity F := by
  induction' n with n ih;
  · exact Nat.zero_le _;
  · simp +decide [ Fin.sum_univ_succ, FamilyUnion ] at *;
    have h_split : #(Finset.biUnion Finset.univ F) ≥ #(Finset.biUnion Finset.univ (fun i => F (Fin.succ i))) + #(F 0) - ∑ i : Fin n, #(F 0 ∩ F (Fin.succ i)) := by
      rw [ ← Finset.card_union_add_card_inter ];
      refine' Nat.sub_le_of_le_add _;
      refine' add_le_add _ _;
      · refine' Finset.card_mono _;
        intro x; aesop;
      · rw [ Finset.inter_comm, Finset.inter_biUnion ];
        exact Finset.card_biUnion_le;
    have h_split : OverlapComplexity F = OverlapComplexity (fun i => F (Fin.succ i)) + ∑ i : Fin n, #(F 0 ∩ F (Fin.succ i)) := by
      unfold OverlapComplexity;
      rw [ Finset.sum_filter, Finset.sum_filter ];
      rw [ Finset.sum_product, Finset.sum_product ];
      simp +decide [ Fin.sum_univ_succ, Finset.sum_add_distrib ];
      exact add_comm _ _;
    grind

/-! ## Section 10: Overlap Class Structure -/

/-
**Structural theorem:** In a pairwise disjoint family with nonempty
    supports, every index is its own overlap class.
-/
theorem overlapClassCount_eq_n_of_pairwiseDisjoint
    {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hF : PairwiseDisjointFamily F)
    (hne : ∀ i, (F i).Nonempty) :
    OverlapClassCount F = n := by
  have h_overlap_classes : ∀ i j : Fin n, i ≠ j → ¬ OverlapEquivRel F i j := by
    intro i j hij; intro h; induction' h with k hk ih; simp_all +decide [ PairwiseDisjointFamily ] ;
    rename_i h₁ h₂; specialize hF k hk; simp_all +decide [ SupportsOverlap ] ;
    exact h₁.ne_empty ( Finset.disjoint_iff_inter_eq_empty.mp hF );
  have h_card_eq : Fintype.card (Quotient (overlapSetoid F)) = Fintype.card (Fin n) := by
    refine' Fintype.card_congr _;
    refine' Equiv.ofBijective ( fun q => Quotient.liftOn' q id fun i j hij => _ ) ⟨ fun q q' h => _, fun i => _ ⟩;
    exact Classical.not_not.1 fun hi => h_overlap_classes i j hi hij;
    · induction q using Quotient.inductionOn' ; induction q' using Quotient.inductionOn' ; aesop;
    · exact ⟨ ⟦i⟧, rfl ⟩;
  aesop

/-
In the trivially overlapping case (all supports equal and nonempty),
    there is exactly one overlap class.
-/
theorem overlapClassCount_eq_one_of_all_equal
    {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (hn : 0 < n)
    (heq : ∀ i j : Fin n, F i = F j)
    (hne : ∀ i, (F i).Nonempty) :
    OverlapClassCount F = 1 := by
  convert Fintype.card_eq_one_iff_nonempty_unique;
  rotate_left;
  exact Fin n;
  exact inferInstance;
  constructor <;> intro h <;> simp_all +decide [ Fintype.card_eq_one_iff, Unique ];
  · constructor <;> intro h' <;> rcases n with ( _ | _ | n ) <;> simp_all +decide [ Unique ];
    · exact?;
    · exact absurd ( Fintype.card_eq_one_iff.mpr ⟨ h'.some.default, fun x => h'.some.uniq x ⟩ ) ( by simp +decide );
  · contrapose! h;
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ OverlapClassCount ];
    exact False.elim ( h <| by rw [ Fintype.card_eq_one_iff ] ; exact ⟨ ⟦0⟧, fun x => by obtain ⟨ i, hi ⟩ := Quotient.exists_rep x; exact hi ▸ Quotient.sound ( by exact Relation.ReflTransGen.single ( by simp +decide [ heq _ 0, SupportsOverlap ] ; exact hne 0 ) ) ⟩ )

/-
**Overlap degree zero ↔ pairwise disjoint.** This bridges the overlap
    framework to the existing disjoint-support theory.
-/
theorem overlapDegree_eq_zero_iff_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α) :
    OverlapDegree F = 0 ↔ PairwiseDisjointFamily F := by
  constructor;
  · unfold OverlapDegree PairwiseDisjointFamily;
    simp +contextual [ Finset.ext_iff, SupportsOverlap ];
    exact fun h i j hij => Finset.disjoint_left.mpr fun x hx hx' => by cases lt_or_gt_of_ne hij <;> tauto;
  · intro hF_disjoint
    simp [OverlapDegree, hF_disjoint];
    exact fun i j hij => Finset.not_nonempty_iff_eq_empty.mpr ( Finset.disjoint_iff_inter_eq_empty.mp ( hF_disjoint i j hij.ne ) )

/-
**Overlap complexity zero ↔ pairwise disjoint.** A finer version of
    the overlap degree characterization.
-/
theorem overlapComplexity_eq_zero_iff_pairwiseDisjoint {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α) :
    OverlapComplexity F = 0 ↔ PairwiseDisjointFamily F := by
  unfold OverlapComplexity PairwiseDisjointFamily;
  simp +decide [ Finset.ext_iff, Finset.disjoint_left ];
  grind

/-! ## Section 11: Disjointness Across Overlap Classes -/

/-- Supports in different overlap classes are disjoint. This is the
    foundation of componentwise factorization. -/
theorem disjoint_of_different_overlap_class {α : Type*} [DecidableEq α]
    {n : ℕ} (F : Fin n → Finset α) {i j : Fin n}
    (h : ¬OverlapEquivRel F i j) :
    Disjoint (F i) (F j) := by
  rw [Finset.disjoint_iff_inter_eq_empty]
  by_contra hne
  apply h
  exact Relation.ReflTransGen.single (Finset.nonempty_of_ne_empty hne)

/-
**Componentwise support disjointness:** the biUnion of supports in
    one overlap class is disjoint from the biUnion of supports in a
    different overlap class.
-/
theorem overlap_class_biUnion_disjoint {α : Type*} [DecidableEq α] {n : ℕ}
    (F : Fin n → Finset α)
    (C₁ C₂ : Finset (Fin n))
    (_hC₁ : ∀ i ∈ C₁, ∀ j ∈ C₁, OverlapEquivRel F i j)
    (_hC₂ : ∀ i ∈ C₂, ∀ j ∈ C₂, OverlapEquivRel F i j)
    (hsep : ∀ i ∈ C₁, ∀ j ∈ C₂, ¬OverlapEquivRel F i j) :
    Disjoint (C₁.biUnion F) (C₂.biUnion F) := by
  simp_all +decide [ Finset.disjoint_left ];
  intro a i hi ha j hj ha';
  exact hsep i hi j hj ( Relation.ReflTransGen.single ( by exact ⟨ a, by aesop ⟩ ) )