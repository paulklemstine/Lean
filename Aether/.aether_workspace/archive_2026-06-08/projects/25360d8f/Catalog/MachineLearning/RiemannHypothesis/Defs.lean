import Mathlib

/-!
# Riemann Hypothesis: Core Definitions

This file establishes the formal language layer for RH-adjacent mathematics.
We define abstract predicates for the critical-line condition, nontrivial zeros,
and the Riemann Hypothesis itself, as well as arithmetic functions needed for
consequence theorems (prime counting, Mertens function, error predicates).

## Design Philosophy

We separate the *logical structure* of RH from the *analytic content*.
The abstract predicate `RHFor ζ` works for any function `ζ : ℂ → ℂ`,
allowing instantiation with the actual Riemann zeta function when Mathlib's
complex-analytic infrastructure matures sufficiently, while enabling
meaningful theorem-proving about the *shape* of RH consequences now.
-/

namespace RH

/-! ## Critical Line and Zero Predicates -/

/-- A complex number lies on the critical line `Re(s) = 1/2`. -/
def OnCriticalLine (s : ℂ) : Prop := s.re = (1 : ℝ) / 2

/-- A nontrivial zero of `ζ` is a zero in the critical strip `0 < Re(s) < 1`. -/
def IsNontrivialZero (ζ : ℂ → ℂ) (s : ℂ) : Prop :=
  ζ s = 0 ∧ 0 < s.re ∧ s.re < 1

/-- The Riemann Hypothesis for an abstract zeta-like function:
    every nontrivial zero lies on the critical line. -/
def RHFor (ζ : ℂ → ℂ) : Prop :=
  ∀ s : ℂ, IsNontrivialZero ζ s → OnCriticalLine s

/-! ## Arithmetic Functions -/

/-- The prime counting function `π(N)`: number of primes in `{0, 1, ..., N}`. -/
def primeCount (N : ℕ) : ℕ :=
  ((Finset.range (N + 1)).filter Nat.Prime).card

/-- The Mertens function `M(N) = ∑_{n=1}^{N} μ(n)`, using Mathlib's
    arithmetic Möbius function. -/
noncomputable def mertensFunction (N : ℕ) : ℤ :=
  ∑ n ∈ Finset.Icc 1 N, (ArithmeticFunction.moebius n : ℤ)

/-- Discrepancy between the prime counting function and an approximation. -/
noncomputable def primeCountError (approx : ℕ → ℝ) (N : ℕ) : ℝ :=
  (primeCount N : ℝ) - approx N

/-! ## Error Bound Predicates -/

/-- RH-quality error bound: the error is `O(√N · log N)`. -/
def PrimeCountSqrtLogBound (approx : ℕ → ℝ) : Prop :=
  ∃ C : ℝ, 0 < C ∧
    ∀ N : ℕ, 2 ≤ N →
      |primeCountError approx N| ≤ C * Real.sqrt N * Real.log N

/-- Square-root bound on the Mertens function: `|M(N)| ≤ C · √N · (log N)²`.
    This is a consequence of RH (but strictly weaker than RH). -/
def MertensSqrtBound : Prop :=
  ∃ C : ℝ, 0 < C ∧
    ∀ N : ℕ, 1 ≤ N →
      |(mertensFunction N : ℝ)| ≤ C * Real.sqrt N * (Real.log N) ^ 2

/-! ## Polynomial Root-Location Predicates -/

/-- All roots of a complex polynomial lie on the critical line `Re(z) = 1/2`. -/
def CriticalLineRoots (P : Polynomial ℂ) : Prop :=
  ∀ z : ℂ, P.IsRoot z → z.re = (1 : ℝ) / 2

/-- All roots of a complex polynomial have zero real part (lie on imaginary axis). -/
def ImagAxisRoots (P : Polynomial ℂ) : Prop :=
  ∀ z : ℂ, P.IsRoot z → z.re = 0

/-- All roots of a complex polynomial are real. -/
def RealRoots (P : Polynomial ℂ) : Prop :=
  ∀ z : ℂ, P.IsRoot z → z.im = 0

end RH