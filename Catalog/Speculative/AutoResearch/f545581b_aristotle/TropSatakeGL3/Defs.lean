/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Satake Convolution-Faithfulness for GL₃: Definitions

## Overview

We work in a concrete GL₃ dominant-coweight model using triples `μ : ℕ × ℕ × ℕ`
with dominance condition `μ₁ ≥ μ₂ ≥ μ₃`. The tropical Satake transform is a
min-plus support function evaluated at test points `x ∈ ℤ × ℤ × ℤ`.

**Key design decision (sign convention).** Test points live in `ℤ³` and range over
the full cocharacter lattice (not restricted to the dominant chamber). The Weyl
chamber walls are the hyperplanes `{x₁ = x₂}` and `{x₂ = x₃}` in `ℤ³`.
Restricting test points to the dominant chamber would break injectivity of the
tropical Satake transform (dominant test points cannot expose all support points
because `evalWeight(μ, x) ≥ evalWeight(ν, x)` whenever `μ ≻ ν` in dominance
order and `x` is dominant).

## Main Definitions

* `Wt` — weight triples `ℕ × ℕ × ℕ` (dominant coweights)
* `TestPt` — test point triples `ℤ × ℤ × ℤ` (full cocharacter lattice)
* `Dominant` — the dominance condition μ₁ ≥ μ₂ ≥ μ₃ on weights
* `evalWeight` — the bilinear pairing ⟨μ, x⟩ = μ₁x₁ + μ₂x₂ + μ₃x₃
* `Facet12`, `Facet23` — the two Weyl chamber walls
* `adjacentData` — the GL₂-type projection family
* `tropSat` — the tropical Satake transform (min-plus support function)
-/
import Mathlib

namespace TropSatakeGL3

/-- Weight type: triples of natural numbers representing GL₃ dominant coweights. -/
abbrev Wt := ℕ × ℕ × ℕ

/-- Test point type: triples of integers (full cocharacter lattice). -/
abbrev TestPt := ℤ × ℤ × ℤ

/-- Dominance condition on weights: μ₁ ≥ μ₂ ≥ μ₃. -/
def Dominant (μ : Wt) : Prop := μ.1 ≥ μ.2.1 ∧ μ.2.1 ≥ μ.2.2

/-- The bilinear evaluation pairing ⟨μ, x⟩ = μ₁x₁ + μ₂x₂ + μ₃x₃. -/
def evalWeight (μ : Wt) (x : TestPt) : ℤ :=
  (μ.1 : ℤ) * x.1 + (μ.2.1 : ℤ) * x.2.1 + (μ.2.2 : ℤ) * x.2.2

@[simp] lemma evalWeight_mk (a b c : ℕ) (x y z : ℤ) :
    evalWeight (a, b, c) (x, y, z) = (a : ℤ) * x + (b : ℤ) * y + (c : ℤ) * z := rfl

/-- Facet12: the α₁-wall `{x₁ = x₂}` of the dominant Weyl chamber.
    On this wall, `evalWeight μ (a, a, b) = (μ₁+μ₂)·a + μ₃·b`. -/
def Facet12 : Set TestPt := {x | x.1 = x.2.1}

/-- Facet23: the α₂-wall `{x₂ = x₃}` of the dominant Weyl chamber.
    On this wall, `evalWeight μ (a, b, b) = μ₁·a + (μ₂+μ₃)·b`. -/
def Facet23 : Set TestPt := {x | x.2.1 = x.2.2}

/-- The adjacent-data map: projects a weight to two GL₂-type pairs.
    This map is injective: the two pairs together determine (μ₁, μ₂, μ₃).
    - First pair `(μ₁+μ₂, μ₃)`: the exponent visible on Facet12
    - Second pair `(μ₁, μ₂+μ₃)`: the exponent visible on Facet23 -/
def adjacentData (μ : Wt) : (ℕ × ℕ) × (ℕ × ℕ) :=
  ((μ.1 + μ.2.1, μ.2.2), (μ.1, μ.2.1 + μ.2.2))

/-- Evaluation formula on Facet12: for x = (a, a, b), ⟨μ,x⟩ = (μ₁+μ₂)·a + μ₃·b. -/
theorem eval_on_facet12 (μ : Wt) (a b : ℤ) :
    evalWeight μ (a, a, b) = ((μ.1 + μ.2.1 : ℕ) : ℤ) * a + (μ.2.2 : ℤ) * b := by
  simp [evalWeight]; ring

/-- Evaluation formula on Facet23: for x = (a, b, b), ⟨μ,x⟩ = μ₁·a + (μ₂+μ₃)·b. -/
theorem eval_on_facet23 (μ : Wt) (a b : ℤ) :
    evalWeight μ (a, b, b) = (μ.1 : ℤ) * a + ((μ.2.1 + μ.2.2 : ℕ) : ℤ) * b := by
  simp [evalWeight]; ring

/-- The tropical Satake transform (min-plus): the minimum of `f(μ) + ⟨μ, x⟩`
    over the support of `f`. Defined for functions with nonempty support. -/
noncomputable def tropSat (f : Wt →₀ ℤ) (hne : f.support.Nonempty) (x : TestPt) : ℤ :=
  f.support.inf' hne (fun μ => f μ + evalWeight μ x)

end TropSatakeGL3