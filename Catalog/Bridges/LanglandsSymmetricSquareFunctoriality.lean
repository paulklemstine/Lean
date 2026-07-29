import Mathlib

/-!
# The unramified symmetric-square transfer from GL(2) to GL(3)

This file gives a self-contained local formalization of the Satake-parameter part of
Langlands functoriality.  An unramified representation is represented by its finite
family of Satake parameters.  Its standard local L-factor is encoded by the Euler
denominator

`∏ᵢ (1 - αᵢ X)`.

For parameters `(a,b)` on GL(2), the symmetric-square transfer has parameters
`(a², ab, b²)` on GL(3).  The results below prove compatibility with scalar extension,
central characters, standard local L-factors, and the decomposition of the tensor-square
Euler denominator into symmetric-square and determinant factors.
-/

namespace LanglandsFunctoriality

open scoped BigOperators
open Polynomial

/-- Unramified automorphic data of rank `n`, represented by its Satake parameters. -/
@[ext] structure UnramifiedAutomorphicRepresentation (R : Type*) (n : ℕ) where
  satake : Fin n → R

namespace UnramifiedAutomorphicRepresentation

variable {R S : Type*} [CommRing R] [CommRing S]

/-- Scalar extension of unramified Satake data. -/
def map (f : R →+* S) (π : UnramifiedAutomorphicRepresentation R n) :
    UnramifiedAutomorphicRepresentation S n :=
  ⟨fun i => f (π.satake i)⟩

/-- The Euler denominator of the standard unramified local L-factor. -/
noncomputable def eulerDenominator (π : UnramifiedAutomorphicRepresentation R n) : Polynomial R :=
  ∏ i : Fin n, (1 - C (π.satake i) * X)

/-- The product of Satake parameters, corresponding to the unramified central character. -/
def centralCharacter (π : UnramifiedAutomorphicRepresentation R n) : R :=
  ∏ i : Fin n, π.satake i

/-- The GL(2) unramified datum with Satake parameters `(a,b)`. -/
def gl2 (a b : R) : UnramifiedAutomorphicRepresentation R 2 :=
  ⟨![a, b]⟩

/-- The symmetric-square transfer from GL(2) to GL(3), on Satake parameters. -/
def symmetricSquare (π : UnramifiedAutomorphicRepresentation R 2) :
    UnramifiedAutomorphicRepresentation R 3 :=
  ⟨![π.satake 0 ^ 2, π.satake 0 * π.satake 1, π.satake 1 ^ 2]⟩

/-- The determinant character attached to GL(2) Satake data. -/
def determinantCharacter (π : UnramifiedAutomorphicRepresentation R 2) :
    UnramifiedAutomorphicRepresentation R 1 :=
  ⟨![π.satake 0 * π.satake 1]⟩

/-- The tensor-square parameter list, with multiplicity, for a GL(2) datum. -/
def tensorSquare (π : UnramifiedAutomorphicRepresentation R 2) :
    UnramifiedAutomorphicRepresentation R 4 :=
  ⟨![π.satake 0 ^ 2, π.satake 0 * π.satake 1,
      π.satake 0 * π.satake 1, π.satake 1 ^ 2]⟩

/-- Scalar extension commutes with the symmetric-square Langlands transfer. -/
theorem map_symmetricSquare (f : R →+* S)
    (π : UnramifiedAutomorphicRepresentation R 2) :
    map f (symmetricSquare π) = symmetricSquare (map f π) := by
  ext i
  fin_cases i <;> simp [map, symmetricSquare]

/-- Scalar extension commutes with formation of standard local Euler denominators. -/
theorem eulerDenominator_map (f : R →+* S)
    (π : UnramifiedAutomorphicRepresentation R n) :
    (π.eulerDenominator.map f) = (π.map f).eulerDenominator := by
  simp [eulerDenominator, Polynomial.map_prod, map]

/-- The central character of `Sym² π` is the cube of the central character of `π`. -/
theorem centralCharacter_symmetricSquare
    (π : UnramifiedAutomorphicRepresentation R 2) :
    (symmetricSquare π).centralCharacter = π.centralCharacter ^ 3 := by
  simp [centralCharacter, symmetricSquare, Fin.prod_univ_succ]
  ring

/-- Explicit standard Euler denominator for the GL(2) datum `(a,b)`. -/
theorem gl2_eulerDenominator (a b : R) :
    (gl2 a b).eulerDenominator =
      (1 - C a * X) * (1 - C b * X) := by
  simp [eulerDenominator, gl2, Fin.prod_univ_succ]

/-- Explicit standard Euler denominator for its GL(3) symmetric-square lift. -/
theorem symmetricSquare_eulerDenominator (a b : R) :
    (symmetricSquare (gl2 a b)).eulerDenominator =
      (1 - C (a ^ 2) * X) * (1 - C (a * b) * X) *
        (1 - C (b ^ 2) * X) := by
  simp [eulerDenominator, symmetricSquare, gl2, Fin.prod_univ_succ]
  ring

/-- Local Rankin--Selberg decomposition:
`L(X, π ⊗ π)⁻¹ = L(X, Sym² π)⁻¹ L(X, det π)⁻¹`.

The repeated middle parameter in the tensor square is split between the symmetric-square
factor and the determinant factor. -/
theorem tensorSquare_eulerDenominator_factorization
    (π : UnramifiedAutomorphicRepresentation R 2) :
    (tensorSquare π).eulerDenominator =
      (symmetricSquare π).eulerDenominator *
        (determinantCharacter π).eulerDenominator := by
  simp [eulerDenominator, tensorSquare, symmetricSquare, determinantCharacter,
    Fin.prod_univ_succ]
  ring

/-- The Hecke trace of the GL(3) lift is `a² + ab + b²`. -/
theorem symmetricSquare_trace (a b : R) :
    ∑ i : Fin 3, (symmetricSquare (gl2 a b)).satake i =
      a ^ 2 + a * b + b ^ 2 := by
  simp [symmetricSquare, gl2, Fin.sum_univ_succ]
  ring

/-- The symmetric-square trace satisfies the degree-three telescoping identity. -/
theorem symmetricSquare_trace_telescope (a b : R) :
    (a - b) * (∑ i : Fin 3, (symmetricSquare (gl2 a b)).satake i) =
      a ^ 3 - b ^ 3 := by
  rw [symmetricSquare_trace]
  ring

end UnramifiedAutomorphicRepresentation
end LanglandsFunctoriality