# Future Directions — Policy Gradient Reinforcement Learning

## Synthesis

This cycle formalized the differential backbone of policy-gradient reinforcement
learning on a finite action space, entirely from `HasDerivAt` first principles, with
**zero `sorry`** and only the standard axioms (`propext`, `Classical.choice`,
`Quot.sound`).  Two files were produced.

`Theorem.lean` proves the **policy gradient theorem** in score form
(`policy_gradient_theorem`: `∇_θ J = E_{a∼π}[R(a)∇_θ log π]`), the **Bartlett identity**
that the expected score vanishes (`expected_score_zero`, descending from the single
conservation law `score_sum_zero` obtained by differentiating `∑ π = 1`), the
**unbiasedness of REINFORCE with an arbitrary constant baseline**
(`reinforce_baseline_unbiased`), and the **nonnegativity of the Fisher information**
together with its identification as the variance of the score
(`fisher_information_nonneg`, `fisher_eq_variance_of_centered`).

`NaturalGradient.lean` isolates the *geometric* content of the natural policy gradient.
The Fisher matrix enters only as a symmetric positive-semidefinite bilinear form, and
the whole "steepest ascent under the Fisher metric" story collapses to a single
**generalized Cauchy–Schwarz inequality** (`bilin_cauchy_schwarz`, proved by the
discriminant of `t ↦ B(x − t·y, x − t·y) ≥ 0`).  From it we derive that the natural
gradient maximizes the return increase per unit Kullback–Leibler movement
(`natural_gradient_steepest_ascent`, `natural_gradient_unit_ball_bound`,
`natural_gradient_tight`), and that — when the Fisher form is positive definite — the
natural and vanilla gradients share *exactly* the same stationary points
(`natural_vanilla_same_stationary`).  The cross-link `localMax_score_weighted_return_zero`
ties this back to optimization: at any local optimum of the expected return the policy
gradient (hence the population REINFORCE update) is zero.

## Results summary

| Theorem | Statement |
|---|---|
| `score_sum_zero` / `expected_score_zero` | Bartlett identity: `E_{a∼π}[∇ log π] = 0` |
| `policy_gradient_theorem` | `∇J = E_{a∼π}[R·∇ log π]` |
| `reinforce_baseline_unbiased` | baselines never bias the gradient |
| `fisher_information_nonneg` / `fisher_eq_variance_of_centered` | `F ≥ 0`, `F = Var(score)` |
| `bilin_cauchy_schwarz` | generalized Cauchy–Schwarz for symmetric PSD forms |
| `natural_gradient_steepest_ascent` / `..._unit_ball_bound` | natural gradient is Fisher-steepest |
| `natural_vanilla_same_stationary` | natural & vanilla PG share stationary points |
| `localMax_score_weighted_return_zero` | first-order optimality of the expected return |

## Bold, falsifiable research directions

### 1. The exact descent lemma: monotone improvement of natural gradient under an L-smooth return

Conjecture: if the expected return `J` has an `L`-Lipschitz gradient in the Fisher metric,
then a natural-gradient step `θ⁺ = θ + η·F(θ)⁻¹∇J(θ)` with `η ≤ 1/L` satisfies the strict
ascent bound `J(θ⁺) ≥ J(θ) + (η/2)·⟨∇J, F⁻¹∇J⟩`, and iterating drives `⟨∇J, F⁻¹∇J⟩ → 0`,
i.e. convergence to a stationary point at rate `O(1/T)`.  The key insight is that
`natural_gradient_steepest_ascent` already gives the per-step *first-order* gain
`⟨∇J, F⁻¹∇J⟩ = grad nat`; the only missing ingredient is a second-order (descent-lemma)
control of the remainder, which is a one-dimensional Taylor estimate along the step.
**Why now?** The steepest-ascent inequality and the Fisher-as-PSD-form abstraction are now
formalized, so the descent lemma can be stated against `bilin_cauchy_schwarz` and
`natural_gradient_steepest_ascent` directly rather than rebuilding the geometry.

### 2. KL is the Fisher quadratic form to second order (Bartlett ⇒ Riemannian metric)

Conjecture: for the finite-action softmax family, the Kullback–Leibler divergence
`KL(π_θ ‖ π_{θ+δ})` equals `½·F(θ)·δ² + o(δ²)`, with the *same* `F` defined in
`fisherInformation`.  The key insight is that the first-order term of KL vanishes for
exactly the reason the expected score vanishes (`expected_score_zero`), so the Hessian of
KL at the diagonal is forced to be the score's second moment — the Fisher information.
**Why now?** `expected_score_zero` and `fisher_eq_variance_of_centered` already pin down
the first two moments of the score; the KL expansion is the analytic completion that turns
"Fisher information" from a definition into the verified metric tensor of the policy
manifold, justifying the word "geometry" in the title.

### 3. Strict variance reduction from the optimal baseline

Conjecture: among all constant baselines `b`, the REINFORCE gradient estimator's variance
`Var_{a∼π}[(R(a) − b)·∇ log π]` is minimized at a unique `b* = E[s²R]/E[s²]` (a
score-weighted average return), and `b = 0` is optimal **iff** the score and `R·score` are
uncorrelated.  The key insight is that `reinforce_baseline_unbiased` makes the *mean*
independent of `b`, so the baseline is a pure variance knob, and minimizing a quadratic in
`b` has a closed-form vertex.  **Why now?** Unbiasedness-for-every-`b` is already proved;
the natural adversarial follow-up ("does the baseline ever *hurt*?") is a falsifiable
optimization over a one-parameter family that the present file's score machinery supports
verbatim.

### 4. Degenerate Fisher directions are reward-flat (boundary stress test)

Conjecture: if the Fisher form is only positive *semi*definite and `F·v = 0` for some
`v ≠ 0`, then the directional derivative of the return along `v` is itself zero,
`∇J · v = 0` — a degenerate KL direction can never improve the return.  The key insight is
that `natural_gradient_steepest_ascent` already yields `(∇J·v)² ≤ (grad nat)·(B v v)` and
`B v v = 0` collapses the bound to `∇J·v = 0`, so the claim is a corollary awaiting
isolation.  **Why now?** Our steepest-ascent theorem was deliberately proved for *PSD*
(not just PD) forms; this direction cashes in that generality to characterize exactly when
positive-definiteness of `F` (the hypothesis of `natural_vanilla_same_stationary`) can be
dropped.

### 5. Continuous (measure-theoretic) policy gradient theorem

Conjecture: the finite-sum `policy_gradient_theorem` lifts to a continuous action space
`A` with a dominated, differentiable density `π_θ` against a base measure `μ`, giving
`∇_θ ∫ π_θ(a) R(a) dμ = ∫ π_θ(a) R(a) ∇_θ log π_θ(a) dμ`, under a uniform integrability
(domination) hypothesis on `∂_θ π`.  The key insight is that the finite proof factors
through exactly two ingredients — interchange of derivative and summation, and the
log-derivative identity — both of which have measure-theoretic analogues
(`hasDerivAt` under the integral sign via dominated convergence, and `Real.hasDerivAt_log`)
already in Mathlib.  **Why now?** The discrete skeleton is complete and axiom-clean, so the
generalization is a controlled replacement of `Finset.sum`/`HasDerivAt.sum` by
`MeasureTheory.integral`/`hasDerivAt_integral_of_dominated`, isolating integrability as the
single new adversarial assumption to be stress-tested.
