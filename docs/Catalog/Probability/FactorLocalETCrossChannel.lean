import Mathlib
import Probability.FactorLocalETScaling

/-!
# FACTOR-LOCAL-ET, cycle 2: cross-channel consistency on **one** population

`Catalog.Probability.FactorLocalETScaling` treats each algorithmic channel
separately.  The distinguishing feature of the round-41 protocol, however, is
that all channels are run on *the same* draw.  That coupling is itself a
theorem-producing constraint: the trial-division cost and the Pollard-ρ cost are
two different functions of the *same* random variable `p`, so their expectations
are linked by Cauchy–Schwarz, and their measured across-`k` slopes cannot be
chosen independently.

## Main results

* `mean_sqrt_sq_le_mean` — Cauchy–Schwarz for the empirical mean:
  `(E√p)² ≤ E p`.
* `mean_le_ratio_mul_mean_sqrt_sq` — the reverse bound on a window
  `L ≤ p ≤ U`: `E p ≤ (U/L)·(E√p)²`.  On a dyadic window `U/L = 2`.
* `cross_channel_bracket` — hence, with pointwise costs `a·p` (trial) and
  `c·√p` (ρ) on one dyadic population,
  `(a/c²)·E[T_ρ]² ≤ E[T_trial] ≤ 2(a/c²)·E[T_ρ]²`.
* `cross_channel_slope_law` — **the constant-free consistency law**
  `|slope_trial - 2·slope_ρ| ≤ 1/Δk`.  Both unknown constants `a`, `c` cancel.
* `measured_pair_inconsistent` — at the experimental lever arm `Δk = 8` the
  reported pair `(slope_trial, slope_ρ) = (0.84, 0.52)` is **impossible** for
  any such population: `2·0.52 - 0.84 = 0.20 > 0.125 = 1/8`.  At least one of
  the two pointwise cost models must fail on the balanced population — which is
  precisely the "within-`k` fits confounded" caveat, here made into a theorem.
* `pointwise_power_band`, `pointwise_slope_band` — for a pointwise cost `a·p^s`
  on a dyadic window the slope is pinned to `s ± s/Δk`, with no extra
  hypothesis on the constants.
* `trial_pointwise_refuted_by_084` — the single-channel corollary: a pointwise
  linear trial-division cost forces `slope ≥ 0.875`, so `0.84` refutes it
  outright.
-/

namespace FactorLocalET

open Real Finset

/-! ## 1. Empirical means of a finite population -/

/-- The empirical mean of a size-`n` population sample. -/
noncomputable def mean {n : ℕ} (f : Fin n → ℝ) : ℝ := (∑ i, f i) / n

theorem le_mean {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} {L : ℝ} (h : ∀ i, L ≤ f i) :
    L ≤ mean f := by
  have hcard : ((Finset.univ : Finset (Fin n)).card : ℝ) = n := by simp
  have hsum : (n : ℝ) * L ≤ ∑ i, f i := by
    have := Finset.card_nsmul_le_sum (Finset.univ : Finset (Fin n)) f L (fun i _ => h i)
    simpa [hcard, nsmul_eq_mul] using this
  rw [mean, le_div_iff₀ (by exact_mod_cast hn)]
  linarith

theorem mean_le {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} {U : ℝ} (h : ∀ i, f i ≤ U) :
    mean f ≤ U := by
  have hcard : ((Finset.univ : Finset (Fin n)).card : ℝ) = n := by simp
  have hsum : ∑ i, f i ≤ (n : ℝ) * U := by
    have := Finset.sum_le_card_nsmul (Finset.univ : Finset (Fin n)) f U (fun i _ => h i)
    simpa [hcard, nsmul_eq_mul] using this
  rw [mean, div_le_iff₀ (by exact_mod_cast hn)]
  linarith

/-! ## 2. The two directions linking `E p` and `E √p` -/

/-- **Cauchy–Schwarz for the empirical mean.**  `(E √p)² ≤ E p`: the ρ channel
can never look better than the square root of the trial-division channel. -/
theorem mean_sqrt_sq_le_mean {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} (hf : ∀ i, 0 ≤ f i) :
    (mean fun i => Real.sqrt (f i)) ^ 2 ≤ mean f := by
  have hcs : (∑ i, Real.sqrt (f i)) ^ 2
      ≤ ((Finset.univ : Finset (Fin n)).card : ℝ) * ∑ i, (Real.sqrt (f i)) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hsq : ∑ i, (Real.sqrt (f i)) ^ 2 = ∑ i, f i :=
    Finset.sum_congr rfl (fun i _ => Real.sq_sqrt (hf i))
  have hcard : ((Finset.univ : Finset (Fin n)).card : ℝ) = n := by simp
  rw [hsq, hcard] at hcs
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [mean, mean, div_pow, div_le_div_iff₀ (by positivity) hnpos]
  nlinarith [hcs, hnpos]

/-- **Reverse bound on a window.**  If every sample lies in `[L, U]` with
`0 < L`, then `E p ≤ (U/L)·(E √p)²`: on a dyadic window the two channels are
tied together to within a factor `U/L = 2`. -/
theorem mean_le_ratio_mul_mean_sqrt_sq {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} {L U : ℝ}
    (hL : 0 < L) (h1 : ∀ i, L ≤ f i) (h2 : ∀ i, f i ≤ U) :
    mean f ≤ (U / L) * (mean fun i => Real.sqrt (f i)) ^ 2 := by
  have hsqrtL : Real.sqrt L ≤ mean fun i => Real.sqrt (f i) :=
    le_mean hn (fun i => Real.sqrt_le_sqrt (h1 i))
  have hLpos : (0 : ℝ) < Real.sqrt L := Real.sqrt_pos.mpr hL
  have hsq : L ≤ (mean fun i => Real.sqrt (f i)) ^ 2 := by
    have := mul_self_le_mul_self hLpos.le hsqrtL
    nlinarith [Real.sq_sqrt hL.le, this]
  have hU : mean f ≤ U := mean_le hn h2
  have hUpos : 0 < U := lt_of_lt_of_le hL (le_trans (h1 ⟨0, hn⟩) (h2 ⟨0, hn⟩))
  calc mean f ≤ U := hU
    _ = (U / L) * L := by field_simp
    _ ≤ (U / L) * (mean fun i => Real.sqrt (f i)) ^ 2 := by
        have : (0 : ℝ) ≤ U / L := by positivity
        nlinarith

/-! ## 3. The cross-channel bracket and the constant-free slope law -/

/-- **Cross-channel bracket.**  With trial-division cost `a·p` and ρ cost
`c·√p` measured on the same dyadic population, the two expectations determine
each other up to a factor `2`. -/
theorem cross_channel_bracket {n : ℕ} (hn : 0 < n) {p : Fin n → ℝ} {a c L U : ℝ}
    (ha : 0 < a) (hc : 0 < c) (hL : 0 < L) (hUL : U ≤ 2 * L)
    (h1 : ∀ i, L ≤ p i) (h2 : ∀ i, p i ≤ U) :
    (a / c ^ 2) * (c * mean fun i => Real.sqrt (p i)) ^ 2 ≤ a * mean p ∧
      a * mean p ≤ 2 * (a / c ^ 2) * (c * mean fun i => Real.sqrt (p i)) ^ 2 := by
  have hpos : ∀ i, 0 ≤ p i := fun i => le_trans hL.le (h1 i)
  have hcs := mean_sqrt_sq_le_mean hn hpos
  have hrev := mean_le_ratio_mul_mean_sqrt_sq hn hL h1 h2
  have hUdiv : U / L ≤ 2 := by rw [div_le_iff₀ hL]; linarith
  have hmsq : (0 : ℝ) ≤ (mean fun i => Real.sqrt (p i)) ^ 2 := sq_nonneg _
  have hexp : (c * mean fun i => Real.sqrt (p i)) ^ 2
      = c ^ 2 * (mean fun i => Real.sqrt (p i)) ^ 2 := by ring
  constructor
  · rw [hexp]
    have : (a / c ^ 2) * (c ^ 2 * (mean fun i => Real.sqrt (p i)) ^ 2)
        = a * (mean fun i => Real.sqrt (p i)) ^ 2 := by field_simp
    rw [this]
    nlinarith [hcs, ha]
  · rw [hexp]
    have hEq : 2 * (a / c ^ 2) * (c ^ 2 * (mean fun i => Real.sqrt (p i)) ^ 2)
        = 2 * a * (mean fun i => Real.sqrt (p i)) ^ 2 := by field_simp
    rw [hEq]
    have hstep : mean p ≤ 2 * (mean fun i => Real.sqrt (p i)) ^ 2 :=
      le_trans hrev (by nlinarith [hmsq, hUdiv])
    nlinarith [hstep, ha]

/-- **The constant-free cross-channel law.**  On one population sampled from a
dyadic window at every level, with pointwise costs `a·p` and `c·√p`, the two
measured across-`k` slopes satisfy `|slope_trial - 2·slope_ρ| ≤ 1/Δk`.  Both
unknown implementation constants `a` and `c` cancel exactly. -/
theorem cross_channel_slope_law {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c : ℝ}
    (ha : 0 < a) (hc : 0 < c)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ ((k : ℝ) - 1) * 2)
    {Etri Erho : ℕ → ℝ}
    (htri : ∀ k, Etri k = a * mean (p k))
    (hrho : ∀ k, Erho k = c * mean fun i => Real.sqrt (p k i))
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |logSlope Etri k₁ k₂ - 2 * logSlope Erho k₁ k₂| ≤ 1 / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  set K := a / c ^ 2 with hK
  have hKpos : 0 < K := by positivity
  -- the bracket at every level
  have hbr : ∀ k : ℕ, K * (Erho k) ^ 2 ≤ Etri k ∧ Etri k ≤ 2 * K * (Erho k) ^ 2 := by
    intro k
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hb := cross_channel_bracket (n := n) hn (p := p k) (a := a) (c := c)
      (L := (2 : ℝ) ^ ((k : ℝ) - 1)) (U := (2 : ℝ) ^ ((k : ℝ) - 1) * 2) ha hc hL
      (by linarith) (fun i => hlo k i) (fun i => hhi k i)
    rw [htri k, hrho k]
    exact hb
  have hrhopos : ∀ k : ℕ, 0 < Erho k := by
    intro k
    rw [hrho k]
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hmean : Real.sqrt ((2 : ℝ) ^ ((k : ℝ) - 1)) ≤ mean fun i => Real.sqrt (p k i) :=
      le_mean hn (fun i => Real.sqrt_le_sqrt (hlo k i))
    have : (0 : ℝ) < Real.sqrt ((2 : ℝ) ^ ((k : ℝ) - 1)) := Real.sqrt_pos.mpr hL
    have hpos : (0 : ℝ) < mean fun i => Real.sqrt (p k i) := lt_of_lt_of_le this hmean
    positivity
  -- pointwise bounds on the discrepancy `d k`
  have hd : ∀ k : ℕ, Real.logb 2 K ≤ Real.logb 2 (Etri k) - 2 * Real.logb 2 (Erho k) ∧
      Real.logb 2 (Etri k) - 2 * Real.logb 2 (Erho k) ≤ Real.logb 2 K + 1 := by
    intro k
    obtain ⟨hb1, hb2⟩ := hbr k
    have hE : 0 < Erho k := hrhopos k
    have hsqpos : (0 : ℝ) < (Erho k) ^ 2 := by positivity
    have htripos : 0 < Etri k := lt_of_lt_of_le (by positivity) hb1
    have hlog1 : Real.logb 2 (K * (Erho k) ^ 2) = Real.logb 2 K + 2 * Real.logb 2 (Erho k) := by
      rw [Real.logb_mul (ne_of_gt hKpos) (ne_of_gt hsqpos), Real.logb_pow]
      ring
    have hlog2 : Real.logb 2 (2 * K * (Erho k) ^ 2)
        = 1 + Real.logb 2 K + 2 * Real.logb 2 (Erho k) := by
      rw [show (2 : ℝ) * K * (Erho k) ^ 2 = 2 * (K * (Erho k) ^ 2) by ring,
        Real.logb_mul (by norm_num) (by positivity), hlog1,
        Real.logb_self_eq_one (b := 2) (by norm_num)]
      ring
    constructor
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) hb1
      rw [hlog1] at this; linarith
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) htripos hb2
      rw [hlog2] at this; linarith
  obtain ⟨hd1L, hd1U⟩ := hd k₁
  obtain ⟨hd2L, hd2U⟩ := hd k₂
  have hsplit : logSlope Etri k₁ k₂ - 2 * logSlope Erho k₁ k₂ =
      ((Real.logb 2 (Etri k₂) - 2 * Real.logb 2 (Erho k₂)) -
        (Real.logb 2 (Etri k₁) - 2 * Real.logb 2 (Erho k₁))) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
    simp only [logSlope]
    field_simp
    ring
  rw [hsplit, abs_div, abs_of_pos hΔ, div_le_div_iff₀ hΔ hΔ]
  have habs : |(Real.logb 2 (Etri k₂) - 2 * Real.logb 2 (Erho k₂)) -
      (Real.logb 2 (Etri k₁) - 2 * Real.logb 2 (Erho k₁))| ≤ 1 := by
    rw [abs_le]; constructor <;> linarith
  nlinarith [habs, hΔ]

/-- **The reported pair is impossible.**  At `Δk = 8` no single dyadic
population with pointwise costs `a·p` and `c·√p` can produce a trial-division
slope `≤ 0.84` together with a ρ slope `≥ 0.52`, because the consistency law
allows a discrepancy of only `1/8 = 0.125` while the pair demands `0.20`.
Hence the honest reading of the round-41 numbers: the ρ channel is the
birthday law, and the trial channel on balanced draws is *not* pointwise
proportional to `p`. -/
theorem measured_pair_inconsistent {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c : ℝ}
    (ha : 0 < a) (hc : 0 < c)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ ((k : ℝ) - 1) * 2)
    {Etri Erho : ℕ → ℝ}
    (htri : ∀ k, Etri k = a * mean (p k))
    (hrho : ∀ k, Erho k = c * mean fun i => Real.sqrt (p k i)) :
    ¬ (logSlope Etri 16 24 ≤ 0.84 ∧ (0.52 : ℝ) ≤ logSlope Erho 16 24) := by
  rintro ⟨h1, h2⟩
  have hlaw := cross_channel_slope_law hn ha hc hlo hhi htri hrho (k₁ := 16) (k₂ := 24)
    (by norm_num)
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hlaw
  have := (abs_le.mp hlaw).1
  linarith

/-! ## 4. Single-channel sharpening: a pointwise power law pins the slope -/

/-- A pointwise cost `a·p^s` on a dyadic window yields a power band with spread
exactly `2^s`, hence no free constants at all. -/
theorem pointwise_power_band {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a s : ℝ}
    (ha : 0 < a) (hs : 0 ≤ s)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => (p k i) ^ s) :
    PowerBand E s (a * (2 : ℝ) ^ (-s)) a := by
  refine PowerBand.of_dyadic_window (E := E) (α := s) ha ?_ ?_
  · intro k
    rw [hE k]
    have hbound : ∀ i, (2 : ℝ) ^ (s * ((k : ℝ) - 1)) ≤ (p k i) ^ s := by
      intro i
      rw [mul_comm s ((k : ℝ) - 1), Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2)]
      exact Real.rpow_le_rpow (by positivity) (hlo k i) hs
    have := le_mean hn (f := fun i => (p k i) ^ s) hbound
    nlinarith [this, ha]
  · intro k
    rw [hE k]
    have hbound : ∀ i, (p k i) ^ s ≤ (2 : ℝ) ^ (s * (k : ℝ)) := by
      intro i
      rw [mul_comm s (k : ℝ), Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2)]
      exact Real.rpow_le_rpow (le_trans (by positivity) (hlo k i)) (hhi k i) hs
    have := mean_le hn (f := fun i => (p k i) ^ s) hbound
    nlinarith [this, ha]

/-- The slope of a pointwise power-law channel is pinned to `s ± s/Δk`. -/
theorem pointwise_slope_band {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a s : ℝ}
    (ha : 0 < a) (hs : 0 ≤ s)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => (p k i) ^ s)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |logSlope E k₁ k₂ - s| ≤ s / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hband := pointwise_power_band hn ha hs hlo hhi hE
  have hb := hband.abs_logSlope_sub_le hk
  have hspread : Real.logb 2 (a / (a * (2 : ℝ) ^ (-s))) = s :=
    PowerBand.logb_spread_dyadic (α := s) (C := a) ha
  rwa [hspread] at hb

/-- **Single-channel refutation.**  A pointwise linear trial-division cost
`a·p` on a dyadic population forces an across-`k` slope of at least `0.875` at
`Δk = 8`; the measured `0.84` therefore refutes the pointwise linear model on
the balanced population without any assumption on the constant `a`. -/
theorem trial_pointwise_refuted_by_084 {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a : ℝ}
    (ha : 0 < a)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => p k i) :
    (0.84 : ℝ) < logSlope E 16 24 := by
  have hE' : ∀ k, E k = a * mean fun i => (p k i) ^ (1 : ℝ) := by
    intro k
    rw [hE k]
    congr 1
    exact congrArg mean (funext fun i => (Real.rpow_one (p k i)).symm)
  have hb := pointwise_slope_band hn ha (by norm_num) hlo hhi hE' (k₁ := 16) (k₂ := 24)
    (by norm_num)
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hb
  have := (abs_le.mp hb).1
  linarith

/-! ## 5. Non-vacuity: the hypotheses of the cross-channel law are satisfiable -/

/-- **Witness.**  The hypotheses of `cross_channel_slope_law` and
`measured_pair_inconsistent` are not vacuous: a one-instance population placed
at the bottom of every dyadic window realises them, with trial slope exactly
`1` and ρ slope exactly `1/2` — the pair `(1, 1/2)` saturating the consistency
law with zero slack.  So the law genuinely constrains, and the value it
predicts for the trial channel given `slope_ρ = 1/2` is `1`, not `0.84`. -/
theorem cross_channel_witness :
    ∃ (p : ℕ → Fin 1 → ℝ) (Etri Erho : ℕ → ℝ),
      (∀ (k : ℕ) (i : Fin 1), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i) ∧
      (∀ (k : ℕ) (i : Fin 1), p k i ≤ (2 : ℝ) ^ ((k : ℝ) - 1) * 2) ∧
      (∀ k, Etri k = 1 * mean (p k)) ∧
      (∀ k, Erho k = 1 * mean fun i => Real.sqrt (p k i)) ∧
      logSlope Etri 16 24 = 1 ∧ logSlope Erho 16 24 = 1 / 2 := by
  refine ⟨fun k _ => (2 : ℝ) ^ ((k : ℝ) - 1),
    fun k => (1 / 2 : ℝ) * (2 : ℝ) ^ ((1 : ℝ) * (k : ℝ)),
    fun k => (2 : ℝ) ^ (-(1 / 2 : ℝ)) * (2 : ℝ) ^ ((1 / 2 : ℝ) * (k : ℝ)),
    fun _ _ => le_refl _, ?_, ?_, ?_, ?_, ?_⟩
  · intro k _
    nlinarith [Real.rpow_pos_of_pos (by norm_num : (0 : ℝ) < 2) ((k : ℝ) - 1)]
  · intro k
    have h1 : (2 : ℝ) ^ ((k : ℝ) - 1) = (2 : ℝ) ^ ((k : ℝ)) * (2 : ℝ) ^ ((-1 : ℝ)) := by
      rw [← Real.rpow_add (by norm_num)]; ring_nf
    have h2 : (2 : ℝ) ^ ((-1 : ℝ)) = 1 / 2 := by
      rw [show ((-1) : ℝ) = ((-1 : ℤ) : ℝ) by norm_num, Real.rpow_intCast]; norm_num
    simp only [one_mul, h1, h2]
    simp [mean]
    ring
  · intro k
    have h3 : Real.sqrt ((2 : ℝ) ^ ((k : ℝ) - 1))
        = (2 : ℝ) ^ (-(1 / 2 : ℝ)) * (2 : ℝ) ^ ((1 / 2 : ℝ) * (k : ℝ)) := by
      rw [Real.sqrt_eq_rpow, ← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2),
        ← Real.rpow_add (by norm_num)]
      ring_nf
    simp only [one_mul, h3]
    simp [mean]
  · exact logSlope_of_pure_power (C := (1 / 2 : ℝ)) (α := 1) (by norm_num) (by norm_num)
  · exact logSlope_of_pure_power (C := (2 : ℝ) ^ (-(1 / 2 : ℝ))) (α := 1 / 2)
      (by positivity) (by norm_num)

end FactorLocalET