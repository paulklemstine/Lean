/-
Copyright (c) 2025. All rights reserved.

# Proof-Theoretic Topology: Definitions

This file introduces the foundational definitions for proof-theoretic topology,
a framework connecting semantic similarity of formal statements to topological
invariants of threshold graphs.

## Main Definitions

* `symmDiffCard` — cardinality of symmetric difference of two finsets
* `SemanticFeatureSpace` — a finite space of statements with feature maps
* `semanticDist` — computable dissimilarity based on symmetric difference
* `semanticGraph` — threshold graph at a given distance parameter ε
* `graphCycleRank` — cyclomatic number (first Betti number of graph as 1-CW complex)
* `HardnessProfile` — monotone hardness functional on a statement space
-/

import Mathlib

open Finset

/-! ## Symmetric Difference Cardinality -/

/-- The cardinality of the symmetric difference of two finsets.
This is our fundamental discrete dissimilarity measure. -/
def symmDiffCard {β : Type*} [DecidableEq β] (A B : Finset β) : ℕ :=
  (A \ B).card + (B \ A).card

/-! ## Semantic Feature Space -/

/-- A semantic feature space assigns to each element of a finite type `α`
a finset of features from type `β`. This models a family of formal statements
where each statement is characterized by its feature set. -/
structure SemanticFeatureSpace (α β : Type*) [Fintype α] where
  /-- The feature map assigning a finset of features to each statement. -/
  featureSet : α → Finset β

/-! ## Semantic Distance -/

/-- The semantic distance between two elements is the symmetric difference
cardinality of their feature sets. This gives a computable, discrete
dissimilarity measure on the statement space. -/
def semanticDist {α β : Type*} [DecidableEq β]
    (S : α → Finset β) (x y : α) : ℕ :=
  symmDiffCard (S x) (S y)

/-! ## Threshold Graphs -/

/-- The semantic threshold graph at parameter ε: two distinct elements are
adjacent if and only if their semantic distance is at most ε. This yields
a filtration of simple graphs parameterized by the threshold. -/
def semanticGraph {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (ε : ℕ) : SimpleGraph α where
  Adj x y := x ≠ y ∧ semanticDist S x y ≤ ε
  symm x y h := ⟨h.1.symm, by
    simp only [semanticDist, symmDiffCard, add_comm]
    exact h.2⟩
  loopless := ⟨fun x h => h.1 rfl⟩

instance semanticGraph_decidableAdj {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (ε : ℕ) : DecidableRel (semanticGraph S ε).Adj :=
  fun x y =>
    inferInstanceAs (Decidable (x ≠ y ∧ semanticDist S x y ≤ ε))

/-! ## Graph Cycle Rank (Cyclomatic Number) -/

/-- The cycle rank (cyclomatic number) of a finite simple graph.
For a graph with `e` edges, `v` vertices, and `c` connected components,
this equals `e - v + c`. This is the first Betti number of the graph
viewed as a 1-dimensional CW complex, and serves as a topological
order parameter detecting nontrivial cycles. -/
noncomputable def graphCycleRank {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card α : ℤ) +
    (Fintype.card G.ConnectedComponent : ℤ)

/-! ## Hardness Profile -/

/-- A hardness profile assigns to each element a hardness value in `ℕ ∪ {∞}`.
This models the computational cost of proving or disproving a statement,
where `⊤` represents unprovability within the given resource bounds. -/
structure HardnessProfile (α : Type*) where
  /-- The hardness function, where `⊤` means the statement is too hard. -/
  hardness : α → WithTop ℕ