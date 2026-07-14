/-
Copyright (c) 2025. All rights reserved.

# Tree Metric Reconstruction: Definitions

Core definitions for the tree-metric reconstruction development: finite metrics
on a finite point set, the four-point/pendant-length quantities, and
leaf-labelled binary trees (`LBTree`) carrying real edge weights together with
their induced leaf-to-leaf distance.

## Main definitions

* `IsFiniteMetric D` - the metric axioms (zero diagonal, non-negativity,
  symmetry, triangle inequality) for a square real matrix.
* `pendantLength D i j k` - the Gromov product `(D i j + D i k - D j k) / 2`.
* `LBTree` - leaf-labelled binary trees with real edge weights, with
  `numLeaves`, `numVerts`, `labels`, `rootDist`, `dist`, and the structural
  predicates `NonnegWeights`, `DistinctLabels`, `WellFormed`.

## References

* Buneman, P. (1971). The recovery of trees from measures of dissimilarity.
-/

import Mathlib

open scoped Matrix

noncomputable section

variable {n : ℕ}

/-- A finite metric on the index set `Fin n`, presented as a square real matrix
satisfying the metric axioms: zero diagonal, non-negativity, symmetry and the
triangle inequality. -/
def IsFiniteMetric (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, D i i = 0) ∧
    (∀ i j, 0 ≤ D i j) ∧
      (∀ i j, D i j = D j i) ∧
        (∀ i j k, D i k ≤ D i j + D j k)

/-- The pendant length (Gromov product) at `i` with respect to `j` and `k`:
`(D i j + D i k - D j k) / 2`. -/
def pendantLength (D : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) : ℝ :=
  (D i j + D i k - D j k) / 2

/-- Leaf-labelled binary trees with real edge weights.  A `leaf i` carries the
natural-number label `i`; a `branch wL L wR R` joins subtrees `L` and `R` through
edges of weights `wL` and `wR`. -/
inductive LBTree where
  | leaf (i : ℕ) : LBTree
  | branch (wL : ℝ) (L : LBTree) (wR : ℝ) (R : LBTree) : LBTree

namespace LBTree

/-- Number of leaves of a tree. -/
def numLeaves : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numLeaves + R.numLeaves

/-- Number of vertices of a tree (internal nodes plus leaves). -/
def numVerts : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numVerts + R.numVerts + 1

/-- The set of leaf labels occurring in a tree. -/
def labels : LBTree → Finset ℕ
  | leaf i => {i}
  | branch _ L _ R => L.labels ∪ R.labels

/-- Distance from the root of the tree to the leaf labelled `j` (following the
path through the subtree containing `j`).  Labels not present in the tree are
assigned distance `0`. -/
def rootDist : LBTree → ℕ → ℝ
  | leaf i, j => if j = i then 0 else 0
  | branch wL L wR R, j =>
      if j ∈ L.labels then L.rootDist j + wL
      else if j ∈ R.labels then R.rootDist j + wR
      else 0

/-- All edge weights of the tree are non-negative. -/
def NonnegWeights : LBTree → Prop
  | leaf _ => True
  | branch wL L wR R => 0 ≤ wL ∧ 0 ≤ wR ∧ L.NonnegWeights ∧ R.NonnegWeights

/-- The two subtrees of every branch have disjoint label sets (so each label
occurs at a unique leaf). -/
def DistinctLabels : LBTree → Prop
  | leaf _ => True
  | branch _ L _ R => Disjoint L.labels R.labels ∧ L.DistinctLabels ∧ R.DistinctLabels

/-- A tree is well-formed if its labels are distinct and its weights are
non-negative. -/
def WellFormed (t : LBTree) : Prop := t.DistinctLabels ∧ t.NonnegWeights

/-- The tree distance between the leaves labelled `i` and `j`. -/
def dist : LBTree → ℕ → ℕ → ℝ
  | leaf _, _, _ => 0
  | branch wL L wR R, i, j =>
      if i ∈ L.labels ∧ j ∈ L.labels then L.dist i j
      else if i ∈ R.labels ∧ j ∈ R.labels then R.dist i j
      else if i ∈ L.labels ∧ j ∈ R.labels then L.rootDist i + wL + wR + R.rootDist j
      else if i ∈ R.labels ∧ j ∈ L.labels then R.rootDist i + wR + wL + L.rootDist j
      else 0

end LBTree

end