/-
# The Grand Unification: Bridges Between Worlds

This is the culminating file of the Oracle Council's research.
Here we prove theorems that explicitly CONNECT the different
mathematical domains — showing that arithmetic, combinatorics,
divisibility, and symmetry are not separate subjects but
different views of a single mathematical reality.

## The Five Bridges:
1. Arithmetic ↔ Combinatorics: Power sums = Polynomial in binomial coefficients
2. Combinatorics ↔ Divisibility: Choosing implies dividing
3. Divisibility ↔ Symmetry: Fermat's little theorem as a symmetry principle
4. Symmetry ↔ Arithmetic: AM-GM controls power sums
5. The Grand Bridge: Sum-Product-Choose-Divide form a cycle
-/

import Mathlib

open Finset BigOperators Nat

/-! ## Bridge 1: Arithmetic ↔ Combinatorics

The sum of the first n natural numbers equals C(n+1, 2).
Power sums are polynomials in binomial coefficients! -/

/-
PROBLEM
The sum 1+2+...+n equals the binomial coefficient C(n+1,2).
    This is the fundamental arithmetic-combinatoric bridge.

PROVIDED SOLUTION
Same as triangular_eq_choose. Induction on n using Nat.choose_succ_succ.
-/
theorem bridge_arith_comb (n : ℕ) :
    ∑ i ∈ range n, (i + 1) = (n + 1).choose 2 := by
      exact Eq.symm ( Nat.recOn n ( by norm_num ) fun k hk ↦ by rw [ Nat.choose_succ_succ ] ; simp +arith +decide [ Finset.sum_range_succ, hk ] )

/-
PROBLEM
Each number k can be written as C(k,1).
    Combined with the hockey stick, this gives Gauss's formula.

PROVIDED SOLUTION
C(k,1) = k by definition. Use Nat.choose_one_right.
-/
theorem number_as_choose (k : ℕ) : k = k.choose 1 := by
  norm_num +zetaDelta at *

/-! ## Bridge 2: Combinatorics ↔ Divisibility

Binomial coefficients are integers. This means that n!/(k!(n-k)!)
is always a whole number — a deep divisibility statement. -/

/-
PROBLEM
The factored form: C(n,k) · k! = n! / (n-k)!.
    This is WHY binomial coefficients are integers.

PROVIDED SOLUTION
C(n,k) * k! = n! / ((n-k)! * k!) * k! = n! / (n-k)!. Use Nat.choose_mul_factorial_mul_factorial or Nat.choose_eq_factorial_div_factorial.
-/
theorem choose_factorial_identity (n k : ℕ) (hk : k ≤ n) :
    n.choose k * k.factorial = n.factorial / (n - k).factorial := by
      rw [ ← Nat.choose_mul_factorial_mul_factorial hk, mul_assoc, mul_comm ];
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left ( Nat.factorial_pos _ ) <| by ring )

/-! ## Bridge 3: Modular Arithmetic Patterns

Powers create cycles modulo primes. This connects
multiplication (arithmetic) to group theory (symmetry). -/

/-
PROBLEM
Fermat's Little Theorem: a^p ≡ a (mod p) for prime p.
    Exponentiation "wraps around" — it has a hidden periodicity.

PROVIDED SOLUTION
Use ZMod.intCast_zmod_eq_zero_iff_dvd or convert from Nat version. Key lemma: ZMod.natCast_self_eq_zero. Or use Int.emod_emod_of_dvd. Actually, use the Mathlib lemma directly - look for Int.ModEq or similar.
-/
theorem fermat_little (p : ℕ) (hp : Nat.Prime p) (a : ℕ) :
    (p : ℤ) ∣ ((a : ℤ) ^ p - (a : ℤ)) := by
      haveI := Fact.mk hp; simp +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;

/-! ## Bridge 4: The Binomial Theorem — The Master Bridge

The binomial theorem connects algebra to combinatorics.
(x + y)^n = ∑ C(n,k) x^k y^(n-k)
This single identity generates ALL row sums, alternating sums,
and derivative identities of binomial coefficients. -/

/-
PROBLEM
A consequence of the binomial theorem: setting x = y = 1 gives
    the row sum identity.

PROVIDED SOLUTION
Use Nat.sum_range_choose.
-/
theorem binomial_row_sum_bridge (n : ℕ) :
    ∑ k ∈ range (n + 1), n.choose k = 2 ^ n := by
      rw [ Nat.sum_range_choose ]

/-! ## Bridge 5: The Euler Phi Bridge

Euler's totient function φ(n) counts integers ≤ n coprime to n.
∑_{d|n} φ(d) = n — divisibility, counting, and arithmetic unite! -/

/-
PROBLEM
Euler's totient sum: the sum of φ(d) over all divisors d of n equals n.
    This is a bridge between multiplicative number theory and additive counting.

PROVIDED SOLUTION
Use Nat.sum_totient from Mathlib.
-/
theorem euler_totient_sum (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, Nat.totient d = n := by
      exact Nat.sum_totient n

/-! ## Bridge 6: Geometric Series — Discrete Meets Continuous

The geometric series formula bridges finite sums to algebra,
and in the limit, to analysis. -/

/-
PROBLEM
Finite geometric series: (r - 1) · ∑ r^i = r^n - 1.

PROVIDED SOLUTION
Use geom_sum_mul or Finset.geom_sum_mul: (r-1) * ∑ r^i = r^n - 1. Or induction: base n=0 trivial, step: (r-1)*(...+r^n) = r^n - 1 + (r-1)*r^n = r^(n+1) - 1.
-/
theorem geometric_series_int (r : ℤ) (n : ℕ) :
    (r - 1) * ∑ i ∈ range n, r ^ i = r ^ n - 1 := by
      rw [ mul_comm, geom_sum_mul ]