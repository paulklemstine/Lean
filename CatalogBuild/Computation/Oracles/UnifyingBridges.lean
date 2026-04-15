/-! # CatalogBuild.Computation.Oracles.UnifyingBridges

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6
-/

import Mathlib

/-- [Section: ## Bridge 1: Arithmetic ↔ Combinatorics
The sum of the first n natural numbers equals C(n+1, 2).
Power sums are polynomials in binomial coefficients!] -/
theorem bridge_arith_comb (n : ℕ) :
    ∑ i ∈ range n, (i + 1) = (n + 1).choose 2 := by
      exact Eq.symm ( Nat.recOn n ( by norm_num ) fun k hk ↦ by rw [ Nat.choose_succ_succ ] ; simp +arith +decide [ Finset.sum_range_succ, hk ] )


theorem number_as_choose (k : ℕ) : k = k.choose 1 := by
  norm_num +zetaDelta at *


/-- [Section: ## Bridge 2: Combinatorics ↔ Divisibility
Binomial coefficients are integers. This means that n!/(k!(n-k)!)
is always a whole number — a deep divisibility statement.] -/
theorem choose_factorial_identity (n k : ℕ) (hk : k ≤ n) :
    n.choose k * k.factorial = n.factorial / (n - k).factorial := by
      rw [ ← Nat.choose_mul_factorial_mul_factorial hk, mul_assoc, mul_comm ];
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left ( Nat.factorial_pos _ ) <| by ring )


/-- [Section: ## Bridge 4: The Binomial Theorem — The Master Bridge
The binomial theorem connects algebra to combinatorics.
(x + y)^n = ∑ C(n,k) x^k y^(n-k)
This single identity generates ALL row sums, alternating sums,
and derivative identities of binomial coefficients.] -/
theorem binomial_row_sum_bridge (n : ℕ) :
    ∑ k ∈ range (n + 1), n.choose k = 2 ^ n := by
      rw [ Nat.sum_range_choose ]


/-- [Section: ## Bridge 5: The Euler Phi Bridge
Euler's totient function φ(n) counts integers ≤ n coprime to n.
∑_{d|n} φ(d) = n — divisibility, counting, and arithmetic unite!] -/
theorem euler_totient_sum (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, Nat.totient d = n := by
      exact Nat.sum_totient n


/-- [Section: ## Bridge 6: Geometric Series — Discrete Meets Continuous
The geometric series formula bridges finite sums to algebra,
and in the limit, to analysis.] -/
theorem geometric_series_int (r : ℤ) (n : ℕ) :
    (r - 1) * ∑ i ∈ range n, r ^ i = r ^ n - 1 := by
      rw [ mul_comm, geom_sum_mul ]
