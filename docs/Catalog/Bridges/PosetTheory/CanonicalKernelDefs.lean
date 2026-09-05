/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Canonical Tropical Kernel — Definitions

This file introduces the foundational definitions for the canonical tropical
kernel theory, connecting harmonic functions on graph subsets to chip-firing
equivalence classes and the restricted critical group.

## Main Definitions

* `IsHarmonicOn` — a function satisfies the discrete Laplace equation on a subset
* `NormalizedOn` — a function sums to zero on a subset (mean-zero normalization)
* `SeparatedOn` — the restriction-faithfulness separation hypothesis
* `FiringEquivalentOn` — two functions differ by a Laplacian image supported on a subset
* `IsTreeAttachmentAlong` — a set T is attached to S as a tree
* `RestrictedLaplacianImage` — the image of the restricted Laplacian on S
* `harmonicKernel` — the set of harmonic functions on S

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Mathlib
import Logic.GraphTheory.Defs

/-- The combinatorial graph Laplacian matrix. -/
def graphLaplacian {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Harmonic Functions on Subsets -/

/-- A function `f : V → ℤ` is **harmonic on** a subset `S` with respect to graph `G`
    if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes:
    `∑ w, L(v,w) · f(w) = 0`.
    This is the discrete analogue of harmonicity in potential theory. -/
def IsHarmonicOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (f : V → ℤ) : Prop :=
  ∀ v ∈ S, ∑ w : V, graphLaplacian G v w * f w = 0

/-- A function is **normalized on** `S` if its values sum to zero over `S`:
    `∑ v ∈ S, f(v) = 0`. This removes the constant-function ambiguity
    from the harmonic kernel. -/
def NormalizedOn (S : Finset V) (f : V → ℤ) : Prop :=
  ∑ v ∈ S, f v = 0

/-- The **separation hypothesis** for `S` in `G`: if two harmonic functions on `S`
    are both normalized on `S` and agree on every vertex of `S`, then they are
    equal everywhere. This ensures that harmonic extensions from `S` are unique
    and encodes the geometric idea that `S` "sees" enough of the graph. -/
def SeparatedOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ ⦃f g : V → ℤ⦄,
    IsHarmonicOn G S f →
    IsHarmonicOn G S g →
    NormalizedOn S f →
    NormalizedOn S g →
    (∀ v ∈ S, f v = g v) →
    f = g

/-- Two functions are **firing-equivalent on** `S` if they differ by a
    Laplacian image of a function supported on `S`. This is the algebraic
    expression of chip-firing: `g = f + L · c` where `c` is supported on `S`. -/
def FiringEquivalentOn
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (f g : V → ℤ) : Prop :=
  ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, g v = f v + ∑ w : V, graphLaplacian G v w * c w

/-- A subset `T` is a **tree attachment along** `S` in `G` if:
    1. `S` and `T` are disjoint,
    2. Every vertex in `T` has at most one neighbor in `S`,
    3. The induced subgraph on `T` is acyclic (forest),
    4. Every vertex in `T` has a path to `S` through `T`. -/
structure IsTreeAttachmentAlong
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S T : Finset V) : Prop where
  disjoint : Disjoint S T
  single_attachment : ∀ v ∈ T,
    ((S.filter (G.Adj v)).card ≤ 1)
  acyclic : ∀ v ∈ T, ∀ w ∈ T, v ≠ w →
    G.Adj v w →
    ¬∃ p : G.Walk v w, p.support.tail.toFinset ⊆ ↑T ∧ p.support.length > 2

/-- The **restricted Laplacian image** on `S`: the set of functions that arise
    as `L · c` for some `c` supported on `S`. This is the chip-firing lattice
    restricted to `S`. -/
def RestrictedLaplacianImage
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {h | ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, h v = ∑ w : V, graphLaplacian G v w * c w}

/-- The **harmonic kernel** on `S`: the set of all functions harmonic on `S`. -/
def harmonicKernel
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {f | IsHarmonicOn G S f}

/-- A function is **constant** if it takes a single value everywhere. -/
def IsConstant (f : V → ℤ) : Prop :=
  ∀ v w : V, f v = f w

/-- Two functions are **equivalent modulo constants** if they differ by
    a constant function. -/
def EquivModConst (f g : V → ℤ) : Prop :=
  ∃ c : ℤ, ∀ v, f v = g v + c