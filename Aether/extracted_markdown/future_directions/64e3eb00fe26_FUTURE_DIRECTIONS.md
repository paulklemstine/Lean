# Future Directions — Neural Tangent Kernel: Convergence of Gradient Descent

## Synthesis

This cycle formalized the *exactly linearized* (lazy) regime of the Neural
Tangent Kernel program and proved that gradient descent on a linear-in-parameters
model is *literally* kernel regression with a fixed kernel. The structural
insight is that nothing about the NTK story requires probability or
infinite-width limits once you are in the linearized regime: the entire content
factors through two elementary facts of linear algebra and analysis. First, the
Jacobian of a linear model is its own (constant) Fréchet derivative
(`ntk_jacobian_constant`), so the kernel `K = Φ Φᵀ` never moves during training —
"lazy training" is exact, not approximate, for the linearization. Second,
parameter-space gradient descent on the squared loss collapses, *without
approximation*, onto the closed residual recursion `r_{t+1} = (I - η K) r_t`
(`gd_residual_dynamics`); the NTK Gram matrix appears automatically from
`Φ.mulVec (Φᵀ.mulVec v) = (Φ Φᵀ).mulVec v`.

Having isolated the recursion, convergence becomes a pure contraction argument.
We deliberately abstracted the spectral content into a single hypothesis
`‖A x‖ ≤ ρ ‖x‖` and proved geometric decay `‖r_t‖ ≤ ρ^t ‖r_0‖`
(`geometric_decay`) and convergence to zero for `ρ < 1`
(`residual_tendsto_zero`). What *failed* to make it into this cycle — and is
therefore the most honest pointer to the next one — is the bridge from the PSD
structure of `K` (which we did prove, `NTK_posSemidef`) to a concrete contraction
constant `ρ = ‖I - η K‖`. That bridge is exactly the spectral/eigenvalue estimate
`0 < η < 2/λ_max(K) ⟹ ‖I - η K‖ < 1`, and it is the natural seam along which to
extend the work. The tie that binds all the directions below: we have a clean,
sorry-free skeleton (PSD kernel + exact residual recursion + abstract
contraction ⟹ convergence), and each direction replaces one abstracted
hypothesis with a theorem.

## Results Summary

- `NTK_posSemidef`: proved — the NTK `K = Φ Φᵀ` is positive semidefinite, the
  defining structural property of a valid kernel.
- `NTK_isSymm`: proved — the NTK is symmetric, completing its Gram-matrix
  characterization.
- `ntk_jacobian_constant`: proved — the Jacobian of a linear model is constant
  in the parameters, so the NTK is *exactly* constant during training (lazy
  training is exact in the linearized regime).
- `gd_residual_dynamics`: proved — one gradient-descent step on the squared loss
  yields the exact kernel recursion `r_{t+1} = (I - η K) r_t`, with `K = Φ Φᵀ`
  emerging automatically.
- `geometric_decay`: proved — iterates of a contraction `‖A x‖ ≤ ρ ‖x‖` satisfy
  `‖r_t‖ ≤ ρ^t ‖r_0‖`.
- `residual_tendsto_zero`: proved — for `0 ≤ ρ < 1` the residual converges to
  zero, i.e. gradient descent drives the training loss to zero.

## Research Directions

### Direction 1: Spectral sufficient condition for the contraction constant
**Hypothesis**: If `K = Φ Φᵀ` is positive semidefinite with largest eigenvalue
`λ_max` and `0 < η < 2 / λ_max`, then `‖(1 - η • K).mulVec v‖ ≤ ρ ‖v‖` holds (in
the Euclidean norm) with `ρ = max(|1 - η λ_min|, |1 - η λ_max|) < 1` whenever
`K` is positive *definite*.
**Test**: Prove the operator-norm bound `‖I - η K‖₂ = max_i |1 - η λ_i|` using
Mathlib's spectral theorem for symmetric real matrices (`Matrix.IsHermitian.spectral_theorem` / `IsHermitian.eigenvalues`), then feed it into
`residual_tendsto_zero`. A disproof would show some symmetric PSD `K` and `η` in
range with `‖I - η K‖ ≥ 1`.
**Why now**: We already proved `NTK_posSemidef` and `NTK_isSymm`, and the
convergence theorem is stated against exactly this contraction hypothesis — only
the spectral estimate is missing.
**If true**: Converts the abstract hypothesis `hA` into a checkable condition on
the learning rate, giving an end-to-end "small learning rate ⟹ GD fits the data"
theorem.
**If false**: Would reveal that the Euclidean operator norm is not the right
contraction measure and point toward energy/`K`-weighted norms instead.

### Direction 2: Explicit limiting predictor (kernel regression solution)
**Hypothesis**: Under the same contraction condition, the parameter iterates'
predictions converge to the minimum-norm interpolant
`f_∞ = y` on the training set, and more generally to the kernel-regression
predictor `K (K)^{-1} y` on the data, so the limit is independent of the
initialization within the row space of `Φ`.
**Test**: Prove `Φ.mulVec θ_t → y` (immediate from `residual_tendsto_zero`),
then characterize `θ_t` itself: show `θ_t - θ_0` stays in the row space of `Φ`
and converges to the least-squares correction. Disproof: exhibit a rank-deficient
`Φ` where predictions converge but to something other than the kernel-regression
solution.
**Why now**: `gd_residual_dynamics` already gives the exact residual trajectory;
lifting it from residuals back to predictions/parameters is the next algebraic
step.
**If true**: Formalizes the headline NTK statement — "GD on a wide net =
kernel regression with the NTK" — as an explicit closed form.
**If false**: Isolates exactly which rank/condition assumption the closed form
needs.

### Direction 3: Quantitative non-laziness for genuinely nonlinear models
**Hypothesis**: For a twice-differentiable model `f(θ)` with bounded Hessian
`‖∇²f‖ ≤ M`, the empirical NTK `K_t = J(θ_t) J(θ_t)ᵀ` satisfies
`‖K_t - K_0‖ ≤ C · M · ‖θ_t - θ_0‖`, so for small step sizes and bounded
trajectories the kernel stays *nearly* (not exactly) constant.
**Test**: Use Mathlib's mean-value / Lipschitz-from-derivative bounds
(`Convex.norm_image_sub_le_of_norm_fderiv_le` style lemmas) to bound the change
in the Jacobian along the trajectory. Disproof: a model whose Jacobian moves at
order 1 even for `O(η)` parameter movement.
**Why now**: `ntk_jacobian_constant` proves the *exact* `M = 0` case; relaxing
to `M > 0` is the precise generalization the Critic flagged (the constancy
breaks the moment the model is nonlinear).
**If true**: Extends the NTK story beyond linearization with an explicit error
budget — the first quantitative "approximately lazy" theorem in this catalog.
**If false**: Pinpoints that Jacobian drift, not loss curvature, is the true
obstruction to lazy training.

### Direction 4: Loss monotonicity and an explicit convergence rate
**Hypothesis**: Define `L_t = (1/2) ‖r_t‖²`. Then `L_{t+1} ≤ (1 - η λ_min)² L_t`
under the spectral condition, giving the explicit rate
`L_t ≤ (1 - η λ_min)^{2t} L_0`, and `L` is monotonically non-increasing for
`0 < η ≤ 1/λ_max`.
**Test**: Square the bound from `geometric_decay` (already proved) and combine
with Direction 1's eigenvalue estimate; monotonicity follows from
`r_{t+1} = (I - ηK) r_t` and PSD-ness. Disproof: a non-monotone loss trajectory
for `η` in the claimed safe range.
**Why now**: `geometric_decay` gives `‖r_t‖ ≤ ρ^t ‖r_0‖` for free; squaring it
is a one-line corollary once `ρ` is identified with `1 - η λ_min`.
**If true**: Upgrades qualitative convergence to a textbook-quality explicit
linear rate keyed to the NTK spectrum.
**If false**: Indicates the loss can transiently increase even in the lazy
regime, an interesting and counterintuitive finding worth its own note.

### Direction 5: Generalization / test-time prediction via the NTK
**Hypothesis**: For a fresh input with feature row `φ_*`, the trained model's
prediction equals the kernel-regression prediction
`f_*(∞) = k_*ᵀ K⁻¹ y`, where `k_* = Φ φ_*` is the NTK evaluated between the test
point and the training set (assuming `K` invertible).
**Test**: Combine Direction 2's explicit limit `θ_∞` with `f_*(θ) = φ_*ᵀ θ` and
simplify; verify the contraction lives in the right subspace. Disproof: a test
point outside the row space of `Φ` where the prediction is initialization-dependent.
**Why now**: Directions 1–2 are projected to deliver the trained parameters in
closed form; test-time prediction is then a direct evaluation.
**If true**: Closes the loop from training dynamics to generalization, the
ultimate payoff of the NTK framework.
**If false**: Highlights the role of initialization in out-of-span directions,
a known subtlety the formalization would make precise.
