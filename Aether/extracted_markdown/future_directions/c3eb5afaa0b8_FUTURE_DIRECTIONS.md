# Future Directions — Neural Tangent Kernel: Convergence of Gradient Descent

## Synthesis

This cycle formalized the *exactly linearized* (lazy) regime of the Neural
Tangent Kernel program and proved, with zero `sorry`, that gradient descent on a
linear-in-parameters model is *literally* kernel regression with a fixed kernel.
The structural insight is that nothing about the NTK story requires probability
or infinite-width limits once you are in the linearized regime: the entire
content factors through two elementary facts of linear algebra and analysis.
First, the Jacobian of a linear model is its own (constant) Fréchet derivative
(`ntk_jacobian_constant`, with the no-remainder companion
`ntk_linearization_exact`), so the kernel `K = Φ Φᵀ` never moves during
training — "lazy training" is exact, not approximate, for the linearization.
Second, parameter-space gradient descent on the squared loss collapses, *without
approximation*, onto the closed residual recursion `r_{t+1} = (I - η K) r_t`
(`gd_residual_dynamics`); the NTK Gram matrix appears automatically from
`Φ.mulVec (Φᵀ.mulVec v) = (Φ Φᵀ).mulVec v`.

Having isolated the recursion, convergence becomes a pure contraction argument.
We deliberately abstracted the spectral content into a single hypothesis
`‖A x‖ ≤ ρ ‖x‖` and proved geometric decay `‖rₜ‖ ≤ ρᵗ ‖r₀‖`
(`geometric_decay`), convergence to zero for `ρ < 1` (`residual_tendsto_zero`),
and an explicit linear loss rate `Lₜ ≤ ρ^{2t} L₀` (`loss_geometric_decay`). What
was *deliberately left abstract* — and is therefore the most honest pointer to
the next cycle — is the bridge from the PSD structure of `K` (which we did prove,
`NTK_posSemidef`) to a concrete contraction constant `ρ = ‖I - η K‖`. That
bridge is exactly the spectral/eigenvalue estimate
`0 < η < 2/λ_max(K) ⟹ ‖I - η K‖ < 1`, and it is the natural seam along which to
extend the work. The tie that binds all the directions below: we have a clean,
sorry-free skeleton (PSD + symmetric kernel + exact residual recursion +
abstract contraction ⟹ convergence + explicit rate), and each direction
replaces one abstracted hypothesis with a theorem.

## Catalog connections

* `EML/FixedPointConvergence.lean` and `Bridges/GronwallDiscreteBridge.lean`
  already host geometric/contraction-style convergence arguments; our
  `geometric_decay`/`residual_tendsto_zero` are the *operator-valued* analogue
  and should eventually share a common abstraction.
* `MachineLearning/ResNetLipschitz.lean` proves additive Lipschitz growth
  `(1+L)`; the contraction constant `ρ = ‖I - ηK‖` here is the dual "below 1"
  regime, suggesting a unified Lipschitz/contraction lemma library.

## Results Summary

- `NTK_isSymm`: proved — the NTK `K = Φ Φᵀ` is symmetric.
- `NTK_posSemidef`: proved — the NTK `K = Φ Φᵀ` is positive semidefinite, the
  defining structural property of a valid kernel.
- `ntk_jacobian_constant`: proved — the Fréchet derivative of the linear model is
  the constant CLM `Φ.mulVecLin`, so the NTK is *exactly* constant during
  training (lazy training is exact in the linearized regime).
- `ntk_linearization_exact`: proved — the model equals its own linearization with
  no remainder, the algebraic shadow of constancy of the Jacobian.
- `gd_residual_dynamics`: proved — one gradient-descent step on the squared loss
  yields the exact kernel recursion `r_{t+1} = (I - η K) r_t`, with `K = Φ Φᵀ`
  emerging automatically.
- `geometric_decay`: proved — iterates of a contraction `‖A x‖ ≤ ρ ‖x‖` satisfy
  `‖rₜ‖ ≤ ρᵗ ‖r₀‖`.
- `residual_tendsto_zero`: proved — for `0 ≤ ρ < 1` the residual converges to
  zero, i.e. gradient descent drives the training loss to zero.
- `loss_geometric_decay`: proved — the squared loss obeys the explicit linear
  rate `Lₜ ≤ ρ^{2t} L₀`.

## Research Directions

### Direction 1: Spectral sufficient condition for the contraction constant
**Hypothesis**: If `K = Φ Φᵀ` is positive definite with eigenvalues
`0 < λ_min ≤ λ_max` and `0 < η < 2 / λ_max`, then the Euclidean operator
`v ↦ (1 - η • K).mulVec v` satisfies `‖(1 - η K) v‖ ≤ ρ ‖v‖` with
`ρ = max(|1 - η λ_min|, |1 - η λ_max|) < 1`.
**Test**: Prove the operator-norm bound `‖I - η K‖₂ = max_i |1 - η λ_i|` using
Mathlib's spectral theorem for symmetric real matrices
(`Matrix.IsHermitian.spectral_theorem`, `Matrix.IsHermitian.eigenvalues`), then
feed `ρ < 1` into `residual_tendsto_zero`. A disproof would exhibit a symmetric
PSD `K` and `η` in range with `‖I - η K‖ ≥ 1`.
**Why now**: We already proved `NTK_posSemidef` and `NTK_isSymm`, and
`residual_tendsto_zero`/`geometric_decay` are stated against exactly this
contraction hypothesis — only the spectral estimate is missing.
**The key insight is** that the contraction constant is not an extra assumption
but a *theorem about the kernel spectrum*: `ρ = ‖I - ηK‖` is computable from
`λ(K)` alone, so "small learning rate ⟹ GD fits the data" becomes a checkable
condition on `η`.
**If true**: yields an end-to-end "GD converges for `η < 2/λ_max`" theorem.
**If false**: would reveal that the Euclidean operator norm is not the right
contraction measure and point toward `K`-weighted/energy norms.

### Direction 2: Explicit limiting predictor (kernel-regression solution)
**Hypothesis**: Under the Direction-1 condition, the predictions converge to the
interpolant `Φ.mulVec θ_t → y`, and the parameter increment `θ_t - θ_0` stays in
the row space of `Φ` and converges to the minimum-norm least-squares correction,
so the limit is independent of initialization within `range Φᵀ`.
**Test**: `Φ.mulVec θ_t → y` is immediate from `residual_tendsto_zero`; then
characterize `θ_t` by showing `θ_t - θ_0 ∈ Submodule.span (rows of Φ)` is
preserved by the update and passes to the limit.  Disproof: a rank-deficient `Φ`
where predictions converge but parameters drift outside the row space.
**Why now**: `gd_residual_dynamics` already gives the exact residual trajectory;
lifting it from residuals back to parameters is the next purely algebraic step.
**The key insight is** that the GD update only ever adds `Φᵀ`-multiples to `θ`, so
the trajectory is confined to a fixed affine subspace and its limit is forced.
**If true**: formalizes the headline NTK statement — "GD on a wide net = kernel
regression with the NTK" — as an explicit closed form.
**If false**: isolates exactly which rank/conditioning assumption the closed form
requires.

### Direction 3: Quantitative non-laziness for genuinely nonlinear models
**Hypothesis**: For a `C²` model `f(θ)` with bounded Hessian `‖∇²f‖ ≤ M`, the
empirical NTK `K_t = J(θ_t) J(θ_t)ᵀ` satisfies
`‖K_t - K_0‖ ≤ C · M · ‖θ_t - θ_0‖`, so for small steps and bounded trajectories
the kernel stays *nearly* (not exactly) constant.
**Test**: bound the Jacobian drift along the trajectory with Mathlib's
mean-value / Lipschitz-from-derivative lemmas
(`Convex.norm_image_sub_le_of_norm_fderiv_le`), then propagate to `K_t`.
Disproof: a model whose Jacobian moves at order 1 under `O(η)` parameter movement.
**Why now**: `ntk_jacobian_constant` proves the *exact* `M = 0` case; relaxing to
`M > 0` is the precise generalization the constancy argument begs for.
**The key insight is** that lazy training is a *continuity* statement about the
Jacobian map `θ ↦ J(θ)`, so its failure is governed by curvature `M`, giving a
quantitative error budget rather than an all-or-nothing dichotomy.
**If true**: the first quantitative "approximately lazy" theorem in this catalog.
**If false**: pinpoints Jacobian drift, not loss curvature, as the true
obstruction to lazy training.

### Direction 4: Loss monotonicity in the safe step-size window
**Hypothesis**: With `L_t = ½‖r_t‖²` and `r_{t+1} = (I - ηK) r_t`, the loss is
monotonically non-increasing for `0 < η ≤ 1/λ_max(K)`, and strictly decreasing
while `r_t ∉ ker K`.
**Test**: expand `‖(I - ηK) r‖² = ‖r‖² - 2η rᵀK r + η² ‖K r‖²` and bound the last
two terms using PSD-ness (`NTK_posSemidef`) and `‖K r‖² ≤ λ_max · rᵀK r`.
Disproof: a non-monotone trajectory for `η` in the claimed window.
**Why now**: `loss_geometric_decay` already gives the *rate*; monotonicity is the
finer per-step statement that the rate alone does not certify.
**The key insight is** that the per-step decrement is a quadratic form in `r_t`
controlled entirely by the kernel spectrum, so the "safe" learning-rate window is
exactly where that quadratic form is sign-definite.
**If true**: upgrades qualitative convergence to a certified descent method.
**If false**: shows the loss can transiently increase even in the lazy regime —
an interesting and counterintuitive finding worth its own note.

### Direction 5: Generalization / test-time prediction via the NTK
**Hypothesis**: For a fresh input with feature row `φ_*`, the trained model's
prediction equals the kernel-regression prediction `f_*(∞) = k_*ᵀ K⁻¹ y`, where
`k_* = Φ φ_*` is the NTK between the test point and the training set (assuming `K`
invertible).
**Test**: combine Direction 2's explicit limit `θ_∞` with `f_*(θ) = φ_*ᵀ θ` and
simplify; verify the contraction lives in the right subspace. Disproof: a test
point with `φ_*` outside `range Φᵀ` where the prediction is
initialization-dependent.
**Why now**: Directions 1–2 are projected to deliver the trained parameters in
closed form; test-time prediction is then a direct evaluation.
**The key insight is** that generalization is *not* a new phenomenon but a linear
read-out of the same confined trajectory — the test prediction is determined by
where `θ_∞` lands in `range Φᵀ`.
**If true**: closes the loop from training dynamics to generalization, the
ultimate payoff of the NTK framework.
**If false**: highlights the role of initialization in out-of-span directions, a
known subtlety the formalization would make precise.
