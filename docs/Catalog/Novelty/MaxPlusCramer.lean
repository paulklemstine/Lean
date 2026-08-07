/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A max-plus (idempotent) Cramér theorem

`Probability.IdempotentLargeDeviations` proves the *upper* half of an idempotent
large-deviation principle: the normalized max-plus score of a path never exceeds
minus the Legendre--Fenchel rate at its empirical velocity.  `Novelty.MaxPlusRateGeometry`
identifies the effective domain of that rate with the convex hull of the increment
values and proves the "easy" mixture bound `rate x ≤ - ∑ λ i * weight i`.

This file closes the loop: for every velocity `x` in the hull, the mixture bound is
**attained**, and it is attained by a mixture supported on at most two increments.

## Main results

* `IdempotentProbability.exists_supporting_tilt` — a purely finite, order-theoretic
  separation lemma: if no chord over `x` beats the level `m`, a supporting tilt exists.
* `MaxPlusLaw.exists_optimal_mixture` — an explicit two-point optimal mixture together
  with a supporting tilt.
* `MaxPlusLaw.isGreatest_mixtureScores` — **max-plus Cramér theorem**:
  `-rate x` is the *greatest* achievable mixture score at velocity `x`.
* `MaxPlusLaw.rate_eq_neg_sSup_mixtureScores` — the rate as an explicit finite
  optimization problem.
* `MaxPlusLaw.rate_prod_eq_infConv` — **Conjecture 2 (tensorization)**: the rate of a
  product law is the infimal convolution of the factor rates.
* `MaxPlusLaw.exposed_event_max_eq_neg_rate` — **Conjecture 1 (exposed velocities)**:
  at a velocity exposed by a tilt, the maximal normalized score among length-`n` paths
  of that velocity is exactly `-rate x`, for every `n ≥ 1`.
-/

import Novelty.MaxPlusRateGeometry

open scoped BigOperators
open Finset

namespace IdempotentProbability

/-! ## A finite separation lemma -/

/-- **Supporting-tilt lemma.**  Let `v, w : ι → ℝ` be finite data and let `m` be a level
such that (i) every increment sitting exactly at `x` has weight at most `m`, and (ii)
every chord joining an increment strictly left of `x` to one strictly right of `x` passes
below `m` at `x`.  Then there is a tilt `θ` for which the affine function
`t ↦ m + θ * (t - x)` dominates all the data points.

This is the finite, division-free heart of the max-plus Cramér theorem: it replaces the
usual Hahn--Banach separation by an explicit computation with slopes. -/
theorem exists_supporting_tilt {ι : Type*} [Fintype ι] (v w : ι → ℝ) (x m : ℝ)
    (H1 : ∀ k, v k = x → w k ≤ m)
    (H2 : ∀ k l, v k < x → x < v l → (v l - x) * w k + (x - v k) * w l ≤ m * (v l - v k)) :
    ∃ θ : ℝ, ∀ k, w k + θ * v k ≤ m + θ * x := by
  classical
  set a : ι → ℝ := fun k => (w k - m) / (x - v k) with ha
  have hval : ∀ k, a k = (w k - m) / (x - v k) := fun k => rfl
  set Km : Finset ι := Finset.univ.filter (fun k => v k < x) with hKm
  set Kp : Finset ι := Finset.univ.filter (fun k => x < v k) with hKp
  have hmemKm : ∀ k, k ∈ Km ↔ v k < x := by intro k; simp [hKm]
  have hmemKp : ∀ k, k ∈ Kp ↔ x < v k := by intro k; simp [hKp]
  have key : ∀ k, v k < x → ∀ l, x < v l → a k ≤ a l := by
    intro k hk l hl
    have h := H2 k l hk hl
    have d1 : (0:ℝ) < x - v k := by linarith
    have d2 : (0:ℝ) < v l - x := by linarith
    have hal : a l = (m - w l) / (v l - x) := by
      rw [hval l, show x - v l = -(v l - x) by ring, show w l - m = -(m - w l) by ring,
        neg_div_neg_eq]
    rw [hval k, hal, div_le_div_iff₀ d1 d2]
    nlinarith
  have main : ∀ θ : ℝ, (∀ k, v k < x → a k ≤ θ) → (∀ l, x < v l → θ ≤ a l) →
      ∀ k, w k + θ * v k ≤ m + θ * x := by
    intro θ hlow hhigh k
    rcases lt_trichotomy (v k) x with h | h | h
    · have h2 := hlow k h
      rw [hval k] at h2
      have d1 : (0:ℝ) < x - v k := by linarith
      rw [div_le_iff₀ d1] at h2
      nlinarith
    · have := H1 k h; rw [h]; linarith
    · have h2 := hhigh k h
      rw [hval k] at h2
      have d2 : x - v k < 0 := by linarith
      rw [le_div_iff_of_neg d2] at h2
      nlinarith
  by_cases hKmne : Km.Nonempty
  · refine ⟨Km.sup' hKmne a, main _ ?_ ?_⟩
    · intro k hk; exact Finset.le_sup' a ((hmemKm k).2 hk)
    · intro l hl
      refine Finset.sup'_le _ _ fun k hk => key k ((hmemKm k).1 hk) l hl
  · by_cases hKpne : Kp.Nonempty
    · refine ⟨Kp.inf' hKpne a, main _ ?_ ?_⟩
      · intro k hk; exact absurd ((hmemKm k).2 hk) (fun hm => hKmne ⟨k, hm⟩)
      · intro l hl; exact Finset.inf'_le a ((hmemKp l).2 hl)
    · refine ⟨0, main _ ?_ ?_⟩
      · intro k hk; exact absurd ((hmemKm k).2 hk) (fun hm => hKmne ⟨k, hm⟩)
      · intro l hl; exact absurd ((hmemKp l).2 hl) (fun hm => hKpne ⟨l, hm⟩)

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Mixtures -/

/-- A *mixture* realizing the velocity `x`: an idempotent-probability analogue of an
empirical distribution with prescribed mean. -/
def MaxPlusLaw.IsMixture (μ : MaxPlusLaw ι) (x : ℝ) (lam : ι → ℝ) : Prop :=
  (∀ i, 0 ≤ lam i) ∧ (∑ i, lam i = 1) ∧ (∑ i, lam i * μ.value i = x)

/-- The set of average weights of mixtures realizing the velocity `x`. -/
def MaxPlusLaw.mixtureScores (μ : MaxPlusLaw ι) (x : ℝ) : Set ℝ :=
  {s : ℝ | ∃ lam : ι → ℝ, μ.IsMixture x lam ∧ s = ∑ i, lam i * μ.weight i}

theorem MaxPlusLaw.mixtureScores_le (μ : MaxPlusLaw ι) {x s : ℝ}
    (hs : s ∈ μ.mixtureScores x) : s ≤ -μ.rate x := by
  obtain ⟨lam, ⟨hnn, hsum, hmean⟩, rfl⟩ := hs
  have := μ.rate_le_neg_mixture lam hnn hsum hmean
  linarith

/-- The mean of a mixture lies between the extreme increment values. -/
theorem MaxPlusLaw.mixture_mem_Icc (μ : MaxPlusLaw ι) {x : ℝ} {lam : ι → ℝ}
    (h : μ.IsMixture x lam) : x ∈ Set.Icc μ.vmin μ.vmax := by
  obtain ⟨hnn, hsum, hmean⟩ := h
  constructor
  · have : ∑ i, lam i * μ.vmin ≤ ∑ i, lam i * μ.value i :=
      Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (μ.vmin_le_value i) (hnn i)
    rw [← Finset.sum_mul, hsum, one_mul, hmean] at this
    exact this
  · have : ∑ i, lam i * μ.value i ≤ ∑ i, lam i * μ.vmax :=
      Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (μ.value_le_vmax i) (hnn i)
    rw [← Finset.sum_mul, hsum, one_mul, hmean] at this
    exact this

/-- **Optimality certificate.**  A mixture whose average weight admits a *supporting
tilt* computes the rate exactly.  This is the duality gap being zero, and it is the only
place where the two directions of the Legendre transform meet. -/
theorem MaxPlusLaw.rate_eq_neg_of_supported_mixture (μ : MaxPlusLaw ι) {x : ℝ}
    {lam : ι → ℝ} (hmix : μ.IsMixture x lam) (θ : ℝ)
    (hsupp : ∀ k, μ.weight k + θ * μ.value k ≤ (∑ i, lam i * μ.weight i) + θ * x) :
    μ.rate x = -∑ i, lam i * μ.weight i := by
  have hle : μ.rate x ≤ -∑ i, lam i * μ.weight i :=
    μ.rate_le_neg_mixture lam hmix.1 hmix.2.1 hmix.2.2
  have hcum : μ.cumulant θ ≤ (∑ i, lam i * μ.weight i) + θ * x := by
    rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    intro k _
    exact hsupp k
  have hbdd : BddAbove (μ.legendreSet x) :=
    μ.bddAbove_legendreSet_of_mem_Icc (μ.mixture_mem_Icc hmix)
  have hge : θ * x - μ.cumulant θ ≤ μ.rate x := le_csSup hbdd ⟨θ, rfl⟩
  linarith

/-! ## Existence of an optimal two-point mixture -/

/-- **Existence of an optimal mixture with a supporting tilt.**  For every velocity in
the convex hull of the increment values there is a mixture, supported on at most two
increments, whose average weight `m` admits a supporting tilt `θ`: every increment
satisfies `weight k + θ * value k ≤ m + θ * x`.  Geometrically, the chord of the upper
concave envelope of the point cloud `{(value i, weight i)}` above `x`. -/
theorem MaxPlusLaw.exists_optimal_mixture (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) :
    ∃ lam : ι → ℝ, μ.IsMixture x lam ∧
      ∃ θ : ℝ, ∀ k, μ.weight k + θ * μ.value k ≤ (∑ i, lam i * μ.weight i) + θ * x := by
  classical
  obtain ⟨hxmin, hxmax⟩ := hx
  -- the finite set of admissible chords
  set P : Finset (ι × ι) :=
    Finset.univ.filter (fun p : ι × ι => μ.value p.1 ≤ x ∧ x ≤ μ.value p.2) with hPdef
  have hmemP : ∀ p : ι × ι, p ∈ P ↔ (μ.value p.1 ≤ x ∧ x ≤ μ.value p.2) := by
    intro p; simp [hPdef]
  obtain ⟨i₀, hi₀⟩ := μ.exists_value_eq_vmin
  obtain ⟨j₀, hj₀⟩ := μ.exists_value_eq_vmax
  have hP : P.Nonempty := ⟨(i₀, j₀), (hmemP _).2 ⟨by rw [hi₀]; exact hxmin, by
    rw [hj₀]; exact hxmax⟩⟩
  set F : ι × ι → ℝ := fun p =>
    if μ.value p.1 < μ.value p.2 then
      ((μ.value p.2 - x) * μ.weight p.1 + (x - μ.value p.1) * μ.weight p.2) /
        (μ.value p.2 - μ.value p.1)
    else μ.weight p.1 with hFdef
  set m : ℝ := P.sup' hP F with hm
  obtain ⟨⟨i, j⟩, hijP, hij⟩ := Finset.exists_mem_eq_sup' hP F
  obtain ⟨hi, hj⟩ := (hmemP (i, j)).1 hijP
  -- the two-point mixture
  set c : ℝ := if μ.value i < μ.value j then
      (μ.value j - x) / (μ.value j - μ.value i) else 1 with hc
  set lam : ι → ℝ := fun k => (if k = i then c else 0) + (if k = j then 1 - c else 0) with hlam
  have hc01 : 0 ≤ c ∧ c ≤ 1 := by
    by_cases h : μ.value i < μ.value j
    · have hd : 0 < μ.value j - μ.value i := by linarith
      rw [hc, if_pos h]
      constructor
      · apply div_nonneg (by linarith) (le_of_lt hd)
      · rw [div_le_one hd]; linarith
    · rw [hc, if_neg h]; norm_num
  have hsum : ∑ k, lam k = 1 := by rw [hlam]; simp [Finset.sum_add_distrib]
  have hmeanF : ∀ f : ι → ℝ, ∑ k, lam k * f k = c * f i + (1 - c) * f j := by
    intro f; rw [hlam]; simp [add_mul, Finset.sum_add_distrib, ite_mul]
  have hmean : ∑ k, lam k * μ.value k = x := by
    rw [hmeanF]
    by_cases h : μ.value i < μ.value j
    · have hd : 0 < μ.value j - μ.value i := by linarith
      rw [hc, if_pos h]
      field_simp
      ring
    · have hij' : μ.value i = μ.value j := le_antisymm (by push_neg at h; linarith)
        (by push_neg at h; exact h)
      have hxi : μ.value i = x := le_antisymm hi (by rw [hij']; exact hj)
      rw [hc, if_neg h]; simp [hxi]
  have hmixture : μ.IsMixture x lam := by
    refine ⟨?_, hsum, hmean⟩
    intro k
    rw [hlam]
    have h1 : (0:ℝ) ≤ if k = i then c else 0 := by
      split_ifs; exacts [hc01.1, le_refl 0]
    have h2 : (0:ℝ) ≤ if k = j then 1 - c else 0 := by
      split_ifs; exacts [by linarith [hc01.2], le_refl 0]
    linarith
  -- the optimal score is exactly the chord value `m`
  have hscore : ∑ k, lam k * μ.weight k = m := by
    rw [hmeanF, hm, hij]
    simp only [hFdef]
    by_cases h : μ.value i < μ.value j
    · have hd : 0 < μ.value j - μ.value i := by linarith
      simp only [if_pos h]
      rw [hc, if_pos h]
      field_simp
      ring
    · simp only [if_neg h]
      rw [hc, if_neg h]; ring
  refine ⟨lam, hmixture, ?_⟩
  rw [hscore]
  -- verify the hypotheses of the separation lemma
  apply exists_supporting_tilt μ.value μ.weight x m
  · intro k hk
    have hkP : (k, k) ∈ P := (hmemP _).2 ⟨le_of_eq hk, ge_of_eq hk⟩
    have h0 : F (k, k) ≤ m := Finset.le_sup' F hkP
    have h1 : F (k, k) = μ.weight k := by
      simp only [hFdef]; rw [if_neg (lt_irrefl _)]
    linarith [h1 ▸ h0]
  · intro k l hk hl
    have hklP : (k, l) ∈ P := (hmemP _).2 ⟨le_of_lt hk, le_of_lt hl⟩
    have hlt : μ.value k < μ.value l := lt_trans hk hl
    have hd : 0 < μ.value l - μ.value k := by linarith
    have h0 : F (k, l) ≤ m := Finset.le_sup' F hklP
    have h1 : F (k, l) =
        ((μ.value l - x) * μ.weight k + (x - μ.value k) * μ.weight l) /
          (μ.value l - μ.value k) := by
      simp only [hFdef]; rw [if_pos hlt]
    rw [h1, div_le_iff₀ hd] at h0
    linarith

/-! ## The max-plus Cramér theorem -/

/-- **Max-plus Cramér theorem.**  For every velocity `x` in the convex hull of the
increment values, `-rate x` is the *greatest* average weight of a mixture of increments
with mean `x`.  In particular the Legendre--Fenchel rate of a finite max-plus law solves
an explicit finite-dimensional optimization problem, and the optimum is attained. -/
theorem MaxPlusLaw.isGreatest_mixtureScores (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ convexHull ℝ (Set.range μ.value)) :
    IsGreatest (μ.mixtureScores x) (-μ.rate x) := by
  rw [μ.convexHull_range_value] at hx
  obtain ⟨lam, hmix, θ, hθ⟩ := μ.exists_optimal_mixture hx
  have heq : μ.rate x = -∑ i, lam i * μ.weight i :=
    μ.rate_eq_neg_of_supported_mixture hmix θ hθ
  refine ⟨⟨lam, hmix, ?_⟩, fun s hs => μ.mixtureScores_le hs⟩
  rw [heq]; ring

/-- The rate function of a finite max-plus law is minus the supremum of the achievable
mixture scores. -/
theorem MaxPlusLaw.rate_eq_neg_sSup_mixtureScores (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ convexHull ℝ (Set.range μ.value)) :
    μ.rate x = -sSup (μ.mixtureScores x) := by
  have h := μ.isGreatest_mixtureScores hx
  rw [h.csSup_eq]
  ring

/-- Every velocity in the hull is realized by a mixture supported on at most two
increments; combined with `isGreatest_mixtureScores` this is the "two-point optimality"
principle for idempotent large deviations. -/
theorem MaxPlusLaw.exists_mixture_attaining_rate (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ convexHull ℝ (Set.range μ.value)) :
    ∃ lam : ι → ℝ, μ.IsMixture x lam ∧ μ.rate x = -∑ i, lam i * μ.weight i := by
  obtain ⟨⟨lam, hmix, hs⟩, -⟩ := μ.isGreatest_mixtureScores hx
  exact ⟨lam, hmix, by linarith⟩

/-! ## Conjecture 1: exactness at exposed velocities -/

/-- **Conjecture 1 (proved).**  Suppose the velocity `x = value i` is *exposed* by the
tilt `θ`, i.e. the increment `i` uniquely maximizes the tilted score.  Then for **every**
`n ≥ 1` the set of normalized scores of length-`n` paths with empirical velocity `x` has
a greatest element, and that element is exactly `-rate x`.  So the threshold `N` of the
conjecture can be taken to be `1`. -/
theorem MaxPlusLaw.exposed_event_max_eq_neg_rate (μ : MaxPlusLaw ι) {x θ : ℝ} {i : ι}
    (hxi : μ.value i = x)
    (hexp : ∀ k, μ.weight k + θ * μ.value k ≤ μ.weight i + θ * μ.value i)
    {n : ℕ} (hn : 0 < n) :
    IsGreatest {s : ℝ | ∃ p : Fin n → ι, μ.empiricalVelocity p = x ∧ s = μ.pathScore p}
      (-μ.rate x) := by
  classical
  have hnreal : (0:ℝ) < n := by exact_mod_cast hn
  have hnne : (n:ℝ) ≠ 0 := ne_of_gt hnreal
  -- the rate at an exposed velocity is minus the weight of the exposing increment
  have hcum : μ.cumulant θ ≤ μ.weight i + θ * x := by
    rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    intro k _
    rw [← hxi]
    exact hexp k
  have hbdd : BddAbove (μ.legendreSet x) := by
    refine μ.bddAbove_legendreSet_of_mem_Icc ?_
    rw [← hxi]
    exact ⟨μ.vmin_le_value i, μ.value_le_vmax i⟩
  have hge : -μ.weight i ≤ μ.rate x := by
    have : θ * x - μ.cumulant θ ≤ μ.rate x := le_csSup hbdd ⟨θ, rfl⟩
    linarith
  have hle : μ.rate x ≤ -μ.weight i := by
    refine μ.rate_le_neg_mixture (fun k => if k = i then 1 else 0) ?_ ?_ ?_ |>.trans ?_
    · intro k; by_cases h : k = i <;> simp [h]
    · simp
    · simp [hxi]
    · simp
  have hrate : μ.rate x = -μ.weight i := le_antisymm hle hge
  constructor
  · -- the constant path realizes the maximum
    refine ⟨fun _ => i, ?_, ?_⟩
    · rw [MaxPlusLaw.empiricalVelocity]
      field_simp [hxi]
      simp [Finset.sum_const, hxi, mul_comm]
    · rw [MaxPlusLaw.pathScore, hrate]
      field_simp
      simp [Finset.sum_const, mul_comm]
  · rintro s ⟨p, hp, rfl⟩
    have hpath := maxPlus_randomWalk_LDP μ hn p
    rw [show (∑ k, μ.value (p k)) / (n : ℝ) = μ.empiricalVelocity p from rfl,
      show (∑ k, μ.weight (p k)) / (n : ℝ) = μ.pathScore p from rfl, hp] at hpath
    exact hpath

/-! ## Conjecture 2: tensorization of the rate as an infimal convolution -/

variable {κ : Type*} [Fintype κ] [Nonempty κ]

/-- **Conjecture 2 (proved).**  The rate function of a product max-plus law is the
infimal convolution of the two factor rates, and the infimum is *attained*: the set of
split values `rate₁ y + rate₂ (x - y)` (over admissible splittings) has a least element,
namely `rateProd x`. -/
theorem MaxPlusLaw.rate_prod_eq_infConv (μ₁ : MaxPlusLaw ι) (μ₂ : MaxPlusLaw κ) {x : ℝ}
    (hx : x ∈ Set.Icc (μ₁.prod μ₂).vmin (μ₁.prod μ₂).vmax) :
    IsLeast {r : ℝ | ∃ y : ℝ, y ∈ Set.Icc μ₁.vmin μ₁.vmax ∧
        (x - y) ∈ Set.Icc μ₂.vmin μ₂.vmax ∧ r = μ₁.rate y + μ₂.rate (x - y)}
      ((μ₁.prod μ₂).rate x) := by
  classical
  constructor
  · -- attainment, via the optimal product mixture and its marginals
    obtain ⟨lam, hmix, hrate⟩ := (μ₁.prod μ₂).exists_mixture_attaining_rate
      (by rw [(μ₁.prod μ₂).convexHull_range_value]; exact hx)
    obtain ⟨hnn, hsum, hmean⟩ := hmix
    set lam₁ : ι → ℝ := fun i => ∑ j, lam (i, j) with hlam₁
    set lam₂ : κ → ℝ := fun j => ∑ i, lam (i, j) with hlam₂
    have hsum₁ : ∑ i, lam₁ i = 1 := by
      rw [hlam₁]; rw [← Fintype.sum_prod_type]; exact hsum
    have hsum₂ : ∑ j, lam₂ j = 1 := by
      rw [hlam₂]; rw [← Fintype.sum_prod_type_right]; exact hsum
    have hnn₁ : ∀ i, 0 ≤ lam₁ i := fun i =>
      Finset.sum_nonneg fun j _ => hnn (i, j)
    have hnn₂ : ∀ j, 0 ≤ lam₂ j := fun j =>
      Finset.sum_nonneg fun i _ => hnn (i, j)
    set y : ℝ := ∑ i, lam₁ i * μ₁.value i with hy
    have hsplit : ∑ j, lam₂ j * μ₂.value j = x - y := by
      have hexp : ∑ p : ι × κ, lam p * (μ₁.prod μ₂).value p
          = (∑ i, lam₁ i * μ₁.value i) + ∑ j, lam₂ j * μ₂.value j := by
        rw [Fintype.sum_prod_type]
        have h1 : ∀ i, ∑ j, lam (i, j) * (μ₁.value i + μ₂.value j)
            = lam₁ i * μ₁.value i + ∑ j, lam (i, j) * μ₂.value j := by
          intro i
          rw [hlam₁, Finset.sum_mul, ← Finset.sum_add_distrib]
          exact Finset.sum_congr rfl fun j _ => by ring
        calc ∑ i, ∑ j, lam (i, j) * (μ₁.value i + μ₂.value j)
            = ∑ i, (lam₁ i * μ₁.value i + ∑ j, lam (i, j) * μ₂.value j) :=
              Finset.sum_congr rfl fun i _ => h1 i
          _ = (∑ i, lam₁ i * μ₁.value i) + ∑ i, ∑ j, lam (i, j) * μ₂.value j := by
              rw [Finset.sum_add_distrib]
          _ = (∑ i, lam₁ i * μ₁.value i) + ∑ j, lam₂ j * μ₂.value j := by
              rw [Finset.sum_comm]
              congr 1
              refine Finset.sum_congr rfl fun j _ => ?_
              rw [hlam₂, Finset.sum_mul]
      rw [hmean] at hexp
      rw [← hy] at hexp
      linarith
    have hweights : (∑ i, lam₁ i * μ₁.weight i) + ∑ j, lam₂ j * μ₂.weight j
        = ∑ p : ι × κ, lam p * (μ₁.prod μ₂).weight p := by
      rw [Fintype.sum_prod_type]
      have h1 : ∀ i, ∑ j, lam (i, j) * (μ₁.weight i + μ₂.weight j)
          = lam₁ i * μ₁.weight i + ∑ j, lam (i, j) * μ₂.weight j := by
        intro i
        rw [hlam₁, Finset.sum_mul, ← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun j _ => by ring
      calc (∑ i, lam₁ i * μ₁.weight i) + ∑ j, lam₂ j * μ₂.weight j
          = (∑ i, lam₁ i * μ₁.weight i) + ∑ i, ∑ j, lam (i, j) * μ₂.weight j := by
            congr 1
            rw [Finset.sum_comm]
            refine Finset.sum_congr rfl fun j _ => ?_
            rw [hlam₂, Finset.sum_mul]
        _ = ∑ i, (lam₁ i * μ₁.weight i + ∑ j, lam (i, j) * μ₂.weight j) := by
            rw [Finset.sum_add_distrib]
        _ = ∑ i, ∑ j, lam (i, j) * (μ₁.weight i + μ₂.weight j) :=
            Finset.sum_congr rfl fun i _ => (h1 i).symm
    have hmix₁ : μ₁.IsMixture y lam₁ := ⟨hnn₁, hsum₁, hy.symm⟩
    have hmix₂ : μ₂.IsMixture (x - y) lam₂ := ⟨hnn₂, hsum₂, hsplit⟩
    have hy₁ : y ∈ Set.Icc μ₁.vmin μ₁.vmax := μ₁.mixture_mem_Icc hmix₁
    have hy₂ : (x - y) ∈ Set.Icc μ₂.vmin μ₂.vmax := μ₂.mixture_mem_Icc hmix₂
    have hb₁ : BddAbove (μ₁.legendreSet y) := μ₁.bddAbove_legendreSet_of_mem_Icc hy₁
    have hb₂ : BddAbove (μ₂.legendreSet (x - y)) := μ₂.bddAbove_legendreSet_of_mem_Icc hy₂
    refine ⟨y, hy₁, hy₂, le_antisymm ?_ ?_⟩
    · exact μ₁.rate_prod_le_add μ₂ x y hb₁ hb₂
    · have e1 := μ₁.rate_le_neg_mixture lam₁ hnn₁ hsum₁ hy.symm
      have e2 := μ₂.rate_le_neg_mixture lam₂ hnn₂ hsum₂ hsplit
      rw [hrate]
      linarith
  · rintro r ⟨y, hy₁, hy₂, rfl⟩
    exact μ₁.rate_prod_le_add μ₂ x y (μ₁.bddAbove_legendreSet_of_mem_Icc hy₁)
      (μ₂.bddAbove_legendreSet_of_mem_Icc hy₂)

end IdempotentProbability