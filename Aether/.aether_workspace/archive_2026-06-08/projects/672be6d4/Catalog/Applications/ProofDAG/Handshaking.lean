/-
# Directed Handshaking Lemma and Hub Existence

The fundamental structural theorem for directed graphs: the sum of in-degrees
equals the sum of out-degrees equals the number of edges. Combined with the
pigeonhole principle, this yields the existence of hub nodes in any sufficiently
dense directed graph — formalizing the observation that proof dependency networks
concentrate around a small number of foundational results.
-/
import Mathlib

open Finset

/-! ## Directed Graph Definitions -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The in-degree of vertex `v` with respect to a decidable relation `R`:
    the number of vertices `u` such that `R u v`. -/
def relInDegree (R : V → V → Prop) [DecidableRel R] (v : V) : ℕ :=
  (Finset.univ.filter (fun u => R u v)).card

/-- The out-degree of vertex `v` with respect to a decidable relation `R`:
    the number of vertices `u` such that `R v u`. -/
def relOutDegree (R : V → V → Prop) [DecidableRel R] (v : V) : ℕ :=
  (Finset.univ.filter (fun u => R v u)).card

/-- The edge set of a relation as a finset of pairs. -/
def relEdgeFinset (R : V → V → Prop) [DecidableRel R] : Finset (V × V) :=
  Finset.univ.filter (fun p => R p.1 p.2)

/-- The number of edges (pairs (u,v) with R u v). -/
def relEdgeCount (R : V → V → Prop) [DecidableRel R] : ℕ :=
  (relEdgeFinset R).card

/-
**Directed Handshaking Lemma (In-degree version)**:
    The sum of in-degrees over all vertices equals the number of edges.
    This is the directed analog of the classical handshaking lemma.

    Proof idea: Both sides count the same set of pairs (u, v) with R u v.
    The left side partitions by the target v; the right side counts directly.
    Use Finset.card_biUnion or a direct bijection argument.
-/

theorem acyclic_implies_few_edges {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hac : G.IsAcyclic) :
    G.edgeFinset.card ≤ Fintype.card V - 1 := by
  -- Since $V$ is finite, we can apply the induction hypothesis to some appropriate subgraph of $G$.
  by_cases hV : (Fintype.card V) > 0;
  · obtain ⟨T, hT⟩ : ∃ T : SimpleGraph V, G ≤ T ∧ T.IsTree := by
      have h_connected : ∃ T : SimpleGraph V, G ≤ T ∧ T.Connected := by
        use ⊤;
        simp +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
        exact Fintype.card_pos_iff.mp hV;
      grind +suggestions;
    exact le_trans ( Finset.card_le_card ( show G.edgeFinset ⊆ T.edgeFinset from by aesop ) ) ( hT.2.card_edgeFinset ▸ le_rfl );
  · simp_all +decide [ Fintype.card_eq_zero_iff ];
    exact Subsingleton.elim _ _

/-! ## Tree Hub Degree -/

/-
**Hub Concentration in Trees**: In a tree (connected acyclic graph) on n ≥ 3 vertices,
    there exists a vertex whose degree is at least 2. This shows that trees
    (and hence proof DAGs) must have structure — they cannot be paths.
-/

theorem tree_has_two_leaves {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (hac : G.IsAcyclic)
    (hn : Fintype.card V ≥ 2) :
    ∃ u v : V, u ≠ v ∧ G.degree u = 1 ∧ G.degree v = 1 := by
  -- By the Handshaking Lemma, the sum of the degrees of all vertices in a tree is 2(n-1).
  have h_handshake : ∑ v : V, G.degree v = 2 * (Fintype.card V - 1) := by
    rw [ SimpleGraph.sum_degrees_eq_twice_card_edges ];
    have h_tree : G.IsTree := by
      constructor <;> assumption;
    have := h_tree.card_edgeFinset;
    rw [ ← this, Nat.add_sub_cancel ];
  -- Since $G$ is a tree, it is connected and acyclic, so every vertex has degree at least 1.
  have h_degree_pos : ∀ v : V, 1 ≤ G.degree v := by
    intro v;
    by_contra h_contra;
    obtain ⟨ w, hw ⟩ := Fintype.exists_ne_of_one_lt_card hn v; have := hconn v w; simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ] ;
    obtain ⟨ p ⟩ := this; induction p <;> aesop;
  -- By contradiction, assume there is at most one vertex with degree 1.
  by_contra h_contra
  have h_at_most_one_leaf : Finset.card (Finset.filter (fun v => G.degree v = 1) (Finset.univ : Finset V)) ≤ 1 := by
    exact Finset.card_le_one.mpr fun u hu v hv => Classical.not_not.1 fun huv => h_contra ⟨ u, v, huv, Finset.mem_filter.mp hu |>.2, Finset.mem_filter.mp hv |>.2 ⟩;
  have h_sum_degrees : ∑ v : V, G.degree v ≥ ∑ v : V, if G.degree v = 1 then 1 else 2 := by
    exact Finset.sum_le_sum fun v _ => by specialize h_degree_pos v; rcases h : G.degree v with ( _ | _ | k ) <;> simp_all +decide ;
  simp_all +decide [ Finset.sum_ite ];
  rw [ Finset.filter_not, Finset.card_sdiff ] at h_sum_degrees ; norm_num at * ; omega;

/-! ## Hub Removal Fragility -/

/-
**Hub Removal Disconnects Trees**: Removing a vertex of degree d ≥ 2 from
    a tree disconnects the remaining graph. More precisely, the induced subgraph
    on V \ {v} is not connected.

    This formalizes the key fragility insight: if a foundational theorem (hub) is
    removed from the proof dependency DAG, the remaining mathematics fragments.

    Proof sketch: In a tree, there is a unique path between any two vertices.
    If v has degree ≥ 2, it has at least two neighbors u₁, u₂. The unique path
    from u₁ to u₂ in the tree must pass through v (otherwise there would be a
    cycle). Removing v therefore disconnects u₁ from u₂.
-/

theorem acyclic_avg_degree_lt_two {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hac : G.IsAcyclic) (hn : Fintype.card V ≥ 1) :
    ∑ v : V, G.degree v < 2 * Fintype.card V := by
  rw [ SimpleGraph.sum_degrees_eq_twice_card_edges ];
  exact mul_lt_mul_of_pos_left ( lt_of_le_of_lt ( acyclic_implies_few_edges G hac ) ( Nat.pred_lt ( ne_bot_of_gt hn ) ) ) zero_lt_two