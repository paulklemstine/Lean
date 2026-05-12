/-
# Tropical Plancherel Reconstruction: Main Theorems

This file proves the core theorems of tropical Plancherel reconstruction theory:

1. **Separation** (Theorem 1): Tropical characters separate points modulo the radical.
2. **Faithfulness** (Theorem 2): The tropical transform is injective under semisimplicity.
3. **Fingerprint Completeness** (Theorem 4): Finite fingerprints decide equality.
4. **Transform Compatibility**: The transform respects semiring operations.

Together, these establish that the tropical spherical transform provides a complete
spectral invariant theory for commutative idempotent semirings — the first formal
tropical analogue of the Plancherel–Satake reconstruction paradigm.
-/

import Bridges.TropicalPlancherel.Defs

set_option maxHeartbeats 400000

open TropicalCharacter

/-! ## Section 1: Transform Compatibility with Semiring Operations

The tropical transform `𝓕 : H → (SphTrop H 𝕋 → 𝕋)` respects the semiring
structure: addition maps to pointwise min, multiplication maps to pointwise +.
This is the tropical analogue of the Fourier transform being a ring homomorphism.
-/

/-
The tropical transform sends addition to pointwise min.
  `𝓕(a + b)(χ) = min(𝓕(a)(χ), 𝓕(b)(χ))`
-/
theorem tropicalTransform_add {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (a b : H) (χ : SphTrop H 𝕋) :
    tropicalTransform (a + b) χ = min (tropicalTransform a χ) (tropicalTransform b χ) := by
  exact χ.map_add' a b

/-
The tropical transform sends multiplication to pointwise addition.
  `𝓕(a * b)(χ) = 𝓕(a)(χ) + 𝓕(b)(χ)`
-/
theorem tropicalTransform_mul {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (a b : H) (χ : SphTrop H 𝕋) :
    tropicalTransform (a * b) χ = tropicalTransform a χ + tropicalTransform b χ := by
  convert TropicalCharacter.map_mul χ a b using 1

/-
The tropical transform sends zero to the constant ⊤ function.
  `𝓕(0)(χ) = ⊤`
-/
theorem tropicalTransform_zero {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ : SphTrop H 𝕋) :
    tropicalTransform (0 : H) χ = ⊤ := by
  exact χ.map_zero'

/-
The tropical transform sends one to the constant 0 function.
  `𝓕(1)(χ) = 0`
-/
theorem tropicalTransform_one {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ : SphTrop H 𝕋) :
    tropicalTransform (1 : H) χ = 0 := by
  convert χ.map_one'

/-! ## Section 2: Tropical Character Separation (Theorem 1)

This is the exact idempotent analogue of character separation in commutative
harmonic analysis: if two elements are inequivalent modulo the radical congruence,
some tropical character distinguishes them.
-/

/-
**Tropical Character Separation Theorem.**
Under a radical-congruence separation hypothesis, for any two elements inequivalent
modulo the radical, there exists a tropical character distinguishing them.
This is the idempotent analogue of the classical separation theorem for characters.
-/
theorem tropical_character_separation
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (S : Set (TropicalCharacter H 𝕋))
    {h₁ h₂ : H}
    (hne : ¬ (radicalCongruence S).r h₁ h₂) :
    ∃ χ ∈ S, χ.toFun h₁ ≠ χ.toFun h₂ := by
  contrapose! hne; tauto;

/-! ## Section 3: Faithfulness of the Tropical Transform (Theorem 2)

Under semisimplicity (the radical is trivial), the tropical spherical transform
is injective: distinct elements have distinct spectral profiles.
-/

/-
**Tropical Transform Faithfulness Theorem.**
Under a semisimple tropical spectrum, the tropical spherical transform is faithful:
if two elements have the same spectral profile (every character assigns them
equal values), then they are equal.
-/
theorem tropicalTransform_faithful
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    [SemisimpleTropicalSpectrum H 𝕋]
    {h₁ h₂ : H}
    (heq : ∀ χ : SphTrop H 𝕋, χ h₁ = χ h₂) :
    h₁ = h₂ := by
  contrapose! heq
  exact SemisimpleTropicalSpectrum.sep heq

/-
**Tropical Transform Injectivity.**
The tropical spherical transform is injective under semisimplicity.
-/
theorem tropicalTransform_injective
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    [SemisimpleTropicalSpectrum H 𝕋] :
    Function.Injective (tropicalTransform (H := H) (𝕋 := 𝕋)) := by
  intro h₁ h₂ h_eq
  apply tropicalTransform_faithful (𝕋 := 𝕋)
  intro χ
  exact congr_fun h_eq χ

/-! ## Section 4: Fingerprint Completeness (Theorem 4)

Given a finite complete set of extremal characters, the fingerprint map
provides a certified equality decision procedure.
-/

/-
**Fingerprint Injectivity.**
A complete finite spectrum yields an injective fingerprint map.
-/
theorem fingerprint_injective
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋)
    (hcomplete : SpectrumComplete E) :
    Function.Injective (transformFingerprint E) := by
  intro a b hab;
  exact Classical.not_not.1 fun h => by obtain ⟨ p, hp ⟩ := hcomplete h; exact hp ( congr_fun hab p ) ;

/-
**Fingerprint Completeness for Equality.**
The fingerprint-based equality decision is correct:
equal fingerprints imply equal elements when the spectrum is complete.
-/
theorem fingerprint_eq_iff_eq
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋)
    (hcomplete : SpectrumComplete E)
    (a b : H) :
    transformFingerprint E a = transformFingerprint E b ↔ a = b := by
  exact ⟨ fun h => fingerprint_injective E hcomplete h, fun h => h ▸ rfl ⟩

/-
**Certified Equality Decision Correctness.**
The fingerprint-based boolean decision procedure is sound and complete
when the spectrum is complete.
-/
theorem decideEqViaFingerprint_spec
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [DecidableEq 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋)
    (hcomplete : SpectrumComplete E)
    (a b : H) :
    decideEqViaFingerprint E a b = true ↔ a = b := by
  unfold decideEqViaFingerprint;
  grind +suggestions

/-! ## Section 5: Complete Spectrum Yields Semisimplicity

A complete finite spectrum implies the full semisimplicity hypothesis.
-/

/-
A complete finite spectrum induces a semisimple tropical spectrum.
-/
theorem completeSpectrum_semisimple
    {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋)
    (hcomplete : SpectrumComplete E) :
    ∀ {h₁ h₂ : H}, h₁ ≠ h₂ → ∃ χ : SphTrop H 𝕋, χ h₁ ≠ χ h₂ := by
  exact fun { h₁ h₂ } hne => by obtain ⟨ p, hp ⟩ := hcomplete hne; exact ⟨ E.val p, hp ⟩ ;

/-! ## Section 6: Fingerprint Compatibility with Operations

The fingerprint map also preserves the tropical semiring structure.
-/

/-
The fingerprint of a sum equals the pointwise min of fingerprints.
-/
theorem fingerprint_add {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (a b : H) (p : E.PointType) :
    transformFingerprint E (a + b) p =
      min (transformFingerprint E a p) (transformFingerprint E b p) := by
  exact E.val p |>.map_add' a b

/-
The fingerprint of a product equals the pointwise sum of fingerprints.
-/
theorem fingerprint_mul {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (a b : H) (p : E.PointType) :
    transformFingerprint E (a * b) p =
      transformFingerprint E a p + transformFingerprint E b p := by
  exact E.val p |>.map_mul' a b

/-
The fingerprint of zero is the constant ⊤ function.
-/
theorem fingerprint_zero {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (p : E.PointType) :
    transformFingerprint E (0 : H) p = ⊤ := by
  exact E.val p |>.map_zero'

/-
The fingerprint of one is the constant 0 function.
-/
theorem fingerprint_one {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (E : FiniteExtremalSpectrum H 𝕋) (p : E.PointType) :
    transformFingerprint E (1 : H) p = 0 := by
  convert E.val p |>.map_one'

/-! ## Section 7: Radical Congruence Properties -/

/-
The radical congruence is reflexive (trivially).
-/
theorem radicalCongruence_refl {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (S : Set (TropicalCharacter H 𝕋)) (h : H) :
    (radicalCongruence S).r h h := by
  intro _ _; rfl

/-
If no character in S separates h₁ and h₂, they are radical-equivalent.
-/
theorem radicalCongruence_of_forall_eq {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (S : Set (TropicalCharacter H 𝕋)) {h₁ h₂ : H}
    (heq : ∀ χ ∈ S, χ.toFun h₁ = χ.toFun h₂) :
    (radicalCongruence S).r h₁ h₂ := by
  exact heq

/-
Separation from the radical congruence is equivalent to existence of a distinguishing
character in S.
-/
theorem not_radicalCongruence_iff {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (S : Set (TropicalCharacter H 𝕋)) {h₁ h₂ : H} :
    ¬ (radicalCongruence S).r h₁ h₂ ↔ ∃ χ ∈ S, χ.toFun h₁ ≠ χ.toFun h₂ := by
  unfold radicalCongruence; aesop;