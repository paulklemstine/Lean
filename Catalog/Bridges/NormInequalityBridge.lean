import Mathlib

/-! # Norm Inequality Bridge

Proves norm comparison inequalities for certified adversarial robustness:

1. L∞ ≤ L1: max(|x|, |y|) ≤ |x| + |y|
2. Young's inequality for p = 2: a*b ≤ a²/2 + b²/2
3. AM-QM squared: ((a+b)/2)² ≤ (a²+b²)/2
4. Cauchy-Schwarz product: a²b² ≤ ((a²+b²)/2)²
5. L1 ≤ √2 · L2 for non-negative values
6. L1 squared ≤ 2 · L2 squared
-/

noncomputable section

open Real

namespace NormInequalityBridge

/-! ## Section 1: L∞ vs L1 Norm Comparison -/

/-- L∞ ≤ L1: the maximum is bounded by the sum. -/
theorem linf_le_l1 (x y : ℝ) :
    max |x| |y| ≤ |x| + |y| :=
  max_le_add_of_nonneg (abs_nonneg x) (abs_nonneg y)

/-- For non-negative values: max(a,b) ≤ a + b -/
theorem max_le_sum (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    max a b ≤ a + b :=
  max_le_add_of_nonneg ha hb

/-! ## Section 2: Young's Inequality for p = 2 -/

/-- Young's inequality for p = q = 2: a*b ≤ a²/2 + b²/2. -/
theorem young_inequality_p2 (a b : ℝ) (_ : 0 ≤ a) (_ : 0 ≤ b) :
    a * b ≤ a ^ 2 / 2 + b ^ 2 / 2 := by nlinarith [sq_nonneg (a - b)]

/-- Square sum ≥ twice product: a² + b² ≥ 2*a*b. -/
theorem sq_sum_ge_twice_product (a b : ℝ) :
    a ^ 2 + b ^ 2 ≥ 2 * a * b := by nlinarith [sq_nonneg (a - b)]

/-! ## Section 3: AM-QM Inequality -/

/-- AM-QM squared: ((a+b)/2)² ≤ (a²+b²)/2. -/
theorem am_le_qm_squared (a b : ℝ) (_ : 0 ≤ a) (_ : 0 ≤ b) :
    ((a + b) / 2) ^ 2 ≤ (a ^ 2 + b ^ 2) / 2 := by nlinarith [sq_nonneg (a - b)]

/-! ## Section 4: Cauchy-Schwarz -/

/-- Cauchy-Schwarz product: a²b² ≤ ((a²+b²)/2)². -/
theorem cauchy_schwarz_product (a b : ℝ) :
    a ^ 2 * b ^ 2 ≤ ((a ^ 2 + b ^ 2) / 2) ^ 2 := by nlinarith [sq_nonneg (a ^ 2 - b ^ 2)]

/-- Product ≤ half norm-squared: a*b ≤ (a² + b²)/2. -/
theorem product_le_half_norm_sq (a b : ℝ) :
    a * b ≤ (a ^ 2 + b ^ 2) / 2 := by nlinarith [sq_nonneg (a - b)]

/-- Absolute value bound: -a*b ≤ (a² + b²)/2. -/
theorem neg_product_le_half_norm_sq (a b : ℝ) :
    -(a * b) ≤ (a ^ 2 + b ^ 2) / 2 := by nlinarith [sq_nonneg (a + b)]

/-! ## Section 5: L1 vs L2 Norm Comparison -/

/-- L1 ≤ √2 · L2 for non-negative values. -/
theorem l1_le_sqrt2_l2_nonneg (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    a + b ≤ Real.sqrt 2 * Real.sqrt (a ^ 2 + b ^ 2) := by
  have h1 : (a + b) ^ 2 ≤ 2 * (a ^ 2 + b ^ 2) := by nlinarith [sq_nonneg (a - b)]
  have h2 : (0 : ℝ) ≤ a + b := by linarith
  have h4 : (0 : ℝ) ≤ a ^ 2 + b ^ 2 := by nlinarith [sq_nonneg a, sq_nonneg b]
  have h5 := Real.sqrt_le_sqrt h1
  rw [Real.sqrt_sq h2] at h5
  rw [Real.sqrt_mul (by norm_num : (0 : ℝ) ≤ 2)] at h5
  exact h5

/-- L1 squared ≤ 2 · L2 squared for non-negative values. -/
theorem l1_sq_le_2_l2_sq_nonneg (a b : ℝ) (_ : 0 ≤ a) (_ : 0 ≤ b) :
    (a + b) ^ 2 ≤ 2 * (a ^ 2 + b ^ 2) := by nlinarith [sq_nonneg (a - b)]

/-- L2 norm is non-negative. -/
theorem l2_norm_nonneg (a b : ℝ) :
    (0 : ℝ) ≤ Real.sqrt (a ^ 2 + b ^ 2) :=
  Real.sqrt_nonneg (a ^ 2 + b ^ 2)

/-- L1 is non-negative for non-negative values. -/
theorem l1_nonneg (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    (0 : ℝ) ≤ a + b := by linarith

end NormInequalityBridge