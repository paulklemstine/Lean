/-! # CatalogBuild.Computation.Oracles.CombinatorialBridges

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 7
-/

import Mathlib

/-- [Section: ## Section 1: Triangular Numbers = Binomial Coefficients] -/
theorem triangular_eq_choose (n : ℕ) :
    ∑ i ∈ range n, (i + 1) = (n + 1).choose 2 := by
      exact Eq.symm ( Nat.recOn n ( by norm_num ) fun n ih ↦ by rw [ Nat.choose_succ_succ ] ; simp +arith +decide [ Finset.sum_range_succ ] at * ; linarith )


/-- [Section: ## Section 2: The Hockey Stick Identity] -/
theorem hockey_stick (r n : ℕ) :
    ∑ i ∈ range (n + 1), (r + i).choose r = (r + n + 1).choose (r + 1) := by
      induction' n with n ih generalizing r <;> simp_all +arith +decide [ Nat.choose, add_comm, add_left_comm, Finset.sum_range_succ ]


/-- [Section: ## Section 3: Row Sum of Pascal's Triangle] -/
theorem pascal_row_sum (n : ℕ) :
    ∑ k ∈ range (n + 1), n.choose k = 2 ^ n := by
      rw [ Nat.sum_range_choose ]


/-- [Section: ## Section 4: Alternating Row Sum Vanishes] -/
theorem alternating_row_sum (n : ℕ) (hn : 0 < n) :
    ∑ k ∈ range (n + 1), ((-1 : ℤ) ^ k * ↑(n.choose k)) = 0 := by
      exact mod_cast by erw [ Int.alternating_sum_range_choose ] ; aesop;


/-- [Section: ## Section 5: The Divisibility-Combinatorics Bridge] -/
theorem consecutive_product_div_factorial (n k : ℕ) (hk : k ≤ n) :
    k.factorial ∣ ∏ i ∈ range k, (n - i) := by
      -- We'll use the fact that $\prod_{i=0}^{k-1} (n-i)$ is the product of $k$ consecutive integers, which is known to be divisible by $k!$.
      have h_prod_div : ∏ i ∈ Finset.range k, (n - i) = Nat.descFactorial n k := by
        rw [ Nat.descFactorial_eq_prod_range ];
      exact h_prod_div ▸ Nat.factorial_dvd_descFactorial _ _


/-- [Section: ## Section 6: Symmetry of Binomial Coefficients] -/
theorem binomial_symmetry (n k : ℕ) (hk : k ≤ n) :
    n.choose k = n.choose (n - k) := by
      rw [ Nat.choose_symm hk ]


/-- [Section: ## Section 7: Sum of Squares of Binomial Coefficients] -/
theorem sum_binomial_squares (n : ℕ) :
    ∑ k ∈ range (n + 1), (n.choose k) ^ 2 = (2 * n).choose n := by
      rw [ two_mul, Nat.add_choose_eq ];
      rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ fun i j => Nat.choose n i * Nat.choose n j ];
      exact Finset.sum_congr rfl fun x hx => by rw [ sq, Nat.choose_symm ( Finset.mem_range_succ_iff.mp hx ) ] ;
