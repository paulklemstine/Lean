/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Meeting-Time Filtration for Finite Trajectories

This file introduces the **meeting-time filtration** — a deterministic construction that
assigns a filtered graph to any finite trajectory in a finite state space. The filtration
captures when pairs of states have both been "discovered" along the walk, creating a
monotone family of graphs whose connectivity phase transition is a topological proxy for
mixing/universality phenomena.

## Main Definitions

* `visitedSet x t` — the set of states visited by trajectory `x` up to time `t`
* `appearsBy x a t` — predicate that state `a` has been visited by time `t`
* `meetEdge x t a b` — predicate that the edge `{a, b}` exists in the filtration at time `t`
* `leftTranslatePath g x` — left-translate a group-valued trajectory by `g`
* `visitedSetCard x t` — cardinality of visited set at time `t`
* `fullVisitedSet x` — all states visited during the entire trajectory

## Design Decisions

We work with `Fin (T + 1)` as the time index to ensure trajectories always have at least
one point. The visited set is defined as a `Finset` for computational decidability.
The filtration is monotone by construction — later times can only add vertices and edges.
-/

import Mathlib

namespace PersistentHomologyMixing

/-! ## Core Definitions -/

/-- The set of states visited by trajectory `x` up through time `t`. -/
def visitedSet {α : Type*} [DecidableEq α] {T : ℕ} (x : Fin (T + 1) → α)
    (t : Fin (T + 1)) : Finset α :=
  (Finset.univ.filter fun i : Fin (T + 1) => i ≤ t).image x

/-- State `a` has appeared in trajectory `x` by time `t`. -/
def appearsBy {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (a : α) (t : Fin (T + 1)) : Prop :=
  a ∈ visitedSet x t

instance {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (a : α) (t : Fin (T + 1)) : Decidable (appearsBy x a t) :=
  Finset.decidableMem a (visitedSet x t)

/-- The edge `{a, b}` exists in the meeting-time filtration at time `t`:
    both `a` and `b` are distinct and have been visited by time `t`. -/
def meetEdge {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (t : Fin (T + 1)) (a b : α) : Prop :=
  a ≠ b ∧ appearsBy x a t ∧ appearsBy x b t

instance {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (t : Fin (T + 1)) (a b : α) : Decidable (meetEdge x t a b) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

/-- The full visited set — all states visited during the entire trajectory. -/
def fullVisitedSet {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) : Finset α :=
  visitedSet x ⟨T, Nat.lt_succ_self T⟩

/-- The number of distinct states visited by time `t`. -/
def visitedSetCard {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (t : Fin (T + 1)) : ℕ :=
  (visitedSet x t).card

/-- Left-translate a group-valued trajectory. -/
def leftTranslatePath {G : Type*} [Mul G] {T : ℕ}
    (g : G) (x : Fin (T + 1) → G) : Fin (T + 1) → G :=
  fun i => g * x i

end PersistentHomologyMixing