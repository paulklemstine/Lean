# Future Directions

## Synthesis

This research cycle established the formal foundations of **overlap class theory**, proving that the overlap class count is a tropical projective equivalence (TPE) invariant and developing the peeling lemma as the key inductive tool. The most significant cross-domain connection is between tropical kernel theory and coding theory via the support interaction matrix — both fields study collections of vectors with prescribed support patterns, and overlap classes provide a unified framework for analyzing when generators/codewords can be treated independently.

The peeling lemma opens the most promising avenue: it provides a constructive descent from any overlapping configuration to a disjoint one, and the number of steps equals the overlap complexity. This suggests that the overlap class conjecture might be proved by tracking how TPE classes transform under peeling — if each peeling step preserves the TPE class count, the result follows by induction from the disjoint-support theorem. The infrastructure is now in place: `peeling_reduces_complexity` (proved in `Pythagorean/OverlapClassConjecture.lean`) provides the descent, and `tpe_preserves_overlap_class_count` ensures the invariant is well-defined.

The highest breakthrough potential lies in Direction 1 (proving the overlap class conjecture for overlap rank 1), as this would establish the inductive base case and likely reveal the proof technique for the general case. Direction 3 (the Tutte polynomial connection) has the highest theoretical impact, as it would embed overlap class theory into the rich framework of graph polynomials.

---

### Direction 1: Overlap Class Conjecture for Rank 1

**Conjecture**: For any family of n supports with exactly one pair of overlapping supports (overlap rank 1), the number of TPE classes of minimal tropical kernel generators equals n - 1 (one less than the disjoint case, since the overlapping pair merges into one class).

**Test**: Enumerate all connected graphs on ≤ 8 vertices whose fundamental cycles have exactly one pair of overlapping supports. For each, compute all minimal generating families, quotient by TPE, and compare the class count against n - 1.

**Impact**: If true, this establishes the base case for an inductive proof of the full overlap class conjecture. If false, the counterexample structure would reveal what additional information beyond overlap class count is needed.

**Catalog References**: `Pythagorean/OverlapClassConjecture.lean` (overlap_class_count_eq_of_disjoint, peeling_reduces_complexity, tpe_preserves_overlap_class_count), `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (disjoint_support_unique_up_to_tropProjEquiv)

**Proof Strategy**: Start with the disjoint-support uniqueness theorem. When exactly one pair (i, j) overlaps, apply a single peeling step to separate them. Show that the peeling step maps TPE classes to TPE classes, and that the resulting disjoint family has a unique TPE class. Then count the preimages of the peeling map to get the class count.

**Domain Bridges**: Tropical Geometry <-> Combinatorial Topology (cycle spaces), Algebra <-> Graph Theory

**Lineage**: Directly extends `disjoint_support_unique_up_to_tropProjEquiv` from `TropicalKernelRigidity.lean` and builds on the peeling lemma from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Weighted Overlap Classes and Graded Descent

**Conjecture**: Define the **weighted overlap complexity** as WOC(F) = Σ_{i<j} |F_i ∩ F_j|². The peeling lemma extends: removing a shared element x from F_i reduces WOC by exactly 2·(number of other supports containing x) - 1. This gives a refined descent that tracks not just total overlap but its distribution.

**Test**: Compute WOC for random families of size 10-20 with varying overlap densities. Verify the exact descent formula by comparing WOC before and after each peeling step.

**Impact**: A refined descent would give tighter bounds on peeling step counts and potentially identify canonical peeling orders (always peel elements shared by the most supports first). This could lead to a canonical form for overlapping families.

**Catalog References**: `Pythagorean/OverlapClassConjecture.lean` (OverlapComplexity, peeling_reduces_complexity), `Pythagorean/TropicalBridge/OverlapClassTheory.lean` (OverlapSignature)

**Proof Strategy**: Express WOC as a sum of squares. When peeling x from F_i, the change in |F_i ∩ F_j|² for each j with x ∈ F_j is (k-1)² - k² = -2k+1 where k = |F_i ∩ F_j|. Sum over all such j. This is a direct calculation amenable to Lean formalization.

**Domain Bridges**: Tropical Geometry <-> Combinatorics (extremal set theory)

**Lineage**: Extends the overlap complexity from this cycle to a quadratic version. Builds on the peeling lemma infrastructure.

**Ambition**: extension

---

### Direction 3: Overlap Classes and the Tutte Polynomial

**Conjecture**: For a connected graph G, the overlap class count of the fundamental cycle supports (with respect to any spanning tree) is determined by the Tutte polynomial T_G(x, y) evaluated at specific points. Specifically, the overlap class count for a random spanning tree equals the expected number of connected components of the cycle-edge intersection graph, which should be expressible as a Tutte polynomial evaluation.

**Test**: Compute the overlap class count for all spanning trees of small graphs (K4, K5, Petersen graph) and compare against Tutte polynomial evaluations. If a formula exists, verify it for all connected graphs on ≤ 7 vertices.

**Impact**: Would embed overlap class theory into the deep framework of graph polynomials, connecting to knot theory, statistical mechanics, and algebraic geometry. The Tutte polynomial is a universal graph invariant, so this would show overlap class theory is a natural part of graph theory's core machinery.

**Catalog References**: `Pythagorean/OverlapClassConjecture.lean` (overlapClassCount', OverlapGraph), `Pythagorean/TropicalBridge/DefectTheory.lean` (inducedCycleRank)

**Proof Strategy**: First establish that the overlap class count depends only on the matroid of the graph (not the specific embedding). Then express it as a matroid invariant. By the universality of the Tutte polynomial for matroid invariants, derive the evaluation formula.

**Domain Bridges**: Tropical Geometry <-> Algebraic Combinatorics (Tutte polynomial), Graph Theory <-> Statistical Mechanics (Potts model)

**Lineage**: Extends the matroid connection (overlap rank) from this cycle. Connects to the Catalog's existing graph theory infrastructure.

**Ambition**: grand_challenge

---

### Direction 4: Algorithmic Overlap Class Computation for Large Graphs

**Conjecture**: The overlap class count of fundamental cycle supports can be computed in O(|E|² · α(|V|)) time using union-find, without explicitly constructing the supports. The key insight is that two fundamental cycles share an edge iff their defining non-tree edges have tree paths that share an edge.

**Test**: Implement the algorithm and benchmark against naive computation on random graphs with 100-10000 vertices. Verify correctness against the brute-force method for graphs up to 100 vertices.

**Impact**: Would make the overlap class conjecture computationally testable for graphs far beyond the current n ≤ 9 limit, potentially providing counterexamples or strong empirical evidence. A fast algorithm also has applications in network analysis and coding theory.

**Catalog References**: `Pythagorean/OverlapClassConjecture.lean` (compute_overlap_classes in the Python implementation), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: Model each fundamental cycle's edge set as a path in the spanning tree plus one non-tree edge. Two cycles share edges iff their tree paths overlap. Use an Euler tour of the spanning tree to represent paths as intervals, then reduce edge-overlap detection to interval intersection detection, which can be done efficiently with sorting.

**Domain Bridges**: Tropical Geometry <-> Algorithms (computational complexity), Graph Theory <-> Data Structures

**Lineage**: Algorithmic version of the mathematical framework from this cycle.

**Ambition**: extension

---

### Direction 5: Overlap Classes in Higher-Dimensional Tropical Varieties

**Conjecture**: The overlap class framework extends to higher-dimensional tropical varieties (tropical linear spaces, tropical curves in ℝⁿ). For a tropical linear space of dimension d, the overlap class count of the d-dimensional analogs of cycle supports is bounded by the f-vector of the matroid complex.

**Test**: Compute overlap classes for the tropical Grassmannian Gr(2, n) for n = 4, 5, 6, where the supports are the Plücker coordinate supports. Compare against matroid f-vector bounds.

**Impact**: Would extend overlap class theory from 1-dimensional (graphs) to higher-dimensional tropical geometry, potentially revealing new invariants of tropical varieties. This is the natural generalization suggested by the matroid-theoretic perspective.

**Catalog References**: `Pythagorean/OverlapClassConjecture.lean` (overlapRank, overlap_class_count_le), `Bridges/AlgebraEMLClosureComputation.lean` (ClosureSemimoduleSystem)

**Proof Strategy**: Define the higher-dimensional support family using the faces of the matroid complex. Prove that the overlap graph in this setting is the 1-skeleton of a simplicial complex (the "interaction complex"). Bound the number of connected components using the f-vector.

**Domain Bridges**: Tropical Geometry <-> Algebraic Geometry (Grassmannians), Combinatorics <-> Topology (simplicial complexes)

**Lineage**: Extends the overlap class framework from graphs (1D) to higher-dimensional tropical varieties. Builds on the matroid connection from this cycle.

**Ambition**: grand_challenge
