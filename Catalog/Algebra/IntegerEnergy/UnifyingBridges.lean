import Mathlib

/-! # CatalogBuild.Computation.Oracles.UnifyingBridges

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6
-/

/-- [Section: # CatalogBuild.Computation.Oracles.UnifyingBridges
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6] -/
theorem bridge_arith_comb (n : ℕ) :
    ∑ i ∈ range n, (i + 1) = (n + 1).choose 2 := by
      exact Eq.symm ( Nat.recOn n ( by norm_num ) fun k hk ↦ by rw [ Nat.choose_succ_succ ] ; simp +arith +decide [ Finset.sum_range_succ, hk ] )

/-- [Section: # CatalogBuild.Computation.Oracles.UnifyingBridges
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6] -/
theorem number_as_choose (k : ℕ) : k = k.choose 1 := by
  norm_num +zetaDelta at *

theorem choose_factorial_identity (n k : ℕ) (hk : k ≤ n) :
    n.choose k * k.factorial = n.factorial / (n - k).factorial := by
      rw [ ← Nat.choose_mul_factorial_mul_factorial hk, mul_assoc, mul_comm ];
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left ( Nat.factorial_pos _ ) <| by ring )

theorem binomial_row_sum_bridge (n : ℕ) :
    ∑ k ∈ range (n + 1), n.choose k = 2 ^ n := by
      rw [ Nat.sum_range_choose ]

theorem euler_totient_sum (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, Nat.totient d = n := by
      exact Nat.sum_totient n

theorem geometric_series_int (r : ℤ) (n : ℕ) :
    (r - 1) * ∑ i ∈ range n, r ^ i = r ^ n - 1 := by
      rw [ mul_comm, geom_sum_mul ]