/-
  # Finite Abelian Harmonic Analysis: Definitions

  Core definitions for spectral decomposition of the regular representation
  of finite abelian groups over ℂ.
-/
import Mathlib

open Finset Complex BigOperators

noncomputable section

/-! ## Character vectors and convolution -/

/-- The character vector associated to a multiplicative character χ : G →* ℂˣ.
    This is the function `g ↦ χ(g)` viewed as an element of the function space `G → ℂ`. -/
def charVec {G : Type*} [CommGroup G] (χ : G →* ℂˣ) : G → ℂ :=
  fun g => ((χ g : ℂˣ) : ℂ)

/-- Convolution of two functions on a finite abelian group. -/
def convFun (G : Type*) [CommGroup G] [Fintype G]
    (f v : G → ℂ) : G → ℂ :=
  fun x => ∑ y : G, f y * v (y⁻¹ * x)

/-- A linear operator on `G → ℂ` is translation-equivariant if it commutes
    with left translation by any group element. -/
def IsTranslationEquivariant {G : Type*} [CommGroup G]
    (T : (G → ℂ) → (G → ℂ)) : Prop :=
  ∀ g v x, T (fun y => v (g * y)) x = T v (g * x)

/-- The Fourier coefficient of `f` at character `χ`. -/
def mulFourierCoeff {G : Type*} [CommGroup G] [Fintype G]
    (f : G → ℂ) (χ : G →* ℂˣ) : ℂ :=
  ∑ y : G, f y * ((χ y : ℂˣ) : ℂ)⁻¹

/-- Structure packaging the spectral decomposition data of the regular representation. -/
structure RegularCharacterDecomposition (G : Type*) [CommGroup G] [Fintype G] where
  /-- The complete set of distinct characters -/
  chars : Finset (G →* ℂˣ)
  /-- The character set has cardinality equal to |G| -/
  complete : chars.card = Fintype.card G
  /-- Characters separate points: if all characters agree on g and h, then g = h -/
  separates_points : ∀ {g h : G}, (∀ χ ∈ chars, χ g = χ h) → g = h

/-- Structure packaging an eigenbasis decomposition for convolution operators. -/
structure AbelianRegularSpectrum (G : Type*) [CommGroup G] [Fintype G] where
  /-- The complete set of characters forming the eigenbasis -/
  chars : Finset (G →* ℂˣ)
  /-- Eigenvector function: the character vector for each character -/
  basisVec : (G →* ℂˣ) → G → ℂ
  /-- Eigenvalue function: maps a convolution kernel and character to its eigenvalue -/
  eigenvalue : (G → ℂ) → (G →* ℂˣ) → ℂ
  /-- Completeness: the character set has cardinality |G| -/
  complete : chars.card = Fintype.card G
  /-- Each basis vector is the character vector -/
  basisVec_eq : ∀ χ ∈ chars, basisVec χ = charVec χ
  /-- Eigenvalue formula: eigenvalue is the Fourier coefficient -/
  eigenvalue_eq : ∀ χ ∈ chars, ∀ f, eigenvalue f χ = mulFourierCoeff f χ

end