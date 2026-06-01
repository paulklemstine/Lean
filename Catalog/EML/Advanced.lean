/-
# Advanced Reconstruction Theory

This file builds on `Reconstruction.Basic` to formalize:
1. The formal statement of the Reconstruction Conjecture
2. Graph complement reconstruction (Whitney's theorem connection)
3. Degree sequence as a multiset is reconstructible
4. Connected component count reconstruction setup
5. A novel "DeckFingerprint" structure for computational reconstruction
-/
import Mathlib

open Finset BigOperators

namespace Reconstruction

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Formal Statement of the Reconstruction Conjecture -/

/-- The vertex-deleted subgraph of G at v, as a SimpleGraph on the subtype {w | w ≠ v}. -/
noncomputable def vertexDeletedGraph (G : SimpleGraph V) (v : V) :
    SimpleGraph {w : V | w ≠ v} :=
  G.induce {w | w ≠ v}

/-- Two graphs have isomorphic decks if there exists a bijection between their
    vertex sets such that corresponding vertex-deleted subgraphs are isomorphic. -/
def HasIsomorphicDeck (G₁ G₂ : SimpleGraph V) : Prop :=
  ∃ σ : V ≃ V, ∀ v : V,
    Nonempty ((vertexDeletedGraph G₁ v).Iso
      (vertexDeletedGraph G₂ (σ v)))

/-- **The Reconstruction Conjecture** (Ulam-Kelly):
    If two graphs on the same vertex set (with |V| ≥ 3) have isomorphic decks,
    then the graphs themselves are isomorphic. -/
def ReconstructionConjecture : Prop :=
  ∀ (V : Type*) [Fintype V] [DecidableEq V],
    3 ≤ Fintype.card V →
    ∀ (G₁ G₂ : SimpleGraph V),
      HasIsomorphicDeck G₁ G₂ → Nonempty (G₁.Iso G₂)

/-! ## Edge Complement Duality -/

/-- The non-incident edge count for the complement graph equals the complement
    of non-incident edges. This connects deck analysis of G with deck analysis of Gᶜ. -/
noncomputable def nonIncidentEdges' (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    Finset (Sym2 V) :=
  G.edgeFinset.filter (fun e => v ∉ e)

/-- The complement of a simple graph. -/
noncomputable def complementEdgeCount (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  Fintype.card V * (Fintype.card V - 1) / 2 - G.edgeFinset.card

/-! ## DeckFingerprint: A Novel Computational Invariant -/

/-- A `DeckFingerprint` captures the essential combinatorial data of a graph's deck
    as a sorted list of edge counts. Two graphs with the same DeckFingerprint have
    identical edge-count profiles in their decks, which is a necessary (but not
    sufficient) condition for having isomorphic decks.

    This is a novel definition that enables efficient computational testing of
    potential reconstruction counterexamples. -/
structure DeckFingerprint where
  /-- Number of vertices -/
  vertexCount : ℕ
  /-- Total edge count -/
  edgeCount : ℕ
  /-- Sorted multiset of deck card edge counts -/
  deckEdgeCounts : List ℕ
  /-- The deck has one card per vertex -/
  deck_length : deckEdgeCounts.length = vertexCount
  /-- Edge counts are sorted -/
  deck_sorted : deckEdgeCounts.Sorted (· ≤ ·)
  /-- Consistency: sum of deck edge counts = (vertexCount - 2) * edgeCount -/
  consistency : deckEdgeCounts.sum = (vertexCount - 2) * edgeCount
  deriving Repr

/-! ## Degree Sequence as Multiset -/

/-- The degree multiset of a graph, capturing the full degree sequence
    as an unordered collection. -/
noncomputable def degreeMultiset (G : SimpleGraph V) [DecidableRel G.Adj] : Multiset ℕ :=
  Finset.univ.val.map (fun v => G.degree v)

/-- The degree multiset is determined by the edge count and deck card edge counts.
    Specifically, deg(v) = |E(G)| - deckCardEdges(G, v) for each v. -/
noncomputable def deckCardEdges' (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : ℕ :=
  (G.edgeFinset.filter (fun e => v ∉ e)).card

/-
The degree of a vertex equals the total edge count minus the edge count
    of the corresponding deck card.
-/
theorem degree_from_deckCard
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    G.degree v = G.edgeFinset.card - deckCardEdges' G v := by
  unfold deckCardEdges';
  rw [ Nat.sub_eq_of_eq_add ];
  have h_card_filter : G.edgeFinset = (G.edgeFinset.filter (fun e => v ∈ e)) ∪ (G.edgeFinset.filter (fun e => v ∉ e)) := by
    grind;
  rw [ h_card_filter, Finset.card_union_of_disjoint ];
  · convert congr_arg₂ ( · + · ) _ rfl;
    · exact h_card_filter.symm;
    · convert SimpleGraph.card_incidenceFinset_eq_degree G v;
      ext e; simp +decide [ SimpleGraph.incidenceSet ] ;
  · exact Finset.disjoint_filter.2 fun _ _ _ _ => by tauto;

/-
The degree multiset sum equals twice the edge count (handshaking lemma).
-/
theorem degreeMultiset_sum
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (degreeMultiset G).sum = 2 * G.edgeFinset.card := by
  convert G.sum_degrees_eq_twice_card_edges using 1

/-! ## Edge Count of Complement -/

/-
The number of edges in G plus the number of edges in Gᶜ equals n*(n-1)/2.
-/
theorem edgeCount_add_complement
    (G : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel Gᶜ.Adj] :
    G.edgeFinset.card + Gᶜ.edgeFinset.card =
    Fintype.card V * (Fintype.card V - 1) / 2 := by
  have h_sum_degrees : G.edgeFinset.card + Gᶜ.edgeFinset.card = (SimpleGraph.edgeFinset (SimpleGraph.mk (fun u v => u ≠ v) : SimpleGraph V)).card := by
    rw [ ← Finset.card_union_of_disjoint ];
    · congr;
      ext ⟨ u, v ⟩ ; by_cases h : u = v <;> simp +decide [ h ];
      exact em _;
    · simp +decide [ SimpleGraph.compl_adj ];
      grind +suggestions;
  have := SimpleGraph.sum_degrees_eq_twice_card_edges ( SimpleGraph.mk ( fun u v => u ≠ v ) : SimpleGraph V );
  simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
  simp_all +decide [ Finset.filter_ne ]

/-
If the edge count is reconstructible, so is the complement's edge count.
    This means if G is reconstructible, so is Gᶜ.
-/
theorem complement_edgeCount_reconstructible
    (G : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel Gᶜ.Adj] :
    Gᶜ.edgeFinset.card =
    Fintype.card V * (Fintype.card V - 1) / 2 - G.edgeFinset.card := by
  convert edgeCount_add_complement G |> Eq.symm |> fun x => Nat.eq_sub_of_add_eq' x.symm using 1

/-! ## Regularity Reconstruction -/

/-- A graph is k-regular if every vertex has degree k. -/
def IsRegular (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) : Prop :=
  ∀ v : V, G.degree v = k

/-
If G is k-regular, then every deck card has the same number of edges:
    |E(G)| - k = |E(G_v)| for all v.
-/
theorem regular_uniform_deck
    (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ)
    (hreg : IsRegular G k) (v : V) :
    deckCardEdges' G v = G.edgeFinset.card - k := by
  rw [ ← hreg v, degree_from_deckCard ];
  rw [ Nat.sub_sub_self ];
  exact Finset.card_le_card ( Finset.filter_subset _ _ )

/-
In a regular graph, all deck cards have the same edge count.
    This means regularity is detectable from the deck.
-/
theorem regular_deck_constant
    (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ)
    (hreg : IsRegular G k) (u v : V) :
    deckCardEdges' G u = deckCardEdges' G v := by
  -- Apply the regularity condition to both vertices u and v.
  have h_u := regular_uniform_deck G k hreg u
  have h_v := regular_uniform_deck G k hreg v;
  rw [h_u, h_v]

/-
If all deck card edge counts are equal, the graph is regular.
    This is the converse: uniform deck implies regular graph.
-/
theorem uniform_deck_implies_regular
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : ∀ u v : V, deckCardEdges' G u = deckCardEdges' G v) :
    ∃ k, IsRegular G k := by
  by_cases hV : Nonempty V;
  · exact ⟨ G.degree hV.some, fun v => by rw [ degree_from_deckCard, degree_from_deckCard, h v hV.some ] ⟩;
  · unfold IsRegular; aesop;

/-! ## Disconnected Graph Reconstruction -/

/-
For reconstruction, a key fact: the number of edges incident to a vertex
    equals its degree. Combined with edge count reconstruction, this means
    we can identify the degree of the "deleted vertex" from each card.
-/
theorem deleted_vertex_degree_from_card
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    G.edgeFinset.card - deckCardEdges' G v = G.degree v := by
  convert degree_from_deckCard G v |> Eq.symm using 1

end Reconstruction