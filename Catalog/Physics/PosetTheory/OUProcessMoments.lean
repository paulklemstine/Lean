import Mathlib

/-!
# Variance-Preserving Ornstein–Uhlenbeck Diffusion: Deterministic Moment Backbone

This file formalizes the **deterministic analytic backbone** of the
variance-preserving (VP) Ornstein–Uhlenbeck (OU) diffusion model that underlies
modern score-based generative diffusion. We do **not** develop stochastic
calculus here; instead we treat the closed-form marginal mean and variance as
ordinary real-analytic functions of diffusion time and prove the calculus facts
they satisfy.

## The underlying SDE

The VP-SDE (in the convention with unit noise and decay rate `1/2`) is

  `dX_t = -(1/2) X_t dt + dW_t`,

where `W_t` is standard Brownian motion. For a Gaussian initial law with mean
`m0` and variance `v0`, the marginal law of `X_t` stays Gaussian, with

* mean     `m(t) = m0 · exp(-t/2)`,
* variance `v(t) = 1 + (v0 - 1) · exp(-t)`.

These satisfy the (deterministic) moment ODEs obtained by taking expectations of
the SDE and of Itô's formula for `X_t^2`:

* `m'(t) = -(1/2) m(t)`              (mean decays toward `0`),
* `v'(t) = 1 - v(t)`                 (variance relaxes toward the stationary `1`).

Everything proved below is a statement about these closed-form functions; the
SDE only motivates the definitions. No measure theory or stochastic calculus is
used anywhere in this file.

## Main definitions

* `vpMean m0 t = m0 * exp (-t/2)`
* `vpVar  v0 t = 1 + (v0 - 1) * exp (-t)`
* `gaussianLogDensity m σ x` — Gaussian log-density up to an additive constant
* `gaussianScore m σ x` — the Gaussian score `∂_x log p`

## Main results

* `vpMean_hasDerivAt`  : `m'(t) = -(1/2) m(t)`
* `vpVar_hasDerivAt`   : `v'(t) = 1 - v(t)`
* `vpVar_stationary`   : `v0 = 1 ⇒ v(t) = 1` for all `t`
* `vpMean_tendsto_zero`: `m(t) → 0` as `t → ∞`
* `vpVar_tendsto_one`  : `v(t) → 1` as `t → ∞`
* `vpVar_pos_of_pos`, `vpVar_nonneg_of_nonneg`, `vpVar_pos_of_pos_of_nonneg_time`
  (variance sign facts, on the physically relevant diffusion-time regime `t ≥ 0`)
* `gaussianScore_eq_deriv_logDensity` : the Gaussian score equals `∂_x log p(x)`
  (the additive normalization constant has zero derivative).
-/

noncomputable section
open Filter Real
open scoped Topology

/-- VP/OU marginal **mean** at diffusion time `t` for initial mean `m0`:
`m(t) = m0 · exp(-t/2)`. This is the solution of `m'(t) = -(1/2) m(t)`,
`m(0) = m0`, obtained by taking the expectation of `dX_t = -(1/2) X_t dt + dW_t`. -/
def vpMean (m0 t : ℝ) : ℝ := m0 * Real.exp (-t / 2)

/-- VP/OU marginal **variance** at diffusion time `t` for initial variance `v0`:
`v(t) = 1 + (v0 - 1) · exp(-t)`. This is the solution of `v'(t) = 1 - v(t)`,
`v(0) = v0`, obtained from Itô's formula for the second moment. -/
def vpVar (v0 t : ℝ) : ℝ := 1 + (v0 - 1) * Real.exp (-t)

/-! ### Moment ODEs

We prove the mean and variance satisfy first-order linear ODEs, directly from
the derivative of `Real.exp` and ring normalization. Each proof uses only the
chain rule for `Real.exp` and ring arithmetic; neither theorem is used in the
proof of the other, and there is no circular rewriting. -/

/-- The mean satisfies the moment ODE `m'(t) = -(1/2) · m(t)`. This is the
expectation of the drift term in `dX_t = -(1/2) X_t dt + dW_t`. -/
theorem vpMean_hasDerivAt (m0 t : ℝ) :
    HasDerivAt (vpMean m0) (-(1 / 2) * vpMean m0 t) t := by
  -- `m(t) = m0 * exp(-t/2)`; chain rule gives `m0 * exp(-t/2) * (-1/2)`.
  unfold vpMean
  have hinner : HasDerivAt (fun t : ℝ => -t / 2) (-1 / 2) t :=
    (hasDerivAt_id t).neg.div_const 2
  have hexp := (Real.hasDerivAt_exp (-t / 2)).comp t hinner
  have hfull := hexp.const_mul m0
  convert hfull using 1
  ring

/-- The variance satisfies the moment ODE `v'(t) = 1 - v(t)`. This is the
relaxation equation for the second moment under the VP-SDE. -/
theorem vpVar_hasDerivAt (v0 t : ℝ) :
    HasDerivAt (vpVar v0) (1 - vpVar v0 t) t := by
  -- `v(t) = 1 + (v0 - 1) * exp(-t)`; derivative is `-(v0 - 1) * exp(-t) = 1 - v(t)`.
  unfold vpVar
  have hinner : HasDerivAt (fun t : ℝ => -t) (-1) t := by
    simpa using (hasDerivAt_id t).neg
  have hexp := (Real.hasDerivAt_exp (-t)).comp t hinner
  have hfull := (hexp.const_mul (v0 - 1)).const_add 1
  convert hfull using 1
  ring

/-! ### Stationarity and convergence -/

/-- **Stationarity.** If the initial variance is the stationary value `1`, the
variance stays `1` for all time: `v0 = 1` is the fixed point of `v' = 1 - v`. -/
theorem vpVar_stationary (t : ℝ) : vpVar 1 t = 1 := by
  unfold vpVar
  ring

/-- Helper: `exp(-t) → 0` as `t → +∞`. -/
theorem exp_neg_tendsto_zero :
    Tendsto (fun t : ℝ => Real.exp (-t)) atTop (𝓝 0) :=
  Real.tendsto_exp_neg_atTop_nhds_zero

/-- **Mean convergence.** The mean decays to `0` as `t → ∞`. -/
theorem vpMean_tendsto_zero (m0 : ℝ) :
    Tendsto (vpMean m0) atTop (𝓝 0) := by
  unfold vpMean
  -- `exp(-t/2) → 0` since `t/2 → ∞`, then multiply by the constant `m0`.
  have hhalf : Tendsto (fun t : ℝ => t / 2) atTop atTop :=
    Filter.Tendsto.atTop_div_const (by norm_num) tendsto_id
  have hexp0 : Tendsto (fun t : ℝ => Real.exp (-t / 2)) atTop (𝓝 0) := by
    have h := Real.tendsto_exp_neg_atTop_nhds_zero.comp hhalf
    convert h using 1
    funext t
    simp [Function.comp, neg_div]
  simpa using hexp0.const_mul m0

/-- **Variance convergence.** The variance relaxes to the stationary value `1`
as `t → ∞`. -/
theorem vpVar_tendsto_one (v0 : ℝ) :
    Tendsto (vpVar v0) atTop (𝓝 1) := by
  unfold vpVar
  have := (exp_neg_tendsto_zero.const_mul (v0 - 1)).const_add 1
  simpa using this

/-! ### Variance positivity / nonnegativity sanity facts

Note that for **arbitrary real time** `t`, positivity of the variance can fail:
as `t → -∞` we have `exp(-t) → +∞`, so if `0 < v0 < 1` then
`v(t) = 1 + (v0 - 1) exp(-t)` becomes negative. We therefore work in the
physically relevant **diffusion-time regime** `t ≥ 0`, where `exp(-t) ≤ 1` and
the variance is controlled. -/

/-- For positive initial variance and nonnegative diffusion time, the variance
is positive. (For `t ≥ 0` we have `0 < exp(-t) ≤ 1`, so
`v(t) = (1 - exp(-t)) + v0 · exp(-t) > 0`.) -/
theorem vpVar_pos_of_pos {v0 t : ℝ} (h : 0 < v0) (ht : 0 ≤ t) :
    0 < vpVar v0 t := by
  unfold vpVar
  have he_pos : 0 < Real.exp (-t) := Real.exp_pos _
  have he_le : Real.exp (-t) ≤ 1 := Real.exp_le_one_iff.mpr (by linarith)
  nlinarith [mul_pos h he_pos, he_le]

/-- For nonnegative initial variance and nonnegative diffusion time, the variance
is nonnegative. -/
theorem vpVar_nonneg_of_nonneg {v0 t : ℝ} (h : 0 ≤ v0) (ht : 0 ≤ t) :
    0 ≤ vpVar v0 t := by
  unfold vpVar
  have he_pos : 0 < Real.exp (-t) := Real.exp_pos _
  have he_le : Real.exp (-t) ≤ 1 := Real.exp_le_one_iff.mpr (by linarith)
  nlinarith [mul_nonneg h (le_of_lt he_pos), he_le]

/-- Restated nonneg-time positivity (explicit name matching the
diffusion-time regime). -/
theorem vpVar_pos_of_pos_of_nonneg_time {v0 t : ℝ} (hv : 0 < v0) (ht : 0 ≤ t) :
    0 < vpVar v0 t := vpVar_pos_of_pos hv ht

/-! ### Gaussian log-density and score

We define the one-dimensional Gaussian log-density **up to an additive
constant**. The full log-density is

  `log p(x) = -(x - m)^2 / (2 σ^2) - log σ - (1/2) log (2π)`.

The omitted term `- log σ - (1/2) log (2π)` is constant in `x`, so its
`x`-derivative is `0` and it does not affect the score. We therefore drop it and
work with the `x`-dependent part only. The **score** is `∂_x log p(x)`. -/

/-- Gaussian log-density up to an additive (in `x`) constant:
`-((x - m)^2) / (2 σ^2)`. The dropped normalization constant
`- log σ - (1/2) log (2π)` has zero `x`-derivative, so it is irrelevant for the
score. -/
def gaussianLogDensity (m σ x : ℝ) : ℝ :=
  -((x - m)^2) / (2 * σ^2)

/-- Gaussian score `∂_x log p(x) = -(x - m) / σ^2`. -/
def gaussianScore (m σ x : ℝ) : ℝ :=
  -(x - m) / σ^2

/-- **Gaussian score formula.** For nonzero scale `σ ≠ 0`, the score is the
`x`-derivative of the Gaussian log-density. The additive normalization constant
omitted from `gaussianLogDensity` has zero derivative, so it is irrelevant. -/
theorem gaussianScore_eq_deriv_logDensity {m σ x : ℝ} (hσ : σ ≠ 0) :
    HasDerivAt (fun y : ℝ => gaussianLogDensity m σ y)
      (gaussianScore m σ x) x := by
  unfold gaussianLogDensity gaussianScore
  -- derivative of `(y - m)^2` is `2 (y - m)`.
  have hbase : HasDerivAt (fun y : ℝ => (y - m)^2) (2 * (x - m)) x := by
    have h1 : HasDerivAt (fun y : ℝ => y - m) 1 x := by
      simpa using (hasDerivAt_id x).sub_const m
    simpa using h1.pow 2
  have hquot : HasDerivAt (fun y : ℝ => -((y - m)^2) / (2 * σ^2))
      (-(2 * (x - m)) / (2 * σ^2)) x := hbase.neg.div_const _
  convert hquot using 1
  field_simp

end