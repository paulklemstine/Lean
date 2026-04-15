/-! # CatalogBuild.Computation.Oracles.ArithmeticBridges

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10
-/

import Mathlib

/-- [Section: ## Section 1: Sum Identities — The Discrete Foundation] -/
theorem oracle_gauss_sum (n : ℕ) :
    2 * ∑ i ∈ range (n + 1), i = n * (n + 1) := by
  induction' n with n ih <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


theorem oracle_sum_squares (n : ℕ) :
    6 * ∑ i ∈ range (n + 1), i ^ 2 = n * (n + 1) * (2 * n + 1) := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


theorem oracle_nicomachus (n : ℕ) :
    4 * ∑ i ∈ range (n + 1), i ^ 3 = (n * (n + 1)) ^ 2 := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


/-- [Section: ## Section 2: Geometric Series — Bridge to Analysis] -/
theorem oracle_geometric_sum (r : ℤ) (n : ℕ) (hr : r ≠ 1) :
    (r - 1) * ∑ i ∈ range (n + 1), r ^ i = r ^ (n + 1) - 1 := by
  rw [ mul_comm, geom_sum_mul ]


/-- [Section: ## Section 3: Modular Arithmetic Bridges] -/
theorem oracle_chinese_remainder (m n a b : ℕ) (hm : m > 0) (hn : n > 0)
    (hcoprime : Nat.Coprime m n) :
    ∃ x, x % m = a % m ∧ x % n = b % n := by
  have := Nat.chineseRemainder hcoprime;
  exact ⟨ _, this a b |>.2 ⟩


theorem oracle_totient_multiplicative (m n : ℕ) (hcoprime : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n := by
  exact Nat.totient_mul hcoprime


/-- [Section: ## Section 4: Divisor Sum Identities] -/
theorem oracle_divisors_of_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.divisors p = {1, p} := by
  exact hp.divisors


theorem oracle_divisor_sum_prime (p : ℕ) (hp : Nat.Prime p) :
    ∑ d ∈ Nat.divisors p, d = p + 1 := by
  rw [ hp.sum_divisors, add_comm ]


/-- [Section: ## Section 5: Binomial Theorem — The Combinatorial Bridge] -/
theorem oracle_pascal (n k : ℕ) (hk : k ≤ n) (hk0 : k ≥ 1) :
    Nat.choose (n + 1) k = Nat.choose n k + Nat.choose n (k - 1) := by
  cases k <;> simp_all +arith +decide [ Nat.choose ]


theorem oracle_vandermonde (m n r : ℕ) :
    Nat.choose (m + n) r = ∑ k ∈ range (r + 1), Nat.choose m k * Nat.choose n (r - k) := by
  rw [ Nat.add_choose_eq ];
  rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ fun i j => Nat.choose m i * Nat.choose n j ]
