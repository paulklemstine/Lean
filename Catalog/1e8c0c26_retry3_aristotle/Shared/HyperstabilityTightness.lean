import Mathlib

/-!
# Hyperstability tightness of `K_{t,t}` for the edge-deletion bound

This file proves that the balanced complete bipartite graph `K_{t,t}`, modeled as
`SimpleGraph.completeEquipartiteGraph 2 t`, is tight for the edge-deletion bound in a
hyperstability version of an Erdős–Gallai type extremal statement.

## Main results

* `card_edges_le_of_vertex_cover` (Lemma A): a graph with a vertex cover of size `k` on `n`
  vertices has at most `k * n` edges.
* `card_edges_le_of_small_component_covers` (Lemma B): if every connected component of `G` has a
  vertex cover of size at most `k`, then `G` has at most `k * n` edges.
* `hyperstability_tightness` (Main theorem): for `t = 2 (1 + 2c) d` and `n = 2t`, any subgraph
  `H ≤ K_{t,t}` all of whose connected components have a vertex cover of size at most `(1+c) d`
  requires at least `c * d * n` edge deletions from `K_{t,t}`.
-/

open SimpleGraph Finset

namespace HyperstabilityTightness

/-
**Lemma A.** If `C` is a vertex cover of a finite simple graph `G` on `n` vertices, then `G`
has at most `C.card * n` edges.
-/
theorem card_edges_le_of_vertex_cover {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj]
    (C : Finset α) (hC : G.IsVertexCover (C : Set α)) :
    G.edgeFinset.card ≤ C.card * Fintype.card α := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.biUnion C fun v => Finset.image ( fun w => Sym2.mk ( v, w ) ) ( Finset.univ : Finset α );
  · intro e he; simp_all +decide;
    rcases e with ⟨ a, b ⟩ ; specialize hC ( G.mem_edgeSet.mp he ) ; aesop;
  · exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => Finset.card_image_le.trans ( by simp +decide ) )

/-
**Lemma B.** If every connected component of a finite simple graph `G` on `n` vertices has a
vertex cover of size at most `k`, then `G` has at most `k * n` edges.
-/
theorem card_edges_le_of_small_component_covers {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] {k : ℕ}
    (h : ∀ (C : G.ConnectedComponent), ∃ (S : Finset C.supp), S.card ≤ k ∧
        (G.induce C.supp).IsVertexCover (S : Set C.supp)) :
    G.edgeFinset.card ≤ k * Fintype.card α := by
  have h_card : ∀ C : G.ConnectedComponent, (G.induce C.supp).edgeFinset.card ≤ k * Fintype.card C.supp := by
    intro C
    obtain ⟨S, hS_card, hS_cover⟩ := h C
    have h_card : (G.induce C.supp).edgeFinset.card ≤ S.card * Fintype.card C.supp := by
      convert card_edges_le_of_vertex_cover ( G.induce C.supp ) S hS_cover using 1;
    exact h_card.trans ( Nat.mul_le_mul_right _ hS_card );
  have h_sum : G.edgeFinset.card ≤ ∑ C : G.ConnectedComponent, (G.induce C.supp).edgeFinset.card := by
    have h_sum : G.edgeFinset ⊆ Finset.biUnion (Finset.univ : Finset G.ConnectedComponent) (fun C => Finset.image (fun e => e.map (Function.Embedding.subtype _)) (G.induce C.supp).edgeFinset) := by
      intro e he; simp_all +decide;
      rcases e with ⟨ u, v ⟩ ; simp_all +decide [ SimpleGraph.edgeSet ] ;
      refine' ⟨ G.connectedComponentMk u, Sym2.mk ( ⟨ u, _ ⟩, ⟨ v, _ ⟩ ), _, _ ⟩ <;> simp_all +decide;
      exact he.symm.reachable;
    exact le_trans ( Finset.card_le_card h_sum ) ( Finset.card_biUnion_le.trans ( Finset.sum_le_sum fun _ _ => Finset.card_image_le ) );
  refine' le_trans h_sum ( le_trans ( Finset.sum_le_sum fun C _ => h_card C ) _ );
  simp +decide only [Fintype.card_subtype];
  rw [ ← Finset.mul_sum _ _ _ ];
  rw [ ← Finset.card_biUnion ];
  · exact Nat.mul_le_mul_left _ ( Finset.card_le_univ _ );
  · intro C _ D _ hCD; simp_all +decide [Finset.disjoint_left];

/-
**Main theorem: hyperstability tightness.** For `t = 2 (1 + 2c) d` and `n = 2t`, any subgraph
`H ≤ K_{t,t}` all of whose connected components admit a vertex cover of size at most `(1+c) d`
requires at least `c * d * n` edge deletions from `K_{t,t}`.

The hypotheses `hd : d ≥ 3`, `hd_odd : Odd d` and `hc : c > 0` are kept as part of the intended
Erdős–Gallai setup (they specify the regime of the extremal construction), but the edge-deletion
bound itself holds for the stated arithmetic relation `t = 2 (1 + 2c) d` and does not require them.
-/
theorem hyperstability_tightness (t d c : ℕ) (hd : d ≥ 3) (hd_odd : Odd d) (hc : c > 0)
    (ht : t = 2 * (1 + 2 * c) * d) :
    ∀ (H : SimpleGraph (Fin 2 × Fin t)) [DecidableRel H.Adj]
      (_hH : H ≤ completeEquipartiteGraph 2 t)
      (_hH_covers : ∀ (C : H.ConnectedComponent),
        ∃ (S : Finset C.supp), S.card ≤ (1 + c) * d ∧
          (H.induce C.supp).IsVertexCover (S : Set C.supp)),
      (completeEquipartiteGraph 2 t).edgeFinset.card - H.edgeFinset.card ≥ c * d * (2 * t) := by
  intros H _ hH _hH_covers
  have hE2 : (completeEquipartiteGraph 2 t).edgeFinset.card = t^2 := by
    convert SimpleGraph.card_edgeFinset_completeEquipartiteGraph using 1
    simp [Nat.choose]
  have hA : H.edgeFinset.card ≤ (1 + c) * d * (2 * t) := by
    convert card_edges_le_of_small_component_covers H _hH_covers using 1 ; norm_num [ mul_assoc, mul_comm, mul_left_comm ]
  have hB : c * d * (2 * t) = t^2 - (1 + c) * d * (2 * t) := by
    exact eq_tsub_of_add_eq <| by subst ht; ring;
  omega

end HyperstabilityTightness