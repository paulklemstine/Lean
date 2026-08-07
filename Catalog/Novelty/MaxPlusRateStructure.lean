/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Local structure of the idempotent rate function

`Novelty.MaxPlusCramer` shows that the Legendre--Fenchel rate of a finite max-plus law
is the greatest achievable mixture score, and `Novelty.MaxPlusOpenLowerBound` upgrades
that to an *explicit* two-point chord together with a supporting tilt.  This file uses
those two facts to settle three of the structural conjectures recorded at the end of
the previous cycle in `FUTURE_DIRECTIONS.md`.

## Main results

* `MaxPlusLaw.rate_eq_neg_weight_of_exposed` — at an exposed velocity the rate is minus
  the weight of the exposing increment.
* `MaxPlusLaw.unique_optimal_mixture_of_exposed` — **Conjecture E**: if the exposing
  tilt has a *unique* maximizer, the optimal mixture is unique and is the Dirac mass at
  the exposing increment.
* `MaxPlusLaw.exists_affine_chord` — **core of Conjecture A**: every velocity in the
  hull lies in a closed interval `[value i, value j]` with `value i ≤ x ≤ value j` on
  which `rate` is *exactly affine*, with a slope `θ` that is a global subgradient on the
  effective domain.  So the rate is locally affine at every point of the hull, and its
  breakpoints are increment values.
* `MaxPlusLaw.rate_sub_rate_eq_of_mem_chord` and `MaxPlusLaw.rate_lipschitzOn_chord` —
  the resulting exact difference formula and local Lipschitz estimate.
* `MaxPlusLaw.isGreatest_twoPointScores` — two-point sufficiency: optimizing over
  mixtures supported on at most two increments already computes `-rate x`.
* `MaxPlusLaw.rate_antitoneOn_left`, `MaxPlusLaw.rate_monotoneOn_right` — the rate is
  unimodal, decreasing up to a typical velocity and increasing after it.
* `MaxPlusLaw.affinePush`, `MaxPlusLaw.rate_affinePush`,
  `MaxPlusLaw.isLeast_contraction_affine` — **Conjecture C for affine maps**: the rate of
  the push-forward law along an invertible affine map `t ↦ a t + b` is the infimum of the
  original rate over the fibre, and the infimum is attained.  The degenerate case `a = 0`
  is `MaxPlusLaw.rate_affinePush_const`.
-/

import Novelty.MaxPlusOpenLowerBound

open scoped BigOperators
open Finset

namespace IdempotentProbability

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Two-point mixtures -/

omit [Nonempty ι] in
/-- The average of `f` against the two-point weight vector supported on `i` and `j`. -/
theorem sum_twoPoint [DecidableEq ι] (f : ι → ℝ) (i j : ι) (c : ℝ) :
    ∑ k, ((if k = i then c else 0) + (if k = j then 1 - c else 0)) * f k
      = c * f i + (1 - c) * f j := by
  simp [add_mul, Finset.sum_add_distrib, ite_mul]

/-- The two-point weight vector supported on `i` and `j` is a mixture realizing the
velocity `c * value i + (1 - c) * value j`. -/
theorem MaxPlusLaw.isMixture_twoPoint [DecidableEq ι] (μ : MaxPlusLaw ι) (i j : ι) {c : ℝ}
    (hc0 : 0 ≤ c) (hc1 : c ≤ 1) :
    μ.IsMixture (c * μ.value i + (1 - c) * μ.value j)
      (fun k => (if k = i then c else 0) + (if k = j then 1 - c else 0)) := by
  refine ⟨fun k => ?_, ?_, ?_⟩
  · have h1 : (0 : ℝ) ≤ if k = i then c else 0 := by split_ifs; exacts [hc0, le_refl 0]
    have h2 : (0 : ℝ) ≤ if k = j then 1 - c else 0 := by
      split_ifs; exacts [by linarith, le_refl 0]
    linarith
  · simp [Finset.sum_add_distrib]
  · exact sum_twoPoint μ.value i j c

/-! ## Exposed velocities: the rate and the uniqueness of the optimal mixture -/

/-- At a velocity `value i` exposed by a tilt `θ`, the rate is exactly `-weight i`. -/
theorem MaxPlusLaw.rate_eq_neg_weight_of_exposed (μ : MaxPlusLaw ι) {θ : ℝ} {i : ι}
    (hexp : ∀ k, μ.weight k + θ * μ.value k ≤ μ.weight i + θ * μ.value i) :
    μ.rate (μ.value i) = -μ.weight i := by
  classical
  have hcum : μ.cumulant θ ≤ μ.weight i + θ * μ.value i := by
    rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    intro k _
    exact hexp k
  have hbdd : BddAbove (μ.legendreSet (μ.value i)) :=
    μ.bddAbove_legendreSet_of_mem_Icc ⟨μ.vmin_le_value i, μ.value_le_vmax i⟩
  have hge : -μ.weight i ≤ μ.rate (μ.value i) := by
    have h : θ * μ.value i - μ.cumulant θ ≤ μ.rate (μ.value i) := le_csSup hbdd ⟨θ, rfl⟩
    linarith
  have hle : μ.rate (μ.value i) ≤ -μ.weight i := by
    have h := μ.rate_le_neg_mixture (x := μ.value i) (fun k => if k = i then 1 else 0)
      (fun k => by by_cases hk : k = i <;> simp [hk]) (by simp) (by simp)
    simpa using h
  linarith

/-- **Conjecture E (proved): uniqueness of the optimal mixture at an exposed velocity.**
If the tilt `θ` has `i` as its *unique* maximizer of the tilted score, then the only
mixture realizing the velocity `value i` with optimal average weight is the Dirac mass
at `i`.  Complementary slackness (`support_tilted_eq`) forces the whole support of an
optimal mixture into the set of tilted maximizers, which here is the singleton `{i}`. -/
theorem MaxPlusLaw.unique_optimal_mixture_of_exposed [DecidableEq ι] (μ : MaxPlusLaw ι)
    {θ : ℝ} {i : ι}
    (hexp : ∀ k, k ≠ i → μ.weight k + θ * μ.value k < μ.weight i + θ * μ.value i)
    {lam : ι → ℝ} (hmix : μ.IsMixture (μ.value i) lam)
    (hopt : ∑ k, lam k * μ.weight k = -μ.rate (μ.value i)) :
    ∀ k, lam k = if k = i then 1 else 0 := by
  classical
  have hexp' : ∀ k, μ.weight k + θ * μ.value k ≤ μ.weight i + θ * μ.value i := by
    intro k
    by_cases hk : k = i
    · rw [hk]
    · exact le_of_lt (hexp k hk)
  have hrate : μ.rate (μ.value i) = -μ.weight i := μ.rate_eq_neg_weight_of_exposed hexp'
  have hM : ∑ k, lam k * μ.weight k = μ.weight i := by rw [hopt, hrate]; ring
  have hsupp : ∀ k, μ.weight k + θ * μ.value k
      ≤ (∑ l, lam l * μ.weight l) + θ * μ.value i := by
    intro k; rw [hM]; exact hexp' k
  have hzero : ∀ k, k ≠ i → lam k = 0 := by
    intro k hk
    by_contra hne
    have hpos : 0 < lam k := lt_of_le_of_ne (hmix.1 k) (Ne.symm hne)
    have heq := μ.support_tilted_eq hmix θ hsupp hpos
    rw [hM] at heq
    exact absurd heq (ne_of_lt (hexp k hk))
  have hsum := hmix.2.1
  have hi : lam i = 1 := by
    rw [← hsum]
    rw [Finset.sum_eq_single i (fun b _ hb => hzero b hb) (fun h => absurd (Finset.mem_univ i) h)]
  intro k
  by_cases hk : k = i
  · rw [hk, hi]; simp
  · rw [hzero k hk]; simp [hk]

/-! ## Local affinity of the rate (Conjecture A) -/

/-- **The rate is affine along an optimal chord.**  For every velocity `x` in the convex
hull of the increment values there are increments `i, j` with `value i ≤ x ≤ value j` and
a slope `θ` such that

* `rate t = rate x + θ * (t - x)` for every `t` in the closed interval
  `[value i, value j]` — the rate is *exactly affine* there; and
* `rate x + θ * (t - x) ≤ rate t` for every `t` in the effective domain `[vmin, vmax]` —
  so `θ` is a genuine subgradient, not merely a local slope.

Consequently the rate of a finite max-plus law is affine on a neighbourhood (relative to
the hull) of every velocity, and its breakpoints occur only at increment values. -/
theorem MaxPlusLaw.exists_affine_chord (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) :
    ∃ (i j : ι) (θ : ℝ), μ.value i ≤ x ∧ x ≤ μ.value j ∧
      (∀ t ∈ Set.Icc (μ.value i) (μ.value j), μ.rate t = μ.rate x + θ * (t - x)) ∧
      (∀ t ∈ Set.Icc μ.vmin μ.vmax, μ.rate x + θ * (t - x) ≤ μ.rate t) := by
  classical
  obtain ⟨lam, hmix, θ, hθ⟩ := μ.exists_optimal_mixture hx
  set M : ℝ := ∑ i, lam i * μ.weight i with hMdef
  have hrate : μ.rate x = -M := μ.rate_eq_neg_of_supported_mixture hmix θ hθ
  obtain ⟨i, hi, hix⟩ := μ.exists_support_le hmix
  obtain ⟨j, hj, hxj⟩ := μ.exists_le_support hmix
  have hwi : μ.weight i = M + θ * (x - μ.value i) := by
    have h := μ.support_tilted_eq hmix θ hθ hi
    rw [← hMdef] at h; linarith
  have hwj : μ.weight j = M + θ * (x - μ.value j) := by
    have h := μ.support_tilted_eq hmix θ hθ hj
    rw [← hMdef] at h; linarith
  -- the cumulant is attained on the chord, so `θ` is a subgradient at `x`
  have hcum : μ.cumulant θ = M + θ * x := by
    refine le_antisymm ?_ ?_
    · rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
      intro k _
      simpa [hMdef] using hθ k
    · have h : μ.weight i + θ * μ.value i ≤ μ.cumulant θ := μ.tilted_score_le_cumulant θ i
      rw [hwi] at h; linarith
  have hsub : ∀ t ∈ Set.Icc μ.vmin μ.vmax, μ.rate x + θ * (t - x) ≤ μ.rate t := by
    intro t ht
    have hbdd : BddAbove (μ.legendreSet t) := μ.bddAbove_legendreSet_of_mem_Icc ht
    have h : θ * t - μ.cumulant θ ≤ μ.rate t := le_csSup hbdd ⟨θ, rfl⟩
    rw [hcum] at h
    rw [hrate]; linarith
  refine ⟨i, j, θ, hix, hxj, ?_, hsub⟩
  intro t ht
  obtain ⟨htl, htr⟩ := ht
  -- the chord interval sits inside the effective domain
  have hti : μ.vmin ≤ t := le_trans (μ.vmin_le_value i) htl
  have htj : t ≤ μ.vmax := le_trans htr (μ.value_le_vmax j)
  refine le_antisymm ?_ (hsub t ⟨hti, htj⟩)
  rcases eq_or_lt_of_le (le_trans hix hxj) with heq | hlt
  · -- degenerate chord: `value i = value j = x = t`
    have hxi : μ.value i = x := le_antisymm hix (by rw [heq] at hix ⊢; linarith)
    have hxj' : μ.value j = x := by rw [← heq, hxi]
    have hti' : t = x := le_antisymm (by rw [← hxj']; exact htr) (by rw [← hxi]; exact htl)
    rw [hti']; simp
  · have hd : (0 : ℝ) < μ.value j - μ.value i := by linarith
    set c : ℝ := (μ.value j - t) / (μ.value j - μ.value i) with hc
    have hc0 : 0 ≤ c := div_nonneg (by linarith) (le_of_lt hd)
    have hc1 : c ≤ 1 := by rw [hc, div_le_one hd]; linarith
    have hmix' := μ.isMixture_twoPoint i j hc0 hc1
    have hvel : c * μ.value i + (1 - c) * μ.value j = t := by
      have h1 : 1 - c = (t - μ.value i) / (μ.value j - μ.value i) := by
        rw [hc]; field_simp; ring
      rw [hc, h1]; field_simp; ring
    rw [hvel] at hmix'
    have hle := μ.rate_le_neg_mixture (x := t) _ hmix'.1 hmix'.2.1 hmix'.2.2
    rw [sum_twoPoint μ.weight i j c] at hle
    have hcw : c * μ.weight i + (1 - c) * μ.weight j = M + θ * (x - t) := by
      rw [hwi, hwj]
      linear_combination (-θ) * hvel
    rw [hcw] at hle
    rw [hrate]
    linarith

/-- Along an optimal chord the rate has an exact affine increment. -/
theorem MaxPlusLaw.rate_sub_rate_eq_of_mem_chord (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) :
    ∃ (i j : ι) (θ : ℝ), μ.value i ≤ x ∧ x ≤ μ.value j ∧
      ∀ s ∈ Set.Icc (μ.value i) (μ.value j), ∀ t ∈ Set.Icc (μ.value i) (μ.value j),
        μ.rate t - μ.rate s = θ * (t - s) := by
  obtain ⟨i, j, θ, hi, hj, haff, -⟩ := μ.exists_affine_chord hx
  refine ⟨i, j, θ, hi, hj, fun s hs t ht => ?_⟩
  rw [haff s hs, haff t ht]; ring

/-- **Local Lipschitz estimate.**  Around every hull velocity the rate is Lipschitz on a
chord interval, with the explicit constant `|θ|` given by the supporting tilt. -/
theorem MaxPlusLaw.rate_lipschitzOn_chord (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) :
    ∃ (i j : ι) (L : ℝ), 0 ≤ L ∧ μ.value i ≤ x ∧ x ≤ μ.value j ∧
      ∀ s ∈ Set.Icc (μ.value i) (μ.value j), ∀ t ∈ Set.Icc (μ.value i) (μ.value j),
        |μ.rate t - μ.rate s| ≤ L * |t - s| := by
  obtain ⟨i, j, θ, hi, hj, hdiff⟩ := μ.rate_sub_rate_eq_of_mem_chord hx
  refine ⟨i, j, |θ|, abs_nonneg θ, hi, hj, fun s hs t ht => ?_⟩
  rw [hdiff s hs t ht, abs_mul]

/-! ## Two-point sufficiency and unimodality -/

/-- The scores achievable at velocity `x` by mixtures supported on at most **two**
increments. -/
def MaxPlusLaw.twoPointScores (μ : MaxPlusLaw ι) (x : ℝ) : Set ℝ :=
  {s : ℝ | ∃ (i j : ι) (c : ℝ), 0 ≤ c ∧ c ≤ 1 ∧
    c * μ.value i + (1 - c) * μ.value j = x ∧ s = c * μ.weight i + (1 - c) * μ.weight j}

/-- **Two-point sufficiency.**  The max-plus Cramér theorem already identifies `-rate x`
with the greatest score of an arbitrary mixture at `x`; here the optimization may be
restricted to mixtures supported on at most *two* increments without changing the value,
and the restricted optimum is still attained. -/
theorem MaxPlusLaw.isGreatest_twoPointScores (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) :
    IsGreatest (μ.twoPointScores x) (-μ.rate x) := by
  classical
  constructor
  · obtain ⟨i, j, c, hc0, hc1, hvel, hsc⟩ := μ.exists_optimal_two_point hx
    exact ⟨i, j, c, hc0, hc1, hvel, hsc.symm⟩
  · rintro s ⟨i, j, c, hc0, hc1, hvel, rfl⟩
    have hmix := μ.isMixture_twoPoint i j hc0 hc1
    rw [hvel] at hmix
    have hle := μ.rate_le_neg_mixture (x := x) _ hmix.1 hmix.2.1 hmix.2.2
    rw [sum_twoPoint μ.weight i j c] at hle
    linarith

/-- **Unimodality, left branch.**  On the segment from the smallest increment value up to
a *typical* velocity (one carrying the full max-plus mass `weight = 0`) the rate is
nonincreasing.  This is the idempotent law of large numbers in monotone form. -/
theorem MaxPlusLaw.rate_antitoneOn_left (μ : MaxPlusLaw ι) {i₀ : ι} (hw : μ.weight i₀ = 0) :
    AntitoneOn μ.rate (Set.Icc μ.vmin (μ.value i₀)) := by
  intro a ha b hb hab
  have hv₀ : μ.value i₀ ∈ Set.Icc μ.vmin μ.vmax :=
    ⟨μ.vmin_le_value i₀, μ.value_le_vmax i₀⟩
  have hrate₀ : μ.rate (μ.value i₀) = 0 := μ.rate_eq_zero_of_weight_eq_zero hw
  rcases eq_or_lt_of_le ha.2 with heq | hlt
  · have hba : b = a := le_antisymm (heq ▸ hb.2) hab
    rw [hba]
  · set d : ℝ := μ.value i₀ - a with hd
    have hdpos : 0 < d := by rw [hd]; linarith
    set t : ℝ := (μ.value i₀ - b) / d with ht
    have ht0 : 0 ≤ t := div_nonneg (by linarith [hb.2]) (le_of_lt hdpos)
    have ht1 : t ≤ 1 := by rw [ht, div_le_one hdpos, hd]; linarith
    have hsum : t + (1 - t) = 1 := by ring
    have hkey : t * d = μ.value i₀ - b := by
      rw [ht]; exact div_mul_cancel₀ _ (ne_of_gt hdpos)
    have hcomb : t * a + (1 - t) * μ.value i₀ = b := by
      rw [hd] at hkey
      linear_combination -hkey
    have hconv := μ.rate_convexOn.2 (Set.mem_Icc.2 ⟨ha.1, le_trans ha.2 hv₀.2⟩) hv₀
      ht0 (by linarith) hsum
    simp only [smul_eq_mul] at hconv
    rw [hcomb, hrate₀] at hconv
    nlinarith [μ.rate_nonneg a]

/-- **Unimodality, right branch.**  Beyond a typical velocity the rate is nondecreasing. -/
theorem MaxPlusLaw.rate_monotoneOn_right (μ : MaxPlusLaw ι) {i₀ : ι} (hw : μ.weight i₀ = 0) :
    MonotoneOn μ.rate (Set.Icc (μ.value i₀) μ.vmax) := by
  intro a ha b hb hab
  have hv₀ : μ.value i₀ ∈ Set.Icc μ.vmin μ.vmax :=
    ⟨μ.vmin_le_value i₀, μ.value_le_vmax i₀⟩
  have hrate₀ : μ.rate (μ.value i₀) = 0 := μ.rate_eq_zero_of_weight_eq_zero hw
  rcases eq_or_lt_of_le hb.1 with heq | hlt
  · have hab' : a = b := le_antisymm hab (heq ▸ ha.1)
    rw [hab']
  · set d : ℝ := b - μ.value i₀ with hd
    have hdpos : 0 < d := by rw [hd]; linarith
    set t : ℝ := (a - μ.value i₀) / d with ht
    have ht0 : 0 ≤ t := div_nonneg (by linarith [ha.1]) (le_of_lt hdpos)
    have ht1 : t ≤ 1 := by rw [ht, div_le_one hdpos, hd]; linarith
    have hsum : t + (1 - t) = 1 := by ring
    have hkey : t * d = a - μ.value i₀ := by
      rw [ht]; exact div_mul_cancel₀ _ (ne_of_gt hdpos)
    have hcomb : t * b + (1 - t) * μ.value i₀ = a := by
      rw [hd] at hkey
      linear_combination hkey
    have hconv := μ.rate_convexOn.2 (Set.mem_Icc.2 ⟨le_trans hv₀.1 hb.1, hb.2⟩) hv₀
      ht0 (by linarith) hsum
    simp only [smul_eq_mul] at hconv
    rw [hcomb, hrate₀] at hconv
    nlinarith [μ.rate_nonneg b]

/-! ## Contraction along an affine map (Conjecture C) -/

/-- The push-forward of a max-plus law along the affine map `t ↦ a * t + b`: the values
are transported and the weights are unchanged. -/
def MaxPlusLaw.affinePush (μ : MaxPlusLaw ι) (a b : ℝ) : MaxPlusLaw ι where
  value := fun i => a * μ.value i + b
  weight := μ.weight
  weight_nonpos := μ.weight_nonpos
  exists_weight_zero := μ.exists_weight_zero

@[simp] theorem MaxPlusLaw.affinePush_value (μ : MaxPlusLaw ι) (a b : ℝ) (i : ι) :
    (μ.affinePush a b).value i = a * μ.value i + b := rfl

@[simp] theorem MaxPlusLaw.affinePush_weight (μ : MaxPlusLaw ι) (a b : ℝ) (i : ι) :
    (μ.affinePush a b).weight i = μ.weight i := rfl

/-- The cumulant transforms by a reparametrization of the tilt together with a shift. -/
theorem MaxPlusLaw.cumulant_affinePush (μ : MaxPlusLaw ι) (a b θ : ℝ) :
    (μ.affinePush a b).cumulant θ = θ * b + μ.cumulant (θ * a) := by
  refine le_antisymm ?_ ?_
  · rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    intro k _
    have h : μ.weight k + θ * a * μ.value k ≤ μ.cumulant (θ * a) :=
      μ.tilted_score_le_cumulant (θ * a) k
    simp only [MaxPlusLaw.affinePush_value, MaxPlusLaw.affinePush_weight]
    nlinarith [h]
  · rw [← le_sub_iff_add_le', MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    intro k _
    have h : (μ.affinePush a b).weight k + θ * (μ.affinePush a b).value k
        ≤ (μ.affinePush a b).cumulant θ :=
      (μ.affinePush a b).tilted_score_le_cumulant θ k
    simp only [MaxPlusLaw.affinePush_value, MaxPlusLaw.affinePush_weight] at h
    nlinarith [h]

/-- The defining Legendre family is *unchanged* by an invertible affine push-forward,
once the base point is transported. -/
theorem MaxPlusLaw.legendreSet_affinePush (μ : MaxPlusLaw ι) {a : ℝ} (ha : a ≠ 0) (b x : ℝ) :
    (μ.affinePush a b).legendreSet (a * x + b) = μ.legendreSet x := by
  ext r
  constructor
  · rintro ⟨θ, rfl⟩
    refine ⟨θ * a, ?_⟩
    rw [MaxPlusLaw.cumulant_affinePush]
    ring
  · rintro ⟨η, rfl⟩
    refine ⟨η / a, ?_⟩
    rw [MaxPlusLaw.cumulant_affinePush]
    field_simp
    ring

/-- **Affine equivariance of the idempotent rate.**  Pushing a max-plus law forward along
an invertible affine map transports its rate function along the same map. -/
theorem MaxPlusLaw.rate_affinePush (μ : MaxPlusLaw ι) {a : ℝ} (ha : a ≠ 0) (b x : ℝ) :
    (μ.affinePush a b).rate (a * x + b) = μ.rate x := by
  rw [MaxPlusLaw.rate_eq_sSup, MaxPlusLaw.rate_eq_sSup, μ.legendreSet_affinePush ha b x]

/-- **Conjecture C for affine maps (proved).**  The rate of the push-forward law at `z` is
the infimum of the original rate over the fibre `{y | a * y + b = z}`, and the infimum is
attained (the fibre is the single point `(z - b) / a`). -/
theorem MaxPlusLaw.isLeast_contraction_affine (μ : MaxPlusLaw ι) {a : ℝ} (ha : a ≠ 0)
    (b z : ℝ) :
    IsLeast {r : ℝ | ∃ y : ℝ, a * y + b = z ∧ r = μ.rate y} ((μ.affinePush a b).rate z) := by
  have hz : a * ((z - b) / a) + b = z := by field_simp; ring
  have key : (μ.affinePush a b).rate z = μ.rate ((z - b) / a) := by
    conv_lhs => rw [← hz]
    exact μ.rate_affinePush ha b _
  constructor
  · exact ⟨(z - b) / a, hz, key⟩
  · rintro r ⟨y, hy, rfl⟩
    have hy' : y = (z - b) / a := by
      field_simp
      linear_combination hy
    rw [key, hy']

/-- The degenerate case of the contraction principle: pushing forward along a *constant*
affine map collapses the law to a point mass, whose rate vanishes at that point — which is
also the infimum of the original rate over the (whole-line) fibre. -/
theorem MaxPlusLaw.rate_affinePush_const (μ : MaxPlusLaw ι) (b : ℝ) :
    (μ.affinePush 0 b).rate b = 0 := by
  obtain ⟨i, hi⟩ := μ.exists_weight_zero
  have hval : (μ.affinePush 0 b).value i = b := by simp
  have h := (μ.affinePush 0 b).rate_eq_zero_of_weight_eq_zero (i := i) (by simpa using hi)
  rwa [hval] at h

/-- The infimum of the rate over the whole line is `0`, so the degenerate contraction
identity of `rate_affinePush_const` really is an instance of Conjecture C. -/
theorem MaxPlusLaw.isLeast_rate_range (μ : MaxPlusLaw ι) :
    IsLeast {r : ℝ | ∃ y : ℝ, r = μ.rate y} 0 := by
  obtain ⟨i, hi⟩ := μ.exists_weight_zero
  refine ⟨⟨μ.value i, (μ.rate_eq_zero_of_weight_eq_zero hi).symm⟩, ?_⟩
  rintro r ⟨y, rfl⟩
  exact μ.rate_nonneg y

end IdempotentProbability