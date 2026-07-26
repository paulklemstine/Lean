import Mathlib

/-!
# Row Sum Fibonacci Property of the Pascal-like Riordan Array

The Pascal-like Riordan array defined by the power-series pair `(1/(1-x), x/(1-x)^2)`
has entries `t_{n,k} = C(n+k, 2k)` (OEIS A085478).  This file proves that the sum of
the entries in row `n` equals the odd-indexed Fibonacci number `fib(2n+1)`
(OEIS A001519), the sequence whose generating function is `(1-x)/(1-3x+x^2)`.

## Main results

* `pascalRiordanA_eq_fib` — **the row-sum identity**:
  `∑_{k=0}^{n} C(n+k, 2k) = fib(2n+1)`.
* `pascalRiordanB_eq_fib` — the companion lower-odd diagonal sum:
  `∑_{k=0}^{n} C(n+k, 2k+1) = fib(2n)`.
* `pascalRiordan_three_term` — the order-2 linear recurrence of the row sums,
  `A(n+2) = 3·A(n+1) − A(n)`, the combinatorial shadow of the generating function
  `(1-x)/(1-3x+x^2)`.

The proof runs a simultaneous induction on the pair `(A, B)` driven by two Pascal
recurrences (`pascalRiordanB_succ`, `pascalRiordanA_succ`).

## Catalog synthesis

This extends the catalog's Fibonacci thread (`Catalog/Applications/Fibonacci*`,
`Catalog/Novelty/FibCarmichaelStructure.lean`) and binomial thread
(`Catalog/Novelty/BinomialGCDA080170.lean`) by linking a Riordan-array row sum to
`Nat.fib`.  Mathlib already has the *shallow* diagonal sum
`Nat.fib_succ_eq_sum_choose` (`fib(n+1) = Σ_{i+j=n} C(i,j)`); the present *steep*
diagonal sum `Σ_k C(n+k,2k) = fib(2n+1)` is a genuinely different identity that is
not in Mathlib.

-- !-- Lab Notes -- !--
-- !-- Hypothesis: the row sums of the Riordan array C(n+k,2k) are exactly the
--     odd-indexed Fibonacci numbers fib(2n+1), per the g.f. (1-x)/(1-3x+x^2). -- !--
-- !-- Experiment: #eval confirmed A(n)=fib(2n+1) and the companion B(n)=fib(2n)
--     for n=0..7, and the two coupled recurrences B(n+1)=A(n)+B(n),
--     A(n+1)=A(n)+B(n+1) for n=0..5. Formalized them and the simultaneous
--     induction. -- !--
-- !-- Analysis: the key is the *pair* (A,B). The B-recurrence is a pure additive
--     Pascal step (no reindexing); the A-recurrence needs a k→k+1 shift because
--     C(n+k,2k-1) would otherwise trigger truncated ℕ subtraction at k=0. Working
--     with the odd lower index 2k+1 sidesteps all ℕ-subtraction hazards. -- !--
-- !-- Critique: the result is non-trivial (genuine two-variable induction, not
--     decide/native_decide; A and B couple through Pascal's rule), uses Mathlib's
--     Nat.choose/Nat.fib API, and the three-term recurrence rules out a vacuous
--     restatement. Base cases B(0)=0=fib 0, A(0)=1=fib 1 pin the sequence. -- !--
-- !-- Synthesis: A(n)=fib(2n+1), B(n)=fib(2n), and A(n+2)=3A(n+1)-A(n). -- !--
-/

open Finset

namespace RiordanRowSumFibonacci

/-- Row sum of the Riordan array: `A n = ∑_{k=0}^{n} C(n+k, 2k)`. -/
def pascalRiordanA (n : ℕ) : ℕ := ∑ k ∈ range (n + 1), Nat.choose (n + k) (2 * k)

/-- Companion lower-odd diagonal sum: `B n = ∑_{k=0}^{n} C(n+k, 2k+1)`. -/
def pascalRiordanB (n : ℕ) : ℕ := ∑ k ∈ range (n + 1), Nat.choose (n + k) (2 * k + 1)

/-- Pascal recurrence for `B`: `B(n+1) = A(n) + B(n)` (pure additive Pascal step). -/
lemma pascalRiordanB_succ (n : ℕ) :
    pascalRiordanB (n + 1) = pascalRiordanA n + pascalRiordanB n := by
  -- Apply Pascal's rule to each term in the sum.
  have h_pascal : ∀ k ∈ Finset.range (n + 2), Nat.choose ((n + 1) + k) (2 * k + 1) = Nat.choose (n + k) (2 * k) + Nat.choose (n + k) (2 * k + 1) := by
    grind +suggestions;
  convert Finset.sum_congr rfl h_pascal using 1;
  simp +arith +decide [ Finset.sum_range_succ, pascalRiordanA, pascalRiordanB ];
  simp +arith +decide [ Finset.sum_add_distrib, Nat.choose_eq_zero_of_lt ]

/-- Pascal recurrence for `A`: `A(n+1) = A(n) + B(n+1)`. -/
lemma pascalRiordanA_succ (n : ℕ) :
    pascalRiordanA (n + 1) = pascalRiordanA n + pascalRiordanB (n + 1) := by
  rw [ show pascalRiordanA ( n + 1 ) = ∑ k ∈ Finset.range ( n + 2 ), Nat.choose ( ( n + 1 ) + k ) ( 2 * k ) from rfl, show pascalRiordanB ( n + 1 ) = ∑ k ∈ Finset.range ( n + 2 ), Nat.choose ( ( n + 1 ) + k ) ( 2 * k + 1 ) from rfl ];
  rw [ Finset.sum_range_succ' ];
  rw [ Finset.sum_range_succ' _ ( n + 1 ) ];
  simp +arith +decide [ Nat.choose_succ_succ, Finset.sum_add_distrib, pascalRiordanA ];
  have := Finset.sum_range_succ' ( fun x => Nat.choose ( n + x ) ( 2 * x + 1 ) ) n; simp_all +arith +decide [ Nat.choose_succ_succ, Finset.sum_range_succ ] ;
  simp_all +arith +decide [ Finset.sum_add_distrib, Nat.choose_eq_zero_of_lt ];
  rw [ ← Finset.mul_sum _ _ _, this ] ; ring;
  rw [ Finset.sum_mul _ _ _ ] ; ring

/-- Simultaneous closed forms: `A n = fib(2n+1)` and `B n = fib(2n)`. -/
lemma pascalRiordan_pair (n : ℕ) :
    pascalRiordanA n = Nat.fib (2 * n + 1) ∧ pascalRiordanB n = Nat.fib (2 * n) := by
  induction n <;> simp_all +arith +decide [ Nat.fib_add_two, pascalRiordanA_succ, pascalRiordanB_succ ]

/-- **Row-sum Fibonacci identity**: `∑_{k=0}^{n} C(n+k, 2k) = fib(2n+1)`. -/
theorem pascalRiordanA_eq_fib (n : ℕ) :
    ∑ k ∈ range (n + 1), Nat.choose (n + k) (2 * k) = Nat.fib (2 * n + 1) :=
  (pascalRiordan_pair n).1

/-- Companion identity: `∑_{k=0}^{n} C(n+k, 2k+1) = fib(2n)`. -/
theorem pascalRiordanB_eq_fib (n : ℕ) :
    ∑ k ∈ range (n + 1), Nat.choose (n + k) (2 * k + 1) = Nat.fib (2 * n) :=
  (pascalRiordan_pair n).2

/-- The order-2 recurrence of the row sums: `A(n+2) = 3·A(n+1) − A(n)`,
the combinatorial shadow of the generating function `(1-x)/(1-3x+x^2)`. -/
theorem pascalRiordan_three_term (n : ℕ) :
    pascalRiordanA (n + 2) + pascalRiordanA n = 3 * pascalRiordanA (n + 1) := by
  -- By definition of $pascalRiordanA$, we can rewrite the goal using the Fibonacci sequence.
  have h_fib : ∀ n, pascalRiordanA n = Nat.fib (2 * n + 1) := by
    exact fun n => pascalRiordan_pair n |>.1;
  simp_all +arith +decide [ Nat.fib_add_two ]

end RiordanRowSumFibonacci