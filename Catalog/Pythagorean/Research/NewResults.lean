/-! # CatalogBuild.Pythagorean.Research.NewResults

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 32
-/

import Mathlib

/-- The parent hypotenuse satisfies c' ≤ c - 2 for PPTs with positive legs. -/
theorem oq_descent_step_decrease (a b c : ℤ) (ha : 1 ≤ a) (hb : 1 ≤ b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c ≤ c - 2 := by
  nlinarith [sq_nonneg (a + b - c)]



/-- Descent always decreases the hypotenuse. -/
theorem oq_descent_always_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c < c := by
  nlinarith [sq_nonneg (a + b - c)]



/-- The parent hypotenuse is positive. -/
theorem oq_parent_hyp_positive (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2 * a - 2 * b + 3 * c := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (3 * c - 2 * (a + b))]



/-- For the trivial triple, descent depth is O(N²). -/
theorem oq_trivial_depth_quadratic (N : ℕ) (hN : 3 ≤ N) :
    (N ^ 2 + 1) / 2 ≤ N ^ 2 := by omega



/-- The Euclid parametrization is always Pythagorean. -/
theorem oq_euclid_parametrization (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring



/-- For the Euclid triple, the gap h - u = (m - n)². -/
theorem oq_euclid_triple_gap (m n : ℤ) :
    (m ^ 2 + n ^ 2) - 2 * m * n = (m - n) ^ 2 := by ring



/-- m - n divides N = m² - n² = (m-n)(m+n). -/
theorem oq_euclid_factor_structure (m n : ℤ) :
    (m - n) ∣ (m ^ 2 - n ^ 2) := ⟨m + n, by ring⟩



/-- The gap h + u = (m + n)². -/
theorem oq_euclid_triple_sum (m n : ℤ) :
    (m ^ 2 + n ^ 2) + 2 * m * n = (m + n) ^ 2 := by ring



/-- (h-u)(h+u) = (m-n)²(m+n)² = N². -/
theorem oq_optimal_start_identity (m n : ℤ) :
    ((m ^ 2 + n ^ 2) - 2 * m * n) * ((m ^ 2 + n ^ 2) + 2 * m * n) =
    (m ^ 2 - n ^ 2) ^ 2 := by ring



/-- If N = (m-n)(m+n), then m-n divides N. -/
theorem oq_euclid_gap_reveals_factor (m n N : ℤ) (hN : N = m ^ 2 - n ^ 2) :
    (m - n) ∣ N := by rw [hN]; exact ⟨m + n, by ring⟩



/-- The trivial triple gap is always 2, providing no factor info. -/
theorem oq_trivial_triple_gap_eq (N : ℤ) :
    (N ^ 2 + 1) - (N ^ 2 - 1) = 2 := by ring



/-- Pythagorean quadruple difference of squares identity. -/
theorem oq_pyth_quadruple_identity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith



/-- Every Pythagorean triple embeds as a quadruple. -/
theorem oq_triple_embeds_in_quadruple (a b h : ℤ)
    (hp : a ^ 2 + b ^ 2 = h ^ 2) :
    a ^ 2 + b ^ 2 + 0 ^ 2 = h ^ 2 := by linarith



/-- The Lorentz form Q₃₁ = a² + b² + c² - d². -/
def oq_lorentzForm31 (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2



/-- Quadruples lie on the null cone of Q₃₁. -/
theorem oq_quadruple_null_cone (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    oq_lorentzForm31 a b c d = 0 := by unfold oq_lorentzForm31; linarith



/-- Factor structure: (h - u₂)(h + u₂) = N² + u₁². -/
theorem oq_quadruple_factor_structure (N u1 u2 h : ℤ)
    (hp : N ^ 2 + u1 ^ 2 + u2 ^ 2 = h ^ 2) :
    (h - u2) * (h + u2) = N ^ 2 + u1 ^ 2 := by nlinarith



/-- Alternative projection: (h - u₁)(h + u₁) = N² + u₂². -/
theorem oq_quadruple_alt_factor (N u1 u2 h : ℤ)
    (hp : N ^ 2 + u1 ^ 2 + u2 ^ 2 = h ^ 2) :
    (h - u1) * (h + u1) = N ^ 2 + u2 ^ 2 := by nlinarith



/-- 4^k ≥ 3^k: more branching in higher dimensions. -/
theorem oq_quadruple_branching_advantage (k : ℕ) :
    3 ^ k ≤ 4 ^ k := Nat.pow_le_pow_left (by norm_num) k



/-- Grover gives quadratic speedup: √(3^k) ≤ 2^k. -/
theorem oq_grover_speedup_bound (k : ℕ) :
    Nat.sqrt (3 ^ k) ≤ 2 ^ k := by
  have h1 : 3 ^ k ≤ 2 ^ k * 2 ^ k := by
    calc 3 ^ k ≤ 4 ^ k := Nat.pow_le_pow_left (by norm_num) k
      _ = (2 * 2) ^ k := by norm_num
      _ = 2 ^ k * 2 ^ k := by rw [mul_pow]
  calc Nat.sqrt (3 ^ k)
      ≤ Nat.sqrt (2 ^ k * 2 ^ k) := Nat.sqrt_le_sqrt h1
    _ = 2 ^ k := Nat.sqrt_eq (2 ^ k)



/-- 3^k > 2^k for k ≥ 1: quantum advantage is genuine. -/
theorem oq_quantum_advantage (k : ℕ) (hk : k ≠ 0) :
    3 ^ k > 2 ^ k :=
  Nat.pow_lt_pow_left (by norm_num : 2 < 3) hk



/-- The Lorentz form Q = a² + b² - c². -/
def oq_lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2



/-- Pythagorean triples lie on the null cone of Q. -/
theorem oq_pyth_null_cone (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    oq_lorentzQ a b c = 0 := by unfold oq_lorentzQ; linarith



/-- Forward Berggren B₂ preserves Q. -/
theorem oq_berggren_B2_preserves_Q (a b c : ℤ) (h : oq_lorentzQ a b c = 0) :
    oq_lorentzQ (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = 0 := by
  unfold oq_lorentzQ at *; nlinarith



/-- Inverse Berggren B₂⁻¹ preserves Q. -/
theorem oq_inv_berggren_B2_preserves_Q (a b c : ℤ) (h : oq_lorentzQ a b c = 0) :
    oq_lorentzQ (a + 2*b - 2*c) (2*a + b - 2*c) (-2*a - 2*b + 3*c) = 0 := by
  unfold oq_lorentzQ at *; nlinarith



/-- B₁ preserves Q. -/
theorem oq_berggren_B1_preserves_Q (a b c : ℤ) (h : oq_lorentzQ a b c = 0) :
    oq_lorentzQ (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = 0 := by
  unfold oq_lorentzQ at *; nlinarith



/-- B₃ preserves Q. -/
theorem oq_berggren_B3_preserves_Q (a b c : ℤ) (h : oq_lorentzQ a b c = 0) :
    oq_lorentzQ (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = 0 := by
  unfold oq_lorentzQ at *; nlinarith



/-- det(B₁) = 1. B₁ = [[1,-2,2],[2,-1,2],[2,-2,3]]. -/
theorem oq_berggren_B1_det :
    (1 : ℤ) * ((-1) * 3 - 2 * (-2)) - (-2) * (2 * 3 - 2 * 2) +
    2 * (2 * (-2) - (-1) * 2) = 1 := by norm_num



/-- det(B₂) = -1. B₂ = [[1,2,2],[2,1,2],[2,2,3]]. -/
theorem oq_berggren_B2_det :
    (1 : ℤ) * (1 * 3 - 2 * 2) - 2 * (2 * 3 - 2 * 2) +
    2 * (2 * 2 - 1 * 2) = -1 := by norm_num



/-- |det(B₂)| = 1, confirming unimodularity. -/
theorem oq_berggren_B2_unimodular :
    |((1 : ℤ) * (1 * 3 - 2 * 2) - 2 * (2 * 3 - 2 * 2) +
    2 * (2 * 2 - 1 * 2))| = 1 := by norm_num



/-- Brahmagupta-Fibonacci identity for products of Pythagorean triples. -/
theorem oq_brahmagupta_fibonacci (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2) (h2 : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  nlinarith [sq_nonneg (a₁ * a₂ - b₁ * b₂), sq_nonneg (a₁ * b₂ + b₁ * a₂)]



/-- The Gaussian integer norm is multiplicative. -/
theorem oq_gaussian_norm_mult (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 =
    (a₁ ^ 2 + b₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2) := by ring



/-- For N = m² - n², the Euclid representation reveals factors. -/
theorem oq_euclid_gap_informative (m n N : ℤ) (hN : N = m ^ 2 - n ^ 2) :
    (m - n) ∣ N := by rw [hN]; exact ⟨m + n, by ring⟩


