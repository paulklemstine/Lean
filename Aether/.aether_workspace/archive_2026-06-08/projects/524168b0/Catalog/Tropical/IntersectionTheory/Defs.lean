/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Intersection Theory: Core Definitions

We formalize tropical polynomials, their evaluation via the min-plus semiring,
and the key structural properties that underlie tropical intersection theory.

## Main Definitions

* `TropPoly d` — A univariate tropical polynomial of degree at most `d`,
  represented as coefficients `Fin (d + 1) → ℤ`.
* `tropEval` — Evaluation: `p(x) = min_{0 ≤ i ≤ d} (aᵢ + i · x)`
* `tropSlope` — The discrete derivative `Δp(x) = p(x + 1) - p(x)`
* `TropCurve` — A tropical curve in ℤ² (bivariate tropical polynomial)
* `StableIntersectionMult` — Stable intersection multiplicity via lattice determinant

## Mathematical Context

In tropical geometry, a polynomial `p(x₁,...,xₙ) = ⊕ᵢ (aᵢ ⊙ x^eᵢ)`
evaluates to `min_i (aᵢ + ⟨eᵢ, x⟩)` under the min-plus convention.
The **tropical variety** (or corner locus) is the set where the minimum
is achieved by at least two monomials. For univariate polynomials, these
corner points are exactly the breakpoints of the piecewise-linear concave
evaluation function.

The **tropical Bézout theorem** states that the stable intersection number
of two tropical curves of degrees `d₁` and `d₂` equals `d₁ · d₂`,
providing a tropical analogue of the classical Bézout bound.

## References

* Maclagan, Sturmfels, *Introduction to Tropical Geometry*, AMS 2015
* Mikhalkin, *Enumerative tropical algebraic geometry in ℝ²*, JAMS 2005
-/

open Finset

noncomputable section

/-! ### Univariate Tropical Polynomials -/

/-- A univariate tropical polynomial of degree at most `d`.
    The coefficient `p i` represents the tropical monomial `aᵢ ⊙ x^{⊙i}`,
    which evaluates to `aᵢ + i · x` in the min-plus semiring. -/
def TropPoly (d : ℕ) := Fin (d + 1) → ℤ

instance (d : ℕ) : Inhabited (TropPoly d) := ⟨fun _ => 0⟩

/-- The image set of a tropical polynomial's affine functions at a point `x`.
    This is the finite set `{aᵢ + i · x : 0 ≤ i ≤ d}`. -/
def tropTerms (d : ℕ) (p : TropPoly d) (x : ℤ) : Finset ℤ :=
  Finset.univ.image (fun i : Fin (d + 1) => p i + (↑i : ℤ) * x)

theorem tropTerms_nonempty (d : ℕ) (p : TropPoly d) (x : ℤ) :
    (tropTerms d p x).Nonempty := by
  simp [tropTerms]

/-- Evaluation of a tropical polynomial at `x ∈ ℤ`:
    `tropEval p x = min_{0 ≤ i ≤ d} (p(i) + i · x)` -/
def tropEval (d : ℕ) (p : TropPoly d) (x : ℤ) : ℤ :=
  (tropTerms d p x).min' (tropTerms_nonempty d p x)

/-- The discrete derivative (slope) of a tropical polynomial:
    `tropSlope p x = tropEval p (x + 1) - tropEval p x` -/
def tropSlope (d : ℕ) (p : TropPoly d) (x : ℤ) : ℤ :=
  tropEval d p (x + 1) - tropEval d p x

/-- The degree of a tropical polynomial: the maximum index in the support.
    For our representation, this is simply `d`. -/
def tropDeg (d : ℕ) (_ : TropPoly d) : ℕ := d

/-! ### Bivariate Tropical Polynomials (Tropical Curves) -/

/-- A tropical monomial in two variables: coefficient and exponent pair. -/
structure TropMonomial2 where
  coeff : ℤ
  expX : ℕ
  expY : ℕ
  deriving DecidableEq

/-- Evaluate a bivariate tropical monomial at a point (x, y) ∈ ℤ². -/
def TropMonomial2.eval (m : TropMonomial2) (x y : ℤ) : ℤ :=
  m.coeff + (↑m.expX) * x + (↑m.expY) * y

/-- The total degree of a bivariate monomial. -/
def TropMonomial2.totalDeg (m : TropMonomial2) : ℕ := m.expX + m.expY

/-- A tropical curve in ℤ² defined by a nonempty finite set of monomials.
    The curve is the corner locus of the tropical polynomial
    `f(x,y) = min_m (m.coeff + m.expX · x + m.expY · y)`. -/
structure TropCurve where
  monomials : Finset TropMonomial2
  nonempty : monomials.Nonempty

/-- The degree of a tropical curve: maximum total degree of its monomials. -/
noncomputable def TropCurve.degree (C : TropCurve) : ℕ :=
  (C.monomials.image TropMonomial2.totalDeg).max' (by simp [Finset.Nonempty]; exact C.nonempty)

/-- Evaluate a tropical curve's polynomial at a point. -/
noncomputable def TropCurve.eval (C : TropCurve) (x y : ℤ) : ℤ :=
  (C.monomials.image (fun m => m.eval x y)).min'
    (by simp [Finset.Nonempty]; exact C.nonempty)

/-- A point (x, y) is in the corner locus if the minimum is achieved
    by at least two distinct monomials. -/
def TropCurve.inCornerLocus (C : TropCurve) (x y : ℤ) : Prop :=
  ∃ m₁ m₂ : TropMonomial2, m₁ ∈ C.monomials ∧ m₂ ∈ C.monomials ∧
    m₁ ≠ m₂ ∧ m₁.eval x y = C.eval x y ∧ m₂.eval x y = C.eval x y

/-! ### Stable Intersection Multiplicity -/

/-- The stable intersection multiplicity of two tropical curves at a transverse
    intersection point is the absolute value of the lattice determinant of
    the primitive edge directions.

    Given edge directions `(u₁, u₂)` from curve C₁ and `(v₁, v₂)` from C₂,
    with respective weights `w₁` and `w₂`, the multiplicity is
    `|u₁ · v₂ - u₂ · v₁| · w₁ · w₂`. -/
def stableIntersectionMult (u₁ u₂ v₁ v₂ : ℤ) (w₁ w₂ : ℕ) : ℕ :=
  (Int.natAbs (u₁ * v₂ - u₂ * v₁)) * w₁ * w₂

/-- The lattice determinant of two direction vectors in ℤ². -/
def latticeDet (u₁ u₂ v₁ v₂ : ℤ) : ℤ := u₁ * v₂ - u₂ * v₁

/-! ### Tropical Resultant (1D intersection theory) -/

/-- The tropical resultant matrix entry for polynomials of degrees d₁, d₂.
    This is a (d₁ + d₂) × (d₁ + d₂) matrix constructed from the
    coefficients of the two polynomials. -/
def tropResultantEntry (d₁ d₂ : ℕ) (p : TropPoly d₁) (q : TropPoly d₂)
    (i j : Fin (d₁ + d₂)) : WithTop ℤ :=
  if h : (j : ℕ) ≥ (i : ℕ) ∧ (j : ℕ) - (i : ℕ) ≤ d₁ ∧ (i : ℕ) < d₂ then
    (p ⟨(j : ℕ) - (i : ℕ), by omega⟩ : ℤ)
  else if h : (j : ℕ) ≥ ((i : ℕ) - d₂) ∧ (j : ℕ) - ((i : ℕ) - d₂) ≤ d₂ ∧
             (i : ℕ) ≥ d₂ then
    (q ⟨(j : ℕ) - ((i : ℕ) - d₂), by omega⟩ : ℤ)
  else
    ⊤

end