# Future Directions: Diffusion Models as SDEs

## Synthesis

This cycle built the foundational analytic infrastructure for formalizing
score-based diffusion models in Lean 4, working entirely at the level of the
**deterministic moment signatures** of the Ornstein–Uhlenbeck (OU) process
rather than attempting to axiomatize Itô calculus (which Mathlib lacks). The
files live under `MachineLearning/DiffusionSDE/`:

- `OU.lean` — the OU mean/variance moment functions, their exponential decay
  and universal stationary limit, variance positivity, and the two **moment
  ODEs** `m' = -θ m` and `v' = σ² − 2θ v` proved as honest `HasDerivAt`
  statements. These ODE identities are the rigorous bridge between the explicit
  marginal solutions and the generator of the SDE.
- `KL.lean` — the closed-form univariate Gaussian KL divergence with identity
  of indiscernibles and **Gibbs' inequality** (`KL ≥ 0`), the latter reduced to
  the scalar inequality `log x ≤ x − 1`.
- `Convergence.lean` — the capstone results: the KL divergence of the time-`t`
  marginal from the stationary law tends to `0` (a Lyapunov-style convergence
  theorem composing the moment limits with KL continuity); the Gaussian
  **score** `−(x−m)/v` is the genuine derivative of the log density; and the
  **reverse-time drift is affine** in `x`, i.e. the time-reversed process is
  again OU.

The structural insight tying the cycle together is that for Gaussians the score
is *linear in `x`*, so the entire forward → score → reverse loop stays inside
the finite-dimensional family of moment equations. All ten theorems are proved
with zero `sorry` and depend only on the standard axioms `propext`,
`Classical.choice`, `Quot.sound`.

The main limitation is that we describe the process by its moments, not by a
genuine stochastic object: the link between the moment evolution and an actual
SDE is asserted at the conceptual level, not derived. Bridging that gap needs
either stochastic integration or an abstract Markov-semigroup approach.

## Results Summary

- `ou_mean_tendsto_zero` — OU mean decays exponentially to `0` ("forgetting").
- `ou_variance_tendsto_stationary` — variance converges to `σ²/(2θ)` for any `v₀`.
- `ou_variance_pos` — variance stays positive, so the Gaussian marginal is well-defined.
- `ou_mean_hasDerivAt` — first-moment ODE `m'(t) = −θ·m(t)`.
- `ou_variance_hasDerivAt` — second-moment ODE `v'(t) = σ² − 2θ·v(t)`.
- `kl_div_gaussian_self_eq_zero` — KL vanishes on identical Gaussians.
- `kl_div_gaussian_nonneg` — Gibbs' inequality for Gaussians.
- `kl_div_along_ou_flow_tendsto_zero` — KL to the stationary law tends to `0`.
- `gaussian_score_eq_deriv` — the score equals `∇ₓ log p(x)`.
- `reverse_drift_affine` — the reverse-time drift is affine (reverse SDE is OU).

## Research Directions

### Direction 1: A quantified Lyapunov rate for the KL flow

We proved `kl_div_along_ou_flow_tendsto_zero` qualitatively; the next step is a
**quantitative exponential rate**: show that
`klDivGaussian (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) 0 (ouStationaryVariance σsq θ)`
is bounded above by `C · exp(−2θ t)` for an explicit constant `C` depending on
`(m₀, v₀, σsq, θ)`, and ideally that the flow is eventually antitone in `t`.
The key insight is that, after substituting the explicit moment formulas, the KL
expression is a sum of terms each governed by `exp(−θt)` or `exp(−2θt)`, so the
log term can be bounded by its first-order Taylor remainder and the whole
expression collapses to a single decaying exponential envelope. Why now? We
already have `ou_mean_hasDerivAt`, `ou_variance_hasDerivAt`, and
`kl_div_gaussian_nonneg`, so the rate is a calculus exercise on explicit
formulas rather than a new conceptual object. If true, this is the formal
sampling guarantee "ε-close after `t = O(θ⁻¹ log ε⁻¹)`"; if false, it would
expose a genuine interaction between the `exp(−θt)` mean-decay and `exp(−2θt)`
variance-decay timescales that the qualitative limit hides.

### Direction 2: Pinsker's inequality bridges KL to total variation

Compose the (to-be-proved) KL decay rate with **Pinsker's inequality**
`TV(p,q)² ≤ ½ KL(p‖q)` to get an explicit `O(exp(−θt))` bound on the total
variation distance between the time-`t` marginal and the stationary law. The key
insight is that for two univariate Gaussians both `KL` and `TV` have closed
forms, so the entire argument stays inside elementary real analysis — no
abstract functional-analytic machinery and no integration theory are needed,
just the closed-form `klDivGaussian` we already have. Why now? The KL side is
already in place (`kl_div_gaussian_nonneg`, and Direction 1's rate); Pinsker for
the 1-D Gaussian special case is a self-contained inequality that can be
formalized directly. If true, it converts our information-theoretic convergence
into a statistically meaningful distributional guarantee; if false, it would
indicate that the Gaussian TV closed form needs error-function infrastructure
not yet convenient in Mathlib.

### Direction 3: Fokker–Planck verification for the Gaussian density

Define the Gaussian density `p(x,t) = (2π v(t))^{-1/2} exp(−(x−m(t))²/(2v(t)))`
with `m = ouMean`, `v = ouVariance`, and verify the **Fokker–Planck PDE**
`∂ₜ p = θ ∂ₓ(x p) + (σ²/2) ∂ₓₓ p` pointwise. The key insight is that this is a
*verification*, not an existence problem: every derivative is an explicit
`HasDerivAt` composition, and the PDE identity reduces algebraically to the two
moment ODEs we already proved (`ou_mean_hasDerivAt`, `ou_variance_hasDerivAt`)
together with `gaussian_score_eq_deriv` for the spatial derivatives. Why now? We
have both moment ODEs and the spatial score derivative in hand, so the PDE is
the algebraic "closure" of results already established. If true, it links our
moment-level description to the distributional (physics-literature) description;
if false, the obstacle would be precisely the second-order `∂ₓₓ` composition,
identifying a concrete missing `HasDerivAt` lemma to contribute upstream.

### Direction 4: Multivariate OU via matrix exponentials

Generalize from ℝ to ℝⁿ: for `dX = −A X dt + B dW` with `A` symmetric positive
definite, define the covariance `Σ(t)` through `Matrix.exp (−tA)` and prove it
converges to the unique solution of the Lyapunov equation
`A Σ∞ + Σ∞ Aᵀ = B Bᵀ`, with the matrix Gaussian KL divergence remaining
nonnegative. The key insight is that positive-definiteness of `A` diagonalizes
the dynamics: in the eigenbasis the system decouples into `n` independent scalar
OU processes, each governed exactly by the `OU.lean` lemmas, so the matrix
result is an orthogonal assembly of the scalar one. Why now? Mathlib provides
`Matrix.exp` and the spectral theorem for symmetric matrices, and our scalar
layer is the per-eigenvalue building block. If true, it opens the door to
realistic high-dimensional diffusion models; if false, it would pinpoint
specific gaps in the `Matrix.exp` / simultaneous-diagonalization API.

### Direction 5: The reverse SDE as an explicit OU process with reversed parameters

Promote `reverse_drift_affine` from "the reverse drift is affine" to a complete
identification: show that the reverse-time process driven by
`2σ² · gaussianScore (ouMean ·) (ouVariance ·) − f` is **itself an OU process**
whose mean and variance functions are again of `ouMean`/`ouVariance` form with
explicitly time-reversed parameters, and that running it from the stationary law
recovers the original marginals. The key insight is that affine drift plus
Gaussian initial data is a closed class: the reverse moments satisfy their own
linear ODEs whose coefficients we can read off directly from the slope
`θ − 2D/v` and intercept `2D m/v` already computed in `reverse_drift_affine`.
Why now? We have the score derivative, the affine reverse drift, and the moment
ODE machinery, so closing the forward→reverse loop is a matter of matching two
explicit linear ODE systems. If true, it formalizes the central correctness
statement of score-based generative modeling (the reverse process regenerates
the data distribution); if false, it would show that moment equations alone
cannot witness time reversal and that a genuine pathwise/measure-level
construction is unavoidable.
