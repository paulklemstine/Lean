/-
# Hilbert class field reciprocity and the GL(1) correspondence

This file combines the catalog's Hilbert-class-field reciprocity interface with its
ideal-class-group algebra.  For a number field `K` and a finite Galois extension `H/K`, the
load-bearing datum is an Artin reciprocity isomorphism

  `Gal(H/K) ≃* ClassGroup (RingOfIntegers K)`.

From this datum we prove that the Galois group is abelian, construct the induced GL(1)
correspondence between ideal-class characters and one-dimensional Galois representations, and
relate triviality of the extension to principality of ideals.  The construction is the direct
number-field analogue of the cyclotomic character correspondence already in the catalog.
-/

import Catalog.Novelty.HilbertClassFieldReciprocity
import Catalog.Algebra.IdealClassGroupBridge

open NumberField

namespace HilbertClassFieldLanglands

noncomputable section

variable (K : Type*) [Field K] [NumberField K]
variable (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]

/-- Characters of the ideal class group, the unramified finite-order automorphic parameters in
this algebraic model. -/
abbrev IdealClassCharacter := ClassGroup (RingOfIntegers K) →* ℂˣ

/-- One-dimensional complex representations of the Galois group of `H/K`. -/
abbrev HilbertGaloisCharacter := (H ≃ₐ[K] H) →* ℂˣ

omit [NumberField K] [FiniteDimensional K H] [IsGalois K H] in
/-- Artin reciprocity forces the Galois group of a Hilbert class field datum to be abelian. -/
theorem galoisGroup_commutative
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (σ τ : H ≃ₐ[K] H) : σ * τ = τ * σ := by
  apply e.injective
  rw [map_mul, map_mul, mul_comm]

/-- Transport an ideal-class character to a Galois character along the Artin map. -/
def classToGalois
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (χ : IdealClassCharacter K) : HilbertGaloisCharacter K H :=
  χ.comp e.toMonoidHom

/-- Transport a Galois character back to an ideal-class character along inverse Artin
reciprocity. -/
def galoisToClass
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (ρ : HilbertGaloisCharacter K H) : IdealClassCharacter K :=
  ρ.comp e.symm.toMonoidHom

omit [NumberField K] [FiniteDimensional K H] [IsGalois K H] in
/-- Transport from the Galois side to the ideal-class side and back is the identity. -/
theorem classToGalois_galoisToClass
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (ρ : HilbertGaloisCharacter K H) :
    classToGalois K H e (galoisToClass K H e ρ) = ρ := by
  ext σ
  simp [classToGalois, galoisToClass]

omit [NumberField K] [FiniteDimensional K H] [IsGalois K H] in
/-- Transport from the ideal-class side to the Galois side and back is the identity. -/
theorem galoisToClass_classToGalois
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (χ : IdealClassCharacter K) :
    galoisToClass K H e (classToGalois K H e χ) = χ := by
  ext c
  simp [classToGalois, galoisToClass]

/-- The unramified GL(1) correspondence attached to the Hilbert class field: ideal-class
characters are isomorphic, as a group, to one-dimensional complex Galois representations. -/
def unramifiedGL1Correspondence
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K)) :
    IdealClassCharacter K ≃* HilbertGaloisCharacter K H where
  toFun := classToGalois K H e
  invFun := galoisToClass K H e
  left_inv := galoisToClass_classToGalois K H e
  right_inv := classToGalois_galoisToClass K H e
  map_mul' χ ψ := by
    ext σ
    simp [classToGalois]

/-- Under Artin reciprocity, the Hilbert class field datum is trivial exactly when the ring of
integers has class number one, equivalently when it is a principal ideal ring. -/
theorem finrank_one_iff_ringOfIntegers_pid
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K)) :
    Module.finrank K H = 1 ↔ IsPrincipalIdealRing (RingOfIntegers K) := by
  rw [HilbertClassFieldReciprocity.finrank_eq_classNumber K H e]
  exact classNumber_one_iff_pid (RingOfIntegers K)

/-- If every nonzero ideal of the ring of integers is principal, then an extension equipped with
Hilbert class field reciprocity has degree one. -/
theorem finrank_one_of_all_nonzero_ideals_principal
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (hprincipal : ∀ I : Ideal (RingOfIntegers K), I ≠ ⊥ → Submodule.IsPrincipal I) :
    Module.finrank K H = 1 := by
  apply (finrank_one_iff_ringOfIntegers_pid K H e).2
  exact IsPrincipalIdealRing.of_prime_ne_bot fun P _ => hprincipal P

/-- Conversely, degree one of a Hilbert class field datum forces every nonzero ideal of the ring
of integers to be principal. -/
theorem all_nonzero_ideals_principal_of_finrank_one
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (hdegree : Module.finrank K H = 1) :
    ∀ I : Ideal (RingOfIntegers K), I ≠ ⊥ → Submodule.IsPrincipal I := by
  have hpid : IsPrincipalIdealRing (RingOfIntegers K) :=
    (finrank_one_iff_ringOfIntegers_pid K H e).1 hdegree
  intro I _
  exact hpid.principal I

end

end HilbertClassFieldLanglands