# Future Directions: Tropical Graph Hodge Theory

## Synthesis

The Tropical Kernel Dimension Formula establishes a precise dictionary between tropical linear algebra and graph topology: the tropical null space of a graph Laplacian principal minor decomposes into cycle modes (measured by β₁) and boundary modes (measured by κ). This opens five interconnected research frontiers that together aim to build a complete **tropical Hodge theory** for discrete structures.

The directions below form a coherent program: Conjecture A provides uniqueness foundations, Conjecture B extends the theory to filtrations and persistent homology, Conjecture C generalizes to weighted/valued settings, Conjecture D establishes the homological framework, and Conjecture E connects to algebraic geometry via chip-firing. Each builds on the formalized Catalog theorems (`Pythagorean/TropicalBridge/`) and is designed to be falsifiable through explicit computational protocols.

---

## Direction 1: Basis Uniqueness up to Tropical Projective Equivalence

**Conjecture**: For each connected graph G, basepoint q, and subset S ⊆ V \ {q}, the cycle-component generating family of the tropical kernel of L_S is unique up to tropical scaling (adding constants to individual generators) and permutation, whenever G[S] has a pairwise edge-disjoint cycle basis and distinct q-visible components.

**Test**: Exhaustive search over all connected graphs on n ≤ 7 vertices. For each (G, q, S), compute all minimal tropical generating families of ker_trop(L_S) and compare equivalence classes. Verify that the number of equivalence classes is exactly 1 when the edge-disjointness condition holds, and characterize the failure cases.

**Impact**: Establishes canonical generators for tropical kernels, enabling effective computation and comparison across graph families. Would be the tropical analogue of the uniqueness of the Smith normal form.

**Catalog References**: `Pythagorean/TropicalBridge/Defs.lean` (tropicalKernel, componentIndicator), `Pythagorean/TropicalBridge/TropicalHodge.lean` (componentIndicator_mem_tropicalKernel, tropicalKernel_leaf_eq).

**Proof Strategy**: Use the separation properties of cycle generators (support on cycle vertices) and component generators (support on component vertices) to show that any alternative generating family must be related by tropical scaling. The key tool is the leaf propagation lemma, which forces values along tree edges.

**Domain Bridges**: Tropical linear algebra ↔ matroid theory (the cycle matroid determines uniqueness), algebraic combinatorics ↔ graph theory.

**Lineage**: Extends the structural kernel theorems in `TropicalHodge.lean` from existence to uniqueness.

**Ambition**: ★★★ (Solid extension — technically challenging but conceptually clear)

---

## Direction 2: Filtration Persistence Formula

**Conjecture**: For an increasing filtration S₀ ⊆ S₁ ⊆ ... ⊆ S_m ⊆ V \ {q}, the sequence of tropical kernel dimensions dim_trop(ker_trop(L_{S_k})) satisfies:

  dim(S_{k+1}) - dim(S_k) = (number of new cycles born) + (number of new q-visible components born) - (number of component merges destroying q-invisible components)

Moreover, the "barcode" of tropical kernel dimensions is completely determined by the births and deaths of cycles and q-visible components in the filtration.

**Test**: Enumerate all increasing filtrations on connected graphs with n ≤ 6 vertices. For each filtration, compute the dimension sequence and compare to the predicted birth/death events. Verify the persistence formula matches in all cases.

**Impact**: Creates a new invariant — the **tropical persistence barcode** — that combines topological persistence (like standard persistent homology) with algebraic structure (tropical linear algebra). This could provide strictly finer invariants than classical persistent homology for weighted networks.

**Catalog References**: `Pythagorean/TropicalBridge/Defs.lean` (inducedCycleRank, qVisibleComponentCount), `Pythagorean/TropicalBridge/UniversalDefect.lean` (universalDefect_eq).

**Proof Strategy**: Induction on filtration length. At each step, adding a vertex v to S either:
(a) connects to an existing component (no new cycle, no new component),
(b) forms a bridge to q (new q-visible component),
(c) closes a cycle (new cycle mode), or
(d) merges two components.
Track each case and verify the dimension change formula.

**Domain Bridges**: Tropical algebra ↔ topological data analysis, computational topology ↔ network science.

**Lineage**: Directly extends the dimension formula to parameterized families, building on `inducedCycleRank_eq_zero_of_forest` for the tree base case.

**Ambition**: ★★★★ (Grand challenge — requires new persistent tropical homology theory)

---

## Direction 3: Weighted Extension

**Conjecture**: For weighted graphs with edge weights w : E → ℤ (or more generally w : E → ℝ), the tropical kernel dimension formula generalizes to:

  dim_trop(ker_trop(L_S^w)) = β₁^w(G[S]) + κ^w(G,q,S)

where β₁^w counts the number of "weight-compatible" independent cycles (cycles where the minimum-weight edge is achieved at least twice) and κ^w counts q-visible components whose connection to q has "generic" weight.

For generic weights (no weight coincidences), β₁^w = β₁ and κ^w = κ, recovering the unweighted formula. For degenerate weights, the dimension can increase due to additional coincidences.

**Test**: Sample 10000 weighted graphs on n ≤ 6 vertices with weights drawn from {1, 2, ..., 10}. For each, compute the tropical kernel dimension by direct enumeration and compare to the predicted β₁^w + κ^w. Identify the precise weight-degeneracy conditions that cause the formula to differ from the unweighted case.

**Impact**: Extends tropical graph Hodge theory to the setting relevant for applications (communication networks, transportation networks, molecular graphs all have weighted edges). Would connect to tropical geometry's theory of valuated matroids.

**Catalog References**: `Pythagorean/TropicalBridge/Defs.lean` (TropicalVal, tropMul), `Pythagorean/TropicalBridge/TropicalHodge.lean` (cycleIndicator, componentIndicator).

**Proof Strategy**: Modify the cycle and component indicator constructions to account for edge weights. The key insight is that the tropical kernel condition becomes weight-dependent: for row i, the minimum of w(i,j) + v(j) over neighbors j must be achieved twice. Weight-compatible cycles are those where the indicator vector, adjusted by cumulative weights, still satisfies this condition.

**Domain Bridges**: Tropical geometry ↔ optimization (weighted matching), network science ↔ statistical physics (Boltzmann weights).

**Lineage**: Generalizes `componentIndicator_mem_tropicalKernel` from unit weights to arbitrary weights.

**Ambition**: ★★★ (Solid extension — natural generalization with clear proof path)

---

## Direction 4: Relative Tropical Hodge Theorem

**Conjecture**: The tropical kernel of L_S is naturally isomorphic (as a tropical semi-module) to a relative tropical homology group:

  ker_trop(L_S) ≅ H₁^trop(G[S ∪ {q}], {q})

where H₁^trop denotes the first tropical homology of the pair (G[S ∪ {q}], {q}), defined via a tropical chain complex using the incidence matrix of the graph.

**Test**: Define the tropical chain complex C₀ → C₁ for the graph G[S ∪ {q}] with boundary map given by the incidence matrix. Compute H₁^trop(G[S ∪ {q}], {q}) = ker(∂₁^trop) / im(∂₀^trop) for all connected graphs on n ≤ 6. Verify isomorphism with the tropical kernel of L_S.

**Impact**: This would be the foundational theorem connecting tropical linear algebra to tropical homology theory. It would justify calling the dimension formula a "Hodge theorem" by providing the precise homological interpretation. Opens the door to higher-dimensional tropical Hodge theory on simplicial complexes.

**Catalog References**: `Pythagorean/TropicalBridge/Defs.lean` (inducedSubgraph, tropicalKernel), `Pythagorean/TropicalBridge/TropicalHodge.lean` (structural theorems).

**Proof Strategy**: Factor the Laplacian as L = ∂ᵀ∂ (incidence factorization) in the tropical setting. Show that the tropical kernel of L_S corresponds to tropical 1-cycles that are boundaries from the q-side, i.e., relative 1-cycles. The cycle generators correspond to absolute 1-cycles (homology of G[S]), while the component generators correspond to relative 0-boundaries (paths from q to components).

**Domain Bridges**: Tropical algebra ↔ algebraic topology (simplicial homology), combinatorics ↔ algebraic geometry (tropical varieties).

**Lineage**: Provides the theoretical foundation for all other directions, upgrading the dimension formula from a counting theorem to a structural isomorphism.

**Ambition**: ★★★★★ (Paradigm-shifting — would establish tropical Hodge theory as a subject)

---

## Direction 5: Chip-Firing Correspondence

**Conjecture**: Tropical kernel generators of L_S correspond to equivalence classes of "balanced" divisor deformations supported on S in the sense of Baker-Norine chip-firing theory. Specifically:

  ker_trop(L_S) ≅ { D ∈ Div⁰(G) : supp(D) ⊆ S, D is q-reduced and balanced }

where "balanced" means every vertex fires at most to neighbors achieving the same potential, and the quotient is by tropical scaling.

**Test**: For all connected graphs on n ≤ 6, compute:
(a) The tropical kernel dimension via the formula,
(b) The number of independent balanced q-reduced divisors supported on S.
Compare dimensions and identify the explicit bijection between kernel generators and divisor classes.

**Impact**: Connects tropical graph Hodge theory to one of the most active areas of combinatorial algebraic geometry. The Baker-Norine theorem gives a Riemann-Roch theorem for graphs; this conjecture would provide the Hodge-theoretic complement. Could lead to new algorithms for computing the Jacobian group of a graph.

**Catalog References**: `Pythagorean/TropicalBridge/Defs.lean` (tropicalKernelProp — the balanced condition), `Pythagorean/TropicalBridge/TropicalHodge.lean` (tropicalKernel_leaf_eq — propagation along edges mirrors chip-firing).

**Proof Strategy**: The leaf propagation lemma (`tropicalKernel_leaf_eq`) already shows that kernel vectors satisfy v(i) = v(j) along tree edges, which is exactly the condition for a divisor to be q-reduced on trees. Extend this to graphs with cycles by showing that the cycle generators correspond to the "circuit divisors" in chip-firing theory. The q-visible component generators correspond to "lending" operations from q to components.

**Domain Bridges**: Tropical algebra ↔ algebraic geometry (divisor theory), combinatorics ↔ number theory (arithmetic geometry of curves).

**Lineage**: Extends `tropicalKernel_leaf_eq` and `tropicalKernel_edge_constant` to the full chip-firing dictionary.

**Ambition**: ★★★★ (Grand challenge — bridges two deep theories)
