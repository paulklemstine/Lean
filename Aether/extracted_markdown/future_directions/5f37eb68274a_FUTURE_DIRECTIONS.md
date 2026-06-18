# Future Directions

## Synthesis

This research cycle established a rigorous formal foundation for Baker-Norine theory on finite graphs, proving 25 theorems about divisors, chip-firing, the canonical divisor, and firing scripts. The key discovery is that the *firing script algebra*—the abelian group action of ℤ^V on divisors—provides a clean computational framework that unifies chip-firing commutativity, degree preservation, and linear equivalence into a single algebraic structure. The *rank stability spectrum* σ(D, k) was introduced as a novel invariant that refines the classical divisor rank, measuring the robustness of chip configurations under perturbation.

The most promising cross-domain connection is between the chip-firing framework developed here and the *tropical geometry* thread in the Catalog. The firing script algebra maps directly to the theory of rational functions on tropical curves, and the rank stability spectrum could provide a new tool for studying the tropical Brill-Noether problem. The canonical divisor characterization for complete graphs connects to the `capacity_tight_for_complete_graph` theorem in the Catalog's tropical information theory file, suggesting a deep link between chip-firing rank and information-theoretic channel capacity on graphs.

The direction with highest breakthrough potential is Direction 1 (Tropical Brill-Noether via Rank Stability), because the rank stability spectrum provides a novel tool for attacking the Brill-Noether problem—one of the major open problems in tropical/combinatorial algebraic geometry—from a quantitative perspective that has not been explored before.

---

### Direction 1: Tropical Brill-Noether Theory via the Rank Stability Spectrum

**Conjecture**: For a generic graph G of genus g, the Brill-Noether number ρ(g, r, d) = g - (r+1)(g - d + r) governs the existence of divisors of degree d and rank r. More precisely: if ρ(g, r, d) ≥ 0, then there exists a divisor D on G with deg(D) = d and r(D) ≥ r such that the rank stability σ(D, r) ≥ ρ(g, r, d) + 1.

**Test**: Compute the rank stability spectrum for all divisor classes of degree d on the complete graph K_n (which has genus (n-1)(n-2)/2) for n = 4, 5, 6 and compare σ(D, r) against ρ. If the conjecture fails for K_5, it would show that complete graphs are "too special" for generic Brill-Noether behavior. If it holds, compute for random graphs of the same genus.

**Impact**: If true, this would provide a quantitative refinement of the Brill-Noether theorem for graphs, showing that generic divisors are not merely existent but *stable*. This would be a new result connecting the rank stability invariant to classical algebraic geometry. If false, the specific failure mode would reveal which graph structures break genericity.

**Catalog References**: `Applications/ChipFiringCanonical.lean` (this cycle's formalization), `Bridges/TropicalInformationTheory.lean` (`capacity_tight_for_complete_graph`)

**Proof Strategy**: 
1. Formalize the Brill-Noether number ρ(g, r, d) as a definition.
2. Prove σ(D, r) is monotone in r (Conjecture 5.1 from this cycle).
3. For complete graphs, use the symmetry of the canonical divisor (K(v) = n-3 for all v) to compute rank stability analytically.
4. Prove the bound σ(D, r) ≥ ρ + 1 by constructing explicit effective divisors.

**Domain Bridges**: Algebra (chip-firing) ↔ Tropical (tropical curves) ↔ Geometry (algebraic curves)

**Lineage**: Builds on the rank stability spectrum introduced in this cycle, and the genus/canonical divisor characterization for complete graphs (Theorems 3.16-3.19 of this cycle).

**Ambition**: grand_challenge

---

### Direction 2: The Jacobian Group and Kirchhoff's Theorem via Chip-Firing

**Conjecture**: The quotient group Jac(G) = Div⁰(G) / Prin(G) (degree-zero divisors modulo principal divisors) is a finite abelian group of order equal to the number of spanning trees of G. For the complete graph K_n, |Jac(K_n)| = n^(n-2) (Cayley's formula).

**Test**: Formalize the Jacobian group as a quotient type in Lean 4, using the firing script algebra from this cycle. Prove |Jac(K_n)| = n^(n-2) for small n (n = 3, 4, 5) by explicit computation, then prove the general formula using the Matrix-Tree theorem.

**Impact**: This would formally connect three major areas: (1) chip-firing dynamics, (2) the algebraic structure of the Picard group, and (3) enumerative combinatorics of spanning trees. The formalization would be the first to rigorously connect all three in a single verified framework.

**Catalog References**: `Applications/ChipFiringCanonical.lean` (firing script algebra, linear equivalence), `Algebra/GraphRiemannRoch/Defs.lean` (`complete_graph_edge_count`)

**Proof Strategy**:
1. Define Pic⁰(G) = Div⁰(G) / linEquiv as a quotient type.
2. Prove it inherits a group structure from Div⁰(G).
3. Define the Laplacian matrix L_G and prove det(L_G^{(q)}) = number of spanning trees (Matrix-Tree theorem).
4. Show |Pic⁰(G)| = det(L_G^{(q)}) using Smith normal form of the Laplacian.

**Domain Bridges**: Algebra (group theory, Smith normal form) ↔ Computation (matrix algorithms) ↔ Combinatorics (spanning tree enumeration)

**Lineage**: Directly extends the firing script algebra and linear equivalence theory from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Chip-Firing Zeta Functions and Spectral Connections

**Conjecture**: Define the *chip-firing zeta function* Z_G(s) = Σ_{[D] ∈ Pic(G)} q^{-s·deg(D)} · t^{r(D)+1} (summing over linear equivalence classes). For the complete graph K_n, this zeta function has a functional equation relating Z_G(s) to Z_G(1-s), analogous to the functional equation of the Riemann zeta function. Specifically: Z_{K_n}(s) = q^{(2g-2)(s - 1/2)} · Z_{K_n}(1-s).

**Test**: Compute Z_{K_n}(s) explicitly for n = 3, 4, 5 by enumerating all linear equivalence classes and their ranks. Check whether the functional equation holds. If it does, investigate whether the "zeros" of Z_G have special properties (an analogue of the Riemann Hypothesis for graphs).

**Impact**: If the functional equation holds, it would provide a new perspective on the Ihara zeta function of graphs and its connection to the Riemann Hypothesis for graphs (proved by Ihara for regular graphs). The chip-firing perspective would be novel and could lead to new proofs or generalizations.

**Catalog References**: `Applications/ChipFiringCanonical.lean` (divisor rank, canonical divisor), `Algebra/FactoringViaBerggren.lean` (`divisor_gap_theorem`)

**Proof Strategy**:
1. Define the chip-firing zeta function formally.
2. Use the Riemann-Roch duality D ↦ K-D to establish the functional equation.
3. The key step: show that the map [D] ↦ [K-D] is a bijection on Pic^d(G) → Pic^{2g-2-d}(G) that sends rank r(D) to r(K-D).
4. The functional equation then follows from the Baker-Norine Riemann-Roch identity.

**Domain Bridges**: Algebra (zeta functions) ↔ Number Theory (Riemann Hypothesis) ↔ Physics (spectral graph theory)

**Lineage**: Builds on the canonical involution and Gauss-Bonnet theorem from this cycle.

**Ambition**: extension

---

### Direction 4: Gonality Bounds and Network Security

**Conjecture**: The *gonality* gon(G) = min{deg(D) : r(D) ≥ 1} of a graph G satisfies gon(G) ≥ edge-connectivity λ(G). For the complete graph K_n, gon(K_n) = ⌈n/2⌉. More generally, for d-regular graphs, gon(G) ≥ d/2 with equality if and only if G has a "balanced" bipartition.

**Test**: Compute gonality for small complete graphs (n = 3,...,8) using the rank computation algorithm from this cycle. Verify gon(K_n) = ⌈n/2⌉. Then test the edge-connectivity bound for random regular graphs of degree 3 and 4 on up to 10 vertices.

**Impact**: Gonality has applications to network security (it measures the minimum "cost" of controlling a network) and coding theory (it determines the parameters of algebraic-geometric codes). A tight bound relating gonality to edge-connectivity would provide a combinatorial characterization of a fundamentally algebraic-geometric invariant.

**Catalog References**: `Applications/ChipFiringCanonical.lean` (divisor rank, complete graph characterization), `Bridges/TropicalInformationTheory.lean` (`capacity_tight_for_complete_graph`)

**Proof Strategy**:
1. Formalize gonality as a definition in Lean.
2. Prove gon(G) ≥ 1 for connected graphs (any divisor of degree 0 has rank ≤ 0).
3. For K_n, construct an explicit divisor of degree ⌈n/2⌉ with rank 1, and prove no divisor of lower degree has rank 1.
4. For the edge-connectivity bound, use max-flow min-cut and relate to chip-firing.

**Domain Bridges**: Algebra (chip-firing) ↔ Cryptography (network security) ↔ Computation (algorithms)

**Lineage**: Extends the rank-degree bound (Theorem 3.20) and complete graph theory from this cycle.

**Ambition**: extension

---

### Direction 5: Harmonic Morphisms and Functoriality of Chip-Firing

**Conjecture**: A *harmonic morphism* φ: G → H between graphs (a graph homomorphism where the number of preimages of each edge is constant on fibers) induces a pushforward map φ_* : Div(G) → Div(H) and a pullback map φ* : Div(H) → Div(G) satisfying:
1. φ_* preserves linear equivalence
2. φ* preserves linear equivalence  
3. deg(φ*(D)) = deg(φ) · deg(D) (the Hurwitz formula)
4. r(φ*(D)) ≥ r(D) (rank can only increase under pullback)

**Test**: Formalize harmonic morphisms for the quotient map K_6 → K_3 (collapsing pairs of vertices). Compute the pushforward and pullback of specific divisors and verify properties 1-4. Test the Hurwitz formula for genus: 2g(G) - 2 = deg(φ)(2g(H) - 2) + Σ_v (e_v - 1) where e_v is the ramification.

**Impact**: Functoriality would establish chip-firing as a genuine "algebraic geometry on graphs" theory with morphisms, making it possible to transfer results between graphs of different sizes. This is the foundation for a theory of "graph covers" analogous to covers of Riemann surfaces.

**Catalog References**: `Applications/ChipFiringCanonical.lean` (linear equivalence, canonical divisor), `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` (`graphs_same_rank_interleaving`)

**Proof Strategy**:
1. Formalize harmonic morphisms as a structure in Lean.
2. Define pushforward: (φ_* D)(w) = Σ_{v ∈ φ^{-1}(w)} D(v).
3. Define pullback: (φ* D)(v) = (1/m_v) · D(φ(v)) where m_v is the local degree.
4. Prove compatibility with the Laplacian: φ_* ∘ Δ_G = Δ_H ∘ φ_*.
5. Derive the Hurwitz formula from the Gauss-Bonnet theorem on both G and H.

**Domain Bridges**: Algebra (category theory, functors) ↔ Geometry (coverings, Hurwitz) ↔ Tropical (tropical morphisms)

**Lineage**: Builds on the Gauss-Bonnet theorem, linear equivalence theory, and Laplacian properties from this cycle.

**Ambition**: extension
