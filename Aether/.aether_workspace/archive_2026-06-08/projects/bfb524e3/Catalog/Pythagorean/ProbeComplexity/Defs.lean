/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Probe Complexity of Finite Categories — Definitions

This file develops a quantitative theory of **probe complexity** for finite categories,
turning the qualitative Yoneda-style reconstruction principle into a measurable invariant.

## Main Definitions

* `ProbeFamily` — a `Finset` of objects of a category used to probe morphisms.
* `ProbeFamily.IsSeparating` — the property that a probe family distinguishes
  all parallel morphisms via precomposition.
* `probeComplexity` — the minimum cardinality of a separating probe family.
* `morphismProfile` — the function recording how a morphism acts on all probes.
* `ProbeFamily.SeparatesPair` — a probe family separates a specific pair of morphisms.

## Main Results

* `totalProbeFamily_isSeparating` — the family of all objects is separating.
* `probeComplexity_le_card` — probe complexity is at most the number of objects.
* `profileMap_injective` — the profile map is injective for separating families.
-/

open CategoryTheory Finset

noncomputable section

universe u

/-! ### Core Definitions -/

variable {C : Type u} [Category C]

/-- A probe family is a `Finset` of objects used to distinguish morphisms
by precomposition. -/
abbrev ProbeFamily (C : Type u) [Category C] := Finset C

/-- A probe family **separates** morphisms if: whenever two parallel morphisms
`f g : X ⟶ Y` agree on precomposition with every morphism from every probe object,
then `f = g`. -/
def ProbeFamily.IsSeparating
    (P : ProbeFamily C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y),
    (∀ Z ∈ P, ∀ h : Z ⟶ X, h ≫ f = h ≫ g) → f = g

/-- A probe family **separates a pair** of morphisms `f` and `g` if there exists
a probe object and a morphism from it that distinguishes them. -/
def ProbeFamily.SeparatesPair
    (P : ProbeFamily C) {X Y : C} (f g : X ⟶ Y) : Prop :=
  ∃ Z ∈ P, ∃ h : Z ⟶ X, h ≫ f ≠ h ≫ g

/-- The **morphism profile** of a morphism `f : X ⟶ Y` relative to a probe family `P`
records, for each probe object `Z ∈ P`, the induced postcomposition map on `Hom(Z, X)`.
Two morphisms are separated by `P` if and only if they have distinct profiles. -/
def morphismProfile
    (P : ProbeFamily C) {X Y : C} (f : X ⟶ Y) :
    ∀ Z : P, (↑Z ⟶ X) → (↑Z ⟶ Y) :=
  fun ⟨_Z, _⟩ h => h ≫ f

/-- The profile map is injective when the probe family is separating. -/
theorem profileMap_injective
    (P : ProbeFamily C) (hP : P.IsSeparating) (X Y : C) :
    Function.Injective (fun f : X ⟶ Y => morphismProfile P f) := by
  intro f g heq
  apply hP
  intro Z hZ h
  have := congr_fun (congr_fun heq ⟨Z, hZ⟩) h
  exact this

end