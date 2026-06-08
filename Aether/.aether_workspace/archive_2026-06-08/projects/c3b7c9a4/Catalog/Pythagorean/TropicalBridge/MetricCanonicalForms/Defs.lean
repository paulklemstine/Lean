/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Metric Canonical Forms — Definitions

This file introduces the foundational structures for canonical kernel theory
on metric graph models: weighted graph models with positive edge lengths,
vertex divisors, principality, S-supported Jacobians, Dirichlet energy,
and harmonic normalization.

## Main Definitions

* `MetricGraphModel` — a finite simple graph with positive symmetric edge weights
* `conductance` — the conductance weight `1/ℓ(e)` from edge lengths
* `mLaplacian` — the weighted Laplacian using conductance weights
* `mLapply` — real-valued Laplacian applied to vertex potentials
* `IsMHarmonicOn` — harmonicity with respect to the metric Laplacian
* `dirichletEnergy` — the Dirichlet energy functional for vertex potentials
* `isMeanZero` — mean-zero normalization predicate
* `IsLeaf` / `IsPendantEdge` — leaf and pendant edge predicates
* `IsSSupported` / `IsSPrincipal` — S-supported divisor theory

## References

* Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and
  electrical networks" (2006)
-/

import Mathlib

open Finset BigOperators

/-! ### Metric Graph Model -/

/-- A **metric graph model** consists of a finite simple graph together with
    positive symmetric edge lengths. The conductance weights `1/ℓ(e)` define
    the metric Laplacian. -/
structure MetricGraphModel where
  /-- The vertex type -/
  V : Type
  /-- Finite vertex set -/
  [instFintype : Fintype V]
  /-- Decidable equality on vertices -/
  [instDecEq : DecidableEq V]
  /-- The underlying simple graph -/
  G : SimpleGraph V
  /-- Decidable adjacency -/
  [instDecAdj : DecidableRel G.Adj]
  /-- Edge length function (positive, symmetric) -/
  edgeLength : V → V → ℝ
  /-- Edge lengths are positive on adjacent pairs -/
  length_pos : ∀ i j, G.Adj i j → 0 < edgeLength i j
  /-- Edge lengths are symmetric -/
  length_symm : ∀ i j, edgeLength i j = edgeLength j i

attribute [instance] MetricGraphModel.instFintype MetricGraphModel.instDecEq
  MetricGraphModel.instDecAdj

namespace MetricGraphModel

variable (M : MetricGraphModel)

/-! ### Conductance and Laplacian -/

/-- The **conductance** of an edge is the reciprocal of its length. -/
noncomputable def conductance (i j : M.V) : ℝ := 1 / M.edgeLength i j

theorem conductance_pos (i j : M.V) (hadj : M.G.Adj i j) :
    0 < M.conductance i j :=
  div_pos one_pos (M.length_pos i j hadj)

theorem conductance_symm (i j : M.V) :
    M.conductance i j = M.conductance j i := by
  simp [conductance, M.length_symm]

/-- The **metric Laplacian** matrix using conductance weights. -/
noncomputable def mLaplacian : Matrix M.V M.V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (M.G.Adj i), M.conductance i k
    else if M.G.Adj i j then -(M.conductance i j)
    else 0

/-- Apply the metric Laplacian to a vertex potential function. -/
noncomputable def mLapply (f : M.V → ℝ) (v : M.V) : ℝ :=
  ∑ j : M.V, M.mLaplacian v j * f j

/-- A function `f` is **metric-harmonically zero** on set `S` if the
    Laplacian vanishes at every vertex in `S`. -/
def IsMHarmonicOn (S : Finset M.V) (f : M.V → ℝ) : Prop :=
  ∀ v ∈ S, M.mLapply f v = 0

/-! ### Dirichlet Energy -/

/-- The **Dirichlet energy** of a vertex potential, defined as `f^T L f`. -/
noncomputable def dirichletEnergy (f : M.V → ℝ) : ℝ :=
  ∑ i : M.V, ∑ j : M.V, M.mLaplacian i j * f i * f j

/-! ### Normalization -/

/-- A vertex function has **mean zero**: `∑ f(v) = 0`. -/
def isMeanZero (f : M.V → ℝ) : Prop :=
  ∑ v : M.V, f v = 0

/-! ### Leaf and Pendant Predicates -/

/-- A vertex `v` is a **leaf** if it has degree 1. -/
def IsLeaf (v : M.V) : Prop := M.G.degree v = 1

/-- An edge `(v, w)` is a **pendant edge** if `w` is a leaf. -/
def IsPendantEdge (v w : M.V) : Prop := M.G.Adj v w ∧ M.IsLeaf w

/-! ### S-Supported Divisor Theory -/

/-- An `S`-supported function vanishes outside `S`. -/
def IsSSupported (S : Finset M.V) (D : M.V → ℝ) : Prop :=
  ∀ v, v ∉ S → D v = 0

/-- An `S`-principal divisor comes from the Laplacian of some potential. -/
def IsSPrincipal (S : Finset M.V) (D : M.V → ℝ) : Prop :=
  ∃ f : M.V → ℝ, (∀ v, v ∉ S → M.mLapply f v = 0) ∧ ∀ v, M.mLapply f v = D v

/-- A real-valued divisor is **(metrically) principal** if it is in the image
    of the Laplacian. -/
def IsRPrincipal (D : M.V → ℝ) : Prop :=
  ∃ f : M.V → ℝ, ∀ v, M.mLapply f v = D v

end MetricGraphModel