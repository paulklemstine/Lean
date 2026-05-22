/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Geometry.HodgeTheory.Defs

/-!
# Hodge Morphisms for Weight-1 Structures

This file defines Hodge morphisms between weight-1 rational Hodge structures and
proves basic categorical properties. These constructions form the algebraic skeleton
of the tensor-Hom correspondence Hdg(W₁ᵛ ⊗ W₂) ≅ Hom_HS(W₁, W₂).

## Main definitions

* `HodgeMorphism` — A ℚ-linear map preserving the Hodge decomposition.
* `HodgeMorphism.id` — Identity Hodge endomorphism.
* `HodgeMorphism.comp` — Composition of Hodge morphisms.

## Mathematical context

A Hodge morphism f : W₁ → W₂ preserves the Hodge decomposition: the complexified
map sends H^{1,0}(W₁) into H^{1,0}(W₂) and H^{0,1}(W₁) into H^{0,1}(W₂).
The collection of all such morphisms forms the morphism space in the category of
rational Hodge structures. Via the tensor-Hom adjunction, these morphisms are
identified with (0,0)-classes in W₁ᵛ ⊗ W₂ — the starting point for Tannakian
formalism in Hodge theory.
-/

noncomputable section

open scoped TensorProduct

variable {V₁ V₂ : Type*}
  [AddCommGroup V₁] [Module ℚ V₁] [FiniteDimensional ℚ V₁]
  [AddCommGroup V₂] [Module ℚ V₂] [FiniteDimensional ℚ V₂]

/-! ## Hodge morphisms -/

/-- A **Hodge morphism** between weight-1 rational Hodge structures: a ℚ-linear
map that preserves H¹⁰ and H⁰¹ on complexified elements 1⊗v. -/
structure HodgeMorphism
    (HD₁ : WeightOneHodgeData V₁) (HD₂ : WeightOneHodgeData V₂) where
  toLinearMap : V₁ →ₗ[ℚ] V₂
  preserves_H10 : ∀ v₁ : V₁,
    complexEmbed V₁ v₁ ∈ HD₁.H10 →
    complexEmbed V₂ (toLinearMap v₁) ∈ HD₂.H10
  preserves_H01 : ∀ v₁ : V₁,
    complexEmbed V₁ v₁ ∈ HD₁.H01 →
    complexEmbed V₂ (toLinearMap v₁) ∈ HD₂.H01

theorem HodgeMorphism.ext_iff {HD₁ : WeightOneHodgeData V₁}
    {HD₂ : WeightOneHodgeData V₂}
    {f g : HodgeMorphism HD₁ HD₂} :
    f = g ↔ f.toLinearMap = g.toLinearMap := by
  constructor
  · intro h; rw [h]
  · intro h; cases f; cases g; congr

/-! ## Identity and composition -/

/-- The identity Hodge endomorphism. -/
def HodgeMorphism.id (HD : WeightOneHodgeData V₁) : HodgeMorphism HD HD where
  toLinearMap := LinearMap.id
  preserves_H10 := fun _ h => by simpa using h
  preserves_H01 := fun _ h => by simpa using h

/-- Composition of Hodge morphisms. -/
def HodgeMorphism.comp
    {V₃ : Type*} [AddCommGroup V₃] [Module ℚ V₃] [FiniteDimensional ℚ V₃]
    {HD₁ : WeightOneHodgeData V₁} {HD₂ : WeightOneHodgeData V₂}
    {HD₃ : WeightOneHodgeData V₃}
    (g : HodgeMorphism HD₂ HD₃) (f : HodgeMorphism HD₁ HD₂) :
    HodgeMorphism HD₁ HD₃ where
  toLinearMap := g.toLinearMap ∘ₗ f.toLinearMap
  preserves_H10 := fun v₁ hv₁ => g.preserves_H10 _ (f.preserves_H10 v₁ hv₁)
  preserves_H01 := fun v₁ hv₁ => g.preserves_H01 _ (f.preserves_H01 v₁ hv₁)

/-- The zero Hodge morphism. -/
def HodgeMorphism.zero' (HD₁ : WeightOneHodgeData V₁)
    (HD₂ : WeightOneHodgeData V₂) : HodgeMorphism HD₁ HD₂ where
  toLinearMap := 0
  preserves_H10 := fun _ _ => by
    change complexEmbed V₂ 0 ∈ HD₂.H10
    have : complexEmbed V₂ 0 = 0 := map_zero _
    rw [this]; exact HD₂.H10.zero_mem
  preserves_H01 := fun _ _ => by
    change complexEmbed V₂ 0 ∈ HD₂.H01
    have : complexEmbed V₂ 0 = 0 := map_zero _
    rw [this]; exact HD₂.H01.zero_mem

/-! ## Hodge endomorphism algebra operations -/

/-- Addition of Hodge endomorphisms. -/
def HodgeEndomorphismAdd {HD : WeightOneHodgeData V₁}
    (f g : HodgeMorphism HD HD) : HodgeMorphism HD HD where
  toLinearMap := f.toLinearMap + g.toLinearMap
  preserves_H10 := fun v₁ hv₁ => by
    change complexEmbed V₁ (f.toLinearMap v₁ + g.toLinearMap v₁) ∈ HD.H10
    rw [map_add]
    exact HD.H10.add_mem (f.preserves_H10 v₁ hv₁) (g.preserves_H10 v₁ hv₁)
  preserves_H01 := fun v₁ hv₁ => by
    change complexEmbed V₁ (f.toLinearMap v₁ + g.toLinearMap v₁) ∈ HD.H01
    rw [map_add]
    exact HD.H01.add_mem (f.preserves_H01 v₁ hv₁) (g.preserves_H01 v₁ hv₁)

/-- Composition gives the multiplication in the endomorphism algebra. -/
def HodgeEndomorphismMul {HD : WeightOneHodgeData V₁}
    (f g : HodgeMorphism HD HD) : HodgeMorphism HD HD :=
  f.comp g

end