# Future Research Directions

## Synthesis

This research cycle established the mathematical foundations for studying spectral universality in theorem-dependency graphs. We formalized directed graphs on finite sets, SCC-based coarse-graining, spectral moments, and renormalization schemes, and proved 11 theorems including the directed handshaking lemma, DAG source existence, partition pigeonhole, edge density bounds, and renormalization termination. The key structural result — that any non-increasing ℕ-valued sequence is eventually constant — underpins the termination theorem and connects the discrete graph theory to dynamical systems notions of fixed points.

The most promising cross-domain connection emerging from this cycle is the bridge between **renormalization in physics** and **proof network structure**. The coarse-graining operation on theorem-dependency graphs is formally analogous to block-spin renormalization in statistical mechanics, and the Termination Theorem plays the role of the existence of a renormalization group fixed point. The Spectral Universality Conjecture, if true, would be the proof-network analog of critical universality in statistical physics. The Catalog's existing work on renormalization universality (`Bridges/RenormalizationUniversality.lean`) and EML complexity measures (`EML/AdvancedTheory.lean`) provide natural bridges to exploit.

The highest breakthrough potential lies in Direction 1 (computational testing of spectral convergence), as it would convert the conjecture from a formal statement into an empirical finding — or a definitive refutation. Direction 2 (degree entropy monotonicity) has the highest near-term provability, while Direction 3 connects to deep open questions in combinatorics and algebraic graph theory.

---

### Direction 1: Empirical Spectral Convergence Across Proof Libraries

**Conjecture**: For any two Mathlib modules with ≥500 declarations drawn from different mathematical domains (e.g., `Mathlib.Algebra.Group` and `Mathlib.Topology.Basic`), the 1-Wasserstein distance between their normalized Laplacian spectral distributions decreases monotonically under iterative SCC coarse-graining, and converges to a value below 0.05 (relative to the initial distance) within 10 iterations.

**Test**: Extract dependency graphs from ≥5 Mathlib modules across algebra, topology, analysis, combinatorics, and number theory. For each pair, compute the Laplacian spectrum at each coarse-graining level (using Tarjan's SCC algorithm + quotient graph construction). Measure 1-Wasserstein distance between spectral CDFs at each level. Plot distance vs. coarse-graining level. The conjecture is refuted if distance plateaus above 0.05 for any pair, or increases under coarse-graining.

**Impact**: A positive result would be the first empirical evidence for spectral universality in mathematical knowledge networks. A negative result would narrow the conjecture to specific graph classes or coarse-graining schemes.

**Catalog References**: `Bridges/RenormalizationUniversality.lean`, `EML/AdvancedTheory.lean`, `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: This is primarily computational. Steps: (1) Use `lake env printPaths` and Lean's environment API to extract `Name → List Name` dependency maps. (2) Construct adjacency matrices. (3) Implement Tarjan's SCC in Python. (4) Compute eigenvalues via numpy.linalg.eigh on the symmetrized Laplacian. (5) Compute Wasserstein distances using scipy.stats.wasserstein_distance. (6) Statistical significance via permutation tests.

**Domain Bridges**: Spectral graph theory ↔ Proof network analysis ↔ Statistical physics (renormalization)

**Lineage**: Builds on this cycle's formalization of DigraphOn, SCCPartition, coarseGrainGraph, and RenormScheme. Extends the formal Spectral Universality Conjecture to an empirical test.

**Ambition**: grand_challenge

---

### Direction 2: Degree Entropy Monotonicity Under Coarse-Graining

**Conjecture**: For any directed graph G and any SCC partition P, the Shannon entropy of the normalized out-degree distribution of the coarse-grained graph coarseGrainGraph(G, P) is less than or equal to the Shannon entropy of the normalized out-degree distribution of G. That is, coarse-graining always concentrates the degree distribution.

**Test**: Define `degreeEntropy(G) = -Σ_d p(d) log p(d)` where `p(d)` is the fraction of vertices with out-degree `d`. Compute degreeEntropy for random DAGs (n=100 to n=10000) before and after SCC coarse-graining. The conjecture is refuted if degreeEntropy increases for any instance. If all instances show decrease, attempt a formal proof in Lean.

**Impact**: Degree entropy monotonicity would provide a scalar Lyapunov function for the renormalization flow, guaranteeing convergence to a minimum-entropy (most uniform) degree distribution. This connects to the information-theoretic perspective of the EML framework.

**Catalog References**: `EML/AdvancedTheory.lean` (ensembleComplexity, entropy-related definitions), `EML/KolmogorovArnoldEMLDeep.lean`

**Proof Strategy**: (1) Formalize Shannon entropy for finite distributions over ℚ. (2) Show that merging vertices in a partition can only reduce the support of the degree distribution. (3) Apply log-sum inequality or Schur-concavity of entropy. Key lemma: if two vertices with degrees d₁, d₂ are merged, the resulting vertex has degree ≤ d₁ + d₂, and the entropy change is controlled by the convexity of -x log x.

**Domain Bridges**: Information theory (Shannon entropy) ↔ Graph theory (degree distributions) ↔ Dynamical systems (Lyapunov functions)

**Lineage**: Builds on this cycle's SCCPartition.sum_blockSizes, exists_large_block, and coarseGrainGraph definitions.

**Ambition**: extension

---

### Direction 3: Spectral Gap of DAGs and Proof Depth

**Conjecture**: For a DAG G on n vertices with longest directed path of length L (the "proof depth"), the spectral gap λ₂ of the symmetrized Laplacian satisfies λ₂ ≥ c / (L · log n) for some universal constant c > 0. Equivalently, the algebraic connectivity of a proof-dependency graph is inversely proportional to the logarithm of the theory size times the proof depth.

**Test**: Generate DAGs with controlled path lengths (chain graphs, layered graphs, random DAGs with fixed depth). Compute spectral gaps numerically. Fit the relationship λ₂ vs. L and n. The conjecture is refuted if λ₂ decays faster than 1/(L log n) for specific graph families.

**Impact**: This would provide the first rigorous connection between proof-theoretic depth (how long the longest dependency chain is) and spectral graph properties. It would enable predicting the computational difficulty of theorem proving from structural graph properties.

**Catalog References**: `EML/Complexity.lean` (EMLCTree.size_from_nodes), `Computation/PadicValuationDepth.lean` (ValuationDepthMeasure)

**Proof Strategy**: (1) For chain graphs (longest path = n-1), compute λ₂ exactly: it's 2(1-cos(π/n)) ≈ π²/n², confirming the bound. (2) For layered DAGs, use Cheeger's inequality: λ₂ ≥ h²/2 where h is the edge expansion. (3) Bound h from below using the structure of DAGs with bounded depth. Key step: relate depth L to the diameter of the symmetrized graph, then use known diameter-spectral gap relationships.

**Domain Bridges**: Spectral graph theory ↔ Proof complexity ↔ Computational complexity (communication complexity via spectral gaps)

**Lineage**: Builds on this cycle's dag_edge_bound, dag_source_exists, and the DAG structural theory. Extends toward quantitative spectral bounds.

**Ambition**: grand_challenge

---

### Direction 4: Topological Invariants of Proof Networks

**Conjecture**: The simplicial complex formed by the cliques of the symmetrized theorem-dependency graph has non-trivial persistent homology in dimensions 0, 1, and 2, with the first Betti number (counting independent cycles) growing as Θ(n^α) for some universal exponent α ∈ (0.3, 0.7), independent of the mathematical domain.

**Test**: Construct the clique complex of the symmetrized dependency graph for multiple Mathlib modules. Compute persistent homology using Ripser or GUDHI. Measure Betti numbers β₀, β₁, β₂ as functions of n. Fit power laws. The conjecture is refuted if α varies significantly across domains or falls outside (0.3, 0.7).

**Impact**: This would extend the spectral universality hypothesis to topological invariants, providing a richer characterization of the "shape" of mathematical knowledge. It connects to topological data analysis (TDA) and provides algebraic invariants beyond the spectrum.

**Catalog References**: `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` (persistent homology connections), `EML/CWApprox.lean` (CW-approximation theory)

**Proof Strategy**: Primarily computational. (1) Extract graphs. (2) Symmetrize. (3) Build Vietoris-Rips or clique complex. (4) Compute persistent homology via standard algorithms. For the theoretical bound, relate Betti numbers to the spectral gap (Garland's method) and use the conjectured spectral gap bound from Direction 3.

**Domain Bridges**: Algebraic topology (persistent homology) ↔ Graph theory (clique complexes) ↔ Data science (TDA)

**Lineage**: Extends this cycle's spectral framework to topological invariants. Connects to the Catalog's work on tropical persistence (`Bridges/AlgebraTropicalGeometry/`).

**Ambition**: extension

---

### Direction 5: Renormalization Fixed Points and Critical Exponents

**Conjecture**: The renormalization flow on theorem-dependency graphs has a unique non-trivial fixed point (up to isomorphism for graphs on ≤ 20 vertices), and the linearized renormalization operator at this fixed point has exactly two relevant eigenvalues (eigenvalues > 1), corresponding to the graph's density and clustering coefficient. All other eigenvalues are irrelevant (< 1), meaning the fixed point is a codimension-2 attractor.

**Test**: Enumerate all DAGs on n ≤ 10 vertices. Apply the SCC coarse-graining operation repeatedly. Identify fixed points. For each fixed point, compute the Jacobian of the renormalization map (by perturbing the adjacency matrix) and find its eigenvalues. Count eigenvalues > 1. The conjecture is refuted if (a) multiple non-isomorphic fixed points exist, (b) the number of relevant eigenvalues ≠ 2, or (c) the fixed point depends on the coarse-graining scheme.

**Impact**: Finding the critical exponents of proof-network renormalization would establish a complete analogy with statistical mechanical universality classes. It would predict the scaling behavior of proof networks near the critical point (the transition between "immature" and "mature" theories).

**Catalog References**: `Bridges/RenormalizationUniversality.lean` (every_stabilizing_observable_has_fixed_universality_class), `EML/ConvergenceGuarantees.lean` (distance_to_fixed_point)

**Proof Strategy**: (1) Implement the renormalization map R on DigraphOn n for small n. (2) Use fixed-point iteration to find fixed points computationally. (3) Compute the numerical Jacobian by finite differences. (4) Classify eigenvalues. If only two relevant eigenvalues exist, attempt to prove this formally by analyzing the structure of the Jacobian for special graph families (star graphs, path graphs, complete DAGs).

**Domain Bridges**: Statistical physics (renormalization group, critical exponents) ↔ Graph theory (graph automorphisms, fixed points) ↔ Dynamical systems (stability analysis)

**Lineage**: Directly extends this cycle's RenormScheme and renorm_terminates. Builds on the Catalog's renormalization universality work.

**Ambition**: grand_challenge
