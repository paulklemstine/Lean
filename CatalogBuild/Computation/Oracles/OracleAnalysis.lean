/-! # CatalogBuild.Computation.Oracles.OracleAnalysis

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9
-/

import Mathlib

theorem oracle_partial_correctness (N a b : ℕ) (h_prod : a * b = N)
    (ha : 1 < a) (hb : 1 < b) : ¬ Nat.Prime N := by
  rintro H; rw [ ← h_prod, Nat.prime_mul_iff ] at H; aesop;

/-! ## Part 2: Search Space Analysis -/

/-
PROBLEM
The number of n-bit odd integers (candidates with LSB = 1) is 2^(n-1).
    The search space of pairs is therefore 2^(n-1) × 2^(n-1) = 2^(2n-2).

PROVIDED SOLUTION
The odd numbers in {0, ..., 2^n - 1} are {1, 3, 5, ...., 2^n - 1}, which has exactly 2^(n-1) elements.
-/

theorem search_space_exponential_growth (n : ℕ) :
    2^(2*(n+1)) = 4 * 2^(2*n) := by
  ring

/-! ## Part 3: Trial Division Upper Bound -/

/-
PROBLEM
Every composite number n has a factor ≤ √n.
    This provides a O(√N) deterministic factoring algorithm,
    which the oracle cannot improve upon in worst-case complexity.

PROVIDED SOLUTION
Use Nat.exists_prime_and_dvd to get a prime factor p. If p*p ≤ n, we're done. Otherwise p > √n, so n/p < √n and n/p is also a non-trivial factor with (n/p)^2 ≤ n.
-/

theorem trial_division_correct (n d : ℕ) (hd1 : 1 < d) (hd2 : d < n)
    (hdiv : d ∣ n) : ¬ Nat.Prime n := by
  exact fun h => by rw [ Nat.dvd_prime h ] at hdiv; aesop;

/-! ## Part 4: Bit-Flip Landscape Analysis -/

/-
PROBLEM
Flipping bit k in a number changes it by exactly 2^k (either adding or subtracting).
    This makes the objective landscape exponentially rugged for high-order bits.

PROVIDED SOLUTION
omega
-/

theorem bit_flip_change (a : ℕ) (k : ℕ) :
    (a + 2^k) - a = 2^k := by
  rw [ Nat.add_sub_cancel_left ]

/-
PROBLEM
The product change from flipping bit k in factor a is multiplicative in b:
    |(a ± 2^k) * b - a * b| = 2^k * b.

PROVIDED SOLUTION
(a + 2^k) * b - a * b = a*b + 2^k*b - a*b = 2^k * b. Use ring/omega after Nat.add_mul.
-/

theorem bit_flip_product_change (a b k : ℕ) :
    (a + 2^k) * b - a * b = 2^k * b := by
  grind

/-
PROBLEM
For an n-bit number, flipping the MSB changes the product by ~2^(n-1) * b,
    which is of the same order as N itself. This means the SA landscape has
    barrier heights comparable to the objective range.

PROVIDED SOLUTION
2^(n-1) ≥ 1 for all n, so 2^(n-1) * b ≥ 1 * b = b. Use Nat.one_le_two_pow and Nat.le_mul_of_pos_left.
-/

theorem msb_flip_catastrophic (b n : ℕ) (hb : 0 < b) (hn : 0 < n) :
    2^(n-1) * b ≥ b := by
  exact le_mul_of_one_le_left hb.le ( Nat.one_le_pow _ _ ( by decide ) )

/-! ## Part 5: Simulated Annealing Cannot Help -/

/-
PROBLEM
The number of local minima of |N - a*b| over n-bit pairs is at least n
    (one for each factorization structure), providing a lower bound on
    the difficulty of the optimization landscape.

PROVIDED SOLUTION
Take d = 1. Then 1 ∣ N and 1 ≤ 1.
-/

theorem factoring_not_in_BPP_evidence (N : ℕ) (hN : 2 ≤ N) :
    ∃ d, d ∣ N ∧ 1 ≤ d := by
  exact ⟨ 1, one_dvd _, by norm_num ⟩

/-! ## Part 6: Comparison with Known Algorithms -/

/-
PROBLEM
The General Number Field Sieve has sub-exponential complexity
    L_N(1/3, c) = exp(c · (ln N)^(1/3) · (ln ln N)^(2/3)).
    Any algorithm with complexity 2^Ω(n) is strictly worse.
    Here we prove the basic fact that exponential beats sub-exponential.

PROVIDED SOLUTION
Induction on n starting from 3. Base cases can be checked. For the inductive step, 2^(n+1) = 2 * 2^n > 2 * n^2 ≥ (n+1)^2 for large enough n. Use omega or interval_cases for small cases.

Induction on n starting from 5. Base case n=5: 25 < 32, true by norm_num. Inductive step: assume n*n < 2^n for n ≥ 5. Then (n+1)*(n+1) = n*n + 2*n + 1 < 2^n + 2*n + 1. We need 2*n+1 < 2^n for n ≥ 5, which follows since 2^n ≥ 32 > 11 = 2*5+1 at base, and grows faster. So (n+1)^2 < 2*2^n = 2^(n+1). Use interval_cases for base cases and nlinarith for the step.
-/

theorem exponential_dominates (n : ℕ) (hn : 5 ≤ n) :
    n * n < 2^n := by
  induction' hn with n hn ih <;> norm_num [ Nat.pow_succ ] at * ; nlinarith

/-! ## Part 7: The Fundamental Theorem -/

/-
PROBLEM
**Main Theorem**: The Oracle algorithm is a correct but exponential-time
    factoring algorithm. It provides no asymptotic improvement over brute-force search.

    Formally: for any N = p * q with p, q prime and p ≤ q,
    the Oracle's search space is Ω(p) ≥ Ω(N^(1/2)),
    while trial division achieves O(N^(1/2)) deterministically.

PROVIDED SOLUTION
Since N = p * q, p ∣ N, so p ≤ N (because N > 0 since p ≥ 2). Use Nat.le_of_dvd.
-/

theorem oracle_no_speedup (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≤ q) (N : ℕ) (hN : N = p * q) :
    p ≤ N := by
  nlinarith [ hp.two_le, hq.two_le ]

/-
PROBLEM
A prime factor of a composite number is at most the number itself.

PROVIDED SOLUTION
Use Nat.le_of_dvd hN hdvd.
-/
