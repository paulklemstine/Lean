# Future Directions

## Synthesis

This research cycle established the complete algebraic foundations of Baker-Norine divisor theory on finite graphs. Fifteen theorems were formally verified: the Riemann-Roch degree identity deg(K_G) = 2g − 2, conservation of degree under chip-firing, the Laplacian degree-zero property, linear equivalence as an equivalence relation, the identification of chip-firing with Laplacian operations, the genus formula g(K_n) = (n−1)(n−2)/2 for complete graphs, and rank bounds for negative-degree divisors. The formalization covers divisors, chip-firing, the Laplacian, linear equivalence, the canonical divisor, genus, q-reduced divisors, and divisor rank as definitions.

The most promising cross-domain connection emerging from this cycle is between chip-firing theory and tropical geometry. Our formalized Laplacian/linear-equivalence framework provides the exact discrete skeleton needed for tropical intersection theory on metric graphs. The existing Catalog work on tropical semirings and the CDPR Brill-Noether formalization can be directly connected to our chip-firing infrastructure. Additionally, the Laplacian lattice Im(Δ) ⊂ ℤ^V connects to lattice-based cryptography (via the Catalog's `Cryptography/BerggrenDiophantineLattice.lean`) and the critical group structure connects to spectral graph theory through the matrix-tree theorem.

The highest breakthrough potential lies in Direction 1 (full Riemann-Roch formalization), which would be among the first complete machine-verified proofs of the Baker-Norine theorem. Direction 3 (Smith normal form and Jacobian structure) has the most unexpected cross-domain potential, linking graph theory to number theory and cryptography. Direction 2 (metric graph extension) bridges to tropical geometry and algebraic geometry proper.

---

### Direction 1: Full Baker-Norine Riemann-Roch via Dhar's Burning Algorithm

**Conjecture**: For any divisor D on a connected graph G with genus g = |E| − |V| + 1, the divisor rank r(D) satisfies r(D) − r(K_G − D) = deg(D) − g + 1, where K_G(v) = deg(v) − 2 is the canonical divisor and r(D) is the maximum k such that D − E is linearly equivalent to an effective divisor for all effective divisors E of degree k (with r(D) = −1 if D has no effective representative).

**Test**: Compute r(D) and r(K_G − D) for all divisors D with 0 ≤ deg(D) ≤ 2g on all connected graphs with ≤ 7 vertices. Verify the identity holds in every case. A single counterexample disproves the theorem (which is known to be true, so none should exist).

**Impact**: A complete formalization of Baker-Norine Riemann-Roch would be one of the first machine-verified proofs of this result. It would establish a formal bridge between combinatorial graph theory and algebraic geometry, and provide a verified foundation for tropical Brill-Noether theory.

**Catalog References**: `EML/BakerNorine.lean` (this cycle's algebraic foundations), `Catalog/Tropical/DivisorTheory.lean` (tree-level divisor theory)

**Proof Strategy**: The proof requires three main components:
1. **Existence and uniqueness of q-reduced forms**: Prove that every divisor has a unique q-reduced representative in its linear equivalence class. Use a potential argument: define the "q-potential" Φ(D) = D(q) and show that the q-reduction algorithm (firing superlevel sets) strictly decreases Φ while the degree is conserved. Uniqueness follows from the fact that two distinct q-reduced divisors in the same class would give a non-trivial element of ker(Δ) ∩ ℤ_≥0^{V\{q}}, which is empty for connected graphs.
2. **Dhar's burning characterization**: Prove that D is q-reduced iff every non-empty S ⊆ V\{q} contains a vertex v with D(v) < outdeg_S(v). This is equivalent to Dhar's burning algorithm: D is q-reduced iff starting a fire at q burns the entire graph.
3. **The rank formula**: Prove that if D_q is the q-reduced form of D, then r(D) = min_{v≠q} D_q(v) if D_q is effective, and r(D) = −1 otherwise. The key lemma is that r(D) = max{k : D_q(v) ≥ k for all v ≠ q} when D_q is effective.

The Riemann-Roch identity then follows from comparing the q-reduced forms of D and K_G − D. The key insight is that the q-reduced form of K_G − D can be expressed in terms of the q-reduced form of D through a complementation identity.

**Domain Bridges**: Graph combinatorics ↔ Algebraic geometry (Riemann-Roch), Chip-firing ↔ Tropical geometry, Laplacian lattices ↔ Lattice cryptography

**Lineage**: Builds on the 15 theorems from this cycle, especially `canonical_degree`, `laplacian_degree_zero`, `linEquiv_preserves_degree`, and the equivalence relation structure of `linEquiv`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Riemann-Roch on Metric Graphs

**Conjecture**: The Baker-Norine Riemann-Roch theorem extends to metric graphs (graphs with positive real edge lengths), where divisors are formal sums of points on edges and linear equivalence is defined via piecewise-linear functions with integer slopes. Specifically, for a metric graph Γ of genus g and any divisor D on Γ, r(D) − r(K_Γ − D) = deg(D) − g + 1.

**Test**: Implement a numerical metric graph simulator. Discretize a metric graph Γ by subdividing edges into n segments each, forming a combinatorial graph G_n. Verify that r_{G_n}(D_n) converges to the metric rank r_Γ(D) as n → ∞ for specific divisors on the theta graph (two vertices connected by three edges of varying lengths).

**Impact**: A formal metric graph Riemann-Roch theorem would bridge discrete chip-firing to continuous tropical geometry, enabling formal proofs of tropical Brill-Noether results. This is the key step toward formalizing the CDPR theorem.

**Catalog References**: `EML/BakerNorine.lean`, `Catalog/Tropical/DivisorTheory.lean`, `Catalog/Bridges/OperadicTropicalization.lean`

**Proof Strategy**: 
1. Define metric graphs as combinatorial graphs with edge length functions ℓ : E → ℝ_{>0}.
2. Define divisors on metric graphs as elements of the free abelian group on points of the metric graph.
3. Define rational functions as continuous piecewise-linear functions with integer slopes.
4. Prove the Laplacian degree-zero property for metric graphs using the slope-sum formula.
5. Establish the approximation theorem: the rank on a fine subdivision converges to the metric rank.
6. Use the combinatorial Riemann-Roch (Direction 1) and the approximation theorem to deduce the metric version.

Key Mathlib requirements: `MeasureTheory.Measure.Lebesgue`, `Topology.MetricSpace.Basic`, continuous piecewise-linear functions.

**Domain Bridges**: Combinatorial graphs ↔ Metric graphs ↔ Tropical curves ↔ Algebraic curves

**Lineage**: Extends Direction 1 from combinatorial to metric setting.

**Ambition**: grand_challenge

---

### Direction 3: Smith Normal Form of the Laplacian and Jacobian Structure

**Conjecture**: For the cycle graph C_n, the Jacobian group (critical group) Jac(C_n) = ℤ^V / Im(Δ) is isomorphic to ℤ/nℤ. More generally, for any connected graph G, the order of Jac(G) equals the number of spanning trees of G (Kirchhoff's matrix-tree theorem), and the group structure is determined by the Smith normal form of the Laplacian.

**Test**: Compute the Smith normal form of the Laplacian of C_n for n = 3, 4, ..., 20. Verify that the invariant factors are [n] (one copy of n, rest are 1 or 0). For K_4, verify that the invariant factors are [4, 4] (since K_4 has 16 spanning trees and Jac(K_4) ≅ ℤ/4ℤ × ℤ/4ℤ).

**Impact**: The Jacobian group is the fundamental algebraic invariant of a graph, analogous to the Jacobian variety of an algebraic curve. Formalizing its computation via Smith normal form would connect graph theory to computational number theory (integer matrix algorithms) and provide the group-theoretic foundation for discrete logarithm problems on graphs.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean` (Lorentz form and lattice theory), `EML/BakerNorine.lean` (Laplacian definition)

**Proof Strategy**:
1. Formalize the Smith normal form algorithm for integer matrices in Lean.
2. Define the Jacobian as ℤ^n / Im(L) where L is the reduced Laplacian (delete one row and column).
3. Prove that the Smith normal form of the reduced Laplacian gives the group structure.
4. For C_n: show the reduced Laplacian is a tridiagonal matrix with determinant n.
5. For K_n: show the reduced Laplacian has determinant n^{n-2} (Cayley's formula) and compute the Smith normal form.
6. Prove Kirchhoff's theorem: |Jac(G)| = number of spanning trees = any cofactor of L.

**Domain Bridges**: Graph theory ↔ Number theory (Smith normal form), Chip-firing ↔ Lattice cryptography (discrete log in Jacobian), Laplacian ↔ Spectral graph theory

**Lineage**: Builds on the Laplacian definition from this cycle and the lattice theory in Cryptography/BerggrenDiophantineLattice.lean.

**Ambition**: extension

---

### Direction 4: Gonality and Graph Treewidth

**Conjecture**: The gonality of a graph G (the minimum degree of a rank-1 divisor) satisfies gon(G) ≤ tw(G) + 1, where tw(G) is the treewidth. Furthermore, for the complete bipartite graph K_{m,n} with m ≤ n, the gonality is exactly m.

**Test**: Compute the gonality of K_{2,n} for n = 2, 3, ..., 10 using divisor rank computation. Verify that gon(K_{2,n}) = 2. Compute treewidth of K_{m,n} (which is min(m,n)) and verify the inequality.

**Impact**: Gonality is a key invariant in both algebraic geometry (it measures the simplest map to a line) and graph theory (it's related to treewidth, a fundamental parameter in algorithms). A formal proof of the treewidth bound would connect structural graph theory to tropical algebraic geometry.

**Catalog References**: `EML/BakerNorine.lean` (divisor rank definition), `Catalog/Tropical/DivisorTheory.lean`

**Proof Strategy**:
1. Define gonality as gon(G) = min{deg(D) : r(D) ≥ 1}.
2. Define treewidth via tree decompositions.
3. Given a tree decomposition of width k, construct a divisor of degree k+1 and rank ≥ 1 by placing chips according to the tree decomposition.
4. For K_{m,n}: show that placing m chips on one side gives rank ≥ 1 (by pigeon-hole in chip-firing), and that no divisor of degree m−1 can have rank 1 (by considering the linear system).

**Domain Bridges**: Tropical geometry (gonality) ↔ Structural graph theory (treewidth) ↔ Algorithms (fixed-parameter tractability)

**Lineage**: Builds on divisor rank from this cycle.

**Ambition**: extension

---

### Direction 5: Chip-Firing and Self-Organized Criticality

**Conjecture**: On any connected graph G with n vertices, the number of critical configurations (maximally stable configurations that are recurrent under chip-firing) equals the number of spanning trees of G. Furthermore, the critical configurations form a torsor for the Jacobian group Jac(G).

**Test**: Enumerate all critical configurations of C_5 and K_4. Verify that C_5 has 5 critical configurations (= spanning trees) and K_4 has 16 (= 4^2 spanning trees). Verify the group action: for each critical configuration c and each element g of the Jacobian, c + g reduces to a unique critical configuration c'.

**Impact**: This connects Baker-Norine theory to statistical physics (abelian sandpile model) and dynamical systems. The critical group/Jacobian acts as a symmetry group of the sandpile dynamics, and the chip-firing process is a discrete model of self-organized criticality.

**Catalog References**: `EML/BakerNorine.lean`, `Computation/InfoEfficientAlgorithms.lean` (algorithmic aspects)

**Proof Strategy**:
1. Define a configuration as *stable* if 0 ≤ D(v) < deg(v) for all v ≠ q.
2. Define a stable configuration as *recurrent* if it can be reached from any configuration by chip-firing.
3. Prove that recurrent = critical: a stable configuration is recurrent iff it passes Dhar's burning test (every vertex burns when q fires).
4. Establish a bijection between critical configurations and elements of the Jacobian via the "burning bijection" of Dhar.
5. Prove this bijection is equivariant under the Jacobian action.

**Domain Bridges**: Chip-firing ↔ Statistical physics (self-organized criticality), Jacobian group ↔ Sandpile dynamics, Graph theory ↔ Dynamical systems

**Lineage**: Builds on chip-firing dynamics and Laplacian structure from this cycle.

**Ambition**: extension
