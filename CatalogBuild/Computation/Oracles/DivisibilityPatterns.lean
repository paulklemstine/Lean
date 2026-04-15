/-! # CatalogBuild.Computation.Oracles.DivisibilityPatterns

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9
-/

import Mathlib

theorem two_consecutive_even (n : ℕ) : 2 ∣ n * (n + 1) := by
  exact even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] )

/-
PROBLEM
The product of any three consecutive integers is divisible by 6.

PROVIDED SOLUTION
Among three consecutive integers, one is divisible by 3 and at least one is even. So 2*3=6 divides the product. Can use n*(n+1)*(n+2) = 6 * C(n+2, 3).
-/

theorem three_consecutive_div_six (n : ℕ) : 6 ∣ n * (n + 1) * (n + 2) := by
  exact Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial )

/-! ## Section 2: The Sum-Divisibility Bridge -/

/-
PROBLEM
The sum of squares formula implies that n(n+1)(2n+1) is always
    divisible by 6. This is a "reverse bridge": we know the sum of
    squares is an integer, so the formula must be divisible.

PROVIDED SOLUTION
Among n, n+1, one is even. Among n, n+1, 2n+1, one is divisible by 3 (check n mod 3). Together with the factor of 2, we get 6 | n(n+1)(2n+1).
-/

theorem sum_sq_divisibility (n : ℕ) : 6 ∣ n * (n + 1) * (2 * n + 1) := by
  rw [ Nat.dvd_iff_mod_eq_zero ] ; norm_num [ Nat.add_mod, Nat.succ_eq_add_one, Nat.mul_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial;

/-
PROBLEM
n⁵ - n is always divisible by 30 for all natural numbers n.
    This follows from Fermat's little theorem applied to primes 2, 3, 5.

PROVIDED SOLUTION
n^5 - n = n(n^4-1) = n(n^2-1)(n^2+1) = (n-1)n(n+1)(n^2+1). Show 2|this, 3|this, 5|this by checking mod 2, mod 3, mod 5. Use omega or decide on ZMod.
-/

theorem fifth_power_minus_self (n : ℕ) : 30 ∣ (n ^ 5 - n : ℤ) := by
  exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.sub_emod, pow_succ, Int.mul_emod ] ; have := Int.emod_nonneg n ( by decide : ( 30 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos n ( by decide : 0 < ( 30 : ℤ ) ) ; interval_cases ( n % 30 : ℤ ) <;> trivial ) ;

/-! ## Section 3: Quadratic Residue Patterns -/

/-
PROBLEM
Every perfect square is congruent to 0 or 1 mod 4.
    This constrains which numbers can be perfect squares.

PROVIDED SOLUTION
n mod 2 is 0 or 1. If n=2k, n²=4k². If n=2k+1, n²=4k²+4k+1=4(k²+k)+1. Use omega after case splitting on n%2.
-/

theorem square_mod_four (n : ℕ) : n ^ 2 % 4 = 0 ∨ n ^ 2 % 4 = 1 := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> ring_nf <;> norm_num

/-
PROBLEM
Every perfect square is congruent to 0, 1, or 4 mod 8.

PROVIDED SOLUTION
Case split on n mod 4 (values 0,1,2,3). n=4k: n²=16k², mod 8 = 0. n=4k+1: n²=16k²+8k+1, mod 8 = 1. n=4k+2: n²=16k²+16k+4, mod 8 = 4. n=4k+3: n²=16k²+24k+9, mod 8 = 1. Use omega after case splitting.
-/

theorem square_mod_eight (n : ℕ) :
    n ^ 2 % 8 = 0 ∨ n ^ 2 % 8 = 1 ∨ n ^ 2 % 8 = 4 := by
      rw [ Nat.pow_mod ] ; have := Nat.mod_lt n ( by decide : 0 < 8 ) ; interval_cases n % 8 <;> trivial;

/-! ## Section 4: The Fibonacci-Divisibility Connection -/

/-
PROBLEM
Fibonacci numbers satisfy: F(m) divides F(n) whenever m divides n.
    This is a remarkable bridge between the additive structure of
    Fibonacci numbers and the multiplicative structure of divisibility.

PROVIDED SOLUTION
Use Nat.fib_dvd from Mathlib.
-/

theorem fib_dvd_fib (m n : ℕ) (hm : 0 < m) (hmn : m ∣ n) :
    Nat.fib m ∣ Nat.fib n := by
      exact?

/-! ## Section 5: Even and Odd Sum Patterns -/

/-
PROBLEM
The sum of the first n odd numbers equals n².

PROVIDED SOLUTION
Induction on n. Or observe that sum of first n odd numbers = 2*(0+1+...+(n-1)) + n = n(n-1) + n = n². Use Finset.sum_range_id_eq_sum_range_succ or similar.
-/

theorem sum_odd_eq_square (n : ℕ) :
    ∑ i ∈ range n, (2 * i + 1) = n ^ 2 := by
      induction n <;> simpa [ Finset.sum_range_succ ] using by linarith;

/-
PROBLEM
The sum of the first n even numbers equals n(n+1).

PROVIDED SOLUTION
Factor out 2: 2*∑(i+1) = 2*n(n+1)/2 = n(n+1). Or use induction.
-/

theorem sum_even (n : ℕ) :
    ∑ i ∈ range n, (2 * (i + 1)) = n * (n + 1) := by
      induction n <;> simpa [ Finset.sum_range_succ ] using by linarith;
