# Future Directions: Diffusion Model Noise Schedule Algebra

These directions extend the new results in
`Catalog/Pythagorean/DiffusionScheduleExtensions.lean`, which now establishes:
the variational core of the Gaussian KL (`univGaussianKL_same_var`,
`univGaussianKL_same_var_eq_zero_iff`), the identity equating a DDPM reverse step's
KL with a weighted noise-prediction MSE (`ddpm_kl_eq_noise_mse`,
`ddpm_kl_zero_iff`), a two-sided exponential envelope for the constant schedule
(`diffusionAlphaBar_const_two_sided`) and its continuous-time corollary
(`continuousLimit_two_sided`), and the additive anisotropic KL
(`multiGaussianKL_nonneg`, `multiGaussianKL_self`).

## 1. Tight per-coordinate ELBO from the noise-MSE identity

The identity `ddpm_kl_eq_noise_mse` rewrites a single reverse step as
`βt/(2·αt·(1-ᾱt))·(εθ-ε)²`. Summing these scalar KLs over the `Fin d` coordinates
of `multiGaussianKL` should yield a *closed-form, fully algebraic* evidence lower
bound (ELBO) for an anisotropic DDPM: a finite sum of weighted squared noise errors
plus a schedule-dependent constant, with the per-step weights being exactly the
`βt/(2·αt·(1-ᾱt))` factors. The conjecture is that the total reverse-process KL is
this sum and is minimized coordinatewise precisely when every predicted noise equals
its true noise.

The key insight is that because `multiGaussianKL` is literally a `Finset.sum` of the
scalar KLs and each scalar KL is *already* a perfect square (no cross terms, by
`ddpm_kl_eq_noise_mse`), the multivariate objective separates with no interaction —
so the global minimizer is the coordinatewise minimizer, provable by
`Finset.sum_eq_zero` together with `ddpm_kl_zero_iff`. Why now? Both ingredients are
in hand and in the same file; the only new work is the bookkeeping `Finset.sum`
lemma, which needs no measure theory.

**Falsifiable test**: Define `ddpmTotalKL d (αt ᾱt βt : Fin d → ℝ) (x ε εθ : Fin d → ℝ)`
as `∑ j, univGaussianKL (ddpmMeanNoiseForm (αt j) (ᾱt j) (βt j) (x j) (ε j)) (Real.sqrt (βt j)) …`
and prove it equals `∑ j, βt j/(2·αt j·(1-ᾱt j))·(εθ j - ε j)²`, hence is `0` iff `εθ = ε`.

## 2. Monotone tightness of the constant-schedule envelope

`continuousLimit_two_sided` squeezes `ᾱ_T` for `β_i = β/T` between `exp(-(β+β²/T))`
and `exp(-β)`. The conjecture is that the *gap* `exp(-β) - ᾱ_T` is itself monotone
decreasing in `T` for fixed `β` (with `2β ≤ T`), so refining the discretization never
moves `ᾱ_T` away from the continuous limit — a discrete-to-continuous monotone
convergence statement, not merely a two-sided bound.

The key insight is that `ᾱ_T = (1-β/T)^T` and the classical fact that
`(1+x/n)^n` is monotone in `n`; transported to `x = -β`, the sequence `(1-β/T)^T`
is monotone increasing toward `exp(-β)`, so the envelope from
`diffusionAlphaBar_const_two_sided` is tightened, not just preserved, by larger `T`.
Why now? The lower envelope already pins `ᾱ_T` from below at distance `O(β²/T)`, so
the remaining step is the monotonicity of `(1-β/T)^T`, a clean inequality between two
finite products that the constant-schedule lemma `diffusionAlphaBar_const` reduces to
pure powers.

**Falsifiable test**: Prove `diffusionAlphaBar (fun _ => β/T) T ≤ diffusionAlphaBar (fun _ => β/(T+1)) (T+1)`
for `0 ≤ β` and `2β ≤ T`, i.e. the discrete cumulative signal increases monotonically
toward `exp(-β)`.

## 3. SNR half-life is a logarithmic schedule integral

With the explicit two-sided envelope, the step `t½` at which the signal-to-noise
ratio `ᾱ_t/(1-ᾱ_t)` first drops below `1` (equal signal and noise power) is
controlled by the cumulative noise `∑_{i<t} β_i`. The conjecture: for any schedule
with `0 < β_i < 1`, `SNR_t ≤ 1` as soon as `∑_{i<t} β_i ≥ log 2`, and for the
constant schedule this threshold is *sharp* up to the `O(c²)` envelope width.

The key insight is that `SNR_t ≤ 1 ⇔ ᾱ_t ≤ 1/2`, and `diffusionAlphaBar_exp_bound`
gives `ᾱ_t ≤ exp(-∑β)`, so `∑β ≥ log 2` forces `ᾱ_t ≤ 1/2`; the lower envelope
`diffusionAlphaBar_const_ge` then shows the constant-schedule threshold cannot occur
much earlier, pinning the half-life between two explicit cumulative-noise levels.
Why now? The upper bound is immediate from the existing exponential bound and the
matching lower bound is exactly what the new `diffusionAlphaBar_const_two_sided`
supplies; the SNR algebra is the already-formalized `ᾱ/(1-ᾱ)`.

**Falsifiable test**: Prove that if `∑ i ∈ Finset.range t, β i ≥ Real.log 2` and each
`β i < 1`, then `diffusionAlphaBar β t / (1 - diffusionAlphaBar β t) ≤ 1` (under
`1 ≤ t`).

## 4. KL to the stationary Gaussian decays at the schedule rate

Combining the variational core with the envelope yields a convergence rate of the
forward marginal to its stationary `N(0,1)` law. For a point mass at `x₀`, the
forward marginal is `N(√ᾱ_t·x₀, 1-ᾱ_t)`. The conjecture: there is a regime
`ᾱ_t ≤ 1/2` in which `univGaussianKL (√ᾱ_t·x₀) (√(1-ᾱ_t)) 0 1 ≤ (1+x₀²)·ᾱ_t`, i.e.
the KL to the target decays at least as fast as the cumulative signal `ᾱ_t`, which by
`diffusionAlphaBar_exp_bound` is exponential in `∑β`.

The key insight is that, expanding the closed form, the KL equals
`-½log(1-ᾱ_t) - ᾱ_t/2 + ᾱ_t·x₀²/2`, and the only non-polynomial term `-½log(1-a)` is
bounded by `a` precisely when `-log(1-a) ≤ 2a`, which holds for `a ≤ 1/2`; the same
derivative/MVT technique already used to prove `diffusionAlphaBar_const_ge`
discharges this scalar inequality. Why now? The closed form `univGaussianKL` and the
shared-variance simplification are formalized, and the lone analytic lemma reuses the
monotone-on-`[0,1/2]` argument already present in the file.

**Falsifiable test**: Prove for `0 < a ≤ 1/2` that
`univGaussianKL (Real.sqrt a * x₀) (Real.sqrt (1-a)) 0 1 ≤ (1 + x₀^2) * a`, then
specialize `a = diffusionAlphaBar β t` under `diffusionAlphaBar β t ≤ 1/2`.

## 5. Strict convexity of the reverse KL in the predicted mean

`univGaussianKL_same_var` shows the shared-variance KL is the quadratic
`(μ₁-μ₂)²/(2σ²)`. The conjecture: as a function of the predicted mean `μ`, the map
`μ ↦ univGaussianKL μ₁ σ μ σ` is *strictly convex* with a unique global minimum at
`μ = μ₁`, and more strongly its second difference is the constant `1/σ²` — giving a
fully explicit curvature for the reverse-step objective and certifying that
gradient-style updates on the predicted mean cannot stall away from the optimum.

The key insight is that `univGaussianKL_same_var` collapses the objective to a pure
parabola, whose strict convexity and unique minimizer are then `nlinarith`/`StrictConvexOn`
facts, while `univGaussianKL_same_var_eq_zero_iff` already certifies the minimizer is
the true mean. Why now? The quadratic reduction is proved, so convexity is a finite
algebraic statement requiring none of the Gaussian's analytic structure — exactly the
kind of clean, self-contained result the current file is built to support.

**Falsifiable test**: Prove `StrictConvexOn ℝ Set.univ (fun μ => univGaussianKL μ₁ σ μ σ)`
for `0 < σ`, and that its unique minimizer is `μ = μ₁` with minimum value `0`.
