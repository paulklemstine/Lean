# Future Directions: Real Stability and the Lorentzianity Bridge

## Synthesis

The formal verification of determinantal real stability establishes the first link in a three-part chain: **PSD → Real Stable → Lorentzian → Hodge inequalities**. Our work proves the first arrow. The remaining directions below aim to complete this chain, extend it to new domains (quantum information, tropical geometry, algorithmic combinatorics), and explore the deep structural consequences of real stability for probability distributions and optimization. The unifying theme is that *positive semidefiniteness propagates through polynomial algebra to produce combinatorial and probabilistic constraints* — and each direction below exploits a different facet of this propagation.

---

## Direction 1: Complete the Brändén–Huh Bridge (Real Stable → Lorentzian)

**Conjecture**: Every real stable homogeneous polynomial with nonneg coefficients satisfies the recursive Lorentzian signature condition formalized in `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`.

**Test**: For random PSD matrices $K$ of size $n = 4, 5, 6$, homogenize $Z_K$ to obtain $h_K(\mathbf{x}, t) = t^n Z_K(\mathbf{x}/t)$. Compute all degree-2 iterated partial derivatives and verify that each Hessian has at most one positive eigenvalue (Lorentzian signature). Failure on *any* example would disprove the conjecture (or reveal a bug in the formalization).

**Impact**: Completing this bridge would yield the first formally verified proof of ultra log-concavity for DPP coefficients, connecting our `determinantal_real_stable` theorem to the `recursivelyLorentzian_iff_brandenHuh` equivalence in the catalog.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (definitions of `IsBrandenHuhLorentzian`, `IsRecursivelyLorentzian`, and the main equivalence theorem).

**Proof Strategy**: Formalize the homogenization step (stability preservation under homogenization), then prove that the Hessian of any degree-2 restriction of a real stable polynomial has at most one positive eigenvalue by showing the associated quadratic form is Lorentzian-signed. The key technical step is showing that univariate restrictions of real stable polynomials are real-rooted.

**Domain Bridges**: Algebraic geometry (Hodge theory) ↔ Probability (DPP concentration) ↔ Combinatorics (matroid theory).

**Lineage**: Builds directly on `determinantal_real_stable` (this work) and `recursivelyLorentzian_iff_brandenHuh` (catalog).

**Ambition**: Grand challenge — this would complete the formal Brändén-Huh pipeline, a result of Fields Medal significance.

---

## Direction 2: Non-Commutative Stability for Quantum Channels

**Conjecture**: For any completely positive trace-preserving (CPTP) quantum channel $\Phi$ with Kraus representation $\Phi(\rho) = \sum_i A_i \rho A_i^\dagger$, the polynomial $Z_\Phi(\mathbf{x}) = \det(I + \sum_i x_i A_i A_i^\dagger)$ is real stable.

**Test**: Generate 1000 random CPTP channels on $\mathbb{C}^{2 \times 2}$ and $\mathbb{C}^{3 \times 3}$ using the Stinespring dilation. For each, evaluate $Z_\Phi$ at $10^4$ random points in $\mathbb{H}^k$. If $|Z_\Phi(\mathbf{z})| < 10^{-10}$ at any point, the conjecture is falsified.

**Impact**: Would establish a non-commutative Lee-Yang theorem connecting quantum information theory to Lorentzian polynomials. The key insight is that CPTP channels are the quantum analogue of PSD matrices, and this conjecture asserts that the "quantumness" of the channel does not destroy real stability.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`, `Pythagorean/DeterminantalStability.lean` (this work).

**Proof Strategy**: The matrix $M(\mathbf{z}) = I + \sum_i z_i A_i A_i^\dagger$ has Hermitian part $H = I + \sum_i \operatorname{Re}(z_i) A_i A_i^\dagger$. Show that when all $\operatorname{Im}(z_i) > 0$, the skew-Hermitian perturbation $iS = \sum_i i \operatorname{Im}(z_i) A_i A_i^\dagger$ makes $M$ invertible by proving that $H + iS$ has positive definite Hermitian part (since each $A_i A_i^\dagger$ is PSD and weighted by positive imaginary parts).

**Domain Bridges**: Quantum information ↔ Complex algebraic geometry ↔ Statistical mechanics.

**Lineage**: Extends `determinantal_real_stable` from commutative (diagonal) to non-commutative (general Kraus) setting.

**Ambition**: Grand challenge — would be the first non-commutative Lee-Yang theorem.

**Why now?** Our formalization of the inner-product contradiction technique provides the template. The non-commutative case requires replacing the scalar quadratic form argument with a matrix inequality argument, but the core idea — Hermitian reality vs. analytic positivity — is the same.

---

## Direction 3: Tropical Stability and Combinatorial Optimization

**Conjecture**: The tropical limit of the real stable polynomial $Z_K$ (as the PSD matrix $K$ is scaled by $t \to \infty$) produces a tropical polynomial whose Newton polytope satisfies the M-convexity condition of discrete convex analysis.

**Test**: For PSD matrices $K$ of size $n = 3, 4, 5$, compute the support of $Z_K$ (the set of exponent vectors with nonzero coefficients) and verify that it satisfies the symmetric matroid exchange axiom. For random PSD matrices, check that the log-coefficients $\log \det(K_S)$ form a valuated matroid.

**Impact**: Would connect the real stability framework to tropical geometry and combinatorial optimization, enabling certified margin bounds for matroid intersection algorithms.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (support exchange property `SupportSatisfiesExchange`), `Catalog/Pythagorean/TropicalMorse/Defs.lean`.

**Proof Strategy**: Use the characterization of Lorentzian polynomial supports as M-convex sets (Brändén-Huh, 2020, Theorem 2.10). The key insight is that the tropical limit preserves the support structure, and M-convexity of the support is equivalent to the symmetric exchange axiom for the underlying matroid.

**Domain Bridges**: Tropical geometry ↔ Combinatorial optimization ↔ Matroid theory.

**Lineage**: Builds on `determinantal_real_stable` (this work) and the tropical Morse theory infrastructure in the catalog.

**Ambition**: Solid extension — tropical limits of stable polynomials are well-studied, and the formalization infrastructure largely exists.

---

## Direction 4: Mixing Time Bounds from Stability Certificates

**Conjecture**: For a PSD matrix $K$ with eigenvalues $\lambda_1 \geq \cdots \geq \lambda_n > 0$ and spectral gap $\gamma = \lambda_1 - \lambda_2$, the mixing time of the natural DPP Gibbs sampler satisfies $t_{\text{mix}} = O(n \log(n) / \gamma)$, where the constant depends only on the stability margin $\min_{z \in \partial \mathbb{H}^n} |Z_K(z)|$.

**Test**: Implement the Gibbs sampler for DPPs with known spectral gaps. Measure empirical mixing times for $n = 10, 20, 50$ and compare against the predicted $O(n \log n / \gamma)$ bound. Deviations exceeding a factor of 2 would suggest the bound is not tight.

**Impact**: Would provide formally certified mixing time guarantees for DPP sampling algorithms, connecting the analytic (stability) framework to algorithmic (MCMC) performance.

**Catalog References**: `Pythagorean/DeterminantalStability.lean` (this work), `Catalog/Pythagorean/DynamicSpectralGap.lean`.

**Proof Strategy**: Use the stability margin to control the log-Sobolev constant of the DPP measure, then apply standard mixing time bounds via log-Sobolev → spectral gap → mixing time. The key insight is that the minimum modulus of $Z_K$ on the boundary of $\mathbb{H}^n$ controls the log-Sobolev constant.

**Domain Bridges**: Analysis (stability margins) ↔ Probability (mixing times) ↔ Algorithms (sampling guarantees).

**Lineage**: Builds on `determinantal_real_stable` and connects to spectral gap theory.

**Ambition**: Solid extension — mixing time analysis for DPPs is an active area with known partial results.

**Why now?** The formal stability certificate provides the missing ingredient: a computable bound on how far $Z_K$ is from vanishing, which directly translates to a mixing rate.

---

## Direction 5: Multivariate Stable Polynomials and Matroid Invariants

**Conjecture**: The basis generating polynomial $f_M(\mathbf{x}) = \sum_{B \in \mathcal{B}(M)} \prod_{i \in B} x_i$ of any matroid $M$ is real stable if and only if $M$ is a regular matroid (representable over every field).

**Test**: Enumerate all matroids on up to 8 elements. For each, compute the basis generating polynomial and test real stability numerically (evaluate at $10^4$ random upper half-plane points). Identify which matroids produce stable polynomials and check whether they are exactly the regular matroids.

**Impact**: Would provide a polynomial-time test for matroid regularity via stability checking, with deep implications for combinatorial optimization (regular matroids are exactly those for which the greedy algorithm works optimally).

**Catalog References**: `Pythagorean/DeterminantalStability.lean` (definition of `IsRealStable`), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (support exchange for matroids).

**Proof Strategy**: One direction (regular → stable) follows from the fact that regular matroids are representable over ℝ, giving a PSD kernel whose determinantal polynomial is the basis generating polynomial (by our main theorem). The reverse direction requires showing that non-regular matroids have basis polynomials with upper half-plane zeros.

**Domain Bridges**: Matroid theory ↔ Algebraic geometry ↔ Combinatorial optimization.

**Lineage**: Extends `IsRealStable` and `determinantal_real_stable` to the matroid setting.

**Ambition**: Grand challenge — characterizing regular matroids via polynomial stability would be a major breakthrough in combinatorial theory.

**Why now?** The formal definition of `IsRealStable` and the proof infrastructure for determinantal polynomials provide the foundation for extending stability analysis to matroid polynomials.
