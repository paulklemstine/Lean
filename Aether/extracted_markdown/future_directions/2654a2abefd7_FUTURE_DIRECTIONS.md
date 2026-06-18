# Future Directions: Overlap Class Theory for Tropical Kernel Rigidity

## Synthesis

The overlap class framework established in this work reveals that tropical kernel generators organize into independent interaction sectors governed by the support overlap graph. The four TPE invariants — class count, degree, complexity, and signature — form a hierarchy of increasingly fine invariants that capture the geometry of interacting cycle supports. The natural next step is to determine whether this hierarchy is *complete*: does the overlap class structure fully determine the TPE equivalence classes, or are there hidden variables? The directions below attack this question from different angles — direct algebraic proof, matroid generalization, computational enumeration, topological refinement, and physics-inspired decomposition. Each direction is independently valuable, but together they would establish overlap classes as a foundational concept in tropical combinatorial algebra.

---

## Direction 1: Overlap Rigidity Equality Conjecture

**Conjecture:** For every connected finite graph G, basepoint q, and subset S ⊆ V \ {q}, the number of tropical projective equivalence classes of minimal generating families for the tropical kernel on S equals the overlap class count of the cycle-support family in G[S].

**Test:** Enumerate all connected graphs on n ≤ 9 vertices. For each (G, q, S), compute the cycle-support family, the overlap class count, and (by exhaustive search over candidate generating families) the number of TPE classes. Report the first triple where the counts disagree.

**Impact:** If true, this would be a complete invariant theorem: overlap classes exactly classify tropical generators. It would mean the combinatorial topology of cycle supports completely governs the tropical algebra. If false, the counterexample would reveal the missing datum and likely launch a corrected invariant theory.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (disjoint-support uniqueness)
- `Catalog/Pythagorean/TropicalBridge/OverlapClassInvariants.lean` (TPE invariance of overlap class count)

**Proof Strategy:** Induction on overlap degree. Base case (degree 0) is the existing disjoint-support theorem. Inductive step: choose overlapping supports A, B, peel off an intersection vertex, compare generating families before and after. Control the correction term using the structural defect from `DefectTheory.lean`.

**Domain Bridges:** Coding theory (support overlap in minimum-weight codewords determines code equivalence classes); matroid theory (circuit overlap controls matroid connectivity).

**Lineage:** Directly extends `disjoint_support_unique_up_to_tropProjEquiv` from the catalog.

**Ambition:** Grand challenge — would establish a complete classification of tropical kernel generators.

---

## Direction 2: Matroid Circuit Overlap Theory

**Conjecture:** For any regular matroid M, the overlap class count of the circuit intersection graph is an invariant of the valuated matroid structure on the tropical kernel.

**Test:** Implement circuit enumeration for graphic matroids M(G) on small graphs (n ≤ 8). Compare circuit overlap invariants across matroid isomorphism classes. Check whether non-isomorphic matroids with identical circuit overlap profiles exist.

**Impact:** Would generalize the entire overlap theory from graphs to matroids, connecting tropical algebra to matroid theory at a structural level. Regular matroids include graphic, cographic, and R₁₀ matroids — the generalization would cover a significant class.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassInvariants.lean` (overlap class count as TPE invariant)
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` (cycle rank and structural defect)

**Proof Strategy:** The key insight is that circuit supports in a matroid satisfy the same exchange/elimination axioms as cycle supports in a graph. Define overlap equivalence for circuit supports, prove that valuated matroid isomorphisms (the matroid analogue of TPE) preserve the overlap relation.

**Domain Bridges:** Oriented matroid theory (chirotopes and circuit axioms); algebraic geometry (tropical linear spaces as valuated matroids).

**Lineage:** Builds on the matroidal invariance theorem `same_induced_structure_same_laplacian` from `TropicalKernelRigidity.lean`.

**Ambition:** Grand challenge — would unify tropical kernel theory with matroid circuit theory.

---

## Direction 3: Support Nerve and Higher-Order Overlaps

**Conjecture:** The overlap class count is determined by the homotopy type of the support nerve (the simplicial complex whose k-simplices are (k+1)-tuples of mutually overlapping supports). In particular, the number of overlap classes equals π₀ of the nerve.

**Test:** Compute the support nerve for cycle-support families on all connected graphs with n ≤ 7 vertices. Compare the nerve structure (Betti numbers, Euler characteristic) with the overlap signature. Identify cases where the nerve provides finer discrimination than the overlap graph alone.

**Impact:** Would connect the overlap theory to algebraic topology. The nerve theorem (Borsuk's theorem) relates the topology of a union of convex sets to the topology of their nerve. An analogous theorem for support nerves would provide topological invariants of tropical kernel structure.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassInvariants.lean` (overlap equivalence as connected components)

**Proof Strategy:** The key insight is that π₀ of the nerve equals the number of connected components of the overlap graph (the 1-skeleton of the nerve). For higher homotopy groups, one would need to analyze when triple and higher overlaps create nontrivial topology. The Mayer-Vietoris sequence applied to the support union should provide the connection.

**Domain Bridges:** Computational topology (persistent homology of support complexes); combinatorial Hodge theory (discrete Laplacians on simplicial complexes).

**Lineage:** Extends the pairwise overlap theory to higher-order interactions.

**Ambition:** Solid extension — the 0-dimensional part (π₀) is already proved; higher dimensions are new.

---

## Direction 4: Defect-Overlap Duality

**Conjecture:** The structural defect from `DefectTheory.lean` satisfies:

    structuralDefect(G, q, S) ≥ overlapClassCount(cycleSupportFamily(G, S)) - 1

with equality when the overlap graph is a tree (overlap degree one).

**Test:** Compute both sides for all connected graphs on n ≤ 7 vertices, all choices of q and S. Verify the inequality and identify cases of equality.

**Impact:** Would provide a precise bridge between the defect theory (which controls the gap between Laplacian rank and tropical divisor rank) and the overlap theory (which controls the structure of tropical generators). The inequality would be a new structural result; equality in the tree case would give a complete characterization.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` (structural defect, cycle rank, root component count)
- `Catalog/Pythagorean/TropicalBridge/OverlapClassInvariants.lean` (overlap class count)

**Proof Strategy:** The key insight is that the induced cycle rank β₁(G[S]) counts independent cycles, while the overlap class count counts interaction sectors. When overlap classes are disjoint (overlap degree 0), the defect reduces to β₁ + κ - 1 where κ is the root component count. Each overlap class contributes at least one to the cycle rank, giving the inequality.

**Domain Bridges:** Algebraic graph theory (spectral analysis of Laplacians); discrete Morse theory (critical cells and Betti numbers).

**Lineage:** Directly combines the two existing formalizations.

**Ambition:** Solid extension — inequality should be provable; equality characterization is harder.

---

## Direction 5: Algorithmic Overlap Decomposition for Tropical Computation

**Conjecture:** Computing the tropical kernel of a graph Laplacian can be reduced from O(|V|³) to O(Σᵢ |Cᵢ|³) where C₁, ..., Cₖ are the overlap classes and |Cᵢ| is the number of vertices in the union of supports in class i.

**Test:** Implement both the monolithic and decomposed algorithms. Benchmark on random graphs with n = 50, 100, 500, 1000 vertices. Measure wall-clock time and verify correctness.

**Impact:** Would make the overlap theory practically useful for large-scale computation. For graphs with many small overlap classes (e.g., sparse graphs with local cycle structure), the speedup could be dramatic — from cubic in V to cubic in the largest overlap class.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/OverlapClassInvariants.lean` (componentwise disjointness theorem)
- `Catalog/Pythagorean/TropicalBridge/OverlapClassRigidity.lean` (overlap class biUnion disjointness)

**Proof Strategy:** The key insight is that Theorem 3.8 (cross-class disjointness) guarantees that generators from different overlap classes live on disjoint vertex sets. This means the Laplacian restricted to each overlap class's vertex set can be analyzed independently. The correction terms from the boundary vertices (connecting to the basepoint q) add only linear overhead.

**Domain Bridges:** Numerical linear algebra (block-diagonal Laplacian solvers); network science (community detection as overlap class computation); distributed computing (independent sector processing).

**Lineage:** Builds on the componentwise factorization from the overlap theory.

**Ambition:** Solid extension with immediate practical applications.
