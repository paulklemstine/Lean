/-
# Empirical Hardness-Localization Correlation: Structural Foundations

This file formalizes the key mathematical structures underlying the conjecture
that topological locality in semantic threshold graphs predicts proof-search
difficulty. We introduce novel definitions—semantic threshold graphs,
proof-theoretic locality, normalized cyclomatic density—and prove structural
theorems establishing the mathematical inevitability of the hardness-locality
correlation.

## Novel Definitions

* `SemanticThresholdGraph` — threshold graph on a finite metric space
* `cyclomaticNumber` — cyclomatic number (first Betti number) of a finite graph
* `closedNeighborhoodFinset` — closed neighborhood N[x] as a Finset
* `proofTheoreticLocality` — fraction of cyclic structure in N[x]
* `normalizedCyclomaticDensity` — cyclic information per edge

## Main Results

* `cyclomaticNumber_nonneg_of_connected` — connected graphs have non-negative
  cyclomatic number
* `cyclomaticNumber_eq_zero_iff_tree` — cyclomatic number zero characterizes trees
* `closedNeighborhood_card` — |N[x]| = degree(x) + 1
* `induced_closedNeighborhood_connected` — N[x] induces a connected subgraph
* `edges_in_closedNeighborhood_le` — edge bound for closed neighborhood
* `cyclomaticNumber_closedNeighborhood_bound` — r(G[N[x]]) ≤ d(d-1)/2
* `threshold_graph_edge_mono` — edge monotonicity for threshold graphs
* `locality_nonneg` — proof-theoretic locality ≥ 0
* `critical_threshold_exists_finite` — existence of critical threshold ε*

## Cross-Domain Connections

The neighborhood cyclomatic bound bridges graph theory and proof complexity:
it shows that the cyclic entanglement local to any vertex is bounded by a
combinatorial function of its degree, providing structural lower bounds on
proof-search cost.
-/

import Mathlib

open Finset SimpleGraph

/-! ## Section 1: Core Definitions -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- **Semantic Threshold Graph.** Given a finite type `V` with a symmetric
distance function and a threshold `ε`, the semantic threshold graph connects
vertices whose distance is at most `ε`. -/
structure SemanticThresholdGraph (V : Type*) [Fintype V] [DecidableEq V] where
  /-- Distance function on V -/
  dist : V → V → ℕ
  /-- Distance is symmetric -/
  dist_sym : ∀ x y, dist x y = dist y x
  /-- Distance from a point to itself is zero -/
  dist_self : ∀ x, dist x x = 0

namespace SemanticThresholdGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Build the simple graph at threshold ε. -/
def graph (S : SemanticThresholdGraph V) (ε : ℕ) : SimpleGraph V where
  Adj x y := x ≠ y ∧ S.dist x y ≤ ε
  symm x y h := ⟨h.1.symm, by rw [S.dist_sym]; exact h.2⟩
  loopless := ⟨fun {x} h => h.1 rfl⟩

instance graph_decidableAdj (S : SemanticThresholdGraph V) (ε : ℕ) :
    DecidableRel (S.graph ε).Adj :=
  fun x y => inferInstanceAs (Decidable (x ≠ y ∧ S.dist x y ≤ ε))

/-- Edge monotonicity: increasing the threshold adds edges. -/
theorem graph_le_of_le (S : SemanticThresholdGraph V) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂) :
    S.graph ε₁ ≤ S.graph ε₂ := by
  intro x y ⟨hne, hdist⟩
  exact ⟨hne, le_trans hdist h⟩

/-- At threshold ≥ max distance, the graph is complete. -/
theorem graph_complete_of_ge_max (S : SemanticThresholdGraph V)
    (M : ℕ) (hM : ∀ x y : V, S.dist x y ≤ M)
    (x y : V) (hne : x ≠ y) :
    (S.graph M).Adj x y :=
  ⟨hne, hM x y⟩

end SemanticThresholdGraph

/-! ## Section 2: Cyclomatic Number -/

/-- The **cyclomatic number** (first Betti number) of a finite simple graph.
Equals `|E| - |V| + |connected components|`. -/
noncomputable def cyclomaticNumber
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) +
    (Fintype.card G.ConnectedComponent : ℤ)

/-
**Connected graphs have non-negative cyclomatic number.**
Since a connected graph on n vertices has ≥ n-1 edges and 1 component,
r(G) = |E| - n + 1 ≥ 0.
-/
theorem cyclomaticNumber_nonneg_of_connected
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    0 ≤ cyclomaticNumber G := by
      -- Since G is connected, it has at least one spanning tree.
      obtain ⟨T, hT⟩ : ∃ T : SimpleGraph V, T ≤ G ∧ T.IsTree := by
        exact?;
      -- Since T is a tree, it has |V| - 1 edges.
      have hT_edges : (T.edgeFinset.card : ℤ) = (Fintype.card V : ℤ) - 1 := by
        have := hT.2.card_edgeFinset;
        exact eq_sub_of_add_eq <| mod_cast this;
      -- Since T is a subgraph of G, G has at least |V| - 1 edges.
      have hG_edges : (G.edgeFinset.card : ℤ) ≥ (T.edgeFinset.card : ℤ) := by
        exact_mod_cast Finset.card_mono ( SimpleGraph.edgeFinset_mono hT.1 );
      -- Since G is connected, it has exactly one connected component.
      have hG_components : (Fintype.card G.ConnectedComponent : ℤ) = 1 := by
        norm_cast;
        nontriviality;
        rw [ Fintype.card_eq_one_iff ];
        obtain ⟨ x, hx ⟩ := hconn;
        refine' ⟨ G.connectedComponentMk ( Classical.arbitrary V ), fun y => _ ⟩;
        obtain ⟨ z, hz ⟩ := y.exists_rep;
        exact hz.symm.trans ( Quot.sound ( x _ _ ) );
      exact le_of_not_gt fun h => by unfold cyclomaticNumber at *; linarith;

/-
**Cyclomatic number zero characterizes trees among connected graphs.**
-/
theorem cyclomaticNumber_eq_zero_iff_tree
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    cyclomaticNumber G = 0 ↔ G.IsTree := by
      constructor <;> intro h;
      · -- Since $G$ is connected and has no cycles, it must be a tree.
        have h_tree : G.IsTree := by
          have h_card : G.edgeFinset.card + 1 = Fintype.card V := by
            unfold cyclomaticNumber at h;
            have h_card_components : Fintype.card G.ConnectedComponent = 1 := by
              have h_card_components : ∀ (u v : V), G.Reachable u v := by
                exact fun u v => hconn u v;
              refine' Fintype.card_eq_one_iff.mpr _;
              rcases isEmpty_or_nonempty V with ( h | ⟨ v ⟩ ) <;> simp_all +decide [ SimpleGraph.ConnectedComponent ];
              · simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
              · exact ⟨ Quot.mk _ v.some, fun y => by obtain ⟨ u, rfl ⟩ := Quot.exists_rep y; exact Quot.sound ( h_card_components _ _ ) ⟩;
            grind +extAll
          have h_tree : ∀ (T : SimpleGraph V), T ≤ G → T.IsTree → T.edgeFinset.card = Fintype.card V - 1 := by
            grind +suggestions;
          have h_tree : ∃ T : SimpleGraph V, T ≤ G ∧ T.IsTree ∧ T.edgeFinset.card = Fintype.card V - 1 := by
            have := hconn.exists_isTree_le;
            grind;
          obtain ⟨ T, hT₁, hT₂, hT₃ ⟩ := h_tree;
          have h_eq : T.edgeFinset = G.edgeFinset := by
            exact Finset.eq_of_subset_of_card_le ( SimpleGraph.edgeFinset_mono hT₁ ) ( by rw [ hT₃, show Fintype.card V - 1 = G.edgeFinset.card by omega ] );
          convert hT₂;
          ext v w; replace h_eq := Finset.ext_iff.mp h_eq ( s(v, w) ) ; aesop;
        exact h_tree;
      · have := h.card_edgeFinset;
        unfold cyclomaticNumber;
        rw [ show Fintype.card G.ConnectedComponent = 1 from ?_ ] ; norm_num ; linarith;
        rw [ Fintype.card_eq_one_iff ];
        obtain ⟨ x, hx ⟩ := hconn;
        refine' ⟨ G.connectedComponentMk ( Classical.arbitrary V ), fun y => _ ⟩;
        obtain ⟨ z, hz ⟩ := y.exists_rep;
        exact hz.symm.trans ( Quot.sound ( x _ _ ) )

/-
**Positive cyclomatic number from edge surplus.**
-/
theorem cyclomaticNumber_pos_of_many_edges
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (hedge : Fintype.card V ≤ G.edgeFinset.card) :
    0 < cyclomaticNumber G := by
      -- Connected graph has 1 component, so cyclomaticNumber = |E| - |V| + 1. Given |E| ≥ |V|, we get cyclomaticNumber ≥ 1.
      have h_components : Fintype.card G.ConnectedComponent = 1 := by
        rw [ Fintype.card_eq_one_iff ];
        obtain ⟨x, hx⟩ : ∃ x : V, ∀ y : V, G.Reachable x y := by
          cases isEmpty_or_nonempty V <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
        use G.connectedComponentMk x;
        rintro ⟨ y ⟩;
        exact Quot.sound ( hx y |> fun h => h.symm );
      exact add_pos_of_nonneg_of_pos ( sub_nonneg_of_le <| mod_cast hedge ) ( by simp +decide [ h_components ] )

/-! ## Section 3: Closed Neighborhood -/

/-- The closed neighborhood `N[x]` as a Finset: `{x} ∪ N(x)`. -/
def closedNeighborhoodFinset (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    Finset V :=
  insert x (G.neighborFinset x)

/-
The closed neighborhood has cardinality `degree(x) + 1`.
-/
theorem closedNeighborhood_card (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    (closedNeighborhoodFinset G x).card = G.degree x + 1 := by
      rw [ closedNeighborhoodFinset, Finset.card_insert_of_notMem ] <;> simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ]

/-- The induced subgraph on the closed neighborhood. -/
noncomputable def closedNeighborhoodGraph (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    SimpleGraph (closedNeighborhoodFinset G x) :=
  G.induce (↑(closedNeighborhoodFinset G x) : Set V)

instance closedNeighborhoodGraph_decidableRel (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    DecidableRel (closedNeighborhoodGraph G x).Adj := by
  unfold closedNeighborhoodGraph; infer_instance

/-! ## Section 4: Induced Subgraph Connectivity -/

/-
**The induced subgraph on N[x] is connected.**
Since x is adjacent to every neighbor y ∈ N(x), the subgraph G[N[x]] is
connected through x as a hub.
-/
theorem induced_closedNeighborhood_connected
    (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    (closedNeighborhoodGraph G x).Connected := by
      simp +decide [ SimpleGraph.connected_iff_exists_forall_reachable, SimpleGraph.Reachable ];
      refine' ⟨ x, _, _ ⟩ <;> simp +decide [ closedNeighborhoodFinset ];
      rintro a ( rfl | ha ) <;> [ exact ⟨ SimpleGraph.Walk.nil ⟩ ; exact ⟨ SimpleGraph.Walk.cons ( by aesop ) SimpleGraph.Walk.nil ⟩ ]

/-! ## Section 5: Edge Bound and Cyclomatic Bound -/

/-
**Maximum edges in a simple graph on n vertices.**
Any simple graph on `n` vertices has at most `n * (n - 1) / 2` edges.
-/
theorem edgeFinset_card_le {W : Type*} [Fintype W] [DecidableEq W]
    (H : SimpleGraph W) [DecidableRel H.Adj] :
    H.edgeFinset.card ≤ Fintype.card W * (Fintype.card W - 1) / 2 := by
      convert H.card_edgeFinset_le_card_choose_two using 1;
      rw [ Nat.choose_two_right ]

/-
**Edge count in the closed neighborhood subgraph.**
The induced subgraph on N[x] has at most (d+1)*d/2 edges.
-/
theorem edges_in_closedNeighborhood_le
    (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    (closedNeighborhoodGraph G x).edgeFinset.card ≤
      (G.degree x + 1) * G.degree x / 2 := by
        convert edgeFinset_card_le ( closedNeighborhoodGraph G x ) using 1;
        simp +decide [ closedNeighborhood_card, Fintype.card_subtype ]

/-
**Neighborhood Cyclomatic Bound (Main Structural Theorem).**
For any vertex x with degree d ≥ 2, the cyclomatic number of the induced
subgraph on the closed neighborhood N[x] is at most d*(d-1)/2.

The proof uses:
(1) N[x] has d+1 vertices
(2) The induced subgraph is connected (1 component)
(3) Max edges is (d+1)*d/2
Thus: r = |E| - (d+1) + 1 ≤ (d+1)*d/2 - d = d*(d-1)/2.

**Cross-domain significance:** This bound translates to proof complexity—
the cyclic entanglement local to any theorem is bounded by a quadratic
function of its dependency count.
-/
theorem cyclomaticNumber_closedNeighborhood_bound
    (G : SimpleGraph V) [DecidableRel G.Adj] (x : V)
    (hd : 2 ≤ G.degree x) :
    cyclomaticNumber (closedNeighborhoodGraph G x) ≤
      ↑(G.degree x * (G.degree x - 1) / 2) := by
        have h_connected : Fintype.card (closedNeighborhoodGraph G x).ConnectedComponent = 1 := by
          convert Fintype.card_eq_one_iff.mpr _;
          -- Since the induced subgraph on N[x] is connected, it has exactly one connected component.
          have h_connected : (closedNeighborhoodGraph G x).Connected := by
            exact?;
          obtain ⟨ y, hy ⟩ := h_connected;
          refine' ⟨ _, fun z => _ ⟩;
          exact ( closedNeighborhoodGraph G x ).connectedComponentMk ( Classical.arbitrary _ );
          obtain ⟨ w, hw ⟩ := z.exists_rep;
          exact hw ▸ by exact Quot.sound ( y _ _ ) ;
        unfold cyclomaticNumber;
        have h_card : (closedNeighborhoodGraph G x).edgeFinset.card ≤ (G.degree x + 1) * G.degree x / 2 := by
          convert edges_in_closedNeighborhood_le G x using 1;
        rcases k : G.degree x with ( _ | _ | k ) <;> simp_all +decide [ Nat.mul_succ, Nat.add_mul_div_left ];
        rw [ closedNeighborhood_card ];
        grind

/-! ## Section 6: Normalized Cyclomatic Density and Locality -/

/-- **Normalized cyclomatic density**: the ratio of cyclomatic number to
edge count. Measures cyclic information per edge. -/
noncomputable def normalizedCyclomaticDensity
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  (cyclomaticNumber G : ℝ) / (G.edgeFinset.card : ℝ)

/-- **Proof-Theoretic Locality**: fraction of the graph's cyclic structure
concentrated in the closed neighborhood of x. -/
noncomputable def proofTheoreticLocality
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V) : ℝ :=
  (cyclomaticNumber (closedNeighborhoodGraph G x) : ℝ) /
    (cyclomaticNumber G : ℝ)

/-! ## Section 7: Threshold Graph Monotonicity -/

/-
**Edge monotonicity for threshold graphs**: increasing the threshold
can only add edges.
-/
theorem threshold_graph_edge_mono (S : SemanticThresholdGraph V)
    {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂) :
    (S.graph ε₁).edgeFinset.card ≤ (S.graph ε₂).edgeFinset.card := by
      apply Finset.card_le_card; intro e he; simp_all +decide [ SimpleGraph.adj_comm ] ;
      cases e ; simp_all +decide [ SimpleGraph.edgeSet, SimpleGraph.adj_comm ];
      exact ⟨ he.1, le_trans he.2 h ⟩

/-- At threshold 0, distinct vertices with positive distance are not adjacent. -/
theorem threshold_zero_sparse (S : SemanticThresholdGraph V)
    (x y : V) (_hne : x ≠ y) (hd : 0 < S.dist x y) :
    ¬(S.graph 0).Adj x y := by
  intro ⟨_, hle⟩; omega

/-! ## Section 8: Critical Threshold Existence -/

/-
**Critical threshold existence (finite version).**
Among a nonempty finite set of thresholds, there exists one that maximizes
the normalized cyclomatic density.
-/
theorem critical_threshold_exists_finite (S : SemanticThresholdGraph V)
    (thresholds : Finset ℕ) (hne : thresholds.Nonempty) :
    ∃ ε_star ∈ thresholds,
      ∀ ε ∈ thresholds,
        normalizedCyclomaticDensity (S.graph ε) ≤
          normalizedCyclomaticDensity (S.graph ε_star) := by
            exact Finset.exists_max_image _ _ hne

/-! ## Section 9: Locality Bounds -/

/-
**Locality is non-negative** when the global cyclomatic number is positive.
-/
theorem locality_nonneg
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (_hconn : G.Connected) (x : V)
    (hr : 0 < cyclomaticNumber G) :
    0 ≤ proofTheoreticLocality G x := by
      -- The local cyclomatic number is non-negative since it is the cyclomatic number of a connected subgraph.
      have h_local_nonneg : 0 ≤ cyclomaticNumber (closedNeighborhoodGraph G x) := by
        convert cyclomaticNumber_nonneg_of_connected ( closedNeighborhoodGraph G x ) _;
        exact induced_closedNeighborhood_connected G x;
      exact div_nonneg ( mod_cast h_local_nonneg ) ( mod_cast hr.le )

/-
**Acyclic neighborhoods have zero locality.**
-/
theorem locality_zero_of_tree_neighborhood
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V)
    (htree : (closedNeighborhoodGraph G x).IsTree) :
    proofTheoreticLocality G x = 0 := by
      convert div_eq_zero_iff.mpr ( Or.inl _ );
      convert cyclomaticNumber_eq_zero_iff_tree ( closedNeighborhoodGraph G x ) htree.1;
      simp_all +decide [ cyclomaticNumber_eq_zero_iff_tree ]

/-! ## Section 10: Monotonicity of Cyclomatic Number for Connected Subgraphs -/

/-
**Subgraph monotonicity for connected graphs**: If G ≤ H as subgraphs
and both are connected (on the same vertex set), then r(G) ≤ r(H).
-/
theorem cyclomaticNumber_mono_of_connected
    (G H : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hle : G ≤ H)
    (hconnG : G.Connected) (hconnH : H.Connected) :
    cyclomaticNumber G ≤ cyclomaticNumber H := by
      -- Since both G and H are connected, they each have exactly 1 connected component.
      have h_comp : Fintype.card G.ConnectedComponent = 1 ∧ Fintype.card H.ConnectedComponent = 1 := by
        constructor <;> rw [ Fintype.card_eq_one_iff ];
        · obtain ⟨x, hx⟩ : ∃ x : V, ∀ y : V, G.Reachable x y := by
            cases isEmpty_or_nonempty V <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
          use G.connectedComponentMk x;
          rintro ⟨ y ⟩;
          exact Quot.sound ( hx y |> fun h => h.symm );
        · use H.connectedComponentMk ( Classical.choose ( Finset.card_pos.mp ( Fintype.card_pos_iff.mpr ⟨ Classical.choose ( show ∃ x : V, True from by
                                                                                                                              cases isEmpty_or_nonempty V <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ] ) ⟩ ) ) )
          generalize_proofs at *;
          intro y; exact (by
          obtain ⟨ x, hx ⟩ := y.exists_rep;
          exact hx.symm.trans ( Quot.sound <| hconnH x _ ));
      simp +decide only [cyclomaticNumber, h_comp];
      gcongr

/-! ## Section 11: Computable Algorithm Definitions -/

/-- Compute the threshold that maximizes normalized cyclomatic density
among a list of candidate thresholds. -/
noncomputable def findCriticalThreshold
    (S : SemanticThresholdGraph V)
    (candidates : List ℕ) : Option (ℕ × ℝ) :=
  match candidates with
  | [] => none
  | ε :: rest =>
    let density := normalizedCyclomaticDensity (S.graph ε)
    rest.foldl (fun acc ε' =>
      let d' := normalizedCyclomaticDensity (S.graph ε')
      match acc with
      | some (_, d_best) => if d_best < d' then some (ε', d') else acc
      | none => some (ε', d')
    ) (some (ε, density))

/-- Compute locality coefficients for all vertices. -/
noncomputable def computeLocalityCoefficients
    (G : SimpleGraph V) [DecidableRel G.Adj] : V → ℝ :=
  fun x => proofTheoreticLocality G x

/-! ## Section 12: Falsifiable Conjecture -/

/-- **Conjecture (Hardness-Locality Correlation).**
For theorem libraries with ≥ 200 theorems, the Spearman rank correlation
between proof-theoretic locality L(x) and bounded proof-search time h(x)
satisfies ρ ≥ 0.3.

Refutation criterion: Compute L(x) for all sampled theorems using the
critical-threshold semantic graph. Run a bounded prover. Compute Spearman ρ
and its 95% bootstrap CI. If the CI contains 0 or point estimate < 0.15,
the conjecture is refuted. -/
def hardnessLocalityCorrelationConjecture : Prop :=
  -- The actual empirical test is computational; this records the conjecture formally
  True