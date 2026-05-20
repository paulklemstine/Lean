/-
# Prime-Modular Morse Stability: Definitions

This file introduces the core definitions for an arithmetic theory of loss landscapes:
critical fibers, separable losses, Morse index surrogates, and modular profiles.

These definitions bridge finite-field arithmetic with real Morse-theoretic complexity
of polynomial optimization problems.
-/

import Mathlib

open Polynomial

namespace PrimeModularMorse

/-! ## One-dimensional critical fibers -/

/-- The one-dimensional critical fiber of a polynomial `f ∈ ℤ[X]` at value `t` over a ring `R`:
the set of points where `f'(x) = 0` and `f(x) = t`. -/
def critFiber1D (R : Type*) [CommRing R] (f : Polynomial ℤ) (t : R) : Set R :=
  {x : R | eval x (map (Int.castRingHom R) (derivative f)) = 0 ∧
            eval x (map (Int.castRingHom R) f) = t}

/-- A critical point over `R` is one where the derivative vanishes. -/
def isCriticalPoint (R : Type*) [CommRing R] (f : Polynomial ℤ) (x : R) : Prop :=
  eval x (map (Int.castRingHom R) (derivative f)) = 0

/-- A critical point is nondegenerate if the second derivative is nonzero. -/
def isNondegenerateCriticalPoint (R : Type*) [CommRing R] (f : Polynomial ℤ) (x : R) : Prop :=
  isCriticalPoint R f x ∧
  eval x (map (Int.castRingHom R) (derivative (derivative f))) ≠ 0

/-! ## Diagonal quadratic losses -/

/-- The real Morse index of a diagonal quadratic loss with sign pattern `ε`:
the number of coordinates with negative coefficient. -/
noncomputable def realMorseIndexDiag {n : ℕ} (ε : Fin n → ℤ) : ℕ :=
  Fintype.card {i : Fin n // ε i < 0}

/-- Count of coordinates where `ε i = -1`. -/
noncomputable def negOneCount {n : ℕ} (ε : Fin n → ℤ) : ℕ :=
  Fintype.card {i : Fin n // ε i = -1}

/-- The Hessian determinant for a diagonal quadratic `∑ εᵢ xᵢ² + cᵢ xᵢ + d`
is `∏ (2 * εᵢ)`. -/
def diagHessianDet {n : ℕ} (ε : Fin n → ℤ) : ℤ :=
  ∏ i : Fin n, (2 * ε i)

/-- The product of the diagonal coefficients `∏ εᵢ`, which determines
the sign of the Hessian determinant up to powers of 2. -/
def diagSignProduct {n : ℕ} (ε : Fin n → ℤ) : ℤ :=
  ∏ i : Fin n, ε i

/-! ## Prime exceptional sets -/

/-- The exceptional set for a nondegenerate integer critical point:
the set of primes dividing the second derivative value `f''(a)`. -/
noncomputable def exceptionalPrimesOfCritPoint (f : Polynomial ℤ) (a : ℤ) : Finset ℕ :=
  (eval a (derivative (derivative f))).natAbs.primeFactors

/-! ## Separable losses -/

/-- A "separable loss" data structure: a family of univariate polynomials,
one per coordinate. The loss function is `L(θ) = ∑ᵢ fᵢ(θᵢ)`. -/
def SeparableLossData (n : ℕ) := Fin n → Polynomial ℤ

/-- The critical set of a separable loss `(f₁, ..., fₙ)` over `R`:
points where each coordinate is a critical point of the corresponding `fᵢ`. -/
def separableCritSet {n : ℕ} (R : Type*) [CommRing R]
    (fs : SeparableLossData n) : Set (Fin n → R) :=
  {θ | ∀ i, isCriticalPoint R (fs i) (θ i)}

/-- The separable critical fiber at value `t`: critical points whose coordinate values sum to `t`. -/
def separableCritFiber {n : ℕ} (R : Type*) [CommRing R]
    (fs : SeparableLossData n) (t : R) : Set (Fin n → R) :=
  {θ | (∀ i, isCriticalPoint R (fs i) (θ i)) ∧
       ∑ i, eval (θ i) (map (Int.castRingHom R) (fs i)) = t}

/-- Decomposed form: a point in the separable critical fiber can be described
by value assignments `τ` summing to `t` with each coordinate in the 1D critical fiber. -/
def separableCritFiberDecomp {n : ℕ} (R : Type*) [CommRing R]
    (fs : SeparableLossData n) (t : R) : Set (Fin n → R) :=
  {θ | ∃ τ : Fin n → R,
       (∑ i, τ i = t) ∧
       ∀ i, θ i ∈ critFiber1D R (fs i) (τ i)}

/-! ## Sign product and parity -/

/-- The sign product of a ±1 sequence: `∏ εᵢ = (-1)^(number of -1 entries)`. -/
def signProductFormula (_n : ℕ) (k : ℕ) : ℤ :=
  (-1) ^ k

end PrimeModularMorse