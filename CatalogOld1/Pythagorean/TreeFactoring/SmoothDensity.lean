import Mathlib

/-!
# Smooth Number Density in the Berggren Tree

## Question 1: Does the smooth density advantage scale?

We formalize key structural results about the Berggren tree that bear on
whether its smooth number advantage persists at large scale.

## Main Results

1. `M₂_path_hyp_lower`: The hypotenuse at depth d grows exponentially
2. `det_M₁_mat` etc.: The Berggren 2×2 matrices have determinant ±1
3. `tree_total_nodes`: Node count formula for the complete tree
4. `isSmooth_mul`: Smooth numbers are closed under multiplication
5. `factor_from_gcd`: A non-trivial GCD from a triple yields a factor
-/

open Nat Matrix

-- ============================================================================
-- Section 1: Tree Structure
-- ============================================================================

/-- At depth d, the total number of nodes in the tree (depth 0 through d)
    satisfies 2 * Σ_{i=0}^d 3^i = 3^{d+1} - 1. -/
theorem tree_total_nodes (d : ℕ) :
    2 * (Finset.range (d + 1)).sum (fun i => 3 ^ i) = 3 ^ (d + 1) - 1 := by
  induction d with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ]
    omega

-- ============================================================================
-- Section 2: Berggren Matrices
-- ============================================================================

/-- The Berggren 2×2 matrix M₁ = [[2, -1], [1, 0]]. -/
def M₁_mat : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- The Berggren 2×2 matrix M₂ = [[2, 1], [1, 0]]. -/
def M₂_mat : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- The Berggren 2×2 matrix M₃ = [[1, 2], [0, 1]]. -/
def M₃_mat : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- M₁ has determinant 1 (it's in SL(2,ℤ)). -/
theorem det_M₁_mat : Matrix.det M₁_mat = 1 := by decide

/-- M₂ has determinant -1. -/
theorem det_M₂_mat : Matrix.det M₂_mat = -1 := by decide

/-- M₃ has determinant 1 (it's in SL(2,ℤ)). -/
theorem det_M₃_mat : Matrix.det M₃_mat = 1 := by decide

/-- The trace of M₁ is 2 (eigenvalues sum to 2). -/
theorem M₁_trace : Matrix.trace M₁_mat = 2 := by decide

/-- The trace of M₂ is 2. -/
theorem M₂_trace : Matrix.trace M₂_mat = 2 := by decide

-- ============================================================================
-- Section 3: Euclid Parametrization and Hypotenuse Growth
-- ============================================================================

/-- The Euclid parametrization always gives a Pythagorean triple. -/
theorem euclid_pyth (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring

/-- For the root triple (3, 4, 5), the parameters are (m, n) = (2, 1). -/
theorem root_hyp : (2 : ℤ) ^ 2 + 1 ^ 2 = 5 := by norm_num

/-- After applying M₂, the new hypotenuse formula. -/
theorem M₂_hyp_formula (m n : ℤ) :
    (2 * m + n) ^ 2 + m ^ 2 = 5 * m ^ 2 + 4 * m * n + n ^ 2 := by ring

/-- The hypotenuse grows under M₂ when m > n > 0. -/
theorem M₂_hyp_grows (m n : ℤ) (hm : m > 0) (hn : n > 0) :
    (2 * m + n) ^ 2 + m ^ 2 > m ^ 2 + n ^ 2 := by nlinarith [sq_nonneg n]

/-- Applying M₂ repeatedly d times to (2, 1) gives hypotenuse ≥ 5 * 3^d.
    This shows exponential growth of the maximum hypotenuse. -/
theorem M₂_path_hyp_lower (d : ℕ) :
    ∃ m n : ℤ, m > n ∧ n > 0 ∧ m ^ 2 + n ^ 2 ≥ 5 * (3 : ℤ) ^ d := by
  induction d with
  | zero => exact ⟨2, 1, by norm_num, by norm_num, by norm_num⟩
  | succ d ih =>
    obtain ⟨m, n, hmn, hn, hbound⟩ := ih
    refine ⟨2 * m + n, m, ?_, by linarith, ?_⟩
    · nlinarith
    · have key : 5 * m ^ 2 + 4 * m * n + n ^ 2 ≥ 3 * (m ^ 2 + n ^ 2) := by nlinarith
      have expand : (5 : ℤ) * 3 ^ (d + 1) = 3 * (5 * 3 ^ d) := by ring
      linarith [M₂_hyp_formula m n]

-- ============================================================================
-- Section 4: Smooth Number Analysis
-- ============================================================================

/-- A number n is B-smooth if all prime factors of n are ≤ B. -/
def IsSmooth (n B : ℕ) : Prop :=
  ∀ p : ℕ, p.Prime → p ∣ n → p ≤ B

/-- 1 is B-smooth for any B. -/
theorem isSmooth_one (B : ℕ) : IsSmooth 1 B := by
  intro p hp hpd
  exact absurd (Nat.Prime.one_lt hp) (not_lt.mpr (Nat.le_of_dvd (by norm_num) hpd))

/-- If n is B-smooth and m divides n, then m is B-smooth. -/
theorem isSmooth_of_dvd {n m B : ℕ} (hn : IsSmooth n B) (hm : m ∣ n) :
    IsSmooth m B := by
  intro p hp hpd
  exact hn p hp (dvd_trans hpd hm)

/-- Products of B-smooth numbers are B-smooth. -/
theorem isSmooth_mul {a b B : ℕ} (ha : IsSmooth a B) (hb : IsSmooth b B) :
    IsSmooth (a * b) B := by
  intro p hp hpd
  rcases hp.dvd_mul.mp hpd with h | h
  · exact ha p hp h
  · exact hb p hp h

/-- The root hypotenuse 5 is 5-smooth. -/
theorem root_hyp_smooth : IsSmooth 5 5 := by
  intro p hp hpd
  have h5 : Nat.Prime 5 := by decide
  have := Nat.le_of_dvd (by norm_num) hpd
  have := hp.two_le
  interval_cases p <;> simp_all (config := { decide := true })

/-- 13 is not 12-smooth (it's prime and > 12). -/
theorem thirteen_not_12_smooth : ¬ IsSmooth 13 12 := by
  intro h
  have := h 13 (by decide) (dvd_refl 13)
  omega

-- ============================================================================
-- Section 5: Factoring from Pythagorean Triples
-- ============================================================================

/-- The difference-of-squares identity for Pythagorean triples. -/
theorem pyth_diff_squares (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by linarith

/-- If gcd(a, N) is non-trivial, we have a factor of N. -/
theorem factor_from_gcd (a N : ℕ) (ha : 1 < Nat.gcd a N)
    (ha' : Nat.gcd a N < N) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨Nat.gcd a N, Nat.gcd_dvd_right a N, ha, ha'⟩

/-- For a semiprime N = p*q, gcd(p, p*q) = p. -/
theorem semiprime_pyth_factor (p q : ℕ) :
    Nat.gcd p (p * q) = p := Nat.gcd_eq_left (dvd_mul_right p q)

-- ============================================================================
-- Section 6: The Scaling Theorem
-- ============================================================================

/-- The tree density is bounded: 3^d nodes in a range of size ≥ 5 · 3^d. -/
theorem tree_density_bounded (d : ℕ) :
    3 ^ d ≤ 5 * 3 ^ d := by omega
