import Mathlib

/-!
# Benford Dynamics: Definitions and Basic Infrastructure

This file provides the foundational definitions for studying Benford's law
in the context of arithmetic dynamical systems with prime seeds.

## Main Definitions

- `leadDigitBase b n` — the leading (most significant) digit of `n` in base `b`
- `primeOrbitCount T X N m b` — count of (prime, iterate) pairs whose orbit value
  has leading digit `m` in base `b`
- `benfordFrequency T X N m b` — the empirical frequency of leading digit `m`
-/

open Finset Nat Real

noncomputable section

/-- The leading digit of a positive natural number `n` in base `b`.
    Returns 0 if `n = 0` or `b < 2`. For a valid input, returns a value in `{1, ..., b-1}`.
    This is computed by repeatedly dividing by `b` until the result is less than `b`. -/
def leadDigitBase (b : ℕ) (n : ℕ) : ℕ :=
  if b < 2 then 0
  else if n = 0 then 0
  else
    -- Find the leading digit by dividing n by b until < b
    n / b ^ (Nat.log b n)

/-- Leading digit for integers: takes the leading digit of the absolute value. -/
def leadDigitBaseInt (b : ℕ) (z : ℤ) : ℕ :=
  leadDigitBase b z.natAbs

/-- Count of (prime, time) pairs `(p, n)` with `p ≤ X` prime, `1 ≤ n ≤ N`,
    such that the leading digit of `|T^[n](p)|` in base `b` equals `m`. -/
def primeOrbitCount (T : ℤ → ℤ) (X N m b : ℕ) : ℕ :=
  ((Finset.range N).product ((Finset.range (X + 1)).filter Nat.Prime)).filter
    (fun ⟨n, p⟩ => leadDigitBaseInt b ((T^[n + 1]) (p : ℤ)) = m) |>.card

/-- The empirical Benford frequency for digit `m` in base `b`,
    averaged over primes up to `X` and iterates up to `N`. -/
def benfordFrequency (T : ℤ → ℤ) (X N m b : ℕ) : ℝ :=
  (primeOrbitCount T X N m b : ℝ) /
    ((((Finset.range (X + 1)).filter Nat.Prime).card : ℝ) * (N : ℝ))

/-- The Benford target probability for digit `m` in base `b`:
    `log_b(1 + 1/m) = log(1 + 1/m) / log(b)`. -/
def benfordTarget (b m : ℕ) : ℝ :=
  Real.log (1 + 1 / (m : ℝ)) / Real.log (b : ℝ)

/-- The quadratic map `T_c(x) = x² + c`. -/
def quadMap (c : ℤ) : ℤ → ℤ := fun x => x ^ 2 + c

end