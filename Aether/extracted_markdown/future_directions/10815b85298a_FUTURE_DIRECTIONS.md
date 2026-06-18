# Future Directions

## Synthesis

This cycle established a rigorous formalization of Baker-Norine chip-firing theory on finite graphs, with deep specializations to complete graphs K_n and formal derivations of key consequences of the Riemann-Roch theorem (Riemann's inequality, canonical rank = g−1, Serre duality, double duality). The most promising cross-domain connection is the **bridge between combinatorial chip-firing and tropical geometry**: the Baker-Norine theorem is the Riemann-Roch theorem for tropical curves, and our formalized Laplacian/linear equivalence framework provides the algebraic backbone for tropical divisor theory.

The computational verification revealed that the gonality of K_n exceeds 2 for n ≥ 4, suggesting that the Brill-Noether theory of complete graphs is richer than initially expected. The effectiveness transition of the canonical divisor at n = 3 connects to the classical distinction between rational (g = 0) and non-rational (g ≥ 1) curves. The degree conservation laws (laplacian_degree_zero, chipFire_preserves_degree) were the easiest to formalize but serve as the foundation for all deeper results.

The highest breakthrough potential lies in **Direction 1** (tropical Brill-Noether for complete graphs), which would characterize the full landscape of achievable ranks on K_n and connect to the classical Brill-Noether theorem via specialization. This would bridge combinatorics, algebraic geometry, and tropical geometry in a single framework.

---

### Direction 1: Tropical Brill-Noether Theory for Complete Graphs

**Conjecture**: The Brill-Noether number ρ(g, r, d) = g − (r+1)(g−d+r) exactly characterizes the existence of divisors of degree d and rank ≥ r on K_n (where g = (n−1)(n−2)/2). Specifically: K_n has a divisor of degree d and rank ≥ r if and only if ρ(g, r, d) ≥ 0.

**Test**: Compute the rank of all divisor classes of each degree d ∈ [0, 2g−2] on K_n for n = 3, 4, 5, 6. Check whether the maximum achievable rank matches the Brill-Noether prediction. The gonality (minimum degree with rank ≥ 1) should be ⌊n/2⌋ + 1 by Cools-Draisma-Payne-Robeva.

**Impact**: If true, this would confirm the Brill-Noether conjecture for the complete graph — a deep structural result that mirrors the classical Brill-Noether theorem for smooth curves. If false, the failure would identify which divisor classes on K_n violate the Brill-Noether bound, revealing new phenomena unique to discrete geometry.

**Catalog References**: `Catalog/EML/BakerNorine.lean`, `Catalog/Tropical/CompleteGraph.lean`, `Novelty/CompleteGraphChipFiring.lean`

**Proof Strategy**: 
1. Formalize the Brill-Noether number ρ(g, r, d) = g − (r+1)(g−d+r)
2. Use the symmetry group S_n acting on divisors of K_n to reduce the search space
3. Establish that the gonality of K_n is ⌊(n+2)/2⌋ using explicit constructions
4. Prove the upper bound r(D) ≤ ρ(g, r, d) using Clifford's inequality and specialization

**Domain Bridges**: Combinatorics (chip-firing on symmetric graphs) ↔ Algebraic Geometry (Brill-Noether theory on curves) ↔ Tropical Geometry (tropical linear series)

**Lineage**: Builds on `genus_complete_graph`, `canonical_complete_graph`, `rank_canonical_complete`, and `clifford_inequality` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: q-Reduced Divisors and Dhar's Burning Algorithm

**Conjecture**: Dhar's burning algorithm can be fully formalized in Lean 4, yielding a constructive proof that every divisor class has a unique q-reduced representative, which in turn provides a constructive proof of the Baker-Norine Riemann-Roch theorem (eliminating our current axiomatization).

**Test**: Formalize the burning algorithm as a decidable procedure. Prove termination (the algorithm always reaches a fixed point in at most |V| − 1 steps). Prove uniqueness of the q-reduced form. Then derive Baker-Norine RR from the existence and uniqueness of q-reduced divisors.

**Impact**: A fully constructive proof of Baker-Norine RR in Lean 4 would be a first in formalized mathematics. The q-reduced divisor approach also yields efficient algorithms (O(|V|²) time) for rank computation, enabling large-scale experiments.

**Catalog References**: `Catalog/EML/BakerNorine.lean` (IsQReduced definition), `Novelty/ChipFiringDefs.lean`

**Proof Strategy**:
1. Formalize Dhar's burning as a function `V → Divisor → Finset V` (the set of unburned vertices)
2. Prove that firing the unburned set strictly reduces a potential function (lexicographic ordering)
3. Prove termination using well-founded induction on the potential
4. Prove uniqueness: two q-reduced divisors in the same class must be equal
5. Derive Baker-Norine: for any D, its q-reduced form D_q satisfies r(D) = D_q(q) if effective, −1 otherwise

**Domain Bridges**: Algorithms (burning algorithm, sandpile models) ↔ Combinatorics (q-reduced divisors) ↔ Algebraic Geometry (Riemann-Roch)

**Lineage**: Extends the definitions in `Novelty/ChipFiringDefs.lean` and would replace the hypothesis-based approach in `Novelty/CompleteGraphChipFiring.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Chip-Firing on Weighted Graphs and Metric Graphs

**Conjecture**: The Baker-Norine theory extends to weighted graphs (where each edge has a positive integer weight), with the canonical divisor K(v) = Σ_{e∋v} w(e) − 2, the genus g = Σ_e w(e) − |V| + 1, and the Riemann-Roch formula r(D) − r(K−D) = deg(D) + 1 − g. The rank on a weighted graph equals the rank on the corresponding subdivision (where each edge of weight w is replaced by a path of w edges).

**Test**: Implement weighted chip-firing and verify Riemann-Roch on weighted complete graphs and weighted cycles. Check that subdivision preserves rank. The genus of the weighted K_n with all weights w should be w · n(n−1)/2 − n + 1.

**Impact**: This bridges finite chip-firing to tropical geometry, where metric graphs (graphs with real-valued edge lengths) are the central objects. The weighted version is the discrete approximation to the tropical Riemann-Roch theorem of Gathmann-Kerber and Mikhalkin-Zharkov.

**Catalog References**: `Catalog/Tropical/ChipFiring/Defs.lean`, `Catalog/Tropical/DivisorTheory.lean`

**Proof Strategy**:
1. Define weighted graph divisors: modify the Laplacian to account for edge weights
2. Define the weighted canonical divisor K(v) = weighted_deg(v) − 2
3. Prove deg(K) = 2g − 2 for weighted genus
4. Verify that subdivision is rank-preserving
5. State and prove the weighted Baker-Norine theorem

**Domain Bridges**: Discrete Mathematics (weighted graphs) ↔ Tropical Geometry (metric graphs) ↔ Analysis (heat equation on graphs)

**Lineage**: Generalizes the complete graph results in this cycle to the weighted setting.

**Ambition**: extension

---

### Direction 4: The Jacobian Group and Abel-Jacobi Map

**Conjecture**: The Jacobian group Jac(K_n) (the quotient of degree-0 divisors by principal divisors) is isomorphic to ℤ^{n−1} / Im(L), where L is the reduced Laplacian of K_n. For the complete graph, |Jac(K_n)| = n^{n−2} (Kirchhoff's matrix-tree theorem), and the Abel-Jacobi map φ: V → Jac(K_n) given by φ(v) = [v − v₀] is an embedding.

**Test**: Compute Jac(K_n) explicitly for n = 3, 4, 5 using Smith normal form of the Laplacian. Verify that |Jac(K_n)| equals the number of spanning trees. Prove the Abel-Jacobi embedding for K_n using the symmetry group.

**Impact**: The Jacobian connects chip-firing to the theory of abelian sandpiles, parking functions, and the Kirchhoff matrix-tree theorem. The embedding result is the graph analogue of the Abel-Jacobi theorem for Riemann surfaces.

**Catalog References**: `Novelty/ChipFiringDefs.lean`, `Catalog/EML/BakerNorine.lean`

**Proof Strategy**:
1. Define the Jacobian as the quotient Div⁰(G) / Prin(G)
2. Compute the Smith normal form of the Laplacian of K_n
3. Use Kirchhoff's theorem to show |Jac(K_n)| = n^{n−2}
4. Define the Abel-Jacobi map and prove injectivity on vertices

**Domain Bridges**: Algebra (group theory, Smith normal form) ↔ Combinatorics (spanning trees, parking functions) ↔ Algebraic Geometry (Abel-Jacobi theory)

**Lineage**: Builds on the Laplacian and linear equivalence formalized in `Novelty/ChipFiringDefs.lean` and `Novelty/ChipFiringTheorems.lean`.

**Ambition**: extension

---

### Direction 5: Spectral Methods and the Chip-Firing Zeta Function

**Conjecture**: The Ihara zeta function of K_n, defined as ζ_{K_n}(u) = Π_{[C]} (1 − u^{|C|})^{−1} (product over prime cycles C), satisfies the determinantal formula ζ_{K_n}(u)^{−1} = (1 − u²)^{g−1} det(I − Au + (n−2)u²I), where A is the adjacency matrix of K_n. The poles of ζ_{K_n} encode the eigenvalues of the Laplacian, which in turn control the rate of convergence of chip-firing to equilibrium.

**Test**: Compute the Ihara zeta function for K_3, K_4, K_5 and verify the determinantal formula. Relate the spectral gap of the Laplacian (which is n for K_n) to the mixing time of chip-firing random walks.

**Impact**: This connects chip-firing dynamics to spectral graph theory and number theory (via the analogy between the Ihara zeta and the Riemann zeta function). The spectral gap controls how quickly a random chip-firing process converges, with implications for MCMC sampling on graph divisor spaces.

**Catalog References**: `Catalog/Algebra/SpectralGraphTheory.lean` (if exists), `Novelty/ChipFiringTheorems.lean`

**Proof Strategy**:
1. Define the Ihara zeta function for simple graphs
2. Prove the Bass-Hashimoto determinantal formula
3. Specialize to K_n using the known eigenvalues (n−1 with multiplicity 1, −1 with multiplicity n−1)
4. Relate the spectral gap to chip-firing convergence rates

**Domain Bridges**: Number Theory (zeta functions) ↔ Spectral Theory (graph eigenvalues) ↔ Probability (mixing times) ↔ Combinatorics (chip-firing)

**Lineage**: Connects the Laplacian structure formalized in this cycle to spectral theory.

**Ambition**: grand_challenge
