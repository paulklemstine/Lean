/-
# Impossible Figures: Height Cocycles and Monodromy — Definitions

This module establishes the mathematical foundations of impossible figures
(Penrose triangles, Escher staircases) through height cocycles on cycle graphs.

The central insight: an "impossible figure" corresponds to a 1-cocycle on a graph
that fails to be a coboundary. The obstruction is measured by the monodromy —
the total height discrepancy accumulated around a cycle.
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Successor on Fin n with wraparound -/

/-- The cyclic successor of `i` in `Fin n`: maps `i ↦ (i+1) mod n`. -/
def Fin.cycSucc {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩

/-! ## Cycle Graph Cocycles

A cocycle on the cycle graph Cₙ assigns a real-valued "height difference" to each
edge. Edge i connects vertex i to vertex (i+1) mod n. -/

/-- A height cocycle on the cycle graph Cₙ (n ≥ 1) is a function assigning
    a real-valued height difference to each of the n edges.
    Edge `i` connects vertex `i` to vertex `(i+1) mod n`. -/
structure CycleCocycle (n : ℕ) (hn : 0 < n) where
  /-- The height difference assigned to each edge -/
  edgeWeight : Fin n → ℝ

instance {n : ℕ} {hn : 0 < n} : Add (CycleCocycle n hn) where
  add ω₁ ω₂ := ⟨fun i => ω₁.edgeWeight i + ω₂.edgeWeight i⟩

instance {n : ℕ} {hn : 0 < n} : Zero (CycleCocycle n hn) where
  zero := ⟨fun _ => 0⟩

instance {n : ℕ} {hn : 0 < n} : Neg (CycleCocycle n hn) where
  neg ω := ⟨fun i => -(ω.edgeWeight i)⟩

instance {n : ℕ} {hn : 0 < n} : SMul ℝ (CycleCocycle n hn) where
  smul c ω := ⟨fun i => c * ω.edgeWeight i⟩

/-- The monodromy of a cocycle is the sum of all edge weights around the cycle.
    This measures the total height discrepancy — the obstruction to realizability.
    When monodromy = 0, the figure is realizable; when ≠ 0, it is impossible. -/
def CycleCocycle.monodromy {n : ℕ} {hn : 0 < n} (ω : CycleCocycle n hn) : ℝ :=
  ∑ i : Fin n, ω.edgeWeight i

/-- A cocycle is a coboundary if there exists a height function `h : Fin n → ℝ`
    such that each edge weight equals the height difference `h(succ i) - h(i)`.
    Coboundaries correspond to *realizable* figures — ones that can be
    consistently embedded in 3D space. -/
def CycleCocycle.IsCoboundary {n : ℕ} {hn : 0 < n} (ω : CycleCocycle n hn) : Prop :=
  ∃ h : Fin n → ℝ, ∀ i : Fin n, ω.edgeWeight i = h (Fin.cycSucc hn i) - h i

/-- The impossibility index of a figure is the absolute value of its monodromy.
    Zero iff the figure is realizable. -/
def CycleCocycle.impossibilityIndex {n : ℕ} {hn : 0 < n} (ω : CycleCocycle n hn) : ℝ :=
  |ω.monodromy|

/-! ## Impossible Figure Structure -/

/-- An impossible figure: a cycle cocycle with nonzero monodromy. -/
structure ImpossibleFigure where
  /-- Number of edges in the cycle (must be ≥ 1) -/
  numEdges : ℕ
  numEdges_pos : 0 < numEdges
  /-- The height cocycle -/
  cocycle : CycleCocycle numEdges numEdges_pos
  /-- The figure is genuinely impossible -/
  impossible : cocycle.monodromy ≠ 0

/-! ## Orientation Cocycles

Orientation cocycles assign ±1 to each edge, modeling local orientation choices.
The orientation monodromy (product around the cycle) detects non-orientability:
+1 for orientable (cylinder), -1 for non-orientable (Möbius strip). -/

/-- An orientation cocycle assigns ±1 to each edge of the cycle graph. -/
structure OrientationCocycle (n : ℕ) (hn : 0 < n) where
  /-- Each edge gets orientation +1 or -1 -/
  orientation : Fin n → ℝ
  /-- Values are restricted to ±1 -/
  values_pm_one : ∀ i, orientation i = 1 ∨ orientation i = -1

/-- The orientation monodromy: product of orientations around the cycle.
    Equals +1 for orientable configurations, -1 for non-orientable (Möbius). -/
def OrientationCocycle.monodromy {n : ℕ} {hn : 0 < n} (σ : OrientationCocycle n hn) : ℝ :=
  ∏ i : Fin n, σ.orientation i

/-- A configuration is non-orientable when its orientation monodromy is -1. -/
def OrientationCocycle.isNonOrientable {n : ℕ} {hn : 0 < n} (σ : OrientationCocycle n hn) : Prop :=
  σ.monodromy = -1

/-! ## Graph Cocycles (General) -/

/-- A graph cocycle on a finite vertex set assigns antisymmetric real weights
    to directed edges. This generalizes cycle cocycles to arbitrary graphs. -/
structure GraphCocycle (V : Type*) [Fintype V] where
  /-- Edge weight function -/
  weight : V → V → ℝ
  /-- Antisymmetry: ω(u,v) = -ω(v,u) -/
  antisymm : ∀ u v, weight u v = -weight v u

/-- A graph cocycle is a coboundary if it comes from vertex potentials. -/
def GraphCocycle.IsCoboundary {V : Type*} [Fintype V] (ω : GraphCocycle V) : Prop :=
  ∃ f : V → ℝ, ∀ u v, ω.weight u v = f v - f u

/-! ## Cohomological Defect Space

The first cohomology H¹ of the cycle graph Cₙ is one-dimensional.
The monodromy map provides a canonical isomorphism H¹(Cₙ; ℝ) ≅ ℝ. -/

/-- Two cocycles are cohomologous if their difference is a coboundary. -/
def CycleCocycle.Cohomologous {n : ℕ} {hn : 0 < n}
    (ω₁ ω₂ : CycleCocycle n hn) : Prop :=
  (ω₁ + (-ω₂)).IsCoboundary

end