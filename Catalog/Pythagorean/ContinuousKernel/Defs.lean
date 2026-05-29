/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Continuous Canonical Kernel Calculus — Definitions

This file introduces the foundational definitions for the continuous canonical
kernel calculus on finite weighted graph models of metric graphs.

## Mathematical Context

A compact metric graph (tropical curve) is modeled by a finite graph with
positive edge lengths. The conductance-weighted Laplacian governs potential
theory. The **canonical kernel** is the unique symmetric Green function
normalized to have zero mean, connecting tropical geometry (Abel–Jacobi maps),
electrical network theory (effective resistance), and quantum graph spectral
theory (Laplacian pseudoinverse).

## Main Definitions

* `MetricGraph` — a finite simple graph with positive symmetric edge weights
* `MetricGraph.laplacian` — the weighted Laplacian matrix
* `MetricGraph.lapply` — Laplacian applied to a vertex potential
* `MetricGraph.energy` — Dirichlet energy quadratic form
* `MetricGraph.energyBilin` — polarization of the Dirichlet energy
* `MetricGraph.meanZero` — mean-zero normalization predicate
* `CanonicalKernel` — structure packaging a symmetric normalized Green kernel
* `CanonicalKernel.effectiveResistance` — effective resistance from kernel
* `CanonicalKernel.dipolePotential` — difference of kernel columns

## References

* Baker–Faber, "Metrized graphs, Laplacian operators, and electrical networks" (2006)
* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Mikhalkin–Zharkov, "Tropical curves, their Jacobians and theta functions" (2008)
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Metric Graph Model -/

/-- A **metric graph model**: a finite simple graph with positive symmetric
    edge weights (conductances). This models a compact metric graph where
    each edge has length `1/w(e)`. -/
structure MetricGraph where
  /-- The vertex type. -/
  V : Type
  /-- Finiteness of the vertex set. -/
  [instFintype : Fintype V]
  /-- Decidable equality on vertices. -/
  [instDecEq : DecidableEq V]
  /-- The underlying simple graph. -/
  G : SimpleGraph V
  /-- Decidable adjacency. -/
  [instDecAdj : DecidableRel G.Adj]
  /-- Edge weight (conductance) function. -/
  w : V → V → ℝ
  /-- Weights are positive on edges. -/
  w_pos : ∀ i j, G.Adj i j → 0 < w i j
  /-- Weights are symmetric. -/
  w_symm : ∀ i j, w i j = w j i

attribute [instance] MetricGraph.instFintype MetricGraph.instDecEq MetricGraph.instDecAdj

namespace MetricGraph

variable (Γ : MetricGraph)

/-! ### Laplacian -/

/-- The **weighted Laplacian matrix** of a metric graph.
    Diagonal entries are the sum of adjacent weights;
    off-diagonal entries are the negation of the weight (if adjacent) or zero. -/
noncomputable def laplacian : Matrix Γ.V Γ.V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (Γ.G.Adj i), Γ.w i k
    else if Γ.G.Adj i j then -(Γ.w i j)
    else 0

/-- Apply the Laplacian to a vertex potential function. -/
noncomputable def lapply (f : Γ.V → ℝ) (v : Γ.V) : ℝ :=
  ∑ j : Γ.V, Γ.laplacian v j * f j

/-! ### Energy -/

/-- The **Dirichlet energy** (quadratic form): `E(f) = f^T L f`. -/
noncomputable def energy (f : Γ.V → ℝ) : ℝ :=
  ∑ i : Γ.V, ∑ j : Γ.V, Γ.laplacian i j * f i * f j

/-- The **energy bilinear form** (polarization of Dirichlet energy). -/
noncomputable def energyBilin (f g : Γ.V → ℝ) : ℝ :=
  ∑ i : Γ.V, ∑ j : Γ.V, Γ.laplacian i j * f i * g j

/-! ### Normalization -/

/-- A function has **mean zero** over the vertices. -/
def meanZero (f : Γ.V → ℝ) : Prop := ∑ v : Γ.V, f v = 0

/-- The number of vertices, cast to ℝ. -/
noncomputable def nVertices : ℝ := (Fintype.card Γ.V : ℝ)

/-! ### Harmonicity -/

/-- A function is **harmonic** at every vertex. -/
def isHarmonic (f : Γ.V → ℝ) : Prop := ∀ v, Γ.lapply f v = 0

end MetricGraph

/-! ## Section 2: Canonical Kernel -/

/-- A **canonical kernel** on a metric graph: a function `g : V → V → ℝ`
    satisfying the Laplacian equation with Dirac-minus-uniform source and
    mean-zero normalization.

    This is the central new definition: it packages the unique normalized
    Green function that simultaneously encodes:
    - tropical potential theory (Laplacian equation),
    - effective resistance (diagonal polarization),
    - Abel–Jacobi coordinates (kernel column differences),
    - quantum graph resolvent (Laplacian pseudoinverse). -/
structure CanonicalKernel (Γ : MetricGraph) where
  /-- The kernel function `g(p, q)`. -/
  g : Γ.V → Γ.V → ℝ
  /-- **Laplacian equation**: for each source `p`, the column `g(p, ·)`
      satisfies `Δ g_p = δ_p - (1/n)·𝟏`. -/
  lap_col : ∀ (p v : Γ.V),
    Γ.lapply (g p) v = (if v = p then 1 else 0) - 1 / Γ.nVertices
  /-- **Mean-zero normalization**: each column sums to zero. -/
  mean_col : ∀ p, Γ.meanZero (g p)

namespace CanonicalKernel

variable {Γ : MetricGraph} (K : CanonicalKernel Γ)

/-- The **effective resistance** between two vertices, defined from the kernel. -/
noncomputable def effectiveResistance (p q : Γ.V) : ℝ :=
  K.g p p + K.g q q - 2 * K.g p q

/-- The **dipole potential** for the pair `(p, q)`: the difference of
    kernel columns, representing the voltage pattern of a unit current
    from `p` to `q`. -/
noncomputable def dipolePotential (p q : Γ.V) : Γ.V → ℝ :=
  fun x => K.g p x - K.g q x

end CanonicalKernel