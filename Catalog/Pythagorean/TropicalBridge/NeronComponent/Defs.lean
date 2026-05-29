/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Néron Component Groups via Tropical Jacobians — Definitions

This file introduces the foundational definitions for computing Néron component
groups of Jacobians of semistable curves through graph-theoretic invariants of
the weighted dual graph.

## Main Definitions

* `SemistableDualGraphData` — weighted graph Laplacian data for a semistable dual graph
* `reducedLaplacian` — the reduced Laplacian matrix obtained by deleting one row and column
* `laplacianImageSubmodule` — the image of the Laplacian as a submodule of ℤ^n
* `reducedLaplacianCokernel` — the cokernel ℤ^(V-1)/im(L_red), the tropical Jacobian
* `weightedSpanningTreeCount` — number of spanning trees (Kirchhoff's theorem value)
* `SpecializationComponentBridge` — arithmetic comparison interface

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Raynaud, M. "Spécialisation du foncteur de Picard" (1970)
-/

import Mathlib

open Finset BigOperators Matrix

/-! ## Semistable Dual Graph Data -/

/-- Data of a weighted graph Laplacian encoding the combinatorics of a semistable
    dual graph. The Laplacian `L` is symmetric with zero row sums and nonpositive
    off-diagonal entries; these are the defining properties of a graph Laplacian
    over ℤ. -/
structure SemistableDualGraphData where
  /-- The vertex type of the dual graph -/
  V : Type
  /-- The vertex type is finite -/
  [fintype_V : Fintype V]
  /-- The vertex type has decidable equality -/
  [decEq_V : DecidableEq V]
  /-- The weighted graph Laplacian matrix -/
  laplacian : Matrix V V ℤ
  /-- The graph is connected (stated as a property) -/
  connected : Prop
  /-- The Laplacian is symmetric -/
  symmetric : laplacianᵀ = laplacian
  /-- Each row of the Laplacian sums to zero -/
  rowSumZero : ∀ v, ∑ w, laplacian v w = 0
  /-- Off-diagonal entries are nonpositive (encoding nonneg edge weights) -/
  offDiag_nonpos : ∀ v w, v ≠ w → laplacian v w ≤ 0

attribute [instance] SemistableDualGraphData.fintype_V SemistableDualGraphData.decEq_V

/-! ## Reduced Laplacian -/

/-- The **reduced Laplacian** of a matrix `L` with respect to a distinguished vertex `v0`.
    This is the submatrix obtained by deleting the row and column of `v0`.
    When `L` is the Laplacian of a connected graph, the reduced Laplacian is nonsingular
    and its determinant equals the number of spanning trees (Kirchhoff's matrix-tree theorem). -/
noncomputable def reducedLaplacian {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) : Matrix {v : V // v ≠ v0} {v : V // v ≠ v0} ℤ :=
  L.submatrix Subtype.val Subtype.val

/-! ## Laplacian Image Submodule -/

/-- The image of the reduced Laplacian as a submodule of ℤ^(V\{v0}).
    The quotient by this submodule is the tropical Jacobian / critical group. -/
noncomputable def laplacianImageSubmodule {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) : Submodule ℤ ({v : V // v ≠ v0} → ℤ) :=
  LinearMap.range (Matrix.mulVecLin (reducedLaplacian L v0))

/-! ## Reduced Laplacian Cokernel (Tropical Jacobian) -/

/-- The **reduced Laplacian cokernel** — the tropical Jacobian / critical group / graph Jacobian.
    For a connected graph with Laplacian `L`, deleting the row and column of vertex `v0`
    gives the reduced Laplacian `L_red`, and the cokernel
    `ℤ^(V\{v0}) / im(L_red)`
    is a finite abelian group whose order equals `|det(L_red)|` and whose invariant factors
    are the Smith normal form diagonal entries of `L_red`.

    This is the combinatorial model for the Néron component group `Φ_J` of the Jacobian
    of a semistable curve with dual graph having Laplacian `L`. -/
noncomputable def reducedLaplacianCokernel {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) :=
  ({v : V // v ≠ v0} → ℤ) ⧸ (laplacianImageSubmodule L v0).toAddSubgroup

noncomputable instance reducedLaplacianCokernel.instAddCommGroup
    {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) : AddCommGroup (reducedLaplacianCokernel L v0) :=
  QuotientAddGroup.Quotient.addCommGroup _

/-! ## Weighted Spanning Tree Count -/

/-- The **weighted spanning tree count** of a graph with Laplacian `L`, defined as
    `|det(L_red)|` for a chosen vertex `v0`. By the matrix-tree theorem, this equals
    the number of spanning trees when edge weights are all 1. -/
noncomputable def weightedSpanningTreeCount'
    {V : Type} [Fintype V] [DecidableEq V] [Nonempty V]
    (L : Matrix V V ℤ) : ℕ :=
  let v0 : V := Classical.arbitrary V
  (Matrix.det (reducedLaplacian L v0)).natAbs

/-! ## Arithmetic Interface -/

/-- The **specialization component bridge** axiomatizes the arithmetic comparison
    between the Néron component group `Φ_J` and the tropical Jacobian.
    This structure encapsulates the deep theorem (due to Raynaud) that for
    a semistable curve, the component group is isomorphic to the cokernel
    of the reduced Laplacian of the dual graph. -/
structure SpecializationComponentBridge (G : SemistableDualGraphData)
    (v0 : G.V) where
  /-- The Néron component group -/
  Phi : Type
  /-- The component group is an additive commutative group -/
  [phiAddCommGroup : AddCommGroup Phi]
  /-- The specialization homomorphism to the tropical Jacobian -/
  toTrop : Phi →+ reducedLaplacianCokernel G.laplacian v0
  /-- The specialization map is surjective -/
  surjective_toTrop : Function.Surjective toTrop
  /-- The specialization map is injective -/
  injective_toTrop : Function.Injective toTrop

attribute [instance] SpecializationComponentBridge.phiAddCommGroup

/-! ## Basic Laplacian properties -/

/-
In a `SemistableDualGraphData`, diagonal entries of the Laplacian are nonneg.
    This follows from the row-sum-zero property and nonpositivity of off-diagonal entries.
-/
lemma SemistableDualGraphData.diag_nonneg (G : SemistableDualGraphData)
    (v : G.V) : 0 ≤ G.laplacian v v := by
  have := G.rowSumZero v;
  rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ v ) ] at this;
  linarith [ show ∑ x ∈ Finset.univ \ { v }, G.laplacian v x ≤ 0 by exact Finset.sum_nonpos fun x hx => G.offDiag_nonpos v x <| by aesop ]

/-
Reformulation: the diagonal entry equals the negation of the sum of off-diagonal entries.
-/
lemma SemistableDualGraphData.diag_eq_neg_sum_off_diag (G : SemistableDualGraphData)
    (v : G.V) : G.laplacian v v = -∑ w ∈ Finset.univ.filter (· ≠ v), G.laplacian v w := by
  simp +decide [ ← eq_sub_iff_add_eq', Finset.filter_ne', G.rowSumZero ]