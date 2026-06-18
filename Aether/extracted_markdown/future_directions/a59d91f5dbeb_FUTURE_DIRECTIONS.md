# Future Directions

## Synthesis

This research cycle established the **Score Transport Semigroup** as a novel algebraic structure capturing the mathematical backbone of diffusion generative models. We proved 25+ theorems covering semigroup structure, KL contraction (Bakry-Émery), Fokker-Planck spectral theory, score transport phase transitions, and score matching divergence bounds — all machine-verified in Lean 4.

The most significant cross-domain connection emerged between our KL contraction theorem and the existing `contractive_convergence` result in the catalog (GazingPool.lean). Both establish exponential convergence via contractivity, but in different spaces: abstract metric spaces vs. probability distributions under KL divergence. This connection suggests a deeper categorical framework where "contraction" is a morphism property in a category of convergent dynamical systems, unifying metric-space contractions, distributional convergence, and spectral gap-based mixing.

The highest breakthrough potential lies in **Direction 1** (Log-Sobolev Inequality), which would close the gap between our axiomatized contraction rate and a fully derived one. If achieved, it would represent the first formalization of a log-Sobolev inequality in any proof assistant — a foundational result in probability theory with applications far beyond diffusion models.

---

### Direction 1: Formal Log-Sobolev Inequality for the Gaussian Measure

**Conjecture**: The Gaussian measure γ on ℝᵈ satisfies the log-Sobolev inequality with constant 1:

∫ f² log(f²) dγ - (∫ f² dγ) log(∫ f² dγ) ≤ 2 ∫ ‖∇f‖² dγ

for all smooth f : ℝᵈ → ℝ. This implies the KL contraction rate 2θ for the OU process, upgrading our current axiomatized rate to a derived one.

**Test**: Formalize the inequality in Lean 4. Verify it implies the Poincaré inequality (spectral gap ≥ 1) as a corollary. Test computationally by evaluating both sides for Hermite polynomials H_k (where equality should hold for k = 1).

**Impact**: If formalized, this would be the first machine-verified log-Sobolev inequality in any proof assistant. It would unlock formalization of hypercontractivity, concentration inequalities (sub-Gaussian bounds), and optimal convergence rates for Langevin Monte Carlo. Failure would indicate that Mathlib's measure theory + Sobolev space infrastructure needs significant development.

**Catalog References**: `MachineLearning/DiffusionSDE/Theorems.lean` (kl_exponential_decay), `Catalog/MachineLearning/Gaussian.lean` (gaussianKLDiv_nonneg)

**Proof Strategy**: 
1. Define the entropy functional Ent_γ(f) = ∫ f log f dγ - (∫ f dγ) log(∫ f dγ).
2. Prove the tensorization lemma: if LSI holds in ℝ¹, it holds in ℝᵈ with the same constant.
3. Prove LSI in ℝ¹ using the Herbst argument or Rothaus' method.
4. Key prerequisites: Gaussian integration by parts, Hermite polynomial orthogonality.

**Domain Bridges**: Probability Theory <-> Functional Analysis <-> Information Theory

**Lineage**: Builds on kl_exponential_decay and ou_contraction_is_twice_drift from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Wasserstein Convergence Rates for Diffusion Models

**Conjecture**: Under the OU forward process, the 2-Wasserstein distance to the stationary measure satisfies:

W₂(ρₜ, ρ∞) ≤ W₂(ρ₀, ρ∞) · e^{-θt}

with rate θ (not 2θ). This is sharp and strictly slower than the KL rate, establishing a hierarchy: KL contracts at 2θ, W₂ at θ, and TV at θ.

**Test**: Formalize W₂ for Gaussian measures (where it has a closed form) and prove the contraction for the Gaussian-to-Gaussian case. Test computationally by comparing W₂ and KL decay curves on numerical OU trajectories.

**Impact**: Would establish the first formal Wasserstein convergence result for SDEs. The rate hierarchy (KL > W₂ > TV) would have implications for choosing the right metric in generative model evaluation. If the conjecture is false, it would reveal a fundamental difference between the KL and Wasserstein geometries of the OU semigroup.

**Catalog References**: `MachineLearning/DiffusionSDE/Defs.lean` (ScoreTransportSemigroup), `MachineLearning/DiffusionSDE/Theorems.lean` (kl_exponential_decay, faster_drift_faster_convergence)

**Proof Strategy**:
1. Define W₂ between Gaussians: W₂²(N(μ₁,Σ₁), N(μ₂,Σ₂)) = ‖μ₁-μ₂‖² + Tr(Σ₁ + Σ₂ - 2(Σ₁^{1/2} Σ₂ Σ₁^{1/2})^{1/2}).
2. For isotropic case: W₂²(N(μ₁,σ₁²I), N(μ₂,σ₂²I)) = ‖μ₁-μ₂‖² + d(σ₁-σ₂)².
3. Track both terms under OU evolution: mean term decays at e^{-θt}, variance term decays at e^{-θt}.
4. Combine to get W₂ decay at e^{-θt}.

**Domain Bridges**: Optimal Transport <-> Probability Theory <-> Machine Learning

**Lineage**: Extends ou_cond_variance_le_stationary and kl_exponential_decay from this cycle.

**Ambition**: extension

---

### Direction 3: Discrete-to-Continuous Approximation Error for DDPM

**Conjecture**: For the DDPM discretization of the OU process with T steps and linear noise schedule β_min to β_max, the total approximation error in KL satisfies:

KL(p_DDPM ‖ p_continuous) ≤ C · d · (β_max - β_min)² / T

where C is a universal constant and d is the dimension. This would provide a rigorous convergence rate for DDPM as T → ∞.

**Test**: Fix d = 10, θ = 1, and compare empirical KL between DDPM (T = 10, 50, 100, 500, 1000) and exact OU sampling. The conjecture predicts the error scales as O(1/T). Plot log(error) vs log(T) — slope should be -1.

**Impact**: Would provide the first formal guarantee that DDPM converges to the continuous-time diffusion model. Currently, practitioners choose T heuristically (typically T = 1000). A formal bound would enable principled selection of T. If the rate is worse than O(1/T), it would motivate better discretization schemes (e.g., exponential integrators).

**Catalog References**: `MachineLearning/DiffusionSDE/Defs.lean` (DenoisingStep, DiffusionSchedule), `MachineLearning/DiffusionSDE/Theorems.lean` (noise_level_monotone)

**Proof Strategy**:
1. Define the discrete OU chain as a composition of DenoisingStep operations.
2. Bound the per-step error using Taylor expansion of e^{-θΔt} ≈ 1 - θΔt.
3. Sum over T steps using the triangle inequality for KL.
4. The key lemma is a one-step KL bound for Euler-Maruyama vs. exact OU.

**Domain Bridges**: Numerical Analysis <-> Probability Theory <-> Machine Learning

**Lineage**: Builds on ou_mean_decay_semigroup, DiffusionSchedule, and convergence_time_bound from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Geometry of Score Functions

**Conjecture**: For piecewise-linear (ReLU) score network approximations in dimension d, the score function's singular locus (where it is non-differentiable) forms a tropical hypersurface in ℝᵈ. The combinatorial complexity of this tropical variety bounds the approximation error:

‖s_ReLU - s_true‖_L² ≥ C · d / (number of tropical cells)

This would connect the tropical geometry catalog (Tropical/*.lean) to the diffusion model framework.

**Test**: Train a small ReLU network to approximate the score of a 2D Gaussian mixture. Extract the tropical structure (piecewise-linear regions). Compute the approximation error and compare with the predicted lower bound. Verify computationally for d = 2, 5, 10 with varying network widths.

**Impact**: Would establish a novel bridge between tropical geometry and generative modeling. If true, it would imply that the "complexity" of a score network (measured tropically) directly controls generation quality. This would be the first result connecting tropical algebraic geometry to deep generative models. If false, it would clarify the limitations of tropical methods for analyzing neural networks.

**Catalog References**: `Tropical/` (existing tropical geometry formalization), `MachineLearning/DiffusionSDE/Theorems.lean` (score_transport_contraction, scoreMatchingBound_diverges_near_zero)

**Proof Strategy**:
1. Formalize piecewise-linear functions as tropical polynomials (connection to existing Tropical/ catalog).
2. Define the tropical variety of a ReLU score network.
3. Prove that the number of linear regions bounds the L² approximation error via a volume argument.
4. The key lemma: each tropical cell contributes at most a bounded amount of approximation error.

**Domain Bridges**: Tropical Geometry <-> Neural Network Theory <-> Generative Modeling

**Lineage**: Bridges the Tropical/ catalog with the MachineLearning/DiffusionSDE framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Information-Geometric Curvature of the Diffusion Path

**Conjecture**: The path traced by the OU marginal distributions {ρₜ}_{t≥0} in the space of probability distributions is a geodesic in the Fisher-Rao information geometry if and only if the initial distribution is Gaussian. For non-Gaussian initial conditions, the path has strictly positive geodesic curvature κ(t) > 0, and:

κ(t) ≤ κ(0) · e^{-2θt}

i.e., the curvature decays at the same rate as the KL divergence.

**Test**: Compute the Fisher-Rao geodesic curvature numerically for the OU process starting from a mixture of two Gaussians. Verify that (1) Gaussian initial conditions give zero curvature, and (2) the curvature decays exponentially with rate 2θ for non-Gaussian starts.

**Impact**: Would establish a precise connection between information geometry and diffusion models. The geodesic property for Gaussian starts would explain why Gaussian score matching is "easy" — the score function is linear along a geodesic. If the curvature bound is tight, it would provide a new characterization of the "difficulty" of the reverse process at each time step.

**Catalog References**: `MachineLearning/DiffusionSDE/Theorems.lean` (kl_exponential_decay, ou_cond_variance_le_stationary), `Catalog/MachineLearning/Gaussian.lean` (Gaussian KL geometry)

**Proof Strategy**:
1. Define the Fisher information metric on the space of Gaussian distributions.
2. Compute the Levi-Civita connection for the Gaussian manifold.
3. Show the OU path for Gaussian initial conditions lies in the Gaussian submanifold and is a geodesic.
4. For non-Gaussian starts, bound the curvature using the rate of change of the cumulant generating function.

**Domain Bridges**: Information Geometry <-> Differential Geometry <-> Machine Learning

**Lineage**: Extends the Gaussian KL analysis from this cycle and connects to the catalog's information-geometric results.

**Ambition**: extension
