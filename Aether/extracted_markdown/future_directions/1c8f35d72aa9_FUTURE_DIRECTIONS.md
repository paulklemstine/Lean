# Future Directions — NTK Lazy Training / Kernel Constancy

## Synthesis

This cycle attacked the *kernel-constancy* half of the Neural Tangent Kernel (NTK)
story, which the existing `MachineLearning.NTKSpectral` file left open. `NTKSpectral`
already proves that the **spectrum** of the Gram matrix `Θ = Jᵀ J` controls the
convergence of gradient descent (PSD-ness, spectral mode decay, optimal
condition-number contraction, convergence to zero). What it does *not* establish is
*why one is allowed to treat the kernel as fixed* in the first place. The new file
`MachineLearning.NTKLazyTraining` supplies exactly that missing justification: in the
lazy / small-learning-rate regime the kernel barely moves during training.

The decisive structural insight was to measure the kernel through its **quadratic
form** `x ↦ xᵀ Θ x` rather than through any operator norm. By `NTKSpectral.ntk_quadratic_form`
that quadratic form equals the squared feature norm `(Jx)·(Jx)`, and its drift between
two parameter settings `A = J(θ_k)`, `B = J(θ_0)` collapses, via a polarization
identity, to a single dot product `((A−B)x)·((A+B)x)`. A lone Cauchy–Schwarz step then
bounds the kernel drift by the product of *feature drift* and *feature sum*, and feeding
in a gradient-descent parameter-drift bound plus a Lipschitz feature map gives the
capstone `lazy_kernel_constancy`: kernel drift is `O(η·k)`, hence vanishes as `η → 0`.

What failed: an operator-norm formulation `‖Θ(A)−Θ(B)‖ ≤ (‖A‖+‖B‖)‖A−B‖` was abandoned
because Mathlib's matrix operator-norm API is heavy and entangled with instance choices;
the quadratic-form route captures the same content with fully elementary proofs and is
in fact what the convergence argument actually consumes (it acts on residual vectors).
Together, `NTKSpectral` (spectrum ⇒ convergence) and `NTKLazyTraining` (lazy ⇒ kernel
constant) now bracket the two pillars of the NTK theorem; the natural next move is to
*combine* them into a single end-to-end statement, since both are phrased on the same
quadratic form.

## Results Summary

- `param_drift_bound`: proved — gradient descent with bounded gradients keeps parameters
  within `η·G·k` of initialization, formalizing the "lazy" regime; the hypothesis `0 ≤ G`
  turned out unnecessary and was dropped.
- `ntk_quadratic_drift_eq`: proved — polarization identity `xᵀΘ(A)x − xᵀΘ(B)x = ((A−B)x)·((A+B)x)`,
  the algebraic heart that reduces kernel drift to feature drift.
- `ntk_quadratic_drift_bound`: proved — Cauchy–Schwarz bound on squared kernel drift in
  terms of feature-drift and feature-sum self-products.
- `lazy_kernel_constancy`: proved (capstone) — under bounded gradients and a Lipschitz
  feature map the NTK quadratic-form drift after `k` steps is `≤ M·L·η·G·k`, hence `→ 0`
  as `η → 0`, licensing the fixed-kernel (kernel-regression) approximation.

## Research Directions

### Direction 1: End-to-end NTK theorem (constancy ⇒ convergence to kernel regression)
**Hypothesis**: There is a single theorem combining `lazy_kernel_constancy` with the
`NTKSpectral` contraction results stating that, for `η` small enough relative to the
NTK spectral gap, the gradient-descent residual `r_k` both converges to `0` AND stays
uniformly close to the residual of the *fixed-kernel* linear dynamics `r̃_{k+1} = (I − ηΘ_0) r̃_k`,
with gap `O(η·k²)` over the trajectory.
**Test**: State `‖r_k − r̃_k‖ ≤ C·η·k²` and prove it by a discrete Grönwall/telescoping
argument using `lazy_kernel_constancy` to bound the per-step kernel error and the
contraction factor `ρ < 1` from `optimal_lr_contraction`.
**Why now**: Both halves are now proved on the *same* quadratic form, so the only new
ingredient is a perturbed-recurrence (Grönwall) lemma — no new geometry.
**If true**: A complete, machine-checked statement of the central NTK theorem.
**If false**: The `k²` rate is wrong, pinpointing whether kernel drift or spectral
contraction dominates the error budget.

### Direction 2: Quantitative width dependence
**Hypothesis**: The Lipschitz constant `L` and the parameter-drift effectively scale so
that for a width-`w` network the kernel drift over a fixed horizon is `O(1/√w)`, i.e.
the kernel becomes constant in the infinite-width limit.
**Test**: Instantiate `lazy_kernel_constancy` with an explicit two-layer model whose
Jacobian rows are `1/√w`-normalized, and prove `L = O(1/√w)` and `G = O(1)`, deducing
drift `→ 0` as `w → ∞`.
**Why now**: `lazy_kernel_constancy` already isolates `L`, `G`, `M` as the only
width-sensitive constants, so the whole infinite-width statement reduces to estimating
these three scalars for a concrete architecture.
**If true**: Connects the abstract drift bound to the literal "infinite-width" hypothesis.
**If false**: The naive `1/√w` scaling fails, revealing that higher-order Jacobian
curvature, not first-order Lipschitzness, controls the limit.

### Direction 3: Operator-norm (full-matrix) kernel constancy
**Hypothesis**: `‖Θ(A) − Θ(B)‖_op ≤ (‖A‖_op + ‖B‖_op) · ‖A − B‖_op`, giving kernel
constancy *uniformly over all residual directions* rather than for a fixed `x`.
**Test**: Prove the operator-norm perturbation bound for `AᵀA` in Mathlib and combine
with `param_drift_bound`; alternatively derive it from `ntk_quadratic_drift_bound` by
quantifying over unit `x` via `Matrix` operator-norm characterizations.
**Why now**: The quadratic-form version is done and is exactly the `x`-pointwise content;
the only gap is the supremum over `x`, a packaging step.
**If true**: Strengthens constancy from "per-residual" to "whole-kernel", needed for
generalization (test-point) guarantees.
**If false**: The operator norm genuinely behaves worse than the quadratic form,
identifying a real obstruction in the multi-output setting.

### Direction 4: Tightness / boundary case of the drift bound
**Hypothesis**: The bound `M·L·η·G·k` is order-optimal: there exists a 1-D model and a
gradient sequence making the actual kernel drift `≥ c·η·G·k` for some `c > 0`.
**Test**: Construct an explicit `J : ℝ → Matrix 1 1 ℝ`, `J(t) = t`, with constant gradient
`g_k = G`, and compute both sides of `lazy_kernel_constancy` to show the bound is achieved
up to a constant.
**Why now**: The proof exposes exactly where slack enters (Cauchy–Schwarz and the
parameter-drift triangle inequality), so a saturating example is constructible by making
both inequalities tight.
**If true**: Confirms the linear-in-`η`, linear-in-`k` law is the true rate.
**If false**: There is hidden cancellation, suggesting a sharper `o(η·k)` bound under
extra (e.g. martingale) structure on the gradients.

### Direction 5: Continuous-time gradient flow constancy
**Hypothesis**: Under gradient flow `θ̇ = −∇L` with `‖∇L‖ ≤ G`, the NTK quadratic form
satisfies `|xᵀΘ(θ_t)x − xᵀΘ(θ_0)x| ≤ M·L·G·t`, the continuous analogue of
`lazy_kernel_constancy`.
**Test**: Replace the discrete `param_drift_bound` induction with an integral bound
`‖θ_t − θ_0‖ ≤ ∫₀ᵗ ‖θ̇‖ ≤ G·t` (Mathlib `norm_integral_le_integral_norm`) and reuse
`ntk_quadratic_drift_bound` verbatim.
**Why now**: The drift identity and Cauchy–Schwarz steps are time-discretization-agnostic;
only the parameter-drift lemma changes, isolating the entire continuous-time work in one
analytic estimate.
**If true**: Unifies the discrete and continuous NTK pictures under one quadratic-form
framework.
**If false**: The integral bound needs absolute continuity assumptions absent in the
discrete case, clarifying the regularity hypotheses the NTK story silently relies on.
