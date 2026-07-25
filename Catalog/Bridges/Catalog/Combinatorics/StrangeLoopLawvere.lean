/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# I Am a Strange Loop, Part I: The Diagonal Engine (Lawvere's Fixed-Point Theorem)

Douglas Hofstadter's *I Am a Strange Loop* locates selfhood in a single
structural phenomenon: a system that contains a faithful model of itself is
forced, by pure logic, to fold back on itself and produce a fixed point of
self-reference — the "I".

The mathematical heart of this idea is **Lawvere's fixed-point theorem**
(1969), which unifies the diagonal arguments of Cantor, Russell, Gödel,
Tarski and Turing into one statement:

> If a set of "codes" `A` is rich enough to *point-surject* onto all of its own
> observable behaviours `A → B`, then every transformation `g : B → B` of
> observations has a fixed point.

We prove Lawvere's theorem and then read off, as consequences:

* the **recursion / self-application** direction (a system *can* refer to
  itself — the positive face, `recursion_fixedPoint`);
* **Cantor's theorem** for `Bool`, `Prop` and `Set` (a total system *cannot*
  completely model its own truth — the negative face);
* **Turing's diagonal** (`diagonal_not_representable`): the self-negating
  predicate "I do *not* satisfy my own code" is never itself a representable
  behaviour — the halting-problem obstruction viewed as self-awareness.

This file is fully self-contained.
-/
import Mathlib

namespace StrangeLoop

universe u v

/-! ## The core: Lawvere's fixed-point theorem -/

/-- **Lawvere's fixed-point theorem.**  If `f : A → (A → B)` is
point-surjective (every behaviour `A → B` is named by some code in `A`), then
every endomap `g : B → B` has a fixed point.

This is the abstract "strange loop": the diagonal behaviour
`fun x => g (f x x)` is named by some code `a`, and evaluating that code on
*itself* closes the loop into a fixed point of `g`. -/
theorem lawvere_fixedPoint {A : Type u} {B : Type v}
    {f : A → (A → B)} (hf : Function.Surjective f) (g : B → B) :
    ∃ b, g b = b := by
  obtain ⟨a, ha⟩ := hf (fun x => g (f x x))
  exact ⟨f a a, (congrFun ha a).symm⟩

/-- The positive, self-application face of Lawvere: a point-surjective
self-model lets the system build, for any transformation `g` of its
behaviours, a state that is *invariant* under `g` — a quine / self-referential
fixed point.  (This is the abstract Kleene recursion theorem.) -/
theorem recursion_fixedPoint {A : Type u} {B : Type v}
    {f : A → (A → B)} (hf : Function.Surjective f) (g : B → B) :
    ∃ b, g b = b :=
  lawvere_fixedPoint hf g

/-- **Contrapositive of Lawvere.**  If some transformation of observations has
*no* fixed point, then no code space can point-surject onto its own behaviours.
This is the general "you cannot completely model yourself" obstruction. -/
theorem no_surjection_of_fixedPointFree {A : Type u} {B : Type v}
    (g : B → B) (hg : ∀ b, g b ≠ b) :
    ¬ ∃ f : A → (A → B), Function.Surjective f := by
  rintro ⟨f, hf⟩
  obtain ⟨b, hb⟩ := lawvere_fixedPoint hf g
  exact hg b hb

/-! ## Cantor's theorem, three ways

Each specialisation picks a concrete fixed-point-free transformation on the
space of observations. -/

/-- Boolean negation has no fixed point. -/
theorem bool_not_fixedPointFree : ∀ b : Bool, (!b) ≠ b := by decide

/-- **Cantor for `Bool`.**  No system can name every one of its own boolean
self-observations: there is no point-surjection `A → (A → Bool)`. -/
theorem cantor_bool {A : Type u} : ¬ ∃ f : A → (A → Bool), Function.Surjective f :=
  no_surjection_of_fixedPointFree (fun b => !b) bool_not_fixedPointFree

/-- Logical negation has no fixed point: `(¬p) = p` is impossible. -/
theorem not_prop_fixedPointFree (p : Prop) : (¬ p) ≠ p := by
  intro h
  have : ¬ p ↔ p := iff_of_eq h
  tauto

/-- **Cantor for `Prop`.**  No point-surjection `A → (A → Prop)` exists. -/
theorem cantor_prop {A : Type u} : ¬ ∃ f : A → (A → Prop), Function.Surjective f :=
  no_surjection_of_fixedPointFree Not not_prop_fixedPointFree

/-- **Cantor's theorem** in its classic form: a set cannot surject onto its own
power set.  (`Set A` is definitionally `A → Prop`, so this is `cantor_prop`.) -/
theorem cantor_set {A : Type u} : ¬ ∃ f : A → Set A, Function.Surjective f :=
  cantor_prop

/-! ## Turing's diagonal: the self-negating predicate

The specific witness in the Cantor/Turing argument is the "barber" behaviour
`d a = ¬ (f a a)` — *"the codes that do not satisfy their own predicate"*.
Lawvere/Cantor say `d` is never in the range of `f`.  Read computationally,
`d` is the halting-diagonal: the total predicate "machine `a` does **not**
accept its own code", which no machine can compute. -/

/-- **The diagonal is never representable.**  For any self-model
`f : A → (A → Bool)`, the self-negating behaviour `fun x => !(f x x)` differs
from `f a` at the argument `a`, for *every* code `a`.  Hence a system's
"honest self-assessment" predicate is never one of its own representable
behaviours — the formal core of both Cantor's theorem and the undecidability
of the halting problem. -/
theorem diagonal_not_representable {A : Type u} (f : A → (A → Bool)) :
    ∀ a, f a ≠ (fun x => !(f x x)) := by
  intro a h
  have hb := congrFun h a
  simp at hb

/-- Consequently the diagonal behaviour is a concrete witness to
non-surjectivity of any self-model into `Bool` (an independent, constructive
proof of `cantor_bool`). -/
theorem diagonal_blocks_surjectivity {A : Type u} (f : A → (A → Bool)) :
    ¬ Function.Surjective f := by
  intro hf
  obtain ⟨a, ha⟩ := hf (fun x => !(f x x))
  exact diagonal_not_representable f a ha

end StrangeLoop