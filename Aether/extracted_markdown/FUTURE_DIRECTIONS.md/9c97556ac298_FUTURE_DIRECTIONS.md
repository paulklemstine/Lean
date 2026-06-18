# Future Directions: Tropical Compactification of Moduli Spaces

## Synthesis

This research cycle formalized the combinatorial backbone of the tropical compactification of M_g: stable graphs, boundary divisors, the edge bound |E| ≤ 3g − 3, and the handshaking lemma. The key discovery was that the edge bound follows purely from the stability condition without requiring the genus-2 hypothesis — the stability constraint alone forces |E| ≤ 3g − 3, which is a cleaner and more general statement than typically stated in the literature.

The most promising cross-domain connection is between the tropical moduli space and the existing tropical semiring formalization in the Catalog. The piecewise-linear structure of tropical curves is governed by the tropical semiring operations (min, +), and the cone complex structure of M_g^{trop} can be viewed as a tropical variety in its own right. This connects the boundary stratification to tropical linear algebra (the Catalog's tropical matrix theory) and to the spectral theory of tropical matrices.

The direction with highest breakthrough potential is the **Tropical Torelli Rigidity** direction below, because it connects graph theory, algebraic geometry, and tropical geometry through a single invariant (the period matrix), and partial results by Chan suggest that the tropical Torelli map is far from injective for large genus — understanding exactly when injectivity fails would be a genuine contribution.

---

### Direction 1: Tropical Torelli Rigidity for Low Genus

**Conjecture**: The tropical Torelli map τ_g^{trop} : M_g^{trop} → A_g^{trop} (sending a tropical curve to its tropical Jacobian) is injective on the set of 3-connected trivalent graphs of genus g ≤ 5, but fails to be injective for g ≥ 6 due to the existence of non-isomorphic 3-connected trivalent graphs with identical cycle space metrics.

**Test**: Enumerate all trivalent graphs of genus g ≤ 6 (there are finitely many). For each pair, check whether the tropical period matrices (the g × g matrix of cycle intersection lengths) are identical. If two non-isomorphic graphs share the same period matrix, the conjecture's failure boundary is confirmed.

**Impact**: If true for g ≤ 5, this gives a computational certificate for tropical Torelli injectivity in low genus, extending Chan's work. The failure at g = 6 would identify the precise genus where tropical curve recovery from Jacobian data becomes impossible, which has implications for cryptographic applications of tropical geometry.

**Catalog References**: `Tropical/ModuliCompactification/Theorems.lean` (edge bound, stability), `Tropical/Arithmetic/TropicalBSDAbelianVariety.lean` (tropical abelian variety theory)

**Proof Strategy**: Define the tropical period matrix as a function from metric graphs to symmetric matrices. Use the graph Laplacian and its Moore-Penrose pseudoinverse to compute periods. For injectivity, show that the period matrix determines the graph up to isomorphism by recovering edge lengths from cycle lengths. For non-injectivity, construct an explicit counterexample pair.

**Domain Bridges**: Tropical Geometry <-> Algebraic Geometry (classical Torelli), Graph Theory <-> Linear Algebra (Laplacian spectrum)

**Lineage**: Builds on `edge_genus_inequality`, `smoothGraph_totalGenus`, and the tropical curve definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Marked Tropical Curves and M_{g,n}

**Conjecture**: For the moduli space M_{g,n}^{trop} of tropical curves of genus g with n marked points, the edge bound generalizes to |E| ≤ 3g − 3 + n, and the number of boundary divisors of M̄_{g,n} is ⌊g/2⌋ + 1 + (number of partitions of [n] into two non-empty subsets compatible with genus constraints).

**Test**: Formalize stable graphs with n marked legs (half-edges). Prove the generalized edge bound. Count boundary divisors for small (g, n) values and verify against known results from the literature (e.g., M_{0,n} has boundary divisors counted by the Catalan numbers, M_{1,1} has one boundary divisor).

**Impact**: This extends the current formalization to the most practically important moduli spaces. M_{0,n} is central to Gromov-Witten theory, and M_{1,1} is the modular curve. Having a unified framework for arbitrary (g, n) would enable formalization of the tropical Kontsevich formula for curve counting.

**Catalog References**: `Tropical/ModuliCompactification/Defs.lean` (StableGraph, TropicalCurve), `boundary_divisor_count`

**Proof Strategy**: Extend `StableGraph` with a `numLegs : ℕ` field and a `legAttachment : Fin numLegs → Fin numVerts` function. Modify the stability condition to 2g(v) − 2 + val(v) + n(v) > 0 where n(v) counts legs at v. The edge bound proof generalizes by adding n to the vertex valence sum.

**Domain Bridges**: Tropical Geometry <-> Enumerative Geometry (Gromov-Witten invariants), Combinatorics <-> Number Theory (modular curves)

**Lineage**: Direct extension of the current cycle's `StableGraph` formalization and `edge_genus_inequality`.

**Ambition**: extension

---

### Direction 3: Tropical Matrix Cones and the Secondary Fan

**Conjecture**: The cone complex structure of M_g^{trop} can be realized as a subfan of the secondary fan of the complete graph K_{2g-2}, and the face lattice of this subfan is isomorphic to the poset of stable graphs of genus g ordered by edge contraction.

**Test**: For g = 2, 3, explicitly compute the secondary fan of K_{2g-2} and identify the subfan corresponding to stable graphs. Verify that edge contraction corresponds to face inclusion.

**Impact**: This would give an explicit polyhedral embedding of the tropical moduli space, connecting it to the theory of regular subdivisions and tropical linear spaces. It would also connect to the Catalog's tropical matrix theory.

**Catalog References**: `Tropical/Matrix/Defs.lean`, `Tropical/Matrix/Algebra.lean` (tropical matrices), `edge_genus_inequality`, `handshaking_lemma`

**Proof Strategy**: Define the secondary fan using tropical determinants of the distance matrix. Show that each stable graph Γ defines a cone in the space of edge-length vectors ℝ^{|E(Γ)|}, and that these cones assemble into a fan structure compatible with the secondary fan.

**Domain Bridges**: Tropical Geometry <-> Polyhedral Combinatorics (secondary fans), Algebraic Geometry <-> Discrete Geometry (matroid theory)

**Lineage**: Builds on `edge_genus_inequality` and the tropical matrix theory in the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Intersection Numbers and Psi-classes

**Conjecture**: The intersection number ⟨τ_{d_1} ... τ_{d_n}⟩_g on M̄_{g,n} can be computed as a weighted count of trivalent tropical curves satisfying balancing conditions at marked points, with weights determined by the multinomial coefficients of the vertex contributions. Specifically, for g = 0, the tropical computation recovers the Witten-Kontsevich recursion.

**Test**: For M̄_{0,4}, compute ⟨τ_1⟩_0 = 1 both classically and tropically. For M̄_{0,5}, verify ⟨τ_1 τ_1⟩_0 = 1. For M̄_{1,1}, verify ⟨τ_1⟩_1 = 1/24.

**Impact**: A formalized tropical proof of the Witten-Kontsevich theorem would be a landmark result, connecting string theory (the KdV hierarchy) to combinatorics through tropical geometry.

**Catalog References**: `Tropical/ModuliCompactification/Theorems.lean` (boundary stratification), `sep_codimension_one`, `nonsep_codimension_one`

**Proof Strategy**: Define tropical psi-classes as piecewise-linear functions on M_g^{trop}. Show that their product (tropical intersection) reduces to a sum over trivalent graphs. Use the recursion from the forgetful map M_{0,n+1} → M_{0,n} to derive the tropical analog of the string equation.

**Domain Bridges**: Tropical Geometry <-> Mathematical Physics (string theory, KdV), Combinatorics <-> Representation Theory (Virasoro algebra)

**Lineage**: Builds on the boundary divisor theory from this cycle and would connect to the tropical semiring operations in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Computational Enumeration of Stable Graphs

**Conjecture**: The number S(g) of isomorphism classes of stable graphs of genus g satisfies the asymptotic formula S(g) ~ C · (12g-12)! / (g! · 6^{2g-2}) for some constant C, and the number of trivalent (maximally degenerate) stable graphs grows as a fixed fraction of S(g).

**Test**: Enumerate S(g) for g = 2, 3, 4, 5, 6 computationally and fit the asymptotic formula. Compare with known values from graph enumeration databases.

**Impact**: Understanding the growth rate of stable graph types is essential for computational tropical geometry — it determines the complexity of algorithms that sum over all boundary strata.

**Catalog References**: `Tropical/ModuliCompactification/Defs.lean` (StableGraph), `edge_genus_inequality`, `stability_valence_bound`

**Proof Strategy**: Use Burnside's lemma to count stable graphs up to isomorphism. The generating function approach uses the species of stable graphs, which satisfies a functional equation from the decomposition into vertices and edges.

**Domain Bridges**: Tropical Geometry <-> Enumerative Combinatorics (species theory), Algebraic Geometry <-> Computational Complexity (enumeration algorithms)

**Lineage**: Direct computational extension of the definitions from this cycle.

**Ambition**: extension
