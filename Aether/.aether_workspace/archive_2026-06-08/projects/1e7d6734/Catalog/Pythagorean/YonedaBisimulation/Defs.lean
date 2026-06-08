/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Yoneda-Bisimulation Correspondence: Definitions

This file defines labeled transition systems (LTS), bisimulation relations,
trace semantics, and the experiment-based characterization that connects
Yoneda extensionality to process equivalence.

## Main Definitions

* `LTS` — Labeled transition system with decidable transitions
* `IsBisimulation` — The zigzag condition for a relation between LTS states
* `Bisimilar` — Two states are bisimilar if connected by some bisimulation
* `TraceAccepted` — A state can perform a given trace (list of actions)
* `TraceEquiv` — Two states accept exactly the same traces
* `ImageFinite` — Every state has finitely many successors per action

## Key Results

* Bisimulation is an equivalence relation
* Bisimilarity implies trace equivalence
* For image-finite systems, the correspondence theorem holds
-/

import Mathlib

universe u

namespace YonedaBisimulation

/-- A labeled transition system over action type `Act` with state type `State`. -/
structure LTS (Act : Type u) where
  /-- The type of states -/
  State : Type u
  /-- The transition relation: `step s a s'` means state `s` can transition
      to state `s'` via action `a` -/
  step : State → Act → State → Prop

/-- A relation `R` between states of two LTS is a bisimulation if it satisfies
    the zigzag condition: every transition from one side can be matched by
    the other side while preserving `R`. -/
structure IsBisimulation {Act : Type u} (P Q : LTS Act)
    (R : P.State → Q.State → Prop) : Prop where
  /-- Forward simulation: if `R s t` and `s →[a] s'`, then there exists
      `t'` such that `t →[a] t'` and `R s' t'` -/
  zig : ∀ s t a s', R s t → P.step s a s' → ∃ t', Q.step t a t' ∧ R s' t'
  /-- Backward simulation: if `R s t` and `t →[a] t'`, then there exists
      `s'` such that `s →[a] s'` and `R s' t'` -/
  zag : ∀ s t a t', R s t → Q.step t a t' → ∃ s', P.step s a s' ∧ R s' t'

/-- Two states `s` and `t` are bisimilar if there exists a bisimulation
    relating them. -/
def Bisimilar {Act : Type u} (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∃ R : P.State → Q.State → Prop, IsBisimulation P Q R ∧ R s t

/-- A trace is a finite sequence of actions. -/
abbrev Trace (Act : Type u) := List Act

/-- A state `s` can perform trace `σ` if there is a sequence of transitions
    matching `σ` starting from `s`. -/
inductive TraceAccepted {Act : Type u} (P : LTS Act) : P.State → Trace Act → Prop where
  | nil : ∀ s, TraceAccepted P s []
  | cons : ∀ s a σ s', P.step s a s' → TraceAccepted P s' σ → TraceAccepted P s (a :: σ)

/-- Two states are trace-equivalent if they accept exactly the same traces. -/
def TraceEquiv {Act : Type u} (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∀ σ : Trace Act, TraceAccepted P s σ ↔ TraceAccepted Q t σ

/-- An LTS is image-finite if for every state and action, there are only
    finitely many successor states. -/
class ImageFinite {Act : Type u} (P : LTS Act) : Prop where
  finite_successors : ∀ (s : P.State) (a : Act), Set.Finite {s' | P.step s a s'}

/-- The set of states reachable from `s` via trace `σ`. This is the key
    construction for the nerve presheaf: `nerveSet P s σ` is the fiber
    of the nerve at experiment `σ` containing states reachable from `s`. -/
def reachableViaTrace {Act : Type u} (P : LTS Act) :
    P.State → Trace Act → Set P.State
  | s, [] => {s}
  | s, a :: σ => ⋃ s' ∈ {t | P.step s a t}, reachableViaTrace P s' σ

/-- The identity relation on states of an LTS. Used for reflexivity of bisimulation. -/
def idRel {Act : Type u} (P : LTS Act) : P.State → P.State → Prop :=
  fun s t => s = t

/-- The converse of a relation. Used for symmetry of bisimulation. -/
def convRel {Act : Type u} {P Q : LTS Act}
    (R : P.State → Q.State → Prop) : Q.State → P.State → Prop :=
  fun t s => R s t

/-- The composition of two relations. Used for transitivity of bisimulation. -/
def compRel {Act : Type u} {P Q R₀ : LTS Act}
    (R : P.State → Q.State → Prop) (S : Q.State → R₀.State → Prop) :
    P.State → R₀.State → Prop :=
  fun s u => ∃ t, R s t ∧ S t u

/-- The union of all bisimulations between two LTS states.
    This is itself a bisimulation — the largest one — and equals bisimilarity. -/
def bisimUnion {Act : Type u} (P Q : LTS Act) : P.State → Q.State → Prop :=
  fun s t => Bisimilar P Q s t

end YonedaBisimulation