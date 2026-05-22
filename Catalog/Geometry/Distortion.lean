/-
Copyright (c) 2025. All rights reserved.
Stereographic Capacity Theory: Distortion Lemmas

This module proves fundamental properties of the stereographic conformal factor,
establishing the distortion calculus that underlies all packing bounds.
-/
import Geometry.StereographicCapacity.Defs

open Real

/-! ## Properties of the Stereographic Conformal Factor -/

/-
The denominator `1 + ‖x‖²` is always positive.
-/
theorem one_add_norm_sq_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    0 < 1 + ‖x‖ ^ 2 := by
  positivity

/-
The stereographic conformal factor is always positive.
-/
theorem stereoFactor_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    0 < stereoFactor x := by
  exact div_pos zero_lt_two ( one_add_norm_sq_pos x )

/-
The stereographic conformal factor is at most 2 (achieved at the origin).
-/
theorem stereoFactor_le_two {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    stereoFactor x ≤ 2 := by
  exact div_le_self zero_le_two ( by linarith [ sq_nonneg ‖x‖ ] )

/-
At the origin, the conformal factor equals exactly 2.
-/
theorem stereoFactor_zero {n : ℕ} :
    stereoFactor (0 : EuclideanSpace ℝ (Fin n)) = 2 := by
  unfold stereoFactor; norm_num

/-
The reciprocal of the conformal factor satisfies `1/λ(x) = (1 + ‖x‖²)/2`.
-/
theorem stereoFactor_inv {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    1 / stereoFactor x = (1 + ‖x‖ ^ 2) / 2 := by
  convert one_div_div 2 ( 1 + ‖x‖ ^ 2 ) using 1

/-
The conformal factor is bounded below by a positive quantity depending on ‖x‖.
-/
theorem stereoFactor_lower_bound {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    2 / (1 + ‖x‖ ^ 2) ≤ stereoFactor x := by
  rfl

/-
The reciprocal conformal factor `1/λ(x)` is at least `1/2`.
-/
theorem inv_stereoFactor_ge {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    1 / 2 ≤ 1 / stereoFactor x := by
  exact one_div_le_one_div_of_le ( stereoFactor_pos x ) ( stereoFactor_le_two x )

/-
The n-th power distortion ratio is bounded: `(1/λ(x))^n ≥ (1/2)^n`.
-/
theorem stereoFactor_pow_distortion {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    (1 / 2 : ℝ) ^ n ≤ (1 / stereoFactor x) ^ n := by
  exact pow_le_pow_left₀ ( by norm_num ) ( by simpa using inv_stereoFactor_ge x ) _