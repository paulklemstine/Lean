/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Bridge Theory for Simple Graphs

This file develops the theory of **bridges** (cut edges) in simple graphs.
A bridge is an edge whose removal disconnects the graph. We prove:

1. **Every edge in a tree is a bridge** (`IsTree.isBridge_of_mem_edgeSet`)
2. **A bridge is not contained in any cycle** (`IsBridge.not_mem_cycle_edges`)
3. **An edge on no cycle is a bridge (if the graph is connected)**
   (`isBridge_of_adj_of_not_mem_cycle`)

These results are fundamental to structural graph theory and connect
to the classical Königsberg Bridge Problem.
-/

import Mathlib

namespace SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-! ## Trees and Bridges -/

/-- **Main Theorem**: In a tree, every edge is a bridge.

A tree is a connected acyclic graph. Since there are no cycles, every edge
is the unique path between its endpoints. Removing it disconnects them. -/
theorem IsTree.isBridge_of_mem_edgeSet [Fintype V] [DecidableEq V]
    (hT : G.IsTree) {e : Sym2 V} (he : e ∈ G.edgeSet) :
    G.IsBridge e := by
  grind +suggestions

/-- In a tree, every adjacent pair is connected by a bridge edge. -/
theorem IsTree.isBridge_of_adj [Fintype V] [DecidableEq V]
    (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
    G.IsBridge s(u, v) := by
  exact isBridge_of_mem_edgeSet hT hadj

/-! ## Bridges and Cycles -/

/-- A bridge edge cannot appear in any cycle.

If an edge {u,v} is a bridge, then every walk from u to v must use it.
A cycle through {u,v} would provide an alternative path, contradiction. -/
theorem IsBridge.not_mem_cycle_edges
    {u : V} {c : G.Walk u u} (hc : c.IsCycle)
    {v w : V} (hb : G.IsBridge s(v, w)) :
    s(v, w) ∉ c.edges := by
  grind +suggestions

/-- If a connected graph has an edge that is not on any cycle, then it is a bridge. -/
theorem isBridge_of_adj_of_not_mem_cycle
    (_hconn : G.Connected)
    {u v : V} (hadj : G.Adj u v)
    (hnocycle : ∀ (w : V) (c : G.Walk w w), c.IsCycle → s(u, v) ∉ c.edges) :
    G.IsBridge s(u, v) := by
  grind +suggestions

end SimpleGraph