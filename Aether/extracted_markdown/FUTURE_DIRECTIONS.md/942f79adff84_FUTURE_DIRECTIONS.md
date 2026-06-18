# Future Directions — NTK Optimal Convergence Rate

This cycle extended the Neural Tangent Kernel spectral convergence programme
(`MachineLearning.NTKCore`, `MachineLearning.NTKSpectral`) into a genuine
*optimal-rate* theory in `MachineLearning.NTKConvergenceRate`. We proved that
the classical step size `η* = 2/(μ+L)` contracts the **whole** spectral band
`[μ, L]` (not just the two extreme modes) at the inverse-condition-number rate
`(L-μ)/(L+μ)`, that this rate is globally minimax optimal over all step sizes,
that it equals `(κ-1)/(κ+1)` with `κ = L/μ` and is monotone in `κ`, and that the
band bound is attained exactly at the smallest eigenvalue while a zero eigenvalue
mode never decays. The following conjectures push this frontier further.

## 1. Full-vector decay from a spectral decomposition

So far convergence is proven *per eigenmode*. The natural next theorem is the
aggregate bound: if `u₀ = Σₖ cₖ vₖ` is expanded in an orthonormal eigenbasis of
the (symmetric PSD) NTK Gram matrix with eigenvalues `λₖ ∈ [μ, L]`, then the full
residual satisfies `‖gdResidual K η* u₀ t‖ ≤ ((L-μ)/(L+μ))^t ‖u₀‖`.

The key insight is that the optimal step size makes the gradient-descent operator
`I - η*K` a *normal contraction simultaneously on every mode*, so the worst-case
mode controls the worst-case vector — the per-mode `optimalRate_band_contraction`
bound lifts to the operator norm because the eigenbasis is orthogonal. Why now?
Mathlib's `Matrix.IsHermitian.spectral_theorem` and the existing
`ntkGramMatrix_posSemidef` give an orthonormal eigenbasis off the shelf, so the
only remaining work is the Parseval/Pythagoras bookkeeping that the current
per-mode lemmas already set up.

## 2. Iteration complexity in terms of the condition number

We have the geometric rate but not yet its logarithmic consequence. Conjecture:
to reach `‖u_t‖ ≤ ε‖u₀‖` it suffices to take
`t ≥ ⌈(κ/2) · log(1/ε)⌉` steps, where `κ = L/μ`, using the elementary bound
`(L-μ)/(L+μ) = (κ-1)/(κ+1) ≤ exp(-2/(κ+1))`.

The key insight is that the contraction factor `(κ-1)/(κ+1)`, already isolated in
`contraction_eq_condition_number`, is bounded by `e^{-2/(κ+1)}`, converting the
multiplicative geometric law into an additive logarithmic step count. Why now?
The rate is now an explicit closed form in `κ`, so the remaining step is a single
real-analysis inequality (`Real.add_one_le_exp` / `Real.log` monotonicity) that
Mathlib supports directly.

## 3. Polyak heavy-ball acceleration to the square-root rate

The gradient-descent rate `(κ-1)/(κ+1)` is provably optimal *among first-order
single-step methods* (our `optimalRate_isMinimax`), but momentum breaks that
barrier. Conjecture: the heavy-ball recursion
`u_{t+1} = (I - ηK)u_t + β(u_t - u_{t-1})` with `η = 4/(√L+√μ)²`,
`β = ((√L-√μ)/(√L+√μ))²` achieves the accelerated rate
`(√κ-1)/(√κ+1)` per eigenmode.

The key insight is that on each eigenmode the two-term recursion becomes a 2×2
companion matrix whose spectral radius is `√β`, so the convergence rate is the
*square root* of the gradient-descent factor — quadratically fewer iterations.
Why now? Our eigenmode reduction (`gdResidual_eigenvector`) already diagonalises
the dynamics scalar-by-scalar; the momentum extension only replaces the scalar
`1 - ηλ` recursion with a 2×2 linear recurrence, which is amenable to the same
induction technique.

## 4. Robustness of the optimal rate to spectrum misestimation

In practice `μ` and `L` are estimated, not known. Conjecture: if one uses
`η = 2/(μ̂+L̂)` for estimates with `μ̂ ≤ μ` and `L ≤ L̂`, then the achieved
worst-case contraction is still `< 1` and degrades continuously, bounded by
`max(|1 - η μ|, |1 - η L|) ≤ (L̂ - μ̂)/(L̂ + μ̂)`.

The key insight is that `optimalRate_band_contraction` already proves a *band*
statement: any true eigenvalue inside the **estimated** band `[μ̂, L̂]` is
contracted by `(L̂-μ̂)/(L̂+μ̂)`, so over-estimating the band only enlarges the
guaranteed-contraction window. Why now? The band lemma is stated for an arbitrary
`λ` with `μ ≤ λ ≤ L`, so re-instantiating it with the estimated endpoints is
immediate — this conjecture is essentially a corollary waiting to be recorded.

## 5. Two-sided (lower) bound: optimality is tight, not just attained

We proved the bound is *attained* at `λ = μ` (`optimalRate_decay_tight`). The
sharper claim is a *lower* envelope: for ANY symmetric step rule there exists an
eigenmode whose residual is at least `((L-μ)/(L+μ))^t ‖v‖`, so no first-order
method beats this rate on the worst input.

The key insight is to combine `optimalRate_minimizes` (no `η` lower-bounds the
worst extreme contraction below `(L-μ)/(L+μ)`) with the *exact* per-mode law
`gdResidual_eigenvector_norm`, turning a contraction-factor lower bound into a
residual-norm lower bound at the adversarial mode. Why now? Both ingredients are
already proven in the catalog; the missing piece is only selecting the
worst-of-two-extremes mode, a finite case split rather than new analysis.
