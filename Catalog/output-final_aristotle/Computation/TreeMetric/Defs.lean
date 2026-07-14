/-
Copyright (c) 2025. All rights reserved.

# Tree Metric Reconstruction: Definitions

Core definitions for the study of finite metrics and their realization by
leaf-labelled weighted trees: the notion of a finite metric on a finite index
set, the pendant length attached to a triple of points, and the recursive family
of leaf-labelled binary trees (`LBTree`) together with their combinatorial and
metric invariants.

## Main definitions

* `IsFiniteMetric` - the metric axioms (zero diagonal, nonnegativity, symmetry,
  triangle inequality) on a square real matrix.
* `pendantLength` - the Gromov product style pendant length of a triple.
* `LBTree` - leaf-labelled binary trees with real edge weights.
* `LBTree.numLeaves`, `LBTree.numVerts`, `LBTree.labels` - combinatorial data.
* `LBTree.rootDist`, `LBTree.dist` - the root distance and induced leaf metric.
* `LBTree.NonnegWeights`, `LBTree.DistinctLabels`, `LBTree.WellFormed` -
  structural regularity predicates.

## References

* Buneman, P. (1971). The recovery of trees from measures of dissimilarity.
-/

import Mathlib

open scoped Matrix
open Classical

noncomputable section

variable {n : ℕ}

/-- A **finite metric** on the index set `Fin n`, presented as a square real
matrix `D`.  It satisfies the four metric axioms: zero diagonal, nonnegativity,
symmetry, and the triangle inequality. -/
def IsFiniteMetric (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, D i i = 0) ∧ (∀ i j, 0 ≤ D i j) ∧ (∀ i j, D i j = D j i) ∧
    (∀ i j k, D i k ≤ D i j + D j k)

/-- The **pendant length** of point `i` relative to the pair `j, k`:
`(D i j + D i k - D j k) / 2`.  For a tree metric this is the length of the path
from leaf `i` to the median of `i, j, k`. -/
def pendantLength (D : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) : ℝ :=
  (D i j + D i k - D j k) / 2

/-- **Leaf-labelled binary trees** with real edge weights.  A tree is either a
`leaf` carrying a natural-number label, or a `branch` joining a left subtree `L`
(via an edge of weight `wL`) and a right subtree `R` (via an edge of weight
`wR`). -/
inductive LBTree where
  | leaf (i : ℕ) : LBTree
  | branch (wL : ℝ) (L : LBTree) (wR : ℝ) (R : LBTree) : LBTree

namespace LBTree

/-- Number of leaves of a tree. -/
def numLeaves : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numLeaves + R.numLeaves

/-- Number of vertices (leaves and internal nodes) of a tree. -/
def numVerts : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numVerts + R.numVerts + 1

/-- The (finite) set of labels occurring at the leaves of a tree. -/
def labels : LBTree → Finset ℕ
  | leaf i => {i}
  | branch _ L _ R => L.labels ∪ R.labels

/-- Distance from the root of the tree to the leaf labelled `i`.  If `i` does not
occur in the tree the value is `0`. -/
def rootDist : LBTree → ℕ → ℝ
  | leaf k, i => if i = k then 0 else 0
  | branch wL L wR R, i =>
      if i ∈ L.labels then L.rootDist i + wL
      else if i ∈ R.labels then R.rootDist i + wR else 0

/-- The tree metric induced on leaf labels: the length of the unique path between
the leaves labelled `i` and `j`. -/
def dist : LBTree → ℕ → ℕ → ℝ
  | leaf _, _, _ => 0
  | branch wL L wR R, i, j =>
      if i ∈ L.labels ∧ j ∈ L.labels then L.dist i j
      else if i ∈ R.labels ∧ j ∈ R.labels then R.dist i j
      else if i ∈ L.labels ∧ j ∈ R.labels then L.rootDist i + wL + wR + R.rootDist j
      else if i ∈ R.labels ∧ j ∈ L.labels then R.rootDist i + wR + wL + L.rootDist j
      else 0

/-- A tree has **nonnegative weights** if every edge weight is `≥ 0`. -/
def NonnegWeights : LBTree → Prop
  | leaf _ => True
  | branch wL L wR R => 0 ≤ wL ∧ 0 ≤ wR ∧ L.NonnegWeights ∧ R.NonnegWeights

/-- A tree has **distinct labels** if the label sets of the two subtrees of every
branch are disjoint (so every label occurs at most once). -/
def DistinctLabels : LBTree → Prop
  | leaf _ => True
  | branch _ L _ R => Disjoint L.labels R.labels ∧ L.DistinctLabels ∧ R.DistinctLabels

/-- A tree is **well-formed** if it has distinct labels and nonnegative weights. -/
def WellFormed (t : LBTree) : Prop := t.DistinctLabels ∧ t.NonnegWeights

end LBTree

end