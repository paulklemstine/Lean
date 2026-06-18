# Future Directions: Diffusion Model Noise Schedule Algebra

This document outlines research directions extending the formalized noise schedule
theory in `Pythagorean/DiffusionSchedule.lean`, which establishes the exponential
decay bound, Gaussian KL properties, and SNR monotonicity for discrete diffusion
processes.

## 1. KL Divergence Convergence Rate Along the Forward Process

The exponential decay bound `diffusionAlphaBar_exp_bound` shows ᾱ_t ≤ exp(-∑β_i),
but does not directly quantify how fast the forward marginal converges to the
stationary Gaussian in KL divergence. The conjecture: for a point-mass initial
distribution at x₀, the KL to standard Gaussian satisfies
KL(p_t ‖ N(0,1)) ≤ C(x₀) · ᾱ_t where C(x₀) depends polynomially on |x₀|.

The key insight is that the data processing inequality for Gaussian channels gives
a per-step contraction factor of exactly (1-β_t) in KL, and telescoping yields
the ᾱ_t bound. Why now? We have `univGaussianKL_nonneg` and the full noise schedule
machinery; the missing piece is the data processing inequality for scalar Gaussian
channels, which is a clean finite-dimensional statement not requiring abstract
measure theory.

**Falsifiable test**: Define `diffusionKLToTarget sched x₀ t` using `univGaussianKL`
with the forward marginal parameters (√ᾱ_t·x₀, √(1-ᾱ_t)) against N(0,1), and prove
the bound `diffusionKLToTarget sched x₀ t ≤ (1 + x₀²) * diffusionAlphaBar β t / 2`.

## 2. Optimal Linear Noise Schedule

For a linear schedule β_t = β_min + t·(β_max - β_min)/(T-1), the cumulative noise
∑β_i = T·(β_min + β_max)/2 grows linearly, so ᾱ_T ≤ exp(-T·(β_min+β_max)/2).
The conjecture: among all schedules with fixed endpoints β_0 = β_min, β_{T-1} = β_max,
the linear schedule minimizes max_t |SNR_t - SNR_{t-1}|, i.e., it produces the most
uniform SNR spacing.

The key insight is that uniform SNR spacing corresponds to equal per-step information
loss, and the linear schedule achieves this when β_t varies slowly relative to ᾱ_t.
Why now? The `diffusionSNR_strictAnti` theorem provides the monotonicity framework,
and the explicit SNR formula `ᾱ_t/(1-ᾱ_t)` makes the optimization problem purely
algebraic over finite products.

**Falsifiable test**: For T=3 with β_0=0.1, β_2=0.3, compare SNR spacing for linear
vs. geometric schedules using `#eval` on rational approximations.

## 3. Reverse Process Step as KL Minimization

Each reverse diffusion step approximates the posterior p(x_{t-1}|x_t), which for
Gaussian forward process is itself Gaussian with mean and variance determined by
ᾱ_t, ᾱ_{t-1}, and β_t. The conjecture: the DDPM reverse step with predicted noise
ε_θ is the unique minimizer of `univGaussianKL` between the true posterior and a
Gaussian with the predicted mean, holding variance fixed at the DDPM schedule
σ_t² = β_t.

The key insight is that `univGaussianKL_self` shows KL=0 when the predicted noise
exactly matches the true noise, and `univGaussianKL_nonneg` provides the lower bound.
Why now? The `univGaussianKL` definition and its properties give us the variational
characterization; the remaining work is expressing the DDPM posterior in terms of the
noise schedule parameters using `diffusionAlphaBar_succ`.

**Falsifiable test**: Prove that for the posterior mean formula
μ_θ = (x_t - β_t/√(1-ᾱ_t)·ε_θ) / √(1-β_t), setting ε_θ = ε (the true noise)
yields `univGaussianKL ... = 0`.

## 4. Continuous-Time Limit of the Exponential Bound

As T → ∞ with β_t = β/T for constant β, the discrete ᾱ_T = (1-β/T)^T converges to
exp(-β). The exponential bound `diffusionAlphaBar_exp_bound` becomes tight in this
limit. The conjecture: |ᾱ_T - exp(-β)| ≤ β²/(2T) for the constant schedule β_t = β/T,
providing a quantitative convergence rate.

The key insight is that log(1-β/T) = -β/T - β²/(2T²) + O(T⁻³), so
log ᾱ_T = T·log(1-β/T) = -β - β²/(2T) + O(T⁻²), giving the rate.
Why now? The `one_sub_le_exp_neg` inequality already captures one direction; the
other direction (lower bound on 1-x vs exp(-x)) is a symmetric argument using
the Taylor remainder of the exponential.

**Falsifiable test**: Prove that for β_t = β/T with 0 < β < T, we have
exp(-β - β²/T) ≤ ᾱ_T ≤ exp(-β).

## 5. Multi-Dimensional Extension: Anisotropic Noise Schedules

The current theory treats scalar noise. In practice, diffusion models operate in
ℝ^d with potentially different noise schedules per coordinate (anisotropic noise).
The conjecture: for coordinate-wise schedules β_t^(j), the multivariate Gaussian KL
decomposes as a sum: KL(p_t ‖ N(0,I)) = ∑_j KL_j where KL_j depends only on
the j-th coordinate's schedule.

The key insight is that independent coordinate-wise noise preserves the product
structure of the marginal, so the KL additivity follows from the chain rule for
KL divergence applied to independent coordinates. Why now? Our `univGaussianKL`
is the building block; the extension to finite products requires only `Finset.sum`
of the scalar KL terms, which connects naturally to the existing
`diffusionAlphaBar_exp_bound` applied coordinate-wise.

**Falsifiable test**: Define `multiGaussianKL (d : ℕ) (μ₁ σ₁ μ₂ σ₂ : Fin d → ℝ)`
as `∑ j, univGaussianKL (μ₁ j) (σ₁ j) (μ₂ j) (σ₂ j)` and prove non-negativity
from `univGaussianKL_nonneg` via `Finset.sum_nonneg`.
