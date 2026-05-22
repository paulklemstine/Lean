/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.BSD.Definitions

/-!
# Local Euler Factor Extensionality from Frobenius Trace

## Main results

* `local_euler_factor_ext_of_trace`: Two `LocalEulerData` packages with the same
  prime and Frobenius trace have identical Euler polynomial coefficients.
* `local_euler_pointCount_of_trace`: Equal prime and trace force equal point counts
  (under good-reduction consistency).
* `local_euler_data_ext`: Full extensionality — equal prime, equal trace, and
  good-reduction consistency force all three fields to agree.

## Proof strategy

Strategy A (coefficient comparison): The good-prime Euler polynomial is
`1 - a_p T + p T²`, so its coefficients are determined by `a_p` and `p` alone.
This is the shortest and most robust proof path.
-/

open LocalEulerData

/-!
### Theorem Target 1: Local Euler factor uniqueness from Frobenius trace data

The Euler polynomial coefficients `[1, -a_p, p]` depend only on `a_p` and `p`.
If two local data packages share these, the polynomial is identical.
-/

/-
**Local Euler factor extensionality from Frobenius trace.**
If two good local Euler data packages have the same residue characteristic and the same
Frobenius trace, then their local Euler polynomial coefficients agree at every index.
This is the formal statement that the local factor is canonically determined by
the trace and the prime.
-/
theorem local_euler_factor_ext_of_trace
    (d₁ d₂ : LocalEulerData)
    (hp : d₁.p = d₂.p)
    (ha : d₁.ap = d₂.ap)
    (i : Fin 3) :
    d₁.eulerCoeffs i = d₂.eulerCoeffs i := by
  fin_cases i <;> simp +decide [ *, LocalEulerData.eulerCoeffs ]

/-
Under good-reduction consistency, equal primes and equal traces
force equal point counts.
-/
theorem local_euler_pointCount_of_trace
    (d₁ d₂ : LocalEulerData)
    (h₁ : goodEulerConsistency d₁)
    (h₂ : goodEulerConsistency d₂)
    (hp : d₁.p = d₂.p)
    (ha : d₁.ap = d₂.ap) :
    d₁.pointCount = d₂.pointCount := by
  exact_mod_cast ( by linarith [ h₁.symm, h₂.symm, show ( d₁.p : ℤ ) = d₂.p from mod_cast hp, show ( d₁.ap : ℤ ) = d₂.ap from mod_cast ha ] : ( d₁.pointCount : ℤ ) = d₂.pointCount )

/-
**Full extensionality for local Euler data.**
Two `LocalEulerData` packages with good-reduction consistency, the same prime,
and the same Frobenius trace must be identical as data.
-/
theorem local_euler_data_ext
    (d₁ d₂ : LocalEulerData)
    (h₁ : goodEulerConsistency d₁)
    (h₂ : goodEulerConsistency d₂)
    (hp : d₁.p = d₂.p)
    (ha : d₁.ap = d₂.ap) :
    d₁ = d₂ := by
  -- Since the prime and trace are the same, the point count must be the same by the definition of goodEulerConsistency.
  have h_pointCount : d₁.pointCount = d₂.pointCount := by
    exact_mod_cast ( by linarith [ h₁.symm, h₂.symm, show ( d₁.p : ℤ ) = d₂.p from mod_cast hp, show ( d₁.ap : ℤ ) = d₂.ap from mod_cast ha ] : ( d₁.pointCount : ℤ ) = d₂.pointCount );
  cases d₁ ; cases d₂ ; aesop

/-!
### Reusable infrastructure: Euler polynomial evaluation

The local L-factor at a good prime is L_p(T) = 1 - a_p T + p T².
We show this is determined by the pair (a_p, p) and provide an
evaluation formula.
-/

/-- The local Euler polynomial evaluated at a point T in any commutative ring
with a ℤ-algebra structure. -/
noncomputable def LocalEulerData.eulerPolyEval (L : LocalEulerData) (T : ℝ) : ℝ :=
  1 - (L.ap : ℝ) * T + (L.p : ℝ) * T ^ 2

/-
Two local data with the same prime and trace give the same Euler polynomial
evaluation at every point.
-/
theorem local_euler_poly_eval_ext
    (d₁ d₂ : LocalEulerData)
    (hp : d₁.p = d₂.p)
    (ha : d₁.ap = d₂.ap)
    (T : ℝ) :
    d₁.eulerPolyEval T = d₂.eulerPolyEval T := by
  unfold LocalEulerData.eulerPolyEval; aesop;

/-!
## Commentary

**Strategy A succeeded**: The Euler polynomial `1 - a_p T + p T²` has coefficients
that depend only on `a_p` and `p`. The proof is a direct case analysis on `Fin 3`
followed by rewriting with `hp` and `ha`.

**Why Strategy B was not needed**: The point-count identity `N = p + 1 - a_p` provides
a logically equivalent route, but requires unfolding `goodEulerConsistency` and working
with integer arithmetic. We prove the point-count corollary separately.

**Why Strategy C was deferred**: The `X`-adic evaluation approach yields a reusable
abstraction for higher-rank motives, but is unnecessary for the degree-2 case. We
provide the evaluation extensionality theorem as partial infrastructure.
-/