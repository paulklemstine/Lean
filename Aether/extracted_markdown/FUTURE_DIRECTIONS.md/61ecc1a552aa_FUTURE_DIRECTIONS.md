# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the formal foundations of number theory on the Poincaré disk: Möbius automorphisms, hyperbolic distance, lattice structures, and hyperbolic primes. The most significant discovery is the tight connection between hyperbolic lattice arithmetic and spectral theory, formalized through our finite Selberg trace formula analog (Theorem `spectral_geometric_duality`). This connects three domains that are usually studied separately: hyperbolic geometry, number theory, and spectral analysis.

The cycle also revealed that the Schläfli condition — the simple inequality (p-2)(q-2) > 4 — serves as a "gateway" between flat and hyperbolic arithmetic. Every pair (p,q) with (p-2)(q-2) > 4 defines a distinct arithmetic on the hyperbolic plane, giving rise to a landscape of different "number systems" parameterized by tessellation type. This is a structural insight that has no classical analog and connects directly to the Catalog's work on algebraic structures (`Algebra/Basic.lean`) and tessellation geometry.

The highest breakthrough potential lies in Direction 1 (Hyperbolic Selberg Zeta), which could establish a rigorous connection between lattice orbit counting and spectral data, potentially yielding a provable analog of the Riemann Hypothesis in a hyperbolic setting. The Selberg zeta function for compact hyperbolic surfaces already satisfies a known "Riemann Hypothesis" — all zeros on a critical line — and our formal framework is positioned to bridge this known result to the arithmetic of hyperbolic integers.

---

### Direction 1: Hyperbolic Selberg Zeta Function

**Conjecture**: For a hyperbolic lattice L arising from a cofinite Fuchsian group Γ, the Selberg zeta function Z_Γ(s) = Π_{γ primitive} Π_{k≥0} (1 - e^{-(s+k)ℓ(γ)}) extends meromorphically to all of ℂ, and its nontrivial zeros lie on the line Re(s) = 1/2.

**Test**: Compute the first 20 zeros of Z_Γ(s) for Γ = PSL(2,ℤ) numerically (using the known relation to the Riemann zeta function and the Selberg/Ruelle zeta function). Verify all have Re(s) = 1/2. Then formalize the functional equation Z_Γ(s) = Z_Γ(1-s)·(explicit gamma factors) in Lean 4.

**Impact**: If formalized, this would give a machine-verified proof of a "Riemann Hypothesis" in a specific geometric setting. This is significant because the Selberg zeta RH is *known to be true* (proved by Selberg for cocompact groups), but has never been formally verified. A formal proof would demonstrate that RH-type results can be machine-checked and would provide infrastructure for attacking the classical RH.

**Catalog References**: `Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Speculative/HyperbolicNumberTheory/Core.lean` (spectral_geometric_duality, finite_euler_product_bound)

**Proof Strategy**:
1. Formalize the definition of primitive closed geodesics in terms of conjugacy classes of Γ.
2. Define the Selberg zeta function as a formal Euler product over primitive geodesics.
3. Establish convergence for Re(s) > 1 using bounds on ℓ(γ).
4. Prove the functional equation using the Selberg trace formula (building on our finite analog).
5. Deduce the zero location from the functional equation and the self-adjointness of the Laplacian.

**Domain Bridges**: NumberTheory <-> SpectralTheory, Geometry <-> Analysis

**Lineage**: Builds on `spectral_geometric_duality` and `finite_euler_product_bound` from this cycle. Extends the `critical_line_implies_unit_disk` result in `Algebra/Foundations.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Geometry at the Boundary of the Poincaré Disk

**Conjecture**: The boundary ∂𝔻 of the Poincaré disk, equipped with the visual metric d_∞(ξ, η) = exp(-⟨ξ|η⟩_o) (where ⟨·|·⟩_o is the Gromov product), has the structure of a tropical semiring. Specifically, the Busemann functions β_ξ(x, y) satisfy tropical addition (min) and the horocyclic distance satisfies tropical multiplication (ordinary addition), making ∂𝔻 a tropical variety.

**Test**: Compute the Busemann functions for 10 boundary points of the Poincaré disk. Verify that the operation (ξ, η) ↦ min(β_ξ, β_η) defines a well-formed tropical addition on the boundary. Check that the tropical Newton polygon of the resulting "boundary polynomial" matches the convex hull of the lattice point distribution.

**Impact**: This would establish a formal bridge between hyperbolic geometry and tropical geometry — two domains that share structural features (valuations, ultrametricity) but have not been formally connected. The Catalog has extensive tropical infrastructure (`Tropical/`) and this would create a new cross-domain bridge.

**Catalog References**: `Tropical/` (entire directory), `Speculative/HyperbolicNumberTheory/Core.lean` (poincareConformalFactor_large — boundary behavior)

**Proof Strategy**:
1. Define Busemann functions in Lean as limits of (d(x, γ(t)) - t) as t → ∞.
2. Show that Busemann functions satisfy the tropical semiring axioms.
3. Define the "tropical boundary ring" as (∂𝔻, min, +).
4. Prove that horocycles correspond to tropical hypersurfaces.
5. Connect to the lattice counting function via the exponential growth rate.

**Domain Bridges**: HyperbolicGeometry <-> TropicalGeometry, NumberTheory <-> AlgebraicGeometry

**Lineage**: Builds on `hypDist_origin` and `poincareConformalFactor_large` from this cycle. Connects to the Catalog's `Tropical/` infrastructure.

**Ambition**: grand_challenge

---

### Direction 3: Hyperbolic Prime Number Theorem via Spectral Methods

**Conjecture**: For the {7,3} tessellation lattice L, the number of hyperbolic primes within hyperbolic radius R satisfies N_prime(R) = C · e^R / R · (1 + O(1/R)) for some explicit constant C > 0 depending on the tessellation.

**Test**: Generate the {7,3} lattice to depth 10 (approximately 10^5 points). Compute N_prime(R) for R = 1, 2, ..., 15. Fit the model N_prime(R) = C · e^R / R and estimate C. Test the goodness of fit (R² value should exceed 0.99 for the asymptotic regime R ≥ 5).

**Impact**: A quantitative hyperbolic PNT would be the first result connecting lattice combinatorics to exponential growth rates in a formally verified framework. Even a verified upper bound N_prime(R) ≤ C₂ · e^R / R would be significant.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Core.lean` (IsHyperbolicPrime, normCountingFn_mono, first_point_is_hyp_prime, hypArea_nonneg)

**Proof Strategy**:
1. Establish a lower bound on the number of lattice points: N(R) ≥ c₁ · e^R (from Huber's theorem).
2. Show that "most" lattice points are composite by bounding the number of Möbius compositions.
3. Use inclusion-exclusion on the set of composites to bound N_prime from above and below.
4. The key technical ingredient is a bound on the number of pairs (i,j) with d(0, φ_{p_i}(p_j)) ≤ R.
5. Connect to the spectral data via the trace formula.

**Domain Bridges**: NumberTheory <-> CombinatorialGeometry

**Lineage**: Directly extends `IsHyperbolicPrime`, `normCountingFn_mono`, and the counting infrastructure from this cycle.

**Ambition**: extension

---

### Direction 4: Unique Factorization in Hyperbolic Lattices

**Conjecture**: For the lattice generated by the modular group PSL(2,ℤ), every lattice point has a unique factorization into hyperbolic primes up to ordering, where "factorization" means iterated Möbius composition.

**Test**: Generate the PSL(2,ℤ) orbit of 0 to depth 6. For each composite point, enumerate all possible factorizations into primes. Check if the factorization is unique (up to ordering).

**Impact**: If true, this establishes that hyperbolic integers form a "unique factorization domain" in a geometric sense, giving a new perspective on why UFDs are natural. If false, the failure mode (specific counterexample) would reveal the geometric obstruction to unique factorization, connecting to ideal theory and class numbers.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Core.lean` (IsHyperbolicPrime, moebiusMap, moebius_involution), `Algebra/Basic.lean`

**Proof Strategy**:
1. Formalize the notion of "factorization" as a sequence of prime indices.
2. Show that the free product structure of PSL(2,ℤ) ≅ ℤ/2 * ℤ/3 implies unique reduced words.
3. Connect reduced words to Möbius compositions via the ping-pong lemma.
4. Prove that unique reduced word ⟹ unique factorization into primes.

**Domain Bridges**: NumberTheory <-> GroupTheory, Geometry <-> Algebra

**Lineage**: Extends `first_point_is_hyp_prime` and `moebius_involution` from this cycle.

**Ambition**: extension

---

### Direction 5: Spectral Gap and Expander Graphs from Hyperbolic Lattices

**Conjecture**: The adjacency graph of the {p,q} hyperbolic tessellation lattice (truncated to N points) has spectral gap λ₁ - λ₀ ≥ 1/4 - ε for any ε > 0 and sufficiently large N, where λ₀, λ₁ are the two smallest Laplacian eigenvalues.

**Test**: Compute the Laplacian spectrum of the {7,3} lattice graph for N = 50, 100, 200, 500 points. Plot λ₁ as a function of N. The conjecture predicts convergence to a value ≥ 1/4.

**Impact**: A verified spectral gap bound would connect hyperbolic number theory to theoretical computer science (expander graphs), coding theory (LDPC codes from hyperbolic tessellations), and quantum computing (quantum error-correcting codes). The value 1/4 is the Selberg eigenvalue conjecture threshold.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Core.lean` (spectral_geometric_duality, weyl_law_finite_analog), `Computation/` (algorithmic results)

**Proof Strategy**:
1. Build the adjacency matrix of the truncated lattice graph in Lean.
2. Use the Cheeger inequality to relate spectral gap to graph expansion.
3. Show that hyperbolic lattice graphs have expansion ratio ≥ c > 0 (geometric argument using exponential volume growth).
4. Apply Cheeger: λ₁ ≥ h²/2 where h is the Cheeger constant.
5. Optimize bounds using the known isoperimetric inequality in hyperbolic space.

**Domain Bridges**: NumberTheory <-> TheoreticalCS, Geometry <-> CodingTheory

**Lineage**: Extends `spectral_geometric_duality` and `weyl_law_finite_analog` from this cycle. Connects to `Computation/` infrastructure.

**Ambition**: extension
