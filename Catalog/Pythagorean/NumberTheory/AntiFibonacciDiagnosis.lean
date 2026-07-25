import Bridges.NumberTheory.AntiFibonacci

/-!
# Rigidity and quadratic diagnostics for anti-Fibonacci rules

The literal instruction “choose the least positive integer different from the sum of the
preceding two” forbids only one integer at each step.  Since two positive predecessors
have sum at least two, the integer one remains admissible forever.  This file sharpens
that diagnosis and studies the separate sequence displayed in the motivating data.

The displayed sequence has constant second difference one and lies on the quadratic
curve

`8 A(n) = (2n - 1)^2 + 7`.

Consequently its leading coefficient is one half.  In particular, the proposed
quarter-square estimate cannot hold with bounded error.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable claims were considered.  (H1) the literal
rule determines a unique trajectory; (H2) this trajectory is constant; (H3) the listed
values have constant second difference; (H4) the listed values lie on a translated
odd-square curve; (H5) their discrepancy from a quarter-square is bounded; and (H6)
the literal trajectory has oscillating consecutive ratios.  The odd-square relation
was prioritized because it links greedy recurrence diagnostics with quadratic
Diophantine structure.

Experiment (Experimenter): The literal rule yields only ones.  The displayed data
`1, 1, 2, 4, 7, 11, 16, 22, 29` have first differences
`0, 1, 2, 3, 4, 5, 6, 7` and constant second difference one.  At index one million,
the displayed value is `499999500001`, approximately twice the proposed
quarter-square scale.

Analysis (Analyst): H1--H4 survive.  H5 and H6 fail: the quarter-square discrepancy is
unbounded, while every literal consecutive ratio equals one.  The source of the
failure is the distinction between avoiding one current sum and avoiding a growing
set of earlier sums.

Critique (Critic): Positivity is essential to the collapse theorem.  The odd-square
identity is not inferred from finitely many values; it follows from the catalog's
inductive closed law.  The bounded-error claim is rejected uniformly, with an
explicit witness for every proposed bound.  No asymptotic conclusion is based solely
on numerical evidence.

Synthesis (Principal Investigator): The literal process is classified completely,
and the displayed process is placed on an exact quadratic curve.  Any nonconstant
greedy anti-Fibonacci theory must enlarge the forbidden set explicitly.
-- !-- Lab Notes -- !--
-/

namespace AntiFibonacciDiagnosis

open AntiFibonacci

/-
The literal rule is equivalent to being the constant-one sequence.
-/
theorem literal_rule_iff_constant_one (a : ℕ → ℕ) :
    SatisfiesLiteralRule a ↔ ∀ n : ℕ, a n = 1 := by
  exact ⟨ fun h => AntiFibonacci.literal_rule_unique h, fun h => by rw [ show a = _ from funext h ] ; exact AntiFibonacci.constant_one_satisfies ⟩

/-
The displayed sequence has constant second forward difference equal to one.
-/
theorem displayed_second_difference (n : ℕ) :
    displayed (n + 2) + displayed n = 2 * displayed (n + 1) + 1 := by
  simp +arith +decide [ displayed_succ ]

/-
Exact odd-square curve containing every point of the displayed sequence.
-/
theorem displayed_odd_square_curve (n : ℕ) (hn : 1 ≤ n) :
    8 * displayed n = (2 * n - 1) ^ 2 + 7 := by
  nlinarith [ Nat.sub_add_cancel hn, Nat.sub_add_cancel ( by linarith : 1 ≤ 2 * n ), displayed_double n ]

/-
The displayed values eventually exceed the proposed quarter-square model by
more than any prescribed linear error.
-/
theorem displayed_quarter_gap_exceeds_linear (C : ℕ) :
    ∃ n : ℕ, quarterSquare n + C * n < displayed n := by
  let k := 2 * C + 2
  refine ⟨2 * k, ?_⟩
  rw [displayed_even_decomposition]
  dsimp [k]
  nlinarith

/-
A genuine Pythagorean-style reformulation: adjoining legs of lengths
`2n-1` and `1` produces a square sum determined exactly by the displayed value.
-/
theorem displayed_two_square_identity (n : ℕ) (hn : 1 ≤ n) :
    (2 * n - 1) ^ 2 + 1 ^ 2 = 8 * displayed n - 6 := by
  exact eq_tsub_of_add_eq (by linarith [displayed_odd_square_curve n hn])

end AntiFibonacciDiagnosis