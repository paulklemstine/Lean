# Future Directions: KL Convergence Along the Forward Diffusion Process

The file `Catalog/Physics/DiffusionForwardKL.lean` proves that the forward
marginal of a DDPM forgets its initial condition *exponentially fast* in KL
divergence: once the schedule has destroyed half the signal
(`ᾱ_t ≤ ½`), `forwardMarginalKL_exp_decay` gives

  KL(q(x_t∣x₀) ‖ N(0,1)) ≤ ½(1 + x₀²)·exp(−∑_{i<t} β_i).

This bound fuses the noise-schedule algebra of `Pythagorean.DiffusionSchedule`
(`diffusionAlphaBar_exp_bound`, `one_sub_le_exp_neg`) with the Gaussian
information theory of `Physics.DiffusionSDE` (`klDivGaussian`,
`kl_div_gaussian_nonneg`).  We also pin down the boundary: `forwardMarginalKL_blowup`
shows the half-signal hypothesis is genuinely necessary, since the KL diverges as
`a → 1⁻`.  Five concrete, falsifiable directions extend this work.

## 1. Data-distribution KL via the second-moment bound

The current bound is *pointwise in `x₀`*. Averaging `forwardMarginalKL_exp_decay`
over a data distribution with finite second moment `E[x₀²] = M` should give a
prior-matching bound `KL(q_t ‖ N(0,1)) ≤ ½(1+M)·exp(−∑β_i)` for the *mixture*
marginal, by convexity of KL in its first argument.

The key insight is that the `x₀`-dependence in our bound is *linear in `x₀²`*, so
the only data statistic that survives averaging is the second moment — the bound
is dimension-free and distribution-free beyond `M`. Why now? Both the pointwise
bound and `kl_div_gaussian_nonneg` are already formalized; the missing ingredient
is the convexity-of-KL lemma, which is a clean, self-contained target.

## 2. Mixing time of the forward schedule

Define the ε-mixing time `T(ε) = min { t : KL(q_t ‖ N(0,1)) ≤ ε }`. The
exponential bound implies `T(ε) ≤ ` the first `t` with
`∑_{i<t} β_i ≥ log((1+x₀²)/(2ε))`. For a constant schedule `β_i ≡ β`, this is
`T(ε) = O(β⁻¹ log(1/ε))`.

The key insight is that mixing time is *logarithmic in the target accuracy* — a
direct corollary of exponential decay, turning a continuous bound into a discrete
step count. Why now? `diffusionAlphaBar_exp_bound` already lower-bounds the
accumulated noise; formalizing `T(ε)` only needs `Nat.find` plus monotonicity of
partial sums, both readily available.

## 3. Tight constant: replacing ½(1+x₀²) by the exact rate near `a = 0`

Our constant `½(1+x₀²)` comes from the coarse step `a²/(1−a) ≤ a` valid for
`a ≤ ½`. The closed form `forwardMarginalKL_eq` shows the true leading behaviour
near `a = 0` is `KL = ½ x₀²·a + O(a²)`, with the variance term contributing only
`¼ a²`. A sharper theorem should give `KL ≤ ½ x₀²·a + a²` with no `a ≤ ½`
restriction (only `a ≤ 1 − δ`).

The key insight is that the *mean* term `½ a x₀²` dominates the *variance* term
`½(−log(1−a) − a) = ¼a² + O(a³)` to first order, so the signal — not the variance
mismatch — controls early convergence. Why now? `forwardMarginalKL_eq` and
`forwardMarginalKL_ge_mean` already isolate these two contributions; a matching
upper bound on the variance term via `−log(1−a) − a ≤ a²/(1−a)` is in hand.

## 4. Reverse-process error propagation

The forward bound controls how close `q_T` is to the prior; the *reverse* process
starts from `N(0,1)` instead of `q_T`, incurring an initialization error of
exactly `forwardMarginalKL (ᾱ_T) x₀`. A data-processing/triangle argument should
bound the total reverse-process KL by this initialization error plus the
per-step score-matching errors.

The key insight is that our exponential bound *is* the initialization-error term
in the standard diffusion-model error decomposition — making the prior-matching
error provably negligible (`exp(−∑β)`) compared to score-estimation error. Why
now? The forward half is now fully formalized; the reverse half needs only an
additive KL-chain inequality, a natural next lemma over `klDivGaussian`.

## 5. Variance-exploding (VE) schedules and the OU bridge

`Physics.DiffusionSDE` already models the Ornstein–Uhlenbeck (variance-preserving)
SDE with `ou_variance_tendsto_stationary`. A parallel `forwardMarginalKL` for the
variance-exploding regime (variance `σ²_t → ∞`, no signal rescaling) should show
KL convergence governed by `−log σ_t` rather than `∑β_i`, i.e. *polynomial* not
exponential mixing.

The key insight is that VP and VE schedules differ precisely in whether the
signal term decays geometrically (VP, our `ᾱ_t`) or the noise term grows (VE),
predicting qualitatively different — exponential vs. sub-exponential — mixing
rates. Why now? The OU mean/variance ODE solutions are already proved in
`Physics.DiffusionSDE`; bridging them to `klDivGaussian` reuses exactly the
machinery assembled in this cycle.
