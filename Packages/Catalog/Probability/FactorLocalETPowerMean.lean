import Mathlib
import Probability.FactorLocalETCrossChannel

/-!
# FACTOR-LOCAL-ET, cycle 3: power-mean rigidity between arbitrary cost channels

Cycle 2 showed that the trial-division channel (`cost = a·p`) and the Pollard-ρ
channel (`cost = c·√p`), run on the *same* population, have across-`k` slopes
linked by Cauchy–Schwarz.  Cauchy–Schwarz is the exponent pair `(1, 1/2)` of a
whole hierarchy: for pointwise costs `a·p^s` and `c·p^t` the link is Jensen's
inequality for `x ↦ x^{s/t}`.  This file proves the general law and recovers the
cycle-2 statement as the special case.

## Main results

* `mean_rpow_le_mean_rpow_of_le` — power-mean monotonicity for the empirical
  mean: `(E[p^t])^{s/t} ≤ E[p^s]` for `0 < t ≤ s`.
* `power_mean_bracket` — with the dyadic window this becomes a two-sided
  bracket: `K·E_B^{s/t} ≤ E_A ≤ 2^s·K·E_B^{s/t}` where `K = a/c^{s/t}`.
* `general_cross_channel_slope_law` — the constant-free rigidity law
  `|t·slope_A - s·slope_B| ≤ s·t/Δk`.  Both implementation constants cancel.
* `cross_channel_slope_law_of_power_mean` — the `(1, 1/2)` instance, i.e. an
  independent derivation of the cycle-2 law `|slope_trial - 2·slope_ρ| ≤ 1/Δk`.
* `slope_band_attained` — sharpness: the identifiability band of cycle 1 is
  attained by an explicit endpoint-saturating curve.
* `exponents_indistinguishable` — the converse of identifiability: at lever arm
  `Δk`, two exponents differing by exactly `2σ/Δk` admit populations, both
  obeying a window of spread `2^σ`, whose measured two-point slopes coincide.
  No two-level estimator can separate them; this is the design bound behind the
  "within-`k` fits are confounded" caveat.
-/

namespace FactorLocalET

open Real

/-! ## 1. Power-mean monotonicity for empirical means -/

/-- **Power-mean monotonicity.**  For `0 < t ≤ s` and a nonnegative population,
`(E[p^t])^{s/t} ≤ E[p^s]`.  Cauchy–Schwarz is `t = 1/2`, `s = 1`. -/
theorem mean_rpow_le_mean_rpow_of_le {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} (hf : ∀ i, 0 ≤ f i)
    {s t : ℝ} (ht : 0 < t) (hts : t ≤ s) :
    (mean fun i => (f i) ^ t) ^ (s / t) ≤ mean fun i => (f i) ^ s := by
  have hr : (1 : ℝ) ≤ s / t := (one_le_div ht).mpr hts
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hnonneg : ∀ i ∈ (Finset.univ : Finset (Fin n)), 0 ≤ (f i) ^ t :=
    fun i _ => Real.rpow_nonneg (hf i) t
  have hjen := Real.rpow_sum_le_const_mul_sum_rpow_of_nonneg (Finset.univ : Finset (Fin n))
    (f := fun i => (f i) ^ t) (p := s / t) hr hnonneg
  have hcard : ((Finset.univ : Finset (Fin n)).card : ℝ) = n := by simp
  have hpow : ∀ i, ((f i) ^ t) ^ (s / t) = (f i) ^ s := by
    intro i
    rw [← Real.rpow_mul (hf i)]
    congr 1
    field_simp
  rw [hcard] at hjen
  simp only [hpow] at hjen
  have hsum_nonneg : (0 : ℝ) ≤ ∑ i, (f i) ^ t :=
    Finset.sum_nonneg (fun i _ => Real.rpow_nonneg (hf i) t)
  have hmean : (mean fun i => (f i) ^ t) ^ (s / t)
      = (∑ i, (f i) ^ t) ^ (s / t) / (n : ℝ) ^ (s / t) := by
    rw [mean, Real.div_rpow hsum_nonneg hnpos.le]
  have hkey : (n : ℝ) ^ (s / t - 1) * (n : ℝ) = (n : ℝ) ^ (s / t) := by
    rw [Real.rpow_sub hnpos, Real.rpow_one]
    field_simp
  rw [hmean, mean, div_le_div_iff₀ (by positivity) hnpos]
  calc (∑ i, (f i) ^ t) ^ (s / t) * (n : ℝ)
      ≤ ((n : ℝ) ^ (s / t - 1) * ∑ i, (f i) ^ s) * (n : ℝ) :=
        mul_le_mul_of_nonneg_right hjen hnpos.le
    _ = (∑ i, (f i) ^ s) * ((n : ℝ) ^ (s / t - 1) * (n : ℝ)) := by ring
    _ = (∑ i, (f i) ^ s) * (n : ℝ) ^ (s / t) := by rw [hkey]

/-! ## 2. The bracket on a dyadic window -/

/-- **Two-sided bracket between channels.**  On a window `[L, 2L]` with
pointwise costs `a·p^s` and `c·p^t` (`0 < t ≤ s`), the two expectations
determine each other up to the factor `2^s`. -/
theorem power_mean_bracket {n : ℕ} (hn : 0 < n) {p : Fin n → ℝ} {a c s t L : ℝ}
    (ha : 0 < a) (hc : 0 < c) (hL : 0 < L) (ht : 0 < t) (hts : t ≤ s)
    (h1 : ∀ i, L ≤ p i) (h2 : ∀ i, p i ≤ 2 * L) :
    (a / c ^ (s / t)) * (c * mean fun i => (p i) ^ t) ^ (s / t)
        ≤ a * mean (fun i => (p i) ^ s) ∧
      a * mean (fun i => (p i) ^ s)
        ≤ 2 ^ s * ((a / c ^ (s / t)) * (c * mean fun i => (p i) ^ t) ^ (s / t)) := by
  have hs : 0 < s := lt_of_lt_of_le ht hts
  have hppos : ∀ i, 0 ≤ p i := fun i => le_trans hL.le (h1 i)
  have hM : (0 : ℝ) < mean fun i => (p i) ^ t := by
    have hge : (L : ℝ) ^ t ≤ mean fun i => (p i) ^ t :=
      le_mean hn (fun i => Real.rpow_le_rpow hL.le (h1 i) ht.le)
    exact lt_of_lt_of_le (Real.rpow_pos_of_pos hL t) hge
  have hsplit : (c * mean fun i => (p i) ^ t) ^ (s / t)
      = c ^ (s / t) * (mean fun i => (p i) ^ t) ^ (s / t) :=
    Real.mul_rpow hc.le hM.le
  have hcpow : (0 : ℝ) < c ^ (s / t) := Real.rpow_pos_of_pos hc _
  have hcancel : (a / c ^ (s / t)) * (c * mean fun i => (p i) ^ t) ^ (s / t)
      = a * (mean fun i => (p i) ^ t) ^ (s / t) := by
    rw [hsplit]; field_simp
  have hjen := mean_rpow_le_mean_rpow_of_le hn hppos ht hts
  constructor
  · rw [hcancel]
    exact mul_le_mul_of_nonneg_left hjen ha.le
  · rw [hcancel]
    -- upper: `E[p^s] ≤ (2L)^s = 2^s L^s ≤ 2^s (E[p^t])^{s/t}`
    have hup : (mean fun i => (p i) ^ s) ≤ (2 * L) ^ s :=
      mean_le hn (fun i => Real.rpow_le_rpow (hppos i) (h2 i) hs.le)
    have hLs : (L : ℝ) ^ s ≤ (mean fun i => (p i) ^ t) ^ (s / t) := by
      have hge : (L : ℝ) ^ t ≤ mean fun i => (p i) ^ t :=
        le_mean hn (fun i => Real.rpow_le_rpow hL.le (h1 i) ht.le)
      have hmono := Real.rpow_le_rpow (Real.rpow_nonneg hL.le t) hge
        (le_of_lt (div_pos (lt_of_lt_of_le ht hts) ht))
      have hLt : ((L : ℝ) ^ t) ^ (s / t) = (L : ℝ) ^ s := by
        rw [← Real.rpow_mul hL.le]
        congr 1
        field_simp
      rwa [hLt] at hmono
    have h2L : (2 * L : ℝ) ^ s = 2 ^ s * L ^ s := Real.mul_rpow (by norm_num) hL.le
    have h2s : (0 : ℝ) < (2 : ℝ) ^ s := Real.rpow_pos_of_pos (by norm_num) s
    calc a * mean (fun i => (p i) ^ s) ≤ a * (2 * L) ^ s :=
          mul_le_mul_of_nonneg_left hup ha.le
      _ = 2 ^ s * (a * L ^ s) := by rw [h2L]; ring
      _ ≤ 2 ^ s * (a * (mean fun i => (p i) ^ t) ^ (s / t)) := by
          exact mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hLs ha.le) h2s.le

/-! ## 3. The general constant-free rigidity law -/

private theorem logb_rpow_eq {x y : ℝ} (hx : 0 < x) :
    Real.logb 2 (x ^ y) = y * Real.logb 2 x := by
  simp only [Real.logb, Real.log_rpow hx]
  ring

/-- **Power-mean rigidity.**  Two channels with pointwise costs `a·p^s` and
`c·p^t` (`0 < t ≤ s`) measured on *one* dyadic population satisfy
`|t·slope_A - s·slope_B| ≤ s·t/Δk`.  Both unknown constants cancel, so the law
is a pure statement about the measured exponents. -/
theorem general_cross_channel_slope_law {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c s t : ℝ}
    (ha : 0 < a) (hc : 0 < c) (ht : 0 < t) (hts : t ≤ s)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1))
    {EA EB : ℕ → ℝ}
    (hA : ∀ k, EA k = a * mean fun i => (p k i) ^ s)
    (hB : ∀ k, EB k = c * mean fun i => (p k i) ^ t)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |t * logSlope EA k₁ k₂ - s * logSlope EB k₁ k₂| ≤ s * t / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hs : 0 < s := lt_of_lt_of_le ht hts
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  set K := a / c ^ (s / t) with hK
  have hKpos : 0 < K := div_pos ha (Real.rpow_pos_of_pos hc _)
  have hBpos : ∀ k : ℕ, 0 < EB k := by
    intro k
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hge : ((2 : ℝ) ^ ((k : ℝ) - 1)) ^ t ≤ mean fun i => (p k i) ^ t :=
      le_mean hn (fun i => Real.rpow_le_rpow hL.le (hlo k i) ht.le)
    have : (0 : ℝ) < mean fun i => (p k i) ^ t :=
      lt_of_lt_of_le (Real.rpow_pos_of_pos hL t) hge
    rw [hB k]; positivity
  have hbr : ∀ k : ℕ, K * (EB k) ^ (s / t) ≤ EA k ∧ EA k ≤ 2 ^ s * (K * (EB k) ^ (s / t)) := by
    intro k
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hb := power_mean_bracket (n := n) hn (p := p k) (a := a) (c := c) (s := s) (t := t)
      (L := (2 : ℝ) ^ ((k : ℝ) - 1)) ha hc hL ht hts (fun i => hlo k i) (fun i => hhi k i)
    rw [hA k, hB k]
    exact hb
  have hApos : ∀ k : ℕ, 0 < EA k := by
    intro k
    have h1 := (hbr k).1
    have : (0 : ℝ) < K * (EB k) ^ (s / t) := by
      have := Real.rpow_pos_of_pos (hBpos k) (s / t)
      positivity
    exact lt_of_lt_of_le this h1
  -- the discrepancy `d k = log₂ E_A - (s/t) log₂ E_B` is trapped in a strip of height `s`
  have hd : ∀ k : ℕ, Real.logb 2 K ≤ Real.logb 2 (EA k) - (s / t) * Real.logb 2 (EB k) ∧
      Real.logb 2 (EA k) - (s / t) * Real.logb 2 (EB k) ≤ Real.logb 2 K + s := by
    intro k
    obtain ⟨hb1, hb2⟩ := hbr k
    have hBk : 0 < EB k := hBpos k
    have hBrp : (0 : ℝ) < (EB k) ^ (s / t) := Real.rpow_pos_of_pos hBk _
    have hlog1 : Real.logb 2 (K * (EB k) ^ (s / t))
        = Real.logb 2 K + (s / t) * Real.logb 2 (EB k) := by
      rw [Real.logb_mul (ne_of_gt hKpos) (ne_of_gt hBrp), logb_rpow_eq hBk]
    have hlog2 : Real.logb 2 (2 ^ s * (K * (EB k) ^ (s / t)))
        = s + Real.logb 2 K + (s / t) * Real.logb 2 (EB k) := by
      rw [Real.logb_mul (by positivity) (by positivity), hlog1,
        logb_rpow_eq (x := (2 : ℝ)) (y := s) (by norm_num),
        Real.logb_self_eq_one (b := 2) (by norm_num)]
      ring
    constructor
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) hb1
      rw [hlog1] at this; linarith
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (hApos k) hb2
      rw [hlog2] at this; linarith
  obtain ⟨hd1L, hd1U⟩ := hd k₁
  obtain ⟨hd2L, hd2U⟩ := hd k₂
  have hsplit : logSlope EA k₁ k₂ - (s / t) * logSlope EB k₁ k₂ =
      ((Real.logb 2 (EA k₂) - (s / t) * Real.logb 2 (EB k₂)) -
        (Real.logb 2 (EA k₁) - (s / t) * Real.logb 2 (EB k₁))) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
    simp only [logSlope]
    field_simp
    ring
  have habs : |logSlope EA k₁ k₂ - (s / t) * logSlope EB k₁ k₂| ≤ s / ((k₂ : ℝ) - (k₁ : ℝ)) := by
    rw [hsplit, abs_div, abs_of_pos hΔ, div_le_div_iff₀ hΔ hΔ]
    have hnum : |(Real.logb 2 (EA k₂) - (s / t) * Real.logb 2 (EB k₂)) -
        (Real.logb 2 (EA k₁) - (s / t) * Real.logb 2 (EB k₁))| ≤ s := by
      rw [abs_le]; constructor <;> linarith
    nlinarith [hnum, hΔ]
  have hmul : t * |logSlope EA k₁ k₂ - (s / t) * logSlope EB k₁ k₂|
      = |t * logSlope EA k₁ k₂ - s * logSlope EB k₁ k₂| := by
    have hfac : t * logSlope EA k₁ k₂ - s * logSlope EB k₁ k₂
        = t * (logSlope EA k₁ k₂ - (s / t) * logSlope EB k₁ k₂) := by
      field_simp
    rw [hfac, abs_mul, abs_of_pos ht]
  calc |t * logSlope EA k₁ k₂ - s * logSlope EB k₁ k₂|
      = t * |logSlope EA k₁ k₂ - (s / t) * logSlope EB k₁ k₂| := hmul.symm
    _ ≤ t * (s / ((k₂ : ℝ) - (k₁ : ℝ))) := mul_le_mul_of_nonneg_left habs ht.le
    _ = s * t / ((k₂ : ℝ) - (k₁ : ℝ)) := by ring

/-- The cycle-2 Cauchy–Schwarz law is the exponent pair `(s, t) = (1, 1/2)` of
the power-mean hierarchy. -/
theorem cross_channel_slope_law_of_power_mean {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c : ℝ}
    (ha : 0 < a) (hc : 0 < c)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1))
    {EA EB : ℕ → ℝ}
    (hA : ∀ k, EA k = a * mean fun i => (p k i) ^ (1 : ℝ))
    (hB : ∀ k, EB k = c * mean fun i => (p k i) ^ (1 / 2 : ℝ))
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |logSlope EA k₁ k₂ - 2 * logSlope EB k₁ k₂| ≤ 1 / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hgen := general_cross_channel_slope_law hn ha hc (s := 1) (t := 1 / 2)
    (by norm_num) (by norm_num) hlo hhi hA hB hk
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  have hrw : |(1 / 2 : ℝ) * logSlope EA k₁ k₂ - 1 * logSlope EB k₁ k₂|
      = (1 / 2) * |logSlope EA k₁ k₂ - 2 * logSlope EB k₁ k₂| := by
    rw [← abs_of_pos (show (0:ℝ) < 1/2 by norm_num), ← abs_mul]
    congr 1
    ring
  rw [hrw] at hgen
  have : (1 : ℝ) * (1 / 2 : ℝ) / ((k₂ : ℝ) - (k₁ : ℝ))
      = (1 / 2) * (1 / ((k₂ : ℝ) - (k₁ : ℝ))) := by ring
  rw [this] at hgen
  linarith [hgen]

/-! ## 4. Sharpness of identifiability, and the converse -/

/-- Shrinking by the window factor `2^{-σ}` can only decrease a positive
quantity. -/
private theorem window_le {C σ x : ℝ} (hC : 0 < C) (hσ : 0 ≤ σ) (hx : 0 < x) :
    C * (2 : ℝ) ^ (-σ) * x ≤ C * x := by
  have h2 : (2 : ℝ) ^ (-σ) ≤ 1 := by
    rw [show (1 : ℝ) = (2 : ℝ) ^ (0 : ℝ) by norm_num]
    exact Real.rpow_le_rpow_of_exponent_le (by norm_num) (by linarith)
  nlinarith [mul_pos hC hx]

/-- **The identifiability band is attained.**  An endpoint-saturating curve
inside a window of spread `2^σ` has measured slope exactly `α + σ/Δk`, so the
bound of `PowerBand.abs_logSlope_sub_le` cannot be improved. -/
theorem slope_band_attained {C α σ : ℝ} (hC : 0 < C) (hσ : 0 ≤ σ) {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    ∃ E : ℕ → ℝ, PowerBand E α (C * (2 : ℝ) ^ (-σ)) C ∧
      logSlope E k₁ k₂ = α + σ / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  have hlogb : ∀ (D : ℝ) (k : ℕ), 0 < D →
      Real.logb 2 (D * (2 : ℝ) ^ (α * k)) = Real.logb 2 D + α * k := by
    intro D k hD
    rw [Real.logb_mul (ne_of_gt hD) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
  refine ⟨fun k => if k = k₂ then C * (2 : ℝ) ^ (α * k₂)
    else C * (2 : ℝ) ^ (-σ) * (2 : ℝ) ^ (α * k), ⟨by positivity, ?_, ?_⟩, ?_⟩
  · intro k
    by_cases h : k = k₂
    · subst h
      rw [if_pos rfl]
      exact window_le hC hσ (by positivity)
    · simp [h]
  · intro k
    by_cases h : k = k₂
    · subst h; simp
    · simp only [if_neg h]
      exact window_le hC hσ (by positivity)
  · have hne : ¬ (k₁ = k₂) := Nat.ne_of_lt hk
    simp only [logSlope, if_neg hne, if_pos]
    rw [hlogb C k₂ hC, hlogb (C * (2 : ℝ) ^ (-σ)) k₁ (by positivity),
      Real.logb_mul (ne_of_gt hC) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
    field_simp
    ring

/-- **Converse of identifiability (design bound).**  If two exponents differ by
exactly `2σ/Δk`, there are two populations — one saturating its window upwards,
one downwards — whose measured two-point slopes are equal.  Hence a two-level
experiment with lever arm `Δk` cannot separate exponents closer than `2σ/Δk`,
and *within* one bit level (`Δk < 1`) the fit is confounded outright. -/
theorem exponents_indistinguishable {C α₁ α₂ σ : ℝ} (hC : 0 < C) (hσ : 0 ≤ σ) {k₁ k₂ : ℕ}
    (hk : k₁ < k₂) (hgap : α₂ - α₁ = 2 * σ / ((k₂ : ℝ) - (k₁ : ℝ))) :
    ∃ E₁ E₂ : ℕ → ℝ, PowerBand E₁ α₁ (C * (2 : ℝ) ^ (-σ)) C ∧
      PowerBand E₂ α₂ (C * (2 : ℝ) ^ (-σ)) C ∧
      logSlope E₁ k₁ k₂ = logSlope E₂ k₁ k₂ := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  obtain ⟨E₁, hb₁, hs₁⟩ := slope_band_attained (C := C) (α := α₁) (σ := σ) hC hσ hk
  -- the second curve saturates downwards: swap the roles of the two endpoints
  have hlogb : ∀ (D : ℝ) (k : ℕ), 0 < D →
      Real.logb 2 (D * (2 : ℝ) ^ (α₂ * k)) = Real.logb 2 D + α₂ * k := by
    intro D k hD
    rw [Real.logb_mul (ne_of_gt hD) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
  refine ⟨E₁, fun k => if k = k₁ then C * (2 : ℝ) ^ (α₂ * k₁)
    else C * (2 : ℝ) ^ (-σ) * (2 : ℝ) ^ (α₂ * k), hb₁, ⟨by positivity, ?_, ?_⟩, ?_⟩
  · intro k
    by_cases h : k = k₁
    · subst h
      rw [if_pos rfl]
      exact window_le hC hσ (by positivity)
    · simp [h]
  · intro k
    by_cases h : k = k₁
    · subst h; simp
    · simp only [if_neg h]
      exact window_le hC hσ (by positivity)
  · have hne : ¬ (k₂ = k₁) := (Nat.ne_of_lt hk).symm
    rw [hs₁]
    simp only [logSlope, if_neg hne, if_pos]
    rw [hlogb C k₁ hC, hlogb (C * (2 : ℝ) ^ (-σ)) k₂ (by positivity),
      Real.logb_mul (ne_of_gt hC) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
    have hg2 : (α₂ - α₁) * ((k₂ : ℝ) - (k₁ : ℝ)) = 2 * σ := by
      rw [hgap]; field_simp
    field_simp
    linear_combination -hg2

end FactorLocalET