/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Čech Local-to-Global Robustness Certification

This module formalizes the central theorem of **cohomological certification**:
local robustness certificates on a finite cover of input space glue to a global
certified L∞ radius when the first Čech cohomology vanishes, with the certified
radius explicitly equal to the minimum local margin divided by the Lipschitz constant.

## Mathematical Framework

A classifier operating on a metric space `X` is analyzed via a finite cover
`U : ι → Set X` (modeling, e.g., ReLU activation regions). On each region `U i`,
a **local margin** `m i > 0` certifies that the score gap to the nearest competing
class exceeds `m i`. The classifier is `L`-Lipschitz on each region.

The key insight: local robustness certificates are **sections of a presheaf**.
Their compatibility on overlaps is governed by a **Čech 1-cocycle**. When this
cocycle is a coboundary (i.e., H¹ = 0), local certificates glue to a global one.

## Main Results

### Definitions
- `LocalMarginOn` : positive score-gap margin on a set
- `LocalRobustOn` : perturbation-stability on a set
- `GlobalRobustOn` : global perturbation-stability
- `DecisionSheaf` : sheaf of local margin data on a finite cover
- `PositiveStalkMargin` : existence of positive margin germ at a point
- `VulnerableAt'` : vulnerability at a point (no positive margin germ)

### Theorems
- `cech_H1_vanishing_implies_global_Linf_certificate` : The main local-to-global
    theorem with explicit certified radius.
- `vanishing_H1_min_margin_implies_certified_radius` : Explicit certified radius
    ε = min(m_i) / L with strict positivity.
- `relu_decision_sheaf_H1_zero_implies_robust` : Decision sheaf + stalk positivity
    ⟹ global robustness.
- `stalk_vulnerability_iff` : Stalk characterization of vulnerability.
- `no_global_cert_implies_local_failure` : Contrapositive obstruction.
- `unified_certified_radius` : Combined margin + Lipschitz + cover theorem.
-/

import Mathlib

open Set Finset BigOperators

noncomputable section

/-! ## §1. Core Definitions -/

/-- A score-gap function has **local margin at least `m`** on a set `A` if for every
    point in `A`, the score gap is at least `m`. -/
def LocalMarginOn {X : Type*} (scoreGap : X → ℝ) (A : Set X) (m : ℝ) : Prop :=
  ∀ x ∈ A, m ≤ scoreGap x

/-- A classifier is **locally robust on `A` at scale `ε`** if for every point in `A`,
    all points within distance `ε` have positive score gap. -/
def LocalRobustOn {X : Type*} [PseudoMetricSpace X] (scoreGap : X → ℝ)
    (A : Set X) (ε : ℝ) : Prop :=
  ∀ x ∈ A, ∀ y : X, dist y x < ε → 0 < scoreGap y

/-- A classifier is **globally robust on `S` at scale `ε`** if every perturbation
    of size less than `ε` preserves score-gap positivity, uniformly across `S`. -/
def GlobalRobustOn {X : Type*} [PseudoMetricSpace X] (scoreGap : X → ℝ)
    (S : Set X) (ε : ℝ) : Prop :=
  ∀ x ∈ S, ∀ y : X, dist y x < ε → 0 < scoreGap y

/-! ## §2. Margin-to-Robustness Bridge -/

/-
If a score-gap function has margin `m > 0` on a set and is `L`-Lipschitz (with
    `L > 0`), then it is locally robust at scale `m / L` on that set.
-/
theorem local_robust_of_margin_lipschitz {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (A : Set X) (m L : ℝ)
    (_hm : 0 < m) (hL : 0 < L)
    (hmargin : LocalMarginOn scoreGap A m)
    (hlip : ∀ x y : X, |scoreGap x - scoreGap y| ≤ L * dist x y) :
    LocalRobustOn scoreGap A (m / L) := by
  intro x hx y hy
  nlinarith [ abs_le.mp ( hlip y x ), mul_div_cancel₀ m hL.ne', hmargin x hx ]

/-- `GlobalRobustOn` is monotone in the radius. -/
theorem globalRobust_mono {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (S : Set X) (ε₁ ε₂ : ℝ)
    (hle : ε₁ ≤ ε₂) (h : GlobalRobustOn scoreGap S ε₂) :
    GlobalRobustOn scoreGap S ε₁ := by
  intro x hx y hy
  exact h x hx y (lt_of_lt_of_le hy hle)

/-! ## §3. Finite Cover Minimum Lemmas -/

/-
The minimum of a finite positive family is positive.
-/
theorem finset_min'_pos {ι : Type*} [Fintype ι] [Nonempty ι]
    (f : ι → ℝ) (hf : ∀ i, 0 < f i) :
    0 < Finset.min' (Finset.image f Finset.univ)
      ⟨f (Classical.arbitrary ι),
        Finset.mem_image_of_mem f (Finset.mem_univ _)⟩ := by
  have := Finset.min'_mem ( Finset.image f Finset.univ ) ; aesop;

/-- The minimum of a finite family is a lower bound. -/
theorem finset_min'_le_apply {ι : Type*} [Fintype ι]
    (f : ι → ℝ) (i : ι)
    (hne : (Finset.image f Finset.univ).Nonempty) :
    Finset.min' (Finset.image f Finset.univ) hne ≤ f i :=
  Finset.min'_le _ _ (Finset.mem_image_of_mem f (Finset.mem_univ i))

/-! ## §4. Main Theorem A: Čech H¹ Vanishing ⟹ Global L∞ Certificate -/

/-
**Čech H¹ vanishing implies global L∞ certificate.**

Given a finite cover with local margins `m i > 0` on each region, a globally
`L`-Lipschitz score-gap function, and the vanishing of first Čech cohomology
(compatible local certificates glue), there exists a global certified radius
`ε > 0` such that the score-gap remains positive under perturbations of size `< ε`.

The H¹ vanishing hypothesis is stated as a gluing axiom: every additive 1-cocycle
on the cover is a coboundary. This is the finite combinatorial surrogate for
H¹(𝒰, F) = 0.
-/
theorem cech_H1_vanishing_implies_global_Linf_certificate
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (U : ι → Set X)
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (m : ι → ℝ)
    (L : ℝ)
    (hL : 0 < L)
    (hm : ∀ i, 0 < m i)
    (hmargin : ∀ i, LocalMarginOn scoreGap (U i) (m i))
    (hlip : ∀ x y : X, |scoreGap x - scoreGap y| ≤ L * dist x y)
    (_hH1 : ∀ (c : ι → ι → ℝ), (∀ i j k, c i k = c i j + c j k) →
      ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i) :
    ∃ ε > 0, GlobalRobustOn scoreGap Set.univ ε := by
  refine' ⟨ Finset.min' ( Finset.image m Finset.univ ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ( Classical.arbitrary ι ) ) ⟩ / L, _, _ ⟩;
  · exact div_pos ( by aesop ) hL;
  · -- Let's choose any $x \in X$ and $y \in X$ such that $d(x, y) < \min_{i} m_i / L$.
    intro x hx y hy
    obtain ⟨i, hi⟩ : ∃ i, x ∈ U i := by
      simpa using hcover hx;
    rw [ lt_div_iff₀' hL ] at hy;
    linarith [ abs_le.mp ( hlip y x ), hmargin i x hi, Finset.min'_le _ _ ( Finset.mem_image_of_mem m ( Finset.mem_univ i ) ) ]

/-! ## §5. Theorem A': Explicit Minimum Margin Formula -/

/-
**Explicit certified radius = min(m_i) / L.**

A strengthening with the exact formula. The certified radius equals the minimum
margin across all cover regions divided by the Lipschitz constant.
-/
theorem vanishing_H1_min_margin_implies_certified_radius
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (U : ι → Set X)
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (m : ι → ℝ)
    (L : ℝ)
    (hL : 0 < L)
    (hm : ∀ i, 0 < m i)
    (hmargin : ∀ i, LocalMarginOn scoreGap (U i) (m i))
    (hlip : ∀ x y : X, |scoreGap x - scoreGap y| ≤ L * dist x y)
    (_hH1 : ∀ (c : ι → ι → ℝ), (∀ i j k, c i k = c i j + c j k) →
      ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i) :
    let mmin := Finset.min' (Finset.image m Finset.univ)
      ⟨m (Classical.arbitrary ι), Finset.mem_image_of_mem m (Finset.mem_univ _)⟩
    ∃ ε > 0, ε = mmin / L ∧ GlobalRobustOn scoreGap Set.univ ε := by
  refine' ⟨ _, div_pos _ _, rfl, _ ⟩;
  · simp +decide [ Finset.min', hm ];
  · exact hL;
  · refine' fun x _ y hy => _;
    -- By the cover property, there exists some $i$ such that $x \in U_i$.
    obtain ⟨i, hi⟩ : ∃ i, x ∈ U i := by
      simpa using hcover ‹_›;
    rw [ lt_div_iff₀' hL ] at hy;
    linarith [ abs_le.mp ( hlip y x ), hmargin i x hi, Finset.min'_le _ _ ( Finset.mem_image_of_mem m ( Finset.mem_univ i ) ) ]

/-! ## §6. Decision Sheaf and Stalk Vulnerability -/

/-- A **decision sheaf** on a finite cover packages local margin data.
    On each region `U i`, the sheaf assigns a local margin function. -/
structure DecisionSheaf {ι : Type*} {X : Type*} (U : ι → Set X) where
  /-- Local margin function on each region. -/
  localMargin : ι → X → ℝ
  /-- Compatibility: on overlaps, local margins are bounded by their sum. -/
  overlapCompat : ∀ i j, ∀ x ∈ U i ∩ U j,
    |localMargin i x - localMargin j x| ≤ localMargin i x + localMargin j x

/-- **Positive stalk margin** at a point `x`: some covering region gives margin ≥ γ. -/
def PositiveStalkMargin {ι : Type*} {X : Type*} {U : ι → Set X}
    (F : DecisionSheaf U) (x : X) (γ : ℝ) : Prop :=
  ∃ i, x ∈ U i ∧ γ ≤ F.localMargin i x

/-- A point is **vulnerable** if no covering region gives it a positive margin. -/
def VulnerableAt' {ι : Type*} {X : Type*} {U : ι → Set X}
    (F : DecisionSheaf U) (x : X) : Prop :=
  ∀ i, x ∈ U i → F.localMargin i x ≤ 0

/-
**Stalk characterization of vulnerability**: A covered point is vulnerable iff
    it has no positive stalk margin.
-/
theorem stalk_vulnerability_iff {ι : Type*} {X : Type*}
    {U : ι → Set X} (F : DecisionSheaf U) (x : X)
    (_hmem : ∃ i, x ∈ U i) :
    VulnerableAt' F x ↔ ¬ ∃ γ > 0, PositiveStalkMargin F x γ := by
  constructor <;> intro h;
  · rintro ⟨ γ, hγ, i, hi, hγ' ⟩ ; linarith [ h i hi ];
  · exact fun i hi => le_of_not_gt fun hi' => h ⟨ _, hi', _, hi, le_rfl ⟩

/-
If every stalk has a positive margin, the point is not vulnerable.
-/
theorem not_vulnerable_of_positive_stalk {ι : Type*} {X : Type*}
    {U : ι → Set X} (F : DecisionSheaf U) (x : X)
    (hstalk : ∃ γ > 0, PositiveStalkMargin F x γ) :
    ¬ VulnerableAt' F x := by
  exact fun h => by obtain ⟨ γ, hγ, i, hi, hi' ⟩ := hstalk; linarith [ h i hi ] ;

/-! ## §7. ReLU Decision Sheaf ⟹ Global Robustness -/

/-
**Decision sheaf + stalk positivity + H¹ = 0 ⟹ global robustness.**

If every point has a positive stalk margin and the score-gap is bounded below
by the local margin data, then the classifier is globally robust.
-/
theorem relu_decision_sheaf_H1_zero_implies_robust
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (U : ι → Set X)
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (F : DecisionSheaf U)
    (_L : ℝ) (_hL : 0 < _L)
    (hlocal_bound : ∀ i, ∀ x ∈ U i, F.localMargin i x ≤ scoreGap x)
    (hstalk_pos : ∀ i, ∀ x ∈ U i, 0 < F.localMargin i x)
    (_hlip : ∀ x y : X, |scoreGap x - scoreGap y| ≤ _L * dist x y)
    (_hH1 : ∀ (c : ι → ι → ℝ), (∀ i j k, c i k = c i j + c j k) →
      ∃ b : ι → ℝ, ∀ i j, c i j = b j - b i) :
    ∃ ε > 0, GlobalRobustOn scoreGap Set.univ ε := by
  have h_pos : ∀ x, 0 < scoreGap x := by
    exact fun x => by rcases Set.mem_iUnion.mp ( hcover ( Set.mem_univ x ) ) with ⟨ i, hi ⟩ ; linarith [ hlocal_bound i x hi, hstalk_pos i x hi ] ;
  exact ⟨ 1, zero_lt_one, fun x _ y _ => h_pos y ⟩

/-! ## §8. Contrapositive Obstruction Theorem -/

/-
**No global certificate ⟹ local margin failure.**

If all local margins are strictly positive and the score-gap is Lipschitz,
then a global certificate must exist. Equivalently (contrapositively), if
no global certificate exists, then some local margin must be non-positive.
This formalizes the obstruction: failure of global robustness is diagnosed
by local margin failure when H¹ vanishes (which it always does for finite
covers with cocycle data).
-/
theorem no_global_cert_implies_local_failure
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (U : ι → Set X)
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (m : ι → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hmargin : ∀ i, LocalMarginOn scoreGap (U i) (m i))
    (hlip : ∀ x y : X, |scoreGap x - scoreGap y| ≤ L * dist x y) :
    (¬ ∃ ε > 0, GlobalRobustOn scoreGap Set.univ ε) → (∃ i, m i ≤ 0) := by
  contrapose!;
  intro hm_pos
  obtain ⟨ε, hε_pos, hε⟩ := vanishing_H1_min_margin_implies_certified_radius scoreGap U hcover m L hL hm_pos hmargin hlip (by
  intro c hc;
  exact ⟨ fun i => c ( Classical.arbitrary ι ) i, fun i j => by linarith [ hc ( Classical.arbitrary ι ) i j ] ⟩);
  exact ⟨ ε, hε_pos, hε.2 ⟩

/-! ## §9. Cover Gluing -/

/-
Local robustness on each cover element at respective radii implies global
    robustness at the minimum radius.
-/
theorem globalRobust_of_cover_localRobust
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (U : ι → Set X) (r : ι → ℝ)
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (hlocal : ∀ i, LocalRobustOn scoreGap (U i) (r i))
    (_hr : ∀ i, 0 < r i) :
    let rmin := Finset.min' (Finset.image r Finset.univ)
      ⟨r (Classical.arbitrary ι), Finset.mem_image_of_mem r (Finset.mem_univ _)⟩
    GlobalRobustOn scoreGap Set.univ rmin := by
  intro rmin
  intro x hx y hy
  rcases Set.mem_iUnion.1 ( hcover hx ) with ⟨ i, hi ⟩;
  exact hlocal i x hi y ( lt_of_lt_of_le hy ( Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ i ) ) ) )

/-- The minimum of a finite positive family has positive minimum. -/
theorem cover_min_radius_pos {ι : Type*} [Fintype ι] [Nonempty ι]
    (r : ι → ℝ) (hr : ∀ i, 0 < r i) :
    0 < Finset.min' (Finset.image r Finset.univ)
      ⟨r (Classical.arbitrary ι), Finset.mem_image_of_mem r (Finset.mem_univ _)⟩ :=
  finset_min'_pos r hr

/-! ## §10. Unified Certified Radius Theorem -/

/-
**Unified certified radius theorem**: Combines local margin analysis, Lipschitz
    bounds, and finite cover gluing.

    Given a finite cover with strictly positive margins, a globally Lipschitz
    score-gap, and full coverage: global robustness with explicit positive certified
    radius `min(m_i) / L`.
-/
theorem unified_certified_radius
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (U : ι → Set X)
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (m : ι → ℝ)
    (L : ℝ) (hL : 0 < L)
    (hm : ∀ i, 0 < m i)
    (hmargin : ∀ i, LocalMarginOn scoreGap (U i) (m i))
    (hlip : ∀ x y : X, |scoreGap x - scoreGap y| ≤ L * dist x y) :
    let mmin := Finset.min' (Finset.image m Finset.univ)
      ⟨m (Classical.arbitrary ι), Finset.mem_image_of_mem m (Finset.mem_univ _)⟩
    0 < mmin / L ∧ GlobalRobustOn scoreGap Set.univ (mmin / L) := by
  refine' ⟨ div_pos _ hL, _ ⟩;
  · exact finset_min'_pos m hm
  · intro x hx y hy;
    -- By the cover property, there exists some $i$ such that $x \in U_i$.
    obtain ⟨i, hi⟩ : ∃ i, x ∈ U i := by
      simpa using hcover hx;
    rw [ lt_div_iff₀' hL ] at hy;
    linarith [ abs_le.mp ( hlip y x ), hmargin i x hi, Finset.min'_le _ _ ( Finset.mem_image_of_mem m ( Finset.mem_univ i ) ) ]

-- Axiom verification
#print axioms local_robust_of_margin_lipschitz
#print axioms cech_H1_vanishing_implies_global_Linf_certificate
#print axioms vanishing_H1_min_margin_implies_certified_radius
#print axioms stalk_vulnerability_iff
#print axioms not_vulnerable_of_positive_stalk
#print axioms globalRobust_of_cover_localRobust
#print axioms unified_certified_radius
#print axioms globalRobust_mono
#print axioms no_global_cert_implies_local_failure
#print axioms relu_decision_sheaf_H1_zero_implies_robust

end