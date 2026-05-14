/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Circuit Lower Bounds: Definitions

## Overview

This file establishes the foundational definitions for a bridge between
tropical (min-plus) matrix invariants and circuit depth lower bounds.

The key model: a **layered circuit matrix** is a finite matrix M over ℕ where
nonzero entries encode weighted directed edges in a DAG. The layered condition
forces all edges to go from smaller to larger indices, making the support graph
acyclic and enabling clean inductive reasoning about paths and depth.

## Definitions

* `IsLayered M` — nonzero entries respect index ordering (i < j)
* `IsPath M p` — consecutive elements of list `p` are connected by edges
* `pathCost M p` — sum of edge weights along path `p`
* `permCost M σ` — assignment cost of permutation σ: Σᵢ M(i, σ(i))
* `minPlusPerm M` — min-plus permanent: minimum assignment cost over all permutations

## Why "Tropical Spectral"

The min-plus permanent and path costs are tropical-algebraic invariants of M.
In the min-plus semiring (ℕ, min, +), the permanent generalizes the classical
permanent to an optimization problem (minimum weight perfect matching).
Path costs generalize tropical eigenvalues (cycle means) to acyclic settings.
Together they form a **spectral semantics of circuits**: structural invariants
that constrain computational depth.

## Keywords

circuit lower bounds, tropical spectral theory, min-plus permanent,
idempotent linear algebra, layered DAG semantics, depth lower bounds
-/

import Mathlib

namespace TropicalCircuit

/-! ## Core Definitions -/

/-- A matrix is **layered** if every nonzero entry goes from a smaller index to
a larger index. This makes the support graph a DAG compatible with the index ordering. -/
def IsLayered {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : Prop :=
  ∀ i j : Fin n, 0 < M i j → i < j

/-- A path in the support graph of M: consecutive entries are connected by edges. -/
def IsPath {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : List (Fin n) → Prop
  | [] => True
  | [_] => True
  | a :: b :: rest => 0 < M a b ∧ IsPath M (b :: rest)

/-- Cost of a path: sum of edge weights along the path. -/
def pathCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : List (Fin n) → ℕ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => M a b + pathCost M (b :: rest)

/-- Assignment cost of a permutation σ: total cost of the assignment i ↦ σ(i). -/
def permCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) (σ : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i, M i (σ i)

/-- The **min-plus permanent**: minimum assignment cost over all permutations.
This is the tropical analogue of the matrix permanent, computed in the min-plus
semiring (ℕ, min, +). -/
noncomputable def minPlusPerm {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  Finset.inf' (Finset.univ : Finset (Equiv.Perm (Fin n)))
    (⟨1, Finset.mem_univ _⟩)
    (permCost M)

/-- Number of edges in a path (one less than the number of vertices). -/
def pathEdges {α : Type*} : List α → ℕ
  | [] => 0
  | [_] => 0
  | _ :: b :: rest => 1 + pathEdges (b :: rest)

end TropicalCircuit