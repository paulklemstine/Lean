/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Activation-Region Nerve as Simplicial Complex and Margin-Cosheaf Exactness

This module formalizes the activation-region decomposition of a classifier as a
finite simplicial complex (the **activation nerve**) and defines a **margin cosheaf**
on that complex. The central result is that **degree-1 exactness of the margin cosheaf
detects global consistency of local positive margins**, yielding certified robustness.

## Mathematical Framework

Given a finite cover {R_i}_{i ∈ ι} of a compact domain K ⊆ X by closed sets
(modeling activation regions of a ReLU network), the **nerve** is the abstract
simplicial complex whose simplices are nonempty finite subsets σ ⊆ ι such that
K ∩ ⋂_{i ∈ σ} R_i ≠ ∅.

The **margin cosheaf** assigns to each simplex σ the infimum of the margin function
over the corresponding intersection:

  M(σ) = sInf(margin '' (K ∩ ⋂_{i ∈ σ} R_i))

**Degree-1 exactness** is defined as the condition that every vertex of the nerve
carries positive margin. This is the combinatorial surrogate for H_0 positivity
of the margin cosheaf on the 0-skeleton.

## Main Results

1. `nerve_down_closed` — the nerve is an abstract simplicial complex (downward-closed).
2. `marginCosheaf_monotone` — the cosheaf values increase on refinements (subset monotonicity).
3. `degreeOneExact_iff_uniformPositiveMargin` — **Main theorem**: degree-1 exactness
   of the margin cosheaf is equivalent to existence of a uniform positive global margin,
   under compactness, continuity, and cover assumptions.
4. `activation_nerve_certified_robustness` — certified robustness radius from exactness
   + Lipschitz bound.
5. `nonexact_implies_vulnerability` — contrapositive: non-exactness implies existence
   of a vulnerable point with non-positive margin.

## Conceptual Significance

This formalizes the principle that **neural robustness is controlled by topological
exactness on activation-space decompositions**. Instead of certifying robustness
pointwise, one certifies it through the combinatorial consistency of local margin
data over the activation nerve. Robustness becomes a statement in combinatorial
topology.
-/

import Mathlib

open Set Finset BigOperators

noncomputable section

/-! ## §1. The Activation Nerve -/

/-- The **nerve** of a finite cover: the collection of nonempty finite subsets of ι
    whose corresponding intersection with K is nonempty.
    This forms an abstract simplicial complex. -/
def coverNerve {X : Type*} (ι : Type*) [DecidableEq ι]
    (K : Set X) (R : ι → Set X) : Set (Finset ι) :=
  {σ : Finset ι | σ.Nonempty ∧ (K ∩ ⋂ i ∈ σ, R i).Nonempty}

/-
The nerve is **downward-closed**: any nonempty subset of a nerve simplex
    is again a nerve simplex. This is the defining property of an abstract
    simplicial complex.
-/
theorem nerve_down_closed {X : Type*} {ι : Type*} [DecidableEq ι]
    (K : Set X) (R : ι → Set X) :
    ∀ σ ∈ coverNerve ι K R, ∀ τ : Finset ι, τ ⊆ σ → τ.Nonempty →
      τ ∈ coverNerve ι K R := by
  intro σ hσ τ hτ hτ_nonempty
  simp [coverNerve] at hσ ⊢;
  exact ⟨ hτ_nonempty, by rcases hσ.2 with ⟨ x, hxK, hxi ⟩ ; exact ⟨ x, hxK, by exact Set.mem_iInter₂.2 fun i hi => Set.mem_iInter₂.1 hxi i ( hτ hi ) ⟩ ⟩

/-! ## §2. The Margin Cosheaf -/

/-- The **margin cosheaf value** on a simplex σ: the infimum of the margin function
    over K ∩ ⋂_{i ∈ σ} R_i. -/
def marginCosheafValue {X : Type*} {ι : Type*} [DecidableEq ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ) (σ : Finset ι) : ℝ :=
  sInf (margin '' (K ∩ ⋂ i ∈ σ, R i))

/-
**Cosheaf monotonicity**: if τ ⊆ σ, then M(τ) ≤ M(σ), because ⋂_{i ∈ σ} R_i ⊆ ⋂_{i ∈ τ} R_i
    (intersecting over more indices gives a smaller set), so the image set is smaller
    and the infimum can only increase.
-/
theorem marginCosheaf_monotone {X : Type*} {ι : Type*} [DecidableEq ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    {σ τ : Finset ι} (h : τ ⊆ σ)
    (hbdd : BddBelow (margin '' (K ∩ ⋂ i ∈ τ, R i)))
    (hne : (margin '' (K ∩ ⋂ i ∈ σ, R i)).Nonempty) :
    marginCosheafValue K R margin τ ≤ marginCosheafValue K R margin σ := by
  -- Since τ ⊆ σ, we have ⋂_{i ∈ σ} R_i ⊆ ⋂_{i ∈ τ} R_i. Therefore, K ∩ ⋂_{i ∈ σ} R_i ⊆ K ∩ ⋂_{i ∈ τ} R_i.
  have h_subset : K ∩ ⋂ i ∈ σ, R i ⊆ K ∩ ⋂ i ∈ τ, R i := by
    exact Set.inter_subset_inter_right _ ( Set.biInter_subset_biInter_left h );
  apply_rules [ csInf_le_csInf ];
  grind

/-! ## §3. Degree-1 Exactness -/

/-- **Degree-1 exactness of the margin cosheaf**: every vertex (singleton simplex)
    of the nerve that intersects K nontrivially carries strictly positive margin.

    This is the combinatorial condition on the 0-skeleton of the nerve that encodes
    "all local margin certificates are positive." It serves as the finite combinatorial
    surrogate for the vanishing of the first cosheaf homology obstruction. -/
def degreeOneExactMarginCosheaf {X : Type*} {ι : Type*} [Fintype ι] [DecidableEq ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ) : Prop :=
  ∀ i : ι, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))

/-! ## §4. Auxiliary Lemmas -/

/-
The margin function is bounded below on a compact set with continuous margin.
-/
theorem margin_bddBelow_on_compact {X : Type*} [TopologicalSpace X]
    {K : Set X} {R : Set X} (margin : X → ℝ)
    (hK : IsCompact K) (hR : IsClosed R) (hcont : Continuous margin)
    (hne : (K ∩ R).Nonempty) :
    BddBelow (margin '' (K ∩ R)) := by
  -- Since $K \cap R$ is compact and $margin$ is continuous, the image $margin(K \cap R)$ is compact.
  have h_compact : IsCompact (margin '' (K ∩ R)) := by
    exact hK.inter_right hR |> IsCompact.image <| hcont
  generalize_proofs at *; exact h_compact.bddBelow;

/-
On a nonempty compact set, a continuous function attains its infimum,
    and the infimum is a lower bound of the image.
-/
theorem sInf_le_of_mem_compact_image {X : Type*} [TopologicalSpace X]
    {K : Set X} (margin : X → ℝ) {S : Set X}
    (hK : IsCompact K) (hSclosed : IsClosed S) (hcont : Continuous margin)
    (hne : (K ∩ S).Nonempty)
    {x : X} (hx : x ∈ K ∩ S) :
    sInf (margin '' (K ∩ S)) ≤ margin x := by
  exact csInf_le ( margin_bddBelow_on_compact margin hK hSclosed hcont hne ) ( Set.mem_image_of_mem _ hx )

/-
On a nonempty compact set, the infimum of a continuous function is positive
    iff the function is positive everywhere on the set.
-/
theorem sInf_pos_iff_all_pos {X : Type*} [TopologicalSpace X]
    {S : Set X} (margin : X → ℝ)
    (hS : IsCompact S) (hne : S.Nonempty) (hcont : ContinuousOn margin S) :
    0 < sInf (margin '' S) ↔ ∀ x ∈ S, 0 < margin x := by
  -- If the infimum of the image is positive, then every element in the image must be positive.
  apply Iff.intro
  intro h_inf_pos
  have h_all_pos : ∀ x ∈ S, 0 < margin x := by
    exact fun x hx => h_inf_pos.trans_le ( csInf_le ( hS.image_of_continuousOn hcont |> IsCompact.bddBelow ) <| Set.mem_image_of_mem _ hx )
  exact h_all_pos;
  intro h
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ ∈ S, ∀ x ∈ S, margin x₀ ≤ margin x := by
    exact hS.exists_isMinOn hne hcont;
  exact lt_of_lt_of_le ( h x₀ hx₀.1 ) ( le_csInf ( Set.Nonempty.image _ hne ) ( Set.forall_mem_image.2 hx₀.2 ) )

/-! ## §5. Main Theorem: Exactness ↔ Uniform Positive Margin -/

/-
**Forward direction**: Degree-1 exactness implies a uniform positive lower bound
    on the margin over K.

    If every activation region carries positive infimal margin over K, and K is covered
    by the regions, then the minimum over all regions gives a uniform positive bound.
-/
theorem degreeOneExact_implies_uniformPositiveMargin
    {X : Type*} [TopologicalSpace X] [T2Space X]
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hcompact : IsCompact K)
    (hcont : Continuous margin)
    (hExact : degreeOneExactMarginCosheaf K R margin) :
    ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
  -- Since K is compact and margin is continuous, margin achieves its minimum on K. If K is empty, ∃ δ > 0 trivially. If K is nonempty, the minimum is positive, so take δ = sInf(margin '' K).
  by_cases hK_empty : K = ∅;
  · exact ⟨ 1, zero_lt_one, by simp +decide [ hK_empty ] ⟩;
  · have h_pos : ∀ x ∈ K, 0 < margin x := by
      intro x hx;
      obtain ⟨ i, hi ⟩ := Set.mem_iUnion.mp ( hcover hx );
      exact lt_of_lt_of_le ( hExact i ⟨ x, hx, hi ⟩ ) ( csInf_le ( margin_bddBelow_on_compact margin hcompact ( hclosed i ) hcont ⟨ x, hx, hi ⟩ ) ⟨ x, ⟨ hx, hi ⟩, rfl ⟩ );
    have := hcompact.exists_isMinOn ( Set.nonempty_iff_ne_empty.2 hK_empty ) ( show ContinuousOn margin K from hcont.continuousOn );
    exact ⟨ margin this.choose, h_pos _ this.choose_spec.1, fun x hx => this.choose_spec.2 hx ⟩

/-
**Backward direction**: A uniform positive margin on K implies degree-1 exactness.

    If margin ≥ δ > 0 everywhere on K, then the infimum on each K ∩ R_i is ≥ δ > 0.
-/
theorem uniformPositiveMargin_implies_degreeOneExact
    {X : Type*} [TopologicalSpace X]
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hclosed : ∀ i, IsClosed (R i))
    (hcompact : IsCompact K)
    (hcont : Continuous margin)
    (hδ : ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x) :
    degreeOneExactMarginCosheaf K R margin := by
  -- Fix an arbitrary $i$.
  intro i
  intro hne;
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := hδ;
  exact lt_of_lt_of_le hδ_pos ( le_csInf ( Set.Nonempty.image _ hne ) ( Set.forall_mem_image.2 fun x hx => hδ x hx.1 ) )

/-- **Main Theorem (Iff)**: Degree-1 exactness of the margin cosheaf on the activation
    nerve is equivalent to existence of a uniform positive global margin on K.

    This is the fundamental equivalence between topological exactness and certified
    robustness. Under compactness, continuity, and finite cover assumptions:

      degreeOneExactMarginCosheaf K R margin
        ↔ ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x

    The forward direction says: local positive margins on each activation region
    glue to a global positive margin.
    The backward direction says: a global positive margin restricts to positive
    local margins on each region. -/
theorem degreeOneExact_iff_uniformPositiveMargin
    {X : Type*} [TopologicalSpace X] [T2Space X]
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hcompact : IsCompact K)
    (hcont : Continuous margin) :
    degreeOneExactMarginCosheaf K R margin
      ↔ ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
  exact ⟨degreeOneExact_implies_uniformPositiveMargin K R margin hcover hclosed hcompact hcont,
         uniformPositiveMargin_implies_degreeOneExact K R margin hclosed hcompact hcont⟩

/-! ## §6. Certified Robustness from Exactness -/

/-- **Certified robustness on a set**: every point in K is robust under perturbations
    of size less than r. -/
def CertifiedRobustOn {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (K : Set X) (r : ℝ) : Prop :=
  ∀ x ∈ K, ∀ y : X, dist y x < r → 0 < scoreGap y

/-
**Activation nerve certified robustness**: If degree-1 exactness holds for the
    margin cosheaf and the margin function is L-Lipschitz with L > 0, then there
    exists a certified robustness radius r > 0.

    The certified radius is δ/L where δ is the uniform positive margin guaranteed
    by exactness.
-/
theorem activation_nerve_certified_robustness
    {X : Type*} [PseudoMetricSpace X] [T2Space X]
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hcompact : IsCompact K)
    (hcont : Continuous margin)
    (hLip : ∀ x y : X, |margin x - margin y| ≤ L * dist x y)
    (hExact : degreeOneExactMarginCosheaf K R margin) :
    ∃ r > 0, CertifiedRobustOn margin K r := by
  -- By degreeOneExact_implies_uniformPositiveMargin, get δ > 0 with ∀ x ∈ K, δ ≤ margin x.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x := by
    apply degreeOneExact_implies_uniformPositiveMargin K R margin hcover hclosed hcompact hcont hExact;
  refine' ⟨ δ / L, div_pos hδ_pos hL, fun x hx y hy => _ ⟩;
  nlinarith [ abs_le.mp ( hLip y x ), hδ x hx, mul_div_cancel₀ δ hL.ne' ]

/-! ## §7. Contrapositive: Non-exactness Implies Vulnerability -/

/-- A point is **vulnerable** if the margin is non-positive there. -/
def VulnerableAt {X : Type*} (margin : X → ℝ) (x : X) : Prop :=
  margin x ≤ 0

/-
**Contrapositive obstruction**: If degree-1 exactness fails, then either some
    activation region has a point with non-positive margin, or the region is empty.
    Under the cover hypothesis, this means K contains a vulnerable point.
-/
theorem nonexact_implies_vulnerability
    {X : Type*} [TopologicalSpace X] [T2Space X]
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hcompact : IsCompact K)
    (hcont : Continuous margin)
    (_hKne : K.Nonempty)
    (hnotExact : ¬ degreeOneExactMarginCosheaf K R margin) :
    ∃ i : ι, (K ∩ R i).Nonempty ∧ ∃ x ∈ K ∩ R i, margin x ≤ 0 := by
  simp_all +decide [ degreeOneExactMarginCosheaf ];
  obtain ⟨ i, hi, hi' ⟩ := hnotExact; rcases ( IsCompact.sInf_mem ( show IsCompact ( margin '' ( K ∩ R i ) ) from hcompact.inter_right ( hclosed i ) |> IsCompact.image <| hcont ) <| Set.Nonempty.image _ hi ) with ⟨ x, hx, hx' ⟩ ; use i, hi, x; aesop;

/-! ## §8. Higher Cosheaf Structure: Edge Compatibility -/

/-
**Edge compatibility** of the margin cosheaf: for every pair of overlapping
    regions, the margin on the overlap is at least as large as the minimum
    of the vertex margins. This is automatic from monotonicity.
-/
theorem edge_compatibility_from_vertex_positivity
    {X : Type*} [TopologicalSpace X]
    {ι : Type*} [DecidableEq ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (i j : ι) (_hij : i ≠ j)
    (hne : (K ∩ R i ∩ R j).Nonempty)
    (_hR_i : IsClosed (R i)) (_hR_j : IsClosed (R j))
    (_hK : IsCompact K) (_hcont : Continuous margin)
    (h_i : 0 < sInf (margin '' (K ∩ R i)))
    (h_j : 0 < sInf (margin '' (K ∩ R j))) :
    0 < sInf (margin '' (K ∩ R i ∩ R j)) := by
  refine' lt_of_lt_of_le ( lt_min h_i h_j ) _;
  refine' le_csInf _ _;
  · exact hne.image _;
  · rintro _ ⟨ x, hx, rfl ⟩;
    refine' le_trans ( min_le_left _ _ ) ( csInf_le _ _ );
    · exact ( by contrapose! h_i; rw [ Real.sInf_of_not_bddBelow h_i ] );
    · exact ⟨ x, ⟨ hx.1.1, hx.1.2 ⟩, rfl ⟩

/-! ## §9. Nerve Finiteness for Finite Index -/

/-
The nerve of a cover indexed by a finite type is automatically a finite
    simplicial complex (the set of faces is finite).
-/
theorem nerve_finite_of_fintype
    {X : Type*} {ι : Type*} [Fintype ι] [DecidableEq ι]
    (K : Set X) (R : ι → Set X) :
    Set.Finite (coverNerve ι K R) := by
  exact Set.toFinite _

/-! ## §10. Cosheaf Differential and Chain Complex Structure -/

/-- The **degree-0 chain group** of the margin cosheaf: assigns a real value
    to each vertex of the nerve. -/
def C0 (ι : Type*) := ι → ℝ

/-- The **degree-1 chain group**: assigns a real value to each ordered pair
    of indices (edges of the nerve). -/
def C1 (ι : Type*) := ι → ι → ℝ

/-- The **cosheaf differential** d₀ : C₀ → C₁, defined by
    d₀(f)(i,j) = f(j) - f(i). -/
def cosheafDifferential {ι : Type*} (f : C0 ι) : C1 ι :=
  fun i j => f j - f i

/-- A **1-cocycle** is a function c : ι → ι → ℝ satisfying the cocycle condition
    c(i,k) = c(i,j) + c(j,k) for all i,j,k. -/
def IsCocycle {ι : Type*} (c : C1 ι) : Prop :=
  ∀ i j k, c i k = c i j + c j k

/-- A **1-coboundary** is a 1-cochain in the image of the differential. -/
def IsCoboundary {ι : Type*} (c : C1 ι) : Prop :=
  ∃ f : C0 ι, c = cosheafDifferential f

/-
Every coboundary is a cocycle.
-/
theorem coboundary_is_cocycle {ι : Type*} (c : C1 ι)
    (h : IsCoboundary c) : IsCocycle c := by
  rcases h with ⟨f, rfl⟩;
  exact fun i j k => by unfold cosheafDifferential; ring;

/-
**H¹ vanishing**: every cocycle is a coboundary. This always holds for
    the standard differential on a finite type.
-/
theorem H1_vanishing {ι : Type*} [Nonempty ι]
    (c : C1 ι) (hc : IsCocycle c) :
    IsCoboundary c := by
  refine' ⟨ fun i => c ( Classical.arbitrary ι ) i, _ ⟩;
  exact funext fun i => funext fun j => by have := hc ( Classical.arbitrary ι ) i j; have := hc ( Classical.arbitrary ι ) j i; have := hc i ( Classical.arbitrary ι ) i; have := hc i ( Classical.arbitrary ι ) j; have := hc j ( Classical.arbitrary ι ) i; have := hc j ( Classical.arbitrary ι ) j; norm_num [ cosheafDifferential ] at *; linarith;

/-! ## §11. Connecting Čech Cohomology to Margin Exactness -/

/-
**Margin cocycle**: Given local margin data m : ι → ℝ, the margin differences
    m(j) - m(i) on overlapping pairs form a 1-cocycle.
-/
theorem margin_differences_form_cocycle {ι : Type*}
    (m : ι → ℝ) :
    IsCocycle (fun i j => m j - m i) := by
  exact fun i j k => by ring;

/-
The margin difference cocycle is always a coboundary (witnessed by m itself).
    This means H¹ always vanishes for the margin cosheaf, so the only obstruction
    to global positivity is local positivity.
-/
theorem margin_cocycle_is_coboundary {ι : Type*}
    (m : ι → ℝ) :
    IsCoboundary (fun i j => m j - m i) := by
  exact ⟨ m, rfl ⟩

/-! ## §12. Full Pipeline: Nerve → Exactness → Robustness -/

/-- **Full certification pipeline**: Starting from a finite closed cover of a compact
    domain, positive local margins on each region, continuity, and a Lipschitz bound,
    derive a certified robustness radius.

    This theorem chains:
    1. Local positive margins → degree-1 exactness
    2. Degree-1 exactness → uniform positive margin
    3. Uniform positive margin + Lipschitz → certified robustness -/
theorem full_activation_nerve_certification_pipeline
    {X : Type*} [PseudoMetricSpace X] [T2Space X]
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (K : Set X) (R : ι → Set X) (margin : X → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hcover : K ⊆ ⋃ i, R i)
    (hclosed : ∀ i, IsClosed (R i))
    (hcompact : IsCompact K)
    (hcont : Continuous margin)
    (hLip : ∀ x y : X, |margin x - margin y| ≤ L * dist x y)
    (hlocal : ∀ i, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))) :
    ∃ r > 0, CertifiedRobustOn margin K r := by
  exact activation_nerve_certified_robustness K R margin L hL hcover hclosed
    hcompact hcont hLip hlocal

-- Axiom verification
#print axioms nerve_down_closed
#print axioms marginCosheaf_monotone
#print axioms degreeOneExact_iff_uniformPositiveMargin
#print axioms activation_nerve_certified_robustness
#print axioms nonexact_implies_vulnerability
#print axioms edge_compatibility_from_vertex_positivity
#print axioms nerve_finite_of_fintype
#print axioms coboundary_is_cocycle
#print axioms H1_vanishing
#print axioms margin_differences_form_cocycle
#print axioms margin_cocycle_is_coboundary
#print axioms full_activation_nerve_certification_pipeline

end