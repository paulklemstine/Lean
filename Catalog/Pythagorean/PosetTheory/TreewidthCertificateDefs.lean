/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Treewidth-Parameterized Certificate Compilation: Definitions

This file defines the core structures for bounded-treewidth polynomial
certificate compilation via deletion/contraction decomposition.

## Mathematical Overview

We formalize the key data structures for treewidth-parameterized
certificates on graphs:

1. **CertTree**: A binary certificate tree representing the
   deletion/contraction branching of a matroid computation.

2. **BagEdgeBound**: The fundamental combinatorial bound that a bag
   with at most k+1 vertices contributes at most k*(k+1)/2 active edges.

3. **BellPartition**: State compression via partitions of bag vertices,
   connecting treewidth certificates to the Bell number hierarchy.

## Key Definitions

* `CertTree` — Binary certificate tree with edge annotations
* `CertTree.size` — Number of nodes in a certificate tree
* `CertTree.depth` — Depth of a certificate tree
* `BagProfile` — State partition profile at a tree decomposition bag
* `maxActiveEdges` — Maximum active edges for bag width k

## References

* Robertson–Seymour, "Graph Minors" series
* Arnborg–Corneil–Proskurowski, "Complexity of finding embeddings
  in a k-tree" (1987)
* Bodlaender, "A linear time algorithm for finding tree-decompositions
  of small treewidth" (1996)
-/

noncomputable section
open Finset Nat

namespace TreewidthCert

/-! ## Certificate Tree Structure -/

/-- A **certificate tree** represents the deletion/contraction branching
    structure of a matroid computation. Each internal node corresponds to
    choosing to delete or contract an edge, producing two subtrees.
    Leaves represent base cases where the matroid invariant is directly computed. -/
inductive CertTree (α : Type*) where
  | leaf (edges : Finset α) : CertTree α
  | branch (edge : α) (delete : CertTree α) (contract : CertTree α) : CertTree α
  deriving Inhabited

namespace CertTree

variable {α : Type*}

/-- The **size** of a certificate tree is its total number of nodes. -/
def size : CertTree α → ℕ
  | leaf _ => 1
  | branch _ d c => 1 + d.size + c.size

/-- The **depth** of a certificate tree. -/
def depth : CertTree α → ℕ
  | leaf _ => 0
  | branch _ d c => 1 + max d.depth c.depth

/-- The **leaf count** of a certificate tree. -/
def leafCount : CertTree α → ℕ
  | leaf _ => 1
  | branch _ d c => d.leafCount + c.leafCount

/-- A certificate tree is **balanced** if both subtrees at every branch
    have depth within 1 of each other. -/
def IsBalanced : CertTree α → Prop
  | leaf _ => True
  | branch _ d c => d.IsBalanced ∧ c.IsBalanced ∧ d.depth ≤ c.depth + 1 ∧ c.depth ≤ d.depth + 1

/-- Certificate tree size is always positive. -/
theorem size_pos (t : CertTree α) : 0 < t.size := by
  cases t <;> simp [size, Nat.add_pos_left]

/-- Leaf count is always positive. -/
theorem leafCount_pos (t : CertTree α) : 0 < t.leafCount := by
  induction t with
  | leaf _ => simp [leafCount]
  | branch _ d c ihd ihc => simp [leafCount]; omega

/-- Leaf count is at most size. -/
theorem leafCount_le_size (t : CertTree α) : t.leafCount ≤ t.size := by
  induction t with
  | leaf _ => simp [leafCount, size]
  | branch _ d c ihd ihc => simp [leafCount, size]; omega

end CertTree

/-! ## Bag Active Edge Bound -/

/-- The maximum number of edges in a complete graph on n vertices,
    i.e., C(n, 2) = n * (n - 1) / 2. -/
def maxEdgesInBag (bagSize : ℕ) : ℕ := bagSize * (bagSize - 1) / 2

/-- For a bag of width k (meaning at most k+1 vertices),
    the maximum number of active edges is at most k*(k+1)/2. -/
def maxActiveEdges (k : ℕ) : ℕ := k * (k + 1) / 2

/-- The **state space size** at a bag of width k: each active edge
    can be either deleted or contracted, giving 2^(active edges) states.
    With the Bell number compression, this is bounded by 2^(k^2+k). -/
def certBranchingBound (k : ℕ) : ℕ := 2 ^ (k ^ 2 + k)

/-- A **bag profile** records the partition structure of vertices in a
    tree decomposition bag induced by edge contractions. This is the
    key state-compression data structure from Strategy B. -/
structure BagProfile (n : ℕ) where
  /-- The partition of bag vertices into equivalence classes. -/
  numClasses : ℕ
  /-- Each class has at most n elements. -/
  classSize_le : numClasses ≤ n
  /-- The number of active (undecided) edges. -/
  activeEdges : ℕ

/-! ## FPT Certificate Size -/

/-- The **FPT certificate bound**: for a graph with m edges and treewidth k,
    the compiled certificate has size at most m * 2^(k^2 + k). -/
def fptCertBound (numEdges k : ℕ) : ℕ := numEdges * 2 ^ (k ^ 2 + k)

end TreewidthCert