# Future Directions: Hyperbolic Number Theory

## Synthesis

This cycle established the formal foundations of number theory on the Poincaré disk, building a bridge between three domains: hyperbolic geometry (Möbius transformations, Gauss-Bonnet, area growth), algebraic number theory (divisor functions, convolution, spectral zeta functions), and spectral theory (eigenvalue bounds, spectral gap monotonicity). The most promising cross-domain connection is the **critical-line-to-disk map**: the Möbius transform s ↦ (s - 1/2)/(s + 1/2) sends the critical line Re(s) = 1/2 strictly into the open unit disk, creating a geometric framework where zeros of L-functions become lattice points in hyperbolic space. This connection is ripe for exploitation — it suggests that the distribution of zeta zeros could be studied using the rich machinery of hyperbolic geometry and Fuchsian group theory.

The hyperbolic convolution and divisor function framework provides a parallel algebraic structure to classical multiplicative number theory. Combined with the spectral gap monotonicity theorem (which gives explicit control on error terms in counting), this opens a path toward quantitative results on "prime" distribution in curved space. The key insight from this cycle is that **exponential growth in hyperbolic space creates a qualitatively different arithmetic** — more primes per unit of "complexity," faster divergence of zeta-like sums, and stronger analytic control via spectral methods.

The highest breakthrough potential lies in Direction 1 (Selberg zeta function formalization), which would create the first machine-verified treatment of the spectral theory of hyperbolic surfaces and connect directly to the Langlands program. Direction 3 (tropical-hyperbolic bridge) offers the most novel cross-domain connection, potentially linking two previously unrelated areas of the Catalog.

---

### Direction 1: Selberg Zeta Function Formalization and Functional Equation

**Conjecture**: The Selberg zeta function Z_Γ(s) for a cocompact Fuchsian group Γ satisfies a functional equation relating Z_Γ(s) to Z_Γ(1-s), analogous to the functional equation of the Riemann zeta function. Specifically, for a surface of genus g, Z_Γ(s) · Z_Γ(1-s) can be expressed in terms of the Barnes double gamma function and the Euler characteristic χ = 2 - 2g.

**Test**: For the (2,3,7) triangle group (the smallest hyperbolic triangle group by covolume), compute the first 50 zeros of Z_Γ(s) numerically and verify they lie on Re(s) = 1/2. Compare with the eigenvalue spectrum obtained from finite-element methods on the corresponding surface.

**Impact**: A formalized Selberg zeta function would be the first machine-verified instance of a zeta function with a proven analogue of the Riemann Hypothesis (for compact surfaces). It would demonstrate that the RH-type statement is provable in the hyperbolic setting and provide a template for attacking the classical case.

**Catalog References**: `Algebra/HyperbolicNumberTheory.lean` (selbergZetaTrunc, isValidSpectrum), `Algebra/HyperbolicArithmetic.lean` (spectralGap, spectralGap_monotone)

**Proof Strategy**: (1) Formalize the Selberg trace formula for compact surfaces using the heat kernel approach. (2) Express Z_Γ(s) as a regularized determinant of the Laplacian. (3) Derive the functional equation from the symmetry of the spectrum. Key lemmas needed: trace formula for compact hyperbolic surfaces, Weyl's law for eigenvalue asymptotics, convergence of the infinite product defining Z_Γ.

**Domain Bridges**: NumberTheory <-> SpectralTheory, Algebra <-> Geometry

**Lineage**: Builds on spectralGap_monotone, spectralGap_at_quarter, and the selbergZetaTrunc definition from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Hyperbolic Sieve Methods and Prime Geodesic Gaps

**Conjecture**: The gaps between consecutive primitive closed geodesics on a hyperbolic surface of genus g satisfy: the largest gap below length L is O(L^{1-δ}) where δ = 1/2 + √(λ₁ - 1/4) is the spectral gap. In particular, for surfaces with λ₁ ≥ 1/4, consecutive gaps are O(L^{1/2}).

**Test**: For the modular surface PSL(2,ℤ)\ℍ, enumerate primitive geodesic lengths up to L = 20 (there are approximately e^20/20 ≈ 24,000 of them) and measure the maximum gap. The predicted bound is O(L^{0.5}) ≈ 4.5.

**Impact**: This would be the hyperbolic analogue of the Cramér conjecture on prime gaps. Unlike the classical case, the spectral gap gives explicit, computable control on the error term, potentially making the hyperbolic version provable.

**Catalog References**: `Algebra/HyperbolicArithmetic.lean` (primeGeodesicCount, primeGeodesicCount_monotone), `Algebra/HyperbolicNumberTheory.lean` (hypPrimeAsymptotic_eventually_increasing)

**Proof Strategy**: (1) Formalize the explicit formula relating π_H(x) to the zeros of Z_Γ(s). (2) Use the spectral gap bound to control the contribution of non-trivial zeros. (3) Apply a combinatorial sieve argument adapted to the exponential growth setting. Key ingredient: the explicit formula π_H(x) = li(x) - Σ_ρ li(x^ρ) + lower order terms.

**Domain Bridges**: NumberTheory <-> Geometry, Computation <-> Algebra

**Lineage**: Builds on primeGeodesicCount_monotone, orbit_growth_exponential, and hypPrimeAsymptotic_eventually_increasing.

**Ambition**: grand_challenge

---

### Direction 3: Tropical-Hyperbolic Bridge via Valuation

**Conjecture**: The map φ : D → ℝ≥0 defined by φ(z) = -log(1 - |z|²) is a "tropical valuation" that converts hyperbolic addition (Möbius composition) into tropical addition (max operation) in the limit. Specifically, for z, w far from the origin (near the boundary), φ(z ⊕ w) ≈ max(φ(z), φ(w)) + O(1) where ⊕ is the Möbius composition.

**Test**: For 100 random pairs (z, w) with |z|, |w| ∈ (0.9, 0.99), compute φ(z ⊕ w) - max(φ(z), φ(w)) and verify it is bounded by a constant (conjectured to be ≤ log 4).

**Impact**: This would create a concrete bridge between tropical geometry (which appears extensively in the Catalog under Tropical/) and hyperbolic geometry. The bridge could transfer results about tropical curves and Newton polygons into statements about geodesic distributions on hyperbolic surfaces.

**Catalog References**: `Tropical/Foundations.lean`, `Algebra/HyperbolicArithmetic.lean` (mobius_maps_disk_to_disk, hypDiskArea_growth)

**Proof Strategy**: (1) Define the tropical valuation φ(z) = -log(1 - |z|²). (2) Show that φ is approximately additive under Möbius composition for points near the boundary. (3) Prove the error bound φ(z ⊕ w) - max(φ(z), φ(w)) ≤ log 4 using the explicit formula for Möbius composition. (4) Show this induces a morphism from the hyperbolic group to the tropical semiring.

**Domain Bridges**: Tropical <-> Geometry, Algebra <-> Computation

**Lineage**: Builds on mobius_maps_disk_to_disk and the tropical framework in the Catalog.

**Ambition**: extension

---

### Direction 4: Hyperbolic Convolution Algebra and Hecke Operators

**Conjecture**: The hyperbolic convolution algebra (with the operation f ⊛ g defined in this cycle) is isomorphic to the Hecke algebra of the underlying Fuchsian group when restricted to functions supported on double cosets. This isomorphism sends the hyperbolic sigma function σ_H(k, ·) to classical Hecke eigenvalues.

**Test**: For G = PSL(2,ℤ/5ℤ) (a finite quotient of the modular group) with S = G and k = 1, compute σ_H(1, g) for all g ∈ G and verify that the resulting function is a Hecke eigenform.

**Impact**: This would connect our formal hyperbolic convolution to the theory of automorphic forms, enabling the transfer of deep results about modular forms (Ramanujan conjecture, Sato-Tate distribution) into the hyperbolic arithmetic framework.

**Catalog References**: `Algebra/HyperbolicArithmetic.lean` (hypConvolution, hypSigmaFunction, hypSigmaFunction_zero), `Algebra/SpectralArithmetic.lean`

**Proof Strategy**: (1) Define the Hecke algebra formally as the convolution algebra of bi-K-invariant functions on G. (2) Show that hypConvolution restricted to double-coset-supported functions satisfies the Hecke multiplication rule. (3) Verify the isomorphism on the level of eigenvalues for small finite groups. Key lemma: the hyperbolic divisor count hypDivisorCount recovers the classical divisor function on ℤ when G = ℤ/nℤ.

**Domain Bridges**: Algebra <-> NumberTheory, Geometry <-> Cryptography

**Lineage**: Builds on hypConvolution_add_left, hypConvolution_smul, hypSigmaFunction_zero, and hypDivisorCount_one_ge.

**Ambition**: extension

---

### Direction 5: Cayley Graph Diameter and Babai's Conjecture

**Conjecture**: For finite simple groups G with "natural" generating sets S (conjugacy classes of small elements), the Cayley graph diameter satisfies diam(G, S) ≤ (log |G|)^3. This is a weak form of Babai's conjecture (which predicts (log |G|)^{O(1)}).

**Test**: Compute Cayley graph diameters for A_n (n = 5,...,12) with S = {(1 2 3), (1 2 3)⁻¹, (1 2)(3 4), ...} and plot diam(A_n, S) vs log |A_n|. The conjecture predicts a polynomial relationship.

**Impact**: A proof (even for specific families like alternating groups) would resolve a major open problem in group theory and have applications to mixing times of random walks, expander graphs, and cryptographic key exchange.

**Catalog References**: `Algebra/HyperbolicArithmetic.lean` (orbit_growth_exponential, hypDivisorCount_le_sq, word_metric_triangle)

**Proof Strategy**: (1) Establish the product replacement lemma: for groups with many generators, the diameter is at most O(log |G|). (2) For alternating groups, use the fact that A_n is generated by 3-cycles and that any permutation can be written as a product of O(n) 3-cycles. (3) Formalize the connection between word length in generators and hyperbolic distance. Key tools needed: character estimates for symmetric groups, representation-theoretic diameter bounds.

**Domain Bridges**: Algebra <-> Computation, Cryptography <-> Geometry

**Lineage**: Builds on orbit_growth_exponential and the falsifiable conjecture from this cycle (which showed the naive version fails for cyclic groups).

**Ambition**: grand_challenge
