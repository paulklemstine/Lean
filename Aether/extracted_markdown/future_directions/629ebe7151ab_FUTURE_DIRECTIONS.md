# Future Directions: Natural Gradient Convergence on Dually Flat Manifolds

## Synthesis

The formal convergence theory established here — telescoping Bregman descent, free energy dissipation, O(log(t)/t) rates with harmonic steps — creates a foundation for three major research thrusts. First, the *acceleration question*: can we formally prove O(1/t²) convergence for the dual-coordinate Nesterov method on dually flat manifolds? Second, the *thermodynamic bridge*: can the discrete entropy production theorem be extended to a formal framework for non-equilibrium statistical mechanics? Third, the *scalability question*: can we formalize natural gradient convergence for infinite-dimensional exponential families (Gaussian processes, neural networks)? Each direction builds directly on the proven theorems and introduces falsifiable predictions that can guide the next cycle of formalization.

---

## Direction 1: Accelerated Convergence in Dual Coordinates

**Conjecture.** For any minimal finite exponential family with log-partition ψ and any loss L̃ that is convex and β-smooth in expectation coordinates η, the accelerated dual natural gradient method with step sizes α_t = 2/(t+2) and momentum β_t = t/(t+3) satisfies:

$$L(\theta_t) - L(\theta^*) \leq \frac{2\beta \|\eta_0 - \eta^*\|^2}{(t+1)^2}$$

**Test.** Generate 1000 random trinomial and quadrinomial exponential families with random L-smooth convex losses in η-coordinates. Run the accelerated dual NGD for T=10000 iterations. Fit log(excess loss) vs log(t) by linear regression. The conjecture is *falsified* if the median slope is significantly greater than -2.0 (i.e., convergence slower than O(1/t²)) across the ensemble.

**Impact.** A formal proof would be the first machine-verified O(1/t²) convergence theorem in non-Euclidean geometry, establishing that Nesterov acceleration transfers intact from flat space to dually flat manifolds via the Legendre transform.

**Catalog References.**
- `Geometry/InformationGeometry/Theorems.lean`: `logPartition_convex` (generates the Bregman geometry)
- `Geometry/InformationGeometry/NaturalGradient/Convergence.lean`: `telescope_descent_bound`, `convergence_harmonic_step`

**Proof Strategy.** Define the Lyapunov function V_t = (t+1)²(L̃(η_t) - L̃(η*)) + 2β‖η_t - η*‖² and prove V_{t+1} ≤ V_t by the three-point identity for Bregman divergences. This reduces to algebraic manipulation of the Nesterov coefficients.

**Domain Bridges.** Optimization theory → Information geometry → Convex analysis

**Lineage.** Extends `convergence_harmonic_step` (this work) and Nesterov (1983).

**Ambition.** Grand challenge — would unify acceleration theory with information geometry.

---

## Direction 2: Non-Acceleration Barrier for Plain Natural Gradient

**Conjecture.** There exists a minimal finite exponential family (d ≥ 2) and a convex loss L̃ in expectation coordinates such that natural gradient descent with harmonic steps α_t = 1/(t+1) satisfies:

$$\liminf_{t \to \infty} \frac{t \cdot (L(\theta_t) - L(\theta^*))}{1} > 0$$

That is, the O(1/t) rate is *tight* and cannot be improved to o(1/t) without acceleration.

**Test.** Construct the loss L̃(η) = η₁² + 100η₂² (high condition number) on a trinomial family. Run natural GD with harmonic steps for T=10⁶ iterations. Compute t·e(t) and verify it does not converge to zero. The conjecture is falsified if t·e(t) → 0 for this or similar examples.

**Impact.** A formal proof would establish a separation between plain natural gradient and accelerated methods, providing rigorous justification for the more complex dual-coordinate scheme.

**Catalog References.**
- `Geometry/InformationGeometry/NaturalGradient/Convergence.lean`: `convergence_harmonic_step`

**Proof Strategy.** Construct an explicit lower bound on the recurrence e(t+1) ≥ c·t/(t+1)·e(t) for an appropriately chosen loss, showing that t·e(t) is bounded below by a positive constant.

**Domain Bridges.** Optimization theory ↔ Lower bound theory ↔ Information geometry

**Lineage.** Extends the upper bound in `convergence_harmonic_step` with a matching lower bound.

**Ambition.** Solid extension — barrier results are foundational for understanding method limitations.

---

## Direction 3: Continuous-Time Natural Gradient Flow and Entropy Production

**Conjecture.** The natural gradient flow dθ/dt = -I(θ)⁻¹∇L(θ) on a minimal exponential family satisfies the entropy production identity:

$$\frac{d}{dt} D_\psi(\theta^*, \theta(t)) = -(L(\theta(t)) - L(\theta^*)) - \|\nabla_\eta L̃(\eta(t))\|_{I(\theta(t))^{-1}}^2$$

Furthermore, the flow converges exponentially fast under geodesic strong convexity of L.

**Test.** Numerically integrate the natural gradient ODE for trinomial models using RK4 with step h=10⁻⁴. Compute d/dt D_ψ numerically and compare with the right-hand side. The identity is falsified if the discrepancy exceeds 10⁻³ at any point along the trajectory (after accounting for discretization error).

**Impact.** A formal proof would establish the natural gradient flow as a gradient flow in the Wasserstein-Fisher-Rao geometry, connecting information geometry to optimal transport and thermodynamics.

**Catalog References.**
- `Geometry/InformationGeometry/NaturalGradient/Convergence.lean`: `bregman_nonincreasing` (discrete analog)
- `Geometry/InformationGeometry/Theorems.lean`: `fisherMatrix_posSemidef`

**Proof Strategy.** Differentiate D_ψ(θ*, θ(t)) using the chain rule and the identity ∇²ψ = I(θ). The key is that d/dt ψ(θ) = ⟨∇ψ(θ), dθ/dt⟩ and the Fisher metric converts between primal and dual representations.

**Domain Bridges.** Information geometry → ODE theory → Statistical mechanics → Optimal transport

**Lineage.** Continuous-time limit of `bregman_nonincreasing`.

**Ambition.** Grand challenge — would formalize the thermodynamic interpretation of machine learning.

---

## Direction 4: Fisher Positive Definiteness from Minimality

**Conjecture.** For a minimal finite exponential family (sufficient statistics T₁, ..., T_d are affinely independent over the support), the Fisher information matrix I(θ) is strictly positive definite for all θ in the natural parameter space.

**Test.** Generate random exponential families with d=3 dimensions and K=5 sample points. Check the minimality condition (rank of sufficient statistic matrix = d). For minimal families, compute the smallest eigenvalue of I(θ) at 1000 random θ values. The conjecture is falsified if any eigenvalue is ≤ 0 for a verifiably minimal family.

**Impact.** Upgrading PSD to PD is essential for defining the natural gradient (requires I⁻¹). This is the gap between `fisherMatrix_posSemidef` and the invertibility needed for practical natural gradient.

**Catalog References.**
- `Geometry/InformationGeometry/Theorems.lean`: `fisherMatrix_posSemidef`, `fisher_eq_sufficientStatCov`

**Proof Strategy.** By `fisher_eq_sufficientStatCov`, I(θ) = Cov(T). For a minimal family, v'Cov(T)v = 0 iff v'T is a.s. constant, which contradicts affine independence of T. Hence I(θ) is positive definite.

**Domain Bridges.** Information geometry → Linear algebra → Statistics

**Lineage.** Direct strengthening of `fisherMatrix_posSemidef`.

**Ambition.** Solid extension — fills a critical gap in the formal infrastructure.

---

## Direction 5: KL Divergence as Bregman Divergence and Variational Inference Guarantees

**Conjecture.** For the multinomial exponential family, the Bregman divergence generated by the log-partition function ψ(θ) = log(∑ exp(θᵢ) + 1) coincides with the KL divergence KL(p_{θ*} ‖ p_θ). Combined with the convergence theorems, this gives explicit finite-time convergence guarantees for natural gradient variational inference:

$$\text{KL}(p^* \| p_{\theta_t}) \leq \frac{B + A \cdot H(t)}{t}$$

**Test.** For 100 random trinomial models, compute both D_ψ(θ*, θ_t) and KL(p_{θ*} ‖ p_{θ_t}) along the natural gradient trajectory. Verify they agree to machine precision. The conjecture is falsified if they differ by more than 10⁻¹⁰ at any point.

**Impact.** Establishes a direct, formally verified connection between information geometry and Bayesian inference, giving the first machine-checked convergence rate for variational inference in exponential families.

**Catalog References.**
- `Geometry/InformationGeometry/NaturalGradient/Defs.lean`: `BregmanDiv`
- `Geometry/InformationGeometry/NaturalGradient/Convergence.lean`: `convergence_harmonic_step`, `bregmanDiv_nonneg`
- `Geometry/InformationGeometry/Defs.lean`: `logPartition`, `ExponentialFamily`

**Proof Strategy.** Direct computation: D_ψ(θ*, θ) = ψ(θ*) - ψ(θ) - ⟨∇ψ(θ), θ*-θ⟩. For exponential families, ψ(θ*) - ψ(θ) - ⟨η(θ), θ*-θ⟩ = ∑ p_{θ*}(ω) log(p_{θ*}(ω)/p_θ(ω)) by direct expansion of the exponential form.

**Domain Bridges.** Information geometry → Bayesian statistics → Machine learning → Variational inference

**Lineage.** Combines `logPartition_convex`, `BregmanDiv`, and `convergence_harmonic_step`.

**Ambition.** Solid extension — the KL=Bregman identity is well-known but has never been formalized.
