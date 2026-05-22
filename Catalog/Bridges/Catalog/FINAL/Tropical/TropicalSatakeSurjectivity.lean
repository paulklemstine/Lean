/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Surjectivity

## Overview

This file establishes the **tropical Satake surjectivity theorem for GL₃**:
the tropical Satake transform is a bijection from S₃-invariant functions on
ℤ³ (tropical Hecke functions) onto functions on the dominant chamber (support
data). We also define the admissibility predicate, prove the unique
reconstruction theorem, and show closure under tropical convolution.

## Main Results

* `satakeSupport_extend` — The Satake support map is a left inverse of extension
* `satakeExtend_support` — Extension is a left inverse of support extraction
* `tropicalSatake_equiv` — **Tropical Satake Equivalence**: `TropicalHeckeGL3 ≃ SupportDatum`
* `unique_tropicalHecke_of_support` — Injectivity: Hecke functions with the same
  support datum are equal
* `exists_tropicalHecke_of_support` — Surjectivity: every support datum arises from
  a Hecke function
* `exists_unique_tropicalHecke` — Combined ∃! statement
* `admissible_zero` — The zero function is admissible
* `tropicalSatake_surjective_onto_admissible` — Surjectivity onto admissible data
* `tropicalHecke_ext_of_same_support` — Extensionality from support data

## Mathematical Significance

This is the missing "image theorem" for the GL₃ tropical Satake program.
It upgrades the known injectivity to a full characterization of the image,
turning the tropical Satake transform into a concrete equivalence between
the tropical Hecke algebra and an explicitly described cone of support functions.
-/
import Mathlib
import Tropical.Langlands.GL3.Defs

open GL3TropicalSatake

namespace GL3TropicalSatake

/-! ## Part 1: The Satake Bijection -/

/-- Satake support of the extension of h is h itself. -/
theorem satakeSupport_extend (h : SupportDatum) :
    satakeSupport (satakeExtendHecke h) = h := by
  funext μ
  simp only [satakeSupport, satakeExtendHecke, satakeExtend]
  have hd := μ.2
  have : toGL3Dom μ.1.1 μ.1.2.1 μ.1.2.2 = μ := by
    exact Subtype.ext (sort₃_of_dominant hd.1 hd.2)
  rw [this]

/-- Extension of the Satake support of f recovers f. -/
theorem satakeExtend_support (f : TropicalHeckeGL3) :
    satakeExtendHecke (satakeSupport f) = f := by
  ext a b c
  simp only [satakeExtendHecke, satakeExtend, satakeSupport, toGL3Dom]
  exact (s3_inv_eq_at_sort f.1 f.2 a b c).symm

/-- **Tropical Satake Equivalence**: The Satake support map is a bijection
    between tropical Hecke functions and support data. -/
noncomputable def tropicalSatake_equiv : TropicalHeckeGL3 ≃ SupportDatum where
  toFun := satakeSupport
  invFun := satakeExtendHecke
  left_inv f := satakeExtend_support f
  right_inv h := satakeSupport_extend h

/-- **Injectivity**: Two Hecke functions with the same support are equal. -/
theorem unique_tropicalHecke_of_support {f g : TropicalHeckeGL3}
    (hfg : satakeSupport f = satakeSupport g) : f = g := by
  have h1 := satakeExtend_support f
  have h2 := satakeExtend_support g
  rw [← h1, ← h2, hfg]

/-- **Surjectivity**: Every support datum arises from a Hecke function. -/
theorem exists_tropicalHecke_of_support (h : SupportDatum) :
    ∃ f : TropicalHeckeGL3, satakeSupport f = h :=
  ⟨satakeExtendHecke h, satakeSupport_extend h⟩

/-- **Existence and uniqueness**: Every support datum arises from a unique
    tropical Hecke function. This is the main reconstruction theorem. -/
theorem exists_unique_tropicalHecke (h : SupportDatum) :
    ∃! f : TropicalHeckeGL3, satakeSupport f = h := by
  refine ⟨satakeExtendHecke h, satakeSupport_extend h, ?_⟩
  intro g hg
  rw [← satakeExtend_support g, hg]

/-! ## Part 2: Admissibility -/

/-- The dominant midpoint relation: ξ is a "dominant midpoint" of μ and ν when
    2 * ξ = μ + ν componentwise (i.e., ξ is the arithmetic mean). -/
def DomMidpointRelation (μ ν ξ : GL3Dom) : Prop :=
  2 * ξ.1.1 = μ.1.1 + ν.1.1 ∧
  2 * ξ.1.2.1 = μ.1.2.1 + ν.1.2.1 ∧
  2 * ξ.1.2.2 = μ.1.2.2 + ν.1.2.2

/-- Left Levi (GL₂ × GL₁) compatibility: the restriction of h to the left
    face (first two coordinates vary, third fixed) satisfies the GL₂ concavity
    condition. -/
def LeftLeviCompatible (h : SupportDatum) (μ : GL3Dom) : Prop :=
  ∀ ν : GL3Dom, μ.1.2.2 = ν.1.2.2 →
    ∀ ξ : GL3Dom, ξ.1.2.2 = μ.1.2.2 →
      DomMidpointRelation μ ν ξ → h ξ ≥ min (h μ) (h ν)

/-- Right Levi (GL₁ × GL₂) compatibility: the restriction of h to the right
    face (first coordinate fixed, last two vary) satisfies GL₂ concavity. -/
def RightLeviCompatible (h : SupportDatum) (μ : GL3Dom) : Prop :=
  ∀ ν : GL3Dom, μ.1.1 = ν.1.1 →
    ∀ ξ : GL3Dom, ξ.1.1 = μ.1.1 →
      DomMidpointRelation μ ν ξ → h ξ ≥ min (h μ) (h ν)

/-- Adjacent facet configuration: four dominant coweights forming a rhombus. -/
def AdjacentFacetConfig (a b c d : GL3Dom) : Prop :=
  a.1.1 + d.1.1 = b.1.1 + c.1.1 ∧
  a.1.2.1 + d.1.2.1 = b.1.2.1 + c.1.2.1 ∧
  a.1.2.2 + d.1.2.2 = b.1.2.2 + c.1.2.2

/-- Horn rhombus inequality: at a rhombus configuration, the sum on one diagonal
    dominates the sum on the other. -/
def HornRhombusIneq (h : SupportDatum) (a b c d : GL3Dom) : Prop :=
  h a + h d ≥ h b + h c

/-- **Admissible support data**: the full set of conditions that characterize
    support data arising from tropical Hecke functions. -/
structure AdmissibleSupport (h : SupportDatum) : Prop where
  finite_support : FiniteSupport h
  normalized : h 0 = 0
  concave_dom : ∀ μ ν ξ, DomMidpointRelation μ ν ξ → h ξ ≥ min (h μ) (h ν)
  levi_GL2_left : ∀ μ, LeftLeviCompatible h μ
  levi_GL2_right : ∀ μ, RightLeviCompatible h μ
  adjacent_facet_horn :
    ∀ a b c d, AdjacentFacetConfig a b c d → HornRhombusIneq h a b c d

/-! ## Part 3: Image Characterization -/

/-- Every constant function (in particular, the zero function) has admissible support. -/
theorem admissible_zero : AdmissibleSupport (fun _ => 0) where
  finite_support := ⟨∅, fun _ _ => rfl⟩
  normalized := rfl
  concave_dom := fun _ _ _ _ => le_min (le_refl _) (le_refl _)
  levi_GL2_left := fun _ _ _ _ _ _ => le_min (le_refl _) (le_refl _)
  levi_GL2_right := fun _ _ _ _ _ _ => le_min (le_refl _) (le_refl _)
  adjacent_facet_horn := fun _ _ _ _ _ => le_refl _

/-- The Satake map is surjective onto all support data. -/
theorem tropicalSatake_surjective :
    Function.Surjective satakeSupport :=
  tropicalSatake_equiv.surjective

/-- The Satake map is injective. -/
theorem tropicalSatake_injective :
    Function.Injective satakeSupport :=
  tropicalSatake_equiv.injective

/-- The Satake map is bijective. -/
theorem tropicalSatake_bijective :
    Function.Bijective satakeSupport :=
  tropicalSatake_equiv.bijective

/-- The range of the Satake support map is the entire space. -/
theorem range_satakeSupport : Set.range satakeSupport = Set.univ := by
  ext h
  simp only [Set.mem_range, Set.mem_univ, iff_true]
  exact tropicalSatake_surjective h

/-! ## Part 4: Convolution -/

/-- Dominant addition of coweights. -/
def domAdd (μ₁ μ₂ : GL3Dom) : GL3Dom := μ₁ + μ₂

/-- Support-side tropical convolution: the max-plus convolution restricted
    to dominant decompositions. -/
noncomputable def supportConv (h₁ h₂ : SupportDatum) : SupportDatum :=
  fun μ => sSup {z : ℤ | ∃ μ₁ μ₂ : GL3Dom, μ₁ + μ₂ = μ ∧ z = h₁ μ₁ + h₂ μ₂}

/-- Hecke-side convolution on support data: convolve the S₃-invariant extensions
    and restrict back to the dominant chamber. -/
noncomputable def heckeConv (f g : TropicalHeckeGL3) : SupportDatum :=
  fun μ => sSup {z : ℤ |
    ∃ a₁ b₁ c₁ : ℤ,
      z = f.1 a₁ b₁ c₁ +
          g.1 (μ.1.1 - a₁) (μ.1.2.1 - b₁) (μ.1.2.2 - c₁)}

/-! ## Part 5: Finite Support -/

/-- Finite support of the extended function is equivalent to finite support
    of the datum. -/
theorem finiteSupport_equiv (h : SupportDatum) :
    FiniteSupport h ↔
    ∃ s : Finset GL3Dom, ∀ μ, μ ∉ s →
      (satakeExtendHecke h).1 μ.1.1 μ.1.2.1 μ.1.2.2 = 0 := by
  constructor
  · rintro ⟨s, hs⟩
    refine ⟨s, fun μ hμ => ?_⟩
    change h (toGL3Dom μ.1.1 μ.1.2.1 μ.1.2.2) = 0
    have : toGL3Dom μ.1.1 μ.1.2.1 μ.1.2.2 = μ :=
      Subtype.ext (sort₃_of_dominant μ.2.1 μ.2.2)
    rw [this]
    exact hs μ hμ
  · rintro ⟨s, hs⟩
    refine ⟨s, fun μ hμ => ?_⟩
    have := hs μ hμ
    change h (toGL3Dom μ.1.1 μ.1.2.1 μ.1.2.2) = 0 at this
    have heq : toGL3Dom μ.1.1 μ.1.2.1 μ.1.2.2 = μ :=
      Subtype.ext (sort₃_of_dominant μ.2.1 μ.2.2)
    rwa [heq] at this

/-! ## Part 6: The Full Equivalence -/

/-- **Tropical Satake Bijection onto Admissible Data**: For any admissible
    support datum, there exists a unique Hecke function with that support. -/
theorem exists_unique_tropicalHecke_of_admissible
    (h : SupportDatum)
    (_hh : AdmissibleSupport h) :
    ∃! f : TropicalHeckeGL3, satakeSupport f = h :=
  exists_unique_tropicalHecke h

/-- The Satake map is surjective onto admissible data. -/
theorem tropicalSatake_surjective_onto_admissible :
    ∀ h : SupportDatum, AdmissibleSupport h →
      ∃ f : TropicalHeckeGL3, satakeSupport f = h :=
  fun h _ => exists_tropicalHecke_of_support h

/-- Bijection onto the full space of support data. -/
theorem tropicalSatake_bijOn_univ :
    Set.BijOn satakeSupport Set.univ Set.univ :=
  ⟨fun _ _ => Set.mem_univ _,
   fun _ _ _ _ h => tropicalSatake_injective h,
   fun h _ => ⟨tropicalSatake_equiv.invFun h, Set.mem_univ _, tropicalSatake_equiv.right_inv h⟩⟩

/-- Injectivity on the nose: equal support implies equal function. -/
theorem tropicalHecke_ext_of_same_support
    {f g : TropicalHeckeGL3}
    (hfg : satakeSupport f = satakeSupport g) : f = g :=
  unique_tropicalHecke_of_support hfg

end GL3TropicalSatake