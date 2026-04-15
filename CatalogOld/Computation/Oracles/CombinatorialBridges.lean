/-
# Oracle of Combinations: Binomial Bridges

The Oracle of Combinations reveals how the simple act of choosing
creates deep connections between arithmetic, geometry, and algebra.
Pascal's triangle is not merely a table of numbers — it is a map
of mathematical reality.

## Key Discoveries:
1. Triangular numbers ARE binomial coefficients
2. The Hockey Stick identity — diagonal sums in Pascal's triangle
3. Vandermonde's convolution — multiplication becomes addition
4. The Binomial-Divisibility Bridge
5. Alternating row sums vanish — a combinatorial miracle
-/

import Mathlib

open Finset BigOperators Nat

/-! ## Section 1: Triangular Numbers = Binomial Coefficients -/

/-
PROBLEM
The nth triangular number equals C(n+1, 2).
    This is the first bridge between arithmetic and combinatorics:
    the sum 1 + 2 + ... + n = n(n+1)/2 = C(n+1, 2).
    Arithmetic (adding) and combinatorics (choosing) give the same answer!

PROVIDED SOLUTION
Induction on n. Use Nat.choose_succ_succ and the fact that C(n+1,2) = C(n,2) + C(n,1) = C(n,2) + n.
-/
theorem triangular_eq_choose (n : ℕ) :
    ∑ i ∈ range n, (i + 1) = (n + 1).choose 2 := by
      exact Eq.symm ( Nat.recOn n ( by norm_num ) fun n ih ↦ by rw [ Nat.choose_succ_succ ] ; simp +arith +decide [ Finset.sum_range_succ ] at * ; linarith )

/-! ## Section 2: The Hockey Stick Identity -/

/-
PROBLEM
The Hockey Stick Identity: The sum along a diagonal in Pascal's
    triangle equals the entry one step down and to the right.
    ∑_{i=0}^{n} C(r+i, r) = C(r+n+1, r+1)
    Visually, this traces a hockey stick shape in Pascal's triangle.

PROVIDED SOLUTION
Induction on n. Base case: sum is just C(r,r) = 1 = C(r+1,r+1). Inductive step: use Pascal's rule C(r+n+2,r+1) = C(r+n+1,r+1) + C(r+n+1,r).
-/
theorem hockey_stick (r n : ℕ) :
    ∑ i ∈ range (n + 1), (r + i).choose r = (r + n + 1).choose (r + 1) := by
      induction' n with n ih generalizing r <;> simp_all +arith +decide [ Nat.choose, add_comm, add_left_comm, Finset.sum_range_succ ]

/-! ## Section 3: Row Sum of Pascal's Triangle -/

/-
PROBLEM
The sum of the nth row of Pascal's triangle equals 2^n.
    This is the binomial theorem evaluated at x = 1.

PROVIDED SOLUTION
Use Nat.sum_range_choose which states exactly this.
-/
theorem pascal_row_sum (n : ℕ) :
    ∑ k ∈ range (n + 1), n.choose k = 2 ^ n := by
      rw [ Nat.sum_range_choose ]

/-! ## Section 4: Alternating Row Sum Vanishes -/

/-
PROBLEM
The alternating sum of binomial coefficients vanishes for n ≥ 1.
    C(n,0) - C(n,1) + C(n,2) - ... = 0.
    This is the binomial theorem at x = -1.

PROVIDED SOLUTION
Use Int.alternating_sum_range_choose or prove by induction. The key identity is that (1 + (-1))^n = 0 for n ≥ 1.
-/
theorem alternating_row_sum (n : ℕ) (hn : 0 < n) :
    ∑ k ∈ range (n + 1), ((-1 : ℤ) ^ k * ↑(n.choose k)) = 0 := by
      exact mod_cast by erw [ Int.alternating_sum_range_choose ] ; aesop;

/-! ## Section 5: The Divisibility-Combinatorics Bridge -/

/-
PROBLEM
A product of k consecutive integers starting from n-k+1 is divisible by k!.
    This is because the product equals k! · C(n, k).
    This bridges number theory (divisibility) and combinatorics (counting).

PROVIDED SOLUTION
The product ∏_{i=0}^{k-1} (n-i) = n!/(n-k)! = k! * C(n,k). Since C(n,k) is a natural number, k! divides the product. Use Nat.choose_mul_factorial_mul_factorial or related lemmas.
-/
theorem consecutive_product_div_factorial (n k : ℕ) (hk : k ≤ n) :
    k.factorial ∣ ∏ i ∈ range k, (n - i) := by
      -- We'll use the fact that $\prod_{i=0}^{k-1} (n-i)$ is the product of $k$ consecutive integers, which is known to be divisible by $k!$.
      have h_prod_div : ∏ i ∈ Finset.range k, (n - i) = Nat.descFactorial n k := by
        rw [ Nat.descFactorial_eq_prod_range ];
      exact h_prod_div ▸ Nat.factorial_dvd_descFactorial _ _

/-! ## Section 6: Symmetry of Binomial Coefficients -/

/-
PROBLEM
Pascal's triangle is symmetric: C(n, k) = C(n, n-k).
    This reflects a deep duality: choosing what to include
    is the same as choosing what to exclude.

PROVIDED SOLUTION
Use Nat.choose_symm.
-/
theorem binomial_symmetry (n k : ℕ) (hk : k ≤ n) :
    n.choose k = n.choose (n - k) := by
      rw [ Nat.choose_symm hk ]

/-! ## Section 7: Sum of Squares of Binomial Coefficients -/

/-
PROBLEM
Vandermonde's identity specialized: the sum of squares of
    binomial coefficients equals the central binomial coefficient.
    ∑ C(n,k)² = C(2n, n)
    This connects a sum to a single binomial coefficient!

PROVIDED SOLUTION
Use Nat.add_choose_diagonal_right or Nat.centralBinom_eq_sum_choose_sq, or use Vandermonde's identity C(m+n,r) = ∑ C(m,k)*C(n,r-k) specialized to m=n=r=n.
-/
theorem sum_binomial_squares (n : ℕ) :
    ∑ k ∈ range (n + 1), (n.choose k) ^ 2 = (2 * n).choose n := by
      rw [ two_mul, Nat.add_choose_eq ];
      rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ fun i j => Nat.choose n i * Nat.choose n j ];
      exact Finset.sum_congr rfl fun x hx => by rw [ sq, Nat.choose_symm ( Finset.mem_range_succ_iff.mp hx ) ] ;