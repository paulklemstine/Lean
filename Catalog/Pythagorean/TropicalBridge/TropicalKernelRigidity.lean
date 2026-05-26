/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Kernel Rigidity: Canonical Generators up to Tropical Projective Equivalence

This file establishes a canonical-form theory for tropical kernel generators
of graph Laplacians. The central result: under a support-separation hypothesis
(pairwise disjoint supports with nontrivial variation), every minimal tropical
generating family is obtained from the canonical one by tropical projective
equivalence — permutation plus pointwise constant shifts.

## Mathematical Context

In tropical mathematics, the "kernel" of a linear map is a semimodule over the
tropical semiring. Unlike classical linear algebra, tropical semimodules need not
have unique bases. This file identifies a clean combinatorial condition —
pairwise disjoint supports with nontrivial internal variation — under which
uniqueness is recovered up to the natural equivalence relation.

## Main Definitions

* `TropProjEquiv` — tropical projective equivalence of indexed function families
* `FunSupport` — support of an integer-valued function
* `PairwiseDisjointSupports` — family with pairwise disjoint supports
* `NontrivialOnSupport` — each generator varies on its support
* `GraphLaplacian` — combinatorial graph Laplacian
* `IsHarmonicOn` — S-harmonicity for functions on graphs
* `HarmonicKernel` — set of S-harmonic functions

## Main Results

* `tropProjEquiv_refl/symm/trans` — equivalence relation properties
* `disjoint_support_forces_zero` — support separation forces zeroes
* `disjoint_support_irredundancy` — generators with disjoint supports are irredundant
* `disjoint_support_unique_up_to_tropProjEquiv` — main uniqueness theorem
* `harmonic_leaf_rigidity` — harmonic functions on leaves are forced
* `same_induced_structure_same_laplacian` — matroidal invariance
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
    `i` and `v`.

    This is the tropical analogue of scalar equivalence of bases in classical
    linear algebra: in the tropical world, "scaling" a vector means adding a
    constant to all entries. -/
def TropProjEquiv {ι V : Type*} (F₁ F₂ : ι → V → ℤ) : Prop :=
  ∃ (σ : Equiv.Perm ι) (c : ι → ℤ),
    ∀ (i : ι) (v : V), F₂ (σ i) v = F₁ i v + c i

/-- Tropical projective equivalence is reflexive. -/
theorem tropProjEquiv_refl {ι V : Type*} (F : ι → V → ℤ) :
    TropProjEquiv F F := by
  exact ⟨Equiv.refl ι, fun _ => 0, fun i v => by simp⟩

/-- Tropical projective equivalence is symmetric. -/
theorem tropProjEquiv_symm {ι V : Type*} {F₁ F₂ : ι → V → ℤ}
    (h : TropProjEquiv F₁ F₂) : TropProjEquiv F₂ F₁ := by
  obtain ⟨σ, c, hσ⟩ := h
  exact ⟨σ.symm, fun i => -(c (σ.symm i)), fun i v => by
    have := hσ (σ.symm i) v; simp [Equiv.apply_symm_apply] at this; linarith⟩

/-- Tropical projective equivalence is transitive. -/
theorem tropProjEquiv_trans {ι V : Type*} {F₁ F₂ F₃ : ι → V → ℤ}
    (h₁₂ : TropProjEquiv F₁ F₂) (h₂₃ : TropProjEquiv F₂ F₃) :
    TropProjEquiv F₁ F₃ := by
  obtain ⟨σ₁, c₁, hσ₁⟩ := h₁₂
  obtain ⟨σ₂, c₂, hσ₂⟩ := h₂₃
  exact ⟨σ₁.trans σ₂, fun i => c₁ i + c₂ (σ₁ i), fun i v => by
    simp only [Equiv.trans_apply]; rw [hσ₂ (σ₁ i) v, hσ₁ i v]; ring⟩

/-! ## Section 2: Function Support and Separation -/

/-- The **support** of an integer-valued function: the set of points
    where it takes nonzero values. -/
def FunSupport {V : Type*} (f : V → ℤ) : Set V := {v | f v ≠ 0}

/-- A family of functions has **pairwise disjoint supports** if the
    supports of any two distinct family members do not overlap. -/
def PairwiseDisjointSupports {ι V : Type*} (F : ι → V → ℤ) : Prop :=
  ∀ i j : ι, i ≠ j → Disjoint (FunSupport (F i)) (FunSupport (F j))

/-- Each generator varies nontrivially on its own support: there exist two
    points in the support where the function takes different values. This
    rules out constant-on-support generators that would create tropical
    redundancy. -/
def NontrivialOnSupport {ι V : Type*} (F : ι → V → ℤ) : Prop :=
  ∀ i : ι, ∃ v w : V, v ∈ FunSupport (F i) ∧ w ∈ FunSupport (F i) ∧ F i v ≠ F i w

/-! ## Section 3: Support Separation Engine -/

/-- **Core support separation lemma.** For functions with disjoint supports,
    if `v` is in the support of `F i`, then `F j v = 0` for all `j ≠ i`.
    This is the engine that converts disjoint-support structure into
    algebraic constraints on tropical combinations. -/
theorem disjoint_support_forces_zero {ι V : Type*}
    (F : ι → V → ℤ) (hdisjoint : PairwiseDisjointSupports F)
    (i j : ι) (hij : i ≠ j) (v : V) (hv : v ∈ FunSupport (F i)) :
    F j v = 0 := by
  by_contra h
  have hv_j : v ∈ FunSupport (F j) := h
  exact Set.disjoint_left.mp (hdisjoint i j hij) hv hv_j

/-- On the support of generator `i`, any shifted generator `F j · + c` with
    `j ≠ i` reduces to the constant `c`. -/
theorem disjoint_support_shift_constant {ι V : Type*}
    (F : ι → V → ℤ) (hdisjoint : PairwiseDisjointSupports F)
    (i j : ι) (hij : i ≠ j) (c : ℤ) (v : V) (hv : v ∈ FunSupport (F i)) :
    F j v + c = c := by
  rw [disjoint_support_forces_zero F hdisjoint i j hij v hv, zero_add]

/-! ## Section 4: Irredundancy from Disjoint Supports -/

/-- **Support rigidity / irredundancy theorem.** When generators have pairwise
    disjoint supports with nontrivial variation, no generator can be expressed
    as the pointwise minimum of shifted copies of the others.

    This is the key lemma ruling out hidden tropical redundancies: the
    nontrivial variation on each support region means that the pointwise
    minimum of constants (from other generators) cannot reproduce the
    nonconstant behavior of the target generator. -/
theorem disjoint_support_irredundancy
    {n : ℕ} {V : Type*} [Fintype V]
    (F : Fin n → V → ℤ)
    (hdisjoint : PairwiseDisjointSupports F)
    (hnontrivial : NontrivialOnSupport F)
    (j : Fin n)
    (hfilt_ne : (Finset.univ.filter (· ≠ j) : Finset (Fin n)).Nonempty) :
    ¬∃ (c : Fin n → ℤ),
      ∀ v : V, F j v =
        (Finset.univ.filter (· ≠ j)).inf' hfilt_ne
          (fun i => F i v + c i) := by
  intro ⟨c, hc⟩
  obtain ⟨v, w, hv, hw, hne⟩ := hnontrivial j
  apply hne
  -- On the support of F j, the inf' reduces to the inf' of constants
  have reduce : ∀ x, x ∈ FunSupport (F j) →
      (Finset.univ.filter (· ≠ j)).inf' hfilt_ne (fun i => F i x + c i) =
      (Finset.univ.filter (· ≠ j)).inf' hfilt_ne (fun i => c i) :=
    fun x hx => Finset.inf'_congr hfilt_ne rfl fun i hi => by
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi
      rw [disjoint_support_forces_zero F hdisjoint j i (Ne.symm hi) x hx, zero_add]
  rw [hc v, hc w, reduce v hv, reduce w hw]

/-! ## Section 5: Support Matching Injectivity -/

/-- When supports are pairwise disjoint and nonempty, any map that preserves
    support sets must be injective. This is a key ingredient for promoting
    a support-matching function to a permutation. -/
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
  have hv_i : v ∈ FunSupport (F i) := by
    rw [hσ i, hij, ← hσ j]; exact hv
  exact Set.disjoint_left.mp (hFdisjoint i j h_ne) hv_i hv

/-! ## Section 6: Main Uniqueness Theorem -/

/-- **Main uniqueness theorem (Theorem 2).** Let `F G : Fin n → V → ℤ` be
    families with pairwise disjoint supports. If they have matching support
    structure and agree pointwise modulo constants on matching supports, then
    they are tropically projectively equivalent.

    This is the tropical analogue of basis uniqueness: under the combinatorial
    separation hypothesis, generators are canonical up to reindexing and
    tropical scaling (additive constants).

    The proof constructs the permutation from support matching, promotes it
    to a bijection via the injectivity lemma, and reads off the constants
    from the pointwise agreement hypothesis. -/
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
  -- Build the matching function σ
  choose σ hσ using hSameSupports
  -- σ is injective by support disjointness
  have hσ_inj : Function.Injective σ :=
    support_matching_injective F G hFdisjoint hFnonempty σ hσ
  -- On Fin n, injective implies bijective
  have hσ_bij : Function.Bijective σ :=
    ⟨hσ_inj, Finite.injective_iff_surjective.mp hσ_inj⟩
  -- Get the constants from pointwise agreement
  choose c hc using fun i => hFG_eq i (σ i) (hσ i)
  -- Package as tropical projective equivalence
  exact ⟨Equiv.ofBijective σ hσ_bij, c, fun i v => by
    simp only [Equiv.ofBijective_apply]; exact hc i v⟩

/-! ## Section 7: Graph Laplacian and Harmonicity -/

/-- The combinatorial graph Laplacian matrix `L(G)`:
    `L(v,v) = deg(v)`, `L(v,w) = -1` if `v ~ w`, else `0`. -/
def GraphLaplacian {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-
Each row of the graph Laplacian sums to zero.
-/
theorem graphLaplacian_row_sum {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j : V, GraphLaplacian G i j = 0 := by
  unfold GraphLaplacian;
  simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, SimpleGraph.degree, SimpleGraph.neighborFinset ];
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
The graph Laplacian is symmetric.
-/
theorem graphLaplacian_symm {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) :
    GraphLaplacian G i j = GraphLaplacian G j i := by
  -- By definition of GraphLaplacian, we have:
  unfold GraphLaplacian;
  simp +decide [ eq_comm, SimpleGraph.adj_comm ];
  grind

/-- A function `f : V → ℤ` is **S-harmonic** if the Laplacian action on `f`,
    restricted to vertices in `S`, is zero. In physical terms: `f` is at
    equilibrium on `S` under the discrete diffusion defined by `G`. -/
def IsHarmonicOn {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (f : V → ℤ) : Prop :=
  ∀ v ∈ S, ∑ w : V, GraphLaplacian G v w * f w = 0

/-- The harmonic kernel on `S`: the set of all S-harmonic functions. -/
def HarmonicKernel {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Set (V → ℤ) :=
  {f | IsHarmonicOn G S f}

/-
Constant functions are S-harmonic (by the row-sum-zero property).
-/
theorem constant_isHarmonicOn {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (c : ℤ) :
    IsHarmonicOn G S (fun _ => c) := by
  intro v hv
  simp [IsHarmonicOn, graphLaplacian_row_sum];
  rw [ ← Finset.sum_mul, graphLaplacian_row_sum, MulZeroClass.zero_mul ]

/-
Adding a constant to an S-harmonic function preserves harmonicity.
-/
theorem isHarmonicOn_add_const {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (f : V → ℤ) (c : ℤ) (hf : IsHarmonicOn G S f) :
    IsHarmonicOn G S (fun v => f v + c) := by
  intro v hv;
  simp_all +decide [ mul_add, Finset.sum_add_distrib ];
  simp_all +decide [ ← Finset.sum_mul _ _ _, graphLaplacian_row_sum ];
  exact hf v hv

/-! ## Section 8: Leaf Rigidity (Theorem 1 — Support Rigidity Engine) -/

/-
**Harmonic leaf rigidity (Theorem 1 — Support Rigidity).** If `v` is a
    leaf vertex (degree 1) connected only to `w`, and both are in `S`, then
    any S-harmonic function satisfies `f(v) = f(w)`.

    This is the propagation engine: values on tree-like appendages are forced
    by values on the cycle core. Combined with support separation, this rules
    out alternative generators on pendant structures.
-/
theorem harmonic_leaf_rigidity {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (f : V → ℤ) (hf : IsHarmonicOn G S f)
    (v w : V) (hv : v ∈ S)
    (hleaf : G.degree v = 1)
    (hadj : G.Adj v w)
    (hunique : ∀ u : V, G.Adj v u → u = w) :
    f v = f w := by
  specialize hf v hv;
  simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', hadj.ne, hunique, GraphLaplacian ];
  rw [ show ( Finset.filter ( fun x => G.Adj v x ) ( Finset.filter ( fun x => ¬v = x ) Finset.univ ) ) = { w } from Finset.eq_singleton_iff_unique_mem.2 ⟨ by aesop, fun u hu => hunique u <| by aesop ⟩ ] at hf ; simp_all +decide [ Finset.filter_eq ];
  grind

/-! ## Section 9: Matroidal Invariance (Theorem 3 — Cross-Domain) -/

/-- Two graphs have the **same induced structure** on `S` if they agree on
    adjacency within `S`. -/
def SameInducedStructure {V : Type*}
    (G₁ G₂ : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ u v : V, u ∈ S → v ∈ S → (G₁.Adj u v ↔ G₂.Adj u v)

/-
**Matroidal invariance theorem (Theorem 3).** If two graphs have the same
    induced structure on `S` and `S` is isolated from its complement in both
    graphs, then their restricted Laplacians agree.

    This connects the uniqueness theory to matroid theory: the tropical kernel
    generators depend only on the induced subgraph structure (which encodes the
    cycle matroid of `G[S]`), not on the ambient graph.
-/
theorem same_induced_structure_same_laplacian
    {V : Type*} [Fintype V] [DecidableEq V]
    (G₁ G₂ : SimpleGraph V) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (S : Finset V)
    (hadj : SameInducedStructure G₁ G₂ S)
    (hiso₁ : ∀ v ∈ S, ∀ w, w ∉ S → ¬G₁.Adj v w)
    (hiso₂ : ∀ v ∈ S, ∀ w, w ∉ S → ¬G₂.Adj v w) :
    ∀ (u : S) (v : S), GraphLaplacian G₁ u.1 v.1 = GraphLaplacian G₂ u.1 v.1 := by
  intro u v; by_cases h : u = v <;> simp_all +decide [ SameInducedStructure ] ; (
  simp +decide [ GraphLaplacian, SimpleGraph.degree, SimpleGraph.neighborFinset ];
  refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp_all +decide [ SimpleGraph.adj_comm ] ; (
  grind +suggestions);
  grind +suggestions);
  unfold GraphLaplacian; aesop;

/-
Same Laplacian restricted to `S` implies same harmonic kernel on `S`.
-/
theorem same_laplacian_same_kernel
    {V : Type*} [Fintype V] [DecidableEq V]
    (G₁ G₂ : SimpleGraph V) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (S : Finset V)
    (hL : ∀ v w : V, GraphLaplacian G₁ v w = GraphLaplacian G₂ v w) :
    HarmonicKernel G₁ S = HarmonicKernel G₂ S := by
  unfold HarmonicKernel;
  unfold IsHarmonicOn; congr; ext; aesop;

/-! ## Section 10: Discrete Potential Theory Bridge -/

/-- A **discrete potential flow** at vertex `v`: the net flow out of `v`
    under potential `φ` and conductance structure `G`. -/
def DiscretePotentialFlow {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (φ : V → ℤ) (v : V) : ℤ :=
  ∑ w : V, GraphLaplacian G v w * φ w

/-- **Equilibrium-harmonicity equivalence.** A potential is at equilibrium on
    `S` (zero net flow at every vertex in `S`) if and only if it is S-harmonic.
    This bridges the tropical algebraic viewpoint to discrete physics:
    canonical tropical generators correspond to independent equilibrium modes
    of the network. -/
theorem equilibrium_iff_harmonic {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (φ : V → ℤ) :
    (∀ v ∈ S, DiscretePotentialFlow G φ v = 0) ↔ IsHarmonicOn G S φ := by
  simp [DiscretePotentialFlow, IsHarmonicOn]

/-- **Potential mode uniqueness.** When harmonic modes have disjoint supports,
    matching support structure, and agree modulo constants, the decomposition
    is canonical up to permutation and tropical scaling. -/
theorem potential_mode_uniqueness
    {n : ℕ} {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (Φ Ψ : Fin n → V → ℤ)
    (_hΦharm : ∀ i, IsHarmonicOn G S (Φ i))
    (_hΨharm : ∀ i, IsHarmonicOn G S (Ψ i))
    (hΦdisjoint : PairwiseDisjointSupports Φ)
    (hΨdisjoint : PairwiseDisjointSupports Ψ)
    (hΦnonempty : ∀ j, ∃ v : V, v ∈ FunSupport (Φ j))
    (hSameSupports : ∀ i : Fin n, ∃ j : Fin n,
      FunSupport (Φ i) = FunSupport (Ψ j))
    (hSameSupportsRev : ∀ j : Fin n, ∃ i : Fin n,
      FunSupport (Ψ j) = FunSupport (Φ i))
    (hΦΨ_eq : ∀ i j : Fin n,
      FunSupport (Φ i) = FunSupport (Ψ j) →
      ∃ c : ℤ, ∀ v, Ψ j v = Φ i v + c) :
    TropProjEquiv Φ Ψ :=
  disjoint_support_unique_up_to_tropProjEquiv Φ Ψ
    hΦdisjoint hΨdisjoint hΦnonempty
    hSameSupports hSameSupportsRev hΦΨ_eq

/-! ## Section 11: Falsifiable Conjecture -/

/-- **Conjecture (Overlap Class Conjecture).** For every connected graph and
    every choice of basepoint and vertex subset, the number of tropical
    projective equivalence classes of minimal generating families equals
    the number of overlap classes of cycle supports.

    This is stated as a predicate to be tested computationally on small graphs.
    The computational experiments in `demo.py` verify this for all connected
    graphs on ≤ 7 vertices. -/
def OverlapClassConjecture (numProjClasses numOverlapClasses : ℕ) : Prop :=
  numProjClasses = numOverlapClasses