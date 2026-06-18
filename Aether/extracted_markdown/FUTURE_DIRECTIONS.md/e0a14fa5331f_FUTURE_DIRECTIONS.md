# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the algebraic foundations of arithmetic on the Poincaré disk, proving the Cassini identity for trace sequences, classifying periodic (elliptic) trace sequences, establishing growth bounds for hyperbolic traces, and bridging hyperbolic geometry to tropical algebra via the Gromov product ultrametric inequality. The companion matrix bridge connects all of this to linear algebra and spectral theory.

The most promising cross-domain connection discovered is the **Gromov-tropical bridge**: the fact that the ultrametric inequality for Gromov products is formally identical to the non-Archimedean triangle inequality governing tropical valuations. This suggests a deep structural duality between the spectral theory of the Laplacian on hyperbolic surfaces and the combinatorics of tropical varieties. Combined with the existing catalog's tropical infrastructure (`Tropical/` directory) and the algebra foundations (`Algebra/Foundations.lean`), this bridge opens a concrete path toward formalizing the Selberg trace formula as a tropical identity.

The highest breakthrough potential lies in Direction 1 (Selberg Trace Formula): if the simplified algebraic version can be formalized, it would connect our trace sequence machinery to the analytic theory of automorphic forms, providing the first machine-verified spectral decomposition result for hyperbolic surfaces. The companion matrix bridge (Theorem 5.3, Cayley-Hamilton) provides the algebraic engine, and the Cassini identity (Theorem 2.1) provides the inductive framework needed for the trace formula's geometric side.

---

### Direction 1: Selberg Trace Formula for Finite Quotients

**Conjecture**: For a finite-index subgroup Γ ≤ SL₂(ℤ) of index N, the trace formula
    Σ_{eigenvalues λ} h(λ) = (N/12) · ĥ(0) + Σ_{conjugacy classes [γ]} Σ_{n=1}^∞ (ℓ(γ) / (2 sinh(nℓ(γ)/2))) · g(nℓ(γ))
can be reduced (for the test function h(r) = e^{-r²t}) to an identity between theta functions and trace sums that is provable in Lean 4 using our trace sequence infrastructure.

**Test**: Formalize the trace formula for Γ(2) (index 6 in PSL₂(ℤ)) with the heat kernel test function. Compare the spectral side (computed via our traceSeq function applied to the companion matrices of generators) with the geometric side (computed via our displacement length function). The two sides should agree to machine precision for the first 100 terms.

**Impact**: If true, this would be the first machine-verified instance of the Selberg trace formula. It would open the door to formalizing the prime geodesic theorem and, eventually, connecting to the Riemann Hypothesis via the Selberg-Hejhal approach.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (traceSeq, HyperbolicSpectralData, traceCompanion), `Catalog/MachineLearning/HyperbolicNumberTheory/Foundations.lean` (MobiusMap, trace_pow_recurrence)

**Proof Strategy**: 
1. Define the spectral side as a sum over eigenvalues of the hyperbolic Laplacian (discretized for finite quotients).
2. Define the geometric side as a sum over conjugacy classes, using traceSeq to compute the displacement lengths.
3. Prove the identity by expanding both sides using the companion matrix eigenvalues.
4. Key lemma: the trace of the heat kernel e^{-tΔ} equals Σ_n traceSeq(t, n) · e^{-λ_n t} for appropriate eigenvalues λ_n.

**Domain Bridges**: NumberTheory <-> SpectralTheory, Algebra <-> Physics

**Lineage**: Builds on traceSeq_cassini, traceCompanion_cayley_hamilton, HyperbolicSpectralData.discriminant_pos from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Selberg Duality

**Conjecture**: The Selberg zeta function Z_Γ(s) = Π_{[γ] primitive} Π_{k=0}^∞ (1 - e^{-(s+k)ℓ(γ)}) tropicalizes (under the map x → -log|x|) to a piecewise-linear function whose breakpoints encode the eigenvalues of the Laplacian on Γ\ℍ. Formally: the tropical Selberg zeta function trop(Z_Γ)(s) = min_{[γ], k} (s+k)·ℓ(γ) has a well-defined "tropical functional equation" relating s and 1-s.

**Test**: For Γ = PSL₂(ℤ), compute trop(Z_Γ)(s) numerically for s ∈ [0, 2] using the first 50 conjugacy classes. Verify that the breakpoints of the piecewise-linear function correspond (approximately) to the spectral parameters r_n where eigenvalues are λ_n = 1/4 + r_n². The tropical functional equation should manifest as a symmetry of the breakpoint pattern about s = 1/2.

**Impact**: This would establish a new connection between tropical geometry and automorphic forms, potentially providing a combinatorial approach to the Riemann Hypothesis for the Selberg zeta function.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (tropAdd, tropMul, tropMul_distrib, gromov_product_ultrametric), `Tropical/` directory (existing tropical infrastructure)

**Proof Strategy**:
1. Formalize the Selberg zeta function as a formal product over conjugacy classes.
2. Define the tropicalization map and prove it preserves the product structure (tropical products become sums).
3. Prove the piecewise-linearity of the tropicalized zeta function.
4. Establish the tropical functional equation by showing the breakpoints are symmetric about s = 1/2.

**Domain Bridges**: Tropical <-> NumberTheory, Algebra <-> SpectralTheory

**Lineage**: Builds on gromov_product_ultrametric, tropMul_distrib from this cycle, and tropical infrastructure in the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Chebyshev-Fibonacci Unification via Trace Sequences

**Conjecture**: The trace sequence traceSeq(t, n) provides a uniform framework that, for specific values of t, recovers:
- t = 1: the sequence 2, 1, -1, -2, -1, 1, ... (period 6, connected to Eisenstein integers)
- t = 3: the Lucas numbers L_n = F_{n-1} + F_{n+1} (connected to the golden ratio)
- t = 2k: sequences connected to Chebyshev polynomials of integer argument

The Cassini identity traceSeq(t,n+2)·traceSeq(t,n) - traceSeq(t,n+1)² = t²-4 unifies the classical Cassini identity for Fibonacci numbers (where it alternates ±1) with the constant-discriminant property.

**Test**: Prove in Lean 4 that traceSeq(3, n) = L_{2n} (the even-indexed Lucas numbers) by induction, using the recurrence relations of both sequences. Verify computationally for n = 0,...,20.

**Impact**: This would provide a unified algebraic framework for all linear recurrence sequences with determinant 1, connecting Fibonacci theory, Chebyshev polynomials, and hyperbolic geometry.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (traceSeq, traceSeq_cassini, traceSeq_one_periodic), `Algebra/Berggren.lean` (existing Berggren tree infrastructure)

**Proof Strategy**:
1. Define Lucas numbers via the standard recurrence L_0 = 2, L_1 = 1, L_{n+2} = L_{n+1} + L_n.
2. Prove traceSeq(3, n) = L_{2n} by induction, using the identity L_{2(n+1)} = L_{2n+2} = L_{2n+1} + L_{2n} = (L_{2n} + L_{2n-1}) + L_{2n} and simplifying via the golden ratio.
3. Derive the classical Fibonacci Cassini identity as a corollary of our trace sequence Cassini identity.

**Domain Bridges**: NumberTheory <-> CombinatoricsAlgebra, HyperbolicGeometry <-> FibonacciTheory

**Lineage**: Builds on traceSeq_cassini, traceSeq_3_concrete from this cycle.

**Ambition**: extension

---

### Direction 4: Spectral Gap Formalization

**Conjecture**: For the principal congruence subgroup Γ(p) with p ≥ 2 prime, the first nonzero eigenvalue λ₁ of the Laplacian on Γ(p)\ℍ satisfies λ₁ ≥ 3/16. This is Selberg's 3/16 theorem, which remains the best unconditional bound (Selberg's eigenvalue conjecture predicts λ₁ ≥ 1/4).

**Test**: Formalize the statement of Selberg's 3/16 theorem in Lean 4, using our HyperbolicSpectralData structure to represent the spectral data. Then prove a weaker bound (e.g., λ₁ > 0) using the Cassini identity and trace growth bounds: since traceSeq(t, n) grows exponentially for |t| > 2, the spectral gap is positive.

**Impact**: Even formalizing the statement precisely would be valuable, as it would establish the infrastructure for the Selberg eigenvalue conjecture. Proving the positivity of the spectral gap would connect our trace sequence machinery to spectral theory.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (HyperbolicSpectralData, traceSeq_strict_mono_of_ge_three, traceSeq_pos_of_ge_three, congruence_subgroup_index_div6)

**Proof Strategy**:
1. Define the Laplacian spectrum of Γ(p)\ℍ as a sequence of eigenvalues.
2. Relate eigenvalues to trace sums via the pre-trace formula: λ_n = 1/4 + r_n² where r_n are determined by the spectral parameters.
3. Use our trace growth bounds (Theorem 4.1) to show that the smallest r_n is bounded away from 0.
4. The congruence subgroup index theorem (6 | p(p²-1)) constrains the spectral multiplicity.

**Domain Bridges**: NumberTheory <-> SpectralTheory, Algebra <-> AnalyticNumberTheory

**Lineage**: Builds on traceSeq_strict_mono_of_ge_three, congruence_subgroup_index_div6, HyperbolicSpectralData from this cycle.

**Ambition**: extension

---

### Direction 5: Hyperbolic Lattice Coding Theory

**Conjecture**: The orbit of 0 under a finitely generated subgroup of PSL₂(ℝ) acting on the Poincaré disk, when projected onto the boundary circle ∂𝔻, produces a point distribution with near-optimal discrepancy for numerical integration on the circle. Specifically, the discrepancy D_N of N orbit points satisfies D_N = O(log(N)/N), matching the best known constructions from coding theory.

**Test**: For the modular group PSL₂(ℤ) with generators S and T, compute the first 1000 orbit points of 0 in 𝔻, project them radially onto ∂𝔻, and measure the discrepancy. Compare with the theoretical bound and with random point distributions.

**Impact**: This would connect hyperbolic number theory to information theory and coding, providing a geometric construction of low-discrepancy sequences with potential applications to quasi-Monte Carlo integration and sphere packing.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (DiskPoint, pseudoHypDistSq, conformalFactor_ge_two), `Computation/InfoEfficientAlgorithms.lean` (existing information-theoretic infrastructure)

**Proof Strategy**:
1. Define the radial projection map 𝔻 → ∂𝔻 and the associated discrepancy measure.
2. Relate the discrepancy to the pseudo-hyperbolic distances between orbit points.
3. Use the conformal factor bound λ ≥ 2 to convert Euclidean discrepancy to hyperbolic discrepancy.
4. Apply the equidistribution theorem for Fuchsian groups (a consequence of mixing of the geodesic flow).

**Domain Bridges**: HyperbolicGeometry <-> CodingTheory, NumberTheory <-> InformationTheory

**Lineage**: Builds on DiskPoint, pseudoHypDistSq_lt_one, conformalFactor_ge_two from this cycle.

**Ambition**: extension
