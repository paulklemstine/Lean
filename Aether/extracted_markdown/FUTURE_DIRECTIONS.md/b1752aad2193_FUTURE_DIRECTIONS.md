# Future Directions: Tropical Kernel Rigidity

## Synthesis

The tropical kernel rigidity theorem establishes that under support-separation hypotheses, the generators of a tropical graph Laplacian kernel are canonical up to permutation. This opens five interconnected research directions: extending the uniqueness to overlapping supports via a precise combinatorial formula (Direction 1), connecting the canonical generators to the chip-firing group (Direction 2), building a tropical Hodge theory for filtered graphs (Direction 3), developing algorithmic applications for graph classification (Direction 4), and bridging to continuous tropical geometry (Direction 5). Each direction builds directly on the formal infrastructure in `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` and related catalog files.

---

## Direction 1: Overlap Class Conjecture — Beyond Disjoint Supports

**Conjecture:** For every connected graph G, basepoint q, and S ⊆ V \ {q}, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in G[S].

**Test:** Enumerate all connected graphs on n ≤ 9 vertices, compute all minimal generating families, quotient by TropProjEquiv, and compare the class count against the cycle overlap class count. A single counterexample falsifies the conjecture; universal agreement up to n = 9 provides strong evidence.

**Impact:** Would extend the uniqueness theorem from the fully disjoint case to the general case, transforming tropical kernel generators into a complete graph invariant for all connected graphs (not just those with separated cycle structures).

**Catalog References:** `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (TropProjEquiv, PairwiseDisjointSupports), `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` (inducedCycleRank).

**Proof Strategy:** Define "overlap degree" as the maximum intersection size between two support sets. Prove uniqueness up to TropProjEquiv for overlap degree 0 (our current theorem), then induct on overlap degree using a "peeling" argument that reduces overlapping supports to disjoint ones plus correction terms.

**Domain Bridges:** Connects tropical linear algebra to combinatorial topology (cycle spaces), matroid theory (circuit overlap structure), and coding theory (support weights of linear codes).

**Lineage:** Extends the main theorem of this work. Builds on the support-matching injectivity argument of `support_matching_injective`.

**Ambition:** Grand challenge — would unify tropical kernel theory with cycle matroid structure.

**The key insight is** that the number of equivalence classes should be determined entirely by the combinatorial overlap pattern of cycle supports, not by the specific geometry of the graph. **Why now?** The formal verification infrastructure for TropProjEquiv and PairwiseDisjointSupports provides the first rigorous foundation for testing this prediction computationally.

---

## Direction 2: Chip-Firing Canonical Forms via Tropical Kernels

**Conjecture:** The canonical tropical kernel generators, under the separation hypothesis, correspond bijectively to the generators of the critical group (sandpile group / Jacobian) of the graph restricted to S.

**Test:** For all connected graphs on n ≤ 7, compute both the canonical tropical kernel generators and the Smith normal form of the restricted Laplacian. Verify that the number of generators matches the rank of the critical group, and that the canonical generators span the correct sublattice.

**Impact:** Would provide a tropical-geometric interpretation of the critical group, connecting chip-firing dynamics to tropical kernel uniqueness.

**Catalog References:** `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (harmonicKernel, IsHarmonicOn), `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian, firingIndependentOn).

**Proof Strategy:** Show that the canonical generators of the harmonic kernel modulo constants form a basis for the critical group. Use the leaf rigidity lemma to propagate values from cycles to trees, matching the chip-firing spreading rule.

**Domain Bridges:** Connects tropical algebra to algebraic graph theory (critical groups), number theory (lattice theory), and statistical mechanics (sandpile models / self-organized criticality).

**Lineage:** Builds on `harmonic_leaf_rigidity` and `constant_isHarmonicOn`.

**Ambition:** Solid extension — well-motivated by existing connections between chip-firing and tropical geometry.

**The key insight is** that the uniqueness of tropical kernel generators under separation should reflect the uniqueness of the Smith normal form — both are canonical decompositions forced by the Laplacian structure. **Why now?** The leaf rigidity and harmonic kernel infrastructure are now formally verified, providing a solid foundation for connecting to chip-firing.

---

## Direction 3: Tropical Hodge Filtration for Persistent Graph Homology

**Conjecture:** The tropical kernel dimension function tropicalKernelDim(G, q, S), tracked along a vertex filtration, satisfies a tropical Hodge decomposition: at each step, the kernel dimension change splits into a "cycle birth" component and a "visibility birth" component, with the split being canonical (not just the sum).

**Test:** For random graphs on n ≤ 20 with random vertex filtrations, compute the filtration event sequence and verify that each event can be uniquely decomposed into cycle and visibility contributions. Check that the decomposition is independent of the filtration order when the underlying topological event is the same.

**Impact:** Would establish a tropical persistence theory with richer structure than standard persistent homology, capturing both homological and "visibility" phenomena simultaneously.

**Catalog References:** `Catalog/Pythagorean/TropicalBridge/FiltrationPersistence.lean` (tropicalKernelDim_step_decomposition, TropicalFiltrationEvent), `Catalog/Pythagorean/TropicalBridge/Stability.lean` (tropical_barcode_stability).

**Proof Strategy:** Use the step decomposition theorem (already proved in FiltrationPersistence.lean) as the algebraic backbone. Prove that the cycle/visibility split is canonical by showing the two components are tropically independent (disjoint support in an appropriate sense). Apply the uniqueness theorem from TropicalKernelRigidity.lean.

**Domain Bridges:** Connects tropical algebra to topological data analysis (persistent homology), applied algebraic topology, and computational biology (protein structure analysis via persistence).

**Lineage:** Directly extends tropicalKernelDim_step_decomposition.

**Ambition:** Solid extension with potential to become a grand challenge if the Hodge decomposition extends to weighted/infinite graphs.

**The key insight is** that the step decomposition into cycle and visibility components should be unique when the two components have disjoint support — exactly the situation our uniqueness theorem addresses. **Why now?** The step decomposition is already formally verified, and the uniqueness theorem provides the missing rigidity piece.

---

## Direction 4: Graph Classification via Tropical Kernel Signatures

**Conjecture:** The multiset of canonical tropical kernel generators (viewed as functions up to scaling) is a complete invariant for 3-connected planar graphs.

**Test:** Compute the tropical kernel signature for all 3-connected planar graphs on n ≤ 12 vertices. Check whether the signature distinguishes all non-isomorphic graphs. Compare discrimination power against the Tutte polynomial and the Laplacian spectrum.

**Impact:** Would provide a new practical tool for graph isomorphism testing, with formal correctness guarantees from the uniqueness theorem.

**Catalog References:** `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (disjoint_support_unique_up_to_tropProjEquiv, same_support_implies_same_restricted_laplacian).

**Proof Strategy:** For 3-connected planar graphs, use Whitney's theorem (the cycle matroid determines the graph up to isomorphism) combined with our matroidal invariance theorem. Show that the tropical kernel generators recover the cycle matroid, hence the graph.

**Domain Bridges:** Connects tropical algebra to computational complexity (graph isomorphism), computer science (molecular structure comparison), and network science (network fingerprinting).

**Lineage:** Applies the matroidal invariance theorem (same_support_implies_same_restricted_laplacian and same_restricted_laplacian_implies_same_kernel).

**Ambition:** Grand challenge — completeness for all 3-connected graphs would be a major result in algebraic graph theory.

**The key insight is** that the matroidal invariance theorem shows the tropical kernel generators encode exactly the cycle matroid information — and for 3-connected planar graphs, the cycle matroid is a complete invariant. **Why now?** The formal matroidal invariance infrastructure makes it possible to rigorously connect tropical kernels to graph classification for the first time.

---

## Direction 5: Continuous Tropical Kernel Rigidity for Metric Graphs

**Conjecture:** The uniqueness theorem for tropical kernel generators extends to metric graphs (tropical curves): under a measure-theoretic disjoint support condition, the canonical generators of the tropical kernel of a metric graph Laplacian are unique up to tropical projective equivalence.

**Test:** Implement the continuous tropical kernel for metric graphs with rational edge lengths. Compute generators for genus-2 and genus-3 curves with explicit edge lengths. Verify uniqueness numerically by perturbing generators and checking convergence.

**Impact:** Would bridge the discrete uniqueness theorem to tropical algebraic geometry, potentially connecting to the tropical Torelli theorem and the structure of tropical Jacobians.

**Catalog References:** `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (entire development), `Catalog/Pythagorean/TropicalBridge/Stability.lean` (stability bounds).

**Proof Strategy:** Discretize the metric graph into a sequence of finite graphs with increasingly fine subdivision. Show that the canonical generators converge as the subdivision refines. Use the stability bounds from Stability.lean to control the approximation error.

**Domain Bridges:** Connects discrete combinatorics to algebraic geometry (tropical curves), analysis (spectral theory on metric graphs), and mathematical physics (quantum graphs).

**Lineage:** Extends the entire TropicalKernelRigidity.lean development to the continuous setting.

**Ambition:** Grand challenge — would unify the discrete and continuous theories of tropical kernel rigidity.

**The key insight is** that the support disjointness condition is topologically robust: small metric perturbations of a graph cannot merge disjoint support regions, so the uniqueness should be stable under passage to the continuous limit. **Why now?** The stability theory in Stability.lean provides quantitative control over perturbations, and the uniqueness theorem provides the discrete foundation to build upon.
