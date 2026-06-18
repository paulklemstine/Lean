# Future Directions: Overlap Class Theory

## Synthesis

The overlap class theory established in this work reveals that the interaction pattern of cycle supports — captured by the support overlap graph and its connected components — is a fundamental invariant of tropical projective equivalence. The key structural results (invariance under support matching, automatic disjointness across overlap classes, recovery of the disjoint-support uniqueness theorem) provide the foundation for several ambitious research directions. These directions span tropical geometry, matroid theory, coding theory, and network science, unified by the central theme: **local overlap patterns control global algebraic structure**.

The directions below are ordered by proximity to current results. Directions 1–3 extend the established framework directly. Directions 4–5 are grand challenges that could reshape entire subfields.

---

## Direction 1: The Overlap Rigidity Conjecture — Equality of Class Counts

**Conjecture.** For every connected finite graph G, basepoint q, and vertex subset S ⊆ V \ {q}, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in G[S].

**Test.** Enumerate all connected graphs on n ≤ 9 vertices. For each (G, q, S) triple, compute both the overlap class count (via the support overlap graph) and the tropical projective equivalence class count (via explicit kernel computation). Report the first (G, q, S) where they differ.

**Impact.** If true, this elevates the overlap class decomposition from a structural invariant to a *complete* invariant of the tropical kernel equivalence structure. It would mean that the combinatorial topology of cycle overlaps fully determines the algebraic complexity of the kernel. If false, the counterexample reveals the "hidden variable" — additional data beyond overlap that affects the algebra.

**Catalog References.**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — overlap class definitions and invariance theorems
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — TropProjEquiv and disjoint-support uniqueness

**Proof Strategy.** Induction on overlap degree using the monotonicity theorem (`overlapDegree_mono_of_subset`). Base case: overlap degree zero, which reduces to the recovery theorem (`overlapDegree_zero_recovers_uniqueness`). Inductive step: choose an overlapping pair, split along a minimal separator, and show the overlap degree strictly decreases.

**Domain Bridges.** Matroid theory (circuit intersection graph), coding theory (support interaction classes).

**Lineage.** Extends `overlapDegree_zero_recovers_uniqueness` and `overlapEquiv_iff_support_matching`.

**Ambition.** Grand challenge — would unify tropical linear algebra with combinatorial topology.

---

## Direction 2: Componentwise Factorization of TropProjEquiv

**Conjecture.** If the support overlap graph of a generating family decomposes into connected components C₁, …, Cₖ, then the TropProjEquiv relation factors as a product over components:

TropProjEquivClassCount(G, q, S) = ∏ᵢ TropProjEquivClassCount(G, q, Sᵢ)

where Sᵢ is the union of supports in component Cᵢ.

**Test.** For each (G, q, S) with disconnected overlap graph, verify that the total class count equals the product of component class counts.

**Impact.** Even without proving the full Overlap Rigidity Conjecture, componentwise factorization would be a major structural theorem. It says that overlap classes are truly independent interaction sectors — the algebraic content decomposes multiplicatively, just as partition functions decomposes multiplicatively in statistical physics over independent subsystems.

**Catalog References.**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — `disjoint_of_not_overlapEquiv`, `overlapEquiv_equivalence`
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` — `inducedCycleRank`, `structuralDefect`

**Proof Strategy.** Use the disjointness theorem (`disjoint_of_not_overlapEquiv`) to show that generators in different overlap classes have disjoint supports. Then apply the existing disjoint-support machinery to show that the permutation σ in TropProjEquiv must permute within each component.

**Domain Bridges.** Statistical physics (partition function factorization), network science (modular decomposition).

**Lineage.** Directly extends `overlapEquiv_iff_support_matching`.

**Ambition.** Solid extension — likely provable with current methods.

---

## Direction 3: Overlap-Degree-One Uniqueness

**Conjecture.** When every pair of distinct cycle supports intersects in at most one vertex (overlap degree at most 1 on each edge), the tropical projective equivalence class is unique within each overlap component.

**Test.** Enumerate all connected graphs on n ≤ 8 with max overlap degree 1. Verify uniqueness of TropProjEquiv classes within each overlap component.

**Impact.** This is the first uniqueness theorem genuinely beyond the disjoint-support regime. It would establish that "thin" overlaps (single shared vertices) do not create additional algebraic freedom.

**Catalog References.**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — `MaxOverlapDeg`, `CrossOverlapCount`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `disjoint_support_unique_up_to_tropProjEquiv`

**Proof Strategy.** When two supports share exactly one vertex v, the overlap at v creates a single algebraic constraint. Show that this constraint forces the constant shifts in TropProjEquiv to be compatible, reducing to the disjoint case after "resolving" each overlap vertex.

**Domain Bridges.** Graph minor theory (vertex cuts), matroid circuit elimination.

**Lineage.** Extends `overlapDegree_zero_recovers_uniqueness` to the next complexity level.

**Ambition.** Solid extension — requires new techniques for handling single-vertex overlaps.

---

## Direction 4: Matroid-Level Generalization

**Conjecture.** The overlap class theory extends from graphic matroids to all regular matroids. Specifically, for any regular matroid M, the circuit overlap graph of M controls the tropical projective equivalence classes of the tropical kernel of M's representation matrix.

**Test.** Implement the overlap class framework for the Fano matroid (which is not graphic) and verify the invariance theorem. Then test on the non-Fano matroid and other small non-graphic matroids.

**Impact.** This would be field-opening: it would establish overlap classes as a universal invariant of tropical linear algebra over matroids, not just graphs. The framework would immediately apply to all representable matroids and potentially to valuated matroids.

**Catalog References.**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — all overlap class machinery (stated over arbitrary finset families, so already matroid-ready)
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `same_induced_structure_same_laplacian` (matroidal invariance)

**Proof Strategy.** The definitions (`SupportsOverlap`, `OverlapEquiv`, etc.) are already parameterized over arbitrary finset families, not just graph-derived ones. The missing piece is the connection to tropical kernels of matroid representation matrices. Formalize the matroid circuit support family and verify that the invariance theorem transfers.

**Domain Bridges.** Matroid theory, tropical geometry, algebraic combinatorics.

**Lineage.** Extends `same_induced_structure_same_laplacian`.

**Ambition.** Grand challenge — would connect two major areas of algebraic combinatorics.

---

## Direction 5: Overlap Nerve and Higher-Order Interactions

**Conjecture.** The support overlap graph is too coarse: the correct invariant is the **overlap nerve** (the simplicial complex whose k-simplices are (k+1)-tuples of supports with nonempty common intersection). The Betti numbers of the nerve, together with the overlap signature, form a complete invariant for TropProjEquiv class counts.

**Test.** Compute the nerve complex for all connected graphs on n ≤ 7 vertices. Compare its Betti numbers with TropProjEquiv class counts. Find two examples with identical overlap graphs but different nerves, and check whether the nerve distinguishes their class counts.

**Impact.** If the nerve (not just its 1-skeleton, the overlap graph) is the correct invariant, this would connect tropical kernel theory to combinatorial topology in a deep way. The Betti numbers of the nerve would encode "higher-order interactions" invisible to the pairwise overlap graph.

**Catalog References.**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` — overlap graph and classes
- `Catalog/Pythagorean/TropicalBridge/OverlapSupport.lean` — interaction energy decomposition

**Proof Strategy.** Define the nerve as a simplicial complex. Prove that it refines the overlap graph (its 1-skeleton is the overlap graph). Show that if the nerve has nontrivial higher Betti numbers, the corresponding overlap class must contain additional algebraic structure.

**Domain Bridges.** Algebraic topology (nerve theorem, persistent homology), topological data analysis.

**Lineage.** Extends the overlap graph to its natural simplicial generalization.

**Ambition.** Grand challenge — would establish a new connection between algebraic topology and tropical algebra.
