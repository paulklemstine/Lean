/-
  The Boolean diagonalisation engine behind the halting problem.

  `Logic/LucasPenroseGodel.lean` refers to `SelfModHalt.diagonal_no_decider`, the abstract
  Boolean core of the halting argument, but the module providing it is not part of this
  development.  This file supplies it, with a complete proof, in the exact form in which it
  is used: a Cantor-style diagonalisation showing that no type enumerates all of its own
  Boolean tests, so a "self-testing machine" (a surjective enumeration together with a
  matching decider) cannot exist.
-/

import Mathlib

namespace SelfModHalt

/-- **Boolean Cantor / diagonalisation.**  No map `enum : α → (α → Bool)` is surjective:
the anti-diagonal test `a ↦ !enum a a` is not in the range, since at its own index it
would have to equal its own negation. -/
theorem not_surjective_boolean_enum {α : Type*} (enum : α → α → Bool) :
    ¬ Function.Surjective enum := by
  intro hsurj
  obtain ⟨b, hb⟩ := hsurj (fun a => !enum a a)
  have h : enum b b = !enum b b := congrFun hb b
  cases hbb : enum b b <;> rw [hbb] at h <;> simp at h

/-- **No self-modifying decider.**  If a Boolean enumeration of a type by its own tests
were surjective, then no decider could reproduce it — indeed the hypothesis is already
contradictory by `not_surjective_boolean_enum`, which is precisely the diagonal obstruction
underlying the undecidability of the halting problem. -/
theorem diagonal_no_decider {α : Type*} (enum : α → α → Bool)
    (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → Bool, ∀ i a, d i a = enum i a :=
  absurd surj (not_surjective_boolean_enum enum)

end SelfModHalt