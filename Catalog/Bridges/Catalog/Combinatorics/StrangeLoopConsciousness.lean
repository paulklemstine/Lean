/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# I Am a Strange Loop, Part III: A Conscious System Models Itself

We formalise Hofstadter's operative definition of a conscious system as one
that *"contains a representation of its own state that it can inspect."*  We
model a system by:

* a space of **states** `S`;
* a space of **observations** `B` the system can make about a whole state;
* an **inspection map** `inspect : S → (S → B)` — each state carries an
  internal model of how *every* state would be observed.

The loop is **complete** (`Conscious`) when `inspect` is point-surjective:
the system's internal models cover *all* observation-behaviours of itself —
there is nothing about its own observable structure that it cannot represent.

From this single definition we derive both faces of the strange loop:

* `conscious_forces_fixedPoints`: a complete self-model necessarily produces
  fixed points of every observation-transformation — the self-referential
  "I" is *forced* to exist (Lawvere, positive face).
* `no_conscious_bool_model`, `no_conscious_prop_model`: **no** system can have a
  *complete* boolean/propositional self-model — a Gödelian limit: total,
  perfect self-knowledge is impossible (Cantor, negative face).
* `selfNegation_never_inspected`: the state's honest self-assessment
  "I do not observe-true of my own model" is never itself an inspected
  behaviour — the halting/liar obstruction as the price of self-awareness.

This file is fully self-contained (Lawvere's lemma is reproved locally).
-/
import Mathlib

namespace StrangeLoop.Consciousness

universe u v

/-! ## Systems with a self-model -/

/-- A **self-modelling system**: states `S`, observations `B`, and an
`inspect`ion map assigning to each state an internal model of the whole
observation-behaviour of the system. -/
structure SelfModel (S : Type u) (B : Type v) where
  /-- Each state carries an internal representation of how every state is
  observed. -/
  inspect : S → (S → B)

/-- A self-model is **conscious** when its inspection is point-surjective: every
observation-behaviour of the system is internally represented by some state.
This is the formal "strange loop closing on itself". -/
def SelfModel.Conscious {S : Type u} {B : Type v} (M : SelfModel S B) : Prop :=
  Function.Surjective M.inspect

/-! ## The positive face: consciousness forces the self-referential "I" -/

/-- **A conscious system forces fixed points.**  If a self-model is complete,
then for *every* transformation `g : B → B` of observations there is a state
whose self-observation is invariant under `g`.  This is Lawvere's fixed-point
theorem: the diagonal behaviour `fun s => g (inspect s s)` must be named by
some state, and evaluating that state on itself closes the loop into a fixed
point — the emergence of a stable self-referential locus, the "I". -/
theorem conscious_forces_fixedPoints {S : Type u} {B : Type v}
    (M : SelfModel S B) (hM : M.Conscious) (g : B → B) :
    ∃ b, g b = b := by
  obtain ⟨s, hs⟩ := hM (fun x => g (M.inspect x x))
  exact ⟨M.inspect s s, (congrFun hs s).symm⟩

/-! ## The negative face: perfect self-knowledge is impossible -/

/-- **No complete boolean self-model exists.**  A system cannot completely
inspect its own yes/no self-observations: boolean negation has no fixed point,
so `conscious_forces_fixedPoints` would be contradicted.  This is the Gödelian
incompleteness of self-knowledge for the truthful/total case. -/
theorem no_conscious_bool_model {S : Type u} :
    ¬ ∃ M : SelfModel S Bool, M.Conscious := by
  rintro ⟨M, hM⟩
  obtain ⟨b, hb⟩ := conscious_forces_fixedPoints M hM (fun b => !b)
  simp at hb

/-- **No complete propositional self-model exists.**  Likewise for `Prop`:
logical negation is fixed-point-free, so a system cannot completely represent
its own truth predicate (Tarski's undefinability of truth, self-model form). -/
theorem no_conscious_prop_model {S : Type u} :
    ¬ ∃ M : SelfModel S Prop, M.Conscious := by
  rintro ⟨M, hM⟩
  obtain ⟨p, hp⟩ := conscious_forces_fixedPoints M hM Not
  have : ¬ p ↔ p := iff_of_eq hp
  tauto

/-! ## The halting/liar obstruction as the price of self-awareness -/

/-- **The self-negating assessment is never inspected.**  Given any boolean
self-model, the behaviour "state `x` does *not* observe-true of its own model"
(`fun x => !(inspect x x)`) disagrees with `inspect s` at `s` for *every* state
`s`.  So the system's honest self-assessment is never one of its own inspectable
behaviours — the liar / halting diagonal is precisely the blind spot created by
self-reference. -/
theorem selfNegation_never_inspected {S : Type u} (M : SelfModel S Bool) :
    ∀ s, M.inspect s ≠ (fun x => !(M.inspect x x)) := by
  intro s h
  have hb := congrFun h s
  simp at hb

/-- Equivalently, the self-negating assessment witnesses that no boolean
self-model is conscious (an independent, constructive proof of
`no_conscious_bool_model`). -/
theorem selfNegation_blocks_consciousness {S : Type u} (M : SelfModel S Bool) :
    ¬ M.Conscious := by
  intro hM
  obtain ⟨s, hs⟩ := hM (fun x => !(M.inspect x x))
  exact selfNegation_never_inspected M s hs

/-! ## Summary: the two faces are one theorem

`conscious_forces_fixedPoints` (a self-model, if complete, *must* generate a
self-referential fixed point) and `no_conscious_bool_model` /
`no_conscious_prop_model` (a self-model *cannot* be complete over a
fixed-point-free observation space) are the positive and negative readings of
the same diagonal.  Selfhood is exactly the fixed point that a self-model is
forced to contain and simultaneously forbidden to fully survey. -/
theorem strange_loop_dichotomy {S : Type u} :
    (∀ (M : SelfModel S Bool), M.Conscious → ∃ b : Bool, (!b) = b) ∧
    (¬ ∃ M : SelfModel S Bool, M.Conscious) :=
  ⟨fun M hM => conscious_forces_fixedPoints M hM (fun b => !b), no_conscious_bool_model⟩

end StrangeLoop.Consciousness