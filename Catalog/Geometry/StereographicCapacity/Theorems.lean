/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Capacity Theory: Main Theorems

This file extends the definitions of `Geometry.StereographicCapacity.Defs`
(`stereoFactor`, `stereoExclusionRadius`, `StereoSeparated`, `sphereArea`,
`sphericalCapArea`, `SphericalPackingBound`, `stereoBoundS2`,
`stereoBoundS2Closed`) with proven theorems on sphere packing.

The headline results:

1. **Conformal factor bounds** (`stereoFactor_pos`, `stereoFactor_le_two`,
   `stereoFactor_eq_two_iff`): the stereographic scale factor is a strictly
   positive quantity, bounded above by `2`, attaining `2` exactly at the origin.

2. **Exclusion-radius closed form** (`stereoExclusionRadius_eq`): the weighted
   Euclidean exclusion radius is `tan r · (1 + ‖x‖²)/2`.

3. **Closed form of the S² distortion bound** (`stereoBoundS2_eq_closed`):
   `stereoBoundS2 r = 8 / (cos²r · (1 - cos r))`.

4. **Trivial packing bound** (`spherePacking_card_le_one`,
   `sphericalPackingBound_one_of_one_lt`): a geodesic radius `r > 1` forces
   any `2r`-separated set on `Sⁿ` to be a singleton, since the sphere has
   diameter `2`. Plus monotonicity (`sphericalPackingBound_mono`).
-/
import Mathlib
import Geometry.StereographicCapacity.Defs

open Real Finset

namespace StereographicCapacity

/-! ## Conformal factor bounds -/

-- !-- The numerator `2 > 0` and denominator `1 + ‖x‖² ≥ 1 > 0`, so the quotient is positive. -- !--
theorem stereoFactor_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    0 < stereoFactor x :=
  div_pos zero_lt_two (by positivity)

-- !-- Since `1 + ‖x‖² ≥ 1`, dividing `2` by it can only shrink it: `2/(1+‖x‖²) ≤ 2`. -- !--
theorem stereoFactor_le_two {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    stereoFactor x ≤ 2 :=
  div_le_self zero_le_two (by nlinarith [sq_nonneg ‖x‖])

-- !-- `2/(1+‖x‖²) = 2` forces `‖x‖² = 0`, hence `‖x‖ = 0`, hence `x = 0`; conversely trivial. -- !--
theorem stereoFactor_eq_two_iff {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    stereoFactor x = 2 ↔ x = 0 := by
  unfold stereoFactor
  norm_num [div_eq_iff, add_eq_zero_iff_of_nonneg, sq_nonneg]

/-! ## Exclusion radius closed form -/

-- !-- Dividing `tan r` by the conformal factor `2/(1+‖x‖²)` multiplies by its reciprocal. -- !--
theorem stereoExclusionRadius_eq {n : ℕ} (r : ℝ) (x : EuclideanSpace ℝ (Fin n)) :
    stereoExclusionRadius r x = Real.tan r * (1 + ‖x‖ ^ 2) / 2 := by
  have h : (1 + ‖x‖ ^ 2) ≠ 0 := by positivity
  unfold stereoExclusionRadius stereoFactor
  field_simp

/-! ## Closed form of the S² distortion bound -/

-- !-- Substitute `sphereArea 2 = 4π`, `sphericalCapArea r = 2π(1-cos r)`, then clear denominators
-- with `π ≠ 0`, `cos r ≠ 0`, `1 - cos r ≠ 0`. -- !--
theorem stereoBoundS2_eq_closed (r : ℝ) (hcos : Real.cos r ≠ 0)
    (hcos1 : Real.cos r ≠ 1) :
    stereoBoundS2 r = stereoBoundS2Closed r := by
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  have h1 : 1 - Real.cos r ≠ 0 := sub_ne_zero.mpr (Ne.symm hcos1)
  unfold stereoBoundS2 stereoBoundS2Closed sphereArea sphericalCapArea
  field_simp
  ring

/-! ## Trivial packing bound for large radius -/

-- !-- Two distinct points on the unit sphere have distance `≤ ‖x‖ + ‖y‖ = 2`, contradicting
-- `2r ≤ dist` when `r > 1`; hence the separated set has at most one point. -- !--
theorem spherePacking_card_le_one {n : ℕ} {r : ℝ} (hr : 1 < r)
    (s : Finset (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n + 1))) 1))
    (hsep : ∀ ⦃x y⦄, x ∈ s → y ∈ s →
      (x : EuclideanSpace ℝ (Fin (n + 1))) ≠ y →
      2 * r ≤ dist (x : EuclideanSpace ℝ (Fin (n + 1)))
        (y : EuclideanSpace ℝ (Fin (n + 1)))) :
    s.card ≤ 1 := by
  apply Finset.card_le_one.mpr
  intro a ha b hb
  by_contra hab
  have hcoe : (a : EuclideanSpace ℝ (Fin (n + 1))) ≠ b := fun h => hab (Subtype.ext h)
  have hkey : 2 * r ≤ dist (a : EuclideanSpace ℝ (Fin (n + 1))) b := hsep ha hb hcoe
  have hna : ‖(a : EuclideanSpace ℝ (Fin (n + 1)))‖ = 1 := by simp
  have hnb : ‖(b : EuclideanSpace ℝ (Fin (n + 1)))‖ = 1 := by simp
  rw [dist_eq_norm] at hkey
  have hle : ‖(a : EuclideanSpace ℝ (Fin (n + 1))) - b‖ ≤ 2 := by
    calc ‖(a : EuclideanSpace ℝ (Fin (n + 1))) - b‖
        ≤ ‖(a : EuclideanSpace ℝ (Fin (n + 1)))‖ + ‖(b : EuclideanSpace ℝ (Fin (n + 1)))‖ :=
          norm_sub_le _ _
      _ = 2 := by rw [hna, hnb]; norm_num
  linarith

-- !-- Immediate from `spherePacking_card_le_one` since `⌈(1:ℝ)⌉₊ = 1`. -- !--
theorem sphericalPackingBound_one_of_one_lt (n : ℕ) {r : ℝ} (hr : 1 < r) :
    SphericalPackingBound n r 1 := by
  intro s hs
  exact le_trans (spherePacking_card_le_one hr s hs) (by norm_num)

-- !-- Larger budgets give weaker (larger) ceilings, so the bound is preserved upward. -- !--
theorem sphericalPackingBound_mono (n : ℕ) (r : ℝ) {B B' : ℝ} (hB : B ≤ B')
    (h : SphericalPackingBound n r B) : SphericalPackingBound n r B' :=
  fun s hs => le_trans (h s hs) (Nat.ceil_mono hB)

end StereographicCapacity