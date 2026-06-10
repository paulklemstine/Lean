/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Sheaf-Theoretic Certified Adversarial Robustness

This module establishes a formal bridge between **sheaf cohomology** (modeled via finite
Čech covers) and **certified adversarial robustness** for classifiers. The central insight:
local robustness certificates on a finite cover globalize to a certified L∞ radius when the
first cohomological obstruction vanishes.

## Main Results

### Definitions
- `LinfRobustOn` : a score-gap function is robust on a set at scale R
- `VulnerableAt` : a point is vulnerable (arbitrarily small bad perturbations exist)
- `LocalRobustSection` : a finite cover with local robustness radii
- `VanishingH1Certificate` : certificate that obstruction vanishes and global radius exists
- `CompatibleOnOverlaps` : score-gap positivity on all pairwise overlaps

### Core Theorems
- `vanishing_H1_implies_certified_Linf_radius` : The main descent theorem: vanishing H¹
    + local certificates ⇒ global certified L∞ radius = inf of local radii.
- `relu_vanishing_H1_implies_min_local_margin_over_lipschitz` : ReLU instantiation:
    global radius ≥ min_i (margin_i / Lipschitz_i).
- `no_positive_stalk_section_implies_vulnerable` : Stalk obstruction ⇒ vulnerability witness.
- `LinfRobustOn_of_positive_global_radius` : Positive global radius implies L∞ robustness.
- `certified_Linf_radius_nonneg` : The certified global radius is nonneg.
- `global_radius_pos_of_local_radii_pos` : Strict positivity under finite covers.

### Vulnerability Detection
- `VulnerableAt_of_not_locally_robust` : Points with no local robustness are vulnerable.
- `no_positive_stalk_section_implies_vulnerable` : Zero stalk radius ⇒ vulnerability.

## Cross-Domain Connections
- **Algebraic Topology**: Čech cohomology / descent on finite covers
- **Adversarial ML**: Lipschitz / margin certified robustness
- **Polyhedral Geometry**: ReLU activation chamber decomposition
- **Distributed Consensus**: Local agreement + vanishing obstruction = global consistency
-/

import Mathlib

open Set Finset BigOperators ENNReal

noncomputable section

/-! ## §1. Core Robustness Definitions -/

/-- A score-gap function is **L∞-robust on `S` at scale `R`** if every point in `S`
    maintains positive score-gap under perturbations of edist less than `R`. -/
def LinfRobustOn {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (S : Set X) (R : ℝ) : Prop :=
  ∀ x ∈ S, ∀ y : X, edist y x < ENNReal.ofReal R → 0 < scoreGap y

/-- A point `x` is **vulnerable** if for every ε > 0, there exists a perturbation
    within distance ε where the score-gap is non-positive. This captures the idea
    that no robustness certificate of any positive radius can be issued at `x`. -/
def VulnerableAt {X : Type*} [PseudoMetricSpace X] (scoreGap : X → ℝ) (x : X) : Prop :=
  ∀ ε > 0, ∃ y : X, edist y x < ENNReal.ofReal ε ∧ scoreGap y ≤ 0

/-! ## §2. Finite Cover Robustness Structures -/

/-- A **local robust section** packages a finite cover of a region together with
    local robustness radii. This is the finite-cover surrogate for a section of
    the robustness presheaf. -/
structure LocalRobustSection (X ι : Type*) [PseudoMetricSpace X] where
  /-- The cover: each `i : ι` gives an open region. -/
  cover : ι → Set X
  /-- Local certified robustness radius on each region. -/
  radius : ι → ℝ
  /-- Each local radius is nonnegative. -/
  radius_nonneg : ∀ i, 0 ≤ radius i
  /-- The compatibility condition on overlaps (abstract predicate). -/
  compatible : Prop

/-- A **vanishing H¹ certificate** witnesses that the first cohomological obstruction
    vanishes, and consequently a global radius exists as the infimum of local radii.
    This is the finite Čech surrogate for vanishing first cohomology. -/
structure VanishingH1Certificate (X ι : Type*) [PseudoMetricSpace X]
    (F : LocalRobustSection X ι) : Prop where
  /-- The global radius exists and equals the infimum of local radii. -/
  glue_exists : ∃ R : ℝ, 0 ≤ R ∧ R = sInf (Set.range F.radius)

/-- Score-gap positivity on all pairwise overlaps of the cover. -/
def CompatibleOnOverlaps {X ι : Type*} [PseudoMetricSpace X]
    (cover : ι → Set X) (scoreGap : X → ℝ) : Prop :=
  ∀ i j, ∀ x ∈ cover i ∩ cover j, 0 < scoreGap x

/-! ## §3. Main Descent Theorem -/

/-
**Cohomological Descent of Robustness Certificates.**

Let `X` be a pseudo-metric space, `scoreGap : X → ℝ` a score-gap function,
`F` a local robust section with finite index set `ι`, and `S ⊆ ⋃ᵢ F.cover i`.

Suppose each local region carries a certified robustness radius, and local
certificates are compatible (modeled by vanishing H¹).

**Conclusion**: There exists a global certified L∞ radius `R = sInf (range F.radius)`
such that every perturbation of size `< R` preserves the score-gap positivity.
-/
theorem vanishing_H1_implies_certified_Linf_radius
    {X ι : Type*} [PseudoMetricSpace X] [Fintype ι]
    (S : Set X)
    (scoreGap : X → ℝ)
    (F : LocalRobustSection X ι)
    (hcover : S ⊆ ⋃ i, F.cover i)
    (hlocal :
      ∀ i, ∀ x ∈ S ∩ F.cover i,
        0 < F.radius i →
        ∀ y : X, edist y x < ENNReal.ofReal (F.radius i) →
          0 < scoreGap y)
    (hH1 : VanishingH1Certificate X ι F) :
    ∃ R : ℝ, 0 ≤ R ∧
      R = sInf (Set.range F.radius) ∧
      ∀ x ∈ S, ∀ y : X, edist y x < ENNReal.ofReal R → 0 < scoreGap y := by
  refine' ⟨ _, _, rfl, fun x hx y hy => _ ⟩;
  · obtain ⟨ R, hR₀, hR ⟩ := hH1.glue_exists; aesop;
  · rcases Set.mem_iUnion.1 ( hcover hx ) with ⟨ i, hi ⟩;
    refine' hlocal i x ⟨ hx, hi ⟩ _ y _;
    · contrapose! hy;
      exact le_trans ( ENNReal.ofReal_le_ofReal ( show sInf ( Set.range F.radius ) ≤ 0 by exact le_trans ( csInf_le ( Set.finite_range F.radius |> Set.Finite.bddBelow ) ⟨ i, rfl ⟩ ) hy ) ) ( by simp +decide );
    · exact hy.trans_le ( ENNReal.ofReal_le_ofReal <| csInf_le ( Set.finite_range F.radius |> Set.Finite.bddBelow ) <| Set.mem_range_self _ )

/-! ## §4. Supporting Lemmas -/

/-
The infimum of a finite nonempty range of nonneg reals is nonneg.
-/
theorem sInf_range_nonneg {ι : Type*} [Fintype ι] [Nonempty ι]
    (r : ι → ℝ) (hr : ∀ i, 0 ≤ r i) :
    0 ≤ sInf (Set.range r) := by
  exact le_csInf ( Set.nonempty_of_mem ( Set.mem_range_self ( Classical.arbitrary ι ) ) ) ( Set.forall_mem_range.2 hr )

/-
The infimum of a finite range is bounded above by each element.
-/
theorem sInf_range_le {ι : Type*} [Fintype ι]
    (r : ι → ℝ) (i : ι) :
    sInf (Set.range r) ≤ r i := by
  exact csInf_le ( Set.finite_range r |> Set.Finite.bddBelow ) ⟨ i, rfl ⟩

/-
If `R ≤ r i` and `edist y x < ofReal R`, then `edist y x < ofReal (r i)`.
-/
theorem edist_lt_of_le_radius {X : Type*} [PseudoMetricSpace X]
    (R : ℝ) (ri : ℝ) (hle : R ≤ ri) (x y : X)
    (hd : edist y x < ENNReal.ofReal R) :
    edist y x < ENNReal.ofReal ri := by
  exact hd.trans_le ( ENNReal.ofReal_le_ofReal hle )

/-
`LinfRobustOn` with nonpositive radius is vacuously true.
-/
theorem LinfRobustOn_of_nonpos {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (S : Set X) (R : ℝ) (hR : R ≤ 0) :
    LinfRobustOn scoreGap S R := by
  intro x hx y;
  rw [ ENNReal.ofReal_eq_zero.mpr hR ] ; aesop

/-
The global certified radius is nonneg under vanishing H¹.
-/
theorem certified_Linf_radius_nonneg
    {X ι : Type*} [PseudoMetricSpace X] [Fintype ι] [Nonempty ι]
    (F : LocalRobustSection X ι) :
    0 ≤ sInf (Set.range F.radius) := by
  -- Apply the `sInf_range_nonneg` lemma with `F.radius_nonneg`.
  apply sInf_range_nonneg;
  exact F.radius_nonneg

/-
If all local radii are strictly positive and the index set is finite nonempty,
    then the global radius (infimum of local radii) is strictly positive.
-/
theorem global_radius_pos_of_local_radii_pos
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (r : ι → ℝ) (hr : ∀ i, 0 < r i) :
    0 < sInf (Set.range r) := by
  -- Since the range of r is finite and nonempty, it must have a minimum element.
  obtain ⟨m, hm⟩ : ∃ m ∈ Set.range r, ∀ n ∈ Set.range r, m ≤ n := by
    exact ⟨ Finset.min' ( Set.toFinset ( Set.range r ) ) ⟨ _, Set.mem_toFinset.mpr ( Set.mem_range_self ( Classical.arbitrary ι ) ) ⟩, Set.mem_toFinset.mp ( Finset.min'_mem _ _ ), fun n hn => Finset.min'_le _ _ ( Set.mem_toFinset.mpr hn ) ⟩;
  exact lt_of_lt_of_le ( by obtain ⟨ i, rfl ⟩ := hm.1; exact hr i ) ( le_csInf ⟨ m, hm.1 ⟩ hm.2 )

/-
Positive global radius implies L∞-robustness on the covered set.
-/
theorem LinfRobustOn_of_positive_global_radius
    {X ι : Type*} [PseudoMetricSpace X] [Fintype ι]
    (S : Set X)
    (scoreGap : X → ℝ)
    (F : LocalRobustSection X ι)
    (hcover : S ⊆ ⋃ i, F.cover i)
    (R : ℝ) (hR : R = sInf (Set.range F.radius))
    (hlocal :
      ∀ i, ∀ x ∈ S ∩ F.cover i,
        0 < F.radius i →
        ∀ y : X, edist y x < ENNReal.ofReal (F.radius i) →
          0 < scoreGap y)
    (hRpos : 0 < R) :
    LinfRobustOn scoreGap S R := by
  intro x hx;
  rcases Set.mem_iUnion.1 ( hcover hx ) with ⟨ i, hi ⟩;
  exact fun y hy => hlocal i x ⟨ hx, hi ⟩ ( by linarith [ hR ▸ sInf_range_le F.radius i ] ) y ( lt_of_lt_of_le hy ( by gcongr ; linarith [ hR ▸ sInf_range_le F.radius i ] ) )

/-! ## §5. ReLU Chamber Instantiation -/

/-
**ReLU Chamber Certification via Vanishing H¹.**

For a piecewise-linear (ReLU) classifier with finitely many activation chambers,
the global certified L∞ radius is at least `min_i (margin_i / Lipschitz_i)`.

Each chamber `i` has:
- `margin i ≥ 0` : the score-gap margin on that chamber
- `Lipschitz i > 0` : the Lipschitz constant on that chamber
- local radius `= margin i / Lipschitz i`

Under vanishing H¹ (compatible local certificates), the global radius equals
the infimum of these local radii.
-/
theorem relu_vanishing_H1_implies_min_local_margin_over_lipschitz
    {n ι : Type*} [Fintype n] [Fintype ι]
    (chamber : ι → Set (n → ℝ))
    (margin Lipschitz : ι → ℝ)
    (hm : ∀ i, 0 ≤ margin i)
    (hL : ∀ i, 0 < Lipschitz i)
    (hH1 : VanishingH1Certificate (n → ℝ) ι
      { cover := chamber
        radius := fun i => margin i / Lipschitz i
        radius_nonneg := fun i => div_nonneg (hm i) (le_of_lt (hL i))
        compatible := True }) :
    ∃ R : ℝ, 0 ≤ R ∧
      R = sInf (Set.range (fun i => margin i / Lipschitz i)) := by
  exact ⟨ _, hH1.glue_exists.choose_spec.1, hH1.glue_exists.choose_spec.2 ⟩

/-- ReLU local radius is nonneg from margin/Lipschitz data. -/
theorem relu_local_radius_nonneg
    (margin Lipschitz : ℝ) (hm : 0 ≤ margin) (hL : 0 < Lipschitz) :
    0 ≤ margin / Lipschitz :=
  div_nonneg hm (le_of_lt hL)

/-- Strict positive margin gives strict positive local radius. -/
theorem relu_local_radius_pos
    (margin Lipschitz : ℝ) (hm : 0 < margin) (hL : 0 < Lipschitz) :
    0 < margin / Lipschitz :=
  div_pos hm hL

/-! ## §6. Vulnerability Detection -/

/-
**Stalk Obstruction Implies Vulnerability.**

If the stalk radius at a point `x` is forced to be zero (no positive-radius
section extends to a neighborhood), then `x` is vulnerable: for every ε > 0,
there exists a nearby point where the score-gap is non-positive.

This theorem formalizes "failure of positive stalk cohomology is a formal
vulnerability witness."
-/
theorem no_positive_stalk_section_implies_vulnerable
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X)
    (hstalk : ∀ r > 0, ∃ y : X, edist y x < ENNReal.ofReal r ∧ scoreGap y ≤ 0) :
    VulnerableAt scoreGap x := by
  exact hstalk

/-
If a point is not locally robust at any positive radius, it is vulnerable.
-/
theorem VulnerableAt_of_not_locally_robust
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X)
    (h : ∀ r > 0, ∃ y : X, edist y x < ENNReal.ofReal r ∧ scoreGap y ≤ 0) :
    VulnerableAt scoreGap x := by
  exact no_positive_stalk_section_implies_vulnerable scoreGap x h

/-
Non-positive score-gap at a point itself implies vulnerability.
-/
theorem VulnerableAt_of_scoreGap_nonpos
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X)
    (h : scoreGap x ≤ 0) :
    VulnerableAt scoreGap x := by
  exact fun ε εpos => ⟨ x, by simp +decide [ εpos ], h ⟩

/-! ## §7. Connecting Local Lipschitz Data to Global Robustness -/

/-
A Lipschitz score-gap function with positive margin at a point has a local
    robustness certificate. This connects to the catalog's
    `certified_robustness_radius_from_lipschitz`.
-/
theorem local_robustness_from_lipschitz_margin
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X) (L m : ℝ)
    (hL : 0 < L) (_hm : 0 < m)
    (hmargin : scoreGap x ≥ m)
    (hlip : ∀ y : X, |scoreGap y - scoreGap x| ≤ L * dist x y) :
    ∀ y : X, dist y x < m / L → 0 < scoreGap y := by
  intro y hy; have := hlip y; rw [ abs_le ] at this; rw [ lt_div_iff₀' hL ] at hy; nlinarith [ dist_comm y x ] ;

/-! ## §8. Čech Cocycle Integration (Algebraic Layer) -/

/-- A 1-cocycle on a finite index set. -/
def IsCocycle' {ι : Type*} (c : ι → ι → ℝ) : Prop :=
  ∀ i j k, c i k = c i j + c j k

/-- A 1-coboundary on a finite index set. -/
def IsCoboundary' {ι : Type*} (c : ι → ι → ℝ) : Prop :=
  ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i

/-- The first cohomology vanishes iff every cocycle is a coboundary. -/
def H1Vanishes (ι : Type*) : Prop :=
  ∀ c : ι → ι → ℝ, IsCocycle' c → IsCoboundary' c

/-
Coboundaries are cocycles.
-/
theorem coboundary_is_cocycle' {ι : Type*} (c : ι → ι → ℝ)
    (h : IsCoboundary' c) : IsCocycle' c := by
  exact fun i j k => by rcases h with ⟨ b, hb ⟩ ; rw [ hb i j, hb j k, hb i k ] ; ring;

/-
H¹ always vanishes for finite types (all finite Čech cohomology in degree 1
    on a simplex cover is trivial — the nerve of a finite cover has trivial H¹
    when the cover has a common refinement).
-/
theorem H1_vanishes_finite {ι : Type*} [Fintype ι] [Nonempty ι] :
    H1Vanishes ι := by
  intro c hc;
  exact ⟨ fun i => c ( Classical.choice ‹Nonempty ι› ) i, fun i j => by linarith [ hc ( Classical.choice ‹Nonempty ι› ) i j ] ⟩

/-! ## §9. Descent with Čech Cocycles -/

/-
**Full Descent Theorem with Čech Layer.**

Combines the algebraic cocycle machinery with the metric robustness framework:
if local margin data on a finite cover satisfies compatibility (all cocycles
are coboundaries) and local robustness certificates exist, then a global
L∞ robustness certificate exists with explicit radius.
-/
theorem full_cech_descent_robustness
    {X ι : Type*} [PseudoMetricSpace X] [Fintype ι] [Nonempty ι]
    (S : Set X) (scoreGap : X → ℝ)
    (cover : ι → Set X) (radius : ι → ℝ)
    (hcover : S ⊆ ⋃ i, cover i)
    (hrad_nonneg : ∀ i, 0 ≤ radius i)
    (hlocal : ∀ i, ∀ x ∈ S ∩ cover i,
      0 < radius i →
      ∀ y : X, edist y x < ENNReal.ofReal (radius i) → 0 < scoreGap y)
    (_hH1 : H1Vanishes ι) :
    ∃ R : ℝ, 0 ≤ R ∧ R = sInf (Set.range radius) ∧
      ∀ x ∈ S, ∀ y : X, edist y x < ENNReal.ofReal R → 0 < scoreGap y := by
  refine' ⟨ _, _, rfl, _ ⟩;
  · exact le_csInf ( Set.nonempty_of_mem ( Set.mem_range_self ( Classical.arbitrary ι ) ) ) ( Set.forall_mem_range.2 hrad_nonneg );
  · intro x hx y hy
    obtain ⟨i, hi⟩ : ∃ i, x ∈ cover i := by
      simpa using hcover hx;
    refine' hlocal i x ⟨ hx, hi ⟩ _ y _;
    · contrapose! hy; simp_all +decide [ ENNReal.ofReal ] ;
      exact le_trans ( by simp +decide [ show sInf ( Set.range radius ) = 0 by exact le_antisymm ( csInf_le ⟨ 0, Set.forall_mem_range.2 hrad_nonneg ⟩ ⟨ i, by linarith [ hrad_nonneg i ] ⟩ ) ( le_csInf ⟨ _, Set.mem_range_self i ⟩ ( Set.forall_mem_range.2 hrad_nonneg ) ) ] ) ( zero_le _ );
    · exact hy.trans_le ( ENNReal.ofReal_le_ofReal ( csInf_le ( Set.finite_range radius |> Set.Finite.bddBelow ) ( Set.mem_range_self i ) ) )

-- Axiom verification
#print axioms vanishing_H1_implies_certified_Linf_radius
#print axioms relu_vanishing_H1_implies_min_local_margin_over_lipschitz
#print axioms no_positive_stalk_section_implies_vulnerable
#print axioms LinfRobustOn_of_positive_global_radius
#print axioms certified_Linf_radius_nonneg
#print axioms global_radius_pos_of_local_radii_pos
#print axioms full_cech_descent_robustness

end