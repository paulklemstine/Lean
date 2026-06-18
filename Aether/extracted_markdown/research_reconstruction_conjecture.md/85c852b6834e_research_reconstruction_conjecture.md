# Formal Foundations of Graph Reconstruction Theory

**Abstract.** We develop a formal mathematical framework for the Graph Reconstruction Conjecture, formalizing key results in the Lean 4 proof assistant with full machine verification. Our contributions include: (1) formal proofs of edge-count reconstruction, degree-sequence reconstruction, and Kelly's lemma for edges; (2) a novel algebraic characterization of reconstruction invariants as a mathematical structure; (3) a formal proof that regularity is detectable from the deck with an if-and-only-if characterization; (4) concrete reconstruction results for complete graphs; and (5) a DeckFingerprint data structure enabling efficient computational testing. All proofs are machine-verified with no axioms beyond the standard foundations.

---

## 1. Introduction

The Graph Reconstruction Conjecture, independently proposed by Kelly [1] and Ulam [2], asserts that every simple graph on at least three vertices is determined up to isomorphism by the multiset of its vertex-deleted subgraphs. Despite being one of the most studied open problems in combinatorics, it remains unresolved after more than six decades.

The conjecture has been verified computationally for graphs up to 13 vertices [3] and proved for numerous special classes, including trees [1], regular graphs [4], disconnected graphs [5], and graphs with sufficiently many or few edges [6]. The fundamental technical tool is Kelly's Lemma, which shows that the subgraph census — the number of copies of any fixed graph H — is a reconstructible invariant.

In this work, we provide a complete formal development of the foundational theory of graph reconstruction in Lean 4, building on Mathlib's `SimpleGraph` library. Our formalization captures the key combinatorial arguments with full machine verification, establishing a rigorous foundation for future work on the conjecture.

## 2. Definitions

### 2.1 Basic Setup

We work with simple graphs `G : SimpleGraph V` where `V` is a finite type with decidable equality. The edge set is `G.edgeSet ⊆ Sym2 V`, and we use `G.edgeFinset` for the finitary version.

**Definition 2.1** (Non-incident edges). For a vertex `v : V`, the *non-incident edges* are:
```
nonIncidentEdges G v := G.edgeFinset.filter (fun e => v ∉ e)
```
This equals the edge set of the vertex-deleted subgraph `G - v`.

**Definition 2.2** (Deck card edge count). The edge count of the `v`-th deck card is:
```
deckCardEdges G v := (nonIncidentEdges G v).card
```

**Definition 2.3** (Vertex-deleted subgraph). The formal vertex-deleted subgraph at `v` is:
```
vertexDeletedGraph G v := G.induce {w : V | w ≠ v}
```
This is a `SimpleGraph` on the subtype `{w : V | w ≠ v}`.

### 2.2 Reconstruction Invariants

**Definition 2.4** (ReconstructionInvariant). A *reconstruction invariant* is a structure consisting of:
- A function `val : SimpleGraph V → ℕ` assigning a value to each graph
- A function `from_deck : Multiset ℕ → ℕ` computing the value from deck edge counts
- A proof `spec` that `val G = from_deck (deck edge counts of G)` for all `G`

This captures the abstract notion of a graph parameter being "reconstructible from the deck."

### 2.3 DeckFingerprint

**Definition 2.5** (DeckFingerprint). A *DeckFingerprint* records:
- `vertexCount : ℕ`
- `edgeCount : ℕ`
- `deckEdgeCounts : List ℕ` (sorted)
- Proof that the list has length equal to vertex count
- Proof that the list is sorted
- Proof of the consistency condition: `sum = (vertexCount - 2) * edgeCount`

This is a novel computational invariant for efficient graph discrimination.

### 2.4 Isomorphic Decks and the Conjecture

**Definition 2.6** (Isomorphic decks). Two graphs `G₁, G₂ : SimpleGraph V` have *isomorphic decks* if there exists a permutation `σ : V ≃ V` such that for all `v`, the vertex-deleted subgraphs `G₁ - v` and `G₂ - σ(v)` are isomorphic.

**Definition 2.7** (Reconstruction Conjecture). For all finite types `V` with `|V| ≥ 3`, if `G₁` and `G₂` have isomorphic decks, then `G₁ ≅ G₂`.

## 3. Main Results

### 3.1 Edge Partition Identity

**Theorem 3.1** (Edge partition). For any `v : V`:
```
(G.edgeFinset.filter (v ∈ ·)).card + (nonIncidentEdges G v).card = G.edgeFinset.card
```

*Proof.* This follows from `Finset.card_filter_add_card_filter_not`, since every edge either contains `v` or does not. □

### 3.2 Degree from Deck Card

**Theorem 3.2** (Degree reconstruction). For any `v : V`:
```
G.degree v = G.edgeFinset.card - deckCardEdges G v
```

*Proof.* The edges incident to `v` are precisely `G.incidenceFinset v`, which has cardinality `G.degree v` (by `card_incidenceFinset_eq_degree`). These are exactly the edges in `G.edgeFinset` that contain `v`. By the partition identity (Theorem 3.1), `G.degree v + deckCardEdges G v = G.edgeFinset.card`, giving the result after rearrangement. □

**Corollary 3.3.** `G.degree v + deckCardEdges G v = G.edgeFinset.card`

### 3.3 Edge Sum Formula (Kelly's Lemma for Edges)

**Theorem 3.4** (Edge sum formula). If `|V| ≥ 2`:
```
∑ v, deckCardEdges G v = (|V| - 2) * G.edgeFinset.card
```

*Proof.* By double counting. We have:
```
∑ v, deckCardEdges G v = ∑ v, |{e ∈ E(G) | v ∉ e}|
                       = ∑ e ∈ E(G), |{v | v ∉ e}|
```
The swap is justified by `Finset.sum_comm`. For each edge `e = {a, b}` with `a ≠ b` (since `G` is simple), the set `{v | v ∉ e}` has cardinality `|V| - 2`. This gives the result. □

**Corollary 3.5** (Edge count from deck). If `|V| ≥ 3`:
```
G.edgeFinset.card * (|V| - 2) = ∑ v, deckCardEdges G v
```

### 3.4 Handshaking Lemma via Deck

**Theorem 3.6.** `∑ v, (G.edgeFinset.card - deckCardEdges G v) = 2 * G.edgeFinset.card`

*Proof.* By Theorem 3.2, each summand equals `G.degree v`. The result follows from the classical handshaking lemma `∑ v, G.degree v = 2 * |E|`. □

### 3.5 Complement Edge Reconstruction

**Theorem 3.7.** `G.edgeFinset.card + Gᶜ.edgeFinset.card = |V| * (|V| - 1) / 2`

*Proof.* The edges of `G` and `Gᶜ` partition the complete graph's edges. We show that the union of `G.edgeFinset` and `Gᶜ.edgeFinset` equals the edge set of the complete graph, using disjointness (`G.Adj a b` and `¬G.Adj a b` are exclusive) and completeness (for `a ≠ b`, either `G.Adj a b` or `¬G.Adj a b`). □

### 3.6 Regularity Characterization

**Theorem 3.8** (Regularity from deck). If `G` is `k`-regular, then for all `v`:
```
deckCardEdges G v = G.edgeFinset.card - k
```

*Proof.* Since `G.degree v = k`, Theorem 3.2 gives `k = |E| - deckCardEdges G v`. □

**Theorem 3.9** (Uniform deck ⟹ regular). If all deck cards have the same edge count, then `G` is regular.

*Proof.* If `deckCardEdges G u = deckCardEdges G v` for all `u, v`, then by Theorem 3.2, `G.degree u = |E| - deckCardEdges G u = |E| - deckCardEdges G v = G.degree v`. So all degrees are equal. □

**Theorem 3.10** (Regular ⟹ constant deck). If `G` is `k`-regular, then `deckCardEdges G u = deckCardEdges G v` for all `u, v`.

These three theorems together give:
> **A graph is regular if and only if all its deck cards have the same edge count.**

### 3.7 Complete Graph Results

**Theorem 3.11.** For `n ≥ 1` and `v : Fin n`, the degree of `v` in `K_n` is `n - 1`.

**Theorem 3.12.** `K_n` has `n(n-1)/2` edges.

**Theorem 3.13.** For `n ≥ 2`, each deck card of `K_n` has `(n-1)(n-2)/2` edges. (Each card is `K_{n-1}`.)

## 4. Algorithms

### 4.1 Edge Count Reconstruction Algorithm

```
INPUT:  Deck D = [G₁, ..., Gₙ] (vertex-deleted subgraphs)
OUTPUT: |E(G)|

1. Compute S = Σᵢ |E(Gᵢ)|
2. Return S / (n - 2)
```

*Correctness:* By Theorem 3.4, `S = (n-2) * |E(G)|`.

### 4.2 Degree Sequence Reconstruction Algorithm

```
INPUT:  Deck D = [G₁, ..., Gₙ], total edge count |E|
OUTPUT: Degree sequence [d₁, ..., dₙ]

For each i = 1, ..., n:
  dᵢ = |E| - |E(Gᵢ)|
Return sorted [d₁, ..., dₙ]
```

*Correctness:* By Theorem 3.2, `dᵢ = G.degree vᵢ`.

### 4.3 Regularity Detection Algorithm

```
INPUT:  Deck D = [G₁, ..., Gₙ]
OUTPUT: (is_regular, k)

1. Compute edge counts [|E(G₁)|, ..., |E(Gₙ)|]
2. If all equal, return (True, |E|/n) where |E| = reconstruction
3. Else return (False, -1)
```

*Correctness:* By Theorems 3.8–3.10.

## 5. The DeckFingerprint Invariant

The DeckFingerprint provides a practical tool for computational exploration of the reconstruction conjecture. It captures the sorted profile of deck card edge counts, which is a necessary condition for graph isomorphism.

**Proposition 5.1.** If `G₁ ≅ G₂`, then `DeckFingerprint(G₁) = DeckFingerprint(G₂)`.

**Conjecture 5.2** (DeckFingerprint Separation). For graphs on at most 11 vertices, the DeckFingerprint together with the degree sequence determines the graph up to isomorphism.

This is a testable conjecture: it can be verified computationally by enumerating all graphs on ≤ 11 vertices and checking whether any two non-isomorphic graphs share both a DeckFingerprint and degree sequence.

## 6. Discussion

Our formalization captures the core "first layer" of reconstruction theory — the arguments that involve only counting edges and vertices. The deeper results (Kelly's full lemma for arbitrary subgraphs, tree reconstruction, regular graph reconstruction) require additional machinery:

1. **Kelly's full lemma** needs a formal count of labeled subgraph copies and induction on the number of vertices of the pattern graph.
2. **Tree reconstruction** (Kelly's theorem) requires formalized tree theory, including the notion of rooted trees and their automorphism groups.
3. **Regular graph reconstruction** builds on our regularity characterization but also requires matching-theoretic arguments.

The `ReconstructionInvariant` structure provides a clean abstraction for organizing future formalization work: each reconstructible parameter can be packaged as an instance, building a library of invariants.

## 7. Future Work

1. Formalize Kelly's full lemma for arbitrary subgraph counts
2. Prove reconstruction for trees (Kelly's theorem, 1957)
3. Formalize the edge reconstruction conjecture (Harary, 1964)
4. Explore connections to Turán-type extremal graph theory
5. Formalize Lovász's result connecting reconstruction to graph homomorphism counts

## References

1. P. J. Kelly, "A congruence theorem for trees," *Pacific J. Math.*, 7(1):961–968, 1957.
2. S. M. Ulam, *A Collection of Mathematical Problems*, Wiley, 1960.
3. B. D. McKay, "Small graphs are reconstructible," *Australas. J. Combin.*, 15:123–126, 1997.
4. W. T. Tutte, "All the king's horses," in *Graph Theory and Related Topics*, Academic Press, 1979.
5. J. A. Bondy, "A graph reconstructor's manual," in *Surveys in Combinatorics*, London Math. Soc. Lecture Note Ser. 166, 1991.
6. J. A. Bondy and R. L. Hemminger, "Graph reconstruction — a survey," *J. Graph Theory*, 1(3):227–268, 1977.
