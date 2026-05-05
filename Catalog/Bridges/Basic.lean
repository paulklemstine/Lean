--- a/Bridges/Basic.lean
+++ b/Bridges/Basic.lean
@@ -1,104 +1,149 @@
 /-
-# Bridge Theory in Simple Graphs
+Copyright (c) 2025. All rights reserved.
+Released under Apache 2.0 license.
+
+# Bridge Theory in Graph Theory
 
 This file develops the theory of bridges (cut edges) in simple graphs,
-proving the fundamental equivalence between trees and connected graphs
-where every edge is a bridge.
+building on Mathlib's `SimpleGraph.IsBridge` definition.
 
-## Main Results
+## Main results
 
-* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
-* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
-* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
-* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
-  A graph is a tree if and only if it is connected and every edge is a bridge
+* `IsBridge.connectedComponent_ne` — Endpoints of a bridge are in different
+  connected components after deletion.
+* `IsBridge.two_connected_components` — Removing a bridge from a connected
+  graph yields exactly two connected components.
+* `IsTree.isBridge_of_adj` — Every edge of a tree is a bridge.
+* `connected_isBridge_all_iff_isTree` — A connected graph is a tree iff
+  every edge is a bridge.
+* `IsBridge.forall_reachable_delete_left_or_right` — Every vertex in a
+  connected graph is reachable from one side of a bridge after deletion.
 
-## Historical Context
+## Historical context
 
-Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
-bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
-structural characterization: trees are precisely the minimally connected graphs,
-where the removal of any single edge disconnects the graph.
-
-## References
-
-* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
+The study of bridges in graph theory traces back to Euler's 1736 solution
+of the Königsberg Bridge Problem — widely considered the birth of graph
+theory. A bridge (or cut edge) is an edge whose removal disconnects the
+graph, making it a critical concept in network reliability and infrastructure
+analysis.
 -/
 
 import Mathlib
 
 namespace SimpleGraph
 
-variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}
+variable {V : Type*} {G : SimpleGraph V}
 
-/-! ### Trees have all bridges
+/-! ### Deletion equivalence
 
-We prove that in a tree, every edge is a bridge. This follows from the
-characterization that an edge is a bridge iff it does not lie on any cycle,
-combined with the fact that trees are acyclic.
+`G.deleteEdges s` and `G \ fromEdgeSet s` have the same adjacency and
+hence the same reachability.  We prove the reachability equivalence
+we need. -/
+
+/-
+`deleteEdges {e}` and `G \ fromEdgeSet {e}` have the same reachability.
 -/
+theorem reachable_deleteEdges_iff_reachable_sdiff {e : Sym2 V} {u v : V} :
+    (G.deleteEdges {e}).Reachable u v ↔ (G \ fromEdgeSet {e}).Reachable u v := by
+  constructor;
+  · intro h;
+    convert h.mono ?_;
+    intro u v; aesop;
+  · intro h;
+    convert h
 
-/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
-no edge can lie on a cycle, which is precisely the bridge characterization. -/
-theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
-    (he : e ∈ G.edgeSet) : G.IsBridge e := by
-  rw [isBridge_iff_mem_and_forall_cycle_notMem]
-  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩
+/-- Bridge characterization using `deleteEdges` instead of `sdiff`. -/
+theorem isBridge_iff_deleteEdges {u v : V} :
+    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G.deleteEdges {s(u, v)}).Reachable u v := by
+  rw [isBridge_iff]
+  exact ⟨
+    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mp hr)⟩,
+    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mpr hr)⟩⟩
 
-/-- In a tree, every edge is a bridge. This is a direct consequence of
-acyclicity: since no cycles exist, no edge can participate in a cycle. -/
-theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
-    (he : e ∈ G.edgeSet) : G.IsBridge e :=
-  hTree.IsAcyclic.isBridge_of_mem_edgeSet he
+/-! ### Bridge fundamentals -/
 
-/-! ### Connected graphs with all bridges are trees
+/-- The endpoints of a bridge lie in different connected components
+after the bridge is deleted. -/
+theorem IsBridge.connectedComponent_ne_deleteEdges {u v : V}
+    (hb : G.IsBridge s(u, v)) :
+    (G.deleteEdges {s(u, v)}).connectedComponentMk u ≠
+    (G.deleteEdges {s(u, v)}).connectedComponentMk v := by
+  rw [Ne, ConnectedComponent.eq]
+  exact (isBridge_iff_deleteEdges.mp hb).2
 
-We prove the converse: if a connected graph has the property that every
-edge is a bridge, then it must be acyclic (and hence a tree).
+/-! ### Bridge splitting: every vertex goes to one side -/
+
+/-
+In a connected graph, after removing a bridge {u,v}, every vertex
+is reachable from either u or v (but not both, since u and v are separated).
+This shows the bridge partitions the vertex set into exactly two parts.
 -/
+theorem IsBridge.forall_reachable_delete_left_or_right
+    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
+    (G.deleteEdges {s(u, v)}).Reachable u w ∨
+    (G.deleteEdges {s(u, v)}).Reachable v w := by
+  obtain ⟨ p ⟩ := hconn w u;
+  induction' p with w' w'' p ih;
+  · exact Or.inl ( SimpleGraph.Reachable.refl _ );
+  · cases' eq_or_ne w'' ih with h h <;> cases' eq_or_ne w'' v with h' h' <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
+    cases' ‹ ( G.deleteEdges { s(ih, v) } ).Reachable ih p ∨ ( G.deleteEdges { s(ih, v) } ).Reachable v p › with h'' h'' <;> [ left; right ] <;> refine' h''.trans _ <;> simp_all +decide [ SimpleGraph.deleteEdges ];
+    · exact SimpleGraph.Adj.reachable ( by aesop ) |> SimpleGraph.Reachable.symm;
+    · exact SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable ( by aesop ) )
 
-/-- If every edge of a graph is a bridge, then the graph is acyclic.
+/-! ### Two connected components -/
 
-**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
-Since `c` is not nil, it has at least one edge `e`. This edge lies in the
-edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
-on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
-that `e` lies on `c`. -/
-theorem isAcyclic_of_forall_isBridge
-    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
-  intro v c hc
-  -- A cycle must have at least one edge
-  have hne : c.edges ≠ [] := by
-    intro he
-    cases c with
-    | nil => exact hc.ne_nil rfl
-    | cons _ _ => simp [Walk.edges_cons] at he
-  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
-  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
-  have hbridge := h e he_mem
-  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
-  exact hbridge.2 c hc he
+/-
+Removing a bridge from a connected graph produces exactly two
+connected components. This is a fundamental structural result about
+bridges, showing that a bridge literally "bridges" two otherwise
+disconnected parts of the graph.
+-/
+theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
+    [DecidableRel G.Adj]
+    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
+    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2 := by
+  convert Set.ncard_eq_two.mpr _;
+  rotate_left;
+  exact ( G.deleteEdges { s(u, v) } ).ConnectedComponent;
+  exact Set.range ( fun w => ( G.deleteEdges { s(u, v) } ).connectedComponentMk w );
+  · refine' ⟨ _, _, _, _ ⟩;
+    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk u;
+    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk v;
+    · exact connectedComponent_ne_deleteEdges hb;
+    · ext w;
+      obtain ⟨ x, rfl ⟩ := w.exists_rep;
+      have := hb.forall_reachable_delete_left_or_right hconn x;
+      cases this <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
+      · exact Or.inl ( Quot.sound ‹_› |> Eq.symm );
+      · exact Or.inr ( Quot.sound <| by tauto );
+  · rw [ Set.ncard_eq_toFinset_card _ ];
+    refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide;
+    exact fun a => a.exists_rep
 
-/-- **Tree-Bridge Equivalence Theorem.**
-A graph is a tree if and only if it is connected and every edge is a bridge.
+/-! ### Trees and bridges -/
 
-This is a fundamental characterization of trees: they are precisely the
-connected graphs that are "minimally connected" — removing any single
-edge disconnects the graph.
+/-
+Every edge of a tree is a bridge. In a tree, every edge is critical
+for connectivity — removing any edge disconnects the tree.
+-/
+theorem IsTree.isBridge_of_adj (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
+    G.IsBridge s(u, v) := by
+  -- By definition of a tree, it is acyclic.
+  have h_acyclic : G.IsAcyclic := by
+    exact hT.2;
+  rw [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ] at h_acyclic ; aesop
 
-### Forward direction
-In a tree (connected + acyclic), every edge is a bridge because there are
-no cycles, so no edge can lie on a cycle.
-
-### Reverse direction
-If every edge is a bridge, the graph must be acyclic: any cycle would contain
-an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
-theorem isTree_iff_connected_and_forall_isBridge :
-    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
-  constructor
-  · intro hTree
-    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
-  · intro ⟨hConn, hBridge⟩
-    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩
+/-
+A connected graph is a tree if and only if every edge is a bridge.
+This provides a characterization of trees in terms of edge criticality.
+-/
+theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
+    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree := by
+  constructor;
+  · intro h;
+    constructor;
+    · assumption;
+    · exact isAcyclic_iff_forall_adj_isBridge.mpr h;
+  · exact fun a ⦃u v⦄ a_1 => IsTree.isBridge_of_adj a a_1
 
 end SimpleGraph