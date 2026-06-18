# Future Directions: Tropical Brill-Noether Theory

## Synthesis

This cycle established the foundational infrastructure for tropical Brill-Noether theory: the Brill-Noether number ρ(g,d,r) with its key algebraic properties (Serre duality, Clifford bound, Castelnuovo bound), the chip-firing framework on finite graphs (Laplacian action, linear equivalence, degree preservation), and the novel `TropicalLinearSeries` structure that packages divisor rank data. The rank-degree inequality was proved using a constructive argument (point-mass divisors) combined with degree preservation.

The most promising cross-domain connection is between **chip-firing dynamics** and **persistent homology** from topological data analysis. The Laplacian on a graph encodes both the chip-firing game (algebraic geometry) and the combinatorial Hodge theory (topology), suggesting that tropical Brill-Noether invariants could serve as features for topological data analysis of networks. The catalog's `tropical_persistent_rank_eq_classical` theorem (in `Bridges/SimplicialMorse.lean`) already hints at this bridge.

The highest breakthrough potential lies in Direction 1 (Baker-Norine Riemann-Roch), as it would unlock the full tropical Brill-Noether theorem and provide the first complete formalization of a major result in tropical geometry. Direction 3 (tropical Jacobians) has the most novel mathematical content, potentially leading to new results about graph connectivity that are not yet in the literature.

---

### Direction 1: Baker-Norine Riemann-Roch for Graphs

**Conjecture**: For any connected graph G of genus g with divisor D of degree d, and canonical divisor K (where K(v) = deg(v) - 2), the rank function satisfies:
$$r(D) - r(K - D) = d - g + 1$$
where r(D) is defined as the maximum integer r ≥ -1 such that D - E is linearly equivalent to an effective divisor for every effective E of degree r.

**Test**: Compute r(D) and r(K-D) for all divisors on the chain of 3 loops (genus 3, 4 vertices) with degree d ∈ {0, 1, 2, 3, 4}. The equality should hold for every divisor class. Implementation: enumerate all q-reduced divisors of each degree, compute ranks via Dhar's burning algorithm, verify the equation.

**Impact**: A formalized Riemann-Roch for graphs would be the first such result in any proof assistant. It would immediately enable the full tropical Brill-Noether theorem (both existence and non-existence directions) and connect to the arithmetic geometry of curves over non-archimedean fields.

**Catalog References**: `Geometry/TropicalBrillNoether.lean` (this cycle's Lean formalization), `Bridges/SimplicialMorse.lean` (`tropical_persistent_rank_eq_classical`), `Geometry/EulerTopology.lean` (`degree_genus_component_chain`)

**Proof Strategy**: 
1. Formalize q-reduced divisors and prove their uniqueness (via Dhar's burning algorithm termination).
2. Define the rank function r(D) as the minimum of D_q(q) over all vertices q, where D_q is the q-reduced representative.
3. Prove the "easy" inequality r(D) ≥ d - g using the degree of the q-reduced form.
4. Prove the "hard" direction using the burning bijection: show that the set of acyclic orientations compatible with D is in bijection with those compatible with K-D, with a shift of d - g + 1.

**Domain Bridges**: Geometry <-> Combinatorics, Algebra <-> Topology

**Lineage**: Builds on the Laplacian framework, linEquiv, and degree preservation theorems from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Specialization Lemma and the Classical Bridge

**Conjecture**: There exists a formalization of Baker's specialization lemma stating: if X is a smooth projective curve over a non-archimedean field K with skeleton graph G, and D is a divisor on X, then rank_G(trop(D)) ≥ rank_X(D). Moreover, the inequality is an equality for "sufficiently generic" curves.

**Test**: Formalize the statement for the case where K = ℂ((t)) (formal Laurent series) and X is a Mumford curve. Verify that for a genus-2 Mumford curve, the specialization map sends the canonical divisor K_X (rank 1, degree 2) to a divisor of rank ≥ 1 on the skeleton graph.

**Impact**: This would complete the tropical proof of the classical Brill-Noether theorem. It bridges tropical combinatorics and scheme-theoretic algebraic geometry, a connection that has never been formalized.

**Catalog References**: `Geometry/TropicalBrillNoether.lean`, `Tropical/FormulaDefinability.lean` (`tropical_formula_iff_recognizable_and_deriv_closed`)

**Proof Strategy**:
1. Define tropical curves as metric graphs (extend `SimpleGraph` with edge-length data).
2. Define the tropicalization map on divisors.
3. State specialization as: for each effective E on G with deg(E) ≤ rank_X(D), there exists effective E' on X with trop(E') = E and D - E' is linearly equivalent to effective.
4. The key step uses the semicontinuity of rank in families.

**Domain Bridges**: Geometry <-> Algebra, Tropical <-> Classical

**Lineage**: Requires Direction 1 (Riemann-Roch) as a prerequisite.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Jacobians and the Abel-Jacobi Map

**Conjecture**: For a connected graph G of genus g, the tropical Jacobian Jac(G) = ℤ^V / Im(L) (where L is the Laplacian matrix) has exactly g invariant factors greater than 1. The number of elements |Jac(G)| equals the number of spanning trees of G (Kirchhoff's theorem). Moreover, the Abel-Jacobi map φ: Div^0(G) → Jac(G) identifies linear equivalence classes.

**Test**: Compute Jac(G) for the chain of g loops, g = 1, ..., 5. Verify |Jac(G)| equals the number of spanning trees (which for the chain of g loops with double edges is 2^g · (g+1) by a combinatorial formula). Verify the Smith normal form has g non-trivial invariant factors.

**Impact**: A formalized tropical Jacobian would connect to the catalog's algebra of lattices and quadratic forms. The Kirchhoff matrix-tree theorem, if formalized as a consequence, would be a significant result in combinatorial algebraic geometry.

**Catalog References**: `Algebra/Basic.lean`, `Cryptography/BerggrenDiophantineLattice.lean` (lattice theory), `Geometry/TropicalBrillNoether.lean`

**Proof Strategy**:
1. Define the Laplacian matrix as a `Matrix (Fin n) (Fin n) ℤ`.
2. Define Jac(G) = ℤ^n / Im(L) using Mathlib's quotient module infrastructure.
3. Prove |Jac(G)| = det(L') where L' is any (n-1)×(n-1) minor of L.
4. Connect to spanning trees via the Matrix-Tree theorem (may need to develop this).

**Domain Bridges**: Algebra <-> Geometry, Combinatorics <-> Number Theory

**Lineage**: Builds on the Laplacian and linEquiv framework from this cycle.

**Ambition**: extension

---

### Direction 4: Chip-Firing as Persistent Homology

**Conjecture**: The filtration of divisor classes by rank defines a persistence module whose Betti numbers recover the Brill-Noether numbers. Specifically, for a chain of g loops, the rank-filtered persistence diagram has points at coordinates (d-r, d+r) for each (d,r) with ρ(g,d,r) = 0.

**Test**: Compute the persistence diagram for g = 3 (genus 3, chain of loops). The critical pairs should be at (d-r, d+r) = (2,4), (1,3), corresponding to ρ(3,3,1) = 1 → 0 and ρ(3,4,2) = 0 transitions.

**Impact**: This would create a new bridge between tropical geometry and topological data analysis. The Brill-Noether number would gain an interpretation as a "persistence length," potentially applicable to network analysis where chip-firing models resource distribution.

**Catalog References**: `Bridges/SimplicialMorse.lean` (`tropical_persistent_rank_eq_classical`), `Geometry/DiscreteMorseInequalities.lean` (`strong_algebraic_inequality`), `Geometry/TropicalBrillNoether.lean`

**Proof Strategy**:
1. Define the rank filtration: W_r(G, d) = {divisor classes of degree d and rank ≥ r}.
2. Show W_r ⊂ W_{r-1} and these inclusions form a persistence module.
3. Compute the persistence diagram using the bn_rank_step formula.
4. Relate to the Morse-theoretic perspective via the catalog's `strong_algebraic_inequality`.

**Domain Bridges**: Geometry <-> Topology, Tropical <-> Data Science

**Lineage**: Builds on `tropical_persistent_rank_eq_classical` from the catalog and the BN framework from this cycle.

**Ambition**: extension

---

### Direction 5: Effective Brill-Noether via Lattice Reduction

**Conjecture**: The maximal rank of a divisor on the chain of g loops can be computed in polynomial time using lattice reduction (LLL algorithm) on the Laplacian lattice. Specifically, the shortest vector in the Laplacian lattice of the chain of g loops, measured in the L¹ norm, has length related to the gonality (minimum degree of a rank-1 divisor).

**Test**: For g = 1, ..., 8, compute the shortest L¹ vector in the Laplacian lattice of the chain of g loops. Compare with the gonality ⌈(g+2)/2⌉ predicted by the Brill-Noether theorem.

**Impact**: If confirmed, this would provide the first efficient algorithm for computing tropical Brill-Noether invariants on specific graphs, with applications to chip-firing-based network analysis and coding theory (where graph gonality controls code parameters).

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean` (lattice methods), `Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean`, `Geometry/TropicalBrillNoether.lean`

**Proof Strategy**:
1. Express the chip-firing equivalence class of a divisor as a coset of the Laplacian lattice.
2. Formalize the connection between shortest lattice vectors and minimum-degree effective representatives.
3. Prove that LLL finds a vector within 2^(g/2) of optimal.
4. For the chain of loops, exploit the tridiagonal structure of the Laplacian for exact computation.

**Domain Bridges**: Cryptography <-> Geometry, Algebra <-> Computation

**Lineage**: Connects the lattice reduction infrastructure from the catalog's cryptography work with the tropical geometry of this cycle.

**Ambition**: extension
