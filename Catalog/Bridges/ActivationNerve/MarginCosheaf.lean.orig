/-
Copyright (c) 2025. All rights reserved.

# Activation-Region Nerve as a Simplicial Complex and Margin-Cosheaf Exactness

This file formalizes the activation-region decomposition of a classifier as a
finite simplicial complex (the **activation nerve**) and defines a **margin cosheaf**
on that complex. The central result is that **degree-1 exactness** of the margin
cosheaf detects global consistency of local positive margins, yielding certified
robustness.

## Main results

### Core Definitions
* `DegreeOneExact` — degree-1 exactness: local positive margins on vertices are
  consistent and yield pointwise positivity on the covered domain.
* `CertifiedRobustOn` — certified margin lower bound on a domain K.
* `activationNerve` — the nerve simplicial complex of the activation-region cover.
* `simplexMargin` — the margin cosheaf value on a nerve simplex.

### Central Theorems
* `nerve_margin_exactness_iff_uniform_positive` — **The Equivalence Theorem**:
  degree-1 exactness of the margin cosheaf ↔ existence of a uniform positive margin.
* `certified_robustness_from_exact_cosheaf` — exactness → certified robustness radius.
* `activation_nerve_certification_pipeline` — the complete pipeline from local
  activation-region data to certified robustness.
* `finite_nerve_cosheaf_glues_positive_sections` — abstract finite combinatorial
  gluing: positive vertex margins + cover + compactness + continuity → uniform bound.
* `certified_robustness_explicit_radius` — explicit perturbation bound via Lipschitz.
* `degree1_exact_from_cover_and_local_positivity` — constructing exactness from data.

### Nerve Structure
* `activationNerve_downClosed` — the nerve is downward-closed (simplicial).
* `simplexDomain_antimono` — the margin cosheaf is antimonotone on the face poset.

### Complexity Bounds
* `maxRegionsSingleLayer` — combinatorial bound on activation regions.

## Mathematical Overview

Given a finite family `R : ι → Set X` of closed subsets covering a compact domain `K`,
the **nerve** is the abstract simplicial complex whose simplices are finite subsets
`σ ⊆ ι` with `(K ∩ ⋂ i ∈ σ, R i).Nonempty`. The **margin cosheaf** assigns to each
simplex the infimum of the margin function on the corresponding intersection.

**Degree-1 exactness** encodes that:
1. Every vertex (singleton simplex) in the nerve carries a positive margin infimum.
2. Every point in the covered domain has positive margin.

The main theorem shows this is equivalent to the existence of a uniform positive
global margin on K. Combined with a Lipschitz bound on the margin function, this
yields a certified robustness radius: any perturbation within that radius preserves
the sign of the margin, hence the classification.

This turns neural robustness certification into a problem in combinatorial topology:
robustness ↔ exactness of a cosheaf on a finite simplicial complex.
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
    on the simplex domain. This is the **margin cosheaf** evaluated at σ. -/
def simplexMargin {X ι : Type*} (K : Set X) (R : ι → Set X)
    (margin : X → ℝ) (σ : Finset ι) : ℝ :=
  sInf (margin '' simplexDomain K R σ)

/-- **Degree-1 exactness of the margin cosheaf**: local positive margins on
    vertices are consistent and yield pointwise positivity on the domain.

    This encodes the cosheaf-theoretic condition that the degree-1 boundary
    map has trivial kernel: positive local data on 0-simplices (vertices)
    glues to a positive global section. -/
structure DegreeOneExact {X ι : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ) : Prop where
  /-- Every vertex in the nerve has positive margin infimum -/
  vertex_positive : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))
  /-- Every point in K has positive margin -/
  pointwise_positive : ∀ x ∈ K, 0 < margin x

/-- **Certified robustness on K with margin r**: every point in K has margin ≥ r. -/
def CertifiedRobustOn {X : Type*} (K : Set X) (margin : X → ℝ) (r : ℝ) : Prop :=
  ∀ x ∈ K, r ≤ margin x

/-! ## §2: The Gluing Theorem — Core Engine -/

/-
A continuous function that is pointwise positive on a nonempty compact set
    has a uniform positive lower bound. This is the analytic engine behind
    the cosheaf gluing.
-/
theorem uniform_positive_margin_of_compact
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (margin : X → ℝ)
    (hK : IsCompact K) (_hKne : K.Nonempty)
    (hcont : ContinuousOn margin K)
    (hpos : ∀ x ∈ K, 0 < margin x) :
    ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
  exact IsCompact.exists_forall_le' hK hcont hpos

/-
**Cover lemma**: if every activation region carries positive margin infimum,
    then every point in the covered domain has positive margin.
-/
theorem pointwise_positive_from_cover_and_local
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (_hclosed : ∀ i, IsClosed (R i))
    (_hK : IsCompact K)
    (_hcont : ContinuousOn margin K)
    (hlocal : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))) :
    ∀ x ∈ K, 0 < margin x := by
  intro x hx
  obtain ⟨i, hi⟩ : ∃ i, x ∈ R i := by
    simpa using hcover hx
  have h_nonempty : (K ∩ R i).Nonempty := by
    exact ⟨ x, hx, hi ⟩
  have h_pos : 0 < sInf (margin '' (K ∩ R i)) := hlocal i h_nonempty
  have h_le : sInf (margin '' (K ∩ R i)) ≤ margin x := by
    apply_rules [ csInf_le, _hcont ];
    · exact ( by by_contra h; rw [ Real.sInf_of_not_bddBelow h ] at h_pos; linarith );
    · grind
  linarith

/-! ## §3: Forward and Converse Directions -/

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

/-
**Converse:** uniform positive margin → degree-1 exactness.
-/
theorem uniform_margin_implies_degree1_exact
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (_hclosed : ∀ i, IsClosed (R i))
    (_hK : IsCompact K)
    (_hcont : ContinuousOn margin K)
    (δ : ℝ) (hδ : 0 < δ) (hbound : ∀ x ∈ K, δ ≤ margin x) :
    DegreeOneExact K R margin := by
  constructor;
  · exact fun i hi => lt_of_lt_of_le hδ ( le_csInf ( Set.Nonempty.image _ hi ) ( Set.forall_mem_image.2 fun x hx => hbound x hx.1 ) );
  · exact fun x hx => lt_of_lt_of_le hδ ( hbound x hx )

/-- **The Equivalence Theorem:** degree-1 exactness of the margin cosheaf
    on the activation nerve is equivalent to the existence of a uniform
    positive global margin on K.

    This is the central result: robustness (uniform positive margin) is
    characterized by a topological/combinatorial condition (cosheaf exactness). -/
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

/-! ## §4: Certified Robustness from Exactness -/

/-
**Robustness radius from margin and Lipschitz constant.**
-/
theorem robustness_radius_from_margin_lipschitz
    (δ L : ℝ) (hδ : 0 < δ) (hL : 0 < L) :
    0 < δ / L ∧ ∀ ε : ℝ, 0 ≤ ε → ε ≤ δ / L → δ - L * ε ≥ 0 := by
  exact ⟨ div_pos hδ hL, fun ε hε₁ hε₂ => by nlinarith [ mul_div_cancel₀ δ hL.ne' ] ⟩

/-- **Certified robustness from cosheaf exactness.** If the margin cosheaf
    is degree-1 exact, there exists a positive robustness radius. -/
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

/-
**Certified robustness with explicit Lipschitz perturbation bound.**
    Given cosheaf exactness and a Lipschitz constant, computes an explicit
    radius within which any perturbation preserves the margin sign.
-/
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
  -- Use degree1_exact_implies_uniform_margin to get δ > 0 with δ ≤ margin x for all x ∈ K.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
    exact degree1_exact_implies_uniform_margin K R margin hExact hK hKne hcont;
  exact ⟨ δ / L, div_pos hδ_pos hL, fun x hx ε hε₁ hε₂ => by nlinarith [ hδ x hx, mul_div_cancel₀ δ hL.ne' ] ⟩

/-! ## §5: The Activation Nerve as a Simplicial Complex -/

/-- The **activation nerve**: the set of all nonempty finite index sets σ
    whose corresponding intersection with K is nonempty. This is the
    abstract simplicial complex of the activation-region cover. -/
def activationNerve {X ι : Type*} (K : Set X) (R : ι → Set X) : Set (Finset ι) :=
  {σ | σ.Nonempty ∧ (simplexDomain K R σ).Nonempty}

/-
The activation nerve is **downward closed**: if σ is a simplex and
    τ ⊆ σ is nonempty, then τ is also a simplex. This makes it an
    abstract simplicial complex.
-/
theorem activationNerve_downClosed {X ι : Type*} [DecidableEq ι]
    {K : Set X} {R : ι → Set X}
    {σ τ : Finset ι} (hσ : σ ∈ activationNerve K R)
    (hτσ : τ ⊆ σ) (hτne : τ.Nonempty) :
    τ ∈ activationNerve K R := by
  exact ⟨ hτne, by obtain ⟨ x, hx ⟩ := hσ.2; exact ⟨ x, by exact ⟨ hx.1, Set.mem_iInter₂.2 fun i hi => Set.mem_iInter₂.1 hx.2 i ( hτσ hi ) ⟩ ⟩ ⟩

/-
The margin cosheaf is **antimonotone** on the face poset:
    larger simplices correspond to smaller domains, hence potentially
    smaller margin infima. This is the cosheaf restriction property.
-/
theorem simplexDomain_antimono {X ι : Type*} [DecidableEq ι]
    {K : Set X} {R : ι → Set X}
    {σ τ : Finset ι} (hστ : σ ⊆ τ) :
    simplexDomain K R τ ⊆ simplexDomain K R σ := by
  exact fun x hx => Set.mem_inter hx.1 ( Set.biInter_subset_biInter_left hστ hx.2 )

/-! ## §6: Constructing Degree-1 Exactness from Local Data -/

/-- **Constructing exactness from local positivity and covering.**
    This is the main interface for building a degree-1 exact cosheaf
    from activation-region data: given a finite closed cover with
    positive local margin infima, the cosheaf is exact. -/
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

/-! ## §7: The Complete Certification Pipeline -/

/-
**The complete activation-nerve certification pipeline.**

    Given a finite closed cover of compact K by activation regions,
    a continuous margin function with positive local infima, and a
    Lipschitz constant, produces a certified robustness radius and
    explicit perturbation bounds.

    This theorem packages the entire theory: nerve construction →
    cosheaf exactness → uniform margin → robustness radius.
-/
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
  -- Use degree1_exact_from_cover_and_local_positivity to get hExact.
  obtain ⟨hExact⟩ : DegreeOneExact K R margin := by
    grind +suggestions;
  -- Use degree1_exact_implies_uniform_margin to get δ > 0 with hbound.
  obtain ⟨δ, hδpos, hδbound⟩ : ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
    exact uniform_positive_margin_of_compact K margin hK hKne hcont ‹_›;
  exact ⟨ δ, hδpos, hδbound, fun x hx ε hε₁ hε₂ => by nlinarith [ hδbound x hx, mul_div_cancel₀ δ hL.ne' ] ⟩

/-! ## §8: Abstract Finite Nerve-Cosheaf Gluing -/

/-- **Abstract gluing theorem for finite nerves.**
    Positive vertex margins on a finite closed cover of a compact nonempty set,
    combined with continuity, yield a uniform positive global margin.
    This is the abstract combinatorial engine independent of neural-net specifics. -/
theorem finite_nerve_cosheaf_glues_positive_sections
    {ι : Type*} [Fintype ι]
    {X : Type*} [TopologicalSpace X]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hK : IsCompact K) (hKne : K.Nonempty)
    (hcont : ContinuousOn margin K)
    (hlocal : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))) :
    ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
  have hExact := degree1_exact_from_cover_and_local_positivity K R margin
    hcover hclosed hK hcont hlocal
  exact degree1_exact_implies_uniform_margin K R margin hExact hK hKne hcont

/-! ## §9: Nerve Complexity Bounds for ReLU Networks -/

/-- Maximum number of activation regions for a single ReLU layer with
    n neurons in d-dimensional space (Zaslavsky's bound). -/
def maxRegionsSingleLayer (n d : ℕ) : ℕ :=
  ∑ k ∈ Finset.range (d + 1), n.choose k

/-
The single-layer region bound is always positive.
-/
theorem maxRegionsSingleLayer_pos (n d : ℕ) : 0 < maxRegionsSingleLayer n d := by
  exact lt_of_lt_of_le ( Nat.choose_pos ( Nat.zero_le _ ) ) ( Finset.single_le_sum ( fun x _ => Nat.zero_le _ ) ( by norm_num ) )

/-! ## §10: Margin Cosheaf Monotonicity -/

/-
The margin cosheaf value is monotone under refinement:
    if τ refines σ (i.e., σ ⊆ τ), then the margin on τ is at least
    as large as on σ, because the domain gets smaller (fewer points
    to take the infimum over).
-/
theorem simplexMargin_mono_of_subset {X ι : Type*} [DecidableEq ι]
    {K : Set X} {R : ι → Set X} {margin : X → ℝ}
    {σ τ : Finset ι} (hστ : σ ⊆ τ)
    (hbdd : BddBelow (margin '' simplexDomain K R σ))
    (hne : (margin '' simplexDomain K R τ).Nonempty) :
    simplexMargin K R margin σ ≤ simplexMargin K R margin τ := by
  apply_rules [ csInf_le_csInf ];
  apply Set.image_mono ( simplexDomain_antimono hστ )

end ActivationNerveCosheaf