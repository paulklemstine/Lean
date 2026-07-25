import Mathlib.Algebra.Polynomial.Derivative
import Mathlib.Algebra.Polynomial.Degree.Lemmas
import Mathlib.Algebra.Polynomial.Basic
import Mathlib

/-!
# Airy's equation has no nonzero polynomial solutions

This file proves two statements about Airy's differential equation,
working entirely inside the polynomial ring `ℝ[X]` with the formal
derivative `Polynomial.derivative`.

## Main results

* `airy_no_polynomial_solution`: the only polynomial `p` satisfying the
  Airy equation `p'' = X · p` is the zero polynomial.
* `airy_riccati_no_polynomial_solution`: the Riccati form of the Airy
  equation, `p'' + (p')² = X`, has no polynomial solution at all.
-/

open Polynomial

/-- **Airy's equation has no nonzero polynomial solution.**

If `p : ℝ[X]` satisfies `p'' = X * p`, then `p = 0`.

The proof compares natural degrees: `X * p` has degree `natDegree p + 1`
when `p ≠ 0`, while the second derivative `p''` has degree at most
`natDegree p - 2`. These are incompatible. -/
theorem airy_no_polynomial_solution (p : ℝ[X])
    (h : derivative (derivative p) = X * p) : p = 0 := by
  by_contra hp
  have hpne : p ≠ 0 := hp
  -- Degree of the right-hand side `X * p`.
  have hX : (X : ℝ[X]) * p = p * X := by ring
  have hrhs : (X * p : ℝ[X]).natDegree = p.natDegree + 1 := by
    rw [hX, natDegree_mul_X hpne]
  -- Degree bound for the left-hand side `p''`.
  have hlhs : (derivative (derivative p)).natDegree ≤ p.natDegree - 2 := by
    calc (derivative (derivative p)).natDegree
        ≤ (derivative p).natDegree - 1 := natDegree_derivative_le _
      _ ≤ (p.natDegree - 1) - 1 := by
            have := natDegree_derivative_le p
            omega
      _ = p.natDegree - 2 := by omega
  rw [h, hrhs] at hlhs
  omega

/-- **The Riccati form of Airy's equation has no polynomial solution.**

There is no `p : ℝ[X]` satisfying `p'' + (p')² = X`.

The proof splits on `d = natDegree (p')`.
* If `d = 0`, then both `p''` and `(p')²` have degree `0`, so the left-hand
  side has degree `≤ 0`, while `X` has degree `1`.
* If `d ≥ 1`, then `(p')²` has degree `2 d` which strictly dominates the
  degree of `p''`, so the sum has degree `2 d ≥ 2`, again incompatible with
  `natDegree X = 1`. -/
theorem airy_riccati_no_polynomial_solution (p : ℝ[X])
    (h : derivative (derivative p) + (derivative p) ^ 2 = X) : False := by
  set d := (derivative p).natDegree with hd
  have hpow : ((derivative p) ^ 2).natDegree = 2 * d := by
    rw [natDegree_pow]
  have hsec : (derivative (derivative p)).natDegree ≤ d - 1 := by
    have := natDegree_derivative_le (derivative p); omega
  rcases Nat.eq_zero_or_pos d with h0 | hpos
  · -- `d = 0`: the whole left-hand side has degree `≤ 0`.
    have hle : (derivative (derivative p) + (derivative p) ^ 2).natDegree ≤ 0 := by
      have := natDegree_add_le (derivative (derivative p)) ((derivative p) ^ 2)
      rw [hpow] at this
      omega
    rw [h, natDegree_X] at hle
    omega
  · -- `d ≥ 1`: the `(p')²` term dominates, giving degree `2 d`.
    have hlt : (derivative (derivative p)).natDegree < ((derivative p) ^ 2).natDegree := by
      rw [hpow]; omega
    have heq : (derivative (derivative p) + (derivative p) ^ 2).natDegree = 2 * d := by
      rw [natDegree_add_eq_right_of_natDegree_lt hlt, hpow]
    rw [h, natDegree_X] at heq
    omega