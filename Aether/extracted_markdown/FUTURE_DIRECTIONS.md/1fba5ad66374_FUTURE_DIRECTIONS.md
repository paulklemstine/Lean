# Future Directions: Algorithmic Tropical Kernel Computation

## Synthesis

This research cycle established the foundational framework for polynomial-time tropical kernel computation. The key structural result — that the graph balance system has size O(|V| · Δ) — provides the necessary prerequisite for efficient algorithms, but the full O(|V|³ · Δ) conjecture remains open. The potential gap theory developed here offers a new tool for analyzing tropical equilibria: the total gap characterizes global equilibrium, and its zero-set decomposition connects to network flow conservation.

The most promising cross-domain connection emerged from the tropical conservation bridge (§6 of the research paper). The formal equivalence between tropical equilibrium and min-plus flow conservation suggests that algorithms from network flow theory — augmenting paths, push-relabel methods, and scaling techniques — may be directly adaptable to tropical kernel computation. This would bypass the need for general-purpose tropical LP algorithms and exploit the specific structure of graph balance systems.

The cycle's results build directly on the Catalog's existing tropical geometry infrastructure. The tie subgraph theory from `Catalog/Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` provides the algebraic structure (generic vs. constant weights), while the stability results in `Catalog/Pythagorean/TropicalBridge/Stability.lean` establish Laplacian bounds that could constrain the potential gap. Bridging these to the algorithmic framework developed here is the highest-priority next step.

---

### Direction 1: Tropical Push-Relabel Algorithm for Kernel Dimension

**Conjecture**: The tropical kernel dimension can be computed by a push-relabel algorithm that terminates in O(|V|²) phases, each costing O(|E|), giving total complexity O(|V|² · |E|) ≤ O(|V|³ · Δ).

**Test**: Implement a tropical push-relabel algorithm modeled on Goldberg–Tarjan. For random d-regular graphs with n = 5..50, verify that:
1. The algorithm terminates and produces the correct kernel dimension (checked against brute force for n ≤ 10)
2. The number of push and relabel operations scales as O(n²) empirically
3. The output matches the weighted Betti number formula from `Catalog/Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean`

**Impact**: If true, this would give the first practical polynomial-time algorithm for tropical kernel computation, immediately applicable to networks with thousands of nodes. If false, the failure mode (which phase takes too long? which graph structure causes blowup?) would identify the structural barriers to efficient computation.

**Catalog References**: 
- `Catalog/Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (weighted_tropical_kernel_dim_formula)
- `Catalog/Pythagorean/TropicalBridge/Stability.lean` (tropical_stability_via_laplacian_bound)

**Proof Strategy**: 
1. Define tropical push and relabel operations on vertex potentials
2. Prove that each operation strictly decreases the total potential gap
3. Bound the number of operations using the discrete structure of ℤ-valued potentials
4. Connect the terminal state to the tropical kernel dimension via the tie subgraph

**Domain Bridges**: Combinatorial Optimization <-> Tropical Geometry, Network Flow <-> Algebraic Geometry

**Lineage**: Extends the potential gap theory developed in this cycle, combined with Goldberg–Tarjan push-relabel [1986] and the weighted dimension formula from the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Kernel Persistence Under Edge Deletion

**Conjecture**: For a connected graph G with edge e, the tropical kernel dimensions satisfy:

    dim ker(G) ≤ dim ker(G \ e) ≤ dim ker(G) + 1

Moreover, equality dim ker(G \ e) = dim ker(G) + 1 holds if and only if e is a "tropical bridge" — its removal creates a new connected component in the tie subgraph.

**Test**: For all graphs on n ≤ 8 vertices with random weights, compute ker(G) and ker(G \ e) for every edge e. Verify the inequalities and the bridge characterization. The tie subgraph can be computed using the definitions from `ExactWeightedTropicalDimension.lean`.

**Impact**: This would establish a deletion-contraction formula for tropical kernel dimension, analogous to the classical deletion-contraction for the Tutte polynomial. Such a formula would enable recursive computation and connect tropical kernels to matroid theory.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (tieSubgraph, weightedBetti₁)
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian)

**Proof Strategy**:
1. Show that removing an edge relaxes exactly one constraint in the balance system
2. Use the solution set antitone property to bound the dimension change
3. Characterize when the relaxed constraint is redundant (no dimension increase) vs. independent (dimension increases by 1)
4. Connect to the tie subgraph: the constraint is redundant iff the edge is not a tie edge

**Domain Bridges**: Matroid Theory <-> Tropical Geometry, Graph Theory <-> Algebraic Topology

**Lineage**: Builds on the solution set antitone theorem proved in this cycle and the tie subgraph theory from the Catalog.

**Ambition**: extension

---

### Direction 3: Tropical Kernel and Chip-Firing Equivalence

**Conjecture**: The tropical kernel dimension equals the number of chip-firing equivalence classes of degree-zero divisors that are effective modulo the kernel, i.e.:

    dim ker(G, w) = |{ [D] : D effective, deg(D) = 0 }| / ~_chip-firing

for an appropriate generalization of chip-firing to weighted graphs.

**Test**: For small graphs (n ≤ 7), enumerate all effective degree-zero divisors, compute chip-firing equivalence classes, and compare the count to the tropical kernel dimension. Use the divisor theory definitions from `Catalog/Pythagorean/TropicalBridge/Defs.lean` (rootedSubsetDivisor, firingIndependentOn).

**Impact**: Would unify the tropical kernel (defined via balance conditions) with chip-firing (defined via integer programming), providing two complementary views of the same object. This could import the rich theory of chip-firing (Dhar's burning algorithm, etc.) into tropical kernel computation.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (rootedSubsetDivisor, firingIndependentOn, graphLaplacian)
- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`

**Proof Strategy**:
1. Define weighted chip-firing: fire vertex v by adding w(v, u) chips to each neighbor u
2. Show that chip-firing preserves the balance system solution set
3. Prove that two kernel elements are chip-firing equivalent iff they differ by a firing configuration
4. Count equivalence classes using the Smith normal form of the weighted Laplacian

**Domain Bridges**: Number Theory <-> Tropical Geometry, Algebraic Geometry <-> Combinatorics

**Lineage**: Extends Baker–Norine [2007] chip-firing theory to the weighted setting using the kernel framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Sparse Tropical Gaussian Elimination

**Conjecture**: For graphs with treewidth ≤ k, the tropical kernel dimension can be computed in O(|V| · k² · Δ) time, which is linear in |V| for bounded treewidth.

**Test**: Generate random graphs with controlled treewidth (using tree decomposition). Compare the runtime of sparse tropical elimination (respecting the tree decomposition) vs. dense elimination. For treewidth k ≤ 5 and n = 10..100, the speedup factor should be approximately n/k.

**Impact**: Would make tropical kernel computation practical for sparse networks (power grids, road networks, molecular graphs) where treewidth is typically O(log n) or O(√n). Combined with the structural bounds from this cycle, this would give near-linear-time algorithms for many practical cases.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (sparse system structure)
- `Catalog/Computation/InfoEfficientAlgorithms.lean` (algorithmic efficiency framework)

**Proof Strategy**:
1. Compute a tree decomposition of the graph
2. Order vertices by the tree decomposition (bags from leaves to root)
3. Perform tropical elimination along this ordering, exploiting that each bag has ≤ k+1 vertices
4. Bound the fill-in by k² per elimination step

**Domain Bridges**: Parameterized Complexity <-> Tropical Geometry, Graph Theory <-> Linear Algebra

**Lineage**: Combines the sparse system bounds from this cycle with tree decomposition techniques from parameterized complexity.

**Ambition**: extension

---

### Direction 5: Tropical Kernel of Random Graphs — Phase Transition

**Conjecture**: For Erdős–Rényi random graphs G(n, p) with uniform weight -1, the tropical kernel dimension undergoes a phase transition at p = ln(n)/n:

    dim ker(G(n,p)) = Θ(n)     for p < (1-ε) ln(n)/n
    dim ker(G(n,p)) = Θ(1)     for p > (1+ε) ln(n)/n

This corresponds to the connectivity threshold: disconnected graphs have large kernels, connected graphs have small kernels.

**Test**: For n = 50, 100, 200, sample G(n, p) for p ranging from 0.5 ln(n)/n to 2 ln(n)/n. Compute kernel dimensions (using brute force for small n, the algorithm for larger n). Plot dim ker vs. p/threshold and look for a sharp transition.

**Impact**: Would connect tropical kernel theory to random graph theory, providing a new invariant for studying random graph phase transitions. The tropical kernel dimension would serve as an "algebraic" connectivity measure complementing classical graph connectivity.

**Catalog References**:
- `Catalog/Pythagorean/TropicalPhaseTransition.lean` (existing phase transition framework)
- `Catalog/Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (dimension formula)

**Proof Strategy**:
1. For p below threshold: use the fact that G(n,p) has Θ(n/ln(n)) components, each contributing to kernel dimension
2. For p above threshold: use the weighted Betti number formula; the tie subgraph of a connected dense graph is small
3. The transition sharpness follows from concentration of the component count

**Domain Bridges**: Probability <-> Tropical Geometry, Random Graph Theory <-> Algebraic Topology

**Lineage**: Extends the tropical phase transition results in the Catalog with the kernel dimension framework from this cycle.

**Ambition**: extension
