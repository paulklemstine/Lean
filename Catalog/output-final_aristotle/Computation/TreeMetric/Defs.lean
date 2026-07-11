/-
Copyright (c) 2025. All rights reserved.

# Tree Metric Reconstruction: Core Definitions

Finite metrics, the pendant-length (Gromov-product) functional, and the
leaf-labelled binary tree model `LBTree` together with its induced path metric.

## References

* Buneman, P. (1971). The recovery of trees from measures of dissimilarity.
-/

import Mathlib

open scoped Matrix
open Classical

noncomputable section

/-- A finite metric on `Fin n`: zero diagonal, nonnegativity, symmetry, and the
triangle inequality. -/
def IsFiniteMetric {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, D i i = 0) ∧
  (∀ i j, 0 ≤ D i j) ∧
  (∀ i j, D i j = D j i) ∧
  (∀ i j k, D i k ≤ D i j + D j k)

/-- The *pendant length* at `i` relative to `j, k`: the Gromov-product-style
quantity `(D i j + D i k - D j k) / 2`. -/
def pendantLength {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) : ℝ :=
  (D i j + D i k - D j k) / 2

/-- A leaf-labelled binary tree with real edge weights: either a leaf carrying a
natural-number label, or an internal node with a left subtree at distance `wL`
and a right subtree at distance `wR`. -/
inductive LBTree where
  | leaf (i : ℕ) : LBTree
  | branch (wL : ℝ) (L : LBTree) (wR : ℝ) (R : LBTree) : LBTree

namespace LBTree

/-- Number of leaves. -/
def numLeaves : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numLeaves + R.numLeaves

/-- Total number of vertices (leaves plus internal nodes). -/
def numVerts : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numVerts + R.numVerts + 1

/-- The finite set of leaf labels occurring in the tree. -/
def labels : LBTree → Finset ℕ
  | leaf i => {i}
  | branch _ L _ R => L.labels ∪ R.labels

/-- Distance from the root to the leaf labelled `i` (or `0` if absent). -/
def rootDist : LBTree → ℕ → ℝ
  | leaf j, i => if i = j then 0 else 0
  | branch wL L wR R, i =>
      if i ∈ L.labels then L.rootDist i + wL
      else if i ∈ R.labels then R.rootDist i + wR
      else 0

/-- The induced path distance between the leaves labelled `i` and `j`. -/
def dist : LBTree → ℕ → ℕ → ℝ
  | leaf _, _, _ => 0
  | branch wL L wR R, i, j =>
      if i ∈ L.labels ∧ j ∈ L.labels then L.dist i j
      else if i ∈ R.labels ∧ j ∈ R.labels then R.dist i j
      else if i ∈ L.labels ∧ j ∈ R.labels then L.rootDist i + wL + wR + R.rootDist j
      else if i ∈ R.labels ∧ j ∈ L.labels then R.rootDist i + wR + wL + L.rootDist j
      else 0

/-- All edge weights are nonnegative. -/
def NonnegWeights : LBTree → Prop
  | leaf _ => True
  | branch wL L wR R => 0 ≤ wL ∧ 0 ≤ wR ∧ L.NonnegWeights ∧ R.NonnegWeights

/-- The leaf labels of the two subtrees are disjoint at every internal node. -/
def DistinctLabels : LBTree → Prop
  | leaf _ => True
  | branch _ L _ R => Disjoint L.labels R.labels ∧ L.DistinctLabels ∧ R.DistinctLabels

/-- A tree is *well formed* when its labels are distinct and its weights
nonnegative. -/
def WellFormed (t : LBTree) : Prop := t.DistinctLabels ∧ t.NonnegWeights

end LBTree

end