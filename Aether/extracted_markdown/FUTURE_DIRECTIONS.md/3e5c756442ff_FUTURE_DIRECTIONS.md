# Future Directions

## Synthesis

This research cycle established the algebraic foundations of Baker-Norine theory on finite graphs: divisors, chip-firing, the Laplacian, linear equivalence, the canonical divisor, and the genus. The key structural identities — deg(K_G) = 2g − 2, chip-firing conservation, and the Riemann-Roch degree identity — were proved for arbitrary finite graphs, with specialized results for complete graphs including the genus formula g(K_n) = (n−1)(n−2)/2 and the uniformity of the canonical divisor.

The most promising cross-domain connection is between chip-firing theory and tropical geometry. The divisor theory on graphs is the discrete skeleton of tropical curve theory, and our formalized Laplacian/linear-equivalence framework can serve as the foundation for formalizing tropical intersection theory. The connection to the existing Catalog work on tropical semirings (`Tropical/`) and algebraic circuit complexity (`Algebra/AlgebraicCircuitComplexity.lean`) suggests a bridge: chip-firing rank computations are essentially tropical linear algebra, and the combinatorial structure of the Jacobian group connects to lattice-based cryptography (`Cryptography/BerggrenDiophantineLattice.lean`).

The highest breakthrough potential lies in Direction 1 (full Riemann-Roch), which would be among the first complete formalizations of Baker-Norine and would unlock a cascade of applications in tropical geometry and coding theory. Direction 3 (Jacobian-Kirchhoff connection) has the most unexpected cross-domain potential, linking graph theory to number theory via the Smith normal form of the Laplacian.

---

### Direction 1: Full Baker-Norine Riemann-Roch via Dhar's Algorithm

**Conjecture**: For any divisor D on a connected graph G with genus g ≥ 1, the rank r(D) satisfies r(D) − r(K_G − D) = deg(D) + 1 − g, where r(D) is defined as max{k : for all effective E with deg(E) = k, D − E ~ effective divisor}, with r(D) = −1 if D is not equivalent to any effective divisor.

**Test**: Implement Dhar's burning algorithm to compute q-reduced divisors for K_5 and verify the Riemann-Roch formula for all divisors of degree 0, 1, ..., 2g−2 = 10. Check both sides of the equation computationally. Any counterexample disproves the formalization's correctness.

**Impact**: A complete formalization of Baker-Norine would be a landmark in formalized combinatorics. It would provide machine-verified access to the rank function and its properties, enabling formalized proofs of specialization bounds for algebraic curves.

**Catalog References**: `Algebra/GraphRiemannRoch/Defs.lean` (this cycle's output), `Tropical/` (tropical semiring foundations)

**Proof Strategy**: 
1. Formalize q-reduced divisors: a divisor D is q-reduced if D(v) ≥ 0 for all v ≠ q, and no nonempty subset S ⊆ V\{q} can fire (i.e., for every S, some v ∈ S has D(v) < |{edges from v to V\S}|).
2. Prove existence and uniqueness of q-reduced representatives (Dhar's burning algorithm).
3. Define rank via q-reduced divisors: r(D) = max{k : the q-reduced representative of D − E has non-negative values at all non-q vertices, for all effective E of degree k}.
4. Prove the key lemma: for the q-reduced representative D' of D, either D'(q) ≥ 0 (and D is equivalent to an effective divisor) or D'(q) < 0 (and D is not).
5. Establish the duality: the q-reduced representative of K_G − D has q-value related to the q-value of D's representative by the Riemann-Roch relation.

**Domain Bridges**: Graph Combinatorics <-> Tropical Geometry <-> Algebraic Geometry (via Baker specialization)

**Lineage**: Builds on this cycle's formalization of divisors, chip-firing, canonical divisor, and the degree identities in `Algebra/GraphRiemannRoch/Defs.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Riemann-Roch for Metric Graphs

**Conjecture**: The Baker-Norine theorem extends to metric graphs (graphs with positive real edge lengths). For a metric graph Γ of genus g and a divisor D on Γ, r(D) − r(K_Γ − D) = deg(D) + 1 − g, where the rank is defined using chip-firing with continuous moves along edges.

**Test**: Discretize a genus-2 metric graph (two loops connected at a point) with varying edge lengths. Compute ranks of divisors supported at subdivision points and verify the formula. The formula should be independent of edge lengths — if it fails for some length assignment, the conjecture is false.

**Impact**: Would establish the first formalized connection between combinatorial and continuous tropical geometry. The metric graph Riemann-Roch (Gathmann-Kerber, Mikhalkin-Zharkov) unifies the discrete and continuous theories.

**Catalog References**: `Algebra/GraphRiemannRoch/Defs.lean`, `Tropical/` (tropical foundations)

**Proof Strategy**: 
1. Define metric graphs as finite graphs with a length function l : E → ℝ₊.
2. Define divisors on metric graphs as formal sums of points (including interior edge points).
3. Define rational functions as piecewise-linear functions with integer slopes.
4. Show that for a "generic" metric graph, the ranks equal those of the underlying combinatorial graph.
5. Use the combinatorial Baker-Norine theorem (Direction 1) and a limiting argument.

**Domain Bridges**: Combinatorial Graphs <-> Tropical Curves <-> Algebraic Curves (via non-Archimedean geometry)

**Lineage**: Extends Direction 1 from combinatorial to metric graphs.

**Ambition**: grand_challenge

---

### Direction 3: The Jacobian Group and Kirchhoff's Theorem

**Conjecture**: For a connected graph G on n vertices, the Jacobian group Jac(G) = Div^0(G) / Prin(G) (degree-zero divisors modulo principal divisors) is a finite abelian group of order equal to the number of spanning trees of G. Moreover, the Smith normal form of the reduced Laplacian matrix gives the invariant factor decomposition of Jac(G).

**Test**: Compute Jac(K_5) = ℤ/5 × ℤ/5 × ℤ/5 (since K_5 has 5^3 = 125 spanning trees by Cayley's formula). Verify by computing the Smith normal form of the 4×4 reduced Laplacian of K_5.

**Impact**: This connects graph theory to number theory and lattice theory. The structure of Jac(G) determines the sandpile group, which governs the dynamics of chip-firing. For complete graphs, Jac(K_n) ≅ (ℤ/n)^{n−2} by Cayley's formula, giving a clean algebraic structure.

**Catalog References**: `Algebra/GraphRiemannRoch/Defs.lean` (linear equivalence definition), `Cryptography/BerggrenDiophantineLattice.lean` (lattice theory)

**Proof Strategy**:
1. Define the principal divisor of a function f as div(f)(v) = ∑_w (f(v) − f(w)) over neighbors w of v.
2. Show Prin(G) = image of the Laplacian matrix L.
3. Define Jac(G) = ℤ^n / (L · ℤ^n) restricted to degree-zero.
4. Prove |Jac(G)| = det(L̃) where L̃ is any (n−1) × (n−1) reduced Laplacian.
5. Apply the matrix-tree theorem: det(L̃) = number of spanning trees.

**Domain Bridges**: Graph Theory <-> Linear Algebra <-> Number Theory (Smith normal form) <-> Cryptography (lattice problems)

**Lineage**: Builds on this cycle's linear equivalence definition and Laplacian vector formalization.

**Ambition**: extension

---

### Direction 4: Chip-Firing and Parking Functions on Complete Graphs

**Conjecture**: The number of superstable configurations on K_n (equivalently, the number of G-parking functions) equals n^{n−2}. Each parking function corresponds to a unique labeled rooted tree on n vertices via a bijection that preserves the "level statistic."

**Test**: Enumerate all parking functions for n = 4 (should give 4^2 = 16) and verify the bijection with labeled trees. For n = 5, verify 5^3 = 125 parking functions. Each parking function (a_1, ..., a_{n-1}) satisfies 0 ≤ a_i ≤ i for an appropriate ordering.

**Impact**: Parking functions are central to combinatorics and connect to the Tutte polynomial, Catalan numbers, and the representation theory of the symmetric group. A formal proof of the bijection would be a significant contribution to formalized enumerative combinatorics.

**Catalog References**: `Algebra/GraphRiemannRoch/Defs.lean` (chip-firing on complete graphs)

**Proof Strategy**:
1. Define G-parking functions as divisors D with D(v) ≥ 0 for v ≠ q and no subset S ⊆ V\{q} can legally fire.
2. Prove that the number of G-parking functions equals det(L̃) (the number of spanning trees).
3. For K_n, use Cayley's formula to get n^{n−2}.
4. Construct the explicit bijection via the "depth-first search" labeling of trees.

**Domain Bridges**: Chip-Firing <-> Enumerative Combinatorics <-> Algebraic Combinatorics (symmetric group representations)

**Lineage**: Builds on complete graph chip-firing results from this cycle.

**Ambition**: extension

---

### Direction 5: Gonality Bounds and Treewidth

**Conjecture**: For any graph G, the gonality gon(G) = min{deg(D) : r(D) ≥ 1} satisfies gon(G) ≥ tw(G), where tw(G) is the treewidth. For the complete graph K_n, gon(K_n) = ⌈n/2⌉.

**Test**: Verify gon(K_n) = ⌈n/2⌉ for n = 3, 4, 5, 6, 7 by exhaustive search over all divisors of degree ⌈n/2⌉ − 1 and showing none has rank ≥ 1. Then verify one divisor of degree ⌈n/2⌉ with rank ≥ 1 exists.

**Impact**: The gonality-treewidth inequality provides a new approach to treewidth lower bounds — a problem of central importance in algorithm design and parameterized complexity. If formalized, this would bridge discrete optimization and algebraic graph theory.

**Catalog References**: `Algebra/GraphRiemannRoch/Defs.lean` (divisor rank definition), `Computation/` (complexity theory)

**Proof Strategy**:
1. Formalize treewidth via tree decompositions.
2. Prove that any divisor D with r(D) ≥ 1 must have deg(D) ≥ tw(G) using a "cops and robbers" game characterization.
3. For K_n, construct an explicit divisor of degree ⌈n/2⌉ with rank 1 using the "midpoint divisor" on a Hamiltonian path.

**Domain Bridges**: Chip-Firing <-> Graph Algorithms <-> Parameterized Complexity <-> Algebraic Geometry (gonality of curves)

**Lineage**: Extends this cycle's rank and divisor framework to optimization questions.

**Ambition**: extension
