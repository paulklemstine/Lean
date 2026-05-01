import Mathlib

/-! # Convex-Tropical Bridge

Proves connections between convex analysis and tropical geometry:

1. AM-GM inequality: sqrt(a*b) ≤ (a+b)/2
2. AM-GM squared: a*b ≤ ((a+b)/2)^2
3. LSE lower bound: max(a,b) ≤ log(exp(a)+exp(b))
4. LSE upper bound: log(exp(a)+exp(b)) ≤ max(a,b) + log(2)
5. Exp midpoint convexity: exp((a+b)/2) ≤ (exp(a)+exp(b))/2

The AM-GM inequality bridges arithmetic mean (tropical) and geometric mean
(product), while the LSE bounds show logarithmic dequantization:
tropical max(a,b) is the limit of (1/c)*LSE(c*a, c*b) as c → ∞.
-/

noncomputable section

open Real

namespace ConvexTropicalBridge

/-! ## Section 1: AM-GM Inequality -/

/-- AM-GM for two non-negative reals: sqrt(a*b) ≤ (a+b)/2. -/
theorem am_gm_two (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    Real.sqrt (a * b) ≤ (a + b) / 2 := by
  have h1 : (0 : ℝ) ≤ (a + b) / 2 := by linarith
  have h2 : a * b ≤ ((a + b) / 2) ^ 2 := by nlinarith [sq_nonneg (a - b)]
  exact (Real.sqrt_le_iff (x := a * b) (y := (a + b) / 2)).mpr ⟨h1, h2⟩

/-- AM-GM squared: a*b ≤ ((a+b)/2)^2. -/
theorem am_gm_squared (a b : ℝ) (_ : 0 ≤ a) (_ : 0 ≤ b) :
    a * b ≤ ((a + b) / 2) ^ 2 := by nlinarith [sq_nonneg (a - b)]

/-- AM-GM for exponentials: sqrt(exp(a)*exp(b)) ≤ (exp(a)+exp(b))/2. -/
theorem am_gm_exp (a b : ℝ) :
    Real.sqrt (Real.exp a * Real.exp b) ≤ (Real.exp a + Real.exp b) / 2 :=
  am_gm_two (Real.exp a) (Real.exp b) (Real.exp_pos a).le (Real.exp_pos b).le

/-! ## Section 2: LSE Bounds (Log-Sum-Exp Dequantization) -/

/-- LSE lower bound: max(a,b) ≤ log(exp(a) + exp(b)).
    The tropical max is bounded below by LSE. -/
theorem lse_ge_max (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  have h_pos : (0 : ℝ) < Real.exp (max a b) := Real.exp_pos (max a b)
  have h_le : Real.exp (max a b) ≤ Real.exp a + Real.exp b := by
    cases' le_total a b with h h
    · rw [max_eq_right h]; exact le_add_of_nonneg_of_le (Real.exp_pos a).le le_rfl
    · rw [max_eq_left h]; exact le_add_of_le_of_nonneg le_rfl (Real.exp_pos b).le
  have := Real.log_le_log h_pos h_le
  rwa [Real.log_exp] at this

/-- LSE upper bound: log(exp(a) + exp(b)) ≤ max(a,b) + log(2).
    The tropical max plus log(2) bounds LSE from above. -/
theorem lse_le_max_add_log2 (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  have h_pos : (0 : ℝ) < Real.exp a + Real.exp b := add_pos (Real.exp_pos a) (Real.exp_pos b)
  have h_le : Real.exp a + Real.exp b ≤ 2 * Real.exp (max a b) := by
    rw [two_mul]; exact add_le_add (Real.exp_le_exp.mpr (le_max_left a b)) (Real.exp_le_exp.mpr (le_max_right a b))
  have h_log := Real.log_le_log h_pos h_le
  have h_prod : Real.log (2 * Real.exp (max a b)) = Real.log 2 + max a b := by
    rw [Real.log_mul two_ne_zero (Real.exp_pos (max a b)).ne', Real.log_exp]
  linarith

/-- Combined LSE bounds: max ≤ LSE ≤ max + log(2).
    Fundamental dequantization theorem connecting LSE to tropical max. -/
theorem lse_bounds (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) ∧
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 :=
  ⟨lse_ge_max a b, lse_le_max_add_log2 a b⟩

/-! ## Section 3: Exp Midpoint Convexity -/

/-- Exp midpoint: exp((a+b)/2) ≤ (exp(a)+exp(b))/2.
    The two-point Jensen inequality for exp (convexity). -/
theorem exp_midpoint_le (a b : ℝ) :
    Real.exp ((a + b) / 2) ≤ (Real.exp a + Real.exp b) / 2 := by
  have h1 : Real.exp (a / 2) * Real.exp (b / 2) ≤
      ((Real.exp (a / 2)) ^ 2 + (Real.exp (b / 2)) ^ 2) / 2 :=
    by nlinarith [sq_nonneg (Real.exp (a / 2) - Real.exp (b / 2))]
  have h2a : (Real.exp (a / 2)) ^ 2 = Real.exp a := by
    rw [pow_two, ← Real.exp_add (a / 2) (a / 2)]; congr 1; ring
  have h2b : (Real.exp (b / 2)) ^ 2 = Real.exp b := by
    rw [pow_two, ← Real.exp_add (b / 2) (b / 2)]; congr 1; ring
  rw [h2a, h2b] at h1
  have h3 : Real.exp (a / 2) * Real.exp (b / 2) = Real.exp ((a + b) / 2) := by
    have : (a + b) / 2 = a / 2 + b / 2 := by ring
    rw [this, ← Real.exp_add]
  calc Real.exp ((a + b) / 2)
      = Real.exp (a / 2) * Real.exp (b / 2) := h3.symm
    _ ≤ (Real.exp a + Real.exp b) / 2 := h1

/-- Exp monotonicity (re-export). -/
theorem exp_mono_consequence (a b : ℝ) (h : a ≤ b) :
    Real.exp a ≤ Real.exp b := Real.exp_le_exp.mpr h

/-- Exp positivity (re-export). -/
theorem exp_pos_consequence (x : ℝ) : (0 : ℝ) < Real.exp x := Real.exp_pos x

end ConvexTropicalBridge
