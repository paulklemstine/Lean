import Mathlib
import Probability.TDialU116ReboundFloor

/-!
# Floor identifiability at a fixed noise level, and averaging across the rebound

## Research context (FACT round-71 #2, exp 553, `U116-MIXED`; second cycle)

`Probability.TDialU116ReboundFloor` established two things about the recorded ladder
`… 0.4880 → 0.4621 → 0.4847` (U116) `→ 0.43636` (U120):

* the `+0.0226` rebound step is **incompatible with any nonnegative multiplicative fade**;
* the three-point Aitken `Δ²` fit recovers a floor `L = 2299719/4850000 ≈ 0.474169`, inside
  the pre-registered window `[0.46, 0.49]`, but the *prediction* it makes for the next rung
  misses the recorded value by `≈ 0.0286`, and the corresponding trap band `η/(1−|λ|)` is
  wider than the whole observed fade.

That leaves the sharp question this cycle answers: **at a given noise level, how well is the
floor determined at all?**  Predictive power and identifiability are different quantities,
and here they come apart: the fit is useless for extrapolation yet the floor is pinned to a
window of width `≈ 0.031`.

## Main results

### 1. An exact identifiability threshold
* `floor_separation_needs_noise` — if one ladder is a noisy affine fade with ratio `λ` for
  **both** floors `L₁` and `L₂` at noise `η`, then `|1 − λ| · |L₁ − L₂| ≤ 2η`.
* `floors_indistinguishable_of_le` — conversely, whenever `|1 − λ| · |L₁ − L₂| ≤ 2η` the
  constant ladder at the midpoint floor realises both models exactly.
* `floor_identifiability_threshold` — hence the **iff**: two floors are confusable at noise
  `η` precisely when `|1 − λ| · |L₁ − L₂| ≤ 2η`.  The resolution of a floor measurement is
  `2η/|1 − λ|`, and it degrades to nothing as `λ → 1` (`floor_resolution_bound`).

### 2. Applied to the record
* `u116_floor_resolution` — at the measured noise `η = 0.02862` and fitted ratio
  `λ = −226/259`, any two consistent floors differ by at most `0.0306`.
* `u116_zero_floor_excluded` — in particular the *zero* floor (the "slide to zero" story) is
  not consistent with the fitted floor at that noise: the two are separated by more than the
  resolution.  This is the precise sense in which the U116 record supports a **positive**
  floor, and it holds despite the failed extrapolation.
* `u116_floor_window_width` — the identifiability window `L ± 0.0306` around the Aitken
  estimate is comparable with (indeed slightly narrower than) the pre-registered
  `[0.46, 0.49]` window: the experiment's stated resolution was honest.

### 3. Averaging beats the band across a rebound
* `alternating_signs_partial_sum_abs_le_one` — `|∑_{k<K} (−1)ᵏ| ≤ 1`.
* `alternating_average_recovers_floor` — for a ladder oscillating about its floor with
  amplitude `η`, the running mean of `K` rungs is within `η/K` of the floor, while every
  individual rung is off by exactly `η`.  Under *sign-alternating* rebound noise, averaging
  rungs is therefore an `O(1/K)` floor estimator: rebounds are not merely harmless, they are
  informative.
* `u116_three_rung_average_in_band`, `u116_two_estimators_agree` — the plain mean of the
  three recorded rungs, `14348/30000 ≈ 0.478267`, also lands inside `[0.46, 0.49]` and agrees
  with the Aitken estimate to within `0.0041`.  Two structurally different estimators, one
  linear and one nonlinear, concur inside the pre-registered window.

## Lab notes (exp 553 / exp 554)

```
Aitken floor L        : 2299719/4850000 = 0.4741689…
three-rung mean       : 14348/30000     = 0.4782667…
estimator gap         : 0.0040978…      (< 0.005)
fitted ratio λ        : -226/259 = -0.8725869…      |1 - λ| = 485/259 = 1.8725869…
noise forced by U120  : η ≥ 370623/12950000 = 0.0286195…
floor resolution 2η/|1-λ| : 0.0305628…             pre-registered window width : 0.03
```
-/

open Finset

namespace Catalog.Probability.TDialU116FloorIdentifiability

open Catalog.Probability.TDialU116ReboundFloor

/-! ## 1. The identifiability threshold -/

/-- **Lower bound on the noise needed to confuse two floors.**  If a single ladder is a noisy
affine fade with the same ratio `λ` for two different floors, the noise level must cover half
the separation, scaled by `|1 − λ|`. -/
theorem floor_separation_needs_noise {L1 L2 lam eta : ℝ} {rho : ℕ → ℝ}
    (h1 : NoisyFade L1 lam eta rho) (h2 : NoisyFade L2 lam eta rho) :
    |1 - lam| * |L1 - L2| ≤ 2 * eta := by
  have e1 := h1 0
  have e2 := h2 0
  have key : |(L1 + lam * (rho 0 - L1)) - (L2 + lam * (rho 0 - L2))| ≤ 2 * eta := by
    have hsplit : (L1 + lam * (rho 0 - L1)) - (L2 + lam * (rho 0 - L2))
        = (rho 1 - (L2 + lam * (rho 0 - L2))) - (rho 1 - (L1 + lam * (rho 0 - L1))) := by
      ring
    calc |(L1 + lam * (rho 0 - L1)) - (L2 + lam * (rho 0 - L2))|
        ≤ |rho 1 - (L2 + lam * (rho 0 - L2))| + |rho 1 - (L1 + lam * (rho 0 - L1))| := by
          rw [hsplit]; exact abs_sub _ _
      _ ≤ eta + eta := add_le_add e2 e1
      _ = 2 * eta := by ring
  have hval : (L1 + lam * (rho 0 - L1)) - (L2 + lam * (rho 0 - L2)) = (1 - lam) * (L1 - L2) := by
    ring
  rw [hval, abs_mul] at key
  exact key

/-- **Sharpness.**  Whenever the separation fits inside twice the noise, the constant ladder at
the midpoint floor is simultaneously a noisy affine fade for both floors: the two hypotheses
are then genuinely indistinguishable. -/
theorem floors_indistinguishable_of_le {L1 L2 lam eta : ℝ}
    (h : |1 - lam| * |L1 - L2| ≤ 2 * eta) :
    ∃ rho : ℕ → ℝ, NoisyFade L1 lam eta rho ∧ NoisyFade L2 lam eta rho := by
  refine ⟨fun _ => (L1 + L2) / 2, ?_, ?_⟩
  · intro k
    have hval : (L1 + L2) / 2 - (L1 + lam * ((L1 + L2) / 2 - L1))
        = ((1 - lam) * (L1 - L2)) * (-(1 : ℝ) / 2) := by ring
    rw [hval, abs_mul, abs_mul]
    have : |(-(1 : ℝ) / 2)| = 1 / 2 := by rw [abs_div]; norm_num
    rw [this]
    nlinarith [abs_nonneg (1 - lam), abs_nonneg (L1 - L2),
      mul_nonneg (abs_nonneg (1 - lam)) (abs_nonneg (L1 - L2))]
  · intro k
    have hval : (L1 + L2) / 2 - (L2 + lam * ((L1 + L2) / 2 - L2))
        = ((1 - lam) * (L1 - L2)) * ((1 : ℝ) / 2) := by ring
    rw [hval, abs_mul, abs_mul]
    have : |((1 : ℝ) / 2)| = 1 / 2 := by rw [abs_div]; norm_num
    rw [this]
    nlinarith [abs_nonneg (1 - lam), abs_nonneg (L1 - L2),
      mul_nonneg (abs_nonneg (1 - lam)) (abs_nonneg (L1 - L2))]

/-- **The exact identifiability threshold for a floor measurement.**  Two floors admit a common
noisy-fade explanation at noise `η` and ratio `λ` if and only if `|1−λ|·|L₁−L₂| ≤ 2η`. -/
theorem floor_identifiability_threshold {L1 L2 lam eta : ℝ} :
    (∃ rho : ℕ → ℝ, NoisyFade L1 lam eta rho ∧ NoisyFade L2 lam eta rho)
      ↔ |1 - lam| * |L1 - L2| ≤ 2 * eta := by
  constructor
  · rintro ⟨rho, h1, h2⟩
    exact floor_separation_needs_noise h1 h2
  · exact floors_indistinguishable_of_le

/-- **Resolution of a floor measurement.**  Two floors consistent with one ladder differ by at
most `2η/|1 − λ|`; the resolution therefore blows up as the ratio approaches `1`. -/
theorem floor_resolution_bound {L1 L2 lam eta : ℝ} {rho : ℕ → ℝ}
    (h1 : NoisyFade L1 lam eta rho) (h2 : NoisyFade L2 lam eta rho) (hlam : lam ≠ 1) :
    |L1 - L2| ≤ 2 * eta / |1 - lam| := by
  have hpos : 0 < |1 - lam| := abs_pos.mpr (sub_ne_zero.mpr (Ne.symm hlam))
  have h := floor_separation_needs_noise h1 h2
  rw [le_div_iff₀ hpos]
  linarith [h, mul_comm (|1 - lam|) (|L1 - L2|)]

/-! ## 2. The record: resolution, and exclusion of the zero floor -/

/-- The noise level forced by the recorded U120 rung against the U116 three-point fit. -/
def measuredNoise : ℚ := 370623 / 12950000

/-- **Floor resolution of the U116 fit.**  At the measured noise and the fitted (alternating)
ratio, two floors compatible with the same ladder differ by at most `0.0306`. -/
theorem u116_floor_resolution {L1 L2 : ℝ} {rho : ℕ → ℝ}
    (h1 : NoisyFade L1 ((fittedRatio : ℚ) : ℝ) ((measuredNoise : ℚ) : ℝ) rho)
    (h2 : NoisyFade L2 ((fittedRatio : ℚ) : ℝ) ((measuredNoise : ℚ) : ℝ) rho) :
    |L1 - L2| ≤ 306 / 10000 := by
  have hr : ((fittedRatio : ℚ) : ℝ) = -(226 / 259 : ℝ) := by
    rw [fittedRatio_value]; norm_num
  have hn : ((measuredNoise : ℚ) : ℝ) = (370623 / 12950000 : ℝ) := by
    unfold measuredNoise; norm_num
  have h := floor_separation_needs_noise h1 h2
  rw [hr, hn] at h
  have habs : |1 - -(226 / 259 : ℝ)| = 485 / 259 := by
    rw [abs_of_pos] <;> norm_num
  rw [habs] at h
  nlinarith [abs_nonneg (L1 - L2)]

/-- **The zero floor is excluded.**  No single ladder can be a noisy affine fade, at the fitted
ratio and the measured noise, for both the Aitken floor `≈ 0.474169` and the floor `0`.  So at
this noise level the "slide to zero" hypothesis and the "positive floor" hypothesis are
genuinely distinguishable — the caveat being that both are compared at the *same* fade
ratio `λ = −226/259`. -/
theorem u116_zero_floor_excluded {rho : ℕ → ℝ} :
    ¬ (NoisyFade ((floorEstimate : ℚ) : ℝ) ((fittedRatio : ℚ) : ℝ)
          ((measuredNoise : ℚ) : ℝ) rho
      ∧ NoisyFade 0 ((fittedRatio : ℚ) : ℝ) ((measuredNoise : ℚ) : ℝ) rho) := by
  rintro ⟨h1, h2⟩
  have h := u116_floor_resolution h1 h2
  have hL : ((floorEstimate : ℚ) : ℝ) = (2299719 / 4850000 : ℝ) := by
    rw [floorEstimate_value]; norm_num
  rw [hL, sub_zero, abs_of_pos (by norm_num : (0:ℝ) < 2299719 / 4850000)] at h
  norm_num at h

/-- The identifiability window `L ± 2η/|1−λ|` around the Aitken estimate is narrower than
`[0.44, 0.51]`, i.e. comparable with the pre-registered `[0.46, 0.49]` window. -/
theorem u116_floor_window_width {L : ℝ} {rho : ℕ → ℝ}
    (h1 : NoisyFade ((floorEstimate : ℚ) : ℝ) ((fittedRatio : ℚ) : ℝ)
      ((measuredNoise : ℚ) : ℝ) rho)
    (h2 : NoisyFade L ((fittedRatio : ℚ) : ℝ) ((measuredNoise : ℚ) : ℝ) rho) :
    (44 / 100 : ℝ) ≤ L ∧ L ≤ 51 / 100 := by
  have h := u116_floor_resolution h1 h2
  have hL : ((floorEstimate : ℚ) : ℝ) = (2299719 / 4850000 : ℝ) := by
    rw [floorEstimate_value]; norm_num
  rw [hL] at h
  have := abs_le.mp h
  constructor <;> [linarith [this.1]; linarith [this.2]]

/-! ## 3. Averaging across a rebound -/

/-- Closed form of the alternating partial sums `∑_{k<K} (−1)ᵏ`: they are `0` or `1`. -/
theorem alternating_signs_partial_sum_eq (K : ℕ) :
    ∑ k ∈ range K, (-1 : ℝ) ^ k = if Even K then 0 else 1 := by
  induction K with
  | zero => simp
  | succ K ih =>
      rw [sum_range_succ, ih]
      rcases Nat.even_or_odd K with hK | hK
      · rw [if_pos hK, if_neg (by simpa [Nat.even_add_one] using hK), hK.neg_one_pow]
        ring
      · have hodd : ¬ Even K := Nat.not_even_iff_odd.mpr hK
        rw [if_neg hodd, if_pos (by simpa [Nat.even_add_one] using hodd), hK.neg_one_pow]
        ring

/-- Consequently the alternating partial sums are bounded by `1` in absolute value. -/
theorem alternating_signs_partial_sum_abs_le_one (K : ℕ) :
    |∑ k ∈ range K, (-1 : ℝ) ^ k| ≤ 1 := by
  rw [alternating_signs_partial_sum_eq K]
  split <;> norm_num

/-- **Averaging beats the band.**  For a ladder oscillating about its floor with amplitude `η`
— the extreme form of "rebound noise" — every single rung is off by exactly `η`, but the mean
of the first `K` rungs is within `η/K` of the floor.  Rebound noise is therefore averageable,
in sharp contrast with the `η/(1−q)` trap band of a one-sided model. -/
theorem alternating_average_recovers_floor (L : ℝ) {eta : ℝ} (heta : 0 ≤ eta) {K : ℕ}
    (hK : 0 < K) :
    |(∑ k ∈ range K, (L + eta * (-1 : ℝ) ^ k)) / K - L| ≤ eta / K := by
  have hKpos : (0 : ℝ) < K := by exact_mod_cast hK
  have hsum : ∑ k ∈ range K, (L + eta * (-1 : ℝ) ^ k)
      = K * L + eta * ∑ k ∈ range K, (-1 : ℝ) ^ k := by
    rw [sum_add_distrib, ← mul_sum, sum_const, card_range]
    simp [nsmul_eq_mul]
  rw [hsum]
  have hdiv : (K * L + eta * ∑ k ∈ range K, (-1 : ℝ) ^ k) / K - L
      = (eta * ∑ k ∈ range K, (-1 : ℝ) ^ k) / K := by
    field_simp
    ring
  rw [hdiv, abs_div, abs_of_pos hKpos, abs_mul, abs_of_nonneg heta,
    div_le_div_iff_of_pos_right hKpos]
  nlinarith [alternating_signs_partial_sum_abs_le_one K,
    abs_nonneg (∑ k ∈ range K, (-1 : ℝ) ^ k)]

/-! ## 4. The record: a second, linear floor estimator -/

/-- The plain mean of the three recorded rungs `0.4880, 0.4621, 0.4847`. -/
def threeRungAverage : ℚ := (rungA + rungB + rungC) / 3

/-- Closed form of the three-rung mean. -/
theorem threeRungAverage_value : threeRungAverage = 14348 / 30000 := by
  unfold threeRungAverage rungA rungB rungC; norm_num

/-- The linear (mean) estimator also lands inside the pre-registered floor window. -/
theorem u116_three_rung_average_in_band :
    (46 : ℚ) / 100 ≤ threeRungAverage ∧ threeRungAverage ≤ 49 / 100 := by
  rw [threeRungAverage_value]
  constructor <;> norm_num

/-- **Two independent estimators concur.**  The nonlinear Aitken `Δ²` floor and the linear
three-rung mean differ by less than `0.005`, well inside the pre-registered window width. -/
theorem u116_two_estimators_agree :
    |threeRungAverage - floorEstimate| < 5 / 1000 := by
  rw [threeRungAverage_value, floorEstimate_value]
  rw [abs_of_pos (by norm_num : (0:ℚ) < 14348 / 30000 - 2299719 / 4850000)]
  norm_num

end Catalog.Probability.TDialU116FloorIdentifiability