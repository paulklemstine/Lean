/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.CubicalSemantics.Basic

/-!
# Higher Inductive Type Surrogate: Circle

This file defines a circle surrogate and its recursion principle.

## Main definitions

- `CircleAlgebra` — Structure packaging a type with a base point and a loop
- `S1` — Circle surrogate (contractible in 0-truncated type theory)
- `S1.rec'` — Recursion principle

## Main results

- `S1.rec_base` — Computation rule at the base point
- `S1.rec_unique` — Uniqueness of the recursor
- `S1.toAlgebra_unique` — Initiality of S1 among circle algebras

## Design

In a 0-truncated type theory like Lean 4, the circle is contractible.
We model it as `Unit` and capture the algebraic content through the
recursion principle interface and the `CircleAlgebra` signature.
-/

namespace CubicalSemantics

/-- A circle algebra consists of a type with a base point and a loop. -/
structure CircleAlgebra (I : Type u) [CubicalInterval I] where
  /-- The carrier type. -/
  carrier : Type v
  /-- The base point. -/
  base : carrier
  /-- The loop at the base point. -/
  loop : PathOver (I := I) carrier base base

/-- A morphism of circle algebras preserving the base point. -/
structure CircleAlgebra.Morphism {I : Type u} [CubicalInterval I]
    (C D : CircleAlgebra I) where
  func : C.carrier → D.carrier
  func_base : func C.base = D.base

/-- Morphism composition. -/
def CircleAlgebra.Morphism.comp {I : Type u} [CubicalInterval I]
    {C D E : CircleAlgebra I}
    (g : CircleAlgebra.Morphism D E) (f : CircleAlgebra.Morphism C D) :
    CircleAlgebra.Morphism C E where
  func := g.func ∘ f.func
  func_base := by
    show g.func (f.func C.base) = E.base
    rw [f.func_base, g.func_base]

/-- The identity morphism. -/
def CircleAlgebra.Morphism.id {I : Type u} [CubicalInterval I]
    (C : CircleAlgebra I) : CircleAlgebra.Morphism C C where
  func := _root_.id
  func_base := rfl

/-- The circle type surrogate. -/
def S1 : Type := Unit

/-- The base point of the circle. -/
def S1.base : S1 := ()

/-- The trivial loop at the base point. -/
def S1.loop : S1.base = S1.base := rfl

/-- **Recursion principle for the circle.** -/
def S1.rec' {X : Type u} (x0 : X) (_ℓ : x0 = x0) : S1 → X :=
  fun _ => x0

/-- Computation rule at the base point. -/
@[simp]
theorem S1.rec_base {X : Type u} (x0 : X) (ℓ : x0 = x0) :
    S1.rec' x0 ℓ S1.base = x0 := rfl

/-- Uniqueness of maps from S1. -/
theorem S1.rec_unique {X : Type u} (x0 : X) (ℓ : x0 = x0)
    (f : S1 → X) (hf : f S1.base = x0) :
    f = S1.rec' x0 ℓ := by
  funext x; cases x; exact hf

/-- Circle algebra structure on S1 over Bool. -/
def S1.circleAlgebra : CircleAlgebra Bool where
  carrier := S1
  base := S1.base
  loop := reflPath S1.base

/-- Map from S1 to any circle algebra (initiality). -/
def S1.toAlgebra {I : Type u} [CubicalInterval I] (C : CircleAlgebra I) :
    S1 → C.carrier :=
  fun _ => C.base

/-- The map preserves the base point. -/
theorem S1.toAlgebra_base {I : Type u} [CubicalInterval I] (C : CircleAlgebra I) :
    S1.toAlgebra C S1.base = C.base := rfl

/-- Uniqueness of morphisms from S1 to any algebra. -/
theorem S1.toAlgebra_unique {I : Type u} [CubicalInterval I] (C : CircleAlgebra I)
    (f : S1 → C.carrier) (hf : f S1.base = C.base) :
    f = S1.toAlgebra C := by
  funext x; cases x; exact hf

end CubicalSemantics