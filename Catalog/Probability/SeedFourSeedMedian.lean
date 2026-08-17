/-
# The fourth seed can confirm the `7/8` law but cannot calibrate it

`Logic.KneeQuotaScaling` pre-registered the four-seed test at `(d = 4, ctx = 2048)`: with the
three recorded knees `{256, 224, 160}` and an unknown fourth seed `x`, the two central rungs
of the completed ensemble are `quotaBudget (knees16four x) 2 = min 224 (max 160 x)` and
`quotaBudget (knees16four x) 3 = max 224 (min 256 x)`.  `Probability.SeedQuotaBinomial`
proved on the probabilistic side that a `2r`-seed ensemble has **no** calibrated rung
(`SeedQuota.even_no_calibrated_rung`).

This file closes conjecture **C1** of the previous cycle's `FUTURE_DIRECTIONS.md` by computing
the *four-seed reading* — the average of the two central order statistics, which is the
convention forced by `SeedQuota.even_rungs_average_calibrated` — as an explicit function of
the fourth seed, and its distance (`bias`) from the `7/8` value `224`.

Main results.

* `SeedFourMedian.reading4_eq` and the four closed forms
  (`reading4_of_le_160`, `reading4_of_low`, `reading4_of_high`, `reading4_of_ge_256`):
  the reading is `192` below `160`, rises linearly to `224` on `[160, 224]`, rises further to
  `240` on `[224, 256]`, and saturates at `240`.  It is **monotone** in the fourth seed
  (`reading4_mono`) — the four-seed reading has no protection against a large fourth seed on
  the *low* side, unlike the three-seed median.
* `SeedFourMedian.bias_eq_zero_iff` — the reading hits the `7/8` value **iff** `x = 224`
  exactly: a single grid point out of the whole axis.
* `SeedFourMedian.bias_le_sixteen_iff` — the reading is within one half grid step (`16`) of
  `224` **iff** `192 ≤ x`, and `bias_eq_thirtytwo_iff` — it is off by a full grid step `32`
  iff `x ≤ 160`.  So the announced low-tail candidates behave differently: `x = 192` and any
  `x ≥ 224` keep the reading within `16`, whereas `x = 160` (a repeat of the measured low
  tail) costs the full `32`.
* `SeedFourMedian.bias_strictAnti_low` / `bias_strictMono_high` — the bias is strictly
  decreasing up to `224` and strictly increasing after it: `224` is the unique minimiser, and
  the profile is a genuine V, flat only outside `[160, 256]`.
* `SeedFourMedian.fourth_seed_confirms_not_calibrates` — **the dichotomy C1 asked for.**  The
  three-seed median already reads `224` exactly; a fourth seed reproduces that reading only
  at the single value `x = 224`, and *no* rung of a four-seed ensemble is calibrated.  A
  fourth seed can therefore confirm the law (weakly, within `16`, for `x ≥ 192`) but cannot
  calibrate the ensemble; by `SeedQuota.odd_median_rung_calibrated` a fifth seed can.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Logic.KneeQuotaScaling

namespace SeedFourMedian

open KneeMedian KneeQuota SeedQuota

/-! ## 1.  The four-seed reading as a function of the fourth seed -/

/-- The **four-seed reading** of the NET-48 cell: the average of the two central order
statistics of `{256, 224, 160, x}`, i.e. the standard even-sample median. -/
noncomputable def reading4 (x : ℕ) : ℚ :=
  ((quotaBudget (knees16four x) 2 : ℚ) + (quotaBudget (knees16four x) 3 : ℚ)) / 2

/-- The reading, in terms of the two pre-registered central rungs. -/
theorem reading4_eq (x : ℕ) :
    reading4 x = (((min 224 (max 160 x) : ℕ) : ℚ) + ((max 224 (min 256 x) : ℕ) : ℚ)) / 2 := by
  rw [reading4, fourSeed_lower_median, fourSeed_upper_median]

theorem reading4_of_le_160 {x : ℕ} (h : x ≤ 160) : reading4 x = 192 := by
  rw [reading4_eq]
  have h1 : min 224 (max 160 x) = 160 := by omega
  have h2 : max 224 (min 256 x) = 224 := by omega
  rw [h1, h2]; norm_num

theorem reading4_of_low {x : ℕ} (h1 : 160 ≤ x) (h2 : x ≤ 224) :
    reading4 x = ((x : ℚ) + 224) / 2 := by
  rw [reading4_eq]
  have ha : min 224 (max 160 x) = x := by omega
  have hb : max 224 (min 256 x) = 224 := by omega
  rw [ha, hb]; push_cast; ring

theorem reading4_of_high {x : ℕ} (h1 : 224 ≤ x) (h2 : x ≤ 256) :
    reading4 x = (224 + (x : ℚ)) / 2 := by
  rw [reading4_eq]
  have ha : min 224 (max 160 x) = 224 := by omega
  have hb : max 224 (min 256 x) = x := by omega
  rw [ha, hb]; push_cast; ring

theorem reading4_of_ge_256 {x : ℕ} (h : 256 ≤ x) : reading4 x = 240 := by
  rw [reading4_eq]
  have ha : min 224 (max 160 x) = 224 := by omega
  have hb : max 224 (min 256 x) = 256 := by omega
  rw [ha, hb]; norm_num

/-- The reading is squeezed between the extreme readings `192` and `240`. -/
theorem reading4_mem (x : ℕ) : 192 ≤ reading4 x ∧ reading4 x ≤ 240 := by
  rcases le_or_gt x 160 with h | h
  · rw [reading4_of_le_160 h]; norm_num
  rcases le_or_gt x 224 with h2 | h2
  · rw [reading4_of_low (by omega) h2]
    have : (160 : ℚ) ≤ (x : ℚ) := by exact_mod_cast h.le
    have hx : (x : ℚ) ≤ 224 := by exact_mod_cast h2
    constructor <;> linarith
  rcases le_or_gt x 256 with h3 | h3
  · rw [reading4_of_high (by omega) h3]
    have : (224 : ℚ) ≤ (x : ℚ) := by exact_mod_cast h2.le
    have hx : (x : ℚ) ≤ 256 := by exact_mod_cast h3
    constructor <;> linarith
  · rw [reading4_of_ge_256 (by omega)]; norm_num

/-- **The four-seed reading is monotone in the fourth seed.**  Unlike the three-seed median,
which is protected in both directions by one corrupted seed
(`KneeQuota.three_seed_median_breakdown`), the even reading moves with every change of `x`
inside `[160, 256]`. -/
theorem reading4_mono : Monotone reading4 := by
  intro x y hxy
  rw [reading4_eq, reading4_eq]
  have h1 : min 224 (max 160 x) ≤ min 224 (max 160 y) := by omega
  have h2 : max 224 (min 256 x) ≤ max 224 (min 256 y) := by omega
  have h1' : ((min 224 (max 160 x) : ℕ) : ℚ) ≤ ((min 224 (max 160 y) : ℕ) : ℚ) := by
    exact_mod_cast h1
  have h2' : ((max 224 (min 256 x) : ℕ) : ℚ) ≤ ((max 224 (min 256 y) : ℕ) : ℚ) := by
    exact_mod_cast h2
  linarith

/-! ## 2.  The bias profile: a V with a unique zero at `224` -/

/-- The distance of the four-seed reading from the `7/8` value `224 = (7/8)·(d·ctx/32)`. -/
noncomputable def bias (x : ℕ) : ℚ := |reading4 x - 224|

theorem bias_of_le_160 {x : ℕ} (h : x ≤ 160) : bias x = 32 := by
  rw [bias, reading4_of_le_160 h]; norm_num

theorem bias_of_low {x : ℕ} (h1 : 160 ≤ x) (h2 : x ≤ 224) : bias x = (224 - (x : ℚ)) / 2 := by
  have hx : (x : ℚ) ≤ 224 := by exact_mod_cast h2
  rw [bias, reading4_of_low h1 h2, abs_of_nonpos (by linarith)]
  ring

theorem bias_of_high {x : ℕ} (h1 : 224 ≤ x) (h2 : x ≤ 256) : bias x = ((x : ℚ) - 224) / 2 := by
  have hx : (224 : ℚ) ≤ (x : ℚ) := by exact_mod_cast h1
  rw [bias, reading4_of_high h1 h2, abs_of_nonneg (by linarith)]
  ring

theorem bias_of_ge_256 {x : ℕ} (h : 256 ≤ x) : bias x = 16 := by
  rw [bias, reading4_of_ge_256 h]; norm_num

/-- **`224` is the unique fourth seed that reproduces the `7/8` reading.** -/
theorem bias_eq_zero_iff (x : ℕ) : bias x = 0 ↔ x = 224 := by
  constructor
  · intro h
    by_contra hx
    rcases le_or_gt x 160 with h1 | h1
    · rw [bias_of_le_160 h1] at h; norm_num at h
    rcases lt_or_gt_of_ne hx with h2 | h2
    · rw [bias_of_low (by omega) (by omega)] at h
      have : (x : ℚ) < 224 := by exact_mod_cast h2
      rw [div_eq_zero_iff] at h
      rcases h with h | h <;> linarith
    rcases le_or_gt x 256 with h3 | h3
    · rw [bias_of_high (by omega) h3] at h
      have : (224 : ℚ) < (x : ℚ) := by exact_mod_cast h2
      rw [div_eq_zero_iff] at h
      rcases h with h | h <;> linarith
    · rw [bias_of_ge_256 (by omega)] at h; norm_num at h
  · rintro rfl
    rw [bias_of_low (by norm_num) (by norm_num)]; norm_num

/-- **The half-step window.**  The four-seed reading lands within `16` — half a grid step —
of the `7/8` value exactly when the fourth seed is at least `192`. -/
theorem bias_le_sixteen_iff (x : ℕ) : bias x ≤ 16 ↔ 192 ≤ x := by
  constructor
  · intro h
    by_contra hx
    push_neg at hx
    rcases le_or_gt x 160 with h1 | h1
    · rw [bias_of_le_160 h1] at h; norm_num at h
    · rw [bias_of_low (by omega) (by omega)] at h
      have : (x : ℚ) < 192 := by exact_mod_cast hx
      linarith
  · intro hx
    rcases le_or_gt x 224 with h2 | h2
    · rw [bias_of_low (by omega) h2]
      have : (192 : ℚ) ≤ (x : ℚ) := by exact_mod_cast hx
      linarith
    rcases le_or_gt x 256 with h3 | h3
    · rw [bias_of_high (by omega) h3]
      have : (x : ℚ) ≤ 256 := by exact_mod_cast h3
      linarith
    · rw [bias_of_ge_256 (by omega)]

/-- **The full-step failure.**  A repeat of the measured low tail costs a whole grid step:
the bias is `32` exactly when the fourth seed does not exceed `160`, and `32` is its maximum. -/
theorem bias_eq_thirtytwo_iff (x : ℕ) : bias x = 32 ↔ x ≤ 160 := by
  refine ⟨fun h => ?_, bias_of_le_160⟩
  by_contra hx
  push_neg at hx
  rcases le_or_gt x 224 with h2 | h2
  · rw [bias_of_low (by omega) h2] at h
    have : (160 : ℚ) < (x : ℚ) := by exact_mod_cast hx
    linarith
  rcases le_or_gt x 256 with h3 | h3
  · rw [bias_of_high (by omega) h3] at h
    have : (x : ℚ) ≤ 256 := by exact_mod_cast h3
    linarith
  · rw [bias_of_ge_256 (by omega)] at h; norm_num at h

theorem bias_le_thirtytwo (x : ℕ) : bias x ≤ 32 := by
  rcases le_or_gt x 160 with h1 | h1
  · rw [bias_of_le_160 h1]
  rcases le_or_gt x 224 with h2 | h2
  · rw [bias_of_low (by omega) h2]
    have : (160 : ℚ) ≤ (x : ℚ) := by exact_mod_cast h1.le
    linarith
  rcases le_or_gt x 256 with h3 | h3
  · rw [bias_of_high (by omega) h3]
    have : (x : ℚ) ≤ 256 := by exact_mod_cast h3
    linarith
  · rw [bias_of_ge_256 (by omega)]; norm_num

/-- On the low arm the bias strictly decreases: every grid step gained by the fourth seed
buys exactly half a step of accuracy. -/
theorem bias_strictAnti_low {x y : ℕ} (h1 : 160 ≤ x) (hxy : x < y) (h2 : y ≤ 224) :
    bias y < bias x := by
  rw [bias_of_low h1 (by omega), bias_of_low (by omega) h2]
  have : (x : ℚ) < (y : ℚ) := by exact_mod_cast hxy
  linarith

/-- On the high arm it strictly increases, at the same half-step rate. -/
theorem bias_strictMono_high {x y : ℕ} (h1 : 224 ≤ x) (hxy : x < y) (h2 : y ≤ 256) :
    bias x < bias y := by
  rw [bias_of_high h1 (by omega), bias_of_high (by omega) h2]
  have : (x : ℚ) < (y : ℚ) := by exact_mod_cast hxy
  linarith

/-! ## 3.  C1: confirmation without calibration -/

/-- The three-seed reading, for comparison: the median rung of the measured ensemble is
exactly the `7/8` value, so its bias is `0`. -/
theorem three_seed_bias_zero : |((quotaBudget (knees16four 224) 2 : ℚ)) - 224| = 0 := by
  rw [fourSeed_lower_median]
  norm_num

/-- **C1, closed.**  (i) The four-seed reading equals the `7/8` value for exactly one fourth
seed, `x = 224`; (ii) for every other fourth seed the reading is strictly worse than the
three-seed median, which is exact; (iii) whatever the fourth seed, *no* rung of a four-seed
ensemble is calibrated on coin-flip seeds, while (iv) the five-seed median rung is.  A fourth
seed can confirm the law but cannot calibrate the ensemble — calibration is a parity
property, and only the fifth seed restores it. -/
theorem fourth_seed_confirms_not_calibrates :
    (∀ x : ℕ, bias x = 0 ↔ x = 224) ∧
      (∀ x : ℕ, x ≠ 224 → 0 < bias x) ∧
      (∀ m : ℕ, rungProb 4 m (1/2 : ℝ) ≠ 1/2) ∧
      rungProb 5 3 (1/2 : ℝ) = 1/2 := by
  refine ⟨bias_eq_zero_iff, fun x hx => ?_, fun m => ?_, ?_⟩
  · rcases lt_or_eq_of_le (abs_nonneg (reading4 x - 224)) with h | h
    · exact h
    · exact absurd ((bias_eq_zero_iff x).1 h.symm) hx
  · have := even_no_calibrated_rung 2 m
    simpa using this
  · have := odd_median_rung_calibrated 2
    simpa using this

end SeedFourMedian