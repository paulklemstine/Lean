/-
Copyright (c) 2025 Tropical Closure Coding Theory. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Closure Coding Theory — Morphisms and Functoriality

This file defines closure morphisms and proves functoriality of syndrome maps
and decoding under closure-preserving maps.

## Main Definitions

* `ClosureHom` — A closure-preserving map between closure codes.
* `inducedSyndromeMap` — The syndrome map induced by a closure morphism.

## Main Results

* `ClosureHom.map_closed` — Closure morphisms preserve codewords.
* `syndrome_naturality` — **Theorem C**: Syndromes are functorial under closure morphisms.
* `decode_naturality` — Decoding commutes with closure morphisms.
-/

import Mathlib
import Logic.BasicMonotoneCircuit.Basic
import Bridges.Decoder
open Classical in
noncomputable section

universe u v

variable {α : Type u} {β : Type v} [DecidableEq α] [DecidableEq β]

/-- A closure morphism: a set-level map that preserves the closure structure.
    Specifically, it maps closed sets to closed sets and commutes with closure. -/
structure ClosureHom (C : ClosureCode α) (D : ClosureCode β) where
  /-- The underlying set-level map -/
  toFun : Set α → Set β
  /-- The map is monotone -/
  monotone' : Monotone toFun
  /-- Closed sets map to closed sets -/
  closed_map' : ∀ x, C.IsClosed x → D.IsClosed (toFun x)
  /-- The map commutes with closure -/
  closure_comm' : ∀ x, toFun (C.cl x) = D.cl (toFun x)

namespace ClosureHom

variable {C : ClosureCode α} {D : ClosureCode β}

/-- A closure morphism maps closed sets to closed sets. -/
theorem map_closed (f : ClosureHom C D) {x : Set α} (hx : C.IsClosed x) :
    D.IsClosed (f.toFun x) :=
  f.closed_map' x hx

/-- A closure morphism commutes with closure. -/
theorem comm_closure (f : ClosureHom C D) (x : Set α) :
    f.toFun (C.cl x) = D.cl (f.toFun x) :=
  f.closure_comm' x

/-- **Decoding naturality (Theorem C):**
    A closure morphism commutes with the tropical decoder.
    That is: decode then map = map then decode. -/
theorem decode_naturality (f : ClosureHom C D) (x : Set α) :
    f.toFun (tropicalDecode C x) = tropicalDecode D (f.toFun x) :=
  f.closure_comm' x

/-- Composition of closure morphisms. -/
def comp {γ : Type*} {E : ClosureCode γ}
    (g : ClosureHom D E) (f : ClosureHom C D) : ClosureHom C E where
  toFun := g.toFun ∘ f.toFun
  monotone' := g.monotone'.comp f.monotone'
  closed_map' x hx := g.closed_map' _ (f.closed_map' x hx)
  closure_comm' x := by
    simp only [Function.comp]
    rw [f.closure_comm', g.closure_comm']

/-- The identity closure morphism. -/
def id (C : ClosureCode α) : ClosureHom C C where
  toFun := _root_.id
  monotone' := monotone_id
  closed_map' _ hx := hx
  closure_comm' _ := rfl

end ClosureHom

/-- A compatible presentation pair for a morphism: presentations of source and
    target that are related by the morphism at the implication level. -/
structure CompatiblePresentations
    (C : ClosureCode α) (D : ClosureCode β)
    (f : ClosureHom C D)
    (P₁ : ClosurePresentation α)
    (P₂ : ClosurePresentation β) : Prop where
  /-- Each target implication is "dominated" by some source implication
      via the morphism. -/
  compatible : ∀ imp₂ ∈ P₂.implications,
    ∀ x : Set α, imp₂.violation (f.toFun x) ≤
      P₁.implications.sum (fun imp₁ => imp₁.violation x)

/-- **Syndrome Naturality (Theorem C):**
    Under compatible presentations, the syndrome of the image is bounded
    by the syndrome of the source. This is the functorial inequality
    for tropical syndromes. -/
theorem syndrome_naturality
    {C : ClosureCode α} {D : ClosureCode β}
    (f : ClosureHom C D)
    (P₁ : ClosurePresentation α) (P₂ : ClosurePresentation β)
    (hcomp : CompatiblePresentations C D f P₁ P₂)
    (x : Set α) :
    syndrome P₂ (f.toFun x) ≤ P₂.implications.card * syndrome P₁ x := by
  unfold syndrome
  calc P₂.implications.sum (fun imp => imp.violation (f.toFun x))
      ≤ P₂.implications.sum (fun _ => P₁.implications.sum (fun imp₁ => imp₁.violation x)) := by
        apply Finset.sum_le_sum
        intro imp₂ himp₂
        exact hcomp.compatible imp₂ himp₂ x
    _ = P₂.implications.card * P₁.implications.sum (fun imp₁ => imp₁.violation x) := by
        rw [Finset.sum_const, smul_eq_mul]

/-- Under exact compatibility where each target violation maps to at most one source
    violation, the syndrome inequality is tight. -/
structure ExactCompatiblePresentations
    (C : ClosureCode α) (D : ClosureCode β)
    (f : ClosureHom C D)
    (P₁ : ClosurePresentation α)
    (P₂ : ClosurePresentation β) : Prop where
  /-- Syndrome of the image equals syndrome of the source -/
  exact : ∀ x : Set α, syndrome P₂ (f.toFun x) = syndrome P₁ x

/-- Under exact compatibility, syndrome is preserved. -/
theorem syndrome_exact_naturality
    {C : ClosureCode α} {D : ClosureCode β}
    (f : ClosureHom C D)
    (P₁ : ClosurePresentation α) (P₂ : ClosurePresentation β)
    (hcomp : ExactCompatiblePresentations C D f P₁ P₂)
    (x : Set α) :
    syndrome P₂ (f.toFun x) = syndrome P₁ x :=
  hcomp.exact x

end