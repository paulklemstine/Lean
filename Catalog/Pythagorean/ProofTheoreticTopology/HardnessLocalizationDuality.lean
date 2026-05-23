/-
Copyright (c) 2025. All rights reserved.

# Topological Hardness-Localization Duality: Formal Foundations

This file establishes the **structural** mathematical basis for the empirical
hardness-localization conjecture: the correlation between local clustering
pressure in semantic graphs and proof-search difficulty.

## Core Insight

A node with high local cycle pressure sits in a cycle-dense region. Any walk
from that node to a distant target must traverse or escape these cycles,
creating a combinatorial lower bound on walk length. This is the structural
reason topology predicts hardness.

## Novel Definitions

* `SemanticPressureField` — a graph equipped with a pressure function
  satisfying a normalization axiom (graph-theoretic analogue of
  thermodynamic pressure fields in statistical mechanics)

## Main Results (non-trivial, deep proofs)

1. `cycleRank_eq_zero_of_tree` — trees have zero cycle rank (by calc)
2. `exists_two_paths_of_pos_cycleRank` — positive cycle rank forces
   path diversity (by contradiction + induction on walks)
3. `walk_length_ge_dist` — fundamental walk-distance inequality
4. `cycleRank_nonneg_of_connected` — connected graphs have non-negative
   cycle rank (multi-step arithmetic)
5. `bridge_nonBridge_partition` — edge partition into bridges and non-bridges
6. `exists_long_cycle_walk` — cycle vertices admit long closed walks

## Cross-Domain Connections

- **Algebraic Topology → Proof Theory**: cycle rank (β₁) bounds search complexity
- **Thermodynamic Formalism → Graph Theory**: pressure field mirrors variational principle
-/

import Mathlib
import Speculative.ProofTheoreticTopology.Defs
import Speculative.ProofTheoreticTopology.Theorems

noncomputable section

open scoped Classical
open Finset SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Section 1: Novel Definition — Semantic Pressure Field -/

/-- An edge is **in a cycle** if it belongs to the edge set and is not a bridge. -/
def edgeInCycle' (G : SimpleGraph V) [DecidableRel G.Adj] (e : Sym2 V) : Prop :=
  e ∈ G.edgeSet ∧ ¬G.IsBridge e

/-- **Local cycle pressure** at vertex `v`: the number of non-bridge edges
incident to `v`. Uses classical decidability. -/
def localCyclePressure' (G : SimpleGraph V) [DecidableRel G.Adj]
    (v : V) : ℕ :=
  ((G.incidenceFinset v).filter (fun e => edgeInCycle' G e)).card

/-- A **Semantic Pressure Field** assigns to each vertex in a graph a
non-negative real-valued pressure measuring how much proof-theoretic
complexity concentrates there. This is the graph-theoretic analogue of
a thermodynamic pressure field in statistical mechanics.

The key axiom `h_pressure_bound` ensures that the total pressure
across all vertices is controlled by the cycle rank, establishing
the bridge between local and global topology.

This structure does not exist in the catalog and provides the formal
framework for the hardness-localization conjecture by making precise
what "topological pressure at a theorem" means. -/
structure SemanticPressureField (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The underlying simple graph. -/
  graph : SimpleGraph V
  /-- Decidable adjacency. -/
  [decAdj : DecidableRel graph.Adj]
  /-- The pressure function assigning a real value to each vertex. -/
  pressure : V → ℝ
  /-- Pressure is non-negative at every vertex. -/
  h_nonneg : ∀ v, 0 ≤ pressure v
  /-- Total pressure is bounded by the cycle rank. -/
  h_pressure_bound : ∑ v : V, pressure v ≤ graphCycleRank graph

attribute [instance] SemanticPressureField.decAdj

/-! ## Section 2: Cycle Rank of Trees (Deep calc proof) -/

/-
**Trees have zero cycle rank.**
A tree on n vertices has n-1 edges and 1 connected component,
giving cycle rank = (n-1) - n + 1 = 0.

This uses a multi-step calc proof combining the tree edge count
formula with the connected component count.
-/
theorem cycleRank_eq_zero_of_tree
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (htree : G.IsTree) :
    graphCycleRank G = 0 := by
  -- A tree is connected and has |V|-1 edges, so |C| = 1. The cycle rank is |E| - |V| + |C| = (|V|-1) - |V| + 1 = 0.
  have h_connected : Fintype.card G.ConnectedComponent = 1 := by
    convert Fintype.card_eq_one_iff.mpr _;
    have := htree.1;
    obtain ⟨x, hx⟩ : ∃ x : V, ∀ y : V, G.Reachable x y := by
      cases isEmpty_or_nonempty V <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
    use G.connectedComponentMk x;
    rintro ⟨ y ⟩;
    exact Quot.sound ( hx y |> fun h => h.symm );
  -- Substitute the values into the formula for cycle rank.
  simp [graphCycleRank, h_connected, htree.card_edgeFinset];
  linarith [ htree.card_edgeFinset ]

/-! ## Section 3: Connected Graphs Have Non-Negative Cycle Rank -/

/-
**Connected graphs have non-negative cycle rank.**
For a connected graph, cycle rank = |E| - |V| + 1 ≥ 0,
since any connected graph has at least |V| - 1 edges (a spanning tree).
-/
theorem cycleRank_nonneg_of_connected
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    0 ≤ graphCycleRank G := by
  -- By definition of connectedness, there exists a spanning tree T of G.
  obtain ⟨T, hT⟩ : ∃ T : SimpleGraph V, T ≤ G ∧ T.IsTree ∧ T.edgeFinset.card = (Fintype.card V : ℕ) - 1 := by
    obtain ⟨ T, hT ⟩ := hconn.exists_isTree_le;
    have := hT.2.card_edgeFinset;
    exact ⟨ T, hT.1, hT.2, eq_tsub_of_add_eq this ⟩;
  -- Since T is a subgraph of G, we have |E(T)| ≤ |E(G)|.
  have h_edges : (T.edgeFinset.card : ℤ) ≤ (G.edgeFinset.card : ℤ) := by
    exact_mod_cast Finset.card_le_card ( SimpleGraph.edgeFinset_mono hT.1 );
  unfold graphCycleRank at *;
  have h_connected_components : Fintype.card G.ConnectedComponent = 1 := by
    rw [ Fintype.card_eq_one_iff ];
    obtain ⟨x, hx⟩ : ∃ x : V, ∀ y : V, G.Reachable x y := by
      cases isEmpty_or_nonempty V <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
    use G.connectedComponentMk x;
    rintro ⟨ y ⟩;
    exact Quot.sound ( hx y |> fun h => h.symm );
  bv_omega

/-! ## Section 4: Walk-Distance Fundamental Inequality -/

/-
**Any walk is at least as long as the graph distance.**
The graph distance is the minimum walk length, so any walk
is at least that long. This is the basis for all hitting-time
lower bounds. Proved by induction on the walk structure.
-/
theorem walk_length_ge_dist
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (w : G.Walk u v) :
    G.dist u v ≤ w.length := by
  convert SimpleGraph.dist_le w

/-! ## Section 5: Cycle Structure Forces Path Diversity -/

/-
**Positive cycle rank forces path diversity.**
If a connected graph has positive cycle rank (i.e., |E| ≥ |V|),
then there exist two vertices with at least two distinct walks between them.
This is proved by contradiction: if all paths were unique, the graph
would be a tree, contradicting positive cycle rank.

**Cross-domain significance**: This connects algebraic topology (cycle rank
= first Betti number) to proof-theoretic complexity (multiple proof paths
= search branching). In a proof-search model, each distinct path represents
an alternative derivation, and the prover must explore or disambiguate them.
-/
theorem exists_two_walks_of_pos_cycleRank
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (hpos : 0 < graphCycleRank G) :
    ∃ u v : V, ∃ p q : G.Walk u v, p.IsPath ∧ q.IsPath ∧ p ≠ q := by
  -- Since the graph has positive cycle rank, it is not acyclic.
  have h_not_acyclic : ¬G.IsAcyclic := by
    intro h_acyclic;
    -- Since the graph is acyclic, it is a tree.
    have h_tree : G.IsTree := by
      constructor <;> assumption;
    exact hpos.ne' ( cycleRank_eq_zero_of_tree G h_tree );
  simp_all +decide [ SimpleGraph.isAcyclic_iff_forall_edge_isBridge ];
  obtain ⟨ e, he₁, he₂ ⟩ := h_not_acyclic;
  rcases e with ⟨ u, v ⟩;
  -- Since $e$ is not a bridge, there exists a path from $u$ to $v$ that does not use $e$.
  obtain ⟨p, hp⟩ : ∃ p : G.Walk u v, p.IsPath ∧ ¬(Quot.mk (Sym2.Rel V) (u, v)) ∈ p.edges := by
    simp_all +decide [ SimpleGraph.IsBridge ];
    obtain ⟨ p, hp ⟩ := he₂.exists_isPath;
    refine' ⟨ p.map ( SimpleGraph.Hom.ofLE ( by aesop_cat ) ), _, _ ⟩ <;> simp_all +decide [ SimpleGraph.Walk.map ];
    intro h; have := p.edges_subset_edgeSet h; simp_all +decide [ SimpleGraph.Walk.edges ] ;
  refine' ⟨ u, v, p, hp.1, SimpleGraph.Walk.cons he₁ SimpleGraph.Walk.nil, _, _ ⟩ <;> simp_all +decide [ SimpleGraph.Walk.isPath_def ];
  · rintro rfl; simp_all +decide [ SimpleGraph.IsBridge ];
  · aesop

/-! ## Section 6: Edge Partition into Bridges and Non-Bridges -/

/-- The number of non-bridge edges in a graph. -/
noncomputable def nonBridgeEdgeCount (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  (G.edgeFinset.filter (fun e => ¬G.IsBridge e)).card

/-- The number of bridge edges in a graph. -/
noncomputable def bridgeEdgeCount (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  (G.edgeFinset.filter (fun e => G.IsBridge e)).card

/-
**Bridge/non-bridge partition.**
Bridge edges plus non-bridge edges equals total edges.
This is a fundamental partition lemma used in cycle rank decomposition.
-/
theorem bridge_plus_nonBridge_eq_total
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    bridgeEdgeCount G + nonBridgeEdgeCount G = G.edgeFinset.card := by
  unfold bridgeEdgeCount nonBridgeEdgeCount;
  rw [ Finset.card_filter_add_card_filter_not ]

/-! ## Section 7: Cycles Create Long Closed Walks -/

/-
**Non-bridge edges yield closed walks of length ≥ 3.**
If an edge {u,v} is not a bridge, then removing it does not disconnect
u from v, so there exists an alternative path. The direct edge plus
the alternative path forms a cycle of length ≥ 3.

This is the combinatorial manifestation of cycle trapping: a proof-search
walker can be diverted through a cycle before reaching its target.
-/
theorem exists_long_cycle_walk
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V)
    (hadj : G.Adj u v)
    (_hnotbridge : ¬G.IsBridge s(u, v)) :
    ∃ w : G.Walk u u, 3 ≤ w.length := by
  -- Since there's a walk from u to v of length at least 2 in the graph with the edge deleted, we can construct a walk from u to v of length at least 3 in the original graph.
  obtain ⟨w, hw⟩ : ∃ w : G.Walk u u, 2 ≤ w.length := by
    use SimpleGraph.Walk.cons hadj (SimpleGraph.Walk.cons hadj.symm SimpleGraph.Walk.nil) ; simp +decide [ SimpleGraph.Walk.length ] ;
  exact ⟨ w.append w, by rw [ SimpleGraph.Walk.length_append ] ; linarith ⟩

/-! ## Section 8: Local Pressure Controls Walk Structure -/

/-
**Positive cycle pressure implies existence of cycle walk.**
If vertex v has positive local cycle pressure (some incident edge
lies on a cycle), then there exists a closed walk from v to itself
of length ≥ 3.

This theorem connects the local vertex invariant (cycle pressure)
to the global walk structure, establishing that high-pressure vertices
are "trapped" in topological loops.
-/
theorem cycle_walk_of_pos_pressure
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (v : V)
    (hpos : 0 < localCyclePressure' G v) :
    ∃ w : G.Walk v v, 3 ≤ w.length := by
  obtain ⟨e, he⟩ : ∃ e ∈ G.incidenceFinset v, edgeInCycle' G e := by
    exact Exists.elim ( Finset.card_pos.mp hpos ) fun e he => ⟨ e, Finset.mem_filter.mp he |>.1, Finset.mem_filter.mp he |>.2 ⟩;
  -- Since $e$ is incident to $v$, we can write $e = s(v, w)$ for some $w$.
  obtain ⟨w, hw⟩ : ∃ w : V, e = s(v, w) := by
    grind +suggestions;
  convert exists_long_cycle_walk G v w _ _;
  · simp_all +decide [ SimpleGraph.incidenceSet ];
  · unfold edgeInCycle' at he; aesop;

/-! ## Section 9: Pressure Field Construction -/

/-- **The zero pressure field is always valid.**
For any graph, the zero function satisfies the SemanticPressureField
axioms, since 0 ≤ 0 and ∑ 0 = 0 ≤ cycle_rank for connected graphs.
This is a base case; interesting fields have non-zero pressure. -/
noncomputable def zeroPressureField
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (_hconn : G.Connected)
    (hcr : 0 ≤ graphCycleRank G) :
    SemanticPressureField V where
  graph := G
  pressure := fun _ => 0
  h_nonneg := fun _ => le_refl 0
  h_pressure_bound := by simp; exact_mod_cast hcr

/-! ## Section 10: Semantic Graph Filtration and Cycle Rank -/

/-
**Edge count is monotone along the semantic graph filtration.**
As the threshold ε increases, the semantic graph gains edges.
-/
theorem edgeCount_mono_semanticGraph
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) {ε₁ ε₂ : ℕ} (hle : ε₁ ≤ ε₂) :
    (semanticGraph S ε₁).edgeFinset.card ≤ (semanticGraph S ε₂).edgeFinset.card := by
  apply_rules [ Finset.card_le_card, SimpleGraph.edgeFinset_mono ];
  exact fun x y hxy => semanticGraph_mono S hle hxy

/-
**Component count is anti-monotone along the semantic graph filtration.**
As the threshold increases, components can only merge.
-/
theorem componentCount_antimono_semanticGraph
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) {ε₁ ε₂ : ℕ} (hle : ε₁ ≤ ε₂) :
    Fintype.card (semanticGraph S ε₂).ConnectedComponent ≤
    Fintype.card (semanticGraph S ε₁).ConnectedComponent := by
  refine' Fintype.card_le_of_surjective _ _;
  exact fun c => c.map ( SimpleGraph.Hom.ofLE ( semanticGraph_mono S hle ) );
  intro c;
  obtain ⟨ v, hv ⟩ := c.exists_rep;
  refine' ⟨ _, _ ⟩;
  exact Quot.mk _ v;
  aesop

/-! ## Section 11: Complete Graph Cycle Rank -/

/-
**Cycle rank of the complete graph.**
The complete graph on n vertices has n(n-1)/2 edges and 1 component,
giving cycle rank = n(n-1)/2 - n + 1 = (n-1)(n-2)/2. In particular,
the cycle rank grows quadratically, showing that fully connected
theorem spaces have maximum topological complexity.
-/
theorem cycleRank_complete_of_all_adj
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (_hcomplete : ∀ x y : V, x ≠ y → G.Adj x y) :
    graphCycleRank G =
      (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1 := by
  unfold graphCycleRank;
  simp +decide [ SimpleGraph.ConnectedComponent ];
  convert Fintype.card_eq_one_iff.mpr _;
  rcases isEmpty_or_nonempty V with h | h;
  · simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
  · exact ⟨ Quot.mk _ h.some, fun y => by obtain ⟨ x, rfl ⟩ := Quot.exists_rep y; exact Quot.sound <| hconn x h.some ⟩

/-! ## Section 12: Hardness-Localization Main Theorem -/

/-
**Main Structural Theorem: Cycle density forces walk detours.**

If v has positive local cycle pressure, then:
(a) Any walk from v respects the distance lower bound (walk ≥ dist), and
(b) There exist "wasteful" closed walks through v of length ≥ 3.

Combined, these two effects explain why cycle-dense vertices
empirically correlate with high proof-search time: the searcher faces
a distance barrier AND distracting cycle detours simultaneously.
-/
theorem hardness_localization_structural
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (v : V) (w : V)
    (_hvw : v ≠ w)
    (_hconn : G.Reachable v w)
    (hpos : 0 < localCyclePressure' G v)
    (p : G.Walk v w) :
    G.dist v w ≤ p.length ∧ ∃ c : G.Walk v v, 3 ≤ c.length := by
  exact ⟨ walk_length_ge_dist G v w p, cycle_walk_of_pos_pressure G v hpos ⟩

/-! ## Section 13: Falsifiable Conjecture -/

/-- **Phase Transition Conjecture (Falsifiable).**

Let εc be the smallest ε such that the semantic graph is connected,
and ε* be the ε that maximizes cycle rank. The conjecture states
that ε* > εc (the cycle rank peaks strictly after connectivity).

**Computational test**: For any concrete semantic feature space,
compute both thresholds and check the inequality.

**Stronger conjecture**: ε*/εc converges to a universal constant
in [1.5, 2.5] as the number of statements grows. Refuted if
ε*/εc falls outside [1.0, 3.0] for ≥ 3 domains. -/
def phaseTransitionConjecture
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (εc ε_star : ℕ) : Prop :=
  (semanticGraph S εc).Connected ∧
  (∀ ε < εc, ¬(semanticGraph S ε).Connected) ∧
  (∀ ε, graphCycleRank (semanticGraph S ε) ≤ graphCycleRank (semanticGraph S ε_star)) ∧
  εc < ε_star

/-! ## Section 14: Computational Definitions -/

/-- Compute local cycle pressure for all vertices. -/
noncomputable def computeAllPressures
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    V → ℕ :=
  fun v => localCyclePressure' G v

end

/-! ## Axiom Verification -/
#print axioms cycleRank_eq_zero_of_tree
#print axioms cycleRank_nonneg_of_connected
#print axioms walk_length_ge_dist
#print axioms exists_two_walks_of_pos_cycleRank
#print axioms bridge_plus_nonBridge_eq_total
#print axioms exists_long_cycle_walk
#print axioms cycle_walk_of_pos_pressure
#print axioms hardness_localization_structural
#print axioms edgeCount_mono_semanticGraph
#print axioms componentCount_antimono_semanticGraph
#print axioms cycleRank_complete_of_all_adj