/-
Copyright (c) 2025. All rights reserved.

# Tree Metric Reconstruction: Core Definitions

This file establishes the core definitions for the theory of additive (tree) metrics
and their reconstruction from boundary distance data.

## Main definitions

* `IsFiniteMetric` - predicate for a finite metric matrix
* `FourPointCondition` - the four-point condition characterizing tree metrics
* `LBTree` - labeled binary tree with real-valued edge weights
* `LBTree.dist` - distance between labeled leaves in a tree
* `LBTree.Realizes` - a tree realizes a given distance matrix

## References

* Buneman, P. "The recovery of trees from measures of dissimilarity" (1971)
* Semple, C. and Steel, M. "Phylogenetics" (2003)
-/

import Mathlib

open scoped Matrix
open Classical

/-! ### Finite metric predicates -/

/-- A matrix `D` on `Fin n` is a finite metric: zero diagonal, nonnegative, symmetric,
and satisfies the triangle inequality. -/
def IsFiniteMetric {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, D i i = 0) ∧
  (∀ i j, 0 ≤ D i j) ∧
  (∀ i j, D i j = D j i) ∧
  (∀ i j k, D i k ≤ D i j + D j k)

/-- The four-point condition: for every four indices, the largest two of the three
pairwise distance sums are equal. This characterizes tree metrics. -/
def FourPointCondition {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j k l : Fin n,
    let s1 := D i j + D k l
    let s2 := D i k + D j l
    let s3 := D i l + D j k
    ((s1 ≤ s2 ∧ s1 ≤ s3) → s2 = s3) ∧
    ((s2 ≤ s1 ∧ s2 ≤ s3) → s1 = s3) ∧
    ((s3 ≤ s1 ∧ s3 ≤ s2) → s1 = s2)

/-! ### Pendant edge length (Gromov product) -/

/-- The pendant edge length (half-Gromov-product) for boundary point `i`
relative to points `j` and `k`: `(D i j + D i k - D j k) / 2`.
In an additive metric, this is the length of the pendant edge at leaf `i`. -/
noncomputable def pendantLength {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) : ℝ :=
  (D i j + D i k - D j k) / 2

/-! ### Labeled Binary Tree -/

/-- A labeled binary tree with real-valued edge weights.
Leaves are labeled by natural numbers. Internal nodes connect two subtrees
via edges of specified nonneg weight.

`branch wL L wR R` represents an internal node with:
- left subtree `L` connected by an edge of weight `wL`
- right subtree `R` connected by an edge of weight `wR` -/
inductive LBTree where
  | leaf : ℕ → LBTree
  | branch : ℝ → LBTree → ℝ → LBTree → LBTree
  deriving Inhabited

namespace LBTree

/-- The set of leaf labels in a tree. -/
def labels : LBTree → Finset ℕ
  | leaf i => {i}
  | branch _ L _ R => L.labels ∪ R.labels

/-- The number of leaves in a tree. -/
def numLeaves : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => L.numLeaves + R.numLeaves

/-- The total number of vertices (leaves + internal nodes) in a tree. -/
def numVerts : LBTree → ℕ
  | leaf _ => 1
  | branch _ L _ R => 1 + L.numVerts + R.numVerts

/-- Whether a label appears in the tree. -/
def hasLabel (t : LBTree) (i : ℕ) : Prop := i ∈ t.labels

instance (t : LBTree) : DecidablePred t.hasLabel := fun i => Finset.decidableMem i t.labels

/-- Distance from a leaf to the root of the tree.
Returns 0 if the label is not present. -/
noncomputable def rootDist : LBTree → ℕ → ℝ
  | leaf j, i => if i = j then 0 else 0
  | branch wL L wR R, i =>
    if i ∈ L.labels then L.rootDist i + wL
    else if i ∈ R.labels then R.rootDist i + wR
    else 0

/-- Distance between two labeled leaves in the tree.
For labels `i` and `j`, this is the sum of edge weights along the
unique path from leaf `i` to leaf `j` in the tree.
Returns 0 if either label is not present. -/
noncomputable def dist : LBTree → ℕ → ℕ → ℝ
  | leaf _, _, _ => 0
  | branch wL L wR R, i, j =>
    if i ∈ L.labels ∧ j ∈ L.labels then L.dist i j
    else if i ∈ R.labels ∧ j ∈ R.labels then R.dist i j
    else if i ∈ L.labels ∧ j ∈ R.labels then
      L.rootDist i + wL + wR + R.rootDist j
    else if i ∈ R.labels ∧ j ∈ L.labels then
      R.rootDist i + wR + wL + L.rootDist j
    else 0

/-- A tree has distinct labels (no repeated leaf labels). -/
def DistinctLabels : LBTree → Prop
  | leaf _ => True
  | branch _ L _ R =>
    L.DistinctLabels ∧ R.DistinctLabels ∧ Disjoint L.labels R.labels

/-- All edge weights in the tree are nonnegative. -/
def NonnegWeights : LBTree → Prop
  | leaf _ => True
  | branch wL L wR R =>
    0 ≤ wL ∧ 0 ≤ wR ∧ L.NonnegWeights ∧ R.NonnegWeights

/-- A well-formed tree: distinct labels and nonneg weights. -/
def WellFormed (t : LBTree) : Prop :=
  t.DistinctLabels ∧ t.NonnegWeights

/-- A tree `t` realizes distance matrix `D` on `Fin n`:
all `Fin n` labels are present, labels are distinct, and tree distances match `D`. -/
def Realizes {n : ℕ} (t : LBTree) (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  t.WellFormed ∧
  (∀ i : Fin n, (i : ℕ) ∈ t.labels) ∧
  (∀ i j : Fin n, t.dist i j = D i j)

end LBTree