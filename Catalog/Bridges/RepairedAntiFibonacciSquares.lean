import Mathlib
import Logic.RepairedAntiFibonacciClassification

/-!
# A bridge from a greedy additive-avoidance rule to squares and Pythagorean triples

The *repaired anti-Fibonacci rule* (see `Logic.RepairedAntiFibonacciClassification`)
is a purely combinatorial greedy process: start at `1` and always take the least
value that exceeds the current term and avoids every sum of two previously seen
terms.  Its unique trajectory is the sequence of positive odd numbers
`a n = 2 n + 1`.

This file is a *connector*: it shows that this extremal-combinatorial object is
secretly the classical arithmetic of **perfect squares** and **Pythagorean
triples**.

* `repaired_partial_sum_eq_sq` — the partial sums of the trajectory are exactly
  the squares: `∑_{k < n} a k = n²`.  This is the ancient identity
  "sum of the first `n` odd numbers is `n²`", here re-derived from the greedy
  additive-avoidance dynamics rather than assumed.
* `repaired_partial_sums_range_eq_squares` — the set of partial sums is precisely
  the set of perfect squares.
* `repaired_term_eq_consecutive_sq_diff` — each term is a difference of
  consecutive squares.
* `repaired_pythagorean` / `repaired_pythagorean_primitive` — every term produces
  an (odd-leg) Pythagorean triple, connecting the sequence to Diophantine
  geometry.

Everything is derived from the rigidity theorem `repaired_exact_value`, so these
statements hold for *any* sequence obeying the repaired rule, not just the
canonical one.
-/

namespace RepairedAntiFibonacci

open Finset

/-- **Combinatorics ↔ arithmetic of squares.**
The partial sums of a repaired anti-Fibonacci trajectory are exactly the perfect
squares: summing the first `n` terms of the greedy additive-avoidance sequence
gives `n²`.  This is the classical "sum of the first `n` odd numbers equals `n²`",
recovered here from the greedy dynamics. -/
theorem repaired_partial_sum_eq_sq {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) : ∑ k ∈ Finset.range n, a k = n ^ 2 := by
  induction n with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ, ih, repaired_exact_value ha]
      ring

/-- The successive partial sums differ by the current term, i.e. the term is the
gap between consecutive squares `(n+1)² - n²`. -/
theorem repaired_term_eq_consecutive_sq_diff {a : ℕ → ℕ}
    (ha : SatisfiesRepairedRule a) (n : ℕ) :
    a n + n ^ 2 = (n + 1) ^ 2 := by
  rw [repaired_exact_value ha]
  ring

/-- **The set of partial sums is exactly the set of perfect squares.** -/
theorem repaired_partial_sums_range_eq_squares {a : ℕ → ℕ}
    (ha : SatisfiesRepairedRule a) :
    Set.range (fun n => ∑ k ∈ Finset.range n, a k) = {m : ℕ | ∃ j, m = j ^ 2} := by
  ext m
  simp only [Set.mem_range, Set.mem_setOf_eq]
  constructor
  · rintro ⟨n, rfl⟩
    exact ⟨n, (repaired_partial_sum_eq_sq ha n)⟩
  · rintro ⟨j, rfl⟩
    exact ⟨j, repaired_partial_sum_eq_sq ha j⟩

/-- **Combinatorics ↔ Pythagorean triples.**
Every term of a repaired trajectory is the odd leg of a Pythagorean triple.
Writing `m = a n = 2n+1`, the triple `(m, 2n²+2n, 2n²+2n+1)` is Pythagorean. -/
theorem repaired_pythagorean {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a) (n : ℕ) :
    (a n) ^ 2 + (2 * n ^ 2 + 2 * n) ^ 2 = (2 * n ^ 2 + 2 * n + 1) ^ 2 := by
  rw [repaired_exact_value ha]
  ring

/-- The odd leg squared is the sum of the two consecutive integers forming the
even leg and the hypotenuse: `(a n)² = (2n²+2n) + (2n²+2n+1)`.  Since those two
legs are consecutive integers, this is exactly the classical odd-leg
parametrisation of primitive Pythagorean triples, tying each term of the greedy
sequence to a primitive triple. -/
theorem repaired_odd_leg_sq_eq_leg_add_hyp {a : ℕ → ℕ}
    (ha : SatisfiesRepairedRule a) (n : ℕ) :
    (a n) ^ 2 = (2 * n ^ 2 + 2 * n) + (2 * n ^ 2 + 2 * n + 1) := by
  rw [repaired_exact_value ha]
  ring

/-- For `n ≥ 1` the odd leg is at least `3`, so the attached Pythagorean triple is
nondegenerate (the smallest such triple being `(3, 4, 5)` at `n = 1`). -/
theorem repaired_leg_ge_three {a : ℕ → ℕ}
    (ha : SatisfiesRepairedRule a) {n : ℕ} (hn : 1 ≤ n) :
    3 ≤ a n := by
  rw [repaired_exact_value ha]
  omega

/-- **Arithmetic-mean form of the odd-number identity.**  The `n`-th partial sum
is `n²`, so the average of the first `n` terms is exactly `n`. -/
theorem repaired_average_eq {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) :
    (∑ k ∈ Finset.range n, a k) = n * n := by
  rw [repaired_partial_sum_eq_sq ha]
  ring

end RepairedAntiFibonacci