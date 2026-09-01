/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spike amplitude of the coincidence (MA-1) scan under rate constraints

Companion to `Catalog.Bridges.MovingAverageScan` (paper 249, hit-position
thread).  That file proves that the coincidence scan `Y i = X i · X (i+1)` of a
latent product-Bernoulli scan with an *arbitrary* rate curve `p` has
autocovariance

  `Cov(Y i, Y (i+1)) = p i · p (i+1) · p (i+2) · (1 - p (i+1))`,   `Cov(Y i, Y (i+k)) = 0` for `k ≥ 2`,

so its lag profile is a single spike, and that at a *constant* latent rate `q`
the spike height is `q / (1 + q) < 1/2`.  The amplitude question for a
heterogeneous curve was left open: how high can the spike go when the rates are
confined to a window `[l, u] ⊆ (0,1)`?

This file settles it.  Writing `a = p i`, `b = p (i+1)`, `c = p (i+2)`, the
lag-1 autocorrelation collapses to the rational function

  `ρ = c (1 - b) / (1 - a b)`                              (`maCorrProfile_lag_one_eq`)

— the two occurrences of `a b` in numerator and denominator cancel, so the spike
height does *not* depend on the marginal rate of the scan at all, only on the
three latent rates.  From that closed form:

* `maCorrProfile_lag_one_lt_one` — the spike is always strictly below `1`;
* `maCorrProfile_lag_one_le_spikeBound` — for rates in `[l, u]` it is at most
  `u (1 - l) / (1 - u l)`, the function being increasing in `a` and `c` and
  decreasing in `b`;
* `spikeBound_attained` — the bound is *sharp*: the alternating curve
  `u, l, u, l, …` attains it exactly;
* `heterogeneity_beats_homogeneous_cap` — with rates in `[1/10, 9/10]` the spike
  reaches `81/91 > 1/2`, so the homogeneous cap `q/(1+q) < 1/2` is genuinely a
  homogeneity artefact;
* `spike_amplitude_sup_one` — the supremum over all curves with values in
  `(0,1)` is exactly `1`: for every `ε > 0` there is a curve whose spike exceeds
  `1 - ε`.

Consequence for the experimental thread: a one-spike lag profile of *any*
height in `(0,1)` is compatible with a coincidence mechanism, so spike height
alone never bounds the mechanism — only the *shape* (exact zeros from lag 2 on)
does.  A measured profile that is flat and slightly negative therefore rules the
coincidence mechanism out at every amplitude, not merely at small ones.
-/

import Bridges.MovingAverageScan

open Finset ConsecutiveVDependency MovingAverageScan

namespace CoincidenceSpikeAmplitude

/-! ## 1. Closed form of the spike height -/

/-- **The lag-1 autocorrelation of the coincidence scan in closed form.**  With
`a = p i`, `b = p (i+1)`, `c = p (i+2)` it equals `c (1 - b) / (1 - a b)`; the
factor `a b` cancels between the autocovariance and the variance, so the spike
height is independent of the coincidence rate itself. -/
theorem maCorrProfile_lag_one_eq (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi2 : i + 2 < n)
    (ha0 : 0 < p i) (ha1 : p i < 1) (hb0 : 0 < p (i + 1)) (hb1 : p (i + 1) < 1) :
    maCorrProfile n p i 1 = p (i + 2) * (1 - p (i + 1)) / (1 - p i * p (i + 1)) := by
  have hab : p i * p (i + 1) < 1 := by nlinarith
  have habpos : 0 < p i * p (i + 1) := mul_pos ha0 hb0
  have hden : (0 : ℝ) < p i * p (i + 1) - (p i * p (i + 1)) ^ 2 := by nlinarith
  unfold maCorrProfile
  rw [maCov_lag_one n p hi2, maVar n p (by omega) (by omega)]
  unfold maRate
  rw [div_eq_div_iff (by nlinarith : p i * p (i + 1) - (p i * p (i + 1)) ^ 2 ≠ 0)
    (by nlinarith : (1 : ℝ) - p i * p (i + 1) ≠ 0)]
  ring

/-- The spike height is strictly below `1` for every rate curve with values in
`(0, 1]` at the anchor and `(0,1)` at the two following positions. -/
theorem maCorrProfile_lag_one_lt_one (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi2 : i + 2 < n)
    (ha0 : 0 < p i) (ha1 : p i < 1) (hb0 : 0 < p (i + 1)) (hb1 : p (i + 1) < 1)
    (hc1 : p (i + 2) ≤ 1) :
    maCorrProfile n p i 1 < 1 := by
  rw [maCorrProfile_lag_one_eq n p hi2 ha0 ha1 hb0 hb1]
  have hden : (0 : ℝ) < 1 - p i * p (i + 1) := by nlinarith
  rw [div_lt_one hden]
  nlinarith [mul_nonneg (le_of_lt hb0) (sub_nonneg.mpr (le_of_lt ha1))]

/-- The spike height is nonnegative when all three rates are. -/
theorem maCorrProfile_lag_one_nonneg (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi2 : i + 2 < n)
    (ha0 : 0 < p i) (ha1 : p i < 1) (hb0 : 0 < p (i + 1)) (hb1 : p (i + 1) < 1)
    (hc0 : 0 ≤ p (i + 2)) :
    0 ≤ maCorrProfile n p i 1 := by
  rw [maCorrProfile_lag_one_eq n p hi2 ha0 ha1 hb0 hb1]
  have hden : (0 : ℝ) < 1 - p i * p (i + 1) := by nlinarith
  apply div_nonneg _ (le_of_lt hden)
  nlinarith

/-! ## 2. The sharp bound over a rate window `[l, u]` -/

/-- The extremal spike height for latent rates confined to `[l, u]`. -/
noncomputable def spikeBound (l u : ℝ) : ℝ := u * (1 - l) / (1 - u * l)

/-- **The spike bound is sharp from above**: over the window `[l, u] ⊆ (0,1)`
the lag-1 correlation never exceeds `u (1 - l) / (1 - u l)`.  The proof is the
exact monotonicity decomposition
`u(1-l)(1-ab) - c(1-b)(1-ul) ≥ u[(b-l)(1-u) + (u-a)(1-l)(l+b-l)]`. -/
theorem maCorrProfile_lag_one_le_spikeBound (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi2 : i + 2 < n)
    (l u : ℝ) (hl0 : 0 < l) (hu1 : u < 1)
    (ha : l ≤ p i) (ha' : p i ≤ u) (hb : l ≤ p (i + 1)) (hb' : p (i + 1) ≤ u)
    (hc' : p (i + 2) ≤ u) :
    maCorrProfile n p i 1 ≤ spikeBound l u := by
  have hlu : l ≤ u := le_trans ha ha'
  have ha0 : 0 < p i := lt_of_lt_of_le hl0 ha
  have hb0 : 0 < p (i + 1) := lt_of_lt_of_le hl0 hb
  have ha1 : p i < 1 := lt_of_le_of_lt ha' hu1
  have hb1 : p (i + 1) < 1 := lt_of_le_of_lt hb' hu1
  have hl1 : l < 1 := lt_of_le_of_lt hlu hu1
  have hu0 : 0 < u := lt_of_lt_of_le hl0 hlu
  rw [maCorrProfile_lag_one_eq n p hi2 ha0 ha1 hb0 hb1]
  have hden : (0 : ℝ) < 1 - p i * p (i + 1) := by nlinarith
  have hden' : (0 : ℝ) < 1 - u * l := by nlinarith
  unfold spikeBound
  rw [div_le_div_iff₀ hden hden']
  -- key algebraic identity, with `s = u - a ≥ 0`, `r = b - l ≥ 0`:
  --   u(1-l)(1-ab) - u(1-b)(1-ul) = u·[ r(1-u) + s(1-l)(l+r) ]
  have key : u * (1 - l) * (1 - p i * p (i + 1)) - u * (1 - p (i + 1)) * (1 - u * l)
      = u * ((p (i + 1) - l) * (1 - u) + (u - p i) * (1 - l) * p (i + 1)) := by ring
  nlinarith [mul_nonneg (mul_nonneg (sub_nonneg.mpr hb) (sub_nonneg.mpr (le_of_lt hu1)))
      (le_of_lt hu0),
    mul_nonneg (mul_nonneg (mul_nonneg (sub_nonneg.mpr ha') (sub_nonneg.mpr (le_of_lt hl1)))
      (le_of_lt hb0)) (le_of_lt hu0),
    mul_nonneg (sub_nonneg.mpr hc') (mul_nonneg (sub_nonneg.mpr (le_of_lt hb1))
      (le_of_lt hden'))]

/-- The alternating rate curve `u, l, u, l, …`. -/
noncomputable def altRate (l u : ℝ) : ℕ → ℝ := fun j => if j % 2 = 1 then l else u

@[simp] theorem altRate_zero (l u : ℝ) : altRate l u 0 = u := by
  unfold altRate; norm_num

@[simp] theorem altRate_one (l u : ℝ) : altRate l u 1 = l := by
  unfold altRate; norm_num

@[simp] theorem altRate_two (l u : ℝ) : altRate l u 2 = u := by
  unfold altRate; norm_num

/-- **The bound is attained**: the alternating curve realises the extremal spike
height exactly, so `spikeBound l u` is the maximum, not merely an upper bound. -/
theorem spikeBound_attained (n : ℕ) (hn : 2 < n) (l u : ℝ) (hl0 : 0 < l) (hlu : l ≤ u)
    (hu1 : u < 1) :
    maCorrProfile n (altRate l u) 0 1 = spikeBound l u := by
  have h0 : altRate l u 0 = u := altRate_zero l u
  have h1 : altRate l u (0 + 1) = l := by simp
  have h2 : altRate l u (0 + 2) = u := by simp
  have hu0 : 0 < u := lt_of_lt_of_le hl0 hlu
  rw [maCorrProfile_lag_one_eq n (altRate l u) (by omega)
      (by rw [h0]; exact hu0) (by rw [h0]; exact hu1)
      (by rw [h1]; exact hl0) (by rw [h1]; exact lt_of_le_of_lt hlu hu1)]
  rw [h1, h2, h0]
  unfold spikeBound
  ring_nf

/-! ## 3. Consequences: heterogeneity breaks the homogeneous cap, and the
supremum is `1` -/

/-- **Heterogeneity genuinely raises the spike above the homogeneous cap.**  At a
constant rate the spike is `q/(1+q) < 1/2` (`MovingAverageScan.maCorr_lag_one_pos`);
with rates alternating between `1/10` and `9/10` it equals `81/91 > 1/2`. -/
theorem heterogeneity_beats_homogeneous_cap (n : ℕ) (hn : 2 < n) :
    maCorrProfile n (altRate (1/10) (9/10)) 0 1 = 81 / 91 ∧
      (1 : ℝ) / 2 < 81 / 91 ∧
      ∀ q : ℝ, 0 < q → q < 1 → q / (1 + q) < 1 / 2 := by
  refine ⟨?_, by norm_num, fun q hq0 hq1 => (maCorr_lag_one_pos q hq0 hq1).2⟩
  rw [spikeBound_attained n hn (1/10) (9/10) (by norm_num) (by norm_num) (by norm_num)]
  unfold spikeBound
  norm_num

/-- **The supremum of the spike height over all latent rate curves with values in
`(0,1)` is exactly `1`.**  For every `ε > 0` the alternating curve with
`l = t`, `u = 1 - t` and `t` small enough has spike height `> 1 - ε`, while by
`maCorrProfile_lag_one_lt_one` no curve reaches `1`. -/
theorem spike_amplitude_sup_one (n : ℕ) (hn : 2 < n) (eps : ℝ) (heps : 0 < eps) :
    ∃ p : ℕ → ℝ, (∀ j, 0 < p j ∧ p j < 1) ∧
      1 - eps < maCorrProfile n p 0 1 ∧ maCorrProfile n p 0 1 < 1 := by
  set t : ℝ := min eps (1 / 2) / 2 with ht
  have ht0 : 0 < t := by
    have : 0 < min eps (1 / 2) := lt_min heps (by norm_num)
    simpa [ht] using half_pos this
  have ht4 : t ≤ 1 / 4 := by
    have : min eps (1 / 2) ≤ 1 / 2 := min_le_right _ _
    simp only [ht]
    linarith
  have hte : t ≤ eps / 2 := by
    have : min eps (1 / 2) ≤ eps := min_le_left _ _
    simp only [ht]
    linarith
  have htlt : t < 1 - t := by linarith
  refine ⟨altRate t (1 - t), ?_, ?_, ?_⟩
  · intro j
    unfold altRate
    by_cases h : j % 2 = 1 <;> simp [h] <;> constructor <;> linarith
  · rw [spikeBound_attained n hn t (1 - t) ht0 (le_of_lt htlt) (by linarith)]
    unfold spikeBound
    rw [lt_div_iff₀ (by nlinarith : (0 : ℝ) < 1 - (1 - t) * t)]
    nlinarith [sq_nonneg t, sq_nonneg (1 - t)]
  · have h0 : altRate t (1 - t) 0 = 1 - t := altRate_zero _ _
    have h1 : altRate t (1 - t) (0 + 1) = t := by simp
    have h2 : altRate t (1 - t) (0 + 2) = 1 - t := by simp
    exact maCorrProfile_lag_one_lt_one n (altRate t (1 - t)) (by omega)
      (by rw [h0]; linarith) (by rw [h0]; linarith)
      (by rw [h1]; linarith) (by rw [h1]; linarith)
      (by rw [h2]; linarith)

/-- **Amplitude does not identify the mechanism, shape does.**  Every value in
`(0,1)` is attainable as a coincidence-scan spike, but the profile is exactly
zero at every lag `≥ 2` for *every* rate curve, so the flat, slightly negative
profile recorded in the experiment excludes the coincidence mechanism at all
amplitudes simultaneously. -/
theorem shape_not_amplitude_identifies (n : ℕ) (hn : 3 < n) (eps : ℝ) (heps : 0 < eps) :
    ∃ p : ℕ → ℝ, (∀ j, 0 < p j ∧ p j < 1) ∧
      1 - eps < maCorrProfile n p 0 1 ∧
      ∀ k : ℕ, 2 ≤ k → k + 1 < n → maCorrProfile n p 0 k = 0 := by
  obtain ⟨p, hp, hlow, -⟩ := spike_amplitude_sup_one n (by omega) eps heps
  refine ⟨p, hp, hlow, fun k hk hkn => ?_⟩
  exact maCorrProfile_ge_two n p hk (by omega)

end CoincidenceSpikeAmplitude