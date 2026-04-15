/-! # CatalogBuild.Computation.Oracles.ArithmeticIdentities

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 7
-/

import Mathlib

/-- [Section: ## Section 1: The Gauss Sum — Foundation of All That Follows] -/
theorem gauss_sum (n : ℕ) :
    2 * ∑ i ∈ range n, (i + 1) = n * (n + 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


/-- [Section: ## Section 2: The Pyramid — Sum of Squares] -/
theorem sum_squares (n : ℕ) :
    6 * ∑ i ∈ range n, (i + 1) ^ 2 = n * (n + 1) * (2 * n + 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


/-- [Section: ## Section 3: Nicomachus's Theorem — The Crown Jewel] -/
theorem nicomachus (n : ℕ) :
    4 * ∑ i ∈ range n, (i + 1) ^ 3 = (n * (n + 1)) ^ 2 := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


/-- [Section: ## Section 4: The Bridge — Sum of Fourth Powers] -/
theorem sum_fourth_powers (n : ℕ) :
    30 * ∑ i ∈ range n, (i + 1) ^ 4 = n * (n + 1) * (2 * n + 1) * (3 * n ^ 2 + 3 * n - 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at *;
      cases ‹ℕ› <;> norm_num [ Nat.mul_succ, pow_succ' ] at * ; linarith!;


/-- [Section: ## Section 5: The Alternating Sum — A Hidden Symmetry] -/
theorem alternating_sum_squares (n : ℕ) :
    2 * (∑ i ∈ range n, ((-1 : ℤ) ^ i * (↑i + 1) ^ 2)) =
    (-1 : ℤ) ^ (n + 1) * (↑n * (↑n + 1)) := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ, pow_succ' ] ; ring;
      grind


/-- [Section: ## Section 6: The Pentagonal Bridge] -/
theorem sum_consecutive_products (n : ℕ) :
    3 * ∑ i ∈ range n, ((i + 1) * (i + 2)) = n * (n + 1) * (n + 2) := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ ] ; linarith


/-- [Section: ## Section 7: Power Sum Recurrence — The Ladder] -/
theorem power_sum_telescope (n : ℕ) :
    3 * ∑ i ∈ range n, (i + 1) ^ 2 + 3 * ∑ i ∈ range n, (i + 1) + n =
    (n + 1) ^ 3 - 1 := by
      exact eq_tsub_of_add_eq <| by induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith;
