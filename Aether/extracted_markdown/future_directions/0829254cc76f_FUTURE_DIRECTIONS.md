# Future Directions: Diffusion Models as SDEs III

This cycle added `Catalog/Physics/DiffusionSDEFlow.lean`, which extends the
Ornstein–Uhlenbeck (OU) moment infrastructure of `Catalog/Physics/DiffusionSDE.lean`
(`ouMean`, `ouVariance`, `ouStationaryVariance`, `klDivGaussian`,
`ou_mean_tendsto_zero`, `ou_variance_tendsto_stationary`,
`kl_div_gaussian_self_eq_zero`, `kl_div_gaussian_nonneg`, `ou_variance_pos`)
with four new pieces of analytic machinery, all proved without `sorry` and
using only the standard axioms:

1. **The Gaussian score is the derivative of the log-density**
   (`gaussian_score_hasDerivAt`, `gaussian_score_eq_logDensity_deriv`,
   `gaussian_log_density_eq`): `∇ₓ log p_{N(m,v)}(x) = -(x-m)/v`.
2. **The reverse-time drift is affine in `x`** (`ou_reverse_drift_affine`) and,
   at stationarity with zero mean, equals the *negated* forward drift
   (`ou_reverse_drift_stationary`) — the formal statement of time-reversibility
   / detailed balance for the OU stationary measure.
3. **Explicit exponential decay of the variance deviation**
   (`ou_variance_sub_stationary`): `v(t) - v∞ = (v₀ - v∞)·exp(-2θt)`, and the
   resulting **monotone contraction** (`ou_variance_deviation_antitone`).
4. **The KL convergence guarantee** (`kl_flow_tendsto_zero`): the OU marginal
   converges to its stationary Gaussian in Kullback–Leibler divergence as
   `t → ∞`, obtained by composing the catalog moment limits with the continuity
   of `klDivGaussian` and evaluating via `kl_div_gaussian_self_eq_zero`.

The directions below are testable, falsifiable extensions that build directly on
these results and on the existing catalog.

---

## Direction 1: Monotone KL divergence along the OU flow (a true Lyapunov function)

**Conjecture.** For `θ > 0`, `σsq > 0`, `v₀ > 0`, the composed function
`t ↦ klDivGaussian (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) 0 (ouStationaryVariance σsq θ)`
is `Antitone` on `[0, ∞)`.

**Test.** Split the KL into a mean part `m₀² exp(-2θt) / (2 v∞)` and a variance
part `f(v(t))` with `f(v) = ½(log(v∞/v) + v/v∞ - 1)`. The mean part is manifestly
antitone (catalog `ou_mean_tendsto_zero` already controls its decay). For the
variance part, combine the new `ou_variance_deviation_antitone` with the fact
that `f` is convex with its unique minimum at `v = v∞`, so `f` is monotone in
`|v - v∞|`. Prove an auxiliary lemma `f_monotone_in_abs_dev` and compose.

**The key insight is** that `f` depends on `v(t)` only through the *magnitude*
`|v(t) - v∞|`, which `ou_variance_deviation_antitone` already shows is antitone —
so monotonicity of KL reduces to monotonicity of a one-variable convex function
of that magnitude, with no calculus on the composite needed.

**Why now?** We just proved both ingredients: `kl_div_gaussian_nonneg` (the
target is bounded below by 0, the floor of the Lyapunov function) and
`ou_variance_deviation_antitone` (monotone contraction). The only missing piece
is the scalar convexity lemma for `f`.

**If true:** gives the first formal Lyapunov function for OU dynamics in this
catalog, the backbone of DDPM/score-matching convergence proofs.
**If false:** would localize the failure to a parameter regime where mean and
variance decay rates interact non-monotonically, pinpointing a hypothesis gap.

---

## Direction 2: Quantitative exponential KL decay rate

**Conjecture.** There is an explicit constant `C = C(m₀, v₀, σsq, θ) ≥ 0` with
`klDivGaussian (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) 0 (ouStationaryVariance σsq θ) ≤ C · exp(-2θt)`
for all `t ≥ 0`.

**Test.** Bound the mean part directly by `(m₀²/(2v∞))·exp(-2θt)` using
`ouMean`'s closed form. For the variance part use `ou_variance_sub_stationary`
together with the elementary bound `log(1+u) ≥ u - u²` (or `½(log(v∞/v)+v/v∞-1) ≤
K·(v-v∞)²` near `v∞`) to convert the squared deviation `(v₀-v∞)²exp(-4θt)` into a
multiple of `exp(-2θt)`. Sum the two bounds.

**The key insight is** that both KL summands are already *explicit exponentials*
in `t` once `ou_variance_sub_stationary` is substituted, so the rate `exp(-2θt)`
can be read off without any abstract functional analysis — only scalar
inequalities on `log`.

**Why now?** `kl_flow_tendsto_zero` establishes the qualitative limit; upgrading
"tends to 0" to "decays at rate `exp(-2θt)`" needs only the explicit decay
identity we just proved plus a one-line `log` inequality already in Mathlib
(`Real.add_one_le_exp` / `Real.log_le_sub_one_of_pos`).

**If true:** yields a quantitative mixing-time bound `t = O(θ⁻¹ log(1/ε))`.
**If false:** the variance term's quadratic-vs-linear balance would expose a
sharper rate, still informative.

---

## Direction 3: Fokker–Planck verification for the Gaussian marginal

**Conjecture.** With `p(x,t) := gaussianDensity (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) x`,
the density satisfies, for `t > 0` (where the variance is positive by
`ou_variance_pos`) and all `x`, the pointwise PDE
`∂ₜ p = θ·∂ₓ(x·p) + (σsq/2)·∂ₓₓ p`.

**Test.** We already have `gaussian_score_hasDerivAt` (the `x`-derivative of
`log p`) and `gaussian_log_density_eq`. Differentiate `log p` once more in `x`
for `∂ₓₓ`, and differentiate the moment functions in `t` (the ODEs
`dm/dt = -θm`, `dv/dt = -2θv + σsq`, both `HasDerivAt`-provable from the closed
forms). Assemble via `HasDerivAt`/`HasDerivAt.comp` and reduce the identity to an
algebraic relation between the moment ODEs and the Gaussian derivatives.

**The key insight is** that for a Gaussian, every derivative of `p` is `p` times
a polynomial in `(x-m)/v`, so the PDE collapses to a *polynomial identity* in
`x`, `m(t)`, `v(t)` once the moment ODEs are substituted — no PDE theory, only
`HasDerivAt` algebra we have already exercised here.

**Why now?** `gaussian_score_hasDerivAt`, `gaussian_log_density_eq`, and
`ou_variance_pos` are exactly the calculus prerequisites; the moment ODEs are
one-line `HasDerivAt` facts about `exp`.

**If true:** bridges the moment-level description to the distributional
(physics) description, closing the gap flagged in the previous cycle.
**If false:** would reveal a missing `HasDerivAt` composition lemma for the
exp-of-rational-of-`t` structure, a concrete Mathlib target.

---

## Direction 4: Reverse process is OU with time-reversed parameters

**Conjecture.** The reverse-time drift `ouReverseDrift θ σsq m(t) v(t) x`, with
`m(t) = ouMean`, `v(t) = ouVariance`, is, for each fixed `t`, the drift of an
OU process: there exist `A(t) > 0` and `b(t)` with
`ouReverseDrift θ σsq (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) x = -A(t)·(x - b(t))`,
and at stationarity `A → θ`, `b → 0` (recovering `ou_reverse_drift_stationary`).

**Test.** Apply `ou_reverse_drift_affine` to get slope `σsq/v(t) - θ` and
intercept; set `A(t) = θ - σsq/v(t)` and `b(t) = (σsq m(t)/v(t))/A(t)`. Prove the
sign of `A(t)` for `t` large (where `v(t) → v∞ = σsq/(2θ)`, giving `A → θ > 0`),
and show `A(t), b(t)` converge using `ou_variance_tendsto_stationary` and
`ou_mean_tendsto_zero`.

**The key insight is** that `ou_reverse_drift_affine` already certifies the drift
is affine, so "the reverse process is OU" is just the statement that an affine
drift with negative slope *is* an OU drift — a definitional repackaging plus a
sign analysis driven by the catalog variance limit.

**Why now?** `ou_reverse_drift_affine` and `ou_reverse_drift_stationary` are
freshly proved, and the limits of the affine coefficients are immediate from the
catalog convergence theorems.

**If true:** completes the structural loop forward-OU → score → reverse-OU,
the mathematical reason score-based generative models recover the data
distribution.
**If false:** the slope could fail to be negative for small `t` (when
`v(t) < σsq/θ`), identifying a precise time threshold after which reversibility
holds — itself a publishable refinement.

---

## Direction 5: Multivariate OU via simultaneous diagonalization

**Conjecture.** For a symmetric positive-definite `A : Matrix (Fin n) (Fin n) ℝ`
and isotropic noise `B = σ·I`, the covariance `Σ(t)` of the multivariate OU
process converges to the Lyapunov solution `A Σ∞ + Σ∞ Aᵀ = σ²I`, and in the
eigenbasis of `A` the system decouples into `n` independent scalar OU processes
to which all results of this file apply coordinatewise.

**Test.** Diagonalize `A = Q D Qᵀ` (Mathlib spectral theorem for symmetric
matrices). In the rotated coordinates each eigen-component evolves by the scalar
`ouVariance` with rate `θ = dᵢ`, so `ou_variance_tendsto_stationary` and
`ou_variance_sub_stationary` lift verbatim. Reassemble `Σ(t)` by conjugation and
verify the Lyapunov equation.

**The key insight is** that isotropic noise commutes with the rotation `Q`, so
the multivariate convergence reduces to `n` *independent* invocations of the
already-proved scalar theorems — no genuinely new analysis, only linear-algebra
bookkeeping.

**Why now?** Mathlib has the spectral theorem and `Matrix.IsHermitian`
eigendecomposition; the scalar engine (`ouVariance`, `ou_variance_sub_stationary`,
`ou_variance_tendsto_stationary`) is in place. The only new work is the
change-of-basis plumbing.

**If true:** opens formalization of practical high-dimensional diffusion models.
**If false:** would surface a specific gap in Mathlib's symmetric-matrix
eigenbasis API (e.g. functoriality of `Matrix.exp` under conjugation), a
concrete contribution target.
