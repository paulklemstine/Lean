/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Rank / Laplacian Minor Bridge — Definitions

This file establishes the foundational definitions for the bridge between
Baker–Norine divisor rank on graphs and tropical matrix rank of Laplacian
principal minors.

## Main Definitions

* `RootedSubsetData` — a basepoint `q` and a subset `S ⊆ V \ {q}`
* `rootedSubsetDivisor` — the degree-zero divisor `D_S`
* `graphLaplacian` — the standard combinatorial Laplacian matrix
* `laplacianPrincipalMinor` — restriction of a matrix to rows/columns in `S`
* `NestedCutFamily` — structure for monotonicity under subset inclusion
* `firingIndependentOn` — chip-firing independence condition
* `IsTree` — connected acyclic graph predicate

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Develin, Santos, Sturmfels, "On the rank of a tropical matrix" (2005)
-/

import Mathlib

open Finset BigOperators

/-! ### Rooted Subset Data -/

/-- A rooted subset of a finite graph: a basepoint `q` and a subset `S` of vertices
    not containing `q`. -/
structure RootedSubsetData (V : Type*) [Fintype V] [DecidableEq V] where
  q : V
  S : Finset V
  hq : q ∉ S

/-! ### Canonical Divisor Family -/

/-- The canonical degree-zero divisor attached to a rooted subset `(q, S)`:
    `D_S(v) = 1` if `v ∈ S`, `D_S(q) = -|S|`, and `D_S(v) = 0` otherwise. -/
def rootedSubsetDivisor
    {V : Type*} [Fintype V] [DecidableEq V]
    (q : V) (S : Finset V) : V → ℤ :=
  fun v => if v ∈ S then 1 else if v = q then -(S.card : ℤ) else 0

/-! ### Graph Laplacian -/

/-- The combinatorial graph Laplacian matrix `L(G)` with entries:
    `L(v,v) = deg(v)`, `L(v,w) = -1` if `v ~ w`, `L(v,w) = 0` otherwise. -/
def graphLaplacian
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-! ### Laplacian Principal Minor -/

/-- The principal submatrix of a matrix `M` indexed by a finset `S`. -/
def laplacianPrincipalMinor
    {V : Type*} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (S : Finset V) :
    Matrix S S ℤ :=
  fun i j => L i.1 j.1

/-! ### Nested Cut Family -/

/-- A nested cut family for subsets `S ⊆ T` relative to a root `q`:
    vertices in `T \ S` adjacent to `S` must also be adjacent to `q`. -/
structure NestedCutFamily
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (S T : Finset V) : Prop where
  subset : S ⊆ T
  hqT : q ∉ T
  cut_condition : ∀ w, w ∈ T → w ∉ S → (∃ v ∈ S, G.Adj v w) → G.Adj q w

/-! ### Firing Independence -/

/-- A subset `S` is firing-independent on `G` if the Laplacian columns
    restricted to `S` are linearly independent over ℤ. -/
def firingIndependentOn
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ (c : V → ℤ), (∀ v, v ∉ S → c v = 0) →
    (∀ (w : S), S.sum (fun v => c v * graphLaplacian G v w) = 0) →
    (∀ v, c v = 0)

/-! ### IsTree predicate -/

/-- A simple graph is a tree if it is connected and has `|V| - 1` edges. -/
def IsTree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Prop :=
  G.Connected ∧ G.edgeFinset.card + 1 = Fintype.card V