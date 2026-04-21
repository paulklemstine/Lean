/-! # CatalogBuild.Pythagorean.Research.ComplexityBounds

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 15
-/

import Mathlib

/-- Each descent step reduces the hypotenuse by at least 2. -/
theorem descent_reduces_hyp_by_2 (a b c : ℤ) (ha : 1 ≤ a) (hb : 1 ≤ b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2*a - 2*b + 3*c ≤ c - 2 := by nlinarith [sq_nonneg (a + b - c)]




/-- The parent hypotenuse is strictly less than the child's. -/
theorem descent_hyp_lt (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2*a - 2*b + 3*c < c := by nlinarith [sq_nonneg (a + b - c)]




/-- The parent hypotenuse is positive. -/
theorem descent_hyp_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2*a - 2*b + 3*c := by nlinarith [sq_nonneg (a - b), sq_nonneg (3*c - 2*(a + b))]




/-- For balanced triples (a = b), the descent formula. -/
theorem balanced_descent_ratio (a c : ℤ) :
    -2*a - 2*a + 3*c = 3*c - 4*a := by ring




/-- For odd prime p ≥ 5, Berggren depth = (p-3)/2. -/
theorem trivial_triple_depth_prime (p : ℕ) (hp5 : 5 ≤ p) (hodd : p % 2 = 1) :
    (p + 1) / 2 - 2 = (p - 3) / 2 := by omega




/-- Depth ≤ p (so O(N) for N = p). -/
theorem trivial_depth_linear (p : ℕ) (hp5 : 5 ≤ p) :
    (p - 3) / 2 ≤ p := by omega




/-- Depth ≥ 1 for p ≥ 5. -/
theorem trivial_depth_positive (p : ℕ) (hp5 : 5 ≤ p) :
    1 ≤ (p - 3) / 2 := by omega




/-- Non-trivial pair product identity. -/
theorem semiprime_nontrivial_pair (p q : ℕ) :
    p * (p * q ^ 2) = (p * q) ^ 2 := by ring




/-- Non-trivial triple identity (over ℤ). -/
theorem nontrivial_triple_params (p q : ℤ) (hodd_p : p % 2 = 1) (hodd_q : q % 2 = 1) :
    (p * q) ^ 2 + ((q ^ 2 - p ^ 2) / 2) ^ 2 = ((q ^ 2 + p ^ 2) / 2) ^ 2 := by
  have hd : (2 : ℤ) ∣ (q ^ 2 - p ^ 2) := by
    have : q ^ 2 - p ^ 2 = (q - p) * (q + p) := by ring
    rw [this]; exact dvd_mul_of_dvd_left (by omega) _
  have hs : (2 : ℤ) ∣ (q ^ 2 + p ^ 2) := by
    have : q ^ 2 + p ^ 2 = (q - p) * (q + p) + 2 * p ^ 2 := by ring
    rw [this]; exact dvd_add (dvd_mul_of_dvd_left (by omega) _) (dvd_mul_right 2 _)
  have := Int.ediv_mul_cancel hd
  have := Int.ediv_mul_cancel hs
  nlinarith




/-- Non-trivial hypotenuse ≤ trivial hypotenuse. -/
theorem nontrivial_smaller_hyp (p q : ℤ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    q ^ 2 + p ^ 2 ≤ (p * q) ^ 2 := by nlinarith [sq_nonneg (p * q - p), sq_nonneg (p * q - q)]




/-- Exact reduction amount. -/
theorem hyp_reduction_exact (a b c : ℤ) :
    c - (-2*a - 2*b + 3*c) = 2*a + 2*b - 2*c := by ring




/-- Trivial triple identity (over ℤ). -/
theorem trivial_hyp_value_int (N : ℤ) (hN : N % 2 = 1) :
    N ^ 2 + ((N ^ 2 - 1) / 2) ^ 2 = ((N ^ 2 + 1) / 2) ^ 2 := by
  have h1 : (2 : ℤ) ∣ (N ^ 2 - 1) := by
    have : N ^ 2 - 1 = (N - 1) * (N + 1) := by ring
    rw [this]; exact dvd_mul_of_dvd_left (by omega) _
  have h2 : (2 : ℤ) ∣ (N ^ 2 + 1) := by
    have : N ^ 2 + 1 = (N - 1) * (N + 1) + 2 := by ring
    rw [this]; exact dvd_add (dvd_mul_of_dvd_left (by omega) _) (dvd_refl 2)
  have := Int.ediv_mul_cancel h1
  have := Int.ediv_mul_cancel h2
  nlinarith




/-- Consecutive-parameter descent: B₁⁻¹ reduces m by 1. -/
theorem consecutive_param_descent (k : ℤ) :
    let m := k + 1
    let a := m ^ 2 - k ^ 2
    let b := 2 * m * k
    let c := m ^ 2 + k ^ 2
    (a + 2*b - 2*c) = k ^ 2 - (k - 1) ^ 2 ∧
    (-2*a - 2*b + 3*c) = k ^ 2 + (k - 1) ^ 2 := by
  constructor <;> ring




/-- Depth bounds for primes. -/
theorem prime_descent_is_linear (p : ℕ) (hp : 5 ≤ p) (hodd : p % 2 = 1) :
    (p - 3) / 2 ≥ 1 ∧ (p - 3) / 2 ≤ p / 2 := by omega




/-- Simple bound for semiprime depth. -/
theorem semiprime_optimal_start (p q : ℕ) :
    q - p ≤ q := Nat.sub_le q p



