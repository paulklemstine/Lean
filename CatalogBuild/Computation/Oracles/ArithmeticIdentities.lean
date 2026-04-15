/-! # CatalogBuild.Computation.Oracles.ArithmeticIdentities

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 7
-/

import Mathlib

theorem gauss_sum (n : ℕ) :
    2 * ∑ i ∈ range n, (i + 1) = n * (n + 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Section 2: The Pyramid — Sum of Squares -/

/-
PROBLEM
Sum of squares: 1² + 2² + ... + n² = n(n+1)(2n+1)/6.
    Stated without division.

PROVIDED SOLUTION
Induction on n. Base trivial. Inductive step: expand and verify algebraically.
-/

theorem sum_squares (n : ℕ) :
    6 * ∑ i ∈ range n, (i + 1) ^ 2 = n * (n + 1) * (2 * n + 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Section 3: Nicomachus's Theorem — The Crown Jewel -/

/-
PROBLEM
Nicomachus's Theorem (c. 100 CE): The sum of the first n cubes
    equals the square of the sum of the first n natural numbers.
    1³ + 2³ + ... + n³ = (1 + 2 + ... + n)²
    This is one of the most beautiful identities in all of mathematics.

PROVIDED SOLUTION
Induction on n. Base trivial. Inductive step: 4*(sum + (n+1)^3) = (n*(n+1))^2 + 4*(n+1)^3 = (n+1)^2 * (n^2 + 4*(n+1)) = (n+1)^2 * (n+2)^2 = ((n+1)*(n+2))^2.
-/

theorem nicomachus (n : ℕ) :
    4 * ∑ i ∈ range n, (i + 1) ^ 3 = (n * (n + 1)) ^ 2 := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Section 4: The Bridge — Sum of Fourth Powers -/

/-
PROBLEM
Sum of fourth powers: connects to all lower power sums.
    1⁴ + 2⁴ + ... + n⁴ = n(n+1)(2n+1)(3n²+3n-1)/30

PROVIDED SOLUTION
Induction on n. Base case n=0: both sides are 0. Inductive step: verify algebraically that adding 30*(n+1)^4 to n*(n+1)*(2n+1)*(3n^2+3n-1) gives (n+1)*(n+2)*(2n+3)*(3(n+1)^2+3(n+1)-1). Use ring or omega after expanding.
-/

theorem sum_fourth_powers (n : ℕ) :
    30 * ∑ i ∈ range n, (i + 1) ^ 4 = n * (n + 1) * (2 * n + 1) * (3 * n ^ 2 + 3 * n - 1) := by
      induction n <;> norm_num [ Finset.sum_range_succ ] at *;
      cases ‹ℕ› <;> norm_num [ Nat.mul_succ, pow_succ' ] at * ; linarith!;

/-! ## Section 5: The Alternating Sum — A Hidden Symmetry -/

/-
PROBLEM
The alternating sum of squares has a beautiful closed form:
    1² - 2² + 3² - 4² + ... + (-1)^(n-1) · n² = (-1)^(n-1) · n(n+1)/2
    Equivalently: the alternating sum of squares equals ± the Gauss sum!

PROVIDED SOLUTION
Induction on n. Base case n=0: both sides 0. Inductive step: split on parity of n, use (-1)^n to flip signs.
-/

theorem alternating_sum_squares (n : ℕ) :
    2 * (∑ i ∈ range n, ((-1 : ℤ) ^ i * (↑i + 1) ^ 2)) =
    (-1 : ℤ) ^ (n + 1) * (↑n * (↑n + 1)) := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ, pow_succ' ] ; ring;
      grind

/-! ## Section 6: The Pentagonal Bridge -/

/-
PROBLEM
A less well-known identity: the sum of products of consecutive integers.
    ∑ i(i+1) = n(n+1)(n+2)/3

PROVIDED SOLUTION
Induction on n. Base trivial. Inductive step: 3*(sum + (n+1)*(n+2)) = n*(n+1)*(n+2) + 3*(n+1)*(n+2) = (n+1)*(n+2)*(n+3).
-/

theorem sum_consecutive_products (n : ℕ) :
    3 * ∑ i ∈ range n, ((i + 1) * (i + 2)) = n * (n + 1) * (n + 2) := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ ] ; linarith

/-! ## Section 7: Power Sum Recurrence — The Ladder -/

/-
PROBLEM
The sum of k-th powers can be related to lower power sums via
    the "telescope" identity. Here we show the simplest case:
    ∑(i+1)³ - ∑i³ = (n+1)³ - 1, which expands to give
    3·∑i² + 3·∑i + n = (n+1)³ - 1.
    This is how sum of squares can be derived from Gauss's sum!

PROVIDED SOLUTION
Induction on n. Base case n=0: LHS = 0+0+0 = 0, RHS = 1-1 = 0. Inductive step: add 3*(n+1)^2 + 3*(n+1) + 1 to both sides and verify the algebra works out.
-/

theorem power_sum_telescope (n : ℕ) :
    3 * ∑ i ∈ range n, (i + 1) ^ 2 + 3 * ∑ i ∈ range n, (i + 1) + n =
    (n + 1) ^ 3 - 1 := by
      exact eq_tsub_of_add_eq <| by induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith;
