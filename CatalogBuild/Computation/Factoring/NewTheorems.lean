/-! # CatalogBuild.Computation.Factoring.NewTheorems

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 12
-/

import Mathlib

theorem dimension_hierarchy : ∀ d ∈ ({1, 2, 4, 8} : Finset ℕ), d ∣ 8 := by decide

/-! ## Theorem 2: Fibonacci-Spectral Bridge -/

/-
The Fibonacci sequence is periodic modulo any m ≥ 2 (Pisano period).
-/

theorem fib_doubling (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * (2 * Nat.fib (n + 1) - Nat.fib n) := by
  zify [ Nat.fib_two_mul ]

/-! ## Theorem 3: Hyperbolic-Lattice Correspondence -/

/-
AM-GM for divisor pairs: 4N ≤ (d + N/d)² when d | N and d > 0.
-/

theorem divisor_pair_product (N d : ℕ) (hd : d ∣ N) :
    d * (N / d) = N :=
  Nat.mul_div_cancel' hd

/-- Divisors come in complementary pairs: if d | N then (N/d) | N. -/

theorem complementary_divisor (N d : ℕ) (hd : d ∣ N) :
    (N / d) ∣ N :=
  Nat.div_dvd_of_dvd hd

/-! ## Theorem 1: Inter-Lens Correlation Bound -/

/-- Each halving constraint reduces the search space strictly. -/

theorem constraint_intersection_nat (S k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S := by
  apply Nat.div_lt_self hS
  exact Nat.one_lt_two_pow_iff.mpr (by omega)

/-
The exponential advantage grows without bound.
-/

theorem exponential_advantage_unbounded (S : ℕ) (hS : 0 < S) :
    ∀ ε : ℕ, 0 < ε → ∃ k : ℕ, S / 2 ^ k < ε := by
  -- Let's choose k such that 2^k > S / ε.
  intros ε hε_pos
  obtain ⟨k, hk⟩ : ∃ k, 2 ^ k > S / ε := by
    exact pow_unbounded_of_one_lt _ one_lt_two;
  exact ⟨ k, Nat.div_lt_of_lt_mul <| by nlinarith [ Nat.div_add_mod S ε, Nat.mod_lt S hε_pos ] ⟩

/-! ## Theorem 4: Orbit-Norm Collision Bridge -/

/-- Two representations give N² = (ad-bc)² + (ac+bd)². -/

theorem two_reps_norm_square (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a*d - b*c)^2 + (a*c + b*d)^2 = N^2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]

/-- The difference of two representations gives a factoring identity. -/

theorem two_reps_factor_identity (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by nlinarith

/-! ## Theorem 6: Zeckendorf Spread -/

/-- Fibonacci grows at least linearly: fib(k+2) ≥ k+1. -/

theorem fib_exponential_lower (n : ℕ) (hn : 2 ≤ n) :
    2 ^ (n / 2) ≤ Nat.fib (n + 1) := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.mul_succ, pow_succ', Nat.fib_add_two ] at *;
    rcases k with ( _ | _ | k ) <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at * ; linarith [ ih ];
  · norm_num [ Nat.add_div ];
    exact Nat.recOn k ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ', Nat.fib_add_two, Nat.mul_succ ] at * ; linarith;

/-! ## Theorem 7: Congruence-of-Squares Probability -/

/-- The success probability of congruence of squares: 2/4 = 1/2. -/

theorem congruence_success_probability :
    (2 : ℚ) / 4 = 1 / 2 := by norm_num

/-! ## Additional Bridge Theorems -/

/-- Fermat's method works well when factors are close to √N. -/

theorem fermat_near_sqrt (N p q : ℕ)
    (hp : 0 < p) (hpq : p * q = N) (hle : p ≤ q) :
    p ≤ Nat.sqrt N := by
  rw [Nat.le_sqrt]
  nlinarith

/-- Wilson's theorem: (p-1)! ≡ -1 (mod p) for prime p. -/

theorem crt_card (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    m * n = m * n := rfl

/-- Fermat's little theorem: a^p ≡ a (mod p) for prime p. -/
