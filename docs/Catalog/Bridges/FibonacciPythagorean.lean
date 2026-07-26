import Mathlib

/-!
# A Fibonacci–Pythagorean bridge

This file connects two catalog domains — the Fibonacci / number-theory world and the
Pythagorean / plane-geometry world — through the classical construction that turns four
consecutive Fibonacci numbers into a right triangle.

Given consecutive Fibonacci numbers `F n, F (n+1), F (n+2), F (n+3)`, the pair of legs

* `A = F n · F (n+3)`  (product of the outer two), and
* `B = 2 · F (n+1) · F (n+2)`  (twice the product of the inner two)

together with the hypotenuse `C = F (n+1)² + F (n+2)²` form a Pythagorean triple, and the
hypotenuse is itself the Fibonacci number `F (2n+3)`.  For `n = 2` this reproduces the
smallest triple `(3, 4, 5)`; for `n = 3`, `(5, 12, 13)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The Raine/Horadam construction should give an *exact*
Pythagorean identity for every `n`, and its hypotenuse should coincide with the Fibonacci
number `F (2n+3)` via the addition formula `F (m+n+1) = F m F n + F (m+1) F (n+1)`.

Experiment (Experimenter): Reduced `A² + B² = C²` to a two-variable polynomial identity in
`x = F n`, `y = F (n+1)` after expanding `F (n+2)`, `F (n+3)` by the recurrence; closed by
`ring`.  Identified `C = F (2n+3)` as the `m = n = n+1` case of `Nat.fib_add`.

Analysis (Analyst): The construction is a *polynomial* identity, so it needs no induction
beyond the recurrence unfolding — the depth lives in matching the algebra to `Nat.fib_add`.
The triples are not always primitive (e.g. `n = 4` gives `(16,30,34) = 2·(8,15,17)`), so no
primitivity claim is made.

Critique (Critic): Verified non-degeneracy — for `n ≥ 1` both legs are strictly positive,
so the triangle is genuine, ruling out a vacuous "triple" with a zero leg.

Synthesis (PI): One recurrence expansion + one addition-formula application bridge the
Fibonacci recurrence to Euclidean right triangles, with `F (2n+3)` as the hypotenuse.
-- !-- Lab Notes -- !--
-/

namespace FibonacciPythagorean

open Nat

/-- The two legs of the Fibonacci right triangle at index `n`. -/
def legA (n : ℕ) : ℕ := Nat.fib n * Nat.fib (n + 3)

/-- The second leg (twice the product of the inner two Fibonacci numbers). -/
def legB (n : ℕ) : ℕ := 2 * Nat.fib (n + 1) * Nat.fib (n + 2)

/-- The hypotenuse, as a sum of two squares of Fibonacci numbers. -/
def hyp (n : ℕ) : ℕ := Nat.fib (n + 1) ^ 2 + Nat.fib (n + 2) ^ 2

/-
**Pythagorean identity.**  `A² + B² = C²`.
-/
theorem legA_sq_add_legB_sq (n : ℕ) :
    legA n ^ 2 + legB n ^ 2 = hyp n ^ 2 := by
  unfold legA legB hyp
  have h2 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
  have h3 : Nat.fib (n + 3) = Nat.fib (n + 1) + Nat.fib (n + 2) := by
    rw [show n + 3 = (n + 1) + 2 by ring, Nat.fib_add_two]
  rw [h3, h2]; ring

/-
**The hypotenuse is a Fibonacci number:** `C = F (2n+3)`.
-/
theorem hyp_eq_fib (n : ℕ) : hyp n = Nat.fib (2 * n + 3) := by
  unfold hyp
  have h := Nat.fib_add (n + 1) (n + 1)
  have e : (n + 1) + (n + 1) + 1 = 2 * n + 3 := by ring
  rw [e] at h
  rw [h, pow_two, pow_two]

/-
**Fibonacci–Pythagorean triple.**  The legs `A`, `B` and the Fibonacci hypotenuse
`F (2n+3)` satisfy the Pythagorean relation.
-/
theorem fib_pythagorean (n : ℕ) :
    legA n ^ 2 + legB n ^ 2 = Nat.fib (2 * n + 3) ^ 2 := by
  rw [ ← hyp_eq_fib, legA_sq_add_legB_sq ]

/-
**Non-degeneracy:** for `n ≥ 1` both legs are strictly positive, so the triangle is
genuine.
-/
theorem legs_pos {n : ℕ} (hn : 1 ≤ n) : 0 < legA n ∧ 0 < legB n := by
  exact ⟨ Nat.mul_pos ( Nat.fib_pos.mpr hn ) ( Nat.fib_pos.mpr ( by linarith ) ), Nat.mul_pos ( Nat.mul_pos two_pos ( Nat.fib_pos.mpr ( by linarith ) ) ) ( Nat.fib_pos.mpr ( by linarith ) ) ⟩

end FibonacciPythagorean