# Future Directions: Tropical Kernel Rigidity Theory

## Synthesis

The uniqueness theorem for tropical kernel generators establishes that under support separation, graph Laplacian kernels possess canonical structure — their generators are determined up to tropical projective equivalence. This opens five natural research directions, each extending the canonicality principle in a different direction: relaxing hypotheses, enriching the algebraic structure, connecting to other mathematical domains, scaling computationally, and bridging to applications in physics and network science. Together, these directions aim to transform tropical kernel theory from a specialized graph-theoretic tool into a general-purpose canonical-form framework for combinatorial algebraic structures.

---

## Direction 1: Overlap Class Conjecture and Complete Classification

**Conjecture:** For any connected graph $G$, basepoint $q$, and subset $S \subseteq V \setminus \{q\}$, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in any cycle basis of $G[S]$.

**Test:** Enumerate all connected graphs on $n \leq 9$ vertices. For each $(G, q, S)$ triple, compute the canonical family, all minimal generating families (via exhaustive search for $n \leq 7$, sampling for $n = 8, 9$), quotient by tropical projective equivalence, and compare with cycle overlap statistics. A single counterexample falsifies the conjecture.

**Impact:** A proof would completely classify the ambiguity in tropical kernel generators, extending the uniqueness theorem from the disjoint-support case to all cases. This would be the definitive structural theorem for tropical graph kernels.

**Catalog References:** `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `disjoint_support_unique_up_to_tropProjEquiv`, `OverlapClassConjecture`

**Proof Strategy:** The key insight is that overlap classes correspond to automorphisms of the support intersection graph. When two cycle indicators share support, their tropical linear combinations can be "rotated" within the shared support, creating additional equivalence classes. The number of such rotations should equal the number of connected components of the overlap graph, counted with multiplicity.

**Domain Bridges:** Matroid theory (overlap classes correspond to matroid circuit families), algebraic topology (support overlaps encode homological intersections)

**Lineage:** Direct extension of the main uniqueness theorem

**Ambition:** Grand challenge — would complete the classification theory

---

## Direction 2: Weighted Tropical Kernel Rigidity

**Conjecture:** For weighted graphs with edge weights in $\mathbb{Z}_{>0}$, the uniqueness theorem extends with the same statement, where support separation is replaced by "weighted support separation" — no two generators have overlapping nonzero weighted contributions.

**Test:** Implement weighted Laplacian construction, generate random weighted graphs on $n \leq 6$ vertices with integer edge weights in $\{1, 2, 3, 4, 5\}$. Verify uniqueness under weighted support separation for all $(G, w, q, S)$ tuples.

**Impact:** Weighted graphs model real networks (where edges have different conductances/capacities). Extending the uniqueness theorem to weighted graphs would make the theory directly applicable to electrical networks, transportation networks, and communication networks.

**Catalog References:** `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `GraphLaplacian`, `IsHarmonicOn`; `Pythagorean/TropicalBridge/Defs.lean` — `graphLaplacian`

**Proof Strategy:** The key insight is that the irredundancy argument (Theorem 3) uses only the vanishing of generators outside their support, which holds regardless of edge weights. The support-matching injectivity argument is purely combinatorial and also extends. The main technical challenge is that weighted Laplacians have entries other than $0, 1, -1$, which complicates the leaf rigidity argument.

**Why now?** The unweighted theory is now established and provides a template. The formalization infrastructure (tropical projective equivalence, support separation) is in place and can be directly generalized.

**Domain Bridges:** Electrical engineering (resistor networks), operations research (capacitated flow networks)

**Lineage:** Extension of `disjoint_support_unique_up_to_tropProjEquiv` to weighted setting

**Ambition:** Solid extension

---

## Direction 3: Tropical Convexity and Extremal Ray Theory

**Conjecture:** The canonical tropical kernel generators are exactly the extremal rays of the tropical kernel viewed as a tropical cone. Under pairwise disjoint support, the extremal rays are in bijection with the canonical generators.

**Test:** For graphs on $n \leq 6$ vertices, compute the tropical kernel as a tropical polytope (using the tropical double description method). Enumerate extremal rays and compare with canonical generators.

**Impact:** This would reframe the entire theory within tropical convex geometry, connecting to optimization (tropical linear programming), algebraic geometry (tropical varieties as polyhedral complexes), and computational geometry.

**Catalog References:** `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `TropProjEquiv`, `PairwiseDisjointSupports`

**Proof Strategy:** The key insight is that disjoint support implies that no generator can be written as a tropical convex combination of the others (because on each generator's support, the combination reduces to a constant). This is exactly the extremal ray property. The converse — that extremal rays correspond to canonical generators — requires showing that every extremal function has connected support concentrated on a single cycle or component region.

**Why now?** Tropical convexity theory has matured significantly in the last decade, with computational tools becoming available. The support separation hypothesis provides a clean entry point into the extremal ray classification.

**Domain Bridges:** Tropical optimization, computational algebraic geometry, polyhedral combinatorics

**Lineage:** Conceptual deepening of `disjoint_support_irredundancy`

**Ambition:** Grand challenge — would unify tropical kernel theory with tropical convexity

---

## Direction 4: Chip-Firing Canonical Forms

**Conjecture:** The tropical projective equivalence classes of kernel generators correspond bijectively to equivalence classes of critical chip-firing configurations under the graph's Jacobian group action.

**Test:** For all connected graphs on $n \leq 7$ vertices, compute the Jacobian group, enumerate critical configurations, and compare their orbit structure with the tropical projective equivalence classes of kernel generators.

**Impact:** Chip-firing is a fundamental model in statistical physics, combinatorics, and theoretical computer science. A bridge between chip-firing canonical forms and tropical kernel generators would unify two major threads of discrete mathematics.

**Catalog References:** `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `HarmonicKernel`, `equilibrium_iff_harmonic`; `Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`

**Proof Strategy:** The key insight is that $S$-harmonic functions correspond to chip-firing configurations that are stable on $S$. The tropical kernel generators should correspond to the "fundamental chips" — minimal stable configurations from which all others can be built by tropical combination. The Jacobian group acts on these by global chip addition (which is tropical scaling).

**Why now?** The equilibrium-harmonicity bridge is now formalized, providing the precise link between harmonic functions and chip-firing stability.

**Domain Bridges:** Statistical physics (sandpile models), combinatorial group theory (Jacobian groups), algebraic geometry (divisor theory on curves)

**Lineage:** Extension of `equilibrium_iff_harmonic` to chip-firing context

**Ambition:** Solid extension

---

## Direction 5: Network Mode Detection in Real-World Graphs

**Conjecture:** For real-world networks (social, biological, infrastructure), the canonical tropical kernel generators identify functionally meaningful modules or communities that are invisible to spectral clustering and standard community detection algorithms.

**Test:** Apply the canonical tropical kernel family construction to:
1. Zachary's Karate Club network (34 nodes)
2. C. elegans neural network (297 nodes)
3. US power grid network (4,941 nodes)

Compare the support-separated generators with communities found by Louvain, spectral clustering, and label propagation. Measure Normalized Mutual Information (NMI) with known functional modules.

**Impact:** If tropical kernel generators detect genuinely different structure from standard methods, this opens a new paradigm for network analysis. The mathematical guarantee of canonicality (under support separation) would provide rigorously justified community detection — unlike heuristic methods that lack uniqueness guarantees.

**Catalog References:** `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `disjoint_support_unique_up_to_tropProjEquiv`, `same_induced_structure_same_laplacian`

**Proof Strategy:** The key insight is that tropical kernel generators are sensitive to the cycle structure and connectivity of the network, not just the spectral gap. Networks with similar spectra but different cycle structures will have different canonical generators. This is precisely the structural information that spectral methods miss.

**Why now?** Network science has reached a point where the limitations of spectral methods are well-documented. The mathematical foundations for tropical-kernel-based analysis are now in place, and the algorithms are polynomial-time.

**Domain Bridges:** Network science, computational biology (protein interaction networks), social network analysis, infrastructure resilience

**Lineage:** Application of `same_induced_structure_same_laplacian` (matroidal invariance) to real networks

**Ambition:** Grand challenge — would create a new paradigm for network analysis
