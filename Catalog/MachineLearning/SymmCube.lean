/-
  # Symmetric Cube Euler Denominator in Trace-Determinant Invariants

  This file proves that the symmetric-cube local Euler denominator for a rank-2
  Satake parameter depends only on the conjugacy invariants t = α + β (trace)
  and d = α * β (determinant), and is therefore a universal polynomial in t, d, and X.

  This is the algebraic core of local Langlands functoriality for GL₂ symmetric
  powers: local factors of symmetric-power lifts depend only on semisimple
  conjugacy data.
-/
import Mathlib

open Complex

/-! ## Definitions -/

/-- The trace parameter of a rank-2 Satake parameter (α, β). -/
def traceParam (α β : ℂ) : ℂ := α + β

/-- The determinant parameter of a rank-2 Satake parameter (α, β). -/
def detParam (α β : ℂ) : ℂ := α * β

/-- The symmetric-cube local Euler denominator for Satake parameters (α, β). -/
def symmCubeEulerDen (α β X : ℂ) : ℂ :=
  (1 - α ^ 3 * X) * (1 - α ^ 2 * β * X) * (1 - α * β ^ 2 * X) * (1 - β ^ 3 * X)

/-- The universal trace-determinant polynomial for the symmetric cube Euler factor.
    Given trace t = α + β, determinant d = α * β, and variable X, this polynomial
    equals the symmetric-cube Euler denominator. -/
def symmCubeTraceDetPoly (t d X : ℂ) : ℂ :=
  1 - (t ^ 3 - 2 * t * d) * X
    + (d * t ^ 4 - 3 * d ^ 2 * t ^ 2 + 2 * d ^ 3) * X ^ 2
    - (d ^ 3 * (t ^ 3 - 2 * t * d)) * X ^ 3
    + d ^ 6 * X ^ 4

/-! ## Coefficient identities

These lemmas express the elementary symmetric polynomials of the symmetric-cube
weights {α³, α²β, αβ², β³} in terms of trace t = α+β and determinant d = αβ.
-/

/-- The first elementary symmetric polynomial of the Sym³ weights:
    e₁ = α³ + α²β + αβ² + β³ = t³ − 2td. -/
lemma symmCube_e1 (α β : ℂ) :
    α ^ 3 + α ^ 2 * β + α * β ^ 2 + β ^ 3 =
      (α + β) ^ 3 - 2 * (α + β) * (α * β) := by
  ring

/-- The second elementary symmetric polynomial of the Sym³ weights:
    e₂ = d·t⁴ − 3d²·t² + 2d³. -/
lemma symmCube_e2 (α β : ℂ) :
    α ^ 3 * (α ^ 2 * β) + α ^ 3 * (α * β ^ 2) + α ^ 3 * β ^ 3
    + (α ^ 2 * β) * (α * β ^ 2) + (α ^ 2 * β) * β ^ 3
    + (α * β ^ 2) * β ^ 3 =
      (α * β) * (α + β) ^ 4 - 3 * (α * β) ^ 2 * (α + β) ^ 2
        + 2 * (α * β) ^ 3 := by
  ring

/-- The third elementary symmetric polynomial of the Sym³ weights:
    e₃ = d³ · (t³ − 2td). -/
lemma symmCube_e3 (α β : ℂ) :
    α ^ 3 * (α ^ 2 * β) * (α * β ^ 2)
    + α ^ 3 * (α ^ 2 * β) * β ^ 3
    + α ^ 3 * (α * β ^ 2) * β ^ 3
    + (α ^ 2 * β) * (α * β ^ 2) * β ^ 3 =
      (α * β) ^ 3 * ((α + β) ^ 3 - 2 * (α + β) * (α * β)) := by
  ring

/-- The fourth elementary symmetric polynomial of the Sym³ weights:
    e₄ = (αβ)⁶ = d⁶. -/
lemma symmCube_e4 (α β : ℂ) :
    α ^ 3 * (α ^ 2 * β) * (α * β ^ 2) * β ^ 3 = (α * β) ^ 6 := by
  ring

/-- The identity α³ + β³ = (α+β)³ − 3(α+β)(αβ), used in the quadratic-pair
    factorization approach. -/
lemma cube_sum_in_trace_det (α β : ℂ) :
    α ^ 3 + β ^ 3 = (α + β) ^ 3 - 3 * (α + β) * (α * β) := by
  ring

/-! ## Main theorems -/

/-- **Symmetric-cube Euler denominator in trace-determinant form.**

The symmetric-cube local Euler denominator for a rank-2 Satake parameter (α, β)
can be expressed as a universal polynomial in the trace t = α + β, the determinant
d = α * β, and the variable X:

  (1 − α³X)(1 − α²βX)(1 − αβ²X)(1 − β³X)
    = 1 − (t³ − 2td)X + (dt⁴ − 3d²t² + 2d³)X²
        − d³(t³ − 2td)X³ + d⁶X⁴

This is the n = 3 case of the principle that all symmetric-power Euler factors
for GL₂ factor through the invariant ring ℤ[t, d]. -/
theorem symmCube_denominator_in_trace_det (α β X : ℂ) :
    (1 - α ^ 3 * X) * (1 - α ^ 2 * β * X) * (1 - α * β ^ 2 * X) * (1 - β ^ 3 * X) =
      1
        - (((α + β) ^ 3 - 2 * (α + β) * (α * β)) * X)
        + (((α * β) * (α + β) ^ 4 - 3 * (α * β) ^ 2 * (α + β) ^ 2 + 2 * (α * β) ^ 3) * X ^ 2)
        - (((α * β) ^ 3 * ((α + β) ^ 3 - 2 * (α + β) * (α * β))) * X ^ 3)
        + ((α * β) ^ 6 * X ^ 4) := by
  ring

/-- The symmetric-cube Euler denominator equals the universal trace-det polynomial
    evaluated at t = α + β, d = α * β. -/
theorem symmCubeEulerDen_eq_traceDetPoly (α β X : ℂ) :
    symmCubeEulerDen α β X = symmCubeTraceDetPoly (α + β) (α * β) X := by
  unfold symmCubeEulerDen symmCubeTraceDetPoly
  ring

/-- The symmetric-cube Euler denominator equals the universal trace-det polynomial
    evaluated at the trace and determinant parameters. -/
theorem symmCubeEulerDen_trace_det (α β X : ℂ) :
    symmCubeEulerDen α β X = symmCubeTraceDetPoly (traceParam α β) (detParam α β) X := by
  unfold symmCubeEulerDen symmCubeTraceDetPoly traceParam detParam
  ring

/-- **Invariant-ring statement**: the symmetric-cube Euler denominator is a function
    of α + β, α * β, and X alone. -/
theorem symmCubeEulerDen_eq_trace_det_formula (α β X : ℂ) :
    ∃ P : ℂ → ℂ → ℂ → ℂ,
      symmCubeEulerDen α β X = P (α + β) (α * β) X :=
  ⟨symmCubeTraceDetPoly, symmCubeEulerDen_eq_traceDetPoly α β X⟩

/-- **Conjugacy invariance**: if two pairs (α, β) and (α', β') have the same trace
    and determinant, they produce the same symmetric-cube Euler factor. -/
theorem symmCubeEulerDen_conjugacy_invariant (α β α' β' X : ℂ)
    (h_trace : α + β = α' + β')
    (h_det : α * β = α' * β') :
    symmCubeEulerDen α β X = symmCubeEulerDen α' β' X := by
  rw [symmCubeEulerDen_eq_traceDetPoly, symmCubeEulerDen_eq_traceDetPoly,
      h_trace, h_det]

/-- The symmetric-cube Euler denominator is symmetric in α and β,
    i.e., swapping eigenvalues does not change the local factor. -/
theorem symmCubeEulerDen_symm (α β X : ℂ) :
    symmCubeEulerDen α β X = symmCubeEulerDen β α X := by
  apply symmCubeEulerDen_conjugacy_invariant
  · ring
  · ring

/-! ## Quadratic-pair factorization

An alternative proof route that factors the four-term product into two structured
quadratics, revealing the self-reciprocal structure up to determinant twist. -/

/-- Factor pairing: the "outer" pair groups α³ and β³. -/
lemma outer_pair (α β X : ℂ) :
    (1 - α ^ 3 * X) * (1 - β ^ 3 * X) =
      1 - (α ^ 3 + β ^ 3) * X + (α * β) ^ 3 * X ^ 2 := by
  ring

/-- Factor pairing: the "inner" pair groups α²β and αβ². -/
lemma inner_pair (α β X : ℂ) :
    (1 - α ^ 2 * β * X) * (1 - α * β ^ 2 * X) =
      1 - (α * β) * (α + β) * X + (α * β) ^ 3 * X ^ 2 := by
  ring

/-! ## Generic version over any commutative ring -/

/-- The symmetric-cube identity holds in any commutative ring, not just ℂ. -/
theorem symmCube_denominator_generic {R : Type*} [CommRing R] (α β X : R) :
    (1 - α ^ 3 * X) * (1 - α ^ 2 * β * X) * (1 - α * β ^ 2 * X) * (1 - β ^ 3 * X) =
      1
        - (((α + β) ^ 3 - 2 * (α + β) * (α * β)) * X)
        + (((α * β) * (α + β) ^ 4 - 3 * (α * β) ^ 2 * (α + β) ^ 2 + 2 * (α * β) ^ 3) * X ^ 2)
        - (((α * β) ^ 3 * ((α + β) ^ 3 - 2 * (α + β) * (α * β))) * X ^ 3)
        + ((α * β) ^ 6 * X ^ 4) := by
  ring