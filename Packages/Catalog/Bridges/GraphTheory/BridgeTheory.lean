import Mathlib

/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge Theory in Finite Graphs

This file develops the theory of bridge edges (cut edges) in finite simple graphs,
proving several fundamental results:

1. **Even-degree bridge-free theorem**: A connected graph where every vertex has
   even degree has no bridges. This connects vertex-local degree information to
   global edge-connectivity structure.

2. **Tree characterization**: A finite connected graph is a tree if and only if
   every edge is a bridge.

## Main results

* `SimpleGraph.not_isBridge_of_even_degree` — if every vertex of a finite connected
  graph has even degree, then no edge is a bridge.

* `SimpleGraph.isTree_iff_connected_and_forall_edge_isBridge` — a graph is a tree
  iff it is connected and every edge is a bridge.

## References

* The even-degree bridge-free theorem is a classical result in graph theory,
  often presented as a corollary of Euler's theorem on Eulerian circuits.
  Our proof uses the handshaking lemma directly.
-/



namespace SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

open Finset

/-! ### Even-degree graphs have no bridges -/

section EvenDegreeBridgeFree

variable [Fintype V] [DecidableEq V] [DecidableRel G.Adj]

/-
**Even-degree bridge-free theorem**: In a finite connected graph where every
vertex has even degree, no edge is a bridge.

**Proof sketch**: Suppose for contradiction that `s(u, v)` is a bridge. By the
cycle characterization, a bridge is an edge not contained in any cycle. But in a
connected graph with all even degrees, every edge lies on a cycle (since removing
any edge from a connected even-degree graph still leaves u and v connected — this
follows from the handshaking lemma applied to connected components).
-/
theorem not_isBridge_of_even_degree (_hconn : G.Connected)
    (heven : ∀ v : V, Even (G.degree v)) : ∀ e, ¬G.IsBridge e := by
  intro e he;
  -- By `isBridge_iff`, after deleting s(u,v), u and v are not reachable.
  obtain ⟨u, v, huv⟩ : ∃ u v, e = s(u, v) ∧ ¬(G \ (SimpleGraph.fromEdgeSet {s(u, v)})).Reachable u v := by
    rcases e with ⟨ u, v ⟩;
    exact ⟨ u, v, rfl, by simpa using he.2 ⟩;
  -- Consider the connected component of $u$ in $G \setminus \{s(u, v)\}$.
  set C := {w : V | (G \ (SimpleGraph.fromEdgeSet {s(u, v)})).Reachable u w} with hC_def;
  -- The sum of degrees of vertices in $C$ must be even (it equals 2 times the number of edges in the induced subgraph).
  have h_sum_degrees_even : Even (∑ w ∈ Finset.filter (fun w => w ∈ C) Finset.univ, (G \ (SimpleGraph.fromEdgeSet {s(u, v)})).degree w) := by
    have h_sum_degrees_even : ∑ w ∈ Finset.filter (fun w => w ∈ C) Finset.univ, (G \ (SimpleGraph.fromEdgeSet {s(u, v)})).degree w = 2 * (SimpleGraph.edgeFinset (SimpleGraph.induce C (G \ (SimpleGraph.fromEdgeSet {s(u, v)})))).card := by
      convert SimpleGraph.sum_degrees_eq_twice_card_edges ( SimpleGraph.induce C ( G \ fromEdgeSet { s(u, v) } ) ) using 1;
      refine' Finset.sum_bij ( fun x hx => ⟨ x, by aesop ⟩ ) _ _ _ _ <;> simp +decide;
      intro a ha; rw [ SimpleGraph.degree, SimpleGraph.degree ] ;
      refine' Finset.card_bij ( fun x hx => ⟨ x, _ ⟩ ) _ _ _ <;> simp_all +decide [ SimpleGraph.neighborFinset ];
      exact ha.trans ( SimpleGraph.Adj.reachable <| by aesop );
    exact h_sum_degrees_even.symm ▸ even_two_mul _;
  -- Vertex $u$ has odd degree in $G \setminus \{s(u, v)\}$.
  have h_u_odd_degree : Odd ((G \ (SimpleGraph.fromEdgeSet {s(u, v)})).degree u) := by
    have h_u_odd_degree : (G \ (SimpleGraph.fromEdgeSet {s(u, v)})).degree u = G.degree u - 1 := by
      simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
      rw [ ← Finset.card_erase_of_mem ];
      congr with x ; by_cases hx : x = v <;> by_cases hx' : u = v <;> simp +decide [ hx, hx' ];
      any_goals tauto;
      cases he ; aesop;
    rcases k : G.degree u with ( _ | _ | k ) <;> simp_all +decide [ parity_simps ];
    · simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
      exact k ( he.1 );
    · exact absurd ( heven u ) ( by simp +decide [ k ] );
    · simpa [ k, parity_simps ] using heven u;
  -- All other vertices $w$ in $C$ have $w \neq v$ (since $v$ is not reachable from $u$ in $G \setminus \{s(u, v)\}$), so they have the same degree in $G \setminus \{s(u, v)\}$ as in $G$, which is even.
  have h_other_even_degrees : ∀ w ∈ Finset.filter (fun w => w ∈ C) Finset.univ, w ≠ u → Even ((G \ (SimpleGraph.fromEdgeSet {s(u, v)})).degree w) := by
    intro w hw hwu
    have h_w_ne_v : w ≠ v := by
      rintro rfl; simp_all +decide [ SimpleGraph.IsBridge ] ;
    convert heven w using 1;
    simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def, hwu, h_w_ne_v ];
  rw [ Finset.sum_eq_add_sum_diff_singleton ( show u ∈ Finset.filter ( fun w => w ∈ C ) Finset.univ from Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by exact SimpleGraph.Reachable.refl _ ⟩ ) ] at h_sum_degrees_even;
  simp_all +decide [Nat.even_iff];
  rw [ Nat.odd_iff ] at h_u_odd_degree; rw [ Nat.add_mod, Finset.sum_nat_mod ] at h_sum_degrees_even; simp_all +decide [ Nat.add_mod ] ;
  rw [ Finset.sum_eq_zero ] at h_sum_degrees_even <;> aesop

end EvenDegreeBridgeFree

/-! ### Tree characterization via bridges -/

/-- A finite connected graph is a tree if and only if it is connected and every
edge is a bridge. This combines the Mathlib results that acyclicity is equivalent
to every edge being a bridge, with the definition of a tree as a connected
acyclic graph. -/
theorem isTree_iff_connected_and_forall_edge_isBridge :
    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
  constructor
  · intro ht
    exact ⟨ht.isConnected, fun e he => isAcyclic_iff_forall_edge_isBridge.mp ht.IsAcyclic he⟩
  · intro ⟨hc, hb⟩
    exact ⟨hc, isAcyclic_iff_forall_edge_isBridge.mpr hb⟩

end SimpleGraph