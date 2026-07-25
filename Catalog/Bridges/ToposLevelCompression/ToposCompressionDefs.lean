/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Topos-Level Compression — Definitions

This file defines the core objects of the **probe compression** framework
for finite presheaf-like models.

## Main Definitions

* `ProbeFamily` — a `Finset` of "probe objects" used to distinguish sections.
* `probeSignature'` — the signature of a section at all probe objects.
* `ProbeSeparates` — a probe family separates if signatures are injective at every object.
* `ProbeSeparating'` — global separation: there exists a separating family.
* `compressionSpectrum'` — the set of cardinalities of separating families.
* `presheafMinCompression'` — the minimum cardinality of a separating family.
* `realizesCompression'` — a natural number is realized if some family of that size separates.
* `representableDim` — the sum of fiber cardinalities.
* `fiberObsComplexity` — fiber-level observation complexity.
* `observationComplexity'` — the maximum fiber observation complexity.
* `CompressionEquiv` — compression-compatible equivalence between two models.
-/

open Finset Fintype

noncomputable section

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

universe u v w

/-- A probe family is a `Finset` of objects. -/
abbrev ProbeFamily (Ob : Type*) := Finset Ob

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-- The **probe signature** of a section `s ∈ F(Y)` relative to a probe family `P`:
for each probe object `Z ∈ P`, apply the restriction map `r Y Z` to `s`. -/
def probeSignature'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : Finset Ob) (Y : Ob) (s : F Y) : ∀ Z : ↥P, F ↑Z :=
  fun ⟨Z, _⟩ => r Y Z s

/-- A probe family `P` **separates** the model `(F, r)` if for every object `Y`,
the probe signature map `F(Y) → ∏_{Z ∈ P} F(Z)` is injective. -/
def ProbeSeparates
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : Finset Ob) : Prop :=
  ∀ Y : Ob, Function.Injective (probeSignature' F r P Y)

/-- The model is **probe-separating** if some probe family separates it. -/
def ProbeSeparating'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∃ P : ProbeFamily Ob, ProbeSeparates F r P

/-- The **compression spectrum** is the set of cardinalities of separating families. -/
def compressionSpectrum'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : Set ℕ :=
  {n : ℕ | ∃ P : ProbeFamily Ob, P.card = n ∧ ProbeSeparates F r P}

/-- A natural number `n` **realizes compression** if there is a separating family
of cardinality `n`. -/
def realizesCompression'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) (n : ℕ) : Prop :=
  ∃ P : ProbeFamily Ob, P.card = n ∧ ProbeSeparates F r P

/-- The **presheaf minimum compression** is the infimum of the compression spectrum. -/
def presheafMinCompression'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : ℕ :=
  sInf (compressionSpectrum' F r)

/-- The **representable dimension**: sum of all fiber cardinalities. -/
def representableDim
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] : ℕ :=
  ∑ Y : Ob, Fintype.card (F Y)

/-- The fiber-level observation complexity at object `Y`. -/
def fiberObsComplexity
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) (Y : Ob) : ℕ :=
  sInf {n : ℕ | ∃ P : ProbeFamily Ob, P.card = n ∧
    Function.Injective (probeSignature' F r P Y)}

/-- The observation complexity: maximum fiber observation complexity. -/
def observationComplexity'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : ℕ :=
  Finset.univ.sup (fiberObsComplexity F r)

/-- A **compression-compatible equivalence** between two models. -/
structure CompressionEquiv
    (Ob₁ : Type u) (Ob₂ : Type v)
    (F₁ : Ob₁ → Type w) (F₂ : Ob₂ → Type w)
    (r₁ : ∀ Y Z, F₁ Y → F₁ Z) (r₂ : ∀ Y Z, F₂ Y → F₂ Z) where
  φ : Ob₁ ≃ Ob₂
  ψ : ∀ Y : Ob₁, F₁ Y ≃ F₂ (φ Y)
  compat : ∀ (Y Z : Ob₁) (s : F₁ Y),
    ψ Z (r₁ Y Z s) = r₂ (φ Y) (φ Z) (ψ Y s)

/-! ### Monotonicity of separation -/

/-- **Monotonicity**: supersets of separating families also separate. -/
theorem ProbeSeparates.mono
    {F : Ob → Type v} {r : ∀ Y Z, F Y → F Z}
    {P Q : ProbeFamily Ob}
    (hP : ProbeSeparates F r P) (hPQ : P ⊆ Q) :
    ProbeSeparates F r Q := by
  intro Y s t hsig
  apply hP Y
  funext ⟨Z, hZ⟩
  exact congr_fun hsig ⟨Z, hPQ hZ⟩

end