# Future Research Directions: Tropical Hodge Theory

## Synthesis

This research cycle established a complete formalization of the combinatorial Hodge decomposition on weighted graphs, proving 19 theorems including the orthogonal direct sum decomposition V = ker(L) ⊕ im(L), the tropical balancing-harmonicity equivalence, the unique harmonic representative theorem, and the Dirichlet principle. The most significant discovery is the bridge between tropical algebraic geometry (balancing condition) and spectral graph theory (Laplacian kernel), which unifies three distinct mathematical perspectives into a single framework.

The cycle's results connect directly to the existing Catalog through the `master_tropical_hodge_theorem` (algebraic Hodge-cycle correspondence over ℤ) and `tropical_stability_via_laplacian_bound` (spectral stability). Our analytic approach over ℝ complements the algebraic approach over ℤ, and the balancing-harmonicity bridge provides the conceptual link between them. The highest breakthrough potential lies in Direction 1 (Higher-Dimensional Hodge Decomposition), which would extend our graph-level results to full polyhedral complexes and connect to the Adiprasito-Huh-Katz proof of the Heron-Rota-Welsh conjecture.

The cross-domain connection between tropical geometry and spectral graph theory also opens a path to the tropical Cheeger inequality (Direction 3), which would provide quantitative bounds on how well the Laplacian spectrum captures graph connectivity — with applications to algorithm design and machine learning.

---

### Direction 1: Higher-Dimensional Tropical Hodge Decomposition

**Conjecture**: For a finite weighted simplicial complex K with coboundary operators d_k : C^k → C^{k+1} and codifferentials δ_k = d_k^* (formal adjoint w.r.t. weighted inner products), the k-th cochain space admits an orthogonal decomposition:

C^k(K; ℝ) = ker(Δ_k) ⊕ im(d_{k-1}) ⊕ im(δ_k)

where Δ_k = δ_k d_k + d_{k-1} δ_{k-1} is the k-th combinatorial Laplacian. Moreover, ker(Δ_k) ≅ H^k(K; ℝ), so harmonic k-cochains represent cohomology classes.

**Test**: Construct a triangulated torus (e.g., 7-vertex Möbius-Kantor triangulation) and verify computationally that:
- dim ker(Δ_0) = 1 (connected)
- dim ker(Δ_1) = 2 (two independent 1-cycles)
- dim ker(Δ_2) = 1 (one 2-cycle)
Then formalize the three-way orthogonal decomposition for general k.

**Impact**: This would complete the tropical analog of the full Hodge theorem. It would provide the formal foundation for tropical intersection theory and connect to the Adiprasito-Huh-Katz proof of log-concavity of matroid characteristic polynomials.

**Catalog References**: `Tropical/HodgeShadow/TropicalCycleCorrespondence.lean`, `Tropical/HodgeDecomposition/Defs.lean`, `Shared/NeuralHodge/Defs.lean`

**Proof Strategy**: 
1. Define the graded cochain complex C^*(K; ℝ) with weighted inner products
2. Prove d² = 0 (coboundary condition)
3. Prove δ = d* (adjunction, extending our current adjunction result)
4. Prove ker(Δ_k) = ker(d_k) ∩ ker(δ_{k-1}) using positive semidefiniteness
5. Apply the orthogonal complement decomposition in each degree
6. Identify ker(Δ_k) with H^k using the closed/exact sequence

**Domain Bridges**: Tropical Geometry ↔ Algebraic Topology ↔ Spectral Theory

**Lineage**: Extends `hodge_isCompl` and `balanced_iff_harmonic` from this cycle's Core.lean and Bridge.lean.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Hard Lefschetz via Kähler Packages

**Conjecture**: For the fan Σ associated to a loopless matroid M of rank r, the tropical (p,q)-Hodge numbers h^{p,q}(Σ) satisfy:
1. Hard Lefschetz: The map L^{r-2k} : H^k(Σ) → H^{r-k}(Σ) is an isomorphism for k ≤ r/2
2. Hodge-Riemann: The primitive cohomology H^k_prim(Σ) satisfies a definite form condition

The Betti numbers b_k = dim H^k(Σ) are the coefficients of the reduced characteristic polynomial of M, and Hard Lefschetz implies they form a unimodal sequence.

**Test**: For the uniform matroid U_{2,4}: compute the Betti sequence and verify (1, 3, 1) with b_0 ≤ b_1 ≥ b_2. For the Fano matroid F_7: verify the Betti sequence satisfies unimodality.

**Impact**: This would provide a formal proof of a key ingredient in the Adiprasito-Huh-Katz theorem (Annals 2018), which resolved the Heron-Rota-Welsh conjecture on log-concavity. Formalizing their "Kähler package" would be a landmark achievement.

**Catalog References**: `Tropical/HodgeDecomposition/Defs.lean` (SatisfiesHLP definition), `Tropical/HodgeShadow/TropicalCycleCorrespondence.lean`

**Proof Strategy**:
1. Formalize matroid fans as balanced polyhedral complexes
2. Define the Lefschetz operator L as multiplication by the first Chern class
3. Establish the Kähler package axioms (HL, HR, PD) for matroid fans
4. Use the Kähler package to derive log-concavity

**Domain Bridges**: Combinatorics (matroids) ↔ Algebraic Geometry (Hodge theory) ↔ Convex Geometry (polytope theory)

**Lineage**: Extends `SatisfiesHLP` and `hlp_implies_poincare_bound` from the Catalog's HodgeDecomposition/Defs.lean.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Cheeger Inequality

**Conjecture**: For a connected weighted graph G with Laplacian L, spectral gap λ_1 (smallest nonzero eigenvalue), and Cheeger constant h(G) = min_{S} |∂S| / min(|S|, |V\S|):

λ_1 / 2 ≤ h(G) ≤ √(2λ_1)

where the edge boundary |∂S| uses the tropical weights. Moreover, there exists a tropical analog: the balanced defect δ(f) of a function f (measuring how far f is from balanced) satisfies:

δ(f) ≥ λ_1 · ‖f - f_harm‖

where f_harm is the harmonic projection.

**Test**: Compute λ_1 and h(G) for the cycle graph C_n with unit weights. Verify λ_1 = 2(1 - cos(2π/n)) and h(C_n) = 2/⌊n/2⌋. Check the Cheeger bounds hold.

**Impact**: Would provide quantitative relationships between tropical balancing defects and spectral properties, with applications to community detection algorithms and network analysis. The tropical interpretation would connect graph partitioning to tropical cycle theory.

**Catalog References**: `Pythagorean/TropicalBridge/Stability.lean` (tropical_stability_via_laplacian_bound), `Tropical/TropicalHodge/Core.lean` (spectral_gap_characterization)

**Proof Strategy**:
1. Formalize the Cheeger constant for weighted graphs
2. Prove the easy direction λ_1/2 ≤ h(G) using variational characterization
3. Prove the hard direction h(G) ≤ √(2λ_1) using the sweep technique
4. Derive the balanced defect bound from the Cheeger inequality + balancing-harmonicity equivalence

**Domain Bridges**: Spectral Graph Theory ↔ Tropical Geometry ↔ Algorithms (graph partitioning)

**Lineage**: Extends `spectral_gap_characterization` and `balanced_iff_harmonic` from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Abel-Jacobi Map and Chip-Firing

**Conjecture**: For a connected weighted graph G with genus g = |E| - |V| + 1, the tropical Jacobian Jac(G) = Div^0(G) / Prin(G) is isomorphic to ℝ^g / Λ for a lattice Λ of full rank. The Abel-Jacobi map AJ : Div^0(G) → Jac(G) is surjective, and the fiber over each point is a torsor for the group of principal divisors.

Moreover, the Hodge decomposition provides a canonical section: the harmonic representative map H : Jac(G) → Div^0(G) sends each class to its unique harmonic representative, and satisfies L ∘ H = 0.

**Test**: For the diamond graph (K_4 minus one edge), compute g = 3, enumerate all chip-firing equivalence classes, verify |Jac(G)| = det(reduced Laplacian) = number of spanning trees (Kirchhoff's theorem).

**Impact**: Would connect our Hodge-theoretic framework to the Baker-Norine theory of divisors on graphs, providing a complete formal treatment of the tropical Abel-Jacobi theory. The harmonic section would provide a computational tool for the tropical Torelli problem.

**Catalog References**: `Tropical/ChipFiring/Defs.lean`, `Tropical/ChipFiring/Theorems.lean`, `Tropical/DivisorTheory.lean`

**Proof Strategy**:
1. Formalize divisor groups Div(G) and Div^0(G)
2. Define principal divisors as im(L) restricted to integer lattice
3. Use `hodge_isCompl` to show Jac(G) ≅ ker(L)^⊥ / (im(L) ∩ ℤ^V)
4. Compute the rank of the lattice using `betti_plus_rank`
5. Prove Kirchhoff's matrix-tree theorem: det(reduced L) = number of spanning trees

**Domain Bridges**: Tropical Geometry ↔ Number Theory (lattices) ↔ Combinatorics (spanning trees)

**Lineage**: Extends `unique_harmonic_representative` and `hodge_isCompl` from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Hodge Theory for Neural Network Decision Boundaries

**Conjecture**: The decision boundary of a ReLU neural network defines a tropical hypersurface in ℝ^d, and the combinatorial Hodge theory of this hypersurface's dual complex captures the "topological complexity" of the network's classification. Specifically:

1. The Betti numbers b_k of the dual complex bound the number of distinct "decision regions" of degree k
2. The spectral gap of the Laplacian on the dual complex controls the robustness radius (via Cheeger-type bounds)
3. The harmonic representatives provide "canonical" decision functions minimizing total variation

**Test**: For a 2-layer ReLU network with 4 hidden neurons classifying points in ℝ², compute the tropical hypersurface, its dual complex, and the Laplacian spectrum. Verify that the spectral gap correlates with adversarial robustness.

**Impact**: Would provide a rigorous foundation for understanding neural network decision surfaces through tropical geometry, connecting deep learning theory to Hodge theory. Could lead to new robustness certificates and pruning algorithms.

**Catalog References**: `Shared/NeuralHodge/Defs.lean` (NeuralComplexity), `Tropical/TropicalDeepLearningFoundations.lean`, `Tropical/TropicalNNFrontier.lean`

**Proof Strategy**:
1. Formalize the dual complex of a tropical hypersurface
2. Apply the weighted Hodge decomposition to the dual complex Laplacian
3. Derive spectral gap → robustness bounds using Cheeger methods
4. Connect to existing `hodge_bound_combinatorial` from `Shared/NeuralHodge/Bounds.lean`

**Domain Bridges**: Tropical Geometry ↔ Machine Learning ↔ Spectral Graph Theory

**Lineage**: Extends this cycle's Hodge decomposition + existing NeuralHodge framework.

**Ambition**: extension
