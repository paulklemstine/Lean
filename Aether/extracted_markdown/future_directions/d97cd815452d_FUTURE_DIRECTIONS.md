# Future Directions: Graph Reconstruction Theory

## Synthesis

This research cycle established formal foundations for the Graph Reconstruction Conjecture, proving edge-count reconstruction, degree-sequence reconstruction, regularity characterization, and Kelly's lemma for edges. The key insight is that double-counting arguments — swapping summation order between vertices and edges — provide the cleanest path to reconstruction results. Our novel `ReconstructionInvariant` structure and `DeckFingerprint` data type offer new tools for organizing and computing reconstruction invariants.

The most promising cross-domain connection is between reconstruction theory and the Catalog's extremal combinatorics work (Erdős–Szekeres, cup-cap bounds). Both fields rely on double-counting and pigeonhole arguments applied to finite structures. The regularity-detection theorem (uniform deck ⟺ regular graph) connects to spectral graph theory, where regular graphs have known eigenvalue properties — bridging combinatorial reconstruction with algebraic invariants.

The highest breakthrough potential lies in Direction 1 (Kelly's Full Lemma), because it would unlock a cascade of reconstruction results for specific graph classes, and in Direction 3 (Spectral Reconstruction), which could provide the algebraic machinery needed for the full conjecture via Lovász's homomorphism framework.

---

### Direction 1: Full Kelly's Lemma for Arbitrary Subgraph Counts

**Conjecture**: For any simple graph H on h vertices and any simple graph G on n ≥ h + 1 vertices, the number of labeled copies of H in G satisfies: (n − h) · s(H, G) = Σ_{v ∈ V(G)} s(H, G−v), where s(H, G) counts injective homomorphisms from H to G that preserve adjacency.

**Test**: Verify computationally for all graphs H with ≤ 4 vertices and all graphs G with ≤ 8 vertices. Compute both sides of the identity and check equality.

**Impact**: This is the central tool of reconstruction theory. Once formalized, it immediately proves that the number of triangles, paths, cycles, and all small subgraph counts are reconstructible. It would also formalize the foundation for Lovász's result that almost all graphs are reconstructible.

**Catalog References**: `Catalog/Geometry/ErdosSzekeres/CupsCaps.lean` (double-counting techniques), `Reconstruction/Basic.lean` (edge-version proved)

**Proof Strategy**: Define `labeledCopyCount H G` as the cardinality of `{f : V(H) ↪ V(G) | ∀ a b, H.Adj a b → G.Adj (f a) (f b)}`. Prove that each copy f contributes to exactly (n − h) terms in the sum Σ_v s(H, G−v), namely those v not in the image of f. The double-counting swap is identical to our edge sum proof but generalized. Key lemma: for f : V(H) ↪ V(G), the set {v ∈ V(G) | v ∉ range f} has cardinality n − h.

**Domain Bridges**: Reconstruction Theory ↔ Extremal Combinatorics (subgraph counting)

**Lineage**: Extends the edge-version Kelly's lemma proved in this cycle (`kelly_edge_version` in `Reconstruction/Basic.lean`)

**Ambition**: grand_challenge

---

### Direction 2: Formal Reconstruction of Trees (Kelly's Theorem)

**Conjecture**: Every tree on n ≥ 3 vertices is reconstructible. That is, if T₁ and T₂ are trees on the same vertex set with isomorphic decks, then T₁ ≅ T₂.

**Test**: Enumerate all trees on ≤ 12 vertices (using Prüfer sequences), compute decks, and verify that no two non-isomorphic trees share a deck. This extends known computational verification.

**Impact**: Trees were the original case proved by Kelly (1957) and remain the most elegant special case. A formalization would demonstrate that the formal framework handles structural induction on graphs effectively.

**Catalog References**: `Reconstruction/Advanced.lean` (degree sequence reconstruction), `Reconstruction/Basic.lean` (edge count reconstruction)

**Proof Strategy**: The classical proof uses induction on the number of vertices. Key steps: (1) The number of leaves is reconstructible (vertices of degree 1, which are reconstructible by degree reconstruction). (2) The number of edges is n−1 for any tree, which is reconstructible. (3) By Kelly's lemma, the number of paths of any length is reconstructible. (4) The pendant edges determine the tree structure inductively. Formally, define `IsTree G` as connected and acyclic, show these properties are reconstructible.

**Domain Bridges**: Reconstruction Theory ↔ Algebraic Combinatorics (Prüfer sequences, tree enumeration)

**Lineage**: Builds on degree sequence reconstruction from this cycle

**Ambition**: grand_challenge

---

### Direction 3: Spectral Reconstruction Invariants

**Conjecture**: The characteristic polynomial of the adjacency matrix of a graph G is reconstructible from the deck. Equivalently, all eigenvalues (with multiplicities) of the adjacency matrix can be computed from the deck cards' characteristic polynomials via a generalization of the edge-sum formula.

**Test**: For all graphs on ≤ 8 vertices, compute the adjacency matrix eigenvalues of G and all deck cards. Verify that the coefficients of the characteristic polynomial of G satisfy the Schwenk relations: n·aₖ(G) = Σ_v aₖ(G−v) + Σ_v aₖ₋₂(G−v−N(v)) where aₖ is the k-th coefficient. (Here N(v) represents contributions from edges incident to v.)

**Impact**: If the characteristic polynomial is reconstructible, this provides a powerful algebraic invariant. Combined with the fact that cospectral non-isomorphic graphs become rare as n grows, this would bring spectral graph theory into the reconstruction framework.

**Catalog References**: `Reconstruction/Advanced.lean` (complement edge reconstruction uses spectral-adjacent arguments)

**Proof Strategy**: Formalize `Matrix.charpoly` for the adjacency matrix of a `SimpleGraph`. Use the Schwenk recursion for characteristic polynomials: χ(G, x) = x·χ(G−v, x) − Σ_{w~v} χ(G−v−w, x) − 2·Σ_{cycles through v} χ(G − cycle, x). Show that summing over v and applying Kelly's lemma recovers each coefficient of χ(G, x). This requires formalizing the relationship between graph structure and matrix algebra in Lean.

**Domain Bridges**: Graph Reconstruction ↔ Spectral Graph Theory ↔ Linear Algebra

**Lineage**: Builds on edge and degree reconstruction from this cycle; connects to matrix theory in Mathlib

**Ambition**: extension

---

### Direction 4: DeckFingerprint Separation Power

**Conjecture**: For graphs on n ≤ 11 vertices, the DeckFingerprint (sorted multiset of deck card edge counts) together with the degree sequence uniquely determines the graph up to isomorphism. That is, no two non-isomorphic graphs on ≤ 11 vertices share both a DeckFingerprint and a degree sequence.

**Test**: Enumerate all graphs on n = 4, 5, 6, 7, 8 vertices using nauty/geng. For each pair of non-isomorphic graphs, compute their DeckFingerprints and degree sequences. Report any collisions. Extend to n = 9, 10, 11 if computationally feasible.

**Impact**: If true for small n, this validates the DeckFingerprint as a practical reconstruction tool. If false, the counterexample reveals what additional invariant (triangle count, etc.) is needed. Either outcome advances understanding of the "information content" of the deck's edge-count profile.

**Catalog References**: `Reconstruction/Advanced.lean` (DeckFingerprint definition), `Reconstruction/Basic.lean` (edge-count reconstruction)

**Proof Strategy**: Primarily computational. Implement efficient DeckFingerprint computation using canonical graph labeling (nauty). For any collisions found, analyze what structural difference the DeckFingerprint misses and propose augmented fingerprints. Formally, prove that DeckFingerprint is an isomorphism invariant (if G₁ ≅ G₂ then Fingerprint(G₁) = Fingerprint(G₂)).

**Domain Bridges**: Graph Reconstruction ↔ Computational Graph Theory ↔ Information Theory

**Lineage**: Builds on DeckFingerprint definition from this cycle

**Ambition**: extension

---

### Direction 5: Edge Reconstruction Conjecture (Harary)

**Conjecture** (Harary, 1964): Every simple graph on n ≥ 4 edges is determined up to isomorphism by the multiset of its edge-deleted subgraphs. That is, the "edge deck" {G − e : e ∈ E(G)} determines G.

**Test**: Verify computationally for all graphs with ≤ 12 edges. For each pair of non-isomorphic graphs with the same number of edges, check if their edge decks are isomorphic as multisets.

**Impact**: The edge reconstruction conjecture is closely related to the vertex version but uses a fundamentally different deck. Proving results about it would complete the picture of reconstruction theory. The edge version is known to imply the vertex version for graphs with enough edges.

**Catalog References**: `Reconstruction/Basic.lean` (vertex reconstruction), `Reconstruction/Advanced.lean` (complement reconstruction)

**Proof Strategy**: Define the edge deck formally: `edgeDeck G := Multiset.map (fun e => G.deleteEdge e) G.edgeFinset.val`. Prove the edge-analogue of the edge-sum formula: each vertex appears in exactly (deg(v)) of the edge-deleted subgraphs. Prove that the vertex count is reconstructible from the edge deck. Establish the relationship: if G has |E| ≥ (n choose 2) / 2, then edge-reconstructibility implies vertex-reconstructibility.

**Domain Bridges**: Edge Reconstruction ↔ Vertex Reconstruction ↔ Matroid Theory

**Lineage**: Natural companion to vertex reconstruction from this cycle

**Ambition**: extension
