/-! # CatalogBuild.Computation.Oracles.ArithmeticBridges

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10
-/

import Mathlib

theorem oracle_gauss_sum (n : ℕ) :
    2 * ∑ i ∈ range (n + 1), i = n * (n + 1) := by
  induction' n with n ih <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-
Sum of squares formula. The quadratic layer of arithmetic.
-/

theorem oracle_sum_squares (n : ℕ) :
    6 * ∑ i ∈ range (n + 1), i ^ 2 = n * (n + 1) * (2 * n + 1) := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-
Nicomachus's Theorem: The sum of cubes equals the square of the sum.
    A miraculous bridge between cubic and quadratic structure.
-/

theorem oracle_nicomachus (n : ℕ) :
    4 * ∑ i ∈ range (n + 1), i ^ 3 = (n * (n + 1)) ^ 2 := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Section 2: Geometric Series — Bridge to Analysis -/

/-
Finite geometric series: the discrete precursor of analytic continuation.
    Connection to RH: The zeta function IS a geometric series in disguise.
-/

theorem oracle_geometric_sum (r : ℤ) (n : ℕ) (hr : r ≠ 1) :
    (r - 1) * ∑ i ∈ range (n + 1), r ^ i = r ^ (n + 1) - 1 := by
  rw [ mul_comm, geom_sum_mul ]

/-! ## Section 3: Modular Arithmetic Bridges -/

/-
The Chinese Remainder Theorem (existence part):
    If gcd(m,n) = 1, then for any a, b, there exists x with
    x ≡ a (mod m) and x ≡ b (mod n).
    Connection to Langlands: CRT is the simplest case of "local-global" principles.
-/

theorem oracle_chinese_remainder (m n a b : ℕ) (hm : m > 0) (hn : n > 0)
    (hcoprime : Nat.Coprime m n) :
    ∃ x, x % m = a % m ∧ x % n = b % n := by
  have := Nat.chineseRemainder hcoprime;
  exact ⟨ _, this a b |>.2 ⟩

/-
Euler's totient multiplicativity: φ(mn) = φ(m)φ(n) when gcd(m,n) = 1.
    Connection to RH: The totient function's average behavior is controlled
    by the zeros of the zeta function.
-/

theorem oracle_totient_multiplicative (m n : ℕ) (hcoprime : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n := by
  exact Nat.totient_mul hcoprime

/-! ## Section 4: Divisor Sum Identities -/

/-
The number of divisors of a prime is exactly 2.
-/

theorem oracle_divisors_of_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.divisors p = {1, p} := by
  exact hp.divisors

/-
The sum of divisors of p is p + 1 for prime p.
    Connection to BSD: Perfect numbers (σ(n) = 2n) are connected to
    Mersenne primes, which are connected to the distribution of primes.
-/

theorem oracle_divisor_sum_prime (p : ℕ) (hp : Nat.Prime p) :
    ∑ d ∈ Nat.divisors p, d = p + 1 := by
  rw [ hp.sum_divisors, add_comm ]

/-! ## Section 5: Binomial Theorem — The Combinatorial Bridge -/

/-
Pascal's identity: the recursive heart of binomial coefficients.
    Connection to P vs NP: Counting (combinatorics) is at the heart of
    computational complexity.
-/

theorem oracle_pascal (n k : ℕ) (hk : k ≤ n) (hk0 : k ≥ 1) :
    Nat.choose (n + 1) k = Nat.choose n k + Nat.choose n (k - 1) := by
  cases k <;> simp_all +arith +decide [ Nat.choose ]

/-
Vandermonde's identity: C(m+n, r) = Σ C(m,k) * C(n,r-k).
    A deep bridge between additive and multiplicative combinatorics.
-/

theorem oracle_vandermonde (m n r : ℕ) :
    Nat.choose (m + n) r = ∑ k ∈ range (r + 1), Nat.choose m k * Nat.choose n (r - k) := by
  rw [ Nat.add_choose_eq ];
  rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ fun i j => Nat.choose m i * Nat.choose n j ]
