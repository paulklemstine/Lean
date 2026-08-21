/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The top shape counts are Catalan numbers times a factorial

`Combinatorics.EvenWalkPolynomial` writes every moment count in the binomial basis,
`evenClosedWalkCount N L = ∑ r, C(N, r) * surjEvenWalkCount r L`, and shows that the
shape counts `surjEvenWalkCount r (2k)` vanish once `r > k + 1`.  The *top* shape
count `surjEvenWalkCount (k+1) (2k)` therefore controls the leading coefficient of
the moment polynomial: the coefficient of `N^(k+1)` is
`surjEvenWalkCount (k+1) (2k) / (k+1)!`.

This file verifies, at the three orders that are within reach of exhaustive
verification, the identity

    surjEvenWalkCount (k+1) (2k) = catalan k * (k+1)!

for `k = 1, 2, 3`, i.e. the leading coefficients of the second, fourth and sixth
moments are the Catalan numbers `1, 2, 5`.  The general statement is the
combinatorial heart of Wigner's semicircle law (the surviving shapes are the doubled
plane trees), and is recorded as a conjecture in `FUTURE_DIRECTIONS.md`.

The file also re-derives the exact fourth count `2 C(N,2) + 12 C(N,3)` from the
general polynomiality theorem, giving an independent check of
`EvenWalks.evenClosedWalkCount_four`.
-/
import Combinatorics.EvenWalkPolynomial

open Finset

namespace EvenWalks

/-! ### Shape counts at length four -/

theorem surjEvenWalkCount_zero_four : surjEvenWalkCount 0 4 = 0 := by decide

theorem surjEvenWalkCount_one_four : surjEvenWalkCount 1 4 = 0 := by decide

theorem surjEvenWalkCount_two_four : surjEvenWalkCount 2 4 = 2 := by decide

set_option maxRecDepth 40000 in
theorem surjEvenWalkCount_three_four : surjEvenWalkCount 3 4 = 12 := by decide

theorem surjEvenWalkCount_four_four : surjEvenWalkCount 4 4 = 0 :=
  surjEvenWalkCount_eq_zero_of_lt 4 4 (by norm_num)

/-- The fourth moment count in the binomial basis, derived from the general
polynomiality theorem rather than from the ensemble computation. -/
theorem evenClosedWalkCount_four_choose (N : ℕ) :
    evenClosedWalkCount N 4 = 2 * N.choose 2 + 12 * N.choose 3 := by
  rw [evenClosedWalkCount_eq_sum_choose, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    surjEvenWalkCount_zero_four, surjEvenWalkCount_one_four, surjEvenWalkCount_two_four,
    surjEvenWalkCount_three_four, surjEvenWalkCount_four_four]
  ring

/-! ### Shape counts at length two -/

theorem surjEvenWalkCount_two_two : surjEvenWalkCount 2 2 = 2 := by decide

/-! ### The Catalan pattern for the top shapes -/

/-- Order two (`k = 1`): the top shape count is `catalan 1 * 2! = 2`. -/
theorem surjEvenWalkCount_top_two : surjEvenWalkCount 2 2 = catalan 1 * (Nat.factorial 2) := by
  rw [surjEvenWalkCount_two_two, catalan_one]
  norm_num [Nat.factorial]

/-- Order four (`k = 2`): the top shape count is `catalan 2 * 3! = 12`. -/
theorem surjEvenWalkCount_top_four : surjEvenWalkCount 3 4 = catalan 2 * (Nat.factorial 3) := by
  rw [surjEvenWalkCount_three_four, catalan_two]
  norm_num [Nat.factorial]

/-- Order six (`k = 3`): the top shape count is `catalan 3 * 4! = 120`. -/
theorem surjEvenWalkCount_top_six : surjEvenWalkCount 4 6 = catalan 3 * (Nat.factorial 4) := by
  rw [surjEvenWalkCount_four_six, catalan_three]
  norm_num [Nat.factorial]

end EvenWalks