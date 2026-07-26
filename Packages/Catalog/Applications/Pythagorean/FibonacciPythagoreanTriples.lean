import Mathlib

/-! # Fibonacci Pythagorean triples

Domain: Number Theory ∩ Euclidean Geometry (Applications / Pythagorean).

Four consecutive Fibonacci numbers `F n, F (n+1), F (n+2), F (n+3)` assemble into a
Pythagorean triple.  Writing `p = F (n+2)` and `q = F (n+1)`, the classical Euclid
parametrisation `(p² − q², 2pq, p² + q²)` specialises, because consecutive Fibonacci
numbers satisfy `p − q = F n` and `p + q = F (n+3)`, to

* leg      `a = F n · F (n+3)      = p² − q²`,
* leg      `b = 2 · F (n+1) · F (n+2) = 2pq`,
* hypotenuse `c = F (n+1)² + F (n+2)² = p² + q²`.

The first two nondegenerate instances are the `3-4-5` and `5-12-13` triples.  Two
features make this family special and tie the geometry back to number theory:

* the hypotenuse is *itself* a Fibonacci number, `c = F (2n+3)` — the odd-index
  sum-of-squares identity; so every triple in the family has a Fibonacci hypotenuse and
  the hypotenuses run through the odd-indexed Fibonacci subsequence;
* the area of the right triangle is the product of the four consecutive Fibonacci
  numbers, `½·a·b = F n · F (n+1) · F (n+2) · F (n+3)`.

## Results

* `fib_sq_add_sq_eq_fib`   — `F (n+1)² + F (n+2)² = F (2n+3)`.
* `fib_pythagorean`        — `a² + b² = c²` over `ℕ`.
* `fib_pythagorean_hyp`    — `a² + b² = F (2n+3)²`.
* `fib_pythagoreanTriple`  — the triple `(a, b, F (2n+3))` is a `PythagoreanTriple`.
* `fib_pyth_area`          — `a · b = 2 · (F n · F (n+1) · F (n+2) · F (n+3))`.
* `fib_pyth_pos`           — for `n ≥ 1` all three sides are strictly positive.

-- !-- Lab Notes -- !--
-- Hypothesis: consecutive Fibonacci numbers, being coprime and obeying the shift
--   `F(n+2) = F n + F(n+1)`, should feed Euclid's `(p²−q², 2pq, p²+q²)` machine and
--   produce a triple whose hypotenuse is again Fibonacci.
-- Experiment: computed `n = 0..7`; got `(0,2,2),(3,4,5),(5,12,13),(16,30,34),…` with
--   `a²+b²=c²` and `c = F(2n+3)` and `a·b = 2·F n F(n+1) F(n+2) F(n+3)` in every case.
-- Analysis: over ℕ the whole identity collapses to a two-variable polynomial identity in
--   `x = F n`, `y = F (n+1)` after substituting `F(n+2)=x+y`, `F(n+3)=x+2y`; then `ring`
--   closes it. The hypotenuse identity is the odd-index case `F(2m+1)=F m²+F(m+1)²` of
--   `Nat.fib_add`.
-- Critique: the `n = 0` triple is degenerate (`a = 0`); positivity is therefore stated
--   for `n ≥ 1`, where all sides are positive and the triangle is genuine.
-- Synthesis: the family bridges the additive number theory of `Nat.fib` with Mathlib's
--   geometric `PythagoreanTriple`, and exhibits the odd-index Fibonacci numbers as an
--   infinite family of Pythagorean hypotenuses.
-- !-- End Lab Notes -- !--
-/

namespace FibPythagorean

open Nat

/-- The first leg of the `n`-th Fibonacci Pythagorean triple, `a = F n · F (n+3)`. -/
def legA (n : ℕ) : ℕ := Nat.fib n * Nat.fib (n + 3)

/-- The second leg of the `n`-th Fibonacci Pythagorean triple, `b = 2 · F (n+1) · F (n+2)`. -/
def legB (n : ℕ) : ℕ := 2 * Nat.fib (n + 1) * Nat.fib (n + 2)

/-- The hypotenuse of the `n`-th Fibonacci Pythagorean triple, `c = F (n+1)² + F (n+2)²`. -/
def hyp (n : ℕ) : ℕ := Nat.fib (n + 1) ^ 2 + Nat.fib (n + 2) ^ 2

/-- **Odd-index sum of squares:** `F (n+1)² + F (n+2)² = F (2n+3)`.

This is the case `m = n+1` of `F (2m+1) = F m² + F (m+1)²`. -/
theorem fib_sq_add_sq_eq_fib (n : ℕ) :
    Nat.fib (n + 1) ^ 2 + Nat.fib (n + 2) ^ 2 = Nat.fib (2 * n + 3) := by
  have h := Nat.fib_add (n + 1) (n + 1)
  have e : (n + 1) + (n + 1) + 1 = 2 * n + 3 := by ring
  rw [e] at h
  rw [h]; ring

/-- **The Fibonacci Pythagorean identity:** `a² + b² = c²`.

After substituting the recurrence `F(n+2) = F n + F(n+1)` and
`F(n+3) = F(n+1) + F(n+2)`, this is a polynomial identity in `F n` and `F (n+1)`. -/
theorem fib_pythagorean (n : ℕ) :
    legA n ^ 2 + legB n ^ 2 = hyp n ^ 2 := by
  have h2 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
  have h3 : Nat.fib (n + 3) = Nat.fib (n + 1) + Nat.fib (n + 2) := Nat.fib_add_two
  simp only [legA, legB, hyp, h3, h2]
  ring

/-- The hypotenuse of the triple is the Fibonacci number `F (2n+3)`. -/
theorem hyp_eq_fib (n : ℕ) : hyp n = Nat.fib (2 * n + 3) :=
  fib_sq_add_sq_eq_fib n

/-- The two legs' squares sum to `F (2n+3)²`: the hypotenuse is a Fibonacci number. -/
theorem fib_pythagorean_hyp (n : ℕ) :
    legA n ^ 2 + legB n ^ 2 = Nat.fib (2 * n + 3) ^ 2 := by
  rw [fib_pythagorean, hyp_eq_fib]

/-- **Bridge to Euclidean geometry:** `(a, b, F (2n+3))` is a `PythagoreanTriple`
in the sense of the standard `x² + y² = z²` relation (over `ℤ`). -/
theorem fib_pythagoreanTriple (n : ℕ) :
    PythagoreanTriple (legA n : ℤ) (legB n : ℤ) (Nat.fib (2 * n + 3) : ℤ) := by
  have h := fib_pythagorean_hyp n
  unfold PythagoreanTriple
  have : ((legA n : ℤ)) * (legA n) + (legB n) * (legB n)
      = ((Nat.fib (2 * n + 3) : ℤ)) * (Nat.fib (2 * n + 3)) := by
    exact_mod_cast by rw [← pow_two, ← pow_two, ← pow_two]; exact_mod_cast h
  simpa using this

/-- **Area identity:** the product of the two legs equals twice the product of the four
consecutive Fibonacci numbers, so the triangle's area is `F n · F (n+1) · F (n+2) · F (n+3)`. -/
theorem fib_pyth_area (n : ℕ) :
    legA n * legB n
      = 2 * (Nat.fib n * Nat.fib (n + 1) * Nat.fib (n + 2) * Nat.fib (n + 3)) := by
  unfold legA legB; ring

/-- For `n ≥ 1` the triple is genuine: all three sides are strictly positive. -/
theorem fib_pyth_pos (n : ℕ) (hn : 1 ≤ n) :
    0 < legA n ∧ 0 < legB n ∧ 0 < hyp n := by
  refine ⟨?_, ?_, ?_⟩
  · exact Nat.mul_pos (Nat.fib_pos.mpr hn) (Nat.fib_pos.mpr (by linarith))
  · exact Nat.mul_pos (Nat.mul_pos two_pos (Nat.fib_pos.mpr (by linarith)))
      (Nat.fib_pos.mpr (by linarith))
  · exact add_pos (pow_pos (Nat.fib_pos.mpr (by linarith)) 2)
      (pow_pos (Nat.fib_pos.mpr (by linarith)) 2)

end FibPythagorean