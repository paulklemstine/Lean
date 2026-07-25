/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.CubicalSemantics.Basic

/-!
# Higher Inductive Type Surrogate: Suspension

This file implements a suspension type surrogate using Lean's quotient types and proves
its recursion principle.

## Main definitions

- `SuspPre` — Pre-suspension type with north and south poles
- `SuspRel` — Meridian relation identifying poles along elements of `A`
- `Susp` — Suspension type as a quotient
- `Susp.rec'` — The recursion principle

## Main results

- `Susp.rec_north` — Computation rule at the north pole
- `Susp.rec_south` — Computation rule at the south pole
- `Susp.rec_unique` — Uniqueness of the recursor
- `Susp.suspEmptyEquivBool` — `Susp Empty ≃ Bool`
- `Susp.susp_nonempty_unique` — `Susp A` is a singleton when `A` is nonempty
-/

namespace CubicalSemantics

/-- Pre-suspension type: north and south poles. -/
inductive SuspPre (A : Type u) : Type u where
  | north : SuspPre A
  | south : SuspPre A

/-- Meridian relation: for each `a : A`, identify north with south. -/
inductive SuspRel (A : Type u) : SuspPre A → SuspPre A → Prop where
  | merid (a : A) : SuspRel A .north .south

/-- The suspension of `A`, constructed as a quotient. -/
def Susp (A : Type u) : Type u := Quot (SuspRel A)

namespace Susp

/-- The north pole. -/
def north {A : Type u} : Susp A := Quot.mk _ .north

/-- The south pole. -/
def south {A : Type u} : Susp A := Quot.mk _ .south

/-- Meridians identify north and south for each element of `A`. -/
theorem merid_eq {A : Type u} (a : A) : (north : Susp A) = south :=
  Quot.sound (SuspRel.merid a)

/-- **Recursion principle for the suspension.** -/
def rec' {A : Type u} {X : Type v}
    (n s : X) (m : A → n = s) : Susp A → X :=
  Quot.lift (fun p => match p with | .north => n | .south => s) (by
    intro a b r
    cases r with
    | merid a => exact m a)

/-- Computation rule at the north pole. -/
@[simp]
theorem rec_north {A : Type u} {X : Type v}
    (n s : X) (m : A → n = s) : rec' n s m north = n := rfl

/-- Computation rule at the south pole. -/
@[simp]
theorem rec_south {A : Type u} {X : Type v}
    (n s : X) (m : A → n = s) : rec' n s m south = s := rfl

/-- Uniqueness of the recursor. -/
theorem rec_unique {A : Type u} {X : Type v}
    (n s : X) (m : A → n = s)
    (f : Susp A → X)
    (hfn : f north = n) (hfs : f south = s) :
    f = rec' n s m := by
  funext x
  induction x using Quot.ind with
  | mk p => cases p with
    | north => exact hfn
    | south => exact hfs

/-- The suspension of `Empty` is equivalent to `Bool`. -/
noncomputable def suspEmptyEquivBool : Susp Empty ≃ Bool where
  toFun := rec' false true (fun e => e.elim)
  invFun := fun b => if b then south else north
  left_inv := by
    intro x
    induction x using Quot.ind with
    | mk p => cases p <;> rfl
  right_inv := by
    intro b; cases b <;> rfl

/-- When `A` is nonempty, all elements of `Susp A` are equal. -/
theorem susp_nonempty_unique {A : Type u} [Nonempty A] (x y : Susp A) : x = y := by
  have a := Classical.arbitrary A
  have hn : ∀ z : Susp A, z = north := by
    intro z
    induction z using Quot.ind with
    | mk p => cases p with
      | north => rfl
      | south => exact (merid_eq a).symm
  rw [hn x, hn y]

end Susp

end CubicalSemantics