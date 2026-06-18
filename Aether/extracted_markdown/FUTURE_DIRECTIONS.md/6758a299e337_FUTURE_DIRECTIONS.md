# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the algebraic foundations of number theory on the Poincaré disk: the Key Identity, Möbius disk preservation, the involution property, the Cayley bridge, and the complement formula — all formally verified. The most significant discovery was computational: the lattice point growth conjecture (N(R) ~ C·R²) was refuted by experiment, with the actual growth closer to N(R) ~ C·R in the normSq parameterization. This is consistent with the classical Selberg–Huber theory and reveals that the relationship between Euclidean and hyperbolic parameterizations is more subtle than initially assumed.

The most promising cross-domain connection from this cycle is the **Cayley bridge** between the upper half-plane (home of modular forms and automorphic representations) and the Poincaré disk (home of our hyperbolic integers). This bridge, combined with the algebraic machinery of Möbius transforms, positions hyperbolic number theory at the intersection of analytic number theory, spectral geometry, and geometric group theory. The `mobius_key_identity` theorem from `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` is the foundational result: every subsequent theorem flows from it.

The highest breakthrough potential lies in Direction 1 (Selberg Zeta ↔ Hyperbolic Primes), which could formalize the deep spectral theory underlying lattice point counting and connect it to the Riemann Hypothesis analogue for Fuchsian groups.

---

### Direction 1: Selberg Zeta Function and Hyperbolic Prime Distribution

**Conjecture**: For a cofinite Fuchsian group Γ acting on the Poincaré disk, the Selberg zeta function Z_Γ(s) = ∏_{γ primitive} ∏_{k=0}^∞ (1 - e^{-(s+k)ℓ(γ)}), where the product is over primitive closed geodesics of length ℓ(γ), can be expressed in terms of the hyperbolic primes defined in our framework. Specifically, the hyperbolic primes correspond to the shortest closed geodesics, and the Selberg trace formula gives the asymptotic count of hyperbolic primes with ℓ(γ) ≤ T as π_H(T) ~ e^T / T.

**Test**: For PSL(2,ℤ), compute the lengths of the first 50 closed geodesics on the modular surface, identify them with hyperbolic prime pairs under the Cayley transform, and verify the asymptotic formula π_H(T) ~ e^T / T computationally.

**Impact**: If true, this provides a direct dictionary between our algebraic framework (Möbius transforms, hyperbolic primes) and the spectral theory of automorphic forms. It would also formalize the analogue of the Riemann Hypothesis for hyperbolic surfaces, which is known to be true (Selberg 1956) — potentially providing proof strategies transferable to the classical RH.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (mobius_key_identity, cayley_maps_UHP_to_disk), `FINAL/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Speculative/IdempotentCollapse/TheoreticalExtensions.lean` (RH_via_fixed_points)

**Proof Strategy**: 
1. Formalize the definition of primitive closed geodesics on Γ\ℍ.
2. Define the Selberg zeta function as a formal product.
3. Prove the functional equation Z_Γ(s)/Z_Γ(1-s) using the trace formula.
4. Connect primitive geodesics to conjugacy classes in Γ, which correspond to hyperbolic prime orbits.
5. Derive the asymptotic count via the logarithmic derivative of Z_Γ.

**Domain Bridges**: NumberTheory <-> SpectralGeometry, Algebra <-> Physics

**Lineage**: Builds on the Cayley bridge theorem (cayley_maps_UHP_to_disk) and the Möbius group structure (mobius_involution) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Unique Factorization in Hyperbolic Lattices

**Conjecture**: A hyperbolic lattice L arising from a Fuchsian group Γ has unique factorization into hyperbolic primes if and only if the associated quaternion algebra has class number 1. For Γ = PSL(2,ℤ), the class number is 1, and unique factorization holds. For certain arithmetic Fuchsian groups derived from quaternion algebras over ℚ(√d) with class number > 1, unique factorization fails.

**Test**: 
1. Implement the factorization algorithm for PSL(2,ℤ): given a lattice point, express it as a product of generators and verify uniqueness.
2. Find a counterexample to unique factorization for an arithmetic group with class number 2 (e.g., the group associated to the quaternion algebra ramified at 2 and 3 over ℚ(√5)).

**Impact**: This would establish hyperbolic number theory as a genuine number theory with a class number theory analogous to algebraic number theory. The failure of unique factorization would motivate the definition of "hyperbolic ideals" — the geometric analogue of ideal classes.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (HyperbolicLattice, HyperbolicPrime), `Algebra/Berggren.lean` (Berggren tree structure for Pythagorean triples)

**Proof Strategy**:
1. Define factorization in HyperbolicLattice as decomposition into HyperbolicPrime elements.
2. For PSL(2,ℤ), use the continued fraction algorithm to show every element has a unique expression in generators.
3. For the counterexample, construct two distinct factorizations of a specific lattice point.

**Domain Bridges**: NumberTheory <-> Algebra, Geometry <-> AlgebraicNumberTheory

**Lineage**: Directly extends the HyperbolicLattice and HyperbolicPrime definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical-Hyperbolic Duality

**Conjecture**: There exists a natural "tropicalization" map from the Poincaré disk to the tropical projective line that sends Möbius transforms to tropical linear maps and pseudo-hyperbolic distance to the tropical metric. Specifically, the map T: 𝔻 → ℝ ∪ {∞} defined by T(z) = -log(1 - |z|²) sends the pseudo-hyperbolic metric to the tropical metric up to a bounded error.

**Test**: Compute T(z) for 100 points in the PSL(2,ℤ) orbit, compute pairwise pseudo-hyperbolic distances and pairwise tropical distances, and verify that the ratio converges to 1 for distant points.

**Impact**: This would establish a bridge between hyperbolic number theory and tropical geometry, opening connections to optimization (tropical linear programming), algebraic geometry (tropical varieties), and phylogenetics (tree metrics as tropical objects). The Catalog has extensive tropical geometry infrastructure that could be leveraged.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (pseudoHypDist, mobius_normSq_complement), Tropical geometry modules in the Catalog

**Proof Strategy**:
1. Define the tropicalization map T(z) = -log(1 - normSq(z)).
2. Show T maps the group operation (Möbius composition) to tropical addition (max) asymptotically.
3. Prove the metric comparison: |d_hyp(z,w) - |T(z) - T(w)|| ≤ C for a universal constant C.

**Domain Bridges**: Geometry <-> Tropical, NumberTheory <-> Optimization

**Lineage**: Extends the pseudo-hyperbolic distance framework from this cycle into the tropical domain.

**Ambition**: extension

---

### Direction 4: Hyperbolic Machine Learning Embeddings via Möbius Algebra

**Conjecture**: The Möbius Key Identity (Theorem 2.1) provides an optimal step-size formula for Riemannian gradient descent on the Poincaré disk: the learning rate η(z) = (1 - |z|²)² / 4 yields convergence with rate independent of the curvature, and the complement formula (Theorem 3.2) guarantees that gradient steps remain in the disk without projection.

**Test**: Implement Riemannian SGD using the Key Identity for step-size adaptation. Compare convergence on a hierarchical embedding task (WordNet taxonomy, 100K nodes) against the standard Poincaré embedding approach (Nickel & Kiela, 2017). Measure embedding quality by mean rank and mean average precision.

**Impact**: This would provide a mathematically rigorous foundation for hyperbolic machine learning, grounding practical embedding algorithms in the formally verified algebraic structure of the Poincaré disk. The complement formula ensures numerical stability near the boundary — a major practical challenge in existing implementations.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (mobius_key_identity, mobius_normSq_complement, mobius_maps_disk_to_disk), MachineLearning modules in the Catalog

**Proof Strategy**:
1. Define the Riemannian gradient on the Poincaré disk: ∇_hyp f(z) = (1-|z|²)²/4 · ∇_euc f(z).
2. Prove the retraction property: z - η·∇_hyp f(z) ∈ 𝔻 using mobius_maps_disk_to_disk.
3. Prove convergence using the complement formula to bound the contraction rate.

**Domain Bridges**: Geometry <-> MachineLearning, Algebra <-> Optimization

**Lineage**: Directly applies the Key Identity and complement formula from this cycle to ML.

**Ambition**: extension

---

### Direction 5: Spectral Gap and Lattice Point Error Terms

**Conjecture**: The error term in the hyperbolic lattice point count N(ρ) = C·e^ρ + O(e^{(1-δ)ρ}) is controlled by the spectral gap δ = λ₁ - 1/4 of the Laplacian on Γ\ℍ, where λ₁ is the first eigenvalue. For PSL(2,ℤ), the Selberg eigenvalue conjecture (λ₁ ≥ 1/4) is known, giving an error term O(e^{ρ/2}). This can be formally verified for specific groups.

**Test**: For PSL(2,ℤ), compute N(ρ) for ρ = 1, 2, ..., 20 and verify that |N(ρ) - C·e^ρ| = O(e^{ρ/2}) where C = 3/π (the reciprocal of the covolume).

**Impact**: Formally verifying the spectral gap → error term connection would be a significant achievement in formalized spectral geometry. It connects directly to the Ramanujan conjecture and the theory of automorphic forms.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (cayley_maps_UHP_to_disk, HyperbolicLattice), `Speculative/EnergyLandscape.lean` (prime_two_zeros)

**Proof Strategy**:
1. Formalize the heat kernel on Γ\ℍ.
2. Express N(ρ) as a sum over eigenvalues using the pre-trace formula.
3. Bound the tail using the spectral gap.
4. For PSL(2,ℤ), use the explicit value λ₁ = 91.14... (Hejhal).

**Domain Bridges**: NumberTheory <-> SpectralGeometry, Geometry <-> Physics

**Lineage**: Extends the lattice point counting framework and computational experiments from this cycle.

**Ambition**: extension
