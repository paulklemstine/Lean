# Future Directions: Quantitative Mixing of the Forward Diffusion Process

## Synthesis

This cycle built a bridge inside `Pythagorean.DiffusionSchedule` between two
previously disconnected results: the *geometric* exponential decay bound on the
signal-retention coefficient, `diffusionAlphaBar_exp_bound`
(ᾱ_t ≤ exp(−∑_{i<t} β_i)), and the *analytic* closed form for the univariate
Gaussian KL divergence, `univGaussianKL` (with `univGaussianKL_nonneg` and
`univGaussianKL_self`). The new file `Pythagorean.DiffusionKLConvergence`
introduces `diffusionTerminalKL a x₀ = KL( N(√a·x₀, 1−a) ‖ N(0,1) )` — the
residual mismatch between the forward marginal `q(x_t | x₀)` and the standard
Gaussian prior — and shows it inherits the exponential decay of ᾱ_t. The
payoff theorem `diffusionForwardKL_exp_decay` gives a fully explicit,
machine-checked convergence rate:

    KL( q(x_t | x₀) ‖ N(0,1) ) ≤ ½·(1 + x₀²)·exp(−∑_{i<t} β_i)   (when ᾱ_t ≤ ½).

The conceptual unification is that the *product structure* of the schedule
(ᾱ_t = ∏(1−β_i)) and the *additive* log-domain structure of Gaussian KL are two
faces of the same exponential: signal half-life equals KL convergence rate.

## Results Summary

- `diffusionTerminalKL_nonneg` — the residual KL is always ≥ 0 (from
  `univGaussianKL_nonneg`).
- `diffusionTerminalKL_closedForm` — `−½·log(1−a) + (1−a+a·x₀²)/2 − ½`, obtained
  by collapsing `√(1−a)` and `√a` through `Real.sq_sqrt`/`Real.log_sqrt`.
- `diffusionTerminalKL_le` — linear control `≤ ½(1+x₀²)·a` on the high-noise
  regime `a ≤ ½`, via `log(1−a) ≥ −a/(1−a)`.
- `diffusionForwardKL_exp_decay` — the headline exponential mixing bound,
  composing the linear control with `diffusionAlphaBar_exp_bound`.

All main results are `sorry`-free and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Removing the `ᾱ_t ≤ 1/2` regime restriction

The current bound needs `ᾱ_t ≤ ½` because `−log(1−a)` is only linearly
controllable away from `a = 1`. Conjecture: for *any* `0 < a < 1`,
`diffusionTerminalKL a x₀ ≤ −½·log(1−a) + ½·a·x₀²`, an exact upper bound with no
regime split, sharp as `a → 0`. **The key insight is** that the `x₀²` term and
the variance term decouple completely in the closed form, so only the variance
term needs the delicate log estimate, and `−½log(1−a) − ½a` is itself monotone
and non-negative on all of `(0,1)`. **Why now?** The closed form
`diffusionTerminalKL_closedForm` is already proven, so this is a pure real-analysis
estimate on a single-variable function — directly attackable with `nlinarith`
plus `Real.log` convexity lemmas already in Mathlib.

### 2. Total signal budget controls total information loss

Define the cumulative noise budget `B_t = ∑_{i<t} β_i`. Conjecture: the *worst
case over unit-energy inputs* of the terminal KL is monotone decreasing in `B_t`
and satisfies `sup_{x₀²≤1} diffusionTerminalKL ᾱ_t x₀ ≤ exp(−B_t)`. **The key
insight is** that `diffusionForwardKL_exp_decay` already exposes `exp(−B_t)` as
the controlling quantity, so the schedule's only relevant summary statistic is
its running sum, not its individual `β_i`. **Why now?** `diffusionAlphaBar_exp_bound`
plus the new linear bound make this a one-line corollary for `x₀² ≤ 1`; the open
part is proving it is the *tight* envelope, which connects to existing
`StrictMonoOn` machinery (`div_one_sub_strictMonoOn`) in the schedule file.

### 3. A KL-based reformulation of `diffusionSNR_strictAnti`

The schedule file proves the signal-to-noise ratio is strictly decreasing
(`diffusionSNR_strictAnti`). Conjecture: the terminal KL is *strictly increasing*
in the SNR, i.e. `diffusionTerminalKL` is a strictly monotone function of
`diffusionSNR` at fixed `x₀ ≠ 0`, making "KL to prior" and "SNR" order-isomorphic
invariants of the process. **The key insight is** that both quantities are
strictly monotone reparametrizations of `ᾱ_t`, so they must be monotone functions
of each other — a structural equivalence rather than a coincidence. **Why now?**
Both monotonicity facts (`diffusionAlphaBar_strictAnti`, the new closed form)
are in place; composing two `StrictMono`/`StrictAnti` facts is routine and would
unify the file's "geometry" and "information" viewpoints into one order theory.

### 4. Multivariate / isotropic generalization

Lift `diffusionTerminalKL` from `ℝ` to `ℝ^d` (or `EuclideanSpace ℝ (Fin d)`) with
isotropic covariance `(1−a)·I`. Conjecture: the KL to `N(0, I_d)` is exactly
`d` copies of the scalar variance term plus `½·a·‖x₀‖²`, hence
`diffusionForwardKL_exp_decay` scales as `≤ ½(d + ‖x₀‖²)·exp(−B_t)`. **The key
insight is** that isotropic Gaussian KL is additive across coordinates, so the
scalar closed form is the entire content and the dimension enters only as a
linear multiplier on the variance term. **Why now?** Mathlib's
`MeasureTheory`/`ProbabilityTheory` Gaussian API and `Finset.sum` additivity make
the per-coordinate decomposition mechanical, and the scalar base case is now fully
proven.

### 5. Reverse-process error budget (denoising side)

The forward bound controls how close the *terminal* sample is to the prior; the
dual question is how a score-matching error `ε` at each step accumulates in the
*reverse* KL. Conjecture: if each reverse transition has KL error `≤ ε`, the
end-to-end generation error is bounded by `T·ε + ½(1+x₀²)·exp(−B_T)`, the second
term being exactly the prior-mismatch this cycle bounds. **The key insight is**
that the prior-initialization error of the reverse process is *precisely*
`diffusionForwardKL_exp_decay`, so this theorem supplies one of the two additive
terms in any end-to-end DDPM sampling guarantee for free. **Why now?** With the
forward/prior term now formalized, the remaining work is a telescoping
`Finset.sum` bound (data-processing inequality), for which Mathlib's KL and
`Finset.sum_range_succ` tooling is sufficient.
