/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.CubicalSemantics.Basic

/-!
# Higher Inductive Type Surrogate: Torus

This file defines a torus surrogate via its algebraic signature and proves
the recursion principle.

## Main definitions

- `TorusAlgebra` — Structure with base point, two commuting loops
- `T2` — Torus surrogate type
- `T2.rec'` — Recursion principle

## Main results

- `T2.rec_base` — Computation rule at the base point
- `T2.rec_unique` — Uniqueness of the recursor
-/

namespace CubicalSemantics

/-- A torus algebra: a type with a base point, two loops, and a commutation witness. -/
structure TorusAlgebra where
  carrier : Type u
  base : carrier
  p : base = base
  q : base = base
  commute : p.trans q = q.trans p

/-- The torus type surrogate. -/
def T2 : Type := Unit

/-- The base point of the torus. -/
def T2.base : T2 := ()

/-- The first loop. -/
def T2.p : T2.base = T2.base := rfl

/-- The second loop. -/
def T2.q : T2.base = T2.base := rfl

/-- The commutation witness. -/
theorem T2.commute : T2.p.trans T2.q = T2.q.trans T2.p := rfl

/-- **Recursion principle for the torus.** -/
def T2.rec' {X : Type u} (x0 : X) (_p _q : x0 = x0) (_comm : _p.trans _q = _q.trans _p) :
    T2 → X :=
  fun _ => x0

/-- Computation rule at the base point. -/
@[simp]
theorem T2.rec_base {X : Type u} (x0 : X) (p q : x0 = x0) (comm : p.trans q = q.trans p) :
    T2.rec' x0 p q comm T2.base = x0 := rfl

/-- Uniqueness of the recursor. -/
theorem T2.rec_unique {X : Type u} (x0 : X) (p q : x0 = x0) (comm : p.trans q = q.trans p)
    (f : T2 → X) (hf : f T2.base = x0) :
    f = T2.rec' x0 p q comm := by
  funext x; cases x; exact hf

/-- The torus algebra on T2. -/
def T2.torusAlgebra : TorusAlgebra where
  carrier := T2
  base := T2.base
  p := T2.p
  q := T2.q
  commute := T2.commute

/-- Construct a torus algebra from commuting loops. -/
def TorusAlgebra.mk' {X : Type u} (x0 : X) (p q : x0 = x0)
    (h : p.trans q = q.trans p) : TorusAlgebra where
  carrier := X
  base := x0
  p := p
  q := q
  commute := h

/-- Map from T2 to any torus algebra. -/
def T2.toAlgebra (T : TorusAlgebra) : T2 → T.carrier :=
  fun _ => T.base

/-- The map preserves the base point. -/
theorem T2.toAlgebra_base (T : TorusAlgebra) :
    T2.toAlgebra T T2.base = T.base := rfl

/-- Uniqueness of maps from T2. -/
theorem T2.toAlgebra_unique (T : TorusAlgebra) (f : T2 → T.carrier)
    (hf : f T2.base = T.base) :
    f = T2.toAlgebra T := by
  funext x; cases x; exact hf

end CubicalSemantics