/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The unconditional open-set lower bound for idempotent large deviations

`Novelty.MaxPlusRateGeometry` proves the large-deviation *upper* bound
`limsup Wₙ(C) ≤ - inf_C rate` for arbitrary velocity sets, and
`Novelty.MaxPlusAccessibility` proves a matching *lower* bound only along the
arithmetic progression of lengths that can realize a prescribed rational mixture
exactly.  The residual open problem recorded at the end of that cycle
("Conjecture B") was to remove the accessibility hypothesis.

This file removes it, and removes even the rationality hypothesis that the original
formulation of the conjecture carried: **openness alone suffices**.  The point is
that a length-`n` two-block path realizes the velocity `⌊cn⌋/n · vᵢ + (1 - ⌊cn⌋/n) · vⱼ`,
which differs from the optimal velocity by `O(1/n)`; on an *open* set that error is
eventually invisible, and it perturbs the score by `O(1/n)` as well.

## Main results

* `MaxPlusLaw.support_tilted_eq` — complementary slackness: a supporting tilt is tight
  on the whole support of an optimal mixture.
* `MaxPlusLaw.exists_optimal_two_point` — every velocity in the hull carries an optimal
  mixture supported on (at most) **two** increments, with the exact rate as its score.
  This upgrades `exists_optimal_mixture` from an existence statement about an abstract
  mixture to an explicit chord of the upper concave envelope.
* `MaxPlusLaw.le_liminf_eventWeightE_of_isOpen` — for every open `G` and every `x ∈ G`
  in the hull, `liminf_n Wₙ(G) ≥ -rate x`.
* `maxPlus_open_liminf_lower_bound` — **Conjecture 5/B (proved, unconditionally)**:
  `liminf_n Wₙ(G) ≥ - inf { rate x : x ∈ G ∩ hull }` for every open `G` meeting the hull.
* `maxPlus_full_LDP_of_open_subset_hull` — combining with the upper bound: for an open
  `G` contained in the hull, `Wₙ(G)` actually **converges**, to `- inf_G rate`.  This is
  a complete idempotent large-deviation principle with no accessibility hypothesis.
-/

import Novelty.MaxPlusAccessibility

open scoped BigOperators
open Finset

namespace IdempotentProbability

/-! ## An `EReal` approximation helper -/

/-- If a real number is, up to an arbitrarily small positive slack, below an extended
real, then it is below it. -/
theorem ereal_coe_le_of_forall_sub_le {a : ℝ} {L : EReal}
    (h : ∀ δ : ℝ, 0 < δ → ((a - δ : ℝ) : EReal) ≤ L) : ((a : ℝ) : EReal) ≤ L := by
  rcases eq_or_ne L ⊥ with rfl | hb
  · have h1 := h 1 one_pos
    rw [le_bot_iff] at h1
    exact absurd h1 (EReal.coe_ne_bot _)
  rcases eq_or_ne L ⊤ with rfl | ht
  · exact le_top
  set b : ℝ := L.toReal with hbdef
  have hcoe : ((b : ℝ) : EReal) = L := EReal.coe_toReal ht hb
  by_contra hcon
  push_neg at hcon
  rw [← hcoe] at hcon
  have hba : b < a := EReal.coe_lt_coe_iff.mp hcon
  have hδ : (0 : ℝ) < (a - b) / 2 := by linarith
  have := h _ hδ
  rw [← hcoe] at this
  have := EReal.coe_le_coe_iff.mp this
  linarith

/-! ## Two-point optimal mixtures -/

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- **Complementary slackness.**  If `θ` is a supporting tilt for the mixture `lam` at
`x`, then the tilted score of every increment in the support of `lam` is *exactly* the
common value `M + θ * x`. -/
theorem MaxPlusLaw.support_tilted_eq (μ : MaxPlusLaw ι) {x : ℝ} {lam : ι → ℝ}
    (hmix : μ.IsMixture x lam) (θ : ℝ)
    (hsupp : ∀ k, μ.weight k + θ * μ.value k ≤ (∑ i, lam i * μ.weight i) + θ * x)
    {k : ι} (hk : 0 < lam k) :
    μ.weight k + θ * μ.value k = (∑ i, lam i * μ.weight i) + θ * x := by
  classical
  obtain ⟨hnn, hsum, hmean⟩ := hmix
  set M : ℝ := ∑ i, lam i * μ.weight i with hM
  set g : ι → ℝ := fun l => lam l * (M + θ * x - (μ.weight l + θ * μ.value l)) with hg
  have hgnn : ∀ l ∈ (Finset.univ : Finset ι), 0 ≤ g l := by
    intro l _
    exact mul_nonneg (hnn l) (by linarith [hsupp l])
  have hgsum : ∑ l, g l = 0 := by
    have : ∑ l, g l =
        (M + θ * x) * (∑ l, lam l) - (∑ l, lam l * μ.weight l)
          - θ * (∑ l, lam l * μ.value l) := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib, Finset.mul_sum, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun l _ => ?_
      simp only [hg]; ring
    rw [this, hsum, hmean, ← hM]
    ring
  have hzero := (Finset.sum_eq_zero_iff_of_nonneg hgnn).mp hgsum k (Finset.mem_univ k)
  have := mul_eq_zero.mp hzero
  rcases this with h | h
  · exact absurd h (ne_of_gt hk)
  · linarith

/-- Some increment in the support of a mixture has value at most the mean. -/
theorem MaxPlusLaw.exists_support_le (μ : MaxPlusLaw ι) {x : ℝ} {lam : ι → ℝ}
    (hmix : μ.IsMixture x lam) : ∃ i, 0 < lam i ∧ μ.value i ≤ x := by
  classical
  obtain ⟨hnn, hsum, hmean⟩ := hmix
  by_contra hcon
  push_neg at hcon
  obtain ⟨k₀, hk₀⟩ : ∃ k₀ : ι, 0 < lam k₀ := by
    by_contra hall
    push_neg at hall
    have : ∑ l, lam l = 0 :=
      Finset.sum_eq_zero fun l _ => le_antisymm (hall l) (hnn l)
    rw [hsum] at this; norm_num at this
  have hstrict : ∑ l, lam l * x < ∑ l, lam l * μ.value l := by
    refine Finset.sum_lt_sum (fun l _ => ?_) ⟨k₀, Finset.mem_univ k₀, ?_⟩
    · rcases eq_or_lt_of_le (hnn l) with h | h
      · rw [← h]; simp
      · exact le_of_lt (by nlinarith [hcon l h])
    · nlinarith [hcon k₀ hk₀]
  rw [← Finset.sum_mul, hsum, one_mul, hmean] at hstrict
  exact lt_irrefl _ hstrict

/-- Some increment in the support of a mixture has value at least the mean. -/
theorem MaxPlusLaw.exists_le_support (μ : MaxPlusLaw ι) {x : ℝ} {lam : ι → ℝ}
    (hmix : μ.IsMixture x lam) : ∃ j, 0 < lam j ∧ x ≤ μ.value j := by
  classical
  obtain ⟨hnn, hsum, hmean⟩ := hmix
  by_contra hcon
  push_neg at hcon
  obtain ⟨k₀, hk₀⟩ : ∃ k₀ : ι, 0 < lam k₀ := by
    by_contra hall
    push_neg at hall
    have : ∑ l, lam l = 0 :=
      Finset.sum_eq_zero fun l _ => le_antisymm (hall l) (hnn l)
    rw [hsum] at this; norm_num at this
  have hstrict : ∑ l, lam l * μ.value l < ∑ l, lam l * x := by
    refine Finset.sum_lt_sum (fun l _ => ?_) ⟨k₀, Finset.mem_univ k₀, ?_⟩
    · rcases eq_or_lt_of_le (hnn l) with h | h
      · rw [← h]; simp
      · exact le_of_lt (by nlinarith [hcon l h])
    · nlinarith [hcon k₀ hk₀]
  rw [← Finset.sum_mul, hsum, one_mul, hmean] at hstrict
  exact lt_irrefl _ hstrict

/-- **Two-point optimality, explicitly.**  Every velocity `x` in the convex hull of the
increment values is a convex combination `c · value i + (1-c) · value j` of *two*
increment values whose corresponding combination of weights is exactly `-rate x`.
Geometrically this is the chord of the upper concave envelope of the point cloud
`{(value i, weight i)}` lying above `x`. -/
theorem MaxPlusLaw.exists_optimal_two_point (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) :
    ∃ (i j : ι) (c : ℝ), 0 ≤ c ∧ c ≤ 1 ∧
      c * μ.value i + (1 - c) * μ.value j = x ∧
      c * μ.weight i + (1 - c) * μ.weight j = -μ.rate x := by
  classical
  obtain ⟨lam, hmix, θ, hθ⟩ := μ.exists_optimal_mixture hx
  set M : ℝ := ∑ i, lam i * μ.weight i with hM
  have hrate : μ.rate x = -M := μ.rate_eq_neg_of_supported_mixture hmix θ hθ
  obtain ⟨i, hi, hix⟩ := μ.exists_support_le hmix
  obtain ⟨j, hj, hxj⟩ := μ.exists_le_support hmix
  have hwi : μ.weight i = M + θ * (x - μ.value i) := by
    have := μ.support_tilted_eq hmix θ hθ hi
    rw [← hM] at this; linarith
  have hwj : μ.weight j = M + θ * (x - μ.value j) := by
    have := μ.support_tilted_eq hmix θ hθ hj
    rw [← hM] at this; linarith
  rcases eq_or_lt_of_le (le_trans hix hxj) with heq | hlt
  · -- degenerate chord: `value i = value j = x`
    have hxi : μ.value i = x := le_antisymm hix (by rw [heq] at hix ⊢; linarith)
    refine ⟨i, j, 1, by norm_num, le_refl 1, by simp [hxi], ?_⟩
    rw [hrate]
    simp only [sub_self, zero_mul, add_zero, one_mul]
    rw [hwi, hxi]; ring
  · -- genuine chord
    have hd : (0 : ℝ) < μ.value j - μ.value i := by linarith
    refine ⟨i, j, (μ.value j - x) / (μ.value j - μ.value i), ?_, ?_, ?_, ?_⟩
    · exact div_nonneg (by linarith) (le_of_lt hd)
    · rw [div_le_one hd]; linarith
    · field_simp; ring
    · have hc : 1 - (μ.value j - x) / (μ.value j - μ.value i)
          = (x - μ.value i) / (μ.value j - μ.value i) := by
        field_simp
        ring
      rw [hc, hwi, hwj, hrate]
      field_simp
      ring

/-! ## The open-set lower bound -/

/-- **Lower bound at an interior velocity.**  For every open set `G` of velocities and
every `x ∈ G` lying in the convex hull of the increment values,
`liminf_n Wₙ(G) ≥ -rate x`.  No accessibility, rationality, or genericity hypothesis is
needed: the two-block path of length `n` with `⌊cn⌋` copies of the first optimal
increment realizes a velocity within `O(1/n)` of `x`, hence eventually inside `G`, at a
score within `O(1/n)` of `-rate x`. -/
theorem MaxPlusLaw.le_liminf_eventWeightE_of_isOpen (μ : MaxPlusLaw ι) {G : Set ℝ}
    (hG : IsOpen G) {x : ℝ} (hxG : x ∈ G) (hxh : x ∈ Set.Icc μ.vmin μ.vmax) :
    ((-μ.rate x : ℝ) : EReal) ≤
      Filter.liminf (fun n => μ.eventWeightE n G) Filter.atTop := by
  classical
  obtain ⟨i, j, c, hc0, hc1, hvel, hwt⟩ := μ.exists_optimal_two_point hxh
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.mp hG x hxG
  set B : ℝ := |μ.value j - μ.value i| with hB
  set C : ℝ := |μ.weight j - μ.weight i| with hC
  refine ereal_coe_le_of_forall_sub_le ?_
  intro δ hδ
  refine Filter.le_liminf_of_le (Filter.isCobounded_ge_of_top) ?_
  have hBt : ∀ᶠ n : ℕ in Filter.atTop, B / n < ε :=
    Filter.Tendsto.eventually_lt_const hε (tendsto_const_div_atTop_nhds_zero_nat B)
  have hCt : ∀ᶠ n : ℕ in Filter.atTop, C / n < δ :=
    Filter.Tendsto.eventually_lt_const hδ (tendsto_const_div_atTop_nhds_zero_nat C)
  filter_upwards [Filter.eventually_gt_atTop 0, hBt, hCt] with n hn hnB hnC
  -- the approximating two-block path
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  set k : ℕ := ⌊c * n⌋₊ with hk
  have hcn : 0 ≤ c * n := mul_nonneg hc0 (le_of_lt hnR)
  have hkle : (k : ℝ) ≤ c * n := Nat.floor_le hcn
  have hklt : c * n < (k : ℝ) + 1 := Nat.lt_floor_add_one _
  have hkn : k ≤ n := by
    have : (k : ℝ) ≤ (n : ℝ) := by nlinarith
    exact_mod_cast this
  set d : ℝ := c - (k : ℝ) / n with hd
  have hd0 : 0 ≤ d := by
    rw [hd, sub_nonneg, div_le_iff₀ hnR]; linarith
  have hd1 : d ≤ 1 / n := by
    have hcancel : (k : ℝ) / n * n = k := div_mul_cancel₀ _ (ne_of_gt hnR)
    rw [hd, le_div_iff₀ hnR, sub_mul, hcancel]
    linarith
  -- statistics of the path
  have hstat : ∀ g : ι → ℝ,
      (∑ t : Fin n, g (twoBlockPath i j n k t)) / (n : ℝ)
        = (c * g i + (1 - c) * g j) + d * (g j - g i) := by
    intro g
    rw [sum_twoBlockPath g i j hkn, hd]
    field_simp
    ring
  have hvelp : μ.empiricalVelocity (twoBlockPath i j n k)
      = x + d * (μ.value j - μ.value i) := by
    rw [MaxPlusLaw.empiricalVelocity, hstat μ.value, hvel]
  have hscp : μ.pathScore (twoBlockPath i j n k)
      = -μ.rate x + d * (μ.weight j - μ.weight i) := by
    rw [MaxPlusLaw.pathScore, hstat μ.weight, hwt]
  -- the velocity lies in `G`
  have hmemG : μ.empiricalVelocity (twoBlockPath i j n k) ∈ G := by
    apply hball
    rw [Metric.mem_ball, Real.dist_eq, hvelp]
    have : |x + d * (μ.value j - μ.value i) - x| = d * B := by
      rw [show x + d * (μ.value j - μ.value i) - x = d * (μ.value j - μ.value i) by ring,
        abs_mul, abs_of_nonneg hd0, hB]
    rw [this]
    calc d * B ≤ (1 / n) * B := by
          apply mul_le_mul_of_nonneg_right hd1 (abs_nonneg _)
      _ = B / n := by ring
      _ < ε := hnB
  -- the score is within `δ` of the optimum
  have hscore : -μ.rate x - δ ≤ μ.pathScore (twoBlockPath i j n k) := by
    rw [hscp]
    have h1 : -(d * C) ≤ d * (μ.weight j - μ.weight i) := by
      rw [← mul_neg]
      apply mul_le_mul_of_nonneg_left _ hd0
      rw [hC, neg_le]
      exact neg_le_abs _
    have h2 : d * C ≤ C / n := by
      calc d * C ≤ (1 / n) * C := mul_le_mul_of_nonneg_right hd1 (abs_nonneg _)
        _ = C / n := by ring
    linarith
  calc ((-μ.rate x - δ : ℝ) : EReal)
      ≤ ((μ.pathScore (twoBlockPath i j n k) : ℝ) : EReal) := EReal.coe_le_coe_iff.mpr hscore
    _ ≤ μ.eventWeightE n G := μ.le_eventWeightE_of_velocity_mem G _ hmemG

/-- **Conjecture 5 / B (proved, unconditionally).**  For every finite max-plus law and
every *open* set `G` of velocities meeting the convex hull of the increment values,
`liminf_n Wₙ(G) ≥ - inf { rate x : x ∈ G ∩ hull }`.

The original formulation of the conjecture assumed that all increment values are
rational and asked only for a bound along accessible lengths; both hypotheses turn out
to be unnecessary.  The infimum must be restricted to the hull, since outside the hull
the real-valued Legendre supremum is unbounded and the `sSup ∅ = 0` convention of `ℝ`
assigns it the junk value `0`. -/
theorem maxPlus_open_liminf_lower_bound (μ : MaxPlusLaw ι) {G : Set ℝ} (hG : IsOpen G)
    (hne : (G ∩ Set.Icc μ.vmin μ.vmax).Nonempty) :
    ((-sInf (μ.rate '' (G ∩ Set.Icc μ.vmin μ.vmax)) : ℝ) : EReal) ≤
      Filter.liminf (fun n => μ.eventWeightE n G) Filter.atTop := by
  classical
  set S : Set ℝ := μ.rate '' (G ∩ Set.Icc μ.vmin μ.vmax) with hS
  have hSne : S.Nonempty := hne.image _
  have hSbdd : BddBelow S := ⟨0, by rintro _ ⟨y, -, rfl⟩; exact μ.rate_nonneg y⟩
  refine ereal_coe_le_of_forall_sub_le ?_
  intro δ hδ
  obtain ⟨s, hsS, hs⟩ := Real.lt_sInf_add_pos hSne hδ
  obtain ⟨y, ⟨hyG, hyh⟩, rfl⟩ := hsS
  have hmain := μ.le_liminf_eventWeightE_of_isOpen hG hyG hyh
  refine le_trans ?_ hmain
  exact EReal.coe_le_coe_iff.mpr (by linarith)

/-- **A complete idempotent large-deviation principle for open subsets of the hull.**
For an open set of velocities contained in the convex hull of the increments, the
extended-real max-plus event weights *converge*, and the limit is minus the infimum of
the rate function.  Both bounds are unconditional. -/
theorem maxPlus_full_LDP_of_open_subset_hull (μ : MaxPlusLaw ι) {G : Set ℝ} (hG : IsOpen G)
    (hsub : G ⊆ Set.Icc μ.vmin μ.vmax) (hne : G.Nonempty) :
    Filter.Tendsto (fun n => μ.eventWeightE n G) Filter.atTop
      (nhds ((-sInf (μ.rate '' G) : ℝ) : EReal)) := by
  have hGeq : G ∩ Set.Icc μ.vmin μ.vmax = G := Set.inter_eq_self_of_subset_left hsub
  have hlow : ((-sInf (μ.rate '' G) : ℝ) : EReal) ≤
      Filter.liminf (fun n => μ.eventWeightE n G) Filter.atTop := by
    have := maxPlus_open_liminf_lower_bound μ hG (by rw [hGeq]; exact hne)
    rwa [hGeq] at this
  have hup : Filter.limsup (fun n => μ.eventWeightE n G) Filter.atTop ≤
      ((-sInf (μ.rate '' G) : ℝ) : EReal) := maxPlus_limsup_le_neg_sInf_rate μ G
  have hls : Filter.limsup (fun n => μ.eventWeightE n G) Filter.atTop ≤
      Filter.liminf (fun n => μ.eventWeightE n G) Filter.atTop := le_trans hup hlow
  have hli : Filter.liminf (fun n => μ.eventWeightE n G) Filter.atTop ≤
      Filter.limsup (fun n => μ.eventWeightE n G) Filter.atTop :=
    Filter.liminf_le_limsup
  have heq₁ : Filter.limsup (fun n => μ.eventWeightE n G) Filter.atTop
      = ((-sInf (μ.rate '' G) : ℝ) : EReal) := le_antisymm hup (le_trans hlow hli)
  have heq₂ : Filter.liminf (fun n => μ.eventWeightE n G) Filter.atTop
      = ((-sInf (μ.rate '' G) : ℝ) : EReal) := le_antisymm (le_trans hli hup) hlow
  exact tendsto_of_liminf_eq_limsup heq₂ heq₁

end IdempotentProbability