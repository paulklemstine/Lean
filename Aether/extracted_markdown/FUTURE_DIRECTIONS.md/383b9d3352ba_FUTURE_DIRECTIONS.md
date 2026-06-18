# Future Directions: Diffusion Model KL Convergence Algebra

This document extends the work in `Pythagorean/DiffusionKLConvergence.lean`, which
proved a two-sided exponential sandwich for the cumulative signal-retention ᾱ_t
(`diffusionAlphaBar_exp_lower_bound` complementing the catalog's
`diffusionAlphaBar_exp_bound`), an explicit O(ᾱ_t) convergence-rate bound for the
KL divergence of the forward marginal to the standard Gaussian
(`diffusionKLToTarget_le`), and the additivity/non-negativity scaffolding for the
anisotropic, coordinate-wise Gaussian KL (`multiGaussianKL_nonneg`,
`multiGaussianKL_self`). The five directions below each name the specific lemmas
they would build on.

## 1. Tightness of the convergence-rate constant

`diffusionKLToTarget_le` gives KL ≤ ᾱ_t·x₀²/2 + ᾱ_t²/(2(1-ᾱ_t)). Numerically the
ratio of the bound to the true KL tends to a finite constant (≈2 for x₀=0 as ᾱ_t→0).
The conjecture: there is a matching lower bound KL ≥ c·(ᾱ_t·x₀² + ᾱ_t²) for an
explicit c>0 uniformly in t once ᾱ_t ≤ 1/2, so the convergence rate is exactly
Θ(ᾱ_t·(1 + x₀²)).

The key insight is that the same Taylor control that yields -log(1-a) ≤ a/(1-a) from
above also yields -log(1-a) ≥ a from below (`one_sub_le_exp_neg` rearranged), and
the two sandwich the log term to within a constant factor on (0,1/2]. Why now? The
upper bound is already formalized via `Real.log_le_sub_one_of_pos`; the lower bound
needs only the already-available `Real.add_one_le_exp`, so both halves live in the
same elementary toolbox with no new analytic machinery.

**Falsifiable test**: Prove `diffusionKLToTarget β x₀ t ≥ diffusionAlphaBar β t * x₀^2 / 2`
for t ≥ 1 (the pure mean-displacement term is always a lower bound), then strengthen
to include an ᾱ_t² variance term valid when `diffusionAlphaBar β t ≤ 1/2`.

## 2. Monotone decay of KL along the forward process

`diffusionAlphaBar_strictAnti` shows ᾱ_t strictly decreases, and `diffusionKLToTarget_le`
bounds KL by an increasing function of ᾱ_t. The conjecture: the KL to the target is
itself eventually monotone decreasing in t, i.e. `diffusionKLToTarget β x₀ (t+1) ≤
diffusionKLToTarget β x₀ t` once ᾱ_t is small enough (specifically once the marginal
variance exceeds the squared mean displacement).

The key insight is that KL = ½(ᾱ_t(x₀²-1) - log(1-ᾱ_t)) is a smooth function g(ᾱ_t)
whose derivative g'(a) = ½(x₀² - 1 + 1/(1-a)) is negative precisely when
1/(1-a) < 1 - x₀², which fails for a near 1 but the *composition* with the
decreasing ᾱ_t can still be monotone via the chain rule. Why now? Monotonicity of
the scalar map and antitonicity of ᾱ_t are both in hand; the remaining step is a
single `StrictMonoOn`/`Antitone` composition argument analogous to the existing
`diffusionSNR_strictAnti` proof.

**Falsifiable test**: Define the monotonicity predicate and prove
`diffusionKLToTarget β 0 (t+1) ≤ diffusionKLToTarget β 0 t` for the special case
x₀ = 0 (pure variance relaxation), where g(a) = -½log(1-a) is manifestly increasing
in a and ᾱ_t is decreasing.

## 3. Anisotropic convergence rate from coordinate-wise schedules

`multiGaussianKL_nonneg` and `multiGaussianKL_self` establish the additive product
structure of the anisotropic KL. The conjecture: a multi-dimensional analogue of
`diffusionKLToTarget_le` holds, namely the total KL of a d-dimensional forward
marginal with per-coordinate schedules β^(j) to N(0,I) is bounded by
∑_j (ᾱ_t^(j)·(x₀^(j))²/2 + (ᾱ_t^(j))²/(2(1-ᾱ_t^(j)))), and hence decays at the rate
of the *slowest* coordinate, max_j ᾱ_t^(j).

The key insight is that independence makes the multivariate KL the Finset.sum of the
scalar KLs, so the scalar bound `diffusionKLToTarget_le` applies termwise and
`Finset.sum_le_sum` lifts it verbatim — the bottleneck coordinate then dominates via
`Finset.sum_le_card_nsmul` against the maximum. Why now? Both the additive definition
and the scalar bound are already proved, so the multivariate statement is a pure
`Finset.sum_le_sum` assembly with no new inequalities required.

**Falsifiable test**: Define `multiDiffusionKLToTarget` as a Finset.sum of
`diffusionKLToTarget` over coordinates and prove the summed upper bound by applying
`diffusionKLToTarget_le` inside `Finset.sum_le_sum`.

## 4. Continuous-time error rate for the constant schedule

`diffusionAlphaBar_constant_sandwich` proves exp(-t·b/(1-b)) ≤ ᾱ_t ≤ exp(-t·b) for a
constant schedule β_i = b. Specializing to b = β/T (so ᾱ_T = (1-β/T)^T → exp(-β)),
the conjecture: |ᾱ_T - exp(-β)| ≤ β²/(2T) — a quantitative O(1/T) discretization
error for the continuous-time SDE limit.

The key insight is that the sandwich bounds give exp(-β·T/(T-β)) ≤ ᾱ_T ≤ exp(-β),
and since T/(T-β) = 1 + β/(T-β), a first-order expansion of exp near -β controls the
gap by β²/(2T) using the convexity bound exp(-β) - exp(-β-ε) ≤ ε·exp(-β) ≤ ε. Why now?
The sandwich is already formalized; the only missing ingredient is the elementary
mean-value/convexity estimate for the exponential, available through
`Real.add_one_le_exp` and the local Lipschitz bound on exp over a bounded interval.

**Falsifiable test**: Prove `diffusionAlphaBar (fun _ => β/T) T ≤ Real.exp (-β)` and
`Real.exp (-β) - diffusionAlphaBar (fun _ => β/T) T ≤ β^2 / T` for 0 < β < T,
deriving the two halves from the constant-schedule sandwich.

## 5. SNR-weighted KL and the variational reverse step

The catalog's `diffusionSNR` and `univGaussianKL_self` together suggest a variational
characterization of the DDPM reverse step. The conjecture: among all Gaussians with a
fixed variance σ_t² = β_t, the posterior mean μ_θ that sets predicted noise ε_θ equal
to the true noise ε is the unique minimizer of `univGaussianKL` against the true
posterior, with minimum value 0.

The key insight is that `univGaussianKL_self` gives KL = 0 exactly when both mean and
variance match, and `univGaussianKL_nonneg` gives the global lower bound, so the
matched-noise mean is a global minimizer; uniqueness follows because the KL is
strictly convex in the mean displacement (μ₁-μ₂)² term. Why now? Non-negativity and
the vanishing-on-equality lemma are both proved, so the minimizer claim reduces to
showing the displacement term (μ₁-μ₂)²/(2σ₂²) is zero iff μ₁=μ₂ — a `sq_eq_zero_iff`
argument requiring no probability theory.

**Falsifiable test**: For the DDPM posterior mean
μ_θ = (x_t - β_t/√(1-ᾱ_t)·ε_θ)/√(1-β_t), prove that substituting ε_θ = ε (true noise)
makes the mean match the true posterior mean and hence
`univGaussianKL (true_mean) σ (μ_θ) σ = 0` via `univGaussianKL_self`.
