# Future Directions: Curvature-Controlled Stochastic Processes

## Synthesis

The spectral gap certificate framework established here — converting Lorentzian Hessian signatures into Poincaré inequalities for basis exchange walks — is the seed of a much larger program. The unifying theme is: **algebraic curvature data from generating polynomials should control the dynamics of all natural stochastic processes on combinatorial structures.** The curvature-controlled kernel abstraction provides the interface; the challenge now is to push through the walls separating algebraic geometry, probability, quantum computing, and statistical physics. The five directions below represent a progression from concrete extensions (Directions 1–2) through the theoretical core (Direction 3) to ambitious cross-domain applications (Directions 4–5). Each builds on the catalog theorems in `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`, `Catalog/Pythagorean/LorentzianExchangeCertificates.lean`, and `Catalog/Pythagorean/StrongRayleighSpectralGap.lean`, and each is formulated to be falsifiable by either computation or proof.

---

## Direction 1: Log-Sobolev Inequalities from Higher-Order Lorentzian Data

**Conjecture:** For matroids whose basis-generating polynomials are Lorentzian, the basis exchange walk satisfies a modified log-Sobolev inequality with constant O(r · log r), where r is the rank. This would imply hypercontractive mixing — exponentially faster convergence than the Poincaré inequality alone guarantees.

**Test:** Compute the log-Sobolev constant numerically for partition matroids with r ∈ {2,...,8} and block sizes n ∈ {2,...,5}. Compare against the Poincaré constant (= 1/gap). If the ratio log-Sobolev / Poincaré is bounded by O(log r), the conjecture is supported.

**Impact:** Log-Sobolev inequalities are the gold standard for mixing time analysis. Achieving them from curvature data would give optimal O(r log r · log(1/ε)) mixing times, matching the best known results for strongly Rayleigh distributions but with a conceptually new proof route.

**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Hessian signature characterization), `Catalog/Pythagorean/StrongRayleighSpectralGap.lean` (CurvatureControlledKernel, poincare_from_mean_zero).

**Proof Strategy:** Extend the Hessian signature analysis to control not just the quadratic form but the entropy functional Ent_μ(f²) = E_μ[f² log f²] - E_μ[f²] log E_μ[f²]. The key step would be showing that the Lorentzian condition implies a "tensorization" property for the entropy along exchange directions.

**Domain Bridges:** Probability theory (hypercontractivity), information theory (entropy decay), statistical physics (Glauber dynamics).

**Lineage:** Direct extension of Theorem A (Poincaré from certificate) in `StrongRayleighSpectralGap.lean`.

**Ambition:** Solid extension — high probability of success within one cycle.

**The key insight is:** the Lorentzian condition constrains not just the second-order (variance) behavior but the full entropy landscape, because the "one positive eigenvalue" condition is inherited by all iterated derivatives.

**Why now?** The formalized Poincaré inequality and curvature-controlled kernel framework provide the exact scaffold needed. The Hessian signature machinery from `LorentzianRecognitionComplete.lean` is already recursive and handles arbitrary derivative depth.

---

## Direction 2: Constructive Certificates for Graphic Matroids via Deletion-Contraction

**Conjecture:** For every connected graph G on n vertices, there exists a constructive Lorentzian exchange certificate for M(G) with constant κ ≥ 1/(2(n-1)), achievable by a polynomial-time algorithm that recursively analyzes deletion-contraction minors.

**Test:** Implement the deletion-contraction certificate construction for small graphs (K₃ through K₇, random graphs on 5–8 vertices). Compare the constructive certificate constant against the numerically computed spectral gap.

**Impact:** A constructive certificate algorithm would make the curvature framework algorithmically practical, enabling certified MCMC sampling for spanning tree distributions.

**Catalog References:** `Catalog/Pythagorean/LorentzianExchangeCertificates.lean` (exchange inequality from log-concavity), `Catalog/Pythagorean/StrongRayleighSpectralGap.lean` (TruncatedCertificateSystem, computeTruncatedGapBound_sound).

**Proof Strategy:** Induction on |E(G)|. For the base case (tree), the matroid has one basis and the gap is trivially 1. For the inductive step, use deletion-contraction: M(G) decomposes along an edge e into M(G\e) and M(G/e). Show that the Poincaré constant of M(G) is bounded by a function of the constants for M(G\e) and M(G/e), using the comparison theorem (`hasSpectralGapAtLeast_mono`).

**Domain Bridges:** Graph theory, network reliability, algebraic graph theory.

**Lineage:** Builds on Theorem B (rank-scale bound) and the truncated certificate system.

**Ambition:** Solid extension with novel algorithmic content.

**The key insight is:** deletion-contraction preserves the Lorentzian property (by Brändén–Huh), so the certificate can be built recursively from the base cases, accumulating a product of local constants.

**Why now?** The truncated certificate framework is formalized and sound. The missing piece is the inductive construction, which leverages matroid minor theory already partially available in Mathlib.

---

## Direction 3: Curvature-Controlled Quantum Samplers

**Conjecture:** For any curvature-controlled kernel with constant κ, there exists a quantum algorithm that prepares an ε-approximate sample from the stationary distribution in time O(1/√κ · log(n/ε)), achieving a quadratic speedup over classical MCMC.

**Test:** Simulate the quantum walk analog of the basis exchange walk on a quantum computer simulator for small partition matroids. Compare the quantum mixing time against the classical bound of O(1/κ · log(n/ε)).

**Impact:** This would establish that curvature certificates translate directly to quantum speedups, creating a new paradigm for quantum-classical algorithm comparison: the curvature constant is the universal interface.

**Catalog References:** `Catalog/Pythagorean/StrongRayleighSpectralGap.lean` (CurvatureControlledKernel, spectralGap_of_curvature), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Hessian signature → negative semidefiniteness on tangent space).

**Proof Strategy:** Use the Szegedy quantum walk framework. The spectral gap of the Szegedy walk squares the classical gap: γ_quantum = Ω(√γ_classical). With the curvature certificate providing γ_classical ≥ κ, the quantum gap is ≥ Ω(√κ). The phase estimation step then gives the claimed mixing time.

**Domain Bridges:** Quantum computing, quantum walks, Hamiltonian simulation.

**Lineage:** Grand extension of Theorem D (curvature-controlled kernel abstraction).

**Ambition:** Grand challenge — paradigm-shifting if successful.

**The key insight is:** the curvature-controlled kernel is the right abstraction for the quantum speedup because it provides exactly the spectral data that Szegedy's framework needs, without requiring any matroid-specific structure.

**Why now?** The CurvatureControlledKernel abstraction is formalized. Szegedy walk theory is mature. The missing link is connecting the two.

---

## Direction 4: Entropy Decay and Information-Theoretic Certificates

**Conjecture:** The curvature constant κ of a curvature-controlled kernel provides a lower bound on the rate of conditional entropy decay: H(X_t | X_∞) ≤ e^{-κt} · H(X_0 | X_∞), where X_t is the state at time t and X_∞ ~ μ.

**Test:** Compute the relative entropy D(P^t(x, ·) || μ) for the partition matroid exchange walk at successive times t, and verify that the decay rate matches or exceeds κ.

**Impact:** This would extend the curvature framework from the L² setting (Poincaré inequality) to the information-theoretic setting (entropy contraction), unifying the probabilistic and information-theoretic views of mixing.

**Catalog References:** `Catalog/Pythagorean/StrongRayleighSpectralGap.lean` (Poincaré inequality, mixing time bounds).

**Proof Strategy:** From the Poincaré inequality Var(f) ≤ κ⁻¹ · E(f,f), derive the L² exponential decay of P^t f. Then use the Rothaus–Simon lemma to lift from L² decay to entropy decay, with an additional factor depending on the log-Sobolev constant (Direction 1).

**Domain Bridges:** Information theory, entropy, data processing inequalities, channel coding.

**Lineage:** Builds on Direction 1 (log-Sobolev) and the core Poincaré framework.

**Ambition:** Solid extension with high theoretical value.

**The key insight is:** the Poincaré inequality controls L² decay, and L² decay controls entropy decay via interpolation — but the Lorentzian structure might allow a *direct* entropy-level certificate, bypassing the interpolation.

**Why now?** The formal Poincaré framework is complete. The entropy decay direction requires building the log-Sobolev bridge (Direction 1) first, but preliminary numerics can test the conjecture immediately.

---

## Direction 5: Universal Curvature-Gap Theory for High-Dimensional Expanders

**Conjecture:** Every simplicial complex whose links satisfy the Lorentzian polynomial condition admits a curvature-controlled random walk with gap ≥ C/dim, where dim is the dimension of the complex and C is a universal constant. This would subsume both matroid exchange walks and high-dimensional expander walks under a single curvature theory.

**Test:** Compute the spectral gap of the "link walk" on small simplicial complexes whose 1-skeleton is a known expander. Verify that the gap scales as 1/dim. Construct explicit Lorentzian certificates for these complexes.

**Impact:** If true, this would unify the Kaufman–Oppenheim high-dimensional expander theory with the Lorentzian polynomial theory, creating a single framework for rapid mixing on multi-level combinatorial structures. This is a field-opening result that would connect algebraic geometry (Lorentzian polynomials), topology (simplicial complexes), and probability (random walks).

**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (recursive Lorentzian characterization), `Catalog/Pythagorean/StrongRayleighSpectralGap.lean` (CurvatureControlledKernel, spectralGap_lowerBound_rank).

**Proof Strategy:** For each link of the complex, the link's generating polynomial should satisfy the Lorentzian condition (by the descent property of Lorentzian polynomials under restriction). The link walk's gap is then bounded by a curvature constant from the link's Hessian. The global gap follows from Garland's method: a weighted average of local gaps gives a global gap, with the weighting controlled by the complex's geometry.

**Domain Bridges:** Algebraic topology (simplicial complexes), theoretical computer science (high-dimensional expanders), coding theory (quantum LDPC codes), algebraic geometry (Hodge–Riemann relations).

**Lineage:** Grand extension of Theorems B and D, combining curvature-controlled kernels with simplicial decomposition.

**Ambition:** Grand challenge — would redefine the field if achieved.

**The key insight is:** the recursive nature of both the Lorentzian characterization (via iterated derivatives) and the high-dimensional expander structure (via links) suggests a deep structural parallel that should be exploitable.

**Why now?** The curvature-controlled kernel abstraction is precisely the interface that connects Lorentzian theory to expander theory. The recursive certificate machinery from `LorentzianRecognitionComplete.lean` mirrors the link decomposition in Garland's method. The formal infrastructure is ready for the synthesis.
