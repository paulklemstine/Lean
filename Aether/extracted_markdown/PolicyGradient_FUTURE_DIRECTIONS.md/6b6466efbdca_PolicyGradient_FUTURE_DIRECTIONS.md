# Future Directions — Policy Gradient Methods

## Synthesis

The new module `MachineLearning.PolicyGradient` formalizes the algebraic and
calculus core of **policy gradient reinforcement learning** in the finite-action
(contextual bandit / one-step MDP) setting, where the entire theory becomes
honest single-variable calculus over finite sums and can be proved
unconditionally. The unifying discovery is that one identity —
`score_expectation_zero`, the differentiated normalization constraint
`∂_θ ∑ₐ π_θ(a) = ∂_θ 1 = 0` — silently powers *both* baseline (control-variate)
invariance and the compatible function approximation theorem. From it we derive
the policy gradient theorem in score form (`𝔼[ψ(a) Q(a)]`), the REINFORCE
log-derivative trick, the exact-gradient property of compatible critics, the
identification of softmax scores with centered features, and an `O(1/ε)`
exploration-variance bound.

This sits naturally beside the catalog's value-side result,
`MachineLearning.FactoredBellmanResidual` (Bellman residual contraction and
finite-step value convergence). Together the actor (policy gradient) and the
critic (Bellman residual) form the two halves of actor–critic methods, and the
clearest next steps are bridges that fuse them.

## Results Summary

| Theorem | Statement |
|---|---|
| `score_expectation_zero` | `∑ₐ ∂_θ π_θ(a) = 0` (score has zero mean) |
| `objective_hasDerivAt` | `J(θ) = ∑ₐ π_θ(a) q(a)` differentiable, `J' = ∑ₐ π'_θ(a) q(a)` |
| `score_eq_deriv_log` | `∂_θ log π_θ(a) = π'_θ(a)/π_θ(a)` (REINFORCE trick) |
| `policy_gradient_theorem` | `J'(θ) = ∑ₐ π_θ(a) ψ(a) q(a) = 𝔼[ψ(a)Q(a)]` |
| `baseline_invariance` | subtracting any baseline `b` leaves `J'` unchanged |
| `compatible_function_approximation` | orthogonal critic gives the *exact* gradient |
| `softmax_score` | softmax score = centered feature `φ(a) − 𝔼_π[φ]` |
| `reinforce_variance_bound` | second moment of REINFORCE estimator is `O(1/ε)` |

## Research Directions

### 1. Multi-parameter policy gradient via the gradient (Fréchet) operator

Lift every result from `θ : ℝ` to `θ : EuclideanSpace ℝ (Fin d)` using
`HasFDerivAt` in place of `HasDerivAt`, so that the score becomes a genuine
gradient vector `∇_θ log π_θ(a) ∈ ℝ^d` and the compatible critic becomes a
*linear* map `w ↦ ⟨w, ψ(a)⟩`. The key insight is that all eight theorems are
already linear in the derivative slot, so each `HasDerivAt.sum`/`mul_const` step
has a verbatim `HasFDerivAt` analogue and `score_expectation_zero` becomes the
vanishing of a vector. Why now? The single-parameter file gives a verified
blueprint whose proof structure transfers mechanically, eliminating the usual
risk of getting lost in multivariate calculus API before the math is settled.
Falsifiable: if `softmax_score` fails to generalize to `ψ(a) = φ(a) − 𝔼_π[φ]`
with `φ : α → ℝ^d`, the centered-feature identity is special to `d = 1`.

### 2. The optimal baseline that minimizes gradient variance

Prove that among all constant baselines `b`, the variance
`∑ₐ π_θ(a) (ψ(a)(q(a) − b))²` is minimized at
`b⋆ = 𝔼[ψ² q] / 𝔼[ψ²]`, and that this strictly improves over `b = 0` whenever
`ψ` and `q` are correlated. The key insight is that `baseline_invariance`
already proves the *mean* is `b`-independent, so the variance is an exact
quadratic in `b` and its minimizer is pure calculus — differentiate and solve.
Why now? `baseline_invariance` plus `reinforce_variance_bound` give both the
unbiasedness and the second-moment scaffolding needed; only the quadratic
minimization remains. Falsifiable: if the minimizing `b⋆` does not equal the
`ψ²`-weighted mean of `q`, the standard "optimal baseline" formula is wrong in
the finite setting.

### 3. Actor–critic bridge: coupling policy gradient with Bellman residuals

Connect this module to `MachineLearning.FactoredBellmanResidual` by bounding the
*policy gradient bias* induced by an inexact critic: if the critic `cf`
satisfies a Bellman-residual bound `‖Qf − cf‖∞ ≤ δ`, then
`‖∑ₐ π_θ(a) ψ(a)(Qf − cf)(a)‖ ≤ δ · ∑ₐ π_θ(a)|ψ(a)|`. The key insight is that
`compatible_function_approximation` is the `δ = 0` corner of a Lipschitz
estimate, so the residual machinery of the catalog's value-side file controls
exactly the term that vanishes under compatibility. Why now? Both endpoints are
already formalized in the catalog; the bridge is a single Hölder/triangle
estimate that turns two isolated results into a quantitative actor–critic
theorem. Falsifiable: if no such bound holds, certified actor–critic convergence
from finite-step critic accuracy is impossible.

### 4. Monotone improvement and convergence of finite-step gradient ascent

Show that one gradient-ascent step `θ_{t+1} = θ_t + η J'(θ_t)` with small enough
`η` and a Lipschitz gradient yields `J(θ_{t+1}) ≥ J(θ_t)`, hence the iterates
reach an `ε`-stationary point in `O(1/ε²)` steps. The key insight is that the
descent lemma is itself a `HasDerivAt` + mean-value-inequality argument, and
`objective_hasDerivAt` already supplies the differentiability hypothesis it
needs. Why now? This is the literal "converges to a local optimum" claim of the
research brief, and the objective's derivative is now a proven, closed-form
finite sum, removing the analytic obstruction. Falsifiable: if monotone
improvement fails for the closed-form `J'`, the step-size/smoothness coupling
must be sharper than the classical descent lemma predicts.

### 5. Natural policy gradient and the Fisher information geometry

Define the Fisher information `F(θ) = ∑ₐ π_θ(a) ψ(a) ψ(a)ᵀ` and prove that the
*natural* gradient `F⁻¹ J'` is invariant under smooth reparameterizations of
`θ`, with softmax giving `F` equal to the policy-weighted feature covariance.
The key insight is that `softmax_score` already identifies `ψ` as the centered
feature, so `F` is literally `Cov_π(φ)` and its positive-semidefiniteness is a
variance, not a hard spectral fact. Why now? With the score and its centered
form proved, the Fisher matrix is assembled from existing pieces, and natural
gradient — the bridge from policy gradient to information geometry — becomes
reachable. Falsifiable: if `F` for softmax is not the feature covariance
`𝔼_π[φφᵀ] − 𝔼_π[φ]𝔼_π[φ]ᵀ`, the information-geometric reading of natural
policy gradient breaks in the finite setting.
