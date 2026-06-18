# Future Directions: Lorentzian Spectral Gap Theory

## Synthesis

The tight spectral gap bound Ω(1/(d·n)) for Lorentzian polynomials opens a corridor connecting three previously separate research programs: (1) the algebraic theory of Lorentzian polynomials and combinatorial Hodge theory, (2) the probabilistic theory of Markov chain mixing via spectral methods, and (3) the quantum information theory of completely positive maps. The reversed Cauchy–Schwarz inequality serves as the structural bridge: it is simultaneously an algebraic property (Lorentzian signature), a probabilistic property (comparison factor for Dirichlet forms), and a quantum property (operator monotonicity for completely positive maps). Each future direction below exploits this triple nature to push the boundary in a different domain while feeding results back to the others.

---

## Direction 1: Sharp Constants for Elementary Symmetric Polynomials

**Conjecture:** For the elementary symmetric polynomial e_d(x₁,...,xₙ), the spectral gap of the certificate-guided birth-death chain is exactly λ₁ = (1 + o(1))/(d·n) as n → ∞ with d fixed, with the limiting constant equal to 1.

**Test:** Compute spectral gaps for e_d with d ∈ {2,3,4,5} and n ∈ {10, 20, 50, 100, 200, 500, 1000}. Fit λ₁·d·n to a polynomial in 1/n. If the constant term is 1.0 ± 0.01 and higher-order terms decay as O(1/n), the conjecture is confirmed numerically. If the constant term depends on d, the conjecture needs refinement.

**Impact:** Establishing sharp constants would make the spectral gap theory quantitatively predictive, enabling practitioners to compute guaranteed mixing time bounds without Monte Carlo estimation. It would also identify the extremal test function achieving equality in the Poincaré inequality.

**Catalog References:**
- `Pythagorean/LorentzianSpectralGap.lean`: `spectral_gap_lorentzian_improvement`, `lorentzian_dominates_log_concave`
- `Pythagorean/CertificateSampling.lean`: `spectral_gap_log_concave_lower_bound`, `binomial_log_concave`

**Proof Strategy:** The test function should be a degree-1 polynomial f(k) = k restricted to {0,...,d} (the support of the coefficients of e_d). The variance is Var(f) = d(n-d)/(4(n-1)) and the Dirichlet form is E(f,f) = 1/(n-1). The ratio gives λ₁ ≈ 4/((n-d)·d) ≈ 1/(d·n) for d ≪ n.

**Domain Bridges:** Combinatorics ↔ Random matrix theory (the birth-death chain is a discrete analogue of Jacobi unitary ensemble)

**Lineage:** Extends `spectral_gap_log_concave_lower_bound` by making the constant explicit.

**Ambition:** Solid extension — technically challenging but within reach of current methods.

---

## Direction 2: Quantum Channel Capacity from Lorentzian Structure

**Conjecture:** A degree-d Lorentzian polynomial in n variables defines a d-fold completely positive map Φ on n×n positive semidefinite matrices. The quantum capacity Q(Φ) satisfies Q(Φ) ≥ log(n) - d·log(d) - O(1), which is achievable by an LOCC (local operations and classical communication) protocol that mirrors the certificate-guided classical sampling algorithm.

**Test:** For the completely positive map defined by e_d, compute the coherent information I_c(Φ) = S(Φ(ρ)) - S((id ⊗ Φ)(|ψ⟩⟨ψ|)) for maximally entangled input states of dimension n. If I_c ≥ log(n) - d·log(d) for small d, the conjecture holds. If I_c is bounded by a constant independent of n, the conjecture fails.

**Impact:** Would establish the first systematic connection between combinatorial log-concavity and quantum channel theory. Potential applications to quantum error correction: Lorentzian structure could enable efficient decoding of certain quantum codes.

**Catalog References:**
- `Pythagorean/LorentzianSpectralGap.lean`: `comparison_spectral_gap`
- `Speculative/AutoResearch/LorentzianMConvex.lean`: `psd_cauchy_schwarz`, `IsLorentzianQuadratic`

**Proof Strategy:** Use the Stinespring dilation theorem to represent Φ as Φ(ρ) = Tr_E(V ρ V†) where V is determined by the Lorentzian certificate. The reversed CS translates to a lower bound on the minimum output entropy, which in turn lower-bounds the coherent information.

**Domain Bridges:** Combinatorics ↔ Quantum information ↔ Algebraic geometry (Hodge–Riemann as operator inequality)

**Lineage:** Novel — first connection between Lorentzian polynomials and quantum capacity.

**Ambition:** Grand challenge — paradigm-shifting if true.

---

## Direction 3: Lorentzian Glauber Dynamics for Matroid Potts Models

**Conjecture:** For the Potts model on the base polytope of a matroid M with n elements and rank d, the Glauber dynamics (single-site heat bath) has spectral gap Ω(1/(d·n)) at all temperatures β < β_c(M), where the critical temperature β_c is determined by the Lorentzian structure of the basis generating polynomial.

**Test:** Simulate Glauber dynamics on the graphic matroid of the complete graph K_n for n ∈ {5, 10, 20, 50} at inverse temperatures β ∈ {0, 0.5, 1.0, 1.5, 2.0}. Measure the autocorrelation time τ_auto and verify τ_auto = O(d·n) for β < β_c and τ_auto grows exponentially for β > β_c.

**Impact:** Would extend the celebrated Martinelli–Olivieri theory of Glauber dynamics mixing to a new class of models, unifying matroid theory with statistical mechanics. Direct applications to approximate counting of matroid bases at non-uniform weights.

**Catalog References:**
- `Pythagorean/CertificateSampling.lean`: `logConcaveSeq_mul`, `certificate_sampling_efficiency`
- `Pythagorean/LorentzianSpectralGap.lean`: `comparison_poincare`

**Proof Strategy:** Decompose the Glauber dynamics into "levels" corresponding to certificate depth. At each level, the dynamics is a walk on the exchangeable pairs of a matroid, whose spectral gap is controlled by the Lorentzian quadratic form. The comparison factor between adjacent levels is Ω(1/d) by reversed CS.

**Domain Bridges:** Statistical mechanics ↔ Matroid theory ↔ Markov chain Monte Carlo

**Lineage:** Extends `comparison_spectral_gap` to temperature-dependent dynamics.

**Ambition:** Solid extension — builds directly on existing comparison framework.

---

## Direction 4: Higher-Order Lorentzian Tensors and Simplicial Sampling

**Conjecture:** There exists a natural notion of "Lorentzian tensor" of order k ≥ 3, generalizing Lorentzian polynomials (k=2), such that:
1. The tensor satisfies a reversed multilinear Cauchy–Schwarz inequality.
2. The Newton support of the associated polynomial satisfies a k-dimensional M-convex exchange property.
3. The spectral gap of the associated simplicial random walk is Ω(1/(d·n^{k-1})).

**Test:** Define a 3-tensor version of Lorentzian signature (at most one positive eigenvalue in each "slice"). Check whether the volume polynomial of a 3-dimensional polytope satisfies this condition and whether the simplicial walk on its faces has gap Ω(1/(d·n²)).

**Impact:** Would open Lorentzian spectral theory to topological data analysis, where sampling from simplicial complexes is a key bottleneck. Would also connect to higher-dimensional Hodge theory and the resolution of the g-conjecture.

**Catalog References:**
- `Speculative/AutoResearch/LorentzianMConvex.lean`: `exchange_from_decomp`, `lorentzian_quadratic_support_mconvex`
- `Pythagorean/LorentzianSpectralGap.lean`: `lorentzian_comparison_factor`

**Proof Strategy:** Generalize the PSD decomposition H = vv^T - B to a tensor decomposition T = v^{⊗k} - B where B is "positive semidefinite in the tensor sense." The comparison argument should extend by induction on the tensor order.

**Domain Bridges:** Algebraic topology ↔ Combinatorics ↔ Computational geometry

**Lineage:** Novel — extends the Lorentzian framework to higher dimensions.

**Ambition:** Grand challenge — would require new algebraic machinery.

---

## Direction 5: Optimal Transport on Lorentzian Measures

**Conjecture:** The Wasserstein-2 distance between two Lorentzian measures (coefficient distributions of Lorentzian polynomials of the same degree d in n variables) is bounded by O(√(d·n)) times the total variation distance, with the constant determined by the Lorentzian Poincaré constant.

**Test:** For pairs of elementary symmetric polynomials e_d(x₁,...,xₙ) and e_d(x₁+ε,...,xₙ+ε), compute both W₂ and TV distances. If W₂/TV = Θ(√(d·n)), the conjecture is confirmed.

**Impact:** Would connect the Lorentzian spectral gap theory to the rapidly developing field of computational optimal transport, enabling efficient approximation of transport plans between combinatorial distributions.

**Catalog References:**
- `Pythagorean/LorentzianSpectralGap.lean`: `poincare_improvement`, `lorentzian_poincare_exists`

**Proof Strategy:** Use the Otto calculus to relate the Wasserstein gradient flow to the Dirichlet form, then apply the Lorentzian Poincaré inequality to bound the displacement convexity constant.

**Domain Bridges:** Optimal transport ↔ PDE theory ↔ Combinatorial optimization

**Lineage:** Extends `poincare_improvement` via the Benamou–Brenier formulation.

**Ambition:** Solid extension — leverages well-established connections between Poincaré inequalities and transport.
