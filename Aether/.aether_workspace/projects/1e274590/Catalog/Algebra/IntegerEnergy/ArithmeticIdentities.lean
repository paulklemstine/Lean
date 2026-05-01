import Mathlib

/-! # CatalogBuild.Computation.Oracles.ArithmeticIdentities

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 7
-/

/-- [Section: # CatalogBuild.Computation.Oracles.ArithmeticIdentities
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 7] -/
theorem gauss_sum (n : ℕ) :
    2 * ∑ i ∈ range n, (i + 1) = n * (n + 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-- [Section: # CatalogBuild.Computation.Oracles.ArithmeticIdentities
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 7] -/
theorem sum_squares (n : ℕ) :
    6 * ∑ i ∈ range n, (i + 1) ^ 2 = n * (n + 1) * (2 * n + 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

theorem nicomachus (n : ℕ) :
    4 * ∑ i ∈ range n, (i + 1) ^ 3 = (n * (n + 1)) ^ 2 := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

theorem sum_fourth_powers (n : ℕ) :
    30 * ∑ i ∈ range n, (i + 1) ^ 4 = n * (n + 1) * (2 * n + 1) * (3 * n ^ 2 + 3 * n - 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at *;
      cases ‹ℕ› <;> norm_num [ Nat.mul_succ, pow_succ' ] at * ; linarith!;

theorem alternating_sum_squares (n : ℕ) :
    2 * (∑ i ∈ range n, ((-1 : ℤ) ^ i * (↑i + 1) ^ 2)) =
    (-1 : ℤ) ^ (n + 1) * (↑n * (↑n + 1)) := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ, pow_succ' ] ; ring;
      grind

theorem sum_consecutive_products (n : ℕ) :
    3 * ∑ i ∈ range n, ((i + 1) * (i + 2)) = n * (n + 1) * (n + 2) := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ ] ; linarith

theorem power_sum_telescope (n : ℕ) :
    3 * ∑ i ∈ range n, (i + 1) ^ 2 + 3 * ∑ i ∈ range n, (i + 1) + n =
    (n + 1) ^ 3 - 1 := by
      exact eq_tsub_of_add_eq <| by induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith;