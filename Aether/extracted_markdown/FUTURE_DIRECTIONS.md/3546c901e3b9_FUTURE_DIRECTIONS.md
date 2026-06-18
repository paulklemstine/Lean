# Future Directions: Diffusion Model KL Convergence Algebra

This cycle produced `Catalog/Pythagorean/DiffusionKLConvergence.lean`, which extends
the catalog file `Catalog/Pythagorean/DiffusionSchedule.lean`. The new results, all
proved with no `sorry` and depending only on the standard axioms, are:

- `diffusionAlphaBar_exp_lower_bound` — the exponential **lower** sandwich
  `exp(-∑_{i<t} β_i/(1-β_i)) ≤ ᾱ_t`, complementing the catalog upper bound
  `diffusionAlphaBar_exp_bound`.
- `diffusionAlphaBar_constant_sandwich` and `diffusionAlphaBar_continuous_upper` —
  the constant-schedule two-sided bound and its continuous-time specialization.
- `diffusionKLToTarget_le` (convergence-rate upper bound) and
  `diffusionKLToTarget_ge_mean` (matching mean-displacement lower bound) for the KL
  divergence `KL = ½(ᾱ_t·(x₀²-1) - log(1-ᾱ_t))` of the forward marginal to `N(0,1)`.
- `diffusionKLToTarget_antitone_zero` — monotone KL decay along the forward process
  for the pure-variance case `x₀ = 0`.
- `multiGaussianKL_self`, `multiGaussianKL_nonneg`, and `multiDiffusionKLToTarget_le`
  — the anisotropic (coordinate-wise) KL scaffolding and its summed convergence bound.

The five directions below each name the specific new lemmas they build on.

## 1. Sharp two-sided Θ-bound for the convergence rate

`diffusionKLToTarget_le` gives `KL ≤ ᾱ_t·x₀²/2 + ᾱ_t²/(2(1-ᾱ_t))` and
`diffusionKLToTarget_ge_mean` gives `KL ≥ ᾱ_t·x₀²/2`. The gap between them is exactly
the variance term `½(-ᾱ_t - log(1-ᾱ_t))`. The conjecture: once `ᾱ_t ≤ 1/2` there is an
explicit constant `c > 0` with `KL ≥ c·(ᾱ_t·x₀² + ᾱ_t²)`, so the convergence rate is
*provably* `Θ(ᾱ_t·(1 + x₀²))`, pinning both endpoints of the sandwich.

The key insight is that the variance term `-a - log(1-a)` is itself sandwiched on
`(0,1/2]`: from above by `a²/(1-a) ≤ 2a²` (already inside `diffusionKLToTarget_le`)
and from below by `a²/2` (the second-order term of `-log(1-a)`, obtainable from
`neg_log_one_sub_le` rearranged with the elementary `a²/2 ≤ a - log(1-a)` valid for
`a ≤ 1/2`). Why now? Both directional bounds and the helper `neg_log_one_sub_le` /
`log_one_sub_le_neg` are already proved in the file, so the lower variance bound is a
single quadratic-vs-log estimate on a bounded interval with no new machinery.

**Falsifiable test**: prove
`diffusionAlphaBar β t ^ 2 / 4 ≤ diffusionKLToTarget β 0 t` whenever
`diffusionAlphaBar β t ≤ 1/2`, then add the `ᾱ_t·x₀²/2` term to get the full
two-sided `Θ` statement.

## 2. Unconditional monotone KL decay for arbitrary `x₀`

`diffusionKLToTarget_antitone_zero` proves `KL_{t+1} ≤ KL_t` for `x₀ = 0`. The
conjecture: for general `x₀`, `diffusionKLToTarget β x₀ (t+1) ≤ diffusionKLToTarget β x₀ t`
holds for all `t ≥ 1` once `x₀² ≤ 1` (the contractive regime), and more generally once
the marginal variance `1-ᾱ_t` exceeds `x₀²·ᾱ_t`.

The key insight is that `KL = ½(ᾱ_t(x₀²-1) - log(1-ᾱ_t))` is `g(ᾱ_t)` with
`g(a) = ½(a(x₀²-1) - log(1-a))` and `g'(a) = ½(x₀² - 1 + 1/(1-a))`; when `x₀² ≤ 1`
the first two terms are `≤ 0` only up to the `1/(1-a)` term, but composing the
*increasing* part with the strictly decreasing `ᾱ_t` (`diffusionAlphaBar_strictAnti`)
still yields antitonicity exactly as in the proved `x₀ = 0` case. Why now? The `x₀ = 0`
proof already isolates the `log` increment via `Real.log_le_sub_one_of_pos`, and the
extra `½ᾱ_t(x₀²-1)` term is handled by the same `diffusionAlphaBar_strictAnti`
monotonicity, so the generalization is a bookkeeping extension of an existing proof.

**Falsifiable test**: prove `diffusionKLToTarget β x₀ (t+1) ≤ diffusionKLToTarget β x₀ t`
for `t ≥ 1` under the hypothesis `x₀^2 ≤ 1`.

## 3. Quantitative O(1/T) continuous-time discretization error

`diffusionAlphaBar_continuous_upper` proves `ᾱ_T ≤ exp(-β)` for the step size `β/T`,
and `diffusionAlphaBar_constant_sandwich` supplies the matching lower bound
`exp(-T·(b/(1-b))) ≤ ᾱ_T`. The conjecture: these combine into the two-sided
discretization estimate `exp(-β) - ᾱ_T ≤ β²/(2(T-β))`, an explicit `O(1/T)` rate for
the convergence of the discrete DDPM to its continuous-time SDE limit.

The key insight is that the lower sandwich exponent is
`T·((β/T)/(1-β/T)) = β·T/(T-β) = β + β²/(T-β)`, so
`exp(-β) - ᾱ_T ≤ exp(-β) - exp(-β - β²/(T-β)) ≤ β²/(T-β)·exp(-β) ≤ β²/(T-β)`, using only
the convexity bound `exp(-β) - exp(-β-ε) ≤ ε·exp(-β)` (a rearrangement of
`one_sub_le_exp_neg`). Why now? Both halves of the sandwich are now formalized; the
only missing ingredient is the elementary local Lipschitz estimate for `exp`, already
available through `Real.add_one_le_exp`.

**Falsifiable test**: prove
`Real.exp (-B) - diffusionAlphaBar (fun _ => B/T) n ≤ B^2 / (T - B)` for `0 < B < T`
and `(n:ℝ) = T`, deriving it from `diffusionAlphaBar_constant_sandwich` and the
exponential convexity bound.

## 4. Bottleneck-coordinate domination of the anisotropic rate

`multiDiffusionKLToTarget_le` bounds the total `d`-dimensional KL by the sum of the
per-coordinate scalar bounds. The conjecture: the total KL decays at the rate of the
*slowest* coordinate, i.e. `multiDiffusionKLToTarget d β x₀ t ≤ d · M_t` where
`M_t = max_j (ᾱ_t^{(j)}·(x₀^{(j)})²/2 + (ᾱ_t^{(j)})²/(2(1-ᾱ_t^{(j)})))`, so a single
badly-conditioned coordinate dictates the global convergence time.

The key insight is that once each summand is bounded (which `multiDiffusionKLToTarget_le`
already gives termwise), the sum is dominated by its maximum scaled by the cardinality
via `Finset.sum_le_card_nsmul`, turning the additive bound into a `max`-controlled one.
Why now? The summed bound is proved, so the maximum-domination step is a pure
`Finset.sum_le_card_nsmul` assembly requiring no new analytic inequality.

**Falsifiable test**: with `M` an explicit per-coordinate upper bound and
`hM : ∀ j, (per-coordinate bound j) ≤ M`, prove
`multiDiffusionKLToTarget d β x₀ t ≤ d • M` via `Finset.sum_le_card_nsmul`.

## 5. Variational characterization of the DDPM reverse step

`multiGaussianKL_self` / `multiGaussianKL_nonneg` (and their scalar parents
`univGaussianKL_self`, `univGaussianKL_nonneg`) establish that the KL is non-negative
and vanishes exactly when the parameters match. The conjecture: among all Gaussians
with a fixed variance `σ²`, the mean `μ_θ` that matches the true posterior mean is the
*unique* minimizer of `univGaussianKL · σ μ_true σ`, with minimum value `0` — the
variational justification for the DDPM noise-prediction objective.

The key insight is that `univGaussianKL μ σ μ_true σ = (μ - μ_true)²/(2σ²)` after the
`log` and variance terms cancel (exactly the cancellation inside `univGaussianKL_self`),
so the global lower bound `0` from `univGaussianKL_nonneg` is attained iff
`(μ - μ_true)² = 0`, i.e. `μ = μ_true`, by `sq_eq_zero_iff`. Why now? The vanishing-on-
equality and non-negativity lemmas are both proved, so the minimizer/uniqueness claim
reduces to the elementary `sq_eq_zero_iff` argument with no probability theory.

**Falsifiable test**: prove
`univGaussianKL μ σ μ_true σ = (μ - μ_true)^2 / (2*σ^2)` for `0 < σ`, then derive that
it equals `0` iff `μ = μ_true`, exhibiting `μ = μ_true` as the unique global minimizer.
