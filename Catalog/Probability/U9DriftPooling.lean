/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Probability.U9DriftIntervals

/-!
# Pooling the pilot and the fresh-seed replication: what "√2-tightened" really buys

Context (experiment 569, paper 216).  The round-74 ledger pools paper 214's pilot interval
for the band-9 smoothness ratio with the fresh-seed replication interval and reports a
"√2-tightened joint point ≈ 0.97".  This file develops the exact algebra of pooling two
independent estimates, and then audits that sentence against the ledger's own numbers.

The general theory:

* `U9Drift.poolVar_optimal` — for two independent estimates with variances `v₁, v₂ > 0`,
  every affine combination `w·x₁ + (1-w)·x₂` has variance at least
  `poolVar v₁ v₂ = v₁v₂/(v₁+v₂)`, with equality exactly at the inverse-variance weight
  `w = v₂/(v₁+v₂)` (`U9Drift.poolVar_attained`, `U9Drift.poolVar_optimal_strict`).
* `U9Drift.pooledHalfWidth_lt_left` / `_lt_right` — pooling is a strict gain over either
  input.
* `U9Drift.pooledHalfWidth_eq_of_eq` — at *matched* precisions the gain is exactly the
  advertised factor `√2`.
* `U9Drift.min_div_sqrt_two_le_pooledHalfWidth` — and `√2` is the *best possible* gain:
  for any precisions the pooled half width is at least `min/√2`, strictly so when the two
  precisions differ (`U9Drift.min_div_sqrt_two_lt_pooledHalfWidth`).

The audit of the ledger:

* `U9Drift.joint_interval_covers_one` — the inverse-variance pooled 95% interval of the two
  runs still covers `1` (`p ≈ 0.9617`, half width `≈ 0.04045`, upper edge `≈ 1.0021`).  So
  pooling does *not* resurrect the drift: the downgrade from "banked" to "open" is correct.
* `U9Drift.sqrt_two_tightening_fails` — the two runs are *not* precision-matched
  (`h_pilot ≈ 1.93 · h_rep`), so the realised tightening is far short of `√2`: the pooled
  half width strictly exceeds `h_rep/√2`.
* `U9Drift.equal_weight_pooling_overstates_the_drift` — the quoted joint point `≈ 0.97` is
  the *equal-weight* average of the two point estimates; the correct inverse-variance
  pooled point is strictly closer to `1`.  The ledger's own summary therefore overstates
  the residual tension.
-/

namespace U9Drift

open Real

/-! ## Inverse-variance pooling is optimal -/

/-- The variance of the inverse-variance pooled estimator. -/
noncomputable def poolVar (v₁ v₂ : ℝ) : ℝ := v₁ * v₂ / (v₁ + v₂)

/-- The inverse-variance weight put on the first estimate. -/
noncomputable def poolWeightVar (v₁ v₂ : ℝ) : ℝ := v₂ / (v₁ + v₂)

theorem poolVar_pos {v₁ v₂ : ℝ} (h₁ : 0 < v₁) (h₂ : 0 < v₂) : 0 < poolVar v₁ v₂ :=
  div_pos (mul_pos h₁ h₂) (by linarith)

/-- No affine combination of two independent estimates beats the inverse-variance pool. -/
theorem poolVar_optimal {v₁ v₂ : ℝ} (h₁ : 0 < v₁) (h₂ : 0 < v₂) (w : ℝ) :
    poolVar v₁ v₂ ≤ w ^ 2 * v₁ + (1 - w) ^ 2 * v₂ := by
  have hs : 0 < v₁ + v₂ := by linarith
  rw [poolVar, div_le_iff₀ hs]
  nlinarith [sq_nonneg (w * (v₁ + v₂) - v₂), mul_pos h₁ h₂]

/-- The bound of `poolVar_optimal` is attained, at the inverse-variance weight. -/
theorem poolVar_attained {v₁ v₂ : ℝ} (h₁ : 0 < v₁) (h₂ : 0 < v₂) :
    poolWeightVar v₁ v₂ ^ 2 * v₁ + (1 - poolWeightVar v₁ v₂) ^ 2 * v₂ = poolVar v₁ v₂ := by
  have hs : (v₁ + v₂) ≠ 0 := by positivity
  simp only [poolWeightVar, poolVar]
  field_simp
  ring

/-- ...and only there: any other weight is strictly worse. -/
theorem poolVar_optimal_strict {v₁ v₂ : ℝ} (h₁ : 0 < v₁) (h₂ : 0 < v₂) {w : ℝ}
    (hw : w ≠ poolWeightVar v₁ v₂) :
    poolVar v₁ v₂ < w ^ 2 * v₁ + (1 - w) ^ 2 * v₂ := by
  have hs : 0 < v₁ + v₂ := by linarith
  have hne : w * (v₁ + v₂) - v₂ ≠ 0 := by
    intro h
    apply hw
    rw [poolWeightVar, eq_div_iff (ne_of_gt hs)]
    linarith
  have hpos : 0 < (w * (v₁ + v₂) - v₂) ^ 2 := by positivity
  rw [poolVar, div_lt_iff₀ hs]
  nlinarith [mul_pos h₁ h₂]

/-- Pooling strictly improves on the first variance. -/
theorem poolVar_lt_left {v₁ v₂ : ℝ} (h₁ : 0 < v₁) (h₂ : 0 < v₂) : poolVar v₁ v₂ < v₁ := by
  rw [poolVar, div_lt_iff₀ (by linarith)]
  nlinarith

/-! ## Pooling in the half-width parameterisation -/

/-- The pooled half width of two intervals with half widths `h₁, h₂` (same coverage
factor): `h₁h₂/√(h₁²+h₂²)`. -/
noncomputable def pooledHalfWidth (h₁ h₂ : ℝ) : ℝ := h₁ * h₂ / Real.sqrt (h₁ ^ 2 + h₂ ^ 2)

/-- The inverse-variance weight on the first estimate, in terms of half widths. -/
noncomputable def poolWeight (h₁ h₂ : ℝ) : ℝ := h₂ ^ 2 / (h₁ ^ 2 + h₂ ^ 2)

/-- The pooled point estimate. -/
noncomputable def poolPoint (p₁ h₁ p₂ h₂ : ℝ) : ℝ :=
  poolWeight h₁ h₂ * p₁ + (1 - poolWeight h₁ h₂) * p₂

theorem pooledHalfWidth_pos {h₁ h₂ : ℝ} (a₁ : 0 < h₁) (a₂ : 0 < h₂) :
    0 < pooledHalfWidth h₁ h₂ := by
  have : 0 < Real.sqrt (h₁ ^ 2 + h₂ ^ 2) := Real.sqrt_pos.mpr (by positivity)
  exact div_pos (mul_pos a₁ a₂) this

theorem pooledHalfWidth_sq {h₁ h₂ : ℝ} (a₁ : 0 < h₁) (a₂ : 0 < h₂) :
    pooledHalfWidth h₁ h₂ ^ 2 = h₁ ^ 2 * h₂ ^ 2 / (h₁ ^ 2 + h₂ ^ 2) := by
  have hs : (0:ℝ) < h₁ ^ 2 + h₂ ^ 2 := by positivity
  rw [pooledHalfWidth, div_pow, Real.sq_sqrt hs.le, mul_pow]

/-- The pooled interval is strictly tighter than the first input. -/
theorem pooledHalfWidth_lt_left {h₁ h₂ : ℝ} (a₁ : 0 < h₁) (a₂ : 0 < h₂) :
    pooledHalfWidth h₁ h₂ < h₁ := by
  refine lt_of_sq_lt_sq_nonneg (pooledHalfWidth_pos a₁ a₂).le a₁.le ?_
  rw [pooledHalfWidth_sq a₁ a₂, div_lt_iff₀ (by positivity)]
  nlinarith [sq_nonneg h₁, sq_nonneg h₂, mul_pos (mul_pos a₁ a₁) (mul_pos a₁ a₁)]

/-- The pooled interval is strictly tighter than the second input. -/
theorem pooledHalfWidth_lt_right {h₁ h₂ : ℝ} (a₁ : 0 < h₁) (a₂ : 0 < h₂) :
    pooledHalfWidth h₁ h₂ < h₂ := by
  refine lt_of_sq_lt_sq_nonneg (pooledHalfWidth_pos a₁ a₂).le a₂.le ?_
  rw [pooledHalfWidth_sq a₁ a₂, div_lt_iff₀ (by positivity)]
  nlinarith [sq_nonneg h₁, sq_nonneg h₂, mul_pos (mul_pos a₂ a₂) (mul_pos a₂ a₂)]

/-- At matched precision the advertised `√2` tightening is exact. -/
theorem pooledHalfWidth_eq_of_eq {h : ℝ} (a : 0 < h) :
    pooledHalfWidth h h = h / Real.sqrt 2 := by
  have h2 : h ^ 2 + h ^ 2 = 2 * h ^ 2 := by ring
  rw [pooledHalfWidth, h2, Real.sqrt_mul (by norm_num) (h ^ 2), Real.sqrt_sq a.le,
    mul_comm (Real.sqrt 2) h, ← div_div]
  congr 1
  field_simp

/-- `√2` is the *best possible* pooling gain: whatever the two precisions, the pooled half
width is at least the better one divided by `√2`. -/
theorem min_div_sqrt_two_le_pooledHalfWidth {h₁ h₂ : ℝ} (a₁ : 0 < h₁) (a₂ : 0 < h₂) :
    min h₁ h₂ / Real.sqrt 2 ≤ pooledHalfWidth h₁ h₂ := by
  have hs : (0:ℝ) < h₁ ^ 2 + h₂ ^ 2 := by positivity
  have hsq : (min h₁ h₂ / Real.sqrt 2) ^ 2 = min h₁ h₂ ^ 2 / 2 := by
    rw [div_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]
  refine le_of_sq_le_sq_nonneg (pooledHalfWidth_pos a₁ a₂).le ?_
  rw [hsq, pooledHalfWidth_sq a₁ a₂, div_le_div_iff₀ (by norm_num) hs]
  rcases min_cases h₁ h₂ with ⟨he, hle⟩ | ⟨he, hle⟩ <;> rw [he]
  · have hsq12 : h₁ ^ 2 ≤ h₂ ^ 2 := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_left hsq12 (sq_nonneg h₁)]
  · have hsq21 : h₂ ^ 2 ≤ h₁ ^ 2 := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_left hsq21 (sq_nonneg h₂)]

/-- ...and the `√2` gain is *strictly* out of reach whenever the precisions differ. -/
theorem min_div_sqrt_two_lt_pooledHalfWidth {h₁ h₂ : ℝ} (a₁ : 0 < h₁) (a₂ : 0 < h₂)
    (hne : h₁ ≠ h₂) : min h₁ h₂ / Real.sqrt 2 < pooledHalfWidth h₁ h₂ := by
  have hs : (0:ℝ) < h₁ ^ 2 + h₂ ^ 2 := by positivity
  have hsq : (min h₁ h₂ / Real.sqrt 2) ^ 2 = min h₁ h₂ ^ 2 / 2 := by
    rw [div_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]
  refine lt_of_sq_lt_sq_nonneg (by positivity) (pooledHalfWidth_pos a₁ a₂).le ?_
  rw [hsq, pooledHalfWidth_sq a₁ a₂, div_lt_div_iff₀ (by norm_num) hs]
  rcases min_cases h₁ h₂ with ⟨he, hle⟩ | ⟨he, hle⟩ <;> rw [he]
  · have hlt : h₁ < h₂ := lt_of_le_of_ne hle hne
    have hsq12 : h₁ ^ 2 < h₂ ^ 2 := by nlinarith
    nlinarith [mul_lt_mul_of_pos_left hsq12 (pow_pos a₁ 2)]
  · have hsq21 : h₂ ^ 2 < h₁ ^ 2 := by nlinarith
    nlinarith [mul_lt_mul_of_pos_left hsq21 (pow_pos a₂ 2)]

/-! ## Auditing the round-74 pooled claim -/

theorem pilot1e6_center_eq : pilot1e6.center = 0.95095 := by
  show ((0.8630 : ℝ) + 1.0389) / 2 = _; norm_num

theorem pilot1e6_halfWidth_eq : pilot1e6.halfWidth = 0.08795 := by
  show ((1.0389 : ℝ) - 0.8630) / 2 = _; norm_num

theorem rep1e6_center_eq : rep1e6.center = 0.96455 := by
  show ((0.919 : ℝ) + 1.0101) / 2 = _; norm_num

theorem rep1e6_halfWidth_eq : rep1e6.halfWidth = 0.04555 := by
  show ((1.0101 : ℝ) - 0.919) / 2 = _; norm_num

/-- **The joint interval still covers the null.**  Inverse-variance pooling of paper 214's
pilot with the fresh-seed replication gives a 95% interval that contains `1`; the drift is
not resurrected by pooling. -/
theorem joint_interval_covers_one :
    |1 - poolPoint pilot1e6.center pilot1e6.halfWidth rep1e6.center rep1e6.halfWidth|
      ≤ pooledHalfWidth pilot1e6.halfWidth rep1e6.halfWidth := by
  rw [pilot1e6_center_eq, pilot1e6_halfWidth_eq, rep1e6_center_eq, rep1e6_halfWidth_eq]
  have a₁ : (0:ℝ) < 0.08795 := by norm_num
  have a₂ : (0:ℝ) < 0.04555 := by norm_num
  refine abs_le_of_sq_le_sq_nonneg (pooledHalfWidth_pos a₁ a₂).le ?_
  rw [pooledHalfWidth_sq a₁ a₂, poolPoint, poolWeight]
  norm_num

/-- The joint interval is nevertheless *close* to excluding the null: its upper edge sits
below `1.0022`.  (Pooled point `≈ 0.96167`, pooled half width `≈ 0.040447`.) -/
theorem joint_interval_upper_edge_lt :
    poolPoint pilot1e6.center pilot1e6.halfWidth rep1e6.center rep1e6.halfWidth
      + pooledHalfWidth pilot1e6.halfWidth rep1e6.halfWidth < 1.0022 := by
  rw [pilot1e6_center_eq, pilot1e6_halfWidth_eq, rep1e6_center_eq, rep1e6_halfWidth_eq]
  have a₁ : (0:ℝ) < 0.08795 := by norm_num
  have a₂ : (0:ℝ) < 0.04555 := by norm_num
  have hp : poolPoint 0.95095 0.08795 0.96455 0.04555 < 0.961674 := by
    rw [poolPoint, poolWeight]; norm_num
  have hw : pooledHalfWidth 0.08795 0.04555 < 0.040448 := by
    refine lt_of_sq_lt_sq_nonneg (pooledHalfWidth_pos a₁ a₂).le (by norm_num) ?_
    rw [pooledHalfWidth_sq a₁ a₂]
    norm_num
  linarith

/-- **The advertised `√2` tightening is not realised.**  The pilot half width is about
`1.93` times the replication's, so the pooled half width strictly exceeds
`h_rep/√2`: pooling with a much noisier study buys far less than `√2`. -/
theorem sqrt_two_tightening_fails :
    rep1e6.halfWidth / Real.sqrt 2 < pooledHalfWidth pilot1e6.halfWidth rep1e6.halfWidth := by
  rw [pilot1e6_halfWidth_eq, rep1e6_halfWidth_eq]
  have a₁ : (0:ℝ) < 0.08795 := by norm_num
  have a₂ : (0:ℝ) < 0.04555 := by norm_num
  have hmin : min (0.08795 : ℝ) 0.04555 = 0.04555 := by norm_num
  have := min_div_sqrt_two_lt_pooledHalfWidth a₁ a₂ (by norm_num)
  rwa [hmin] at this

/-- Even the *achievable* gain over the better study is modest: the pooled half width is
more than `0.88` times the replication's own half width. -/
theorem pooling_gain_is_small :
    0.88 * rep1e6.halfWidth < pooledHalfWidth pilot1e6.halfWidth rep1e6.halfWidth := by
  rw [pilot1e6_halfWidth_eq, rep1e6_halfWidth_eq]
  have a₁ : (0:ℝ) < 0.08795 := by norm_num
  have a₂ : (0:ℝ) < 0.04555 := by norm_num
  refine lt_of_sq_lt_sq_nonneg (by norm_num) (pooledHalfWidth_pos a₁ a₂).le ?_
  rw [pooledHalfWidth_sq a₁ a₂]
  norm_num

/-! ### Equal-weight versus inverse-variance pooling of the two point estimates -/

/-- Paper 214's reported point estimate at the `1e6` cut. -/
def pilotPoint : ℝ := 0.947

/-- Experiment 569's reported point estimate at the `1e6` cut. -/
def repPoint : ℝ := 0.99

/-- **The quoted joint point `≈ 0.97` is the equal-weight average.**  Weighting the two
runs by their precisions — as pooling requires — moves the joint point strictly closer to
the null value `1`, so the ledger's summary overstates the residual tension. -/
theorem equal_weight_pooling_overstates_the_drift :
    |1 - poolPoint pilotPoint pilot1e6.halfWidth repPoint rep1e6.halfWidth|
      < |1 - (pilotPoint + repPoint) / 2| := by
  rw [pilot1e6_halfWidth_eq, rep1e6_halfWidth_eq, poolPoint, poolWeight, pilotPoint, repPoint]
  rw [abs_of_nonneg (by norm_num), abs_of_nonneg (by norm_num)]
  norm_num

/-- The equal-weight average is indeed the ledger's `≈ 0.97`, and the inverse-variance
point is `≈ 0.98`. -/
theorem joint_points_numeric :
    (pilotPoint + repPoint) / 2 = 0.9685 ∧
      0.98 < poolPoint pilotPoint pilot1e6.halfWidth repPoint rep1e6.halfWidth ∧
      poolPoint pilotPoint pilot1e6.halfWidth repPoint rep1e6.halfWidth < 0.9810 := by
  refine ⟨by norm_num [pilotPoint, repPoint], ?_, ?_⟩ <;>
    rw [pilot1e6_halfWidth_eq, rep1e6_halfWidth_eq, poolPoint, poolWeight, pilotPoint,
      repPoint] <;> norm_num

end U9Drift