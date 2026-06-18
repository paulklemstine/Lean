# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational infrastructure for number theory on the Poincaré disk: Möbius transformations, pseudo-hyperbolic distance, lattice point counting, and a bridge connecting spectral theory to prime counting via the trace formula. The most promising cross-domain connection discovered is the **spectral-arithmetic bridge**: the trace of the adjacency/Laplacian operator on a hyperbolic lattice encodes both geometric (counting) and analytic (eigenvalue) information, exactly mirroring the Selberg trace formula that connects prime geodesics to spectral data.

The key insight from this cycle is that the orbit depth function serves as a valuation analog, and its prime-index specialization recovers the classical prime counting function. This suggests that more sophisticated orbit metrics — using true hyperbolic word length rather than index — could yield counting functions with genuinely different (and potentially more tractable) analytical properties than π(x). The formal verification of the Möbius inverse property (φ_{-a} ∘ φ_a = id) and disk preservation provides a rock-solid algebraic foundation for iterating these constructions.

The highest breakthrough potential lies in **Direction 1** below: if the hyperbolic zeta function defined via true hyperbolic distances possesses a functional equation, its zeros would carry geometric meaning absent from the classical Riemann zeta function. The spectral interpretation via the Selberg trace formula could make the zero-free region provably determinable — a path toward a "provable RH" in this geometric setting.

---

### Direction 1: Hyperbolic Zeta Function with Functional Equation

**Conjecture**: Define ζ_H(s) = Σ_{γ ∈ Γ, γ ≠ e} (cosh d_H(0, γ·0))^{-s} for a cofinite Fuchsian group Γ ⊂ PSL(2,ℝ). Then ζ_H satisfies a functional equation relating ζ_H(s) to ζ_H(1-s), analogous to the Riemann functional equation ξ(s) = ξ(1-s).

**Test**: For Γ = PSL(2,ℤ) (the modular group), compute ζ_H(s) numerically for s along the critical line Re(s) = 1/2 and verify: (a) the functional equation holds to machine precision, (b) the first 20 zeros lie on Re(s) = 1/2.

**Impact**: If true, this would provide a geometric zeta function where the "Riemann Hypothesis" (all zeros on Re(s)=1/2) might be provable via the Selberg trace formula, since the zeros are explicitly linked to Laplacian eigenvalues. If false, the failure mode reveals which aspects of classical ζ(s) are essentially non-geometric.

**Catalog References**: `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (hypZeta, moebius_maps_disk)

**Proof Strategy**:
1. Formalize the Selberg/Ruelle zeta function for cofinite Fuchsian groups.
2. Establish the connection Z_Γ(s) = det(Δ - s(1-s)) via the determinant formula.
3. Use self-adjointness of Δ on L²(Γ\ℍ²) to show eigenvalues are real.
4. Deduce the functional equation from the symmetry s ↦ 1-s in the spectrum.
5. Key lemma needed: `Selberg_trace_formula_cofinite` (not yet in Mathlib).

**Domain Bridges**: NumberTheory <-> SpectralTheory, HyperbolicGeometry <-> ComplexAnalysis

**Lineage**: Builds on moebius_maps_disk, moebius_inverse, and the spectral bridge (trace_eq_sum_diagonal) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Hyperbolic Multiplication and Unique Factorization

**Conjecture**: Define a multiplication ⊗ on hyperbolic lattice points by: for γ₁, γ₂ ∈ Γ, define (γ₁ · 0) ⊗ (γ₂ · 0) = (γ₁ γ₂) · 0. Under this operation, the hyperbolic lattice Z_H = Γ · 0 forms a monoid. Conjecture: for Γ = PSL(2,ℤ), unique factorization holds in Z_H with respect to hyperbolic primes (points at prime word length from the origin).

**Test**: Enumerate all lattice points up to word length 20 in PSL(2,ℤ), compute all products, and check whether every point has a unique factorization into prime-depth factors (up to order and units).

**Impact**: If unique factorization holds, it provides a new UFD in a geometric setting, opening the door to hyperbolic algebraic number theory. If it fails, the failure points (non-unique factorizations) reveal the "class number" of the hyperbolic lattice, connecting to algebraic K-theory.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (isHyperbolicPrime, orbitDepth), `Catalog/Algebra/Basic.lean`

**Proof Strategy**:
1. Formalize the monoid structure on Γ · 0 (well-definedness requires showing the map Γ → D is injective on orbits for a free group).
2. Define irreducible elements as lattice points whose word in generators has prime length.
3. Use the free group structure of PSL(2,ℤ) (via the presentation ⟨S, T | S² = (ST)³ = 1⟩) to analyze factorization.
4. Key lemma: word length is additive under composition in the free monoid on generators.

**Domain Bridges**: Algebra <-> HyperbolicGeometry, GroupTheory <-> NumberTheory

**Lineage**: Builds on moebius_comp_maps_disk, hyp_prime_existence from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Spectral Gap Lower Bounds for Lattice Counting Error Terms

**Conjecture**: For the modular group Γ = PSL(2,ℤ), the lattice point counting error E(R) = N(R) - C·e^R satisfies |E(R)| ≤ C' · e^{(2/3)R}, where the exponent 2/3 comes from Selberg's lower bound λ₁ ≥ 3/16 on the first nonzero eigenvalue of the Laplacian.

**Test**: Compute N(R) for R = 1, 2, ..., 20 using exact enumeration of PSL(2,ℤ)-orbit points, compare to the main term C·e^R, and verify the error is bounded by e^{(2/3)R}.

**Impact**: A formalized spectral gap bound would be the first machine-verified ingredient of the Selberg trace formula, opening the path to formalizing the entire prime geodesic theorem.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (countPointsInBall, lattice_count_le_size, trace_eq_sum_diagonal)

**Proof Strategy**:
1. Formalize the spectral decomposition of the counting kernel on Γ\ℍ².
2. Bound the contribution of the continuous spectrum using Eisenstein series.
3. Use Selberg's 3/16 bound (or Ramanujan conjecture improvements) for the discrete spectrum.
4. Key infrastructure needed: formalization of Eisenstein series and their analytic continuation in Mathlib.

**Domain Bridges**: SpectralTheory <-> NumberTheory, AnalyticNumberTheory <-> HyperbolicGeometry

**Lineage**: Builds on trace_eq_sum_diagonal and the counting framework from this cycle.

**Ambition**: extension

---

### Direction 4: Hyperbolic Embeddings for Machine Learning

**Conjecture**: For hierarchical datasets (taxonomies, organizational charts, phylogenetic trees), hyperbolic lattice embeddings achieve lower distortion than Euclidean embeddings of the same dimension, and the distortion gap grows logarithmically with the tree's branching factor.

**Test**: Embed the WordNet noun hierarchy (80,000 nodes, average branching factor ~5) into the Poincaré disk using Möbius-based gradient descent. Compare mean average precision (MAP) against Euclidean embeddings in ℝ² and ℝ^{10}. Predict: Poincaré disk in ℝ² achieves MAP > 0.85, beating Euclidean ℝ^{10}.

**Impact**: This bridges pure mathematics (Möbius transformation algebra) to applied ML, demonstrating that the formal verification of disk-preservation (moebius_maps_disk) guarantees numerical stability of hyperbolic embeddings.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (moebius_maps_disk, pseudoHypDist_lt_one), `Catalog/MachineLearning/`

**Proof Strategy**:
1. Formalize the Riemannian gradient on the Poincaré disk: ∇_H f = (1-|z|²)²/4 · ∇_E f.
2. Prove convergence of Möbius-based SGD using the disk-preservation guarantee.
3. Bound embedding distortion using the pseudo-hyperbolic triangle inequality.
4. Key lemma: moebius_maps_disk ensures iterates stay in the feasible region.

**Domain Bridges**: HyperbolicGeometry <-> MachineLearning, Algebra <-> MachineLearning

**Lineage**: Builds on moebius_maps_disk, pseudoHypDist_lt_one, and the lattice generation framework from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Hyperbolic Duality

**Conjecture**: There exists a dequantization limit in which the algebra of Möbius transformations on the Poincaré disk degenerates to tropical (min-plus) algebra on the upper half-plane, analogous to how quantum mechanics degenerates to classical mechanics in the ℏ → 0 limit. Specifically, as the curvature κ → 0, the hyperbolic distance arctanh(ρ(z,w)) → |z-w| (Euclidean), and as κ → ∞, it degenerates to a tropical metric max(|Re(z-w)|, |Im(z-w)|).

**Test**: Compute the hyperbolic distance function for varying curvature parameters and verify the tropical limit numerically. Plot the distance function for κ = 0.01, 0.1, 1, 10, 100 and check convergence to the L^∞ norm.

**Impact**: If the duality exists, it would bridge hyperbolic number theory to tropical geometry, connecting the Catalog's extensive Tropical module to the new hyperbolic framework. This could yield new proof strategies for tropical analogs of the prime number theorem.

**Catalog References**: `Catalog/Tropical/`, `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (pseudoHypDist, moebiusMap)

**Proof Strategy**:
1. Parametrize the Poincaré disk by curvature κ: D_κ = {z : |z| < 1/√κ}.
2. Show that as κ → 0, the distance function converges pointwise to Euclidean distance.
3. Introduce a "tropical deformation" parameter t and define d_t(z,w) = t · log(exp(d_H(z,w)/t)).
4. Verify that lim_{t→0} d_t = tropical distance.

**Domain Bridges**: HyperbolicGeometry <-> Tropical, NumberTheory <-> Tropical

**Lineage**: Builds on pseudoHypDist, moebius_maps_disk from this cycle and connects to the existing Tropical module in the Catalog.

**Ambition**: extension
