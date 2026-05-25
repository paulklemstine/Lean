/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Morse Theory for Weighted Graph Filtrations

This file develops a **discrete tropical Morse theory** for weighted graph filtrations,
establishing a rigorous connection between persistent topology, tropical geometry,
and network phase transitions.

The central idea: given a finite weighted graph, edges appear in increasing weight order.
At each insertion, the topology changes in exactly one of two ways:
- a **merge event** (bridge): two components join, β₀ drops by 1
- a **cycle event**: an independent cycle closes, β₁ rises by 1

We formalize this dichotomy, prove global counting theorems relating cycle/merge
events to Betti numbers, and establish that critical values are exactly the
discontinuity points of topological observables — connecting to statistical mechanics
phase transitions.

## Main Definitions

* `addEdge` — graph obtained by adding a single edge
* `EdgeEventType` — merge vs. cycle classification
* `classifyEdge` — determines event type for an edge insertion
* `GraphFiltration` — ordered sequence of edge insertions

## Main Results

* `betti0_addEdge_of_not_reachable` — adding a bridge drops β₀ by 1
* `betti0_addEdge_of_reachable` — adding within a component preserves β₀
* `betti1_addEdge_of_reachable` — adding within a component raises β₁ by 1
* `betti1_addEdge_of_not_reachable` — adding a bridge preserves β₁
* `betti_update_dichotomy` — exactly one of the above cases holds
* `filtration_merge_plus_cycle` — merge count + cycle count = total edges
* `filtration_betti1_eq_cycleCount` — β₁ of final graph = # cycle events
* `filtration_rank_eq_mergeCount` — |V| - β₀ of final graph = # merge events
* `critical_iff_topology_jump` — every valid edge insertion changes topology

## References

* Baker–Norine (2007), Edelsbrunner–Harer: Persistent Homology
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Graph Operations -/

/-- Add a single edge to a simple graph. -/
def addEdge (G : SimpleGraph V) (u v : V) : SimpleGraph V :=
  G ⊔ SimpleGraph.fromEdgeSet {s(u, v)}

instance addEdge_decidableRel (G : SimpleGraph V) [DecidableRel G.Adj] (u v : V) :
    DecidableRel (addEdge G u v).Adj := by
  intro a b; unfold addEdge; rw [SimpleGraph.sup_adj]; infer_instance

/-- Adding edge {u,v} makes u and v adjacent (when u ≠ v). -/
theorem addEdge_adj (G : SimpleGraph V) (u v : V) (huv : u ≠ v) :
    (addEdge G u v).Adj u v := by
  unfold addEdge
  rw [SimpleGraph.sup_adj]
  right
  rw [SimpleGraph.fromEdgeSet_adj]
  exact ⟨Set.mem_singleton _, huv⟩

/-- The original adjacency is preserved when adding an edge. -/
theorem addEdge_adj_of_adj (G : SimpleGraph V) (u v a b : V) (h : G.Adj a b) :
    (addEdge G u v).Adj a b := by
  unfold addEdge
  rw [SimpleGraph.sup_adj]
  left; exact h

/-- Adjacency in addEdge is either original or the new edge. -/
theorem addEdge_adj_iff (G : SimpleGraph V) (u v a b : V) :
    (addEdge G u v).Adj a b ↔ G.Adj a b ∨ (s(a, b) = s(u, v) ∧ a ≠ b) := by
  unfold addEdge
  rw [SimpleGraph.sup_adj, SimpleGraph.fromEdgeSet_adj]
  constructor
  · rintro (h | ⟨h, hne⟩)
    · left; exact h
    · right; exact ⟨Set.mem_singleton_iff.mp h, hne⟩
  · rintro (h | ⟨h, hne⟩)
    · left; exact h
    · right; exact ⟨Set.mem_singleton_iff.mpr h, hne⟩

/-- G is a subgraph of addEdge G u v. -/
theorem le_addEdge (G : SimpleGraph V) (u v : V) :
    G ≤ addEdge G u v := le_sup_left

/-! ## Betti Numbers -/

/-- β₀(G) = number of connected components. -/
def graphBetti0 (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  Fintype.card G.ConnectedComponent

/-- β₁(G) = |E| - |V| + β₀ (first Betti number / cycle rank).
    This is always ≥ 0 for finite graphs since a spanning forest
    has |V| - β₀ edges. -/
def graphBetti1 (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  G.edgeFinset.card + graphBetti0 G - Fintype.card V

/-! ## Edge Event Classification -/

/-- Edge event type for a filtration step. -/
inductive EdgeEventType where
  | mergeEvent : EdgeEventType
  | cycleEvent : EdgeEventType
  deriving DecidableEq, Repr

/-- Classify an edge {u,v} being added to graph G. -/
def classifyEdge (G : SimpleGraph V) [DecidableRel G.Adj] (u v : V) : EdgeEventType :=
  if G.Reachable u v then EdgeEventType.cycleEvent else EdgeEventType.mergeEvent

/-! ## Core Lemmas -/

/-
Adding a non-adjacent edge increases the edge count by 1.
-/
theorem edgeFinset_card_addEdge (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (huv : u ≠ v) (hnadj : ¬G.Adj u v) :
    (addEdge G u v).edgeFinset.card = G.edgeFinset.card + 1 := by
  convert Set.toFinset_card ( s := G.edgeFinset ∪ { s(u, v) } ) using 1;
  · congr with e ; simp +decide [ hnadj, huv, addEdge ];
    cases e ; aesop;
  · simp +decide [ hnadj, huv, SimpleGraph.edgeFinset ]

/-
If u and v are not reachable in G, then adding edge {u,v}
    merges their components, reducing β₀ by 1.
-/
theorem betti0_addEdge_of_not_reachable (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (huv : u ≠ v) (hreach : ¬G.Reachable u v) :
    graphBetti0 (addEdge G u v) + 1 = graphBetti0 G := by
  -- Define a map φ: G.ConnectedComponent → (addEdge G u v).ConnectedComponent by φ(C) = the component of any representative of C in the new graph.
  set phi : G.ConnectedComponent → (addEdge G u v).ConnectedComponent := fun C => C.map (SimpleGraph.Hom.ofLE (le_addEdge G u v));
  have h_phi_surjective : Function.Surjective phi := by
    intro C';
    obtain ⟨ w, hw ⟩ := C'.exists_rep;
    use G.connectedComponentMk w;
    aesop
  have h_phi_injective : ∀ C₁ C₂ : G.ConnectedComponent, phi C₁ = phi C₂ → C₁ = C₂ ∨ (C₁ = G.connectedComponentMk u ∧ C₂ = G.connectedComponentMk v) ∨ (C₁ = G.connectedComponentMk v ∧ C₂ = G.connectedComponentMk u) := by
    intro C₁ C₂ h_eq
    obtain ⟨w₁, hw₁⟩ : ∃ w₁ : V, C₁ = G.connectedComponentMk w₁ := by
      exact ⟨ Classical.choose ( C₁.exists_rep ), Eq.symm ( Classical.choose_spec ( C₁.exists_rep ) ) ⟩
    obtain ⟨w₂, hw₂⟩ : ∃ w₂ : V, C₂ = G.connectedComponentMk w₂ := by
      exact ⟨ C₂.out, C₂.out_eq.symm ⟩
    generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
    -- Since $w₁$ and $w₂$ are in the same connected component of $addEdge G u v$, there exists a path between them in $addEdge G u v$.
    obtain ⟨p, hp⟩ : ∃ p : SimpleGraph.Walk (addEdge G u v) w₁ w₂, True := by
      aesop
    generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
    -- Since $p$ is a walk in $addEdge G u v$, it can be decomposed into a sequence of edges in $G$ and the edge $\{u, v\}$.
    have h_walk_decomp : ∀ (w₁ w₂ : V), ∀ p : SimpleGraph.Walk (addEdge G u v) w₁ w₂, (G.Reachable w₁ w₂ ∨ (G.Reachable w₁ u ∧ G.Reachable v w₂) ∨ (G.Reachable w₁ v ∧ G.Reachable u w₂)) := by
      intro w₁ w₂ p
      induction' p with w₁ w₂ p ih
      generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
      · exact Or.inl ⟨ SimpleGraph.Walk.nil ⟩;
      · rename_i h₁ h₂ h₃
        generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
        rcases h₁ with ( h₁ | h₁ ) <;> simp_all +decide [ SimpleGraph.adj_comm ];
        · exact Or.imp ( fun h => h₁.reachable.trans h ) ( Or.imp ( fun h => ⟨ h₁.reachable.trans h.1, h.2 ⟩ ) ( fun h => ⟨ h₁.reachable.trans h.1, h.2 ⟩ ) ) h₃;
        · grind +suggestions
    generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
    specialize h_walk_decomp w₁ w₂ p; simp_all +decide [ SimpleGraph.Reachable ] ;
    exact Or.imp id ( Or.imp ( fun h => ⟨ h.1, h.2.elim fun p => ⟨ p.reverse ⟩ ⟩ ) fun h => ⟨ h.1, h.2.elim fun p => ⟨ p.reverse ⟩ ⟩ ) h_walk_decomp
  generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
  have h_phi_fibers : ∀ C : (addEdge G u v).ConnectedComponent, Finset.card (Finset.filter (fun C' => phi C' = C) Finset.univ) = if C = phi (G.connectedComponentMk u) then 2 else 1 := by
    intro C
    by_cases hC : C = phi (G.connectedComponentMk u);
    · have h_phi_fibers_u_v : Finset.filter (fun C' => phi C' = C) Finset.univ = {G.connectedComponentMk u, G.connectedComponentMk v} := by
        ext C'
        simp [hC];
        apply Iff.intro;
        · grind +ring;
        · rintro ( rfl | rfl ) <;> simp +decide [ phi ];
          exact SimpleGraph.Adj.reachable ( by unfold addEdge; aesop ) |> SimpleGraph.Reachable.symm
      generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
      rw [ h_phi_fibers_u_v, Finset.card_insert_of_notMem, Finset.card_singleton ] <;> simp +decide [ hC ];
      exact hreach;
    · obtain ⟨ C', hC' ⟩ := h_phi_surjective C; simp_all +decide [ Finset.card_eq_one ] ;
      use C';
      grind +suggestions
  generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
  have h_phi_fibers_card : Finset.card (Finset.univ : Finset G.ConnectedComponent) = Finset.sum Finset.univ (fun C => Finset.card (Finset.filter (fun C' => phi C' = C) Finset.univ)) := by
    simp +decide only [card_eq_sum_ones, sum_fiberwise_of_maps_to (fun C _ => Finset.mem_univ (phi C))]
  generalize_proofs at *; -- This is to handle the generalizations introduced by `have`.;
  simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ];
  simp_all +decide [ Finset.filter_eq', graphBetti0 ];
  rw [ Finset.card_filter ] ; norm_num ; ring;
  linarith [ Nat.sub_add_cancel ( show 1 ≤ Fintype.card ( addEdge G u v ).ConnectedComponent from Fintype.card_pos_iff.mpr ⟨ phi ( G.connectedComponentMk u ) ⟩ ) ]

/-
If u and v are already reachable in G, then adding edge {u,v}
    does not change the number of connected components.
-/
theorem betti0_addEdge_of_reachable (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (hreach : G.Reachable u v) :
    graphBetti0 (addEdge G u v) = graphBetti0 G := by
  -- If u and v are reachable in G, then the connected components of G and addEdge G u v are the same.
  have h_connected_components : ∀ (x y : V), G.Reachable x y ↔ (addEdge G u v).Reachable x y := by
    intro x y;
    constructor <;> rintro ⟨ p ⟩;
    · exact ⟨ p.map ( SimpleGraph.Hom.ofLE ( by unfold addEdge; aesop ) ) ⟩;
    · induction' p with x y p ih;
      · exact SimpleGraph.Reachable.refl x;
      · rename_i h₁ h₂ h₃;
        cases' h₁ with h₁ h₁;
        · exact h₁.reachable.trans h₃;
        · cases' h₁ with h₁ h₁ ; simp_all +decide [ SimpleGraph.fromEdgeSet_adj ];
          cases' ‹y = u ∧ p = v ∨ y = v ∧ p = u› with h h <;> simp_all +decide [ SimpleGraph.Reachable ];
          · exact ⟨ hreach.some.append h₃.some ⟩;
          · exact ⟨ hreach.some.reverse.append h₃.some ⟩;
  have h_card_eq : Nonempty (G.ConnectedComponent ≃ (addEdge G u v).ConnectedComponent) := by
    refine' ⟨ Equiv.ofBijective ( fun x => x.map ( SimpleGraph.Hom.ofLE ( le_addEdge G u v ) ) ) ⟨ fun x y hxy => _, fun x => _ ⟩ ⟩;
    · obtain ⟨ a, rfl ⟩ := x.exists_rep; obtain ⟨ b, rfl ⟩ := y.exists_rep; simp_all +decide [ SimpleGraph.ConnectedComponent.map ] ;
      simp_all +decide [ SimpleGraph.ConnectedComponent.lift ];
      exact Quot.sound ( h_connected_components a b |>.2 hxy );
    · obtain ⟨ y, hy ⟩ := x.exists_rep;
      refine' ⟨ Quot.mk _ y, _ ⟩;
      convert hy using 1;
  exact Fintype.card_congr h_card_eq.some.symm

/-! ## Main Theorem 1: Edge Insertion Dichotomy -/

/-
A graph has at least |V| - β₀ edges (spanning forest bound).
-/
theorem edgeFinset_card_add_betti0_ge (G : SimpleGraph V) [DecidableRel G.Adj] :
    Fintype.card V ≤ G.edgeFinset.card + graphBetti0 G := by
  have h_spanning_forest : ∀ (G : SimpleGraph V) [DecidableRel G.Adj], (Fintype.card V) ≤ G.edgeFinset.card + graphBetti0 G := by
    intro G _;
    -- Each connected component of $G$ has at least $|V_i| - 1$ edges.
    have h_connected_components : ∀ (C : G.ConnectedComponent), (Fintype.card C.supp - 1) ≤ (G.induce C.supp).edgeFinset.card := by
      intro C
      have h_connected : (SimpleGraph.induce C.supp G).Connected := by
        have h_induced_connected : ∀ (u v : V), u ∈ C.supp → v ∈ C.supp → G.Reachable u v := by
          grind +suggestions;
        rw [ SimpleGraph.connected_iff_exists_forall_reachable ];
        obtain ⟨v, hv⟩ : ∃ v : V, v ∈ C.supp := by
          exact C.exists_rep;
        use ⟨v, hv⟩;
        rintro ⟨ w, hw ⟩;
        obtain ⟨ p ⟩ := h_induced_connected v w hv hw;
        induction' p with u v p ih;
        · exact SimpleGraph.Reachable.refl _;
        · grind +suggestions;
      have := h_connected.exists_isTree_le;
      obtain ⟨ T, hT₁, hT₂ ⟩ := this;
      have := hT₂.card_edgeFinset;
      exact Nat.sub_le_of_le_add ( by linarith [ show #T.edgeFinset ≤ #(SimpleGraph.induce C.supp G).edgeFinset from Finset.card_mono <| by aesop ] );
    -- Summing over all connected components, we get $|V| - \beta_0(G) \leq |E|$.
    have h_sum_components : (Fintype.card V) - graphBetti0 G ≤ ∑ C : G.ConnectedComponent, (G.induce C.supp).edgeFinset.card := by
      have h_sum_components : (Fintype.card V) = ∑ C : G.ConnectedComponent, (Fintype.card C.supp) := by
        simp +decide only [Fintype.card_subtype];
        simp +decide only [card_filter];
        rw [ Finset.sum_comm ];
        rw [ Finset.sum_congr rfl fun x _ => Finset.sum_eq_single ( G.connectedComponentMk x ) _ _ ] <;> aesop;
      have h_sum_components : (Fintype.card V) - graphBetti0 G = ∑ C : G.ConnectedComponent, (Fintype.card C.supp - 1) := by
        rw [ h_sum_components, Nat.sub_eq_of_eq_add ];
        zify [ graphBetti0 ];
        rw [ Finset.sum_congr rfl fun x _ => Nat.cast_sub <| Fintype.card_pos_iff.mpr <| by
          obtain ⟨ v, hv ⟩ := x.exists_rep; exact ⟨ v, hv ⟩ ; ] ; simp +decide [ Finset.sum_add_distrib ];
      exact h_sum_components.symm ▸ Finset.sum_le_sum fun C _ => h_connected_components C;
    -- Since the edge set of $G$ is the union of the edge sets of its connected components, we have $|E| = \sum_{C} |E(C)|$.
    have h_edge_set_union : G.edgeFinset = Finset.biUnion (Finset.univ : Finset G.ConnectedComponent) (fun C => (G.induce C.supp).edgeFinset.image (fun e => e.map (Function.Embedding.subtype _))) := by
      ext e; simp [SimpleGraph.edgeFinset];
      constructor;
      · rcases e with ⟨ u, v ⟩;
        intro huv
        obtain ⟨C, hC⟩ : ∃ C : G.ConnectedComponent, u ∈ C.supp ∧ v ∈ C.supp := by
          exact ⟨ G.connectedComponentMk u, by simp +decide, by simp +decide [ SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable huv ) ] ⟩;
        refine' ⟨ C, Sym2.mk ( ⟨ u, hC.1 ⟩, ⟨ v, hC.2 ⟩ ), _, _ ⟩ <;> aesop;
      · rintro ⟨ C, e, he, rfl ⟩ ; induction e ; aesop;
    rw [ h_edge_set_union, Finset.card_biUnion ];
    · rw [ Finset.sum_congr rfl fun _ _ => Finset.card_image_of_injective _ fun x y hxy => ?_ ];
      · grind +locals;
      · rcases x with ⟨ ⟨ a, ha ⟩, ⟨ b, hb ⟩ ⟩ ; rcases y with ⟨ ⟨ c, hc ⟩, ⟨ d, hd ⟩ ⟩ ; simp_all +decide [ Sym2.eq ] ;
    · intro C _ D _ hCD; simp_all +decide [ Finset.disjoint_left, Sym2.map ] ;
      intro a ha x hx; contrapose! hCD; simp_all +decide [ Quot.map ] ;
      rcases a with ⟨ ⟨ u, hu ⟩, ⟨ v, hv ⟩ ⟩ ; rcases x with ⟨ ⟨ w, hw ⟩, ⟨ x, hx ⟩ ⟩ ; simp_all +decide [ Quot.lift ] ;
      cases hCD <;> aesop;
  exact h_spanning_forest G

/-- **Merge case**: Adding a bridge edge drops β₀ by 1 and preserves β₁. -/
theorem betti1_addEdge_of_not_reachable (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (huv : u ≠ v) (hnadj : ¬G.Adj u v) (hreach : ¬G.Reachable u v) :
    graphBetti1 (addEdge G u v) = graphBetti1 G := by
  unfold graphBetti1
  rw [edgeFinset_card_addEdge G u v huv hnadj]
  have hb0 := betti0_addEdge_of_not_reachable G u v huv hreach
  have hge := edgeFinset_card_add_betti0_ge G
  unfold graphBetti0 at hb0 hge ⊢
  omega

/-- **Cycle case**: Adding a cycle edge preserves β₀ and increases β₁ by 1. -/
theorem betti1_addEdge_of_reachable (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (huv : u ≠ v) (hnadj : ¬G.Adj u v) (hreach : G.Reachable u v) :
    graphBetti1 (addEdge G u v) = graphBetti1 G + 1 := by
  unfold graphBetti1
  rw [edgeFinset_card_addEdge G u v huv hnadj]
  have hb0 := betti0_addEdge_of_reachable G u v hreach
  have hge := edgeFinset_card_add_betti0_ge G
  unfold graphBetti0 at hb0 hge ⊢
  omega

/-- **Edge insertion dichotomy** (Discrete Tropical Morse Principle):
    For any edge insertion of a non-existing edge into a graph,
    exactly one of two mutually exclusive events occurs:
    - **Merge**: β₀ drops by 1, β₁ unchanged
    - **Cycle**: β₀ unchanged, β₁ rises by 1

    This is the atomic local Morse law for graph filtrations. -/
theorem betti_update_dichotomy (G : SimpleGraph V) [DecidableRel G.Adj]
    (u v : V) (huv : u ≠ v) (hnadj : ¬G.Adj u v) :
    -- Merge case
    (¬G.Reachable u v →
      graphBetti0 (addEdge G u v) + 1 = graphBetti0 G ∧
      graphBetti1 (addEdge G u v) = graphBetti1 G) ∧
    -- Cycle case
    (G.Reachable u v →
      graphBetti0 (addEdge G u v) = graphBetti0 G ∧
      graphBetti1 (addEdge G u v) = graphBetti1 G + 1) := by
  constructor
  · intro hreach
    exact ⟨betti0_addEdge_of_not_reachable G u v huv hreach,
           betti1_addEdge_of_not_reachable G u v huv hnadj hreach⟩
  · intro hreach
    exact ⟨betti0_addEdge_of_reachable G u v hreach,
           betti1_addEdge_of_reachable G u v huv hnadj hreach⟩

/-! ## Filtration Framework -/

/-- A graph filtration: edges added one at a time.
    We use a vector of edges for easier indexing. -/
structure GraphFiltration (V : Type*) [Fintype V] [DecidableEq V] (n : ℕ) where
  /-- Edges to insert, in order -/
  edges : Fin n → V × V
  /-- Each edge connects distinct vertices -/
  distinct : ∀ i, (edges i).1 ≠ (edges i).2

/-- The graph at step i of the filtration: the empty graph plus the first i edges. -/
def GraphFiltration.graphAt {n : ℕ} (F : GraphFiltration V n) : ℕ → SimpleGraph V
  | 0 => ⊥
  | k + 1 =>
    if h : k < n then
      addEdge (F.graphAt k) (F.edges ⟨k, h⟩).1 (F.edges ⟨k, h⟩).2
    else F.graphAt k

instance GraphFiltration.graphAt_decidableRel {n : ℕ} (F : GraphFiltration V n) (i : ℕ) :
    DecidableRel (F.graphAt i).Adj := by
  induction i with
  | zero => unfold GraphFiltration.graphAt; infer_instance
  | succ k ih =>
    unfold GraphFiltration.graphAt
    split
    · exact addEdge_decidableRel _ _ _
    · exact ih

/-- Valid filtration: each new edge is not already present. -/
def GraphFiltration.isValid {n : ℕ} (F : GraphFiltration V n) : Prop :=
  ∀ i : Fin n, ¬(F.graphAt i).Adj (F.edges i).1 (F.edges i).2

/-- The event type at step i. -/
def GraphFiltration.eventAt {n : ℕ} (F : GraphFiltration V n) (i : Fin n) : EdgeEventType :=
  classifyEdge (F.graphAt i) (F.edges i).1 (F.edges i).2

/-- Whether step i is a cycle event. -/
def GraphFiltration.isCycleAt {n : ℕ} (F : GraphFiltration V n) (i : Fin n) : Bool :=
  if F.eventAt i = EdgeEventType.cycleEvent then true else false

/-- Whether step i is a merge event. -/
def GraphFiltration.isMergeAt {n : ℕ} (F : GraphFiltration V n) (i : Fin n) : Bool :=
  if F.eventAt i = EdgeEventType.mergeEvent then true else false

/-- Number of cycle events in the first k steps. -/
def GraphFiltration.cycleCount {n : ℕ} (F : GraphFiltration V n) (k : ℕ) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => i.val < k ∧ F.eventAt i = EdgeEventType.cycleEvent)).card

/-- Number of merge events in the first k steps. -/
def GraphFiltration.mergeCount {n : ℕ} (F : GraphFiltration V n) (k : ℕ) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => i.val < k ∧ F.eventAt i = EdgeEventType.mergeEvent)).card

/-! ## Theorem 2: Counting Theorems -/

/-
Each step is either a merge or a cycle event: merge + cycle = k.
-/
theorem filtration_merge_plus_cycle {n : ℕ} (F : GraphFiltration V n) (k : ℕ)
    (hk : k ≤ n) :
    F.mergeCount k + F.cycleCount k = k := by
  unfold GraphFiltration.mergeCount GraphFiltration.cycleCount;
  rw [ ← Finset.card_union_of_disjoint ];
  · rw [ show ( Finset.filter ( fun i : Fin n => ( i : ℕ ) < k ∧ F.eventAt i = EdgeEventType.mergeEvent ) Finset.univ ∪ Finset.filter ( fun i : Fin n => ( i : ℕ ) < k ∧ F.eventAt i = EdgeEventType.cycleEvent ) Finset.univ ) = Finset.filter ( fun i : Fin n => ( i : ℕ ) < k ) Finset.univ from ?_ ];
    · rw [ Finset.card_eq_of_bijective ];
      use fun i hi => ⟨ i, by linarith ⟩;
      · grind;
      · aesop;
      · aesop;
    · ext i; cases h : F.eventAt i <;> aesop;
  · exact Finset.disjoint_filter.mpr ( by aesop )

/-
**Global tropical Morse equality (cycle count)**:
    The number of cycle events equals β₁ of the final graph.
-/
theorem filtration_betti1_eq_cycleCount {n : ℕ} (F : GraphFiltration V n)
    (hvalid : F.isValid) :
    F.cycleCount n = graphBetti1 (F.graphAt n) := by
  -- First, prove the stronger statement that for all k ≤ n, cycleCount k (F) = graphBetti1 (graphAt k (F)).
  have h_cycle_count_eq_betti1 (k : ℕ) (hk : k ≤ n) : F.cycleCount k = graphBetti1 (F.graphAt k) := by
    induction' k with k ih;
    · simp +decide [ GraphFiltration.cycleCount ];
      -- The graph at step 0 is the empty graph, which has no edges.
      have h_empty : F.graphAt 0 = ⊥ := by
        rfl;
      simp +decide [ h_empty, graphBetti1 ];
      simp +decide [ h_empty, graphBetti0 ];
      simp +decide [ h_empty, SimpleGraph.edgeFinset ];
      rw [ eq_comm, tsub_eq_zero_iff_le ];
      exact Fintype.card_le_of_surjective _ ( show Function.Surjective ( fun v : V => ( ⊥ : SimpleGraph V ).connectedComponentMk v ) from fun x => by rcases x with ⟨ x ⟩ ; exact ⟨ x, rfl ⟩ );
    · -- By definition of `cycleCount`, we have:
      have h_cycleCount_succ : F.cycleCount (k + 1) = F.cycleCount k + (if F.eventAt ⟨k, by linarith⟩ = EdgeEventType.cycleEvent then 1 else 0) := by
        unfold GraphFiltration.cycleCount;
        split_ifs <;> simp_all +decide [ Finset.filter_or, Finset.filter_and ];
        · rw [ show ( Finset.filter ( fun a : Fin n => ( a : ℕ ) ≤ k ) Finset.univ ∩ Finset.filter ( fun a : Fin n => F.eventAt a = EdgeEventType.cycleEvent ) Finset.univ ) = Finset.filter ( fun a : Fin n => ( a : ℕ ) < k ) Finset.univ ∩ Finset.filter ( fun a : Fin n => F.eventAt a = EdgeEventType.cycleEvent ) Finset.univ ∪ { ⟨ k, by linarith ⟩ } from ?_, Finset.card_union ] <;> norm_num;
          grind;
        · congr 1 with a ; simp +decide [ Nat.lt_succ_iff ];
          grind;
      -- By definition of `graphAt`, we have:
      have h_graphAt_succ : F.graphAt (k + 1) = addEdge (F.graphAt k) (F.edges ⟨k, by linarith⟩).1 (F.edges ⟨k, by linarith⟩).2 := by
        exact dif_pos ( Nat.lt_of_succ_le hk );
      split_ifs at * <;> simp_all +decide [ GraphFiltration.eventAt ];
      · rw [ ih ( Nat.le_of_succ_le hk ), betti1_addEdge_of_reachable ];
        · exact F.distinct _;
        · exact hvalid ⟨ k, by linarith ⟩;
        · unfold classifyEdge at *; aesop;
      · rw [ ih ( Nat.le_of_succ_le hk ), betti1_addEdge_of_not_reachable ];
        · exact F.distinct _;
        · exact hvalid ⟨ k, by linarith ⟩;
        · unfold classifyEdge at * ; aesop;
  exact h_cycle_count_eq_betti1 n le_rfl

/-
**Global tropical Morse equality (merge count)**:
    The number of merge events = |V| - β₀(final graph).
-/
theorem filtration_rank_eq_mergeCount {n : ℕ} (F : GraphFiltration V n)
    (hvalid : F.isValid) :
    F.mergeCount n + graphBetti0 (F.graphAt n) = Fintype.card V := by
  -- Prove by induction on k (with k ≤ n), showing mergeCount k + graphBetti0 (graphAt k) = Fintype.card V.
  have h_ind : ∀ k ≤ n, F.mergeCount k + graphBetti0 (F.graphAt k) = Fintype.card V := by
    intro k hk
    induction' k with k ih
    generalize_proofs at *; (
    unfold GraphFiltration.mergeCount GraphFiltration.graphAt;
    simp +decide [ graphBetti0 ];
    refine' Fintype.card_congr _;
    symm;
    refine' Equiv.ofBijective ( fun v => SimpleGraph.connectedComponentMk _ v ) ⟨ fun v w h => _, fun c => _ ⟩ <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
    · rw [ Quot.eq ] at h;
      induction h <;> aesop;
    · exact c.exists_rep);
    -- By definition of `mergeCount`, we have:
    have h_mergeCount_succ : F.mergeCount (k + 1) = F.mergeCount k + if F.eventAt ⟨k, hk⟩ = EdgeEventType.mergeEvent then 1 else 0 := by
      unfold GraphFiltration.mergeCount; simp +decide [ Finset.sum_ite, Finset.filter_or, Finset.filter_and ] ;
      rw [ show ( Finset.filter ( fun a : Fin n => ( a : ℕ ) ≤ k ) Finset.univ ∩ Finset.filter ( fun a : Fin n => F.eventAt a = EdgeEventType.mergeEvent ) Finset.univ ) = Finset.filter ( fun a : Fin n => ( a : ℕ ) < k ) Finset.univ ∩ Finset.filter ( fun a : Fin n => F.eventAt a = EdgeEventType.mergeEvent ) Finset.univ ∪ if F.eventAt ⟨ k, hk ⟩ = EdgeEventType.mergeEvent then { ⟨ k, hk ⟩ } else ∅ from ?_, Finset.card_union ] ; aesop;
      grind;
    -- By definition of `graphAt`, we have:
    have h_graphAt_succ : F.graphAt (k + 1) = addEdge (F.graphAt k) (F.edges ⟨k, hk⟩).1 (F.edges ⟨k, hk⟩).2 := by
      exact dif_pos ( Nat.lt_of_succ_le hk );
    split_ifs at * <;> simp_all +decide [ GraphFiltration.eventAt ];
    · unfold classifyEdge at *;
      have := betti0_addEdge_of_not_reachable ( F.graphAt k ) ( F.edges ⟨ k, hk ⟩ |>.1 ) ( F.edges ⟨ k, hk ⟩ |>.2 ) ( F.distinct ⟨ k, hk ⟩ ) ( by aesop ) ; linarith [ ih ( Nat.le_of_succ_le hk ) ] ;
    · rw [ ← ih ( Nat.le_of_succ_le hk ), betti0_addEdge_of_reachable ];
      unfold classifyEdge at * ; aesop;
  exact h_ind n le_rfl

/-- **Euler relation from Morse data**: combining the two Morse equalities. -/
theorem euler_from_morse {n : ℕ} (F : GraphFiltration V n)
    (hvalid : F.isValid) :
    graphBetti1 (F.graphAt n) + Fintype.card V =
    (F.graphAt n).edgeFinset.card + graphBetti0 (F.graphAt n) := by
  unfold graphBetti1
  have hge := edgeFinset_card_add_betti0_ge (F.graphAt n)
  omega

/-! ## Tropical Critical Values -/

/-- A filtration index is tropically critical if it changes the topology. -/
def GraphFiltration.isCritical {n : ℕ} (F : GraphFiltration V n) (i : Fin n) : Prop :=
  graphBetti0 (F.graphAt (i.val + 1)) ≠ graphBetti0 (F.graphAt i.val) ∨
  graphBetti1 (F.graphAt (i.val + 1)) ≠ graphBetti1 (F.graphAt i.val)

/-! ## Theorem 3: Critical iff Topology Jump -/

/-
**Phase transition characterization**: Every valid edge insertion
    is a critical point — it always changes the topology.
    This is the discrete analogue of a phase transition.
-/
theorem critical_iff_topology_jump {n : ℕ} (F : GraphFiltration V n) (i : Fin n)
    (hvalid : ¬(F.graphAt i.val).Adj (F.edges i).1 (F.edges i).2) :
    F.isCritical i := by
  have h_edge_insertion : (F.graphAt (i.val + 1)) = addEdge (F.graphAt i.val) (F.edges i).1 (F.edges i).2 := by
    rw [ GraphFiltration.graphAt ];
    simp +zetaDelta at *;
  by_cases hreach : (F.graphAt i.val).Reachable (F.edges i).1 (F.edges i).2 <;> simp_all +decide [ GraphFiltration.isCritical ];
  · exact Or.inr ( by rw [ betti1_addEdge_of_reachable _ _ _ ( by simpa using F.distinct i ) hvalid hreach ] ; omega );
  · exact Or.inl ( by linarith [ betti0_addEdge_of_not_reachable ( F.graphAt i.val ) ( F.edges i |>.1 ) ( F.edges i |>.2 ) ( F.distinct i ) hreach ] )

/-! ## Tropical Persistence -/

/-- The degree-1 tropical persistent rank: number of cycle classes born
    at or before step s. For graph filtrations, all cycle classes
    are born and never die, so this is the cumulative cycle count. -/
def tropicalPersistentRank1 {n : ℕ} (F : GraphFiltration V n) (s : ℕ) : ℕ :=
  F.cycleCount s

/-- The classical persistent rank in degree 1: β₁ at step s. -/
def classicalPersistentRank1 {n : ℕ} (F : GraphFiltration V n) (s : ℕ) : ℕ :=
  graphBetti1 (F.graphAt s)

/-
**Tropical persistence = classical persistence in degree 1**:
    The tropical persistent rank function agrees with the classical one.
-/
theorem tropical_persistence_eq_classical {n : ℕ} (F : GraphFiltration V n)
    (s : ℕ) (hs : s ≤ n) (hvalid : F.isValid) :
    tropicalPersistentRank1 F s = classicalPersistentRank1 F s := by
  unfold tropicalPersistentRank1 classicalPersistentRank1;
  induction' s with s ih;
  · unfold graphBetti1; simp +decide [ GraphFiltration.graphAt ] ;
    unfold GraphFiltration.cycleCount graphBetti0; simp +decide [ SimpleGraph.edgeFinset ] ;
    rw [ eq_comm, tsub_eq_zero_iff_le ];
    exact Fintype.card_le_of_surjective _ ( show Function.Surjective ( fun v => ( ⊥ : SimpleGraph V ).connectedComponentMk v ) from fun c => by rcases c with ⟨ v ⟩ ; exact ⟨ v, rfl ⟩ );
  · -- By definition of `cycleCount`, we have:
    have h_cycleCount_succ : F.cycleCount (s + 1) = F.cycleCount s + (if F.eventAt ⟨s, hs⟩ = EdgeEventType.cycleEvent then 1 else 0) := by
      unfold GraphFiltration.cycleCount;
      split_ifs <;> simp_all +decide [ Finset.filter_or, Finset.filter_and, Nat.lt_succ_iff ];
      · rw [ show ( Finset.filter ( fun a : Fin n => ( a : ℕ ) ≤ s ) Finset.univ ∩ Finset.filter ( fun a : Fin n => F.eventAt a = EdgeEventType.cycleEvent ) Finset.univ ) = Finset.filter ( fun a : Fin n => ( a : ℕ ) < s ) Finset.univ ∩ Finset.filter ( fun a : Fin n => F.eventAt a = EdgeEventType.cycleEvent ) Finset.univ ∪ { ⟨ s, hs ⟩ } from ?_, Finset.card_union ] <;> norm_num;
        grind;
      · congr 1 with a ; simp +decide [ Nat.lt_succ_iff ];
        grind +splitImp;
    -- By definition of `graphAt`, we have:
    have h_graphAt_succ : F.graphAt (s + 1) = addEdge (F.graphAt s) (F.edges ⟨s, hs⟩).1 (F.edges ⟨s, hs⟩).2 := by
      exact dif_pos ( Nat.lt_of_succ_le hs );
    split_ifs at * <;> simp_all +decide [ GraphFiltration.eventAt ];
    · rw [ ih ( Nat.le_of_succ_le hs ), betti1_addEdge_of_reachable ];
      · exact F.distinct _;
      · exact hvalid ⟨ s, hs ⟩;
      · unfold classifyEdge at *; aesop;
    · rw [ ih ( Nat.le_of_succ_le hs ), betti1_addEdge_of_not_reachable ];
      · exact F.distinct _;
      · exact hvalid ⟨ s, hs ⟩;
      · unfold classifyEdge at *; aesop;

/-! ## Statistical Mechanics Interpretation -/

/-- The susceptibility observable: β₀ as a function of filtration step. -/
def susceptibility {n : ℕ} (F : GraphFiltration V n) (i : ℕ) : ℕ :=
  graphBetti0 (F.graphAt i)

/-
**Phase transition theorem**: susceptibility jumps ↔ merge event.
-/
theorem susceptibility_jump_iff_merge {n : ℕ} (F : GraphFiltration V n)
    (i : Fin n) (hvalid : ¬(F.graphAt i.val).Adj (F.edges i).1 (F.edges i).2) :
    susceptibility F (i.val + 1) ≠ susceptibility F i.val ↔
    classifyEdge (F.graphAt i.val) (F.edges i).1 (F.edges i).2 = EdgeEventType.mergeEvent := by
  -- By definition of graphAt, F.graphAt (i+1) = addEdge (F.graphAt i) u v where (u,v) = F.edges i.
  have h_graphAt_succ : F.graphAt (i.val + 1) = addEdge (F.graphAt i.val) (F.edges i).1 (F.edges i).2 := by
    rw [ GraphFiltration.graphAt ];
    simp +decide [ Nat.succ_eq_add_one, i.2 ];
  by_cases h : ( F.graphAt i.val ).Reachable ( F.edges i |>.1 ) ( F.edges i |>.2 ) <;> simp_all +decide [ susceptibility, classifyEdge ];
  · convert betti0_addEdge_of_reachable _ _ _ h;
  · have := betti0_addEdge_of_not_reachable ( F.graphAt i.val ) ( F.edges i |>.1 ) ( F.edges i |>.2 ) ( F.distinct i ) h; aesop;

/-! ## Computational Algorithm -/

/-- Output of the tropical critical value computation. -/
structure FiltrationOutput where
  /-- Event type at each step -/
  events : List EdgeEventType
  /-- β₀ sequence -/
  betti0Seq : List ℕ
  /-- β₁ sequence -/
  betti1Seq : List ℕ

/-- Compute the filtration output for a graph filtration. -/
def computeFiltration {n : ℕ} (F : GraphFiltration V n) : FiltrationOutput where
  events := (List.finRange n).map (fun i => F.eventAt i)
  betti0Seq := (List.range (n + 1)).map (fun i => graphBetti0 (F.graphAt i))
  betti1Seq := (List.range (n + 1)).map (fun i => graphBetti1 (F.graphAt i))

end