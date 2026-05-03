/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Classification — Definitions

## Overview

This file provides the core definitions for the GL₃ tropical Satake
classification theorem on bounded support. We model the dominant coweight
chamber for GL₃ (modulo center) as pairs `(a, b) ∈ ℕ²`, representing the
dominant coweight `(a + b, b, 0)`.

## Mathematical Model

The tropical Hecke algebra is modeled by *edge data*: a pair of functions
on `ℕ` representing the generator coefficients along the two simple-coroot
directions of the GL₃ dominant chamber. The tropical Satake transform extends
edge data to the full chamber via the additive formula

  `D(a, b) = f₁(a) + f₂(b)`

reflecting the factored structure of the GL₃ Satake kernel in the tropical limit.

The admissibility conditions characterize which functions on the dominant chamber
arise as images of the tropical Satake transform. They decompose into:

* **EdgeValuationCompatible** — normalization at the origin
* **Levi12Compatible** — first-coordinate increment independence
* **Levi23Compatible** — second-coordinate increment independence
* **AdjacentFacetCompatible** — vanishing discrete Laplacian

These conditions are shown to be mutually equivalent (up to the origin condition)
and collectively equivalent to additive separability `D(a,b) = D(a,0) + D(0,b)`.
-/
import Mathlib

namespace TropSatakeGL3

/-! ## Core Types -/

/-- Dominant coweight for GL₃ (mod center), parameterized as
    `(a, b) ↦ (a + b, b, 0)`. -/
abbrev DomWt := ℕ × ℕ

/-- A tropical datum: a real-valued function on the dominant chamber. -/
abbrev TropDatum := DomWt → ℝ

/-- Height of a dominant coweight: `height(a, b) = a + b = λ₁`. -/
def height (p : DomWt) : ℕ := p.1 + p.2

@[simp] lemma height_def (a b : ℕ) : height (a, b) = a + b := rfl

/-! ## Bounded Support -/

/-- Bounded support: the datum vanishes above a given height. -/
def BoundedSupport (N : ℕ) (D : TropDatum) : Prop :=
  ∀ p : DomWt, N < p.1 + p.2 → D p = 0

/-! ## Tropical Hecke Algebra -/

/-- A tropical Hecke element for GL₃, given by edge data along the two
    simple-coroot directions, normalized so that both vanish at the origin.

    * `edge1` stores the values along the first wall `{(a, 0) : a ∈ ℕ}`
    * `edge2` stores the values along the second wall `{(0, b) : b ∈ ℕ}` -/
@[ext]
structure TropHecke where
  /-- Generator coefficients along the first simple-coroot direction. -/
  edge1 : ℕ → ℝ
  /-- Generator coefficients along the second simple-coroot direction. -/
  edge2 : ℕ → ℝ
  /-- Normalization: edge1 vanishes at the origin. -/
  edge1_zero : edge1 0 = 0
  /-- Normalization: edge2 vanishes at the origin. -/
  edge2_zero : edge2 0 = 0

/-- The tropical Satake transform for GL₃: extends edge data to the full
    dominant chamber via `D(a, b) = f₁(a) + f₂(b)`.

    This additive extension encodes the fact that the GL₃ Satake kernel
    factors through the two simple-root SL₂ subgroups in the tropical limit. -/
noncomputable def tropSatake (h : TropHecke) : TropDatum :=
  fun p => h.edge1 p.1 + h.edge2 p.2

/-- Bounded support for Hecke elements: both edge functions vanish beyond height N. -/
def HeckeBoundedSupport (N : ℕ) (h : TropHecke) : Prop :=
  (∀ a, N < a → h.edge1 a = 0) ∧ (∀ b, N < b → h.edge2 b = 0)

/-! ## Admissibility Conditions -/

/-- **Edge valuation compatibility**: the datum vanishes at the origin.
    This is the normalization condition corresponding to the identity
    element of the Hecke algebra. -/
def EdgeValuationCompatible (D : TropDatum) : Prop :=
  D (0, 0) = 0

/-- **Levi₁₂ compatibility**: increments in the first coordinate direction
    are independent of the second coordinate. This corresponds to the
    rank-2 Levi subgroup for the simple root α₁. -/
def Levi12Compatible (D : TropDatum) : Prop :=
  ∀ a b : ℕ, D (a + 1, b) - D (a, b) = D (a + 1, 0) - D (a, 0)

/-- **Levi₂₃ compatibility**: increments in the second coordinate direction
    are independent of the first coordinate. This corresponds to the
    rank-2 Levi subgroup for the simple root α₂. -/
def Levi23Compatible (D : TropDatum) : Prop :=
  ∀ a b : ℕ, D (a, b + 1) - D (a, b) = D (0, b + 1) - D (0, b)

/-- **Adjacent facet compatibility**: the discrete Laplacian vanishes,
    expressing the commutativity of the two simple-root propagation
    operators on the dominant chamber. -/
def AdjacentFacetCompatible (D : TropDatum) : Prop :=
  ∀ a b : ℕ, D (a + 1, b + 1) + D (a, b) = D (a + 1, b) + D (a, b + 1)

/-- **Full Satake admissibility**: conjunction of all four compatibility
    conditions for the GL₃ tropical Satake transform. -/
def SatakeAdmissible (D : TropDatum) : Prop :=
  EdgeValuationCompatible D ∧
  Levi12Compatible D ∧
  Levi23Compatible D ∧
  AdjacentFacetCompatible D

end TropSatakeGL3