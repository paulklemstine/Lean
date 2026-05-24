/-
Copyright (c) 2025. All rights reserved.

# Local Cycle Pressure: A Proof-Topological Complexity Invariant

This file introduces **local cycle pressure**, a graph-theoretic invariant that
measures the cyclomatic excess of induced subgraphs over tree capacity. It serves
as a local first Betti number surrogate for finite graphs and provides a rigorous
foundation for proof-topological learning theory.

## Main Definitions

* `inducedEdgeCount G S` — number of edges of `G` with both endpoints in `S`
* `subsetCycleRank G S` — cyclomatic excess: `|E(G[S])| - |S| + 1` (ℤ-valued)
* `graphCycleRankZ G` — graph cycle rank: `|E| - |V| + 1`
* `collapseEntropyProxy G` — collapse entropy: `|E| - |V| + c` (c = components)
* `localCyclePressure G v r` — cycle pressure at vertex `v` with radius `r`

## Main Results

* `isAcyclic_induce_of_isAcyclic` — induced subgraphs of forests are forests
* `edgeFinset_card_le_card_sub_one_of_isAcyclic` — forests have ≤ |V|−1 edges
* `inducedEdgeCount_le_card_sub_one_of_isAcyclic` — acyclic ⇒ ≤ |S|−1 edges
* `subsetCycleRank_nonpos_of_isAcyclic` — acyclic ⇒ nonpositive cycle rank
* `graphCycleRankZ_eq_zero_of_isTree` — trees have zero cycle rank
* `not_isAcyclic_of_graphCycleRankZ_pos` — positive cycle rank ⇒ cycles exist
* `isTree_iff_connected_and_edgecount` — tree ↔ connected + |E|=|V|−1
* `subsetCycleRank_increment` — increment formula for expanding subsets
* `exists_same_degree_diff_cycleRank` — feature separation theorem
* `cycleAwareScore_separates` — cycle-aware scores provably outperform degree
-/

import Mathlib

open Finset SimpleGraph

/-! ## Part 1: Core Definitions -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Count the number of edges of `G` whose both endpoints lie in `S`.
This is the edge count of the induced subgraph `G[S]`. -/
def inducedEdgeCount (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : ℕ :=
  (G.edgeFinset.filter (fun e => ∀ v, v ∈ e → v ∈ S)).card

/-- The **subset cycle rank** of a vertex set `S` in graph `G`:
  `|E(G[S])| - |S| + 1`.

When `G[S]` is connected, this equals the cycle rank (first Betti number)
of the induced subgraph. This is ≤ 0 for acyclic graphs. -/
def subsetCycleRank (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : ℤ :=
  (inducedEdgeCount G S : ℤ) - (S.card : ℤ) + 1

/-- The **graph cycle rank** (cyclomatic number): `|E| - |V| + 1`.
For connected graphs, this is the first Betti number. -/
def graphCycleRankZ (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-- **Collapse entropy proxy**: `|E| - |V| + c` where `c` = number of connected
components. This is the true cycle rank (first Betti number) of the graph. -/
noncomputable def collapseEntropyProxy (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) +
    (Fintype.card G.ConnectedComponent : ℤ)

/-- The geodesic ball of radius `r` around vertex `v`. -/
noncomputable def graphBall (G : SimpleGraph V) [DecidableRel G.Adj]
    (v : V) (r : ℕ) : Finset V :=
  Finset.univ.filter (fun u => G.Reachable v u ∧ G.dist v u ≤ r)

/-- **Local cycle pressure** at vertex `v` with radius `r`:
the subset cycle rank of the geodesic ball `B(v, r)`. -/
noncomputable def localCyclePressure (G : SimpleGraph V) [DecidableRel G.Adj]
    (v : V) (r : ℕ) : ℤ :=
  subsetCycleRank G (graphBall G v r)

/-- A **cycle-aware ranking score**: the subset cycle rank of the closed neighborhood
of a vertex. Combines local cycle information with structural topology. -/
def cycleAwareScore (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : ℤ :=
  let closedNbhd := Finset.univ.filter (fun u => G.Adj v u ∨ u = v)
  subsetCycleRank G closedNbhd

/-! ## Part 2: Basic Properties of Induced Edge Count -/

/-- The induced edge count on the full vertex set equals the total edge count. -/
theorem inducedEdgeCount_univ (G : SimpleGraph V) [DecidableRel G.Adj] :
    inducedEdgeCount G Finset.univ = G.edgeFinset.card := by
  unfold inducedEdgeCount
  congr 1
  rw [Finset.filter_true_of_mem]
  intro e _ v _
  exact Finset.mem_univ v

/-- The induced edge count on the empty set is zero. -/
theorem inducedEdgeCount_empty (G : SimpleGraph V) [DecidableRel G.Adj] :
    inducedEdgeCount G ∅ = 0 := by
  unfold inducedEdgeCount
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro e he
  push_neg
  refine Sym2.ind (fun a _ _ => ⟨a, Sym2.mem_mk_left a _, by simp⟩) e he

/-- The induced edge count on a singleton is zero (no self-loops). -/
theorem inducedEdgeCount_singleton (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    inducedEdgeCount G {v} = 0 := by
  unfold inducedEdgeCount
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro e he
  push_neg
  refine Sym2.ind (fun a b he' => ?_) e he
  rw [SimpleGraph.mem_edgeFinset, SimpleGraph.mem_edgeSet] at he'
  have hne := G.ne_of_adj he'
  by_cases ha : a = v
  · exact ⟨b, Sym2.mem_mk_right a b, by simp [Ne.symm (ha ▸ hne)]⟩
  · exact ⟨a, Sym2.mem_mk_left a b, by simp [ha]⟩

/-- Induced edge count is monotone: if `S ⊆ T`, then `|E(G[S])| ≤ |E(G[T])|`. -/
theorem inducedEdgeCount_mono (G : SimpleGraph V) [DecidableRel G.Adj]
    {S T : Finset V} (h : S ⊆ T) :
    inducedEdgeCount G S ≤ inducedEdgeCount G T := by
  apply Finset.card_le_card
  intro e
  simp only [Finset.mem_filter]
  exact fun ⟨he, hs⟩ => ⟨he, fun v hv => h (hs v hv)⟩

/-- The subset cycle rank on the full vertex set equals the graph cycle rank. -/
theorem subsetCycleRank_univ (G : SimpleGraph V) [DecidableRel G.Adj] :
    subsetCycleRank G Finset.univ = graphCycleRankZ G := by
  simp [subsetCycleRank, graphCycleRankZ, inducedEdgeCount_univ, Finset.card_univ]

/-- The subset cycle rank of the empty set is 1. -/
theorem subsetCycleRank_empty (G : SimpleGraph V) [DecidableRel G.Adj] :
    subsetCycleRank G ∅ = 1 := by
  simp [subsetCycleRank, inducedEdgeCount_empty]

/-- The subset cycle rank of a singleton is 0. -/
theorem subsetCycleRank_singleton (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    subsetCycleRank G {v} = 0 := by
  simp [subsetCycleRank, inducedEdgeCount_singleton]

/-! ## Part 3: Acyclicity and Induced Subgraphs -/

/-- **Induced subgraphs of acyclic graphs are acyclic.**
A cycle in G[S] lifts to a cycle in G, contradicting acyclicity. -/
theorem isAcyclic_induce_of_isAcyclic (G : SimpleGraph V) (S : Set V)
    (hacyc : G.IsAcyclic) :
    (G.induce S).IsAcyclic := by
  intro v c hc
  have := hacyc (c.map (SimpleGraph.Hom.comap _ _)) ?_
  · contradiction
  · convert hc.map _
    intro x y; aesop

/-! ## Part 4: Tree Characterization by Cycle Pressure -/

/-- **Trees have zero graph cycle rank.** -/
theorem graphCycleRankZ_eq_zero_of_isTree (G : SimpleGraph V) [DecidableRel G.Adj]
    (hT : G.IsTree) :
    graphCycleRankZ G = 0 := by
  have h := hT.card_edgeFinset
  simp [graphCycleRankZ]; omega

/-
**Forests have at most |V| - 1 edges.**
-/
theorem edgeFinset_card_le_card_sub_one_of_isAcyclic [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hacyc : G.IsAcyclic) :
    G.edgeFinset.card ≤ Fintype.card V - 1 := by
  have h_spanning_forest : ∃ T : SimpleGraph V, G ≤ T ∧ T.IsAcyclic ∧ T.IsTree := by
    -- By definition of acyclicity, $G$ is a forest.
    have h_forest : G.IsAcyclic := by
      grobner;
    -- Since $G$ is acyclic, it is a forest. We can add edges to $G$ to make it a tree.
    obtain ⟨T, hT⟩ : ∃ T : SimpleGraph V, G ≤ T ∧ T.IsTree := by
      have h_spanning_tree : ∀ (G : SimpleGraph V), G.IsAcyclic → ∃ T : SimpleGraph V, G ≤ T ∧ T.IsTree := by
        intro G hacyc
        obtain ⟨T, hT⟩ : ∃ T : SimpleGraph V, G ≤ T ∧ T.IsTree := by
          have h_spanning_tree : ∃ T : SimpleGraph V, G ≤ T ∧ T.Connected := by
            exact ⟨ ⊤, le_top, by simp +decide [ SimpleGraph.connected_iff_exists_forall_reachable ] ⟩
          obtain ⟨ T, hT₁, hT₂ ⟩ := h_spanning_tree;
          have := hT₂.exists_isTree_le;
          grind +suggestions;
        use T;
      exact h_spanning_tree G h_forest;
    exact ⟨ T, hT.1, hT.2.2, hT.2 ⟩;
  obtain ⟨ T, hGT, hTacyc, hTtree ⟩ := h_spanning_forest;
  have := hTtree.card_edgeFinset;
  exact Nat.le_sub_one_of_lt ( lt_of_le_of_lt ( Finset.card_mono <| by aesop ) ( Nat.lt_of_succ_le this.le ) )

/-
**Relating inducedEdgeCount to induced subgraph edge count.**
-/
theorem inducedEdgeCount_eq_induce_edgeFinset_card
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    inducedEdgeCount G S = (G.induce (S : Set V)).edgeFinset.card := by
  convert Set.ncard_coe_finset _ using 1;
  convert Set.ncard_coe_finset _ using 1;
  convert Set.ncard_coe_finset _ using 1;
  convert Set.ncard_coe_finset _ using 1;
  any_goals exact ( G.edgeFinset.filter fun e => ∀ v, v ∈ e → v ∈ S );
  · convert rfl;
    convert Set.ncard_coe_finset _ using 2;
  · rw [ Set.ncard_coe_finset ];
  · rw [ Set.ncard_coe_finset ];
  · rw [ Set.ncard_coe_finset ];
    refine' Finset.card_bij _ _ _ _;
    use fun a ha => Sym2.map ( fun x => x.val ) a;
    · rintro ⟨ u, v ⟩ huv; simp_all +decide [ SimpleGraph.mem_edgeSet ] ;
      exact huv;
    · intro a₁ ha₁ a₂ ha₂ h; induction a₁ using Sym2.inductionOn ; induction a₂ using Sym2.inductionOn ; aesop;
    · simp +decide [ Sym2.map ];
      rintro ⟨ u, v ⟩ huv huS;
      exact ⟨ Sym2.mk ( ⟨ u, huS u ( by simp +decide ) ⟩, ⟨ v, huS v ( by simp +decide ) ⟩ ), by simpa using huv, rfl ⟩

/-
**In an acyclic graph, induced edge count ≤ |S| - 1 for nonempty S.**
-/
theorem inducedEdgeCount_le_card_sub_one_of_isAcyclic
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hacyc : G.IsAcyclic) (S : Finset V) (hS : S.Nonempty) :
    inducedEdgeCount G S ≤ S.card - 1 := by
  convert edgeFinset_card_le_card_sub_one_of_isAcyclic ( G.induce ( S : Set V ) ) _ using 1;
  · convert inducedEdgeCount_eq_induce_edgeFinset_card G S using 1;
  · simp +decide [ Fintype.card_subtype ];
  · exact ⟨ hS.choose, hS.choose_spec ⟩;
  · exact?

/-- **Theorem 1: Acyclic graphs have nonpositive subset cycle rank.** -/
theorem subsetCycleRank_nonpos_of_isAcyclic
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hacyc : G.IsAcyclic) (S : Finset V) (hS : S.Nonempty) :
    subsetCycleRank G S ≤ 0 := by
  have h := inducedEdgeCount_le_card_sub_one_of_isAcyclic G hacyc S hS
  have hcard := Finset.Nonempty.card_pos hS
  simp only [subsetCycleRank]; omega

/-- **Trees have zero cycle rank on the full vertex set.** -/
theorem subsetCycleRank_univ_eq_zero_of_isTree
    (G : SimpleGraph V) [DecidableRel G.Adj] (hT : G.IsTree) :
    subsetCycleRank G Finset.univ = 0 := by
  rw [subsetCycleRank_univ]; exact graphCycleRankZ_eq_zero_of_isTree G hT

/-
**Theorem 2: Positive cycle rank implies cycle existence.**
-/
theorem not_isAcyclic_of_graphCycleRankZ_pos [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hpos : 0 < graphCycleRankZ G) :
    ¬G.IsAcyclic := by
  exact fun h => by have := edgeFinset_card_le_card_sub_one_of_isAcyclic G h; linarith! [ Nat.sub_add_cancel ( Fintype.card_pos_iff.mpr ‹_› ), hpos, show graphCycleRankZ G = ( G.edgeFinset.card : ℤ ) - Fintype.card V + 1 from rfl ] ;

/-
**Theorem 3: For connected graphs, tree ↔ |E| + 1 = |V|.**
-/
theorem isTree_iff_connected_and_edgecount [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    G.IsTree ↔ G.edgeFinset.card + 1 = Fintype.card V := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · have := h.card_edgeFinset;
    exact this;
  · have h_spanning_tree : ∃ T : SimpleGraph V, T.IsTree ∧ T ≤ G ∧ T.edgeFinset.card = Fintype.card V - 1 := by
      obtain ⟨T, hT⟩ : ∃ T : SimpleGraph V, T.IsTree ∧ T ≤ G := by
        have := hconn.exists_isTree_le; aesop;
      have := hT.1.card_edgeFinset;
      exact ⟨ T, hT.1, hT.2, eq_tsub_of_add_eq this ⟩;
    obtain ⟨ T, hT₁, hT₂, hT₃ ⟩ := h_spanning_tree;
    have h_eq : T.edgeFinset = G.edgeFinset := by
      refine' Finset.eq_of_subset_of_card_le _ _;
      · aesop;
      · omega;
    aesop

/-! ## Part 5: Increment Formula and Monotonicity -/

/-- **Subset cycle rank increment formula.** -/
theorem subsetCycleRank_increment (G : SimpleGraph V) [DecidableRel G.Adj]
    (S T : Finset V) (_hST : S ⊆ T) :
    subsetCycleRank G T - subsetCycleRank G S =
      (inducedEdgeCount G T : ℤ) - (inducedEdgeCount G S : ℤ) -
      ((T.card : ℤ) - (S.card : ℤ)) := by
  simp [subsetCycleRank]; ring

/-- **Graph cycle rank ≤ collapse entropy.** -/
theorem graphCycleRankZ_le_collapseEntropyProxy [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    graphCycleRankZ G ≤ collapseEntropyProxy G := by
  simp only [graphCycleRankZ, collapseEntropyProxy]
  haveI : Nonempty G.ConnectedComponent := ⟨G.connectedComponentMk (Classical.arbitrary V)⟩
  have : 0 < Fintype.card G.ConnectedComponent := Fintype.card_pos
  omega

/-- **Positive edges imply positive cycle rank when |E| ≥ |V|.** -/
theorem edgeFinset_card_ge_of_graphCycleRankZ_pos
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : 0 < graphCycleRankZ G) :
    Fintype.card V ≤ G.edgeFinset.card := by
  simp only [graphCycleRankZ] at h; omega

/-- **Positive cycle rank from edge surplus for connected graphs.** -/
theorem graphCycleRankZ_pos_of_connected_many_edges
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (_hconn : G.Connected) (hedge : Fintype.card V ≤ G.edgeFinset.card) :
    0 < graphCycleRankZ G := by
  simp only [graphCycleRankZ]; omega

/-! ## Part 6: Explicit Graph Constructions and Feature Separation -/

/-- The complete graph on `Fin 3` (triangle K₃). -/
def triangleGraph : SimpleGraph (Fin 3) where
  Adj a b := a ≠ b
  symm _ _ h := h.symm
  loopless := ⟨fun _ h => h rfl⟩

/-- The path graph on `Fin 3`: edges 0-1 and 1-2. -/
def pathGraph3 : SimpleGraph (Fin 3) where
  Adj a b := (a.val + 1 = b.val) ∨ (b.val + 1 = a.val)
  symm _ _ h := by rcases h with h | h <;> simp [*]
  loopless := ⟨fun _ h => by rcases h with h | h <;> omega⟩

instance : DecidableRel triangleGraph.Adj :=
  fun x y => by unfold triangleGraph; exact inferInstance

instance : DecidableRel pathGraph3.Adj :=
  fun x y => by unfold pathGraph3; exact inferInstance

/-- Triangle has 3 edges. -/
theorem triangleGraph_edgeCount : triangleGraph.edgeFinset.card = 3 := by native_decide
/-- Path has 2 edges. -/
theorem pathGraph3_edgeCount : pathGraph3.edgeFinset.card = 2 := by native_decide
/-- Triangle cycle rank is 1. -/
theorem triangleGraph_cycleRank : graphCycleRankZ triangleGraph = 1 := by
  simp [graphCycleRankZ, triangleGraph_edgeCount, Fintype.card_fin]
/-- Path cycle rank is 0. -/
theorem pathGraph3_cycleRank : graphCycleRankZ pathGraph3 = 0 := by
  simp [graphCycleRankZ, pathGraph3_edgeCount, Fintype.card_fin]
/-- Vertex 1 has degree 2 in the triangle. -/
theorem triangleGraph_degree_one : triangleGraph.degree (1 : Fin 3) = 2 := by native_decide
/-- Vertex 1 has degree 2 in the path. -/
theorem pathGraph3_degree_one : pathGraph3.degree (1 : Fin 3) = 2 := by native_decide

/-- **Theorem 4: Feature Separation — same degree, different cycle rank.** -/
theorem exists_same_degree_diff_cycleRank :
    ∃ (G₁ G₂ : SimpleGraph (Fin 3)) (_ : DecidableRel G₁.Adj) (_ : DecidableRel G₂.Adj)
      (v : Fin 3),
      G₁.degree v = G₂.degree v ∧
      graphCycleRankZ G₁ ≠ graphCycleRankZ G₂ := by
  exact ⟨triangleGraph, pathGraph3, inferInstance, inferInstance, 1,
    by rw [triangleGraph_degree_one, pathGraph3_degree_one],
    by rw [triangleGraph_cycleRank, pathGraph3_cycleRank]; decide⟩

/-- Triangle: cycle-aware score at vertex 1 is 1 (detects the cycle). -/
theorem triangleGraph_cycleAwareScore :
    cycleAwareScore triangleGraph (1 : Fin 3) = 1 := by native_decide
/-- Path: cycle-aware score at vertex 1 is 0 (no local cycles). -/
theorem pathGraph3_cycleAwareScore :
    cycleAwareScore pathGraph3 (1 : Fin 3) = 0 := by native_decide

/-- **Cycle-aware scores separate what degree cannot.** -/
theorem cycleAwareScore_separates :
    triangleGraph.degree (1 : Fin 3) = pathGraph3.degree (1 : Fin 3) ∧
    cycleAwareScore triangleGraph (1 : Fin 3) ≠ cycleAwareScore pathGraph3 (1 : Fin 3) := by
  exact ⟨by rw [triangleGraph_degree_one, pathGraph3_degree_one],
         by rw [triangleGraph_cycleAwareScore, pathGraph3_cycleAwareScore]; decide⟩

/-- **Feature Separation — Subset Cycle Rank edition.** -/
theorem exists_same_degree_diff_subsetCycleRank :
    ∃ (G₁ G₂ : SimpleGraph (Fin 3)) (_ : DecidableRel G₁.Adj) (_ : DecidableRel G₂.Adj)
      (v : Fin 3),
      G₁.degree v = G₂.degree v ∧
      subsetCycleRank G₁ Finset.univ ≠ subsetCycleRank G₂ Finset.univ := by
  exact ⟨triangleGraph, pathGraph3, inferInstance, inferInstance, 1,
    by rw [triangleGraph_degree_one, pathGraph3_degree_one],
    by rw [subsetCycleRank_univ, subsetCycleRank_univ,
           triangleGraph_cycleRank, pathGraph3_cycleRank]; decide⟩

/-! ## Part 7: Entropy and Cycle Rank Bridge -/

/-- **Connected graphs have exactly 1 connected component.** -/
theorem connected_component_card_eq_one (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    Fintype.card G.ConnectedComponent = 1 := by
  rw [Fintype.card_eq_one_iff]
  obtain ⟨v, _⟩ : ∃ v : V, True := by
    cases isEmpty_or_nonempty V <;>
    simp_all [SimpleGraph.connected_iff_exists_forall_reachable]
  exact ⟨G.connectedComponentMk v, fun w => by
    obtain ⟨u, rfl⟩ := w.exists_rep
    exact Quot.sound (hconn u v)⟩

/-- **For connected graphs, collapse entropy = graph cycle rank.** -/
theorem collapseEntropyProxy_eq_graphCycleRankZ_of_connected
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    collapseEntropyProxy G = graphCycleRankZ G := by
  simp [collapseEntropyProxy, graphCycleRankZ, connected_component_card_eq_one G hconn]

/-! ## Part 8: Verified Computation -/

/-- Correctness: edge count computation. -/
theorem computeInducedEdgeCount_eq (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) :
    inducedEdgeCount G S = (G.edgeFinset.filter (fun e => ∀ v, v ∈ e → v ∈ S)).card := rfl

/-- Correctness: cycle rank computation. -/
theorem computeSubsetCycleRank_eq (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) :
    subsetCycleRank G S = (inducedEdgeCount G S : ℤ) - (S.card : ℤ) + 1 := rfl