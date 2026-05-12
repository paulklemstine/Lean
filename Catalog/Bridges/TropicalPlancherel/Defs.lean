/-
# Tropical Plancherel Reconstruction: Core Definitions

This file establishes the foundational definitions for a tropical analogue of the
Satake–Plancherel reconstruction paradigm for commutative idempotent semirings.

## Mathematical Context

In classical harmonic analysis, the Plancherel theorem says that functions on a group
are determined by their Fourier transforms — evaluations against characters. We develop
a parallel theory where:
- The "Fourier dual" consists of tropical spherical characters: semiring morphisms
  into a min-plus tropical semiring.
- The "Fourier transform" evaluates a semiring element at all characters.
- "Reconstruction" means proving that the transform is injective (faithful).

The key objects are:
- `TropicalCharacter H 𝕋`: a morphism `H → 𝕋` preserving idempotent addition as `min`
  and multiplication as `+`.
- `tropicalTransform`: the map `h ↦ (χ ↦ χ(h))` from `H` to the function space.
- `FiniteExtremalSpectrum`: a finite set of characters sufficient for reconstruction.
- `transformFingerprint`: a finite evaluation vector for certified equality checking.
-/

import Mathlib

set_option maxHeartbeats 400000

/-! ## Idempotent Addition -/

/-- A type has idempotent addition if `a + a = a` for all elements. This is the
characteristic property of lattice-like semirings where addition acts as `min` or `max`. -/
class IdempotentAdd (α : Type*) [Add α] : Prop where
  add_idem : ∀ a : α, a + a = a

theorem IdempotentAdd.idem {α : Type*} [Add α] [IdempotentAdd α] (a : α) : a + a = a :=
  IdempotentAdd.add_idem a

/-! ## Tropical Character -/

/-- A **tropical spherical character** on a type `H` (with semiring-like operations)
with values in a linearly ordered type `𝕋` (with additive monoid structure and a top).

Mathematically, this is a semiring morphism `H → 𝕋` where:
- Addition in `H` maps to `min` in `𝕋` (tropical addition)
- Multiplication in `H` maps to `+` in `𝕋` (tropical multiplication)
- Zero of `H` maps to `⊤` (tropical zero / additive identity of min)
- One of `H` maps to `0` (tropical one / multiplicative identity) -/
structure TropicalCharacter (H : Type*) (𝕋 : Type*)
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋] where
  toFun : H → 𝕋
  map_add' : ∀ a b : H, toFun (a + b) = min (toFun a) (toFun b)
  map_mul' : ∀ a b : H, toFun (a * b) = toFun a + toFun b
  map_zero' : toFun 0 = ⊤
  map_one' : toFun 1 = 0

attribute [simp] TropicalCharacter.map_zero' TropicalCharacter.map_one'

namespace TropicalCharacter

variable {H 𝕋 : Type*}
  [Add H] [Mul H] [Zero H] [One H]
  [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]

instance : CoeFun (TropicalCharacter H 𝕋) (fun _ => H → 𝕋) where
  coe := TropicalCharacter.toFun

@[simp] theorem coe_toFun (χ : TropicalCharacter H 𝕋) : χ.toFun = ⇑χ := rfl

theorem map_add (χ : TropicalCharacter H 𝕋) (a b : H) :
    χ (a + b) = min (χ a) (χ b) := χ.map_add' a b

theorem map_mul (χ : TropicalCharacter H 𝕋) (a b : H) :
    χ (a * b) = χ a + χ b := χ.map_mul' a b

theorem map_zero (χ : TropicalCharacter H 𝕋) : χ 0 = ⊤ := χ.map_zero'

theorem map_one (χ : TropicalCharacter H 𝕋) : χ 1 = 0 := χ.map_one'

/-- Two tropical characters are equal iff they agree on all elements. -/
@[ext]
theorem ext {χ₁ χ₂ : TropicalCharacter H 𝕋} (h : ∀ x : H, χ₁ x = χ₂ x) :
    χ₁ = χ₂ := by
  cases χ₁; cases χ₂; simp only [mk.injEq]; ext x; exact h x

end TropicalCharacter

/-! ## Spherical Tropical Spectrum -/

/-- The type of all tropical spherical characters on `H` with values in `𝕋`. -/
abbrev SphTrop (H : Type*) (𝕋 : Type*)
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋] :=
  TropicalCharacter H 𝕋

/-! ## Tropical Spherical Transform -/

/-- The **tropical spherical transform** sends an element `h : H` to the function
evaluating each character at `h`:  `𝓕(h)(χ) = χ(h)`.

This is the tropical analogue of the Fourier/Gelfand transform. -/
def tropicalTransform {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (h : H) : SphTrop H 𝕋 → 𝕋 :=
  fun χ => χ h

@[simp]
theorem tropicalTransform_apply {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (h : H) (χ : SphTrop H 𝕋) :
    tropicalTransform h χ = χ h := rfl

/-! ## Semisimplicity / Separation Hypothesis -/

/-- A **semisimple tropical spectrum** asserts that tropical spherical characters
separate points of `H`. This is the tropical analogue of the condition that
characters separate points in Gelfand theory. -/
class SemisimpleTropicalSpectrum (H : Type*) (𝕋 : Type*)
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋] : Prop where
  sep : ∀ {h₁ h₂ : H}, h₁ ≠ h₂ → ∃ χ : SphTrop H 𝕋, χ h₁ ≠ χ h₂

/-! ## Finite Extremal Spectrum -/

/-- A **finite extremal spectrum** is a finite collection of tropical spherical characters.
These play the role of extremal points of a spectral measure. -/
structure FiniteExtremalSpectrum (H : Type*) (𝕋 : Type*)
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋] where
  PointType : Type*
  [fintype_points : Fintype PointType]
  [deceq_points : DecidableEq PointType]
  val : PointType → SphTrop H 𝕋

attribute [instance] FiniteExtremalSpectrum.fintype_points
attribute [instance] FiniteExtremalSpectrum.deceq_points

/-- A finite extremal spectrum is **complete** if its characters separate all
distinct elements of `H`. -/
def SpectrumComplete {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) : Prop :=
  ∀ {h₁ h₂ : H}, h₁ ≠ h₂ → ∃ p : E.PointType, (E.val p) h₁ ≠ (E.val p) h₂

/-! ## Transform Fingerprint -/

/-- The **transform fingerprint** evaluates `h` at each character in a finite spectrum,
producing a finite vector of tropical values. -/
def transformFingerprint {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (h : H) : E.PointType → 𝕋 :=
  fun p => (E.val p) h

@[simp]
theorem transformFingerprint_apply {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (h : H) (p : E.PointType) :
    transformFingerprint E h p = (E.val p) h := rfl

/-! ## Equality Decision via Fingerprint -/

/-- Decide equality of two elements by comparing fingerprints pointwise. -/
noncomputable def decideEqViaFingerprint {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [DecidableEq 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (a b : H) : Bool :=
  decide (transformFingerprint E a = transformFingerprint E b)

/-! ## Radical Congruence -/

/-- The **radical congruence** on `H` induced by a set of tropical characters.
Two elements are radical-equivalent if no character in the set distinguishes them.
This is the tropical analogue of the Jacobson radical / intersection of maximal ideals. -/
def radicalCongruence {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (S : Set (TropicalCharacter H 𝕋)) : Setoid H where
  r a b := ∀ χ ∈ S, χ.toFun a = χ.toFun b
  iseqv := {
    refl := fun _ _ _ => rfl
    symm := fun h χ hχ => (h χ hχ).symm
    trans := fun h₁ h₂ χ hχ => (h₁ χ hχ).trans (h₂ χ hχ)
  }