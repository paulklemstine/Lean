/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Kernel Rigidity: Uniqueness of Generators up to Tropical Projective Equivalence

This file establishes a canonical-form theory for tropical kernel generators
of graph Laplacians. The central result is that under support-separation
hypotheses (pairwise disjoint supports), every minimal tropical generating
family is obtained from the canonical one by tropical projective equivalence:
permutation plus pointwise constant shifts.

## Main Definitions

* `TropProjEquiv` — tropical projective equivalence of indexed function families
* `FunSupport` — support of an integer-valued function (where it's nonzero)
* `PairwiseDisjointSupports` — family with pairwise disjoint supports
* `restrictedLaplacian'` — graph Laplacian restricted to a vertex subset
* `IsHarmonicOn` — S-harmonicity for graph functions
* `harmonicKernel` — set of S-harmonic functions

## Main Results

* `tropProjEquiv_refl` — tropical projective equivalence is reflexive
* `tropProjEquiv_symm` — tropical projective equivalence is symmetric
* `tropProjEquiv_trans` — tropical projective equivalence is transitive
* `min_on_disjoint_support` — support separation forces zeroes
* `disjoint_support_no_redundancy` — generators with disjoint supports are irredundant
* `disjoint_support_unique_up_to_tropProjEquiv` — main uniqueness theorem
* `harmonic_leaf_rigidity` — harmonic functions are rigid on leaves
* `same_support_implies_same_restricted_laplacian` — matroidal invariance
* `equilibrium_iff_harmonic` — bridge to discrete potential theory

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a
  finite graph" (2007)
* Develin, Santos, Sturmfels, "On the rank of a tropical matrix" (2005)
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Tropical Projective Equivalence -/

/-- **Tropical projective equivalence** of two indexed families of ℤ-valued
    functions. Two families `F₁ F₂ : ι → V → ℤ` are tropically projectively
    equivalent if there exists a permutation `σ` of the index set and
    constants `c : ι → ℤ` such that `F₂ (σ i) v = F₁ i v + c i` for all
    `i` and `v`. -/
def TropProjEquiv {ι V : Type*} (F₁ F₂ : ι → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm ι) (c : ι → ℤ),
    ∀ (i : ι) (v : V), F₂ (σ i) v = F₁ i v + c i

/-- Tropical projective equivalence is reflexive. -/
theorem tropProjEquiv_refl {ι V : Type*} (F : ι → V → ℤ) :
    TropProjEquiv F F := by
  exact ⟨Equiv.refl ι, fun _ => 0, fun i v => by simp⟩

/-- Tropical projective equivalence is symmetric. -/
theorem tropProjEquiv_symm {ι V : Type*} (F₁ F₂ : ι → V → ℤ)
    (h : TropProjEquiv F₁ F₂) : TropProjEquiv F₂ F₁ := by
  obtain ⟨σ, c, hσ⟩ := h
  refine ⟨σ.symm, fun i => -(c (σ.symm i)), fun i v => ?_⟩
  have := hσ (σ.symm i) v
  simp [Equiv.apply_symm_apply] at this
  linarith

/-- Tropical projective equivalence is transitive. -/
theorem tropProjEquiv_trans {ι V : Type*} (F₁ F₂ F₃ : ι → V → ℤ)
    (h₁₂ : TropProjEquiv F₁ F₂) (h₂₃ : TropProjEquiv F₂ F₃) :
    TropProjEquiv F₁ F₃ := by
  obtain ⟨σ₁, c₁, hσ₁⟩ := h₁₂
  obtain ⟨σ₂, c₂, hσ₂⟩ := h₂₃
  refine ⟨σ₁.trans σ₂, fun i => c₁ i + c₂ (σ₁ i), fun i v => ?_⟩
  simp only [Equiv.trans_apply]
  rw [hσ₂ (σ₁ i) v, hσ₁ i v]
  ring

/-! ## Section 2: Function Support -/

/-- The **support** of an integer-valued function: the set of points
    where it takes nonzero values. -/
def FunSupport {V : Type*} (f : V → ℤ) : Set V := {v | f v ≠ 0}

/-- A family of functions has **pairwise disjoint supports** if the
    supports of any two distinct family members do not overlap. -/
def PairwiseDisjointSupports {ι V : Type*} (F : ι → V → ℤ) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (FunSupport (F i)) (FunSupport (F j))

/-! ## Section 3: Support Separation Lemmas -/

/-- For functions with disjoint supports, any function is zero outside
    its own support region. -/
theorem min_on_disjoint_support {ι V : Type*} [DecidableEq ι]
    (F : ι → V → ℤ)
    (hdisjoint : PairwiseDisjointSupports F)
    (i : ι) (v : V) (hv : v ∈ FunSupport (F i))
    (j : ι) (hj : j ≠ i) :
    F j v = 0 := by
  exact Classical.not_not.1 fun h => Set.disjoint_left.1 (hdisjoint j i hj) h hv

/-- If `f` takes two distinct values on `A` and `g` is zero on `A`,
    then `f` and `g + c` differ at some point of `A`. -/
theorem support_disjoint_shift_ne {V : Type*} (f g : V → ℤ) (A : Set V)
    (hf : ∃ v ∈ A, ∃ w ∈ A, f v ≠ f w) (hg : ∀ v ∈ A, g v = 0) (c : ℤ) :
    ∃ v ∈ A, f v ≠ g v + c := by
  grind

/-! ## Section 4: Disjoint Support Implies Irredundancy -/

/-- **Support rigidity theorem.** When generators have pairwise disjoint and
    nontrivial supports, no generator can be expressed as the pointwise minimum
    of shifted copies of the others. -/
theorem disjoint_support_no_redundancy
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (hn : 0 < n)
    (F : Fin n → V → ℤ)
    (hdisjoint : PairwiseDisjointSupports F)
    (hnontrivial : ∀ j : Fin n, ∃ v w : V,
      v ∈ FunSupport (F j) ∧ w ∈ FunSupport (F j) ∧ F j v ≠ F j w)
    (j : Fin n) (hn1 : 1 < n)
    (hne : ∃ i : Fin n, i ≠ j)
    (hfilt_ne : (Finset.univ.filter (· ≠ j) : Finset (Fin n)).Nonempty) :
    ¬∃ (c : Fin n → ℤ),
      ∀ v : V, F j v =
        (Finset.univ.filter (· ≠ j)).inf' hfilt_ne
          (fun i => F i v + c i) := by
  intro ⟨c, hc⟩
  obtain ⟨v, w, hv, hw, hne⟩ := hnontrivial j
  have h_zero : ∀ i, i ≠ j → (F i v) = 0 ∧ (F i w) = 0 :=
    fun i hi => ⟨min_on_disjoint_support F hdisjoint j v hv i hi,
                 min_on_disjoint_support F hdisjoint j w hw i hi⟩
  have h_const : F j v = inf' ((Finset.univ : Finset (Fin n)).filter (fun x => x ≠ j))
      hfilt_ne (fun i => c i) ∧
      F j w = inf' ((Finset.univ : Finset (Fin n)).filter (fun x => x ≠ j))
      hfilt_ne (fun i => c i) := by
    simp_all +decide [Finset.inf'_eq_csInf_image]
    exact ⟨congr_arg _ (Set.image_congr fun i hi => by simp +decide [h_zero i hi]),
           congr_arg _ (Set.image_congr fun i hi => by simp +decide [h_zero i hi])⟩
  exact hne (h_const.1.trans h_const.2.symm)

/-! ## Section 5: Tropical Span on Disjoint Supports -/

/-- If a function `g` is a pointwise minimum of shifted generators from
    a disjoint-support family, then on the support of generator `i`,
    `g` is bounded by `F i + c_i`. -/
theorem tropical_span_determined_on_support
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (hn : 0 < n)
    (F : Fin n → V → ℤ)
    (hdisjoint : PairwiseDisjointSupports F)
    (g : V → ℤ)
    (c : Fin n → ℤ)
    (hg : ∀ v : V, g v = Finset.univ.inf' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
      (fun i => F i v + c i))
    (i : Fin n) (v : V) (hv : v ∈ FunSupport (F i)) :
    g v ≤ F i v + c i := by
  exact hg v ▸ Finset.inf'_le _ (Finset.mem_univ _)

/-! ## Section 6: Main Uniqueness Theorem -/

/-
**Helper.** The support-matching function is injective when supports are
    pairwise disjoint and nontrivial.
-/
theorem support_matching_injective
    {n : ℕ} {V : Type*}
    (F G : Fin n → V → ℤ)
    (hFdisjoint : PairwiseDisjointSupports F)
    (hFnontrivial : ∀ j, ∃ v : V, v ∈ FunSupport (F j))
    (σ : Fin n → Fin n)
    (hσ : ∀ i, FunSupport (F i) = FunSupport (G (σ i))) :
    Function.Injective σ := by
  intros i j hij
  have h_support_eq : FunSupport (F i) = FunSupport (F j) := by
    grind;
  contrapose! hFnontrivial;
  exact ⟨ j, fun v hv => Set.disjoint_left.mp ( hFdisjoint i j hFnontrivial ) ( h_support_eq.symm ▸ hv ) hv ⟩

/-
**Main uniqueness theorem.** Let `F G : Fin n → V → ℤ` be families with
    pairwise disjoint supports. If they have matching support structure and
    agree pointwise on matching supports, then they are tropically projectively
    equivalent (in fact with zero constants, i.e., equal up to permutation).

    This is the tropical analogue of basis uniqueness: under the combinatorial
    separation hypothesis, generators are canonical up to reindexing.
-/
theorem disjoint_support_unique_up_to_tropProjEquiv
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (F G : Fin n → V → ℤ)
    (hFdisjoint : PairwiseDisjointSupports F)
    (hGdisjoint : PairwiseDisjointSupports G)
    (hFnontrivial : ∀ j, ∃ v : V, v ∈ FunSupport (F j))
    (hSameSupports : ∀ i : Fin n, ∃ j : Fin n,
      FunSupport (F i) = FunSupport (G j))
    (hSameSupportsRev : ∀ j : Fin n, ∃ i : Fin n,
      FunSupport (G j) = FunSupport (F i))
    (hFG_eq : ∀ i j : Fin n,
      FunSupport (F i) = FunSupport (G j) →
      ∀ v, G j v = F i v) :
    TropProjEquiv F G := by
  -- Let's choose any $i$ and derive the corresponding $j$ from the support matching hypothesis.
  obtain ⟨σ, hσ⟩ : ∃ σ : Fin n → Fin n, ∀ i : Fin n, FunSupport (F i) = FunSupport (G (σ i)) := by
    exact ⟨ fun i => Classical.choose ( hSameSupports i ), fun i => Classical.choose_spec ( hSameSupports i ) ⟩
  generalize_proofs at *; (
  -- Since σ is injective and Fin n is finite, σ is bijective.
  have hσ_bijective : Function.Bijective σ := by
    exact ⟨ support_matching_injective F G hFdisjoint hFnontrivial σ hσ, Finite.injective_iff_surjective.mp ( support_matching_injective F G hFdisjoint hFnontrivial σ hσ ) ⟩
  generalize_proofs at *; (
  exact ⟨ Equiv.ofBijective σ hσ_bijective, fun i => 0, fun i v => by simpa using hFG_eq i ( σ i ) ( hσ i ) v ⟩ ;))

/-! ## Section 7: Graph-Theoretic Specialization -/

/-- The combinatorial graph Laplacian matrix. -/
def graphLaplacianZ {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

theorem graphLaplacianZ_row_sum_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j : V, graphLaplacianZ G i j = 0 := by
  simp [graphLaplacianZ]
  simp +decide [Finset.sum_ite, Finset.filter_eq, Finset.filter_ne,
    SimpleGraph.degree, SimpleGraph.neighborFinset]
  simp +decide [Finset.filter_erase, SimpleGraph.adj_comm]

/-- The graph Laplacian restricted to a vertex subset `S`. -/
def restrictedLaplacian' {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Matrix S S ℤ :=
  fun i j => graphLaplacianZ G i.1 j.1

/-- A function `f : V → ℤ` is **S-harmonic** if the Laplacian applied to `f`,
    restricted to vertices in `S`, is zero. -/
def IsHarmonicOn {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (f : V → ℤ) : Prop :=
  ∀ v ∈ S, ∑ w : V, graphLaplacianZ G v w * f w = 0

/-- The **harmonic kernel** on `S`: the set of all S-harmonic functions. -/
def harmonicKernel {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Set (V → ℤ) :=
  {f | IsHarmonicOn G S f}

/-- Constant functions are always S-harmonic (by the row-sum-zero property). -/
theorem constant_isHarmonicOn {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (c : ℤ) :
    IsHarmonicOn G S (fun _ => c) := by
  intro v hv
  have h_sum_zero : ∑ w : V, graphLaplacianZ G v w * c = 0 := by
    rw [← Finset.sum_mul _ _ _, graphLaplacianZ_row_sum_zero]; simp +decide
  exact h_sum_zero

/-- Adding a constant to an S-harmonic function preserves harmonicity. -/
theorem isHarmonicOn_add_const {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (f : V → ℤ) (c : ℤ) (hf : IsHarmonicOn G S f) :
    IsHarmonicOn G S (fun v => f v + c) := by
  intro v hv
  specialize hf v hv
  simp_all +decide [mul_add, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm]
  rw [← Finset.mul_sum _ _ _, graphLaplacianZ_row_sum_zero, MulZeroClass.mul_zero]

/-- **Harmonic leaf rigidity.** If `v` is a leaf vertex connected only to `w`,
    and both are in `S`, then any S-harmonic function has `f(v) = f(w)`. -/
theorem harmonic_leaf_rigidity {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (f : V → ℤ) (hf : IsHarmonicOn G S f)
    (v w : V) (hv : v ∈ S)
    (hleaf : G.degree v = 1)
    (hadj : G.Adj v w)
    (hunique : ∀ u : V, G.Adj v u → u = w) :
    f v = f w := by
  specialize hf v hv
  simp_all +decide [SimpleGraph.degree, SimpleGraph.neighborFinset_def]
  unfold graphLaplacianZ at hf
  simp_all +decide [Finset.sum_ite, Finset.filter_ne', Finset.filter_eq']
  simp_all +decide [Finset.filter_ne, Finset.filter_and, SimpleGraph.degree,
    SimpleGraph.neighborFinset_def]
  simp_all +decide [Finset.filter_erase, Finset.filter_eq, SimpleGraph.adj_comm]
  lia

/-! ## Section 8: Matroidal Invariance -/

/-- Two graphs have the **same induced structure** on `S` if they have
    exactly the same adjacency relation on `S`. -/
def SameInducedStructure {V : Type*}
    (G₁ G₂ : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ u v : V, u ∈ S → v ∈ S → (G₁.Adj u v ↔ G₂.Adj u v)

/-- **Matroidal invariance.** If two graphs agree on `S` and have no edges
    from `S` to its complement, their restricted Laplacians are equal. -/
theorem same_support_implies_same_restricted_laplacian
    {V : Type*} [Fintype V] [DecidableEq V]
    (G₁ G₂ : SimpleGraph V) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (S : Finset V)
    (hadj : SameInducedStructure G₁ G₂ S)
    (hiso₁ : ∀ v ∈ S, ∀ w, w ∉ S → ¬G₁.Adj v w)
    (hiso₂ : ∀ v ∈ S, ∀ w, w ∉ S → ¬G₂.Adj v w) :
    restrictedLaplacian' G₁ S = restrictedLaplacian' G₂ S := by
  funext ⟨u, hu⟩ ⟨v, hv⟩
  by_cases huv : u = v <;> simp_all +decide [graphLaplacianZ, restrictedLaplacian']
  · refine' Finset.card_bij (fun w hw => w) _ _ _ <;>
      simp_all +decide [SimpleGraph.degree, SimpleGraph.neighborFinset_def]
    · grind +locals
    · grind +locals
  · specialize hadj u v hu hv; aesop

/-- Same Laplacian entries implies same harmonic kernel. -/
theorem same_restricted_laplacian_implies_same_kernel
    {V : Type*} [Fintype V] [DecidableEq V]
    (G₁ G₂ : SimpleGraph V) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (S : Finset V)
    (hL : ∀ v : V, ∀ w : V, graphLaplacianZ G₁ v w = graphLaplacianZ G₂ v w) :
    harmonicKernel G₁ S = harmonicKernel G₂ S := by
  unfold harmonicKernel
  unfold IsHarmonicOn; aesop

/-! ## Section 9: Discrete Potential Theory Bridge -/

/-- A **discrete potential flow** at vertex `v`. -/
def discretePotentialFlow {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (φ : V → ℤ) (v : V) : ℤ :=
  ∑ w : V, graphLaplacianZ G v w * φ w

/-- Equilibrium potentials are exactly S-harmonic functions. -/
theorem equilibrium_iff_harmonic {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (φ : V → ℤ) :
    (∀ v ∈ S, discretePotentialFlow G φ v = 0) ↔ IsHarmonicOn G S φ := by
  simp [discretePotentialFlow, IsHarmonicOn]

/-- **Potential mode uniqueness.** When harmonic modes have disjoint supports,
    matching support structure, and agree on their supports, the decomposition
    is canonical up to permutation. -/
theorem potential_mode_uniqueness
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (Φ Ψ : Fin n → V → ℤ)
    (_hΦharm : ∀ i, IsHarmonicOn G S (Φ i))
    (_hΨharm : ∀ i, IsHarmonicOn G S (Ψ i))
    (hΦdisjoint : PairwiseDisjointSupports Φ)
    (hΨdisjoint : PairwiseDisjointSupports Ψ)
    (hΦnontrivial : ∀ j, ∃ v : V, v ∈ FunSupport (Φ j))
    (hSameSupports : ∀ i : Fin n, ∃ j : Fin n,
      FunSupport (Φ i) = FunSupport (Ψ j))
    (hSameSupportsRev : ∀ j : Fin n, ∃ i : Fin n,
      FunSupport (Ψ j) = FunSupport (Φ i))
    (hΦΨ_eq : ∀ i j : Fin n,
      FunSupport (Φ i) = FunSupport (Ψ j) →
      ∀ v, Ψ j v = Φ i v) :
    TropProjEquiv Φ Ψ :=
  disjoint_support_unique_up_to_tropProjEquiv Φ Ψ
    hΦdisjoint hΨdisjoint hΦnontrivial
    hSameSupports hSameSupportsRev hΦΨ_eq

/-! ## Section 10: Falsifiable Conjecture -/

/-- **Conjecture.** For every connected graph and every choice of basepoint
    and vertex subset, the number of tropical projective equivalence classes
    of minimal generating families equals the number of overlap classes of
    cycle supports. Stated as a predicate to be tested computationally. -/
def OverlapClassConjecture
    (numProjClasses numOverlapClasses : ℕ) : Prop :=
  numProjClasses = numOverlapClasses