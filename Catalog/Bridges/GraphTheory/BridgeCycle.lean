/-
# Bridge-Cycle Characterization Theorem

This file proves the fundamental characterization of bridges in graph theory:

**An edge of a graph is a bridge if and only if it does not lie on any cycle.**

This is one of the most basic and important results in graph connectivity theory,
connecting the global property of disconnection upon edge removal with the local
structural property of cycle membership.

## Main Results

* `SimpleGraph.isBridge_iff_not_mem_cycle` — the bridge-cycle characterization
* `SimpleGraph.IsTree.isBridge` — every edge of a tree is a bridge

## References

* Diestel, R. *Graph Theory*, 5th edition, Springer, 2017.
-/

import Mathlib

namespace SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-! ### Bridge-Cycle Characterization

We prove that an edge `{v, w}` is a bridge of `G` if and only if
it does not appear in the edge list of any cycle in `G`.
-/

/-
An edge is a bridge if and only if it does not lie on any cycle.
This is the fundamental structural characterization of bridges.
-/
theorem isBridge_iff_not_mem_cycle {v w : V} :
    G.IsBridge s(v, w) ↔
      G.Adj v w ∧ ¬∃ (u : V) (c : G.Walk u u), c.IsCycle ∧ s(v, w) ∈ c.edges := by
  constructor <;> intro H;
  · refine' ⟨ H.1, _ ⟩;
    obtain ⟨h_adj, h_not_reachable⟩ := SimpleGraph.isBridge_iff.mp H;
    grind +suggestions;
  · refine' ⟨ H.1, _ ⟩;
    -- If there's no cycle containing the edge s(v, w), then removing s(v, w) disconnects v and w.
    have h_disconnect : ¬(G \ SimpleGraph.fromEdgeSet {s(v, w)}).Reachable v w := by
      intro h_reachable
      -- If v and w are reachable in the graph without s(v, w), then there exists a path between them.
      obtain ⟨p, hp⟩ : ∃ p : G.Walk v w, s(v, w) ∉ p.edges := by
        obtain ⟨ p, hp ⟩ := h_reachable.exists_isPath;
        refine' ⟨ p.map ( SimpleGraph.Hom.ofLE ( show G \ fromEdgeSet { s(v, w) } ≤ G from _ ) ), _ ⟩ <;> simp_all +decide;
        intro h; have := p.edges_subset_edgeSet h; simp_all +decide [ SimpleGraph.edgeSet_sdiff ] ;
      refine' H.2 ⟨ v, p.append ( SimpleGraph.Walk.cons H.1.symm SimpleGraph.Walk.nil ), _, _ ⟩ <;> simp_all +decide [ SimpleGraph.Walk.isCycle_def ];
      grind +suggestions;
    exact h_disconnect

/-! ### Tree Bridge Theorem -/

/-
In a tree, every edge is a bridge. This follows from the bridge-cycle
characterization since trees have no cycles by definition.
-/
theorem IsTree.isBridge {v w : V} (hT : G.IsTree) (hadj : G.Adj v w) :
    G.IsBridge s(v, w) := by
  convert isBridge_iff_not_mem_cycle.mpr _;
  exact ⟨ hadj, fun ⟨ u, c, hc, h ⟩ => hT.2 c hc ⟩

end SimpleGraph