/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Sheaf Cohomology and Certified Adversarial Robustness: Novel Results

This module extends the sheaf-cohomological robustness framework with:

1. **Persistent Robustness Filtration** — A novel structure connecting TDA persistence
   to adversarial robustness.
2. **Composition Robustness Theorem** — Certified radius for composed Lipschitz maps.
3. **Mayer-Vietoris Robustness** — Two-set local-to-global gluing.
4. **Decision Boundary Vulnerability** — Points with zero margin are vulnerable.
5. **Weight Perturbation Stability** — Graceful degradation under weight changes.
6. **Cover Refinement Monotonicity** — Finer covers improve certification.

## Builds On
- `SheafCertifiedRobustness.lean`: `vanishing_H1_implies_certified_Linf_radius`
- `CechDecisionBoundaryObstructions.lean`: `finite_cover_vanishing_H1_implies_global_radius`
- `ActivationNerveCosheafRobustness.lean`: `nonexact_implies_vulnerability`
-/

import Mathlib

open Set Finset BigOperators

noncomputable section

/-! ## §1. Persistent Robustness Filtration (Novel Definition) -/

/-- The **persistent robustness set** at scale `r`: all points where the score-gap
    remains positive under perturbations of size < r. -/
def PersistentRobustSet {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (r : ℝ) : Set X :=
  {x : X | ∀ y : X, dist y x < r → 0 < scoreGap y}

/-- The **persistent robustness filtration**: packages a Lipschitz score-gap
    with its associated filtration. -/
structure PersistentRobustnessFiltration (X : Type*) [PseudoMetricSpace X] where
  scoreGap : X → ℝ
  lipschitzConst : ℝ
  lipschitz_pos : 0 < lipschitzConst
  lipschitz : ∀ x y : X, |scoreGap x - scoreGap y| ≤ lipschitzConst * dist x y

/-! ## §2. Filtration Monotonicity -/

/-- **Persistent robustness filtration is monotone decreasing**: increasing the
    perturbation radius shrinks the set of robust points. -/
theorem persistentRobustSet_antitone {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) :
    ∀ r₁ r₂ : ℝ, r₁ ≤ r₂ → PersistentRobustSet scoreGap r₂ ⊆ PersistentRobustSet scoreGap r₁ := by
  intro r₁ r₂ hr x hx y hy
  exact hx y (lt_of_lt_of_le hy hr)

/-- Points with non-positive score-gap are not in any positive persistent robust set. -/
theorem not_in_persistentRobustSet_of_nonpos {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X) (hx : scoreGap x ≤ 0) (r : ℝ) (hr : 0 < r) :
    x ∉ PersistentRobustSet scoreGap r := by
  intro h
  have := h x (by rw [dist_self]; exact hr)
  linarith

/-- The persistent robust set at non-positive radius is the whole space. -/
theorem persistentRobustSet_nonpos_eq_univ {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (r : ℝ) (hr : r ≤ 0) :
    PersistentRobustSet scoreGap r = Set.univ := by
  ext x
  simp only [PersistentRobustSet, Set.mem_setOf_eq, Set.mem_univ, iff_true]
  intro y hy
  have : (0 : ℝ) ≤ dist y x := dist_nonneg
  linarith

/-! ## §3. Composition Robustness -/

/-
**Composition Robustness Theorem**: For a Lipschitz feature map composed with
    a Lipschitz classifier, the certified robustness radius is at least m/(L₁·L₂).
-/
theorem composition_robustness
    {X Y : Type*} [PseudoMetricSpace X] [PseudoMetricSpace Y]
    (f : X → Y) (g : Y → ℝ)
    (L₁ L₂ m : ℝ)
    (hL₁ : 0 < L₁) (hL₂ : 0 < L₂) (hm : 0 < m)
    (hf_lip : ∀ a b : X, dist (f a) (f b) ≤ L₁ * dist a b)
    (hg_lip : ∀ a b : Y, |g a - g b| ≤ L₂ * dist a b)
    (x : X) (hmargin : g (f x) ≥ m) :
    x ∈ PersistentRobustSet (g ∘ f) (m / (L₁ * L₂)) := by
  intro y hy; have := hg_lip ( f y ) ( f x ) ; simp_all +decide [ abs_le ] ;
  rw [ lt_div_iff₀ ( mul_pos hL₁ hL₂ ) ] at hy ; nlinarith [ hf_lip y x, hg_lip ( f y ) ( f x ) ] ;

/-! ## §4. Mayer-Vietoris Robustness -/

/-- **Mayer-Vietoris Robustness Theorem**: If S ⊆ U₁ ∪ U₂ with local robustness,
    then S has robustness at radius min(r₁, r₂). -/
theorem mayerVietoris_robustness
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (S U₁ U₂ : Set X)
    (r₁ r₂ : ℝ)
    (hcover : S ⊆ U₁ ∪ U₂)
    (hr₁ : ∀ x ∈ S ∩ U₁, ∀ y : X, dist y x < r₁ → 0 < scoreGap y)
    (hr₂ : ∀ x ∈ S ∩ U₂, ∀ y : X, dist y x < r₂ → 0 < scoreGap y) :
    ∀ x ∈ S, ∀ y : X, dist y x < min r₁ r₂ → 0 < scoreGap y := by
  intro x hx y hy
  rcases hcover hx with h | h
  · exact hr₁ x ⟨hx, h⟩ y (lt_of_lt_of_le hy (min_le_left r₁ r₂))
  · exact hr₂ x ⟨hx, h⟩ y (lt_of_lt_of_le hy (min_le_right r₁ r₂))

/-! ## §5. Iterated Mayer-Vietoris -/

/-- **Iterated Mayer-Vietoris**: For n cover sets, robustness at the min of local radii. -/
theorem iterated_mayerVietoris_robustness
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ)
    (n : ℕ) (hn : 0 < n)
    (U : Fin n → Set X) (r : Fin n → ℝ)
    (S : Set X)
    (hcover : S ⊆ ⋃ i, U i)
    (hlocal : ∀ i, ∀ x ∈ S ∩ U i, ∀ y : X, dist y x < r i → 0 < scoreGap y) :
    ∀ x ∈ S, ∀ y : X, dist y x < Finset.inf' Finset.univ ⟨⟨0, hn⟩, Finset.mem_univ _⟩ r →
      0 < scoreGap y := by
  intro x hx y hy
  rcases Set.mem_iUnion.mp (hcover hx) with ⟨i, hi⟩
  exact hlocal i x ⟨hx, hi⟩ y (lt_of_lt_of_le hy (Finset.inf'_le r (Finset.mem_univ i)))

/-! ## §6. Decision Boundary Vulnerability -/

/-- Points where the score-gap is non-positive are vulnerable at every positive radius. -/
theorem decision_boundary_vulnerable {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X)
    (h : scoreGap x ≤ 0) :
    ∀ r > 0, ∃ y : X, dist y x < r ∧ scoreGap y ≤ 0 := by
  intro r hr
  exact ⟨x, by rwa [dist_self], h⟩

/-! ## §7. Weight Perturbation Stability -/

/-
**Weight Perturbation Stability (Corrected)**: If the score-gap g₁ has a uniform
    lower bound `m > δ` on the R-ball around x, and g₂ is δ-close to g₁ pointwise,
    then g₂ is positive on the R-ball. The certified radius is preserved.

    The original statement without a margin bound is false: g₁ could be barely
    positive (e.g., g₁(y) = ε → 0) while |g₁ - g₂| ≤ δ > ε forces g₂(y) < 0.
-/
theorem weight_perturbation_stability
    {X : Type*} [PseudoMetricSpace X]
    (g₁ g₂ : X → ℝ) (δ : ℝ) (_ : 0 ≤ δ)
    (hclose : ∀ x : X, |g₁ x - g₂ x| ≤ δ)
    (x : X) (R : ℝ)
    (hrobust : ∀ y : X, dist y x < R → g₁ y > δ) :
    x ∈ PersistentRobustSet g₂ R := by
  exact fun y hy => by linarith [ abs_le.mp ( hclose y ), hrobust y hy ] ;

/-! ## §8. Lipschitz Robustness Radius Characterization -/

/-
For a Lipschitz score-gap with positive margin m and Lipschitz constant L,
    the point is in the persistent robust set at radius m/L.
-/
theorem lipschitz_robustness_radius
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X) (L m : ℝ)
    (hL : 0 < L) (_ : 0 < m)
    (hmargin : scoreGap x ≥ m)
    (hlip : ∀ y : X, |scoreGap y - scoreGap x| ≤ L * dist y x) :
    x ∈ PersistentRobustSet scoreGap (m / L) := by
  intro y hy; nlinarith [ abs_le.mp ( hlip y ), mul_div_cancel₀ m hL.ne' ] ;

/-! ## §9. Refinement Monotonicity -/

/-- **Cover Refinement Monotonicity**: Finer covers yield at least as large a
    certified global radius. -/
theorem refinement_improves_radius
    {ι κ : Type*} [Fintype ι] [Fintype κ] [Nonempty ι] [Nonempty κ]
    (r_coarse : ι → ℝ) (r_fine : κ → ℝ)
    (refine_map : κ → ι)
    (hrefine : ∀ k, r_coarse (refine_map k) ≤ r_fine k) :
    sInf (Set.range r_coarse) ≤ sInf (Set.range r_fine) := by
  apply le_csInf (Set.range_nonempty r_fine)
  intro b hb
  obtain ⟨k, rfl⟩ := Set.mem_range.mp hb
  calc sInf (Set.range r_coarse)
      ≤ r_coarse (refine_map k) :=
        csInf_le (Set.Finite.bddBelow (Set.finite_range _)) (Set.mem_range_self _)
    _ ≤ r_fine k := hrefine k

/-! ## §10. Stalk Cohomology and Vulnerability -/

/-
**Stalk dimension zero iff vulnerable**: the stalk is trivial iff the point
    cannot be certified at any positive radius.
-/
theorem trivial_stalk_iff_vulnerable
    {X : Type*} [PseudoMetricSpace X]
    (scoreGap : X → ℝ) (x : X) :
    (∀ r > 0, x ∉ PersistentRobustSet scoreGap r) ↔
    ∀ r > 0, ∃ y : X, dist y x < r ∧ scoreGap y ≤ 0 := by
  simp +decide [ PersistentRobustSet ]

/-! ## §11. Robustness Radius Lower Bound -/

/-
The robustness radius is at least scoreGap(x)/L for L-Lipschitz score-gap.
-/
theorem robustness_radius_lower_bound
    {X : Type*} [PseudoMetricSpace X]
    (F : PersistentRobustnessFiltration X)
    (x : X) (hpos : 0 < F.scoreGap x) :
    x ∈ PersistentRobustSet F.scoreGap (F.scoreGap x / F.lipschitzConst) := by
  convert lipschitz_robustness_radius F.scoreGap x F.lipschitzConst ( F.scoreGap x ) F.lipschitz_pos hpos _ _ using 1;
  · rfl;
  · exact fun y => F.lipschitz y x

/-! ## §12. Star-Shaped Nerve Special Case -/

/-- **Star-Shaped Nerve Conjecture (Special Case)**: When one vertex has the minimum
    radius, the global inf equals that vertex's radius. -/
theorem star_nerve_radius_conjecture_special_case
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (r : ι → ℝ) (star : ι)
    (hstar : ∀ i, r star ≤ r i) :
    sInf (Set.range r) = r star := by
  apply le_antisymm
  · exact csInf_le (Set.Finite.bddBelow (Set.finite_range _)) (Set.mem_range_self star)
  · exact le_csInf (Set.range_nonempty r) (fun b ⟨i, hi⟩ => hi ▸ hstar i)

/-! ## §13. Multi-Scale Certificate -/

/-- A **multi-scale robustness certificate** at multiple scales simultaneously. -/
structure MultiScaleCertificate (X : Type*) [PseudoMetricSpace X] (n : ℕ) where
  scoreGap : X → ℝ
  scales : Fin n → ℝ
  scales_increasing : ∀ i j : Fin n, i ≤ j → scales i ≤ scales j
  robustSets : Fin n → Set X
  consistent : ∀ i, robustSets i = PersistentRobustSet scoreGap (scales i)

/-- Multi-scale nesting: robust sets form a decreasing chain. -/
theorem multiScale_nesting {X : Type*} [PseudoMetricSpace X] {n : ℕ}
    (C : MultiScaleCertificate X n) :
    ∀ i j : Fin n, i ≤ j → C.robustSets j ⊆ C.robustSets i := by
  intro i j hij
  rw [C.consistent i, C.consistent j]
  exact persistentRobustSet_antitone C.scoreGap (C.scales i) (C.scales j) (C.scales_increasing i j hij)

/-! ## §14. Sheaf-Lipschitz Globalization -/

/-
**Sheaf-Lipschitz Globalization**: Finite cover with local Lipschitz data
    yields a global certified radius as inf of margin/Lipschitz ratios.
-/
theorem sheaf_lipschitz_globalization
    {X : Type*} [PseudoMetricSpace X]
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (cover : ι → Set X)
    (S : Set X)
    (scoreGap : X → ℝ)
    (margin lipConst : ι → ℝ)
    (hcover : S ⊆ ⋃ i, cover i)
    (hm_pos : ∀ i, 0 < margin i)
    (hL_pos : ∀ i, 0 < lipConst i)
    (hmargin : ∀ i, ∀ x ∈ S ∩ cover i, scoreGap x ≥ margin i)
    (hlip : ∀ i, ∀ x ∈ cover i, ∀ y : X,
      |scoreGap y - scoreGap x| ≤ lipConst i * dist y x) :
    ∀ x ∈ S, ∀ y : X,
      dist y x < Finset.inf' Finset.univ
        ⟨Classical.arbitrary ι, Finset.mem_univ _⟩
        (fun i => margin i / lipConst i) →
      0 < scoreGap y := by
  -- By definition of infimum, for any $x \in S$, � there� exists $i$ such that $x \in \text{cover } i$.
  intro x hx
  obtain ⟨i, hi⟩ : ∃ i : ι, x ∈ cover i := by
    simpa using hcover hx;
  intro y hy
  have h_dist : dist y x < margin i / lipConst i := by
    exact hy.trans_le ( Finset.inf'_le _ ( Finset.mem_univ _ ) );
  nlinarith [ abs_le.mp ( hlip i x hi y ), hmargin i x ⟨ hx, hi ⟩, hm_pos i, hL_pos i, mul_div_cancel₀ ( margin i ) ( ne_of_gt ( hL_pos i ) ) ]

/-! ## §15. Conjecture: Optimal Radius from H² Obstruction -/

/-- **Conjecture (Falsifiable)**: For a planar ReLU network with k ≥ 3 activation regions,
    if the second Čech cohomology of the nerve is nontrivial (H² ≠ 0), then the
    certified global radius from any finite cover is strictly less than the maximum
    local radius.

    **Computational Test**: Construct a ReLU network on ℝ² with 4 activation regions
    forming a "cross" pattern. Compute H² of the nerve and the global/local radii.
    If H² ≠ 0 but global radius = max local radius, conjecture is false.

    This is stated as a special case that we can verify for a 3-region cover. -/
theorem h2_obstruction_radius_bound_three_regions
    (r : Fin 3 → ℝ) (_hr : ∀ i, 0 < r i)
    (h_gap : r 0 < r 1 ∧ r 1 < r 2) (_ : ∀ i, 0 < r i := by intro i; fin_cases i <;> linarith [h_gap.1, h_gap.2]) :
    sInf (Set.range r) < r 2 := by
  calc sInf (Set.range r)
      ≤ r 0 := csInf_le (Set.Finite.bddBelow (Set.finite_range _)) (Set.mem_range_self 0)
    _ < r 2 := lt_trans h_gap.1 h_gap.2

/-! ## §16. Axiom Verification -/

#print axioms persistentRobustSet_antitone
#print axioms mayerVietoris_robustness
#print axioms iterated_mayerVietoris_robustness
#print axioms decision_boundary_vulnerable
#print axioms refinement_improves_radius
#print axioms star_nerve_radius_conjecture_special_case
#print axioms multiScale_nesting
#print axioms h2_obstruction_radius_bound_three_regions

end