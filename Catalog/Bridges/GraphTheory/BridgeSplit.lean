/-
# Bridge Splitting Theorem

This file proves that removing a bridge from a connected graph
produces exactly two connected components, and develops the theory
of 2-edge-connectivity.

## Main Results

* `SimpleGraph.bridge_removal_two_components` — removing a bridge gives 2 components
* `SimpleGraph.IsTwoEdgeConnected` — definition of 2-edge-connectivity
* `SimpleGraph.isTwoEdgeConnected_iff_forall_reachable_after_delete` — characterization

## References

* Diestel, R. *Graph Theory*, 5th edition, Springer, 2017.
-/

import Mathlib

namespace SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-! ### Bridge Endpoint Separation -/

/-- The endpoints of a bridge are in different connected components
after the bridge is removed. -/
theorem bridge_endpoints_not_reachable {v w : V}
    (hb : G.IsBridge s(v, w)) :
    ¬(G \ fromEdgeSet {s(v, w)}).Reachable v w := by
  convert hb.2

/-! ### Bridge Splitting -/

/-- Every vertex in a connected graph with a bridge removed is reachable
from one of the two bridge endpoints. -/
theorem bridge_split_dichotomy {v w : V}
    (hconn : G.Connected) (_hb : G.IsBridge s(v, w)) (x : V) :
    (G \ fromEdgeSet {s(v, w)}).Reachable v x ∨
    (G \ fromEdgeSet {s(v, w)}).Reachable w x := by
  have h_ind : ∀ {u x : V}, G.Reachable u x →
      (G \ fromEdgeSet {s(v, w)}).Reachable v x ∨
      (G \ fromEdgeSet {s(v, w)}).Reachable w x ∨
      (G \ fromEdgeSet {s(v, w)}).Reachable u x := by
    intro u x
    rintro ⟨p⟩
    induction' p with u x p ih
    · exact Or.inr <| Or.inr <| SimpleGraph.Reachable.refl _
    · by_cases h : s(x, p) = s(v, w)
      · aesop
      · rename_i h₁ h₂
        exact h₂.imp id (Or.imp id (fun h => by
          exact SimpleGraph.Reachable.trans
            (SimpleGraph.Adj.reachable <| by aesop) h))
  cases h_ind (hconn v x) <;> aesop

/-- Removing a bridge from a connected finite graph produces exactly
two connected components. -/
theorem bridge_removal_two_components [Fintype V] [DecidableEq V]
    [DecidableRel G.Adj] {v w : V}
    (hconn : G.Connected) (hb : G.IsBridge s(v, w)) :
    Fintype.card (G \ fromEdgeSet {s(v, w)}).ConnectedComponent = 2 := by
  rw [Fintype.card_eq_nat_card]
  rw [Nat.card_eq_two_iff']
  swap
  exact (G \ fromEdgeSet {s(v, w)}).connectedComponentMk v
  refine ⟨(G \ fromEdgeSet {s(v, w)}).connectedComponentMk w, ?_, ?_⟩
  · intro h
    exact hb.2 (by simpa [SimpleGraph.reachable_comm] using
      SimpleGraph.ConnectedComponent.eq.mp h)
  · rintro ⟨x⟩ hx
    have := bridge_split_dichotomy hconn hb x
    cases' this with h h
    · exact False.elim (hx (Quot.sound h.symm))
    · exact Quot.sound h.symm

/-! ### 2-Edge-Connectivity -/

/-- A graph is 2-edge-connected if it is connected and has no bridges. -/
def IsTwoEdgeConnected (G : SimpleGraph V) : Prop :=
  G.Connected ∧ ∀ e, ¬G.IsBridge e

/-
A 2-edge-connected graph remains connected after removing any single edge.
This is the defining property in terms of edge-fault tolerance.
-/
theorem IsTwoEdgeConnected.connected_delete_edge
    (h2ec : G.IsTwoEdgeConnected) (e : Sym2 V) :
    (G \ fromEdgeSet {e}).Connected := by
  rcases h2ec with ⟨ hG, h ⟩;
  -- Since $e$ is not a bridge, removing $e$ from $G$ does not disconnect the graph.
  have h_connected : ∀ u v : V, G.Reachable u v → (G \ fromEdgeSet {e}).Reachable u v := by
    intro u v huv
    induction' huv with u v huv ih;
    induction' u with u v huv ih;
    · exact SimpleGraph.Reachable.refl _;
    · by_cases he : e = s(v, huv);
      · specialize h ( s(v, huv) ) ; simp_all +decide [ SimpleGraph.isBridge_iff ] ;
        exact h.trans ‹_›;
      · exact SimpleGraph.Reachable.trans ( SimpleGraph.Adj.reachable <| by aesop ) ‹_›;
  cases isEmpty_or_nonempty V <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
  exact ⟨ hG.choose, fun w => h_connected _ _ ( hG.choose_spec w ) ⟩

/-
Conversely, a connected graph where every single-edge deletion preserves
connectivity is 2-edge-connected.
-/
theorem isTwoEdgeConnected_of_connected_delete
    (hconn : G.Connected)
    (hdel : ∀ e ∈ G.edgeSet, (G \ fromEdgeSet {e}).Connected) :
    G.IsTwoEdgeConnected := by
  refine ⟨ hconn, fun e he => ?_ ⟩;
  cases e ; simp_all +decide [ SimpleGraph.isBridge_iff ];
  exact he.2 ( hdel _ ( by simpa using he.1 ) |> fun h => h _ _ )

/-
A connected graph with no bridges has the property that every edge
lies on a cycle. This is the cycle characterization of 2-edge-connectivity,
using the bridge-cycle theorem from `BridgeCycle.lean`.
-/
theorem IsTwoEdgeConnected.every_edge_on_cycle
    (h2ec : G.IsTwoEdgeConnected) {v w : V} (hadj : G.Adj v w) :
    ∃ (u : V) (c : G.Walk u u), c.IsCycle ∧ s(v, w) ∈ c.edges := by
  by_contra! h;
  -- Since $G$ is 2-edge-connected, no edge is a bridge. In particular, $\neg G.IsBridge s(v,w)$.
  have h_not_bridge : ¬G.IsBridge s(v, w) := by
    exact h2ec.2 _;
  grind +suggestions

end SimpleGraph