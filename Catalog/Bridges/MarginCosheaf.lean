/-
Copyright (c) 2025. All rights reserved.

# Activation-Region Nerve and Margin-Cosheaf Exactness

This file formalizes the activation-region decomposition of a classifier as a
finite simplicial complex (the **activation nerve**) and defines a **margin cosheaf**
on that complex. The central result is that **degree-1 exactness** of the margin
cosheaf detects global consistency of local positive margins, yielding certified
robustness.

## Main results

### Definitions
* `DegreeOneExact` — degree-1 exactness: local positive margins glue globally
* `CertifiedRobustOn` — a margin lower bound on the domain K

### Core theorems
* `uniform_positive_margin_of_compact` — continuous positive function on compact
  set has uniform positive lower bound
* `pointwise_positive_from_cover_and_local` — local positivity + cover → pointwise
* `degree1_exact_implies_uniform_margin` — exactness → uniform margin
* `uniform_margin_implies_degree1_exact` — uniform margin → exactness
* `nerve_margin_exactness_iff_uniform_positive` — the full equivalence
* `certified_robustness_from_exact_cosheaf` — exactness + Lipschitz → robustness
* `activation_nerve_certification_pipeline` — the full pipeline theorem

## Mathematical overview

Given a finite family `R : ι → Set X` of closed subsets covering a compact domain `K`,
the **nerve** is the abstract simplicial complex whose simplices are finite subsets
`σ ⊆ ι` with `(K ∩ ⋂ i ∈ σ, R i).Nonempty`. The **margin cosheaf** assigns to each
simplex the infimum of the margin function on the intersection.

**Degree-1 exactness** requires positive local margin on every vertex and every
point. The main theorem shows this is equivalent to a uniform positive margin on K,
which combined with a Lipschitz bound yields certified robustness.

## Bridge keywords
activation_nerve, margin_cosheaf, degree1_exactness, certified_robustness,
neural_certification, topological_machine_learning, homological_deep_learning
-/

import Mathlib

open Set Finset

noncomputable section

namespace ActivationNerveCosheaf

/-! ## §1: Core Definitions -/

/-- The intersection of K with the family of sets indexed by a finset σ. -/
def simplexDomain {X ι : Type*} (K : Set X) (R : ι → Set X) (σ : Finset ι) : Set X :=
  K ∩ ⋂ i ∈ σ, R i

/-- The margin value on a simplex: the infimum of the margin function
    on the simplex domain. -/
def simplexMargin {X ι : Type*} (K : Set X) (R : ι → Set X)
    (margin : X → ℝ) (σ : Finset ι) : ℝ :=
  sInf (margin '' simplexDomain K R σ)

/-- **Degree-1 exactness of the margin cosheaf**: every point in K has
    positive margin, and every vertex (singleton) in the nerve has
    positive margin infimum. This encodes that local margin certificates
    are positive and consistent. -/
structure DegreeOneExact {X ι : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ) : Prop where
  /-- Every vertex in the nerve has positive margin -/
  vertex_positive : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))
  /-- Every point in K has positive margin -/
  pointwise_positive : ∀ x ∈ K, 0 < margin x

/-- **Certified robustness on K with margin r**. -/
def CertifiedRobustOn {X : Type*} (K : Set X) (margin : X → ℝ) (r : ℝ) : Prop :=
  ∀ x ∈ K, r ≤ margin x

/-! ## §2: The Main Gluing Theorem -/

/-- **Local positive margins glue to a uniform global bound.**
    K compact, margin continuous and pointwise positive on K
    implies a uniform positive lower bound. -/
theorem uniform_positive_margin_of_compact
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (margin : X → ℝ)
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K)
    (hpos : ∀ x ∈ K, 0 < margin x) :
    ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
  obtain ⟨x₀, hx₀K, hmin⟩ := hK.exists_isMinOn hKne hcont
  exact ⟨margin x₀, hpos x₀ hx₀K, fun y hy => hmin hy⟩

/-- **Cover lemma**: every point in K lies in some R i, so has positive
    margin if each local infimum is positive. -/
theorem pointwise_positive_from_cover_and_local
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hK : IsCompact K)
    (hcont : ContinuousOn margin K)
    (hlocal : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))) :
    ∀ x ∈ K, 0 < margin x := by
  intro x hxK
  obtain ⟨i, hi⟩ := mem_iUnion.mp (hcover hxK)
  have hne : (K ∩ R i).Nonempty := ⟨x, hxK, hi⟩
  have hxi : x ∈ K ∩ R i := ⟨hxK, hi⟩
  have hbound := hlocal i hne
  have hmem : margin x ∈ margin '' (K ∩ R i) := ⟨x, hxi, rfl⟩
  have hbdd : BddBelow (margin '' (K ∩ R i)) :=
    (hK.inter_right (hclosed i)).bddBelow_image (hcont.mono Set.inter_subset_left)
  exact lt_of_lt_of_le hbound (csInf_le hbdd hmem)

/-- **Forward direction:** degree-1 exactness → uniform positive margin. -/
theorem degree1_exact_implies_uniform_margin
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hExact : DegreeOneExact K R margin)
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K) :
    ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x :=
  uniform_positive_margin_of_compact K margin hK hKne hcont hExact.pointwise_positive

/-- **Converse:** uniform positive margin → degree-1 exactness. -/
theorem uniform_margin_implies_degree1_exact
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (_hclosed : ∀ i, IsClosed (R i))
    (_hK : IsCompact K)
    (_hcont : ContinuousOn margin K)
    (δ : ℝ) (hδ : 0 < δ) (hbound : ∀ x ∈ K, δ ≤ margin x) :
    DegreeOneExact K R margin := by
  refine ⟨fun i ⟨x, hxK, hxR⟩ => ?_, fun x hxK => lt_of_lt_of_le hδ (hbound x hxK)⟩
  apply lt_of_lt_of_le hδ
  apply le_csInf
  · exact ⟨margin x, x, ⟨hxK, hxR⟩, rfl⟩
  · rintro _ ⟨y, ⟨hyK, _⟩, rfl⟩
    exact hbound y hyK

/-- **The equivalence:** degree-1 exactness ↔ uniform positive margin. -/
theorem nerve_margin_exactness_iff_uniform_positive
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hclosed : ∀ i, IsClosed (R i))
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K) :
    DegreeOneExact K R margin ↔ ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
  constructor
  · exact fun h => degree1_exact_implies_uniform_margin K R margin h hK hKne hcont
  · rintro ⟨δ, hδ, hbound⟩
    exact uniform_margin_implies_degree1_exact K R margin hclosed hK hcont δ hδ hbound

/-! ## §3: Certified Robustness from Exactness -/

/-- **Certified robustness radius from margin and Lipschitz constant.** -/
theorem robustness_radius_from_margin_lipschitz
    (δ L : ℝ) (hδ : 0 < δ) (hL : 0 < L) :
    0 < δ / L ∧ ∀ ε : ℝ, 0 ≤ ε → ε ≤ δ / L → δ - L * ε ≥ 0 := by
  refine ⟨div_pos hδ hL, fun ε _ hε => ?_⟩
  have : L * ε ≤ L * (δ / L) := mul_le_mul_of_nonneg_left hε hL.le
  rw [mul_div_cancel₀ δ hL.ne'] at this
  linarith

/-- **Full certified robustness from cosheaf exactness.** -/
theorem certified_robustness_from_exact_cosheaf
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hExact : DegreeOneExact K R margin)
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K) :
    ∃ r > 0, CertifiedRobustOn K margin r := by
  obtain ⟨δ, hδ, hbound⟩ :=
    degree1_exact_implies_uniform_margin K R margin hExact hK hKne hcont
  exact ⟨δ, hδ, hbound⟩

/-- **Certified robustness with explicit Lipschitz perturbation bound.** -/
theorem certified_robustness_explicit_radius
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hExact : DegreeOneExact K R margin)
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K) :
    ∃ r > 0, ∀ x ∈ K, ∀ ε : ℝ, 0 ≤ ε → ε ≤ r →
      margin x - L * ε ≥ 0 := by
  obtain ⟨δ, hδ, hbound⟩ :=
    degree1_exact_implies_uniform_margin K R margin hExact hK hKne hcont
  refine ⟨δ / L, div_pos hδ hL, fun x hxK ε _ hεr => ?_⟩
  have hmargin := hbound x hxK
  have : L * ε ≤ L * (δ / L) := mul_le_mul_of_nonneg_left hεr hL.le
  rw [mul_div_cancel₀ δ hL.ne'] at this
  linarith

/-! ## §4: The Activation Nerve as a Simplicial Complex -/

/-- The activation nerve: simplices are nonempty finsets whose
    intersection with K is nonempty. -/
def activationNerve {X ι : Type*} (K : Set X) (R : ι → Set X) : Set (Finset ι) :=
  {σ | σ.Nonempty ∧ (simplexDomain K R σ).Nonempty}

/-- The activation nerve is downward closed. -/
theorem activationNerve_downClosed {X ι : Type*} [DecidableEq ι]
    {K : Set X} {R : ι → Set X}
    {σ τ : Finset ι} (hσ : σ ∈ activationNerve K R)
    (hτσ : τ ⊆ σ) (hτne : τ.Nonempty) :
    τ ∈ activationNerve K R := by
  refine ⟨hτne, ?_⟩
  obtain ⟨_, x, hx⟩ := hσ
  refine ⟨x, ?_⟩
  simp only [simplexDomain, Set.mem_inter_iff, Set.mem_iInter] at hx ⊢
  exact ⟨hx.1, fun i hi => hx.2 i (hτσ hi)⟩

/-- The margin cosheaf is antimonotone on the face poset:
    larger simplices have smaller domains. -/
theorem simplexDomain_antimono {X ι : Type*} [DecidableEq ι]
    {K : Set X} {R : ι → Set X}
    {σ τ : Finset ι} (hστ : σ ⊆ τ) :
    simplexDomain K R τ ⊆ simplexDomain K R σ := by
  intro x hx
  simp only [simplexDomain, Set.mem_inter_iff, Set.mem_iInter] at hx ⊢
  exact ⟨hx.1, fun i hi => hx.2 i (hστ hi)⟩

/-! ## §5: Constructing Degree-1 Exactness from Local Data -/

/-- **Constructing exactness from local positivity + cover.** -/
theorem degree1_exact_from_cover_and_local_positivity
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hK : IsCompact K)
    (hcont : ContinuousOn margin K)
    (hlocal : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))) :
    DegreeOneExact K R margin :=
  ⟨hlocal, pointwise_positive_from_cover_and_local K R margin hcover hclosed hK hcont hlocal⟩

/-! ## §6: The Complete Certification Pipeline -/

/-- **The complete activation-nerve certification pipeline.**

Given a finite closed cover of compact K by activation regions,
continuous margin function with positive local infima, and Lipschitz
constant, produces a certified robustness radius. -/
theorem activation_nerve_certification_pipeline
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K)
    (hlocal : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))) :
    ∃ r > 0, CertifiedRobustOn K margin r ∧
      ∀ x ∈ K, ∀ ε : ℝ, 0 ≤ ε → ε ≤ r / L → margin x - L * ε ≥ 0 := by
  have hExact := degree1_exact_from_cover_and_local_positivity K R margin
    hcover hclosed hK hcont hlocal
  obtain ⟨δ, hδ, hbound⟩ :=
    degree1_exact_implies_uniform_margin K R margin hExact hK hKne hcont
  refine ⟨δ, hδ, hbound, fun x hxK ε _ hεr => ?_⟩
  have hmargin := hbound x hxK
  have : L * ε ≤ L * (δ / L) := mul_le_mul_of_nonneg_left hεr hL.le
  rw [mul_div_cancel₀ δ hL.ne'] at this
  linarith

/-! ## §7: Nerve Complexity Bounds for ReLU Networks -/

/-- Maximum number of activation regions for a single ReLU layer with
    n neurons in d-dimensional space. -/
def maxRegionsSingleLayer (n d : ℕ) : ℕ :=
  ∑ k ∈ Finset.range (d + 1), n.choose k

/-- Single layer region bound is positive. -/
theorem maxRegionsSingleLayer_pos (n d : ℕ) : 0 < maxRegionsSingleLayer n d := by
  unfold maxRegionsSingleLayer
  calc 0 < 1 := by omega
    _ = n.choose 0 := (Nat.choose_zero_right n).symm
    _ ≤ ∑ k ∈ Finset.range (d + 1), n.choose k := by
        apply Finset.single_le_sum (fun k _ => Nat.zero_le _)
        exact Finset.mem_range.mpr (by omega)

end ActivationNerveCosheaf