/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Rank / Laplacian Minor Bridge — Definitions

Foundational definitions for the bridge between Baker–Norine divisor rank
on graphs and tropical matrix rank of Laplacian principal minors.
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

/-- The combinatorial graph Laplacian matrix. -/
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

/-! ### IsTree predicate -/

/-- A simple graph is a tree if it is connected and has `|V| - 1` edges. -/
def IsTree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Prop :=
  G.Connected ∧ G.edgeFinset.card + 1 = Fintype.card V