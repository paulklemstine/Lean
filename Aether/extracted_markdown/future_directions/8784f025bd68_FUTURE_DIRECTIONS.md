# Future Directions: Graph Riemann-Roch and Chip-Firing Theory

## Synthesis

This cycle established the formal foundations of Baker-Norine theory for finite graphs: divisors, chip-firing, the canonical divisor, genus, linear equivalence, and divisor rank. The key structural results — chip-firing conservation, the 2g-2 degree formula for the canonical divisor, and the negative-degree obstruction — form the base layer for a deeper formalization of the Riemann-Roch theorem itself.

The most promising cross-domain connection is between **tropical geometry and network theory**. The chip-firing game simultaneously models tropical curve theory (connecting to the Catalog's tropical geometry bridges in `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`) and network resilience (connecting to graph capacity results in `Bridges/Catalog/Pythagorean/TropicalBridge/TropicalInformationTheory.lean`). The canonical divisor, which we showed has degree 2g-2 and rank g-1 on complete graphs, encodes the same information as the dualizing sheaf in algebraic geometry — this duality is the engine that drives Riemann-Roch.

The direction with highest breakthrough potential is **Direction 2 (Jacobian structure)**: proving that the sandpile group of a graph is isomorphic to the Jacobian, which would connect the Catalog's modular chip-firing dynamics (`Bridges/ModularCFDynamics.lean`) to classical algebraic geometry. This is both tractable (the group structure is well-understood) and impactful (it would unify combinatorial, algebraic, and tropical perspectives).

---

### Direction 1: Formal Proof of the Baker-Norine Riemann-Roch Theorem

**Conjecture**: For any divisor D on a connected graph G with canonical divisor K_G and genus g, the rank function satisfies r(D) - r(K_G - D) = deg(D) + 1 - g.

**Test**: Verify the theorem for all divisors on the Petersen graph (10 vertices, genus 6) and all graphs on ≤ 7 vertices. A single counterexample disproves it (none expected — the theorem is proved in the literature). More practically, test whether the formal proof can be constructed from the lemmas established in this cycle.

**Impact**: A fully formal proof of Baker-Norine would be one of the first complete formalizations of a major theorem in tropical geometry. It would validate the entire chip-firing framework and enable downstream applications (specialization lemma, gonality bounds, tropical Brill-Noether theory).

**Catalog References**: `Bridges/GraphRiemannRoch.lean` (this cycle's foundational lemmas), `FINAL/Bridges/TropicalPersistenceRealizationDuality.lean` (tropical geometry bridge)

**Proof Strategy**: The Baker-Norine proof proceeds by:
1. Defining q-reduced divisors and proving their uniqueness (requires Dhar's burning algorithm formalization)
2. Proving that every divisor class has a unique q-reduced representative
3. Establishing that r(D) = max over sinks q of {D_q(q)}, where D_q is the q-reduced form
4. Using a duality argument: the q-reduced form of K-D with respect to q is related to the q-reduced form of D
5. The Riemann-Roch formula follows from this duality and a counting argument

Key lemmas needed:
- `q_reduced_unique`: The q-reduced divisor in each equivalence class is unique
- `q_reduced_rank`: r(D) ≥ k iff the q-reduced form has q-coordinate ≥ k (for all q)
- `duality_q_reduced`: Relationship between q-reduced forms of D and K-D
- `superstable_characterization`: A divisor is q-reduced iff it satisfies Dhar's condition

**Domain Bridges**: Tropical Geometry <-> Combinatorics, Algebraic Geometry <-> Graph Theory

**Lineage**: Builds directly on the foundational lemmas from this cycle: `chipFire_preserves_degree`, `canonical_divisor_degree`, `firingVector_sum_eq_zero`, `linearEquiv_degree`, `negative_degree_not_equiv_effective`.

**Ambition**: grand_challenge

---

### Direction 2: The Jacobian Group and Sandpile Group Isomorphism

**Conjecture**: The Jacobian group Jac(G) = Div^0(G) / Prin(G) (degree-zero divisors modulo principal divisors) is isomorphic to the sandpile group (critical configurations under chip-firing). For the complete graph K_n, this group has order n^{n-2} (by Kirchhoff's matrix tree theorem = number of spanning trees).

**Test**: Compute Jac(K_n) for n = 3, 4, 5 explicitly and verify |Jac(K_n)| = n^{n-2}. For K_3: |Jac| = 3. For K_4: |Jac| = 16. For K_5: |Jac| = 125.

**Impact**: This isomorphism connects three different areas: (1) algebraic geometry (Jacobian variety), (2) statistical physics (abelian sandpile model), and (3) combinatorics (spanning tree enumeration). It would bridge the Catalog's modular chip-firing dynamics to classical algebraic structure theory.

**Catalog References**: `Bridges/ModularCFDynamics.lean` (modular chip-firing), `Bridges/GraphRiemannRoch.lean` (divisor theory)

**Proof Strategy**:
1. Define the group of principal divisors Prin(G) = {Lf : f ∈ ℤ^V} ∩ Div^0
2. Define Jac(G) = Div^0(G) / Prin(G) as a quotient group
3. Show Jac(G) ≅ ℤ^V / (Im(L) + ℤ·1) where L is the Laplacian
4. Compute |Jac(G)| = det(L') where L' is any cofactor of L (by the Matrix Tree Theorem)
5. For K_n: det(L') = n^{n-2} (Cayley's formula)

Key lemma: `Matrix.det_laplacian_cofactor_eq_spanning_trees`

**Domain Bridges**: Algebra <-> Combinatorics, Statistical Physics <-> Algebraic Geometry

**Lineage**: Builds on `ChipFiring.LinearEquiv`, `ChipFiring.firingVector`, and the degree preservation results from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Brill-Noether Theory and Gonality Bounds

**Conjecture**: For a graph G of genus g, the gonality gon(G) = min{deg(D) : r(D) ≥ 1} satisfies gon(G) ≤ ⌊(g+3)/2⌋. For the complete graph K_n, gon(K_n) = ⌈n/2⌉.

**Test**: Compute the gonality of K_n for n = 3, ..., 8 and all graphs on ≤ 6 vertices. Verify the upper bound gon(G) ≤ ⌊(g+3)/2⌋ computationally. A counterexample would disprove the bound.

**Impact**: Tropical gonality bounds have direct applications to algebraic geometry via Baker's specialization lemma. If gon(G) ≥ k for a graph G, then any algebraic curve specializing to G also has gonality ≥ k. This has been used to prove new results about the gonality of modular curves and Brill-Noether generality.

**Catalog References**: `FINAL/Bridges/TropicalPersistenceRealizationDuality.lean` (tropical persistence), `Bridges/GraphRiemannRoch.lean` (rank computation)

**Proof Strategy**:
1. Define gonality as the minimum degree of a rank-1 divisor
2. Use the Riemann-Roch theorem: if deg(D) ≥ g, then r(D) ≥ deg(D) - g + 1 ≥ 1 when deg(D) ≥ g
3. Refine using the Clifford bound: r(D) ≤ deg(D)/2 for special divisors
4. For K_n: use the symmetry of the complete graph to compute gonality exactly

Key definition: `GraphGonality G := Finset.inf' {D | ChipFiring.HasRankAtLeast G D 1} degree`

**Domain Bridges**: Tropical Geometry <-> Algebraic Geometry, Combinatorics <-> Number Theory

**Lineage**: Builds on the rank definition `HasRankAtLeast` and the Riemann-Roch framework from this cycle.

**Ambition**: extension

---

### Direction 4: Chip-Firing on Random Graphs and Phase Transitions

**Conjecture**: For the Erdős-Rényi random graph G(n, p), the expected rank of the canonical divisor concentrates around g - 1 (where g is the genus) when p > log(n)/n (connected regime). At the connectivity threshold p = log(n)/n, a phase transition occurs where rank(K_G) drops sharply.

**Test**: Sample 1000 random graphs G(n, p) for n = 20, 50, 100 at p values crossing the connectivity threshold. Compute rank(K_G) for each and plot the distribution. The conjecture predicts a sharp transition near p = log(n)/n.

**Impact**: This would connect chip-firing theory to random graph theory and statistical physics. If verified, it would suggest that the Riemann-Roch structure is robust under randomization — a key property for applications in network design.

**Catalog References**: `Bridges/GraphRiemannRoch.lean` (canonical divisor, genus), `FINAL/Bridges/TropicalInformationTheory.lean` (information-theoretic capacity of graphs)

**Proof Strategy**:
1. Show that for connected G(n,p), rank(K_G) = g - 1 using the Baker-Norine theorem
2. At the connectivity threshold, use the structure of barely-connected random graphs (giant component analysis)
3. Relate the phase transition to the spectral gap of the Laplacian
4. Use concentration inequalities for genus (which depends on edge count)

**Domain Bridges**: Probability <-> Tropical Geometry, Statistical Physics <-> Graph Theory

**Lineage**: Builds on `canonical_divisor_degree`, `K_genus`, and the canonical rank conjecture verification from this cycle.

**Ambition**: extension

---

### Direction 5: Specialization from Algebraic Curves to Graphs

**Conjecture**: Baker's specialization lemma can be formalized: if X is a smooth algebraic curve over a discretely valued field with reduction graph G, then for any divisor D on X, r_X(D) ≤ r_G(D̄), where D̄ is the specialization of D to G. In particular, the gonality of X is bounded below by the gonality of G.

**Test**: Verify the specialization inequality for elliptic curves (genus 1) reducing to cycle graphs. For an elliptic curve with good reduction, the specialization should preserve rank exactly. For bad reduction, the inequality should be strict in specific computable cases.

**Impact**: This is the deepest connection between algebraic geometry and graph theory in the Baker-Norine framework. A formal proof would provide a certified tool for bounding invariants of algebraic curves using combinatorial methods — a technique already used in research-level algebraic geometry.

**Catalog References**: `Bridges/GraphRiemannRoch.lean` (graph divisor rank), `FINAL/Bridges/TropicalPersistenceRealizationDuality.lean` (tropical-algebraic bridge)

**Proof Strategy**:
1. Define the specialization map from Div(X) to Div(G) using the intersection pairing on the special fiber
2. Show that effective divisors specialize to effective divisors
3. Show that linearly equivalent divisors specialize to linearly equivalent divisors
4. Conclude r_X(D) ≤ r_G(D̄) by definition of rank

This requires formalizing: (a) models of curves over DVRs, (b) the dual graph of the special fiber, (c) the specialization map. Each of these is a substantial piece of algebraic geometry.

**Domain Bridges**: Algebraic Geometry <-> Combinatorics, Number Theory <-> Tropical Geometry

**Lineage**: Builds on all foundational results from this cycle, plus the tropical persistence framework from the Catalog.

**Ambition**: grand_challenge
