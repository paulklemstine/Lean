/-
# Bridge Theory in Simple Graphs

This file develops the theory of bridges (cut edges) in simple graphs,
proving the fundamental equivalence between trees and connected graphs
where every edge is a bridge.

## Main Results

* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
  A graph is a tree if and only if it is connected and every edge is a bridge

## Historical Context

Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
structural characterization: trees are precisely the minimally connected graphs,
where the removal of any single edge disconnects the graph.

## References

* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
-/

import Mathlib

namespace SimpleGraph

variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}

/-! ### Trees have all bridges

We prove that in a tree, every edge is a bridge. This follows from the
characterization that an edge is a bridge iff it does not lie on any cycle,
combined with the fact that trees are acyclic.
-/

/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
no edge can lie on a cycle, which is precisely the bridge characterization. -/
theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
    (he : e ∈ G.edgeSet) : G.IsBridge e := by
  rw [isBridge_iff_mem_and_forall_cycle_notMem]
  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩

/-- In a tree, every edge is a bridge. This is a direct consequence of
acyclicity: since no cycles exist, no edge can participate in a cycle. -/
theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
    (he : e ∈ G.edgeSet) : G.IsBridge e :=
  hTree.IsAcyclic.isBridge_of_mem_edgeSet he

/-! ### Connected graphs with all bridges are trees

We prove the converse: if a connected graph has the property that every
edge is a bridge, then it must be acyclic (and hence a tree).
-/

/-- If every edge of a graph is a bridge, then the graph is acyclic.

**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
Since `c` is not nil, it has at least one edge `e`. This edge lies in the
edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
that `e` lies on `c`. -/
theorem isAcyclic_of_forall_isBridge
    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
  intro v c hc
  -- A cycle must have at least one edge
  have hne : c.edges ≠ [] := by
    intro he
    cases c with
    | nil => exact hc.ne_nil rfl
    | cons _ _ => simp [Walk.edges_cons] at he
  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
  have hbridge := h e he_mem
  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
  exact hbridge.2 c hc he

/-- **Tree-Bridge Equivalence Theorem.**
A graph is a tree if and only if it is connected and every edge is a bridge.

This is a fundamental characterization of trees: they are precisely the
connected graphs that are "minimally connected" — removing any single
edge disconnects the graph.

### Forward direction
In a tree (connected + acyclic), every edge is a bridge because there are
no cycles, so no edge can lie on a cycle.

### Reverse direction
If every edge is a bridge, the graph must be acyclic: any cycle would contain
an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
theorem isTree_iff_connected_and_forall_isBridge :
    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
  constructor
  · intro hTree
    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
  · intro ⟨hConn, hBridge⟩
    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩

end SimpleGraph