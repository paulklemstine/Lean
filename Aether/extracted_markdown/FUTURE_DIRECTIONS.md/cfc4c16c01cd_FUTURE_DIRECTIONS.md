# Future Directions: Information Geometry Research Program

## Synthesis

This cycle established the foundational algebraic framework for information geometry in Lean 4, centering on the **DuallyFlatManifold** structure and proving the generalized Pythagorean theorem, Bregman duality, α-divergence duality, and the Cauchy-Schwarz/Cramér-Rao connection. The most promising cross-domain connection is the bridge between the Fisher metric (statistical manifolds) and optimization theory (natural gradient descent), which connects to the existing `InformationGeometryOptimization.lean` catalog entry.

The key mathematical insight is that **duality** — between exponential and mixture connections, between primal and dual Bregman divergences, between natural and expectation parameters — is the organizing principle of information geometry. This duality is algebraically captured by the Legendre transform and geometrically captured by the two flat connections. Future work should exploit this duality structure in three directions: (1) extending to curved statistical manifolds where the Pythagorean theorem fails, (2) connecting to optimal transport where a different duality (Kantorovich duality) governs, and (3) exploring quantum information geometry where non-commutativity introduces new phenomena.

The highest breakthrough potential lies in **Direction 1**: formalizing the Cramér-Rao efficiency gap for curved exponential families, which would quantify exactly how much efficiency is lost when the statistical curvature tensor is nonzero. This would connect our curvature tensor definition to concrete statistical applications and provide the first formalized version of Efron's (1975) theory of curved exponential families.

---

### Direction 1: Efficiency Loss in Curved Exponential Families

**Conjecture**: For a curved exponential family with statistical curvature tensor C, the maximum likelihood estimator achieves variance Var(θ̂) = 1/I(θ) + ‖C‖²/n² + O(1/n³), where ‖C‖² is the curvature norm defined in our `StatCurvatureTensor` structure.

**Test**: Construct a concrete 1-parameter curved exponential family (e.g., the location-scale family {N(θ, θ²) : θ > 0}), compute its statistical curvature tensor, and verify that the MLE variance matches the predicted formula for sample sizes n = 100, 1000, 10000 via Monte Carlo simulation.

**Impact**: If true, this gives the first formalized proof of Efron's asymptotic expansion for curved families, connecting the abstract curvature tensor to concrete estimation performance. If false, it would reveal that the curvature norm alone is insufficient and higher-order invariants are needed.

**Catalog References**: `Bridges/FisherMetric/Defs.lean` (StatCurvatureTensor), `Bridges/FisherMetric/Theorems.lean` (pythagorean_with_curvature_error), `Bridges/InformationGeometryOptimization.lean` (convergence_factor_bounds)

**Proof Strategy**: Define a curved exponential family as a submanifold of a full exponential family. Compute the induced metric and second fundamental form. The curvature tensor appears as the difference between the ambient Christoffel symbols and the projected ones. Taylor-expand the MLE around the true parameter and use the curvature tensor to control the second-order term.

**Domain Bridges**: Information geometry ↔ Mathematical statistics ↔ Differential geometry (second fundamental form)

**Lineage**: Builds on StatCurvatureTensor and pythagorean_with_curvature_error from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Bregman-Wasserstein Bridge via Convex Order

**Conjecture**: For probability distributions on Fin n, the Bregman divergence D_ψ(θ₁‖θ₂) with ψ = log-partition function satisfies D_ψ(θ₁‖θ₂) ≥ (1/2) · W₂(softmax(θ₁), softmax(θ₂))² where W₂ is the Wasserstein-2 distance with the discrete metric d(i,j) = |i-j|/n.

**Test**: Compute D_ψ and W₂ for 10,000 random pairs of 10-dimensional parameter vectors. Plot the ratio D_ψ/W₂². If any ratio falls below 0.5, the conjecture is false. If all ratios exceed 0.5, estimate the tight constant.

**Impact**: If true, this would establish a formal bridge between information geometry and optimal transport — two of the most active areas in modern applied mathematics. The connection would give new convergence guarantees for natural gradient methods via Wasserstein stability results.

**Catalog References**: `Bridges/FisherMetric/Theorems.lean` (wasserstein_fisher_conjecture), `Bridges/FisherMetric/Defs.lean` (DuallyFlatManifold, bregmanDiv)

**Proof Strategy**: Use the Talagrand inequality T₂ for log-concave measures. The softmax map produces a log-concave distribution when ψ is strongly convex, and T₂ gives exactly D_KL ≥ c·W₂². The challenge is computing the optimal constant c and showing c ≥ 1/2.

**Domain Bridges**: Information geometry ↔ Optimal transport ↔ Probability theory (concentration inequalities)

**Lineage**: Builds on wasserstein_fisher_conjecture from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Quantum Fisher Information and Non-Commutative Duality

**Conjecture**: The symmetric logarithmic derivative (SLD) Fisher information on quantum states (density matrices) defines a dually flat structure on the manifold of full-rank density matrices, where the two connections correspond to the SLD and right logarithmic derivative (RLD) metrics.

**Test**: Construct the 2×2 density matrix manifold (the Bloch ball). Compute the SLD and RLD metrics explicitly. Verify that they define dual connections in the sense of Amari. Check whether the Pythagorean theorem holds for projections onto the equator (maximally mixed states restricted to a basis).

**Impact**: If true, this would extend our DuallyFlatManifold formalization to quantum information theory, providing the geometric foundation for quantum state estimation, quantum channel capacity, and quantum Cramér-Rao bounds. The quantum case introduces genuinely new phenomena (the SLD and RLD metrics are different, unlike the classical case).

**Catalog References**: `Bridges/FisherMetric/Defs.lean` (DuallyFlatManifold), `Bridges/QuantumPythagoreanInformation.lean`

**Proof Strategy**: Define quantum states as positive semidefinite matrices with trace 1. Define the SLD Fisher metric via the Lyapunov equation G·L + L·G = 2·dG. Show this satisfies the metric tensor axioms. Construct the dual potential via the von Neumann entropy S(ρ) = -Tr(ρ log ρ). The key challenge is formalizing matrix logarithms in Lean.

**Domain Bridges**: Information geometry ↔ Quantum information theory ↔ Matrix analysis

**Lineage**: Extends DuallyFlatManifold to the non-commutative setting.

**Ambition**: extension

---

### Direction 4: Natural Gradient Convergence via Pythagorean Decomposition

**Conjecture**: For μ-strongly convex losses on a dually flat manifold with Fisher metric G, natural gradient descent with step size η = 1/(L_G) converges at rate O(exp(-μ_G/L_G · t)) where μ_G, L_G are the strong convexity and smoothness constants in the Fisher metric (not the Euclidean metric). The ratio μ_G/L_G is always at least as good as μ/L and can be exponentially better.

**Test**: Implement natural gradient descent for logistic regression. Compare convergence in terms of the condition number κ = L/μ (Euclidean) versus κ_G = L_G/μ_G (Fisher). For a synthetic dataset with condition number κ = 1000, verify that κ_G ≤ 10.

**Impact**: Would provide the first formalized proof that natural gradient descent has a provably better condition number than standard gradient descent for statistical models. This is widely observed empirically but lacks rigorous formalization.

**Catalog References**: `Bridges/InformationGeometryOptimization.lean` (NatGradDescent, natgrad_steepest_descent), `Bridges/FisherMetric/Theorems.lean` (pythagorean_dually_flat)

**Proof Strategy**: Use the Pythagorean theorem to decompose the Bregman divergence to the optimum. The key lemma is that the natural gradient step decreases the Bregman divergence by at least η·(f(θ) - f*) - η²L_G/2. Sum over T iterations and optimize η.

**Domain Bridges**: Information geometry ↔ Optimization theory ↔ Machine learning

**Lineage**: Combines pythagorean_dually_flat with natgrad_descent_progress from the catalog.

**Ambition**: extension

---

### Direction 5: Tropical Fisher Metric and Dequantization

**Conjecture**: The Fisher metric on the probability simplex has a well-defined tropical limit: as the temperature T → 0 in the softmax parameterization p_i = exp(θ_i/T)/Σexp(θ_j/T), the Fisher metric tensor G_ij(θ) converges (after rescaling by T²) to a piecewise-linear metric on the tropical simplex.

**Test**: Compute G_ij(θ) numerically for T = 1, 0.1, 0.01, 0.001 and a fixed θ. Plot T²·G_ij against the conjectured tropical limit (a piecewise-linear function depending on which θ_i is maximal).

**Impact**: Would establish a bridge between information geometry and tropical geometry, connecting the "temperature" of softmax to the Maslov dequantization. This could provide new insight into the sharp transition behavior of neural network training at low temperatures.

**Catalog References**: `Tropical/TropicalArithmeticCoding.lean` (tropical_and_bound), `Bridges/TropicalInformationGeometry.lean`, `Bridges/FisherMetric/Defs.lean`

**Proof Strategy**: Write G_ij in terms of softmax probabilities. As T → 0, the softmax concentrates on argmax(θ). In each region where a particular θ_i dominates, compute the limit of T²·G_ij explicitly. Show the limits match across region boundaries, giving a well-defined piecewise-linear metric.

**Domain Bridges**: Information geometry ↔ Tropical geometry ↔ Neural network optimization

**Lineage**: Connects Fisher metric to tropical geometry catalog entries.

**Ambition**: grand_challenge
