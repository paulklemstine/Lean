# Future Directions: EML Fixed-Point Theory

## Synthesis

This cycle established the foundational contraction theory for the EML operator f(x) = e^a · log(x + c), proving derivative bounds, Lipschitz estimates via MVT, uniqueness of fixed points, geometric convergence at rate ρ = e^a/(L+c), and a composition theorem for cascaded EML layers. The most promising cross-domain connection discovered is the **bridge between EML contraction theory and the General C¹ Contraction Principle**: any smooth map with bounded derivative is automatically Lipschitz, and the EML case is the canonical example with an explicitly computable, monotonically decaying derivative.

The composition theorem (Theorem 3.8) opens a direct path to neural network convergence certification: a deep feedforward network of EML layers has contraction ratio equal to the product of layer ratios. This multiplicative structure mirrors the spectral radius theory of linear operators, suggesting a deeper algebraic connection between EML dynamics and operator semigroup theory (linking to `contraction_convergence_rate` in `Algebra/SpectralArithmetic/Core.lean`).

The most high-impact direction is **Direction 1** (Invariant Interval Existence), which would close the main gap in the current theory — the assumption that iterates stay in the contraction domain. This would yield a fully self-contained convergence theorem requiring only parameter conditions, with no auxiliary hypotheses on trajectories.

---

### Direction 1: EML Invariant Interval Existence and Banach Complete Convergence

**Conjecture**: For all a ∈ (0, log(1 + c)) with c > 0, there exists an interval [L, U] ⊂ (−c, ∞) such that the EML operator f(x) = e^a · log(x + c) maps [L, U] into itself, and e^a < L + c (contraction condition). Specifically, L and U can be chosen as the two solutions of e^a · log(x + c) = x when they exist, with the fixed point x* lying between them.

**Test**: For a = 0.5, c = 1.0, verify computationally that the equation e^0.5 · log(x + 1) = x has solutions bounding the fixed point x* ≈ 1.143. Then prove in Lean 4 that f([L, U]) ⊆ [L, U] using monotonicity of f and the intermediate value theorem.

**Impact**: Removes the `hiter` hypothesis from `eml_iteration_convergence`, yielding a clean theorem: "For a ∈ (0, log(1+c)), the EML iteration converges to a unique fixed point from any starting point in the invariant interval." This would be a complete, practical convergence certificate.

**Catalog References**: `EML/FixedPoint.lean` (this cycle), `contraction_fixed_point_unique` in `EML/SocialCreditDynamics.lean`

**Proof Strategy**: (1) Show f is concave on (−c, ∞) by computing f''(x) = −e^a/(x+c)² < 0. (2) Use concavity + continuity to prove that the graph of f crosses y = x at most twice. (3) If f(L₀) > L₀ and f(U₀) < U₀ for suitable L₀, U₀, then by IVT and monotonicity, f maps [L₀, U₀] into itself. (4) Apply the existing `eml_fixed_point_unique` and `eml_iteration_convergence`.

**Domain Bridges**: EML Contraction Theory ↔ Dynamical Systems (invariant sets, attracting basins)

**Lineage**: Builds on `eml_iteration_convergence` and `emlFun_lipschitz_on_Ici` from this cycle.

**Ambition**: extension

---

### Direction 2: Tropical Limit of EML Fixed Points as a → ∞

**Conjecture**: As a → ∞ with c fixed, the rescaled fixed point x*(a)/e^a converges to a limit that satisfies the tropical (min-plus) fixed-point equation. Specifically, if we define z(a) = x*(a)/e^a, then lim_{a→∞} z(a) = log(c) (the tropical logarithm of c). The contraction ratio ρ(a) → 1 as a → ∞, and the convergence transitions from geometric to algebraic.

**Test**: Compute x*(a)/e^a numerically for a = 1, 2, 5, 10, 20 with c = 1. Check whether the sequence approaches log(1) = 0. If not, find the correct scaling and limit.

**Impact**: Establishes a rigorous bridge between EML contraction dynamics and tropical algebra, the "dequantization" of classical mathematics. This would connect the catalog's EML results to the tropical computing strand (`MachineLearning/TropicalCTC.lean`, `Tropical/` family).

**Catalog References**: `contraction_unique_fixed_point` in `MachineLearning/TropicalCTC.lean`, `EML/FixedPoint.lean`

**Proof Strategy**: (1) From the exponential form exp(x*/e^a) = x* + c, substitute z = x*/e^a to get exp(z) = z·e^a + c. (2) For large a, the z·e^a term dominates, so z ≈ c·e^{-a} → 0. But x* ≈ e^a · log(c + e^a · z) ≈ e^a · a for large a. Careful asymptotic expansion needed. (3) Formalize the limit using Lean 4's `Filter.Tendsto` framework.

**Domain Bridges**: EML Fixed-Point Theory ↔ Tropical Algebra (min-plus semirings, dequantization)

**Lineage**: Builds on `eml_fixed_point_exp_form` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: EML Operator Semigroup and Spectral Theory

**Conjecture**: The set of EML operators {T_{a,c} : a > 0, c > 0} forms a semigroup under composition (with appropriate parameter transformations), and the "spectral radius" of this semigroup — defined as the infimum of n-th root contraction ratios — equals the contraction ratio at the fixed point, ρ = |f'(x*)|. Moreover, this spectral radius satisfies a variational formula analogous to the Gelfand formula for linear operators.

**Test**: (1) Verify computationally that composing T_{a₁,c₁} with T_{a₂,c₂} gives a function of the form e^{a₃} · log(g(x)) where g is not linear — so the semigroup is NOT closed in the EML family. (2) Check whether the contraction ratio of T^n (n-fold self-composition) satisfies ρ(T^n) = ρ(T)^n exactly. (3) If not, investigate whether lim ρ(T^n)^{1/n} = |f'(x*)|.

**Impact**: Would establish EML operators as a nonlinear analogue of bounded linear operators on Banach spaces, with a coherent spectral theory. The Gelfand formula for nonlinear contractions would be a novel result in nonlinear functional analysis.

**Catalog References**: `contraction_convergence_rate` in `Algebra/SpectralArithmetic/Core.lean`, `eml_composition_contraction_ratio` from this cycle

**Proof Strategy**: (1) Compute T^n explicitly by induction. (2) Show that T^n has contraction ratio at most ρ^n (already proved). (3) For the lower bound, exhibit sequences where |T^n(x) - T^n(y)| / |x - y| → ρ^n. (4) Take n-th roots and send n → ∞.

**Domain Bridges**: EML Dynamics ↔ Operator Algebra (semigroup theory, spectral radius)

**Lineage**: Builds on `eml_composition_contraction_ratio` and `general_C1_contraction_on_Icc` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Parametric Sensitivity and Implicit Function Theorem for EML Fixed Points

**Conjecture**: The fixed point x*(a, c) of the EML operator is a smooth function of the parameters (a, c) in the contraction region {(a,c) : a < log(x* + c)}. Specifically, ∂x*/∂a = x* · (x* + c) / (x* + c − e^a) and ∂x*/∂c = e^a / (x* + c − e^a), obtained by implicit differentiation of x* = e^a · log(x* + c).

**Test**: Verify numerically that the finite-difference approximation of ∂x*/∂a matches the formula above for a = 0.5, c = 1.0. Then prove the formula in Lean 4 using HasDerivAt for implicit functions.

**Impact**: Enables gradient-based optimization of EML network parameters with certified derivatives. This is the key ingredient for backpropagation through EML layers with convergence guarantees.

**Catalog References**: `EML/FixedPoint.lean`, `eml_gradient_log_bounded` in `EML/EMLNeuralNetworks.lean`

**Proof Strategy**: (1) Define F(a, c, x) = e^a · log(x + c) − x. (2) At the fixed point, F = 0 and ∂F/∂x = e^a/(x+c) − 1 = ρ − 1 ≠ 0 (since ρ < 1). (3) Apply the Implicit Function Theorem to get smoothness of x*(a,c). (4) Compute partial derivatives by implicit differentiation.

**Domain Bridges**: EML Fixed-Point Theory ↔ Optimization (gradient computation, sensitivity analysis)

**Lineage**: Builds on `eml_fixed_point_exp_form` and `emlFun_hasDerivAt` from this cycle.

**Ambition**: extension

---

### Direction 5: Complex EML Dynamics and Julia Sets

**Conjecture**: For the complex EML operator f(z) = e^a · Log(z + c) where Log is the principal branch, the Julia set (boundary of the basin of attraction of the fixed point) is connected when a < log(|z* + c|) and totally disconnected when a exceeds a critical value a_crit(c). This parallels the Mandelbrot-Julia correspondence for z² + c.

**Test**: Plot the basin of attraction numerically for c = 1 and several values of a ∈ (0, 3). Look for the connectivity transition. Estimate a_crit empirically.

**Impact**: Would establish the first rigorous connection between EML dynamics and holomorphic dynamics / fractal geometry. The EML family would join z² + c as one of the few families with completely understood bifurcation structure.

**Catalog References**: `EML/FixedPoint.lean`, `emlContractionRatio_lt_one`

**Proof Strategy**: (1) Extend the contraction analysis to ℂ using the complex derivative |f'(z)| = e^a / |z + c|. (2) The contraction region in ℂ is {z : |z + c| > e^a}, a disk complement. (3) Use Montel's theorem and the classification of Fatou components to analyze the Julia set. (4) The connectivity transition should occur at the parameter value where the critical point z = −c escapes to infinity.

**Domain Bridges**: EML Dynamics ↔ Complex Dynamics (Julia sets, Mandelbrot set, holomorphic iteration)

**Lineage**: Builds on the real contraction analysis from this cycle, extending to the complex plane.

**Ambition**: grand_challenge
