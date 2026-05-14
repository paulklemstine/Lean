/-
# Tropical Complexity Theory: Definitions

This file establishes the foundational definitions for tropical complexity theory,
a framework connecting bounded-space computation to min-plus linear algebra.

## Key Ideas

- Configurations become vertices in a finite directed graph.
- Transitions become edges encoded as entries in a min-plus matrix.
- Bounded-space computations correspond to paths in layered graphs.
- Simulation cost = tropical matrix power = shortest-path computation.
- "Hardness of flattening space into time" becomes a theorem about
  tropical path lengths and layer structure.

## Mathematical Setup

We work over `Tropical (WithTop ℕ)`, the min-plus semiring where:
- Addition is `min` (with identity `⊤`)
- Multiplication is `+` (with identity `0`)

For adjacency/transition matrices, entries are either:
- `trop (0 : WithTop ℕ)` = `1` in the semiring, meaning "edge exists"
- `trop (⊤ : WithTop ℕ)` = `0` in the semiring, meaning "no edge"

Then `(W ^ k) i j = 1` iff there exists a walk of length `k` from `i` to `j`.
-/

import Mathlib

open Tropical Matrix Finset

namespace TropicalComplexity

/-- The tropical semiring we use: min-plus over natural numbers with infinity. -/
abbrev T := Tropical (WithTop ℕ)

/-- The "edge present" value: cost 0, which equals `1` in the tropical semiring. -/
noncomputable abbrev edge : T := 1

/-- The "no edge" value: cost ∞, which equals `0` in the tropical semiring. -/
noncomputable abbrev noEdge : T := 0

/-- A transition matrix is a 0/1 matrix in the tropical semiring:
    every entry is either `edge` (= 1) or `noEdge` (= 0). -/
def IsZeroInfMatrix {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) : Prop :=
  ∀ a b, W a b = edge ∨ W a b = noEdge

/-- Predicate: there is a directed edge from `a` to `b` in the transition matrix. -/
def HasEdge {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (a b : α) : Prop :=
  W a b = edge

/-- A walk of length `k` from `s` to `t` in the graph defined by matrix `W`.
    This is the key combinatorial object: a sequence of vertices connected by edges. -/
def Walk {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (s t : α) : ℕ → Prop
  | 0 => s = t
  | k + 1 => ∃ u, HasEdge W s u ∧ Walk W u t k

/-- A layered (ranked) transition matrix: every edge increases rank by exactly 1. -/
def IsLayered {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (W : Matrix α α T) : Prop :=
  ∀ a b, W a b = edge → rank b = rank a + 1

/-- A finite transition system representing a bounded-space computation. -/
structure TransitionSystem where
  /-- Configuration type (finite) -/
  Cfg : Type
  /-- Finiteness of configurations -/
  finCfg : Fintype Cfg
  /-- Decidable equality on configurations -/
  decEqCfg : DecidableEq Cfg
  /-- The transition matrix -/
  W : Matrix Cfg Cfg T
  /-- Start configuration -/
  start : Cfg
  /-- Accept configuration -/
  accept : Cfg

attribute [instance] TransitionSystem.finCfg TransitionSystem.decEqCfg

/-- A layered transition system with a rank function. -/
structure LayeredSystem extends TransitionSystem where
  /-- Rank function assigning layers to configurations -/
  rank : Cfg → ℕ
  /-- The matrix respects the layering -/
  layered : IsLayered rank W
  /-- Start has rank 0 -/
  startRank : rank start = 0

/-- A family of transition systems indexed by input length. -/
structure TransitionFamily where
  /-- System for each input length -/
  system : ℕ → TransitionSystem
  /-- Space bound: number of configuration bits -/
  spaceBound : ℕ → ℕ
  /-- Time bound: maximum computation steps -/
  timeBound : ℕ → ℕ
  /-- Configuration count bounded by 2^(spaceBound n) -/
  cfgBound : ∀ n, Fintype.card (system n).Cfg ≤ 2 ^ spaceBound n

/-- Tropical reachability: `t` is reachable from `s` in exactly `k` steps. -/
def TropicalReachable {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (s t : α) (k : ℕ) : Prop :=
  (W ^ k) s t = edge

/-- A tropical compression: a matrix `C` that "dominates" `W` in the sense
    that any reachability witness in `C` implies reachability in the transitive
    closure of `W`. -/
def TropicalDominates {α : Type*} [Fintype α] [DecidableEq α]
    (C W : Matrix α α T) : Prop :=
  ∀ a b, C a b = edge → ∃ k, (W ^ k) a b = edge

end TropicalComplexity