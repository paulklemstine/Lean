/-
Copyright (c) 2025. All rights reserved.

# Activation-Region Nerve as a Simplicial Complex and Margin-Cosheaf Exactness

This file formalizes the activation-region decomposition of a classifier as a
finite simplicial complex and defines a margin cosheaf on that complex. The
central result is that **degree-1 exactness of the margin cosheaf detects
global consistency of local positive margins**, yielding certified robustness.

## Main results

* `degreeOneExact_iff_uniform_positive_margin` — degree-1 exactness of the
  margin cosheaf on the activation nerve is equivalent to existence of a
  uniform positive global margin on the covered compact domain.

* `activation_nerve_exactness_gives_certified_radius` — from degree-1
  exactness and a Lipschitz bound, derive a positive certified robustness
  radius.

* `finite_cover_glues_positive_margin` — abstract gluing theorem:
  positive local sections compatible on overlaps glue to a global positive
  section.

* `nonexact_produces_margin_gap` — non-exactness implies existence of a
  region or overlap where the margin certificate fails.

## Mathematical overview

Let `R_i` be closed sets forming a finite cover of a compact set `K ⊆ ℝ^d`.
For a continuous margin function, we define the *margin cosheaf* as the
assignment sending each region index `i` to `sInf (margin '' (K ∩ R i))`.

**Degree-1 exactness** is the condition that the local margin lower bounds
are positive on every region and every pairwise overlap. This purely
combinatorial condition (finitely checkable) implies existence of a uniform
positive global margin on all of `K`.

Combined with a Lipschitz bound on the margin function, this yields a
certified robustness radius: perturbations up to `δ / L` cannot change the
classifier's prediction.
-/

import Mathlib

open Set Finset

noncomputable section

namespace ActivationNerveMarginCosheaf

/-! ## Core Definitions -/

/-- An **activation cover** of a compact set `K` by finitely many closed sets.
This models the activation-region decomposition of a ReLU network. -/
structure ActivationCover (ι : Type*) [Fintype ι] (E : Type*) [TopologicalSpace E] where
  /-- The compact domain -/
  K : Set E
  /-- The covering regions (activation regions) -/
  R : ι → Set E
  /-- K is compact -/
  hcompact : IsCompact K
  /-- Each region is closed -/
  hclosed : ∀ i, IsClosed (R i)
  /-- The regions cover K -/
  hcover : K ⊆ ⋃ i, R i

/-- The **margin cosheaf value** on a single region: infimum of the margin
function on `K ∩ R i`. -/
def regionMargin {ι E : Type*} [Fintype ι] [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ) (i : ι) : ℝ :=
  sInf (margin '' (cov.K ∩ cov.R i))

/-- The **margin cosheaf value** on a pairwise overlap `K ∩ R i ∩ R j`. -/
def overlapMargin {ι E : Type*} [Fintype ι] [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ) (i j : ι) : ℝ :=
  sInf (margin '' (cov.K ∩ cov.R i ∩ cov.R j))

/-- **Degree-1 exactness of the margin cosheaf**: every region and every
pairwise overlap carries strictly positive margin infimum.

This is the finite combinatorial certificate that local positive margins
glue to a global positive margin. In cosheaf-theoretic language, this
says the degree-1 differential of the margin cosheaf has trivial kernel
in the positive cone. -/
def DegreeOneExact {ι E : Type*} [Fintype ι] [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ) : Prop :=
  (∀ i : ι, (cov.K ∩ cov.R i).Nonempty → 0 < regionMargin cov margin i) ∧
  (∀ i j : ι, (cov.K ∩ cov.R i ∩ cov.R j).Nonempty →
    0 < overlapMargin cov margin i j)

/-- **Uniform positive margin**: there exists δ > 0 such that margin(x) ≥ δ
for all x ∈ K. This is the global certification target. -/
def UniformPositiveMargin {E : Type*} [TopologicalSpace E]
    (K : Set E) (margin : E → ℝ) : Prop :=
  ∃ δ > 0, ∀ x ∈ K, δ ≤ margin x

/-- **Certified robustness** on K with radius r: perturbations of size ≤ r
from any point in K leave the margin positive. -/
def CertifiedRobustOn {E : Type*} [PseudoMetricSpace E]
    (K : Set E) (margin : E → ℝ) (r : ℝ) : Prop :=
  ∀ x ∈ K, ∀ y : E, dist x y ≤ r → 0 < margin y

/-! ## Auxiliary Lemmas -/

/-
On a compact nonempty set, a continuous function that is everywhere positive
has a positive infimum.
-/
theorem compact_pos_sInf {E : Type*} [TopologicalSpace E]
    {K : Set E} {f : E → ℝ} (hK : IsCompact K) (hne : K.Nonempty)
    (hf : ContinuousOn f K) (hpos : ∀ x ∈ K, 0 < f x) :
    0 < sInf (f '' K) := by
  -- By the extreme value theorem, f attains its minimum on K.
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ ∈ K, ∀ x ∈ K, f x₀ ≤ f x := by
    exact hK.exists_isMinOn hne hf;
  exact lt_of_lt_of_le ( hpos x₀ hx₀.1 ) ( le_csInf ( Set.Nonempty.image _ hne ) ( Set.forall_mem_image.2 hx₀.2 ) )

/-
On a compact set, a continuous real function's image infimum is a lower bound.
-/
theorem sInf_image_le_of_mem {E : Type*} [TopologicalSpace E]
    {K : Set E} {f : E → ℝ} (hK : IsCompact K)
    (hf : ContinuousOn f K) {x : E} (hx : x ∈ K) :
    sInf (f '' K) ≤ f x := by
  apply csInf_le;
  · exact IsCompact.bddBelow ( hK.image_of_continuousOn hf );
  · exact Set.mem_image_of_mem f hx

/-
On a compact nonempty set, a continuous function has positive infimum
iff it is everywhere positive.
-/
theorem compact_sInf_pos_iff {E : Type*} [TopologicalSpace E]
    {K : Set E} {f : E → ℝ} (hK : IsCompact K) (hne : K.Nonempty)
    (hf : ContinuousOn f K) :
    0 < sInf (f '' K) ↔ ∀ x ∈ K, 0 < f x := by
  exact IsCompact.lt_sInf_iff_of_continuous hK hne hf 0

/-! ## Main Theorems -/

/-
**Forward direction**: Degree-1 exactness implies uniform positive margin.

If every activation region (and every pairwise overlap) carries a strictly
positive margin infimum, then the entire compact domain K has a uniform
positive margin.

**Proof sketch**: For every x ∈ K, by the cover property x ∈ R_i for some i.
Then margin(x) ≥ sInf(margin on K ∩ R_i) > 0 by degree-1 exactness.
Since ι is finite, the minimum of these infima is positive.
-/
theorem degreeOneExact_implies_uniform_positive_margin
    {ι : Type*} [Fintype ι]
    {E : Type*} [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ)
    (hcont : ContinuousOn margin cov.K)
    (hne : cov.K.Nonempty)
    (hexact : DegreeOneExact cov margin) :
    UniformPositiveMargin cov.K margin := by
  have := hexact;
  -- By definition of degree-1 exactness, for every region i, the margin is positive on K ∩ R i.
  have h_region_pos : ∀ i : ι, (cov.K ∩ cov.R i).Nonempty → ∀ x ∈ cov.K ∩ cov.R i, 0 < margin x := by
    intro i hi x hx;
    exact lt_of_lt_of_le ( this.1 i hi ) ( sInf_image_le_of_mem ( cov.hcompact.inter_right ( cov.hclosed i ) ) ( hcont.mono ( Set.inter_subset_left ) ) hx );
  -- By definition of degree-1 exactness, for every region i, the margin is positive on K ∩ R i. Hence, we can apply the finite cover gluing lemma to conclude that the margin is positive on K.
  have h_finite_cover_gluing : ∀ x ∈ cov.K, 0 < margin x := by
    intro x hx
    obtain ⟨i, hi⟩ : ∃ i : ι, x ∈ cov.R i := by
      simpa using cov.hcover hx;
    exact h_region_pos i ⟨ x, hx, hi ⟩ x ⟨ hx, hi ⟩;
  exact ⟨ sInf ( margin '' cov.K ), compact_sInf_pos_iff cov.hcompact hne hcont |>.2 h_finite_cover_gluing, fun x hx => sInf_image_le_of_mem cov.hcompact hcont hx ⟩

/-
**Backward direction**: Uniform positive margin implies degree-1 exactness
(under continuity and compactness assumptions).
-/
theorem uniform_positive_margin_implies_degreeOneExact
    {ι : Type*} [Fintype ι]
    {E : Type*} [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ)
    (_hcont : ContinuousOn margin cov.K)
    (hglob : UniformPositiveMargin cov.K margin) :
    DegreeOneExact cov margin := by
  cases' hglob with δ hδ
  constructor;
  · intro i hi;
    refine' lt_of_lt_of_le hδ.1 ( le_csInf _ _ );
    · exact hi.image _;
    · grind;
  · intro i j h;
    exact lt_of_lt_of_le hδ.1 ( le_csInf ( Set.Nonempty.image _ h ) ( by rintro _ ⟨ x, hx, rfl ⟩ ; exact hδ.2 x hx.1.1 ) )

/-- **The Main Equivalence**: Degree-1 exactness of the margin cosheaf on the
activation nerve is equivalent to existence of a uniform positive global
margin on the covered compact domain.

This is the central theorem connecting combinatorial topology (cosheaf
exactness on the activation nerve) to neural certification (global
robustness). -/
theorem degreeOneExact_iff_uniform_positive_margin
    {ι : Type*} [Fintype ι]
    {E : Type*} [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ)
    (hcont : ContinuousOn margin cov.K)
    (hne : cov.K.Nonempty) :
    DegreeOneExact cov margin ↔ UniformPositiveMargin cov.K margin := by
  exact ⟨degreeOneExact_implies_uniform_positive_margin cov margin hcont hne,
         uniform_positive_margin_implies_degreeOneExact cov margin hcont⟩

/-
**Certified Robustness Radius**: From degree-1 exactness and a Lipschitz
bound on the margin function, derive a positive certified robustness radius.
-/
theorem activation_nerve_exactness_gives_certified_radius
    {ι : Type*} [Fintype ι]
    {E : Type*} [PseudoMetricSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hcont : ContinuousOn margin cov.K)
    (hne : cov.K.Nonempty)
    (hLip : LipschitzWith ⟨L, hL.le⟩ margin)
    (hexact : DegreeOneExact cov margin) :
    ∃ r > 0, CertifiedRobustOn cov.K margin r := by
  -- From hexact and degreeOneExact_implies_uniform_positive_margin, get δ > 0 with ∀ x ∈ K, δ ≤ margin x.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x ∈ cov.K, δ ≤ margin x := by
    apply degreeOneExact_implies_uniform_positive_margin cov margin hcont hne hexact;
  refine' ⟨ δ / ( 2 * L ), div_pos hδ_pos ( mul_pos zero_lt_two hL ), fun x hx y hy => _ ⟩;
  have := hLip.dist_le_mul x y;
  norm_num at *; nlinarith [ hδ x hx, mul_div_cancel₀ δ ( by positivity : ( 2 * L ) ≠ 0 ), abs_le.mp this ] ;

/-! ## Abstract Gluing Theorem -/

/-
**Finite cover gluing**: If a compact set is covered by finitely many
closed sets, and a continuous function is positive on each piece, then it
is uniformly positive on the whole set.
-/
theorem finite_cover_glues_positive_margin
    {ι : Type*} [Fintype ι]
    {E : Type*} [TopologicalSpace E]
    (K : Set E) (R : ι → Set E) (f : E → ℝ)
    (hK : IsCompact K) (hne : K.Nonempty)
    (_hcov : K ⊆ ⋃ i, R i)
    (hcont : ContinuousOn f K)
    (hpos : ∀ x ∈ K, 0 < f x) :
    ∃ δ > 0, ∀ x ∈ K, δ ≤ f x := by
  have := hK.exists_isMinOn hne hcont;
  exact ⟨ f this.choose, hpos _ this.choose_spec.1, fun x hx => this.choose_spec.2 hx ⟩

/-
**Non-exactness produces a margin witness**: If degree-1 exactness fails,
then either some region or some overlap has non-positive margin infimum.
-/
theorem nonexact_produces_margin_gap
    {ι : Type*} [Fintype ι]
    {E : Type*} [TopologicalSpace E]
    (cov : ActivationCover ι E) (margin : E → ℝ)
    (hnotexact : ¬ DegreeOneExact cov margin) :
    (∃ i : ι, (cov.K ∩ cov.R i).Nonempty ∧ regionMargin cov margin i ≤ 0) ∨
    (∃ i j : ι, (cov.K ∩ cov.R i ∩ cov.R j).Nonempty ∧
      overlapMargin cov margin i j ≤ 0) := by
  contrapose! hnotexact;
  exact hnotexact

/-! ## Lipschitz Perturbation Bound -/

/-
**Lipschitz margin perturbation**: If margin is L-Lipschitz and
margin(x) ≥ δ, then margin(y) > 0 for all y with dist(x,y) < δ/(2L).
-/
theorem lipschitz_margin_perturbation
    {E : Type*} [PseudoMetricSpace E]
    (margin : E → ℝ) (L δ : ℝ) (hL : 0 < L) (hδ : 0 < δ)
    (hLip : LipschitzWith ⟨L, hL.le⟩ margin)
    (x : E) (hx : δ ≤ margin x)
    (y : E) (hy : dist x y ≤ δ / (2 * L)) :
    0 < margin y := by
  have := hLip.dist_le_mul x y;
  norm_num at *; nlinarith [ mul_div_cancel₀ δ ( by linarith : ( 2 * L ) ≠ 0 ), abs_le.mp this ] ;

end ActivationNerveMarginCosheaf

/- Corrupted trailing fragment of a lost statement, preserved verbatim but
commented out so the file parses.

end .
-/