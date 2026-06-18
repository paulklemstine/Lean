# Future Directions: Overlap Class Rigidity Theory

## Synthesis

The overlap class framework has revealed that the algebraic structure of tropical kernel generators decomposes naturally along the connected components of the support overlap graph. The key insight threading through all future directions below is that **overlap classes are the correct interaction sectors for tropical geometry on graphs**: they capture precisely which generators can influence each other and which are algebraically independent. The proven factorization theorem and TPE invariance results provide the foundation for a much deeper theory connecting tropical algebra, matroid theory, coding theory, and network science. Each direction below builds on this foundation to probe a different facet of the interaction between combinatorial overlap and algebraic structure.

---

## Direction 1: Overlap Class Conjecture — Exact Equality

**Conjecture:** For every connected finite graph G, basepoint q, and subset S ⊆ V \ {q}, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in G[S].

**Test:** Enumerate all connected graphs on n ≤ 9 vertices. For each (G, q, S), compute the cycle support family, the overlap class count, and (when feasible) the TPE class count. Report any mismatch.

**Impact:** If true, this would establish overlap classes as a *complete invariant* of tropical kernel generators — meaning the combinatorial overlap pattern alone determines the algebraic structure. This would be a fundamental result connecting tropical linear algebra to graph combinatorics. If false, the first counterexample reveals the "hidden variable" — the additional data beyond overlap needed to control tropical generators.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (overlap class definitions, factorization theorem, TPE invariance); `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (disjoint-support uniqueness).

**Proof Strategy:** Strategy B (component factorization) from the overlap theory. First prove that TPE classes factor over overlap components, then show each component contributes exactly one class. The factorization step is already partially established by `tropProjEquiv_preserves_varOverlapEquiv`. The single-class-per-component step would require showing that within an overlap class, any two minimal generating families are TPE-related — this is the hard open step.

**Domain Bridges:** Matroid theory (circuit intersection graphs), coding theory (support profiles of minimum codewords), algebraic geometry (tropical Grassmannians).

**Lineage:** Extends `overlapDegree_zero_recovers_uniqueness` and `overlapClassCount_eq_of_pairwiseDisjoint_nonempty` from the current catalog.

**Ambition:** Grand challenge — would be a breakthrough result in tropical combinatorics.

---

## Direction 2: Overlap-Degree-One Uniqueness

**Conjecture:** When every pair of distinct cycle supports in G[S] intersects in at most one vertex (max overlap degree ≤ 1), the minimal generating family is unique up to tropical projective equivalence within each overlap class.

**Test:** Enumerate graphs with max overlap degree 1 on n ≤ 8 vertices. For each, verify uniqueness of TPE class within each overlap component by exhaustive enumeration.

**Impact:** This would be the first genuinely new rigidity theorem beyond the pairwise-disjoint case. It covers a large family of graphs (trees with a single added edge, cactus graphs, etc.) and provides the inductive base case for a potential full overlap theory.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (MaxOverlapDeg, overlapDegree_eq_zero_iff_pairwiseDisjoint); `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` (inducedCycleRank).

**Proof Strategy:** Strategy A (induction on overlap degree via peeling). When max overlap degree ≤ 1, each overlap is a single shared vertex. Peel off the shared vertex and apply the disjoint-support theorem to the residual family. The correction term from the peeled vertex should be controlled by the harmonic leaf rigidity theorem.

**Domain Bridges:** Cactus graphs and seriesparallel networks (electrical engineering), block-cut tree decompositions (graph theory).

**Lineage:** Direct extension of `disjoint_support_unique_up_to_tropProjEquiv` via the overlap degree peeling strategy.

**Ambition:** Solid extension — achievable with focused effort, high mathematical value.

---

## Direction 3: Matroid-Level Generalization

**Conjecture:** The overlap class factorization theorem generalizes from graphic matroids to all regular matroids: for a regular matroid M, the connected components of the circuit intersection graph of M provide independent sectors for tropical kernel generators of the associated totally unimodular matrix.

**Test:** Verify the factorization theorem computationally for all regular matroids on ground sets of size ≤ 12, using standard matroid enumeration databases.

**Impact:** This would elevate the overlap theory from a graph-specific result to a matroid-theoretic one, opening connections to tropical geometry of linear spaces, valuated matroids, and oriented matroids. The key insight is that circuit intersection structure is a matroid property, not just a graph property.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (SupportOverlapGraph, overlap_class_unions_disjoint); `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (SameInducedStructure, same_induced_structure_same_laplacian).

**Proof Strategy:** Strategy C (matroid-circuit reformulation). Restate the overlap definitions using circuit supports in an abstract matroid. The key lemma is that circuit elimination preserves overlap class structure — when two circuits share an element and we eliminate it, the resulting circuit stays within the same overlap class.

**Domain Bridges:** Matroid theory (circuit axioms, regular matroids), tropical geometry (tropical linear spaces, Dressians), optimization (network flows on totally unimodular matrices).

**Lineage:** Generalizes `same_induced_structure_same_laplacian` from graph isomorphism to matroid isomorphism.

**Ambition:** Grand challenge — would connect overlap theory to a major branch of combinatorics.

---

## Direction 4: Support Nerve and Higher-Order Overlaps

**Conjecture:** The support nerve (simplicial complex whose k-simplices are (k+1)-tuples of mutually overlapping supports) provides strictly more information than the overlap graph for controlling TPE classes. Specifically, there exist support families with isomorphic overlap graphs but non-isomorphic support nerves that have different TPE class counts.

**Test:** Construct explicit families of 4–6 supports with identical overlap graphs but different nerve structures (e.g., same 1-skeleton but different 2-simplices). Compare TPE class counts computationally.

**Impact:** This would identify the correct level of combinatorial complexity needed for a complete invariant theory. If the nerve is sufficient but the graph is not, this pins down exactly where the "hidden variables" live — in the higher-order interactions among supports.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (OverlapSignature, CrossOverlapCount).

**Proof Strategy:** Define the support nerve as a simplicial complex in Lean. Prove that the overlap graph is its 1-skeleton. Show that nerve isomorphism is preserved by TPE (extending `tropProjEquiv_preserves_varOverlapEquiv`). Construct explicit counterexamples to graph-level sufficiency using small families with controlled triple intersections.

**Domain Bridges:** Combinatorial topology (nerve theorems, Čech complexes), persistent homology (topological data analysis), algebraic topology (simplicial cohomology).

**Lineage:** Extends `tropProjEquiv_preserves_varOverlapEquiv` from pairwise to higher-order overlap preservation.

**Ambition:** Solid extension — the definitions are clear and the counterexample search is computationally feasible.

---

## Direction 5: Algorithmic Classification via Overlap Invariants

**Conjecture:** The triple (overlap degree, overlap class count, overlap signature) provides a polynomial-time computable graph invariant that distinguishes all non-isomorphic connected graphs on n ≤ 12 vertices, modulo a small number of collisions that can be resolved by the support nerve.

**Test:** Compute the triple for all connected graphs on n ≤ 10 vertices. Measure the collision rate and characterize the graphs that collide. Test whether nerve refinement resolves all collisions.

**Impact:** This would provide a practical new graph invariant with deep algebraic meaning. Unlike purely structural invariants (degree sequence, spectrum), the overlap invariant reflects the *cycle interaction structure* — a fundamentally different aspect of graph topology. The key insight is that overlap classes encode information about the cycle space that is invisible to edge-counting or spectral methods.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (OverlapDegree, overlapClassCount, OverlapSignature).

**Proof Strategy:** Implement efficient algorithms for computing cycle supports (using spanning tree + non-tree edges), build the overlap graph in O(n² · max_support_size), and compute connected components in O(n). Benchmark against existing graph invariants on standard graph databases.

**Domain Bridges:** Graph isomorphism testing (computer science), chemical graph theory (molecular fingerprinting), social network analysis (community detection).

**Lineage:** Builds on the computational infrastructure developed alongside the formal theory.

**Ambition:** Solid extension with immediate practical applications in graph classification and network analysis.
