/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Bridge Edges in Graphs — Structural Theorems

A **bridge** (or cut edge) in a graph is an edge whose removal disconnects the graph.
This file proves structural results about bridge edges that connect to network reliability
and the theory of Eulerian paths.

## Main Results

* `tree_edge_count` — A tree on n ≥ 1 vertices has exactly n - 1 edges.
* `tree_all_bridges` — In a tree, every edge is a bridge.
* `bridge_iff_not_in_cycle` — An edge is a bridge iff it belongs to no cycle.
* `sum_degrees_eq` — The handshaking lemma (∑ deg = 2|E|).
* `completeGraph_no_bridges` — Kₙ for n > 2 has no bridges.

## Connection to Euler's Theorem

The Königsberg problem is intimately connected to bridge edges: Fleury's algorithm
for finding Eulerian trails works by preferring non-bridge edges. A graph with too
many bridges constrains possible traversals.
-/

import Mathlib

open SimpleGraph Finset

namespace Bridges

/-! ## Tree Properties -/

/-
A tree on n ≥ 1 vertices has exactly n - 1 edges. This is a fundamental result
    connecting to the fact that every edge in a tree is a bridge.
-/
theorem tree_edge_count {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] [Fintype G.edgeSet]
    (hT : G.IsTree) :
    G.edgeFinset.card + 1 = Fintype.card V := by
  exact IsTree.card_edgeFinset hT

/-
In a tree, every edge is a bridge. This follows from acyclicity.
-/
theorem tree_all_bridges {V : Type*} [DecidableEq V]
    (G : SimpleGraph V) (hT : G.IsTree)
    (e : Sym2 V) (he : e ∈ G.edgeSet) :
    G.IsBridge e := by
  grind +suggestions

/-
In a connected graph, an edge is a bridge if and only if it belongs to no cycle.
-/
theorem bridge_iff_not_in_cycle {V : Type*} [DecidableEq V]
    (G : SimpleGraph V) {u v : V} :
    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ∀ ⦃w : V⦄ (p : G.Walk w w), p.IsCycle → s(u, v) ∉ p.edges := by
  exact isBridge_iff_adj_and_forall_cycle_notMem

/-! ## Degree-Sum Applications -/

/-- The handshaking lemma: the sum of all vertex degrees equals twice the edge count.
    (Re-exported from Mathlib for convenience.) -/
theorem sum_degrees_eq {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ v, G.degree v = 2 * G.edgeFinset.card :=
  G.sum_degrees_eq_twice_card_edges

/-! ## Complete Graph Properties -/

/-
The complete graph on n ≥ 2 vertices has no bridges
    (it is 2-edge-connected).
-/
theorem completeGraph_no_bridges (n : ℕ) (hn : 2 < n)
    (e : Sym2 (Fin n)) :
    ¬(⊤ : SimpleGraph (Fin n)).IsBridge e := by
  rcases e with ⟨ u, v ⟩;
  by_cases h : u = v <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
  -- Since $u \neq v$, there exists a vertex $w$ such that $w \neq u$ and $w \neq v$.
  obtain ⟨w, hw⟩ : ∃ w : Fin n, w ≠ u ∧ w ≠ v := by
    exact Exists.imp ( by aesop ) ( Finset.exists_mem_ne ( show 1 < Finset.card ( Finset.univ.erase u ) from by rw [ Finset.card_erase_of_mem ( Finset.mem_univ u ), Finset.card_fin ] ; exact Nat.lt_pred_iff.mpr hn ) v );
  refine' SimpleGraph.Reachable.trans _ _;
  exact w;
  · exact SimpleGraph.Adj.reachable ( by aesop );
  · exact SimpleGraph.Adj.reachable ( by aesop )

end Bridges