# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational connection between SL₂(ℤ) trace arithmetic, Markov number theory, and the Poincaré disk model of hyperbolic geometry. The most promising discovery is the formally verified Fricke trace identity, which provides a single algebraic equation bridging hyperbolic isometries to the Markov equation — a purely Diophantine problem. This bridge opens two major avenues: (1) using geometric tools to attack Diophantine problems like the Markov uniqueness conjecture, and (2) using algebraic trace identities to understand the spectral theory of hyperbolic surfaces.

The cross-domain connection to tropical geometry via Gromov products is the most unexpected finding. The fact that 0-hyperbolicity (tree-like metric spaces) produces exactly the ultrametric inequality — the defining axiom of tropical semirings — suggests that tropical geometry is the "shadow at infinity" of hyperbolic arithmetic. This connection could link the Catalog's Tropical module (`Tropical/`) to the hyperbolic number theory developed here.

The highest breakthrough potential lies in Direction 1 (Selberg trace formula), which would connect our SL₂(ℤ) trace arithmetic to the spectral theory of automorphic forms — the deepest analytic tool in modern number theory.

---

### Direction 1: Formalize the Selberg Trace Formula for Finite Graphs

**Conjecture**: For a finite graph Cayley graph of SL₂(ℤ/pℤ), the trace formula
∑ eigenvalues = ∑ conjugacy class contributions
can be formalized as a matrix identity, with each side expressible in terms of our SL₂(ℤ) trace machinery.

**Test**: Construct the Cayley graph of SL₂(ℤ/5ℤ) (which has 120 elements), compute its adjacency matrix eigenvalues, and verify they match the conjugacy class sum formula.

**Impact**: A finite model of the Selberg trace formula would provide a concrete, provable version of the deepest tool in automorphic form theory. The infinite version connects ζ-function zeros to closed geodesics (= conjugacy classes). If true, this opens a path to formalizing spectral methods.

**Catalog References**: `Catalog/Algebra/Foundations.lean` (trace_eq_sum_diagonal), `Catalog/Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (fricke_trace_identity, SL2Z structure)

**Proof Strategy**: 
1. Define SL₂(ℤ/pℤ) as a quotient of SL₂(ℤ)
2. Construct the Cayley graph adjacency matrix
3. Prove the trace formula as a matrix identity: Tr(A^n) = ∑ conjugacy classes C of length n, |C|
4. Use the index formula (congruence_subgroup_index_div6) to control group size

**Domain Bridges**: NumberTheory <-> SpectralTheory, Algebra <-> Computation

**Lineage**: Builds on fricke_trace_identity, SL2Z group structure, and congruence_subgroup_index_div6 from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Markov Numbers

**Conjecture**: The tropicalization of the Markov equation x² + y² + z² = 3xyz, obtained by replacing (×, +) with (+, min), yields the tropical equation min(2x, 2y, 2z) = x + y + z. The solutions to this tropical equation form a polyhedral complex that is dual to the Markov tree.

**Test**: Enumerate solutions to min(2x, 2y, 2z) = x + y + z for x, y, z ∈ {0, 1, ..., 20} and verify the solution set has the structure of the Markov tree (a binary tree with the same branching pattern).

**Impact**: If true, this would establish Markov numbers as the "de-tropicalization" of a polyhedral structure, connecting classical Diophantine equations to tropical algebraic geometry. The existing Tropical module in the Catalog could be extended with this bridge.

**Catalog References**: `Catalog/Tropical/` (tropical semiring definitions), `Catalog/Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (tropAdd, tropMul, tropMul_distrib, MarkovTriple, vieta_preserves_markov_eq)

**Proof Strategy**:
1. Define the tropical Markov equation in the Tropical module
2. Characterize its solution set as a polyhedral fan
3. Construct a bijection between tropical solutions and Markov tree vertices
4. Show the Vieta involution tropicalizes to a piecewise-linear involution

**Domain Bridges**: Tropical <-> NumberTheory, Algebra <-> Geometry

**Lineage**: Builds on tropMul_distrib, gromov_product_tree_ineq, and MarkovTriple from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Chebyshev Polynomial Factorization and Hyperbolic Primality

**Conjecture**: A Chebyshev polynomial T_n(t) (trace version) is irreducible over ℤ if and only if n is prime. Equivalently, if n = pq, then T_n factors as a product involving T_p and T_q, mirroring unique factorization into "hyperbolic primes."

**Test**: Compute T_p(t) for primes p = 2, 3, 5, 7, 11, 13 and verify irreducibility over ℤ[t]. Compute T_6(t) = T_2(T_3(t)) and verify it factors.

**Impact**: This would provide a precise notion of "hyperbolic prime" — not as a geometric object, but as an algebraic one characterized by the irreducibility of trace polynomials. It would connect the research direction's original goal (unique factorization for hyperbolic integers) to classical algebra.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (chebyshevT, trace_eq_chebyshev, trace_power_recurrence)

**Proof Strategy**:
1. Prove the composition property: T_{mn}(t) = T_m(T_n(t))
2. Use cyclotomic polynomial theory to characterize irreducibility
3. Connect to the Galois group of the splitting field

**Domain Bridges**: NumberTheory <-> Algebra, Computation <-> Algebra

**Lineage**: Builds on chebyshevT, trace_eq_chebyshev from this cycle.

**Ambition**: extension

---

### Direction 4: Farey Graph as Cayley Graph and Word Metric

**Conjecture**: The Farey graph (vertices = ℚ ∪ {∞}, edges = Farey neighbors) is isomorphic to the Cayley graph of PSL(2,ℤ) with generators S and T. The word metric on this graph gives an explicitly computable approximation to the hyperbolic metric on ℍ/PSL(2,ℤ).

**Test**: For the first 100 elements of PSL(2,ℤ) (enumerated by word length in S, T), verify that the Farey graph distance matches the word length, and compare both to the hyperbolic distance.

**Impact**: This would give an algorithmic construction of the hyperbolic metric purely in terms of continued fractions and integer arithmetic, without any transcendental functions. The Farey sequence connection (farey_to_sl2z, farey_mediant_neighbor) provides the starting point.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (farey_to_sl2z, farey_mediant_neighbor, farey_count_ge, IsFareyNeighbor)

**Proof Strategy**:
1. Construct the isomorphism explicitly using the matrix ↔ fraction correspondence
2. Prove the word metric bounds: |d_word(g,h) − d_hyp(g·i, h·i)| ≤ C for some constant C
3. Use the tree structure of the Farey graph to compute distances efficiently

**Domain Bridges**: NumberTheory <-> Computation, Geometry <-> Algebra

**Lineage**: Builds on farey_to_sl2z, SL2Z group structure from this cycle.

**Ambition**: extension

---

### Direction 5: Hyperbolic Machine Learning via Trace Embeddings

**Conjecture**: Hierarchical data (trees) can be embedded into the trace spectrum of SL₂(ℤ) with distortion O(log n) for n-node trees. Specifically, map each node to an SL₂(ℤ) element such that the word metric approximates the tree distance, and the trace provides a 1-dimensional "sketch" preserving the hierarchical structure.

**Test**: Embed a binary tree of depth 10 (1023 nodes) into SL₂(ℤ) using words in S and T. Measure the correlation between tree distance and |tr(g⁻¹h)| for random pairs (g, h).

**Impact**: This would bridge the Catalog's MachineLearning module to hyperbolic geometry, providing a new embedding method for hierarchical data that is algebraically structured (integer matrices) rather than continuous (real coordinates).

**Catalog References**: `Catalog/MachineLearning/HyperbolicNumberTheory/PoincareDisk.lean` (existing ML-hyperbolic bridge), `Catalog/Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (SL2Z, trace_eq_chebyshev)

**Proof Strategy**:
1. Define the embedding map: tree node → word in S, T → SL₂(ℤ) element
2. Prove distortion bound using the quasi-isometry of the Cayley graph
3. Show trace provides a Lipschitz function on the word metric

**Domain Bridges**: MachineLearning <-> Algebra, Computation <-> Geometry

**Lineage**: Builds on SL2Z group structure, trace_eq_chebyshev, and the ML-Hyperbolic bridge in the Catalog.

**Ambition**: extension
