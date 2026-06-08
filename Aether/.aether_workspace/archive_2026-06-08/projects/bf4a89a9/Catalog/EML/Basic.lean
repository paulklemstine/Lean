/-
# Graph Reconstruction Conjecture — Foundations

The Reconstruction Conjecture (Ulam, 1960; Kelly, 1957) asserts that every
simple graph on at least 3 vertices is determined up to isomorphism by the
multiset of its vertex-deleted subgraphs (the "deck").

This file formalizes:
1. The deck of a graph and the notion of reconstructibility
2. Edge-count reconstruction from the deck
3. Degree-sequence reconstruction
4. A novel "ReconstructionInvariant" structure capturing graph parameters
   that can be recovered from the deck
-/
import Mathlib

open Finset BigOperators

namespace Reconstruction

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Core Definitions -/

/-- The set of edges of G not incident to vertex v.
    This equals the edge set of the vertex-deleted subgraph G - v. -/
noncomputable def nonIncidentEdges (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    Finset (Sym2 V) :=
  G.edgeFinset.filter (fun e => v ∉ e)

/-- The number of edges in the vertex-deleted subgraph at v,
    computed as edges of G not incident to v. -/
noncomputable def deckCardEdges (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : ℕ :=
  (nonIncidentEdges G v).card

/-- A `ReconstructionInvariant` is a graph parameter that can be recovered
    from the deck — i.e., it depends only on the multiset of vertex-deleted
    edge counts and structure, not on the labeling. This is a novel abstraction
    capturing what it means for a quantity to be "reconstructible". -/
structure ReconstructionInvariant (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The invariant value for a graph -/
  val : (G : SimpleGraph V) → [DecidableRel G.Adj] → ℕ
  /-- The invariant can be computed from the multiset of deck card edge counts -/
  from_deck : Multiset ℕ → ℕ
  /-- Correctness: the invariant equals what the deck formula produces -/
  spec : ∀ (G : SimpleGraph V) [DecidableRel G.Adj],
    val G = from_deck (Finset.univ.val.map (fun v => deckCardEdges G v))

/-! ## Edge-Count Reconstruction -/

/-
Key identity: the edges incident to v are exactly those in G but not in G-v.
    Therefore deg(v) = |E(G)| - |E(G-v)|.
-/
theorem degree_eq_edgeFinset_sub_deckCard
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    G.degree v = G.edgeFinset.card - deckCardEdges G v := by
  unfold deckCardEdges;
  rw [ Nat.sub_eq_of_eq_add ];
  rw [ ← SimpleGraph.card_incidenceFinset_eq_degree ];
  rw [ ← Finset.card_union_of_disjoint ];
  · congr with e ; by_cases he : v ∈ e <;> simp +decide [ he, SimpleGraph.incidenceFinset ];
    · simp +decide [ SimpleGraph.incidenceSet, nonIncidentEdges, he ];
    · simp +decide [ he, SimpleGraph.incidenceSet, nonIncidentEdges ];
  · simp +decide [ Finset.disjoint_left, nonIncidentEdges ];
    exact fun e he₁ he₂ => he₁.2

/-
The edges incident to v plus the non-incident edges partition the edge set.
-/
theorem incidentEdges_add_nonIncident
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    (G.edgeFinset.filter (fun e => v ∈ e)).card + (nonIncidentEdges G v).card =
    G.edgeFinset.card := by
  unfold nonIncidentEdges;
  rw [ Finset.card_filter_add_card_filter_not ]

/-
Each edge of G is non-incident to exactly (|V| - 2) vertices.
    An edge {a,b} is incident to a and b, and non-incident to all other vertices.
-/
theorem sum_deckCardEdges_eq
    (G : SimpleGraph V) [DecidableRel G.Adj] (hn : 2 ≤ Fintype.card V) :
    ∑ v : V, deckCardEdges G v = (Fintype.card V - 2) * G.edgeFinset.card := by
  -- For each edge $e = \{a, b\}$, there are $|V| - 2$ vertices $v$ such that $v \notin e$.
  have h_card : ∀ e ∈ G.edgeFinset, (Finset.filter (fun v => v ∉ e) Finset.univ).card = Fintype.card V - 2 := by
    intro e he
    have h_card_filter : (Finset.filter (fun v => v ∈ e) Finset.univ).card = 2 := by
      rcases e with ⟨ a, b ⟩;
      by_cases hab : a = b <;> simp_all +decide [ Finset.filter_eq', Finset.filter_or ];
    rw [ ← h_card_filter, Finset.filter_not, Finset.card_sdiff ] ; aesop;
  -- By double-counting, the sum of the number of non-incident edges for each vertex is equal to the sum over all edges of the number of vertices not incident to each edge.
  have h_double_count : ∑ v : V, (Finset.filter (fun e => v ∉ e) G.edgeFinset).card = ∑ e ∈ G.edgeFinset, (Finset.filter (fun v => v ∉ e) Finset.univ).card := by
    simp +decide only [card_filter];
    exact Finset.sum_comm;
  simpa [ mul_comm, Finset.sum_congr rfl h_card ] using h_double_count

/-
The total number of edges is reconstructible from the deck:
    |E(G)| = (∑ deck card edges) / (|V| - 2).
    This is the fundamental edge-reconstruction formula.
-/
theorem edgeCount_from_deck
    (G : SimpleGraph V) [DecidableRel G.Adj] (hn : 3 ≤ Fintype.card V) :
    G.edgeFinset.card * (Fintype.card V - 2) =
    ∑ v : V, deckCardEdges G v := by
  rw [ Nat.mul_comm, Reconstruction.sum_deckCardEdges_eq ];
  grind

/-! ## Degree Sequence Reconstruction -/

/-
The degree of each vertex can be recovered from the deck.
    If we know |E(G)| (which is reconstructible) and the edge count
    of each card, then deg(v) = |E(G)| - deckCardEdges(G, v).
-/
theorem degree_reconstructible
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    G.degree v + deckCardEdges G v = G.edgeFinset.card := by
  rw [ degree_eq_edgeFinset_sub_deckCard ];
  rw [ Nat.sub_add_cancel ];
  exact Finset.card_le_card ( Finset.filter_subset _ _ )

/-
The sum of all degrees equals twice the number of edges.
    This is the handshaking lemma, which we use as a consistency check.
-/
theorem handshaking_via_deck
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ v : V, (G.edgeFinset.card - deckCardEdges G v) =
    2 * G.edgeFinset.card := by
  rw [ ← SimpleGraph.sum_degrees_eq_twice_card_edges ];
  exact Finset.sum_congr rfl fun v _ => by rw [ degree_eq_edgeFinset_sub_deckCard ] ;

/-! ## Kelly's Lemma Setup -/

/-- Count of labeled copies of a pattern graph H in G.
    This counts the number of injective graph homomorphisms from H to G
    (up to automorphisms of H, this gives the subgraph count). -/
noncomputable def labeledCopyCount
    {W : Type*} [Fintype W] [DecidableEq W]
    (H : SimpleGraph W) [DecidableRel H.Adj]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  Fintype.card { f : W ↪ V // ∀ a b, H.Adj a b → G.Adj (f a) (f b) }

/-
Kelly's Lemma (edge-counting version): For the complete graph K₂ (a single edge),
    the number of edges times (|V| - 2) equals the sum over all v of the
    number of edges in G-v. This is our edge sum formula restated.
-/
theorem kelly_edge_version
    (G : SimpleGraph V) [DecidableRel G.Adj] (hn : 2 ≤ Fintype.card V) :
    (Fintype.card V - 2) * G.edgeFinset.card =
    ∑ v : V, deckCardEdges G v := by
  exact?

/-! ## Concrete Example: Complete Graph Reconstruction -/

/-
In the complete graph on Fin n (n ≥ 1), every vertex has degree n-1.
-/
theorem completeGraph_degree (n : ℕ) (hn : 1 ≤ n) (v : Fin n) :
    (⊤ : SimpleGraph (Fin n)).degree v = n - 1 := by
  simp +decide [ Finset.filter_ne, Finset.card_sdiff ]

/-
The complete graph on n vertices has n*(n-1)/2 edges.
-/
theorem completeGraph_edgeCount (n : ℕ) :
    (⊤ : SimpleGraph (Fin n)).edgeFinset.card = n * (n - 1) / 2 := by
  convert Finset.card_powersetCard 2 ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Finset.card_bij _ _ _ _;
    use fun a ha => Finset.univ.filter ( fun x => x ∈ a );
    · simp +decide [ powersetCard_one ];
      rintro ⟨ a, b ⟩ hab; rw [ Finset.card_eq_two ] ; use a, b; aesop;
    · simp +contextual [ Finset.ext_iff, Set.ext_iff ];
      intro a₁ ha₁ a₂ ha₂ h; ext x; specialize h x; aesop;
    · intro b hb; rw [ Finset.mem_powersetCard ] at hb; rcases Finset.card_eq_two.mp hb.2 with ⟨ x, y, hxy ⟩ ; use s(x, y); aesop;
  · simp +decide [ Nat.choose_two_right ]

/-
Each deck card of K_n is K_{n-1}, so has (n-1)*(n-2)/2 edges.
-/
theorem completeGraph_deckCard_edges (n : ℕ) (hn : 2 ≤ n) (v : Fin n) :
    deckCardEdges (⊤ : SimpleGraph (Fin n)) v = (n - 1) * (n - 2) / 2 := by
  -- Using the degree_reconstructible theorem, we can express the deckCardEdges in terms of the total edge count and the degree of v.
  have h_deckCardEdges : deckCardEdges (⊤ : SimpleGraph (Fin n)) v = (n * (n - 1) / 2) - (n - 1) := by
    -- By definition of deckCardEdges, we have deckCardEdges (⊤ : SimpleGraph (Fin n)) v = (edgeFinset (⊤ : SimpleGraph (Fin n))).card - degree (⊤ : SimpleGraph (Fin n)) v.
    have h_deckCardEdges_def : deckCardEdges (⊤ : SimpleGraph (Fin n)) v = (⊤ : SimpleGraph (Fin n)).edgeFinset.card - (⊤ : SimpleGraph (Fin n)).degree v := by
      rw [ eq_comm, Nat.sub_eq_of_eq_add ];
      rw [ add_comm, degree_reconstructible ];
    rw [ h_deckCardEdges_def, completeGraph_degree ];
    · rw [ completeGraph_edgeCount ];
    · grind +qlia;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ mul_comm ];
  grind

end Reconstruction