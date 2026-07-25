/-
# Pushout as a Higher Inductive Type Surrogate

Defines a pushout via Lean's quotient types, proving recursion and uniqueness.

## Relationship to catalog
- Inspired by `HoTT.SuspensionData` from `Logic.HoTT.Univalence`
- Connects to `fundamental_theorem_oracle'` as a verified recursor construction

## What is genuinely new
- `Pushout`: concrete quotient-based HIT surrogate
- `pushout_rec_unique`: verified universal property
-/

import Mathlib

universe u

namespace HoTTFound

/-! ## Pushout relation -/

/-- Generated equivalence relation on `B ⊕ C` identifying `inl (f a)` with `inr (g a)`. -/
inductive PushoutRel {A B C : Type u} (f : A → B) (g : A → C) :
    B ⊕ C → B ⊕ C → Prop
  | glue : ∀ a, PushoutRel f g (Sum.inl (f a)) (Sum.inr (g a))
  | refl : ∀ x, PushoutRel f g x x
  | symm : ∀ {x y}, PushoutRel f g x y → PushoutRel f g y x
  | trans : ∀ {x y z}, PushoutRel f g x y → PushoutRel f g y z → PushoutRel f g x z

/-- The pushout of `f : A → B` and `g : A → C`. -/
def Pushout {A B C : Type u} (f : A → B) (g : A → C) : Type u :=
  Quot (PushoutRel f g)

/-! ## Canonical maps -/

def Pushout.inl {A B C : Type u} {f : A → B} {g : A → C} (b : B) : Pushout f g :=
  Quot.mk _ (Sum.inl b)

def Pushout.inr {A B C : Type u} {f : A → B} {g : A → C} (c : C) : Pushout f g :=
  Quot.mk _ (Sum.inr c)

theorem Pushout.glue {A B C : Type u} {f : A → B} {g : A → C} (a : A) :
    (Pushout.inl (f := f) (g := g) (f a) : Pushout f g) = Pushout.inr (g a) :=
  Quot.sound (PushoutRel.glue a)

/-! ## Recursion principle -/

/-- The sum eliminator used in pushout recursion. -/
def pushoutSumElim {B C X : Type u} (iB : B → X) (iC : C → X) : B ⊕ C → X
  | Sum.inl b => iB b
  | Sum.inr c => iC c

/-- Recursion for pushouts: given compatible maps, produce a map out of the pushout. -/
def pushout_rec {A B C X : Type u} {f : A → B} {g : A → C}
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a)) :
    Pushout f g → X := by
  apply Quot.lift (pushoutSumElim iB iC)
  intro x y hrel
  induction hrel with
  | glue a => exact comm a
  | refl _ => rfl
  | symm _ ih => exact ih.symm
  | trans _ _ ih1 ih2 => exact ih1.trans ih2

/-- Computation on left inclusions. -/
theorem pushout_rec_inl {A B C X : Type u} {f : A → B} {g : A → C}
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a))
    (b : B) :
    pushout_rec iB iC comm (Pushout.inl b) = iB b := rfl

/-- Computation on right inclusions. -/
theorem pushout_rec_inr {A B C X : Type u} {f : A → B} {g : A → C}
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a))
    (c : C) :
    pushout_rec iB iC comm (Pushout.inr c) = iC c := rfl

/-! ## Universal property -/

/-
**Universal property of the pushout.**
    The recursor produces the unique map satisfying the boundary equations.

    This is the characteristic property: the pushout is the universal cocone
    for the span `B ← A → C`.
-/
theorem pushout_rec_unique
    {A B C X : Type u} (f : A → B) (g : A → C)
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a)) :
    ∃! h : Pushout f g → X,
      (∀ b, h (Pushout.inl b) = iB b) ∧
      (∀ c, h (Pushout.inr c) = iC c) := by
  refine' ⟨ pushout_rec iB iC comm, _, _ ⟩;
  · exact ⟨ fun b => pushout_rec_inl iB iC comm b, fun c => pushout_rec_inr iB iC comm c ⟩;
  · rintro h ⟨ hg₁, hg₂ ⟩;
    funext x;
    induction x using Quot.ind;
    cases ‹_› <;> tauto

/-! ## Pushout of identity maps -/

/-
Gluing along identity maps collapses the pushout.
-/
theorem pushout_id_id_surj {A : Type u} :
    ∀ x : Pushout (id : A → A) (id : A → A),
      ∃ a : A, x = Pushout.inl a := by
  intro x
  induction' x using Quot.ind;
  rename_i x;
  rcases x with ( x | x ) <;> [ exact ⟨ x, rfl ⟩ ; exact ⟨ x, Quot.sound ( PushoutRel.glue x ) |> Eq.symm ⟩ ]

/-! ## Functoriality -/

/-- A commutative square of spans induces a map of pushouts. -/
def pushout_map {A B C A' B' C' : Type u}
    {f : A → B} {g : A → C} {f' : A' → B'} {g' : A' → C'}
    (hA : A → A') (hB : B → B') (hC : C → C')
    (commB : ∀ a, hB (f a) = f' (hA a))
    (commC : ∀ a, hC (g a) = g' (hA a)) :
    Pushout f g → Pushout f' g' :=
  pushout_rec (fun b => Pushout.inl (hB b)) (fun c => Pushout.inr (hC c))
    (fun a => by
      show Pushout.inl (hB (f a)) = Pushout.inr (hC (g a))
      rw [commB, commC]
      exact Pushout.glue (hA a))

end HoTTFound