/-! # CatalogBuild.Bridges.BesselInequalityBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

import Mathlib

/-- Bessel inequality (1-dim): squared inner product with unit vector
is at most the norm squared. -/
theorem bessel_one (x e : E) (he : ‖e‖ = 1) :
    (inner ℝ x e) ^ 2 ≤ ‖x‖ ^ 2 := by
  have h₁ := real_inner_le_norm x e
  have h₂ := real_inner_le_norm (-x) e
  rw [inner_neg_left, norm_neg] at h₂
  rw [he] at h₁; rw [he, mul_one] at h₂
  nlinarith


/-- Gram discriminant is non-negative:
0 ≤ ‖x‖^2 * ‖y‖^2 - (inner x y)^2 -/
theorem gram_nonneg (x y : E) :
    0 ≤ ‖x‖ ^ 2 * ‖y‖ ^ 2 - (inner ℝ x y) ^ 2 := by
  have h₁ := real_inner_le_norm x y
  have h₂ := real_inner_le_norm (-x) y
  rw [inner_neg_left, norm_neg] at h₂
  nlinarith


/-- Cauchy-Schwarz in squared form:
(inner x y)^2 ≤ ‖x‖^2 * ‖y‖^2 -/
theorem inner_sq_le_norm_sq_mul (x y : E) :
    (inner ℝ x y) ^ 2 ≤ ‖x‖ ^ 2 * ‖y‖ ^ 2 := by
  have := gram_nonneg x y; nlinarith


/-- Gram discriminant zero when the second vector is zero. -/
theorem gram_eq_zero_right_zero (x : E) :
    ‖x‖ ^ 2 * ‖(0 : E)‖ ^ 2 - (inner ℝ x (0 : E)) ^ 2 = 0 := by
  simp [norm_zero, inner_zero_right]


/-- Gram is bounded by the product of norms squared. -/
theorem gram_le_norm_sq (x y : E) :
    ‖x‖ ^ 2 * ‖y‖ ^ 2 - (inner ℝ x y) ^ 2 ≤ ‖x‖ ^ 2 * ‖y‖ ^ 2 := by
  nlinarith [gram_nonneg x y]

