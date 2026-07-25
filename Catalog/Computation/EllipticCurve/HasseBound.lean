import Mathlib

/-!
# The Hasse (trace) bound for elliptic curves over finite fields

For an elliptic curve `E` over a finite field `𝔽_q` with `N = #E(𝔽_q)` points, the
*trace of Frobenius* is the integer `a_q = q + 1 - N`, and **Hasse's theorem** asserts the
integer bound `a_q ^ 2 ≤ 4 q`, equivalently the analytic bound `|N - (q + 1)| ≤ 2 √q`.

Hasse's theorem itself (the integer bound) is a deep result that is not available in Mathlib,
so we package it as a predicate `HasseTraceBound q N`.  This file's mathematical content is the
*analytic conversion* `abs_sub_le_of_hasseTraceBound`: the integer trace bound implies the
real-analytic bound.  This is the form consumed downstream in the group-arithmetic development.
-/

namespace Computation.EllipticCurve

/-- The integer **trace of Frobenius** of a finite curve having `N` points over `𝔽_q`:
`a_q = q + 1 - N`. -/
def trace (q N : ℕ) : ℤ := (q : ℤ) + 1 - (N : ℤ)

/-- The **Hasse trace bound** (Hasse's theorem), stated as an integer predicate `a_q ^ 2 ≤ 4 q`.
It is supplied as a hypothesis where needed, since the bound itself is not available in Mathlib. -/
def HasseTraceBound (q N : ℕ) : Prop := (trace q N) ^ 2 ≤ 4 * (q : ℤ)

/-
**Analytic form of the Hasse bound.**  The integer trace bound `a_q ^ 2 ≤ 4 q` implies the
real bound `|N - (q + 1)| ≤ 2 √q`.
-/
theorem abs_sub_le_of_hasseTraceBound (q N : ℕ) (h : HasseTraceBound q N) :
    |(N : ℝ) - ((q : ℝ) + 1)| ≤ 2 * Real.sqrt q := by
  rw [ ← Real.sqrt_sq_eq_abs, Real.sqrt_le_left ] <;> ring_nf at *;
  · rw [ Real.sq_sqrt ] <;> norm_cast ; norm_num at *;
    · unfold HasseTraceBound at h; norm_num [ trace ] at h; linarith;
    · positivity;
  · positivity

end Computation.EllipticCurve