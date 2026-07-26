/-
# Diffusion Models as SDEs — Part I: Ornstein–Uhlenbeck Marginal Moments

This file formalizes the deterministic *moment dynamics* of the Ornstein–Uhlenbeck
(OU) forward process used in score-based diffusion models.

The OU forward SDE is

  dX_t = -θ X_t dt + σ dW_t,    X_0 ∼ μ_0,

with θ > 0 (mean reversion) and σ² > 0 (diffusion).  Its marginal law `X_t` is
Gaussian for all `t`, completely described by its mean `m(t)` and variance `v(t)`.
Taking expectations of the SDE / its Itô square yields the closed *moment ODEs*

  m'(t) = -θ m(t),              (mean decay)
  v'(t) = -2θ v(t) + σ²,        (variance relaxation)

whose explicit solutions are

  m(t) = m₀ e^{-θt},
  v(t) = v_∞ + (v₀ - v_∞) e^{-2θt},     v_∞ = σ²/(2θ).

We prove (i) these explicit functions satisfy the moment ODEs (`HasDerivAt`),
and (ii) they converge as `t → ∞` to the **stationary distribution** moments
`m → 0`, `v → v_∞ = σ²/(2θ)`, i.e. `N(0, σ²/(2θ))`.

These are the scalar building blocks for the Fokker–Planck and reverse-time
results in the companion files.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the OU marginals are Gaussian with moments solving
linear ODEs whose unique fixed point is the stationary variance σ²/(2θ).
Experiment (Experimenter): encode m, v as explicit exponential solutions and
verify the ODEs via `HasDerivAt`; verify convergence via `Real.tendsto_exp_atBot`.
Analysis (Analyst): the variance ODE needs θ ≠ 0 to identify v_∞·2θ = σ²; the
mean ODE is unconditional. Convergence needs θ > 0 so that -θt, -2θt → -∞.
Critique (Critic): statements are non-vacuous (derivative values are exact, not
bounds); the limits are the genuine stationary moments, not 0 by accident.
Synthesis (PI): clean scalar OU layer reused downstream for Fokker–Planck.
-- !-- Lab Notes -- !--
-/

import Mathlib

open Filter Topology
open scoped Topology

namespace Geometry.DiffusionSDE

/-- Mean of the OU marginal at time `t`: `m(t) = m₀ e^{-θt}`. -/
noncomputable def ouMean (θ m0 t : ℝ) : ℝ := m0 * Real.exp (-θ * t)

/-- Stationary variance of the OU process: `v_∞ = σ²/(2θ)`. -/
noncomputable def stationaryVar (θ σ2 : ℝ) : ℝ := σ2 / (2 * θ)

/-- Variance of the OU marginal at time `t`:
`v(t) = v_∞ + (v₀ - v_∞) e^{-2θt}`. -/
noncomputable def ouVar (θ σ2 v0 t : ℝ) : ℝ :=
  stationaryVar θ σ2 + (v0 - stationaryVar θ σ2) * Real.exp (-(2 * θ) * t)

/-- The mean satisfies the linear moment ODE `m'(t) = -θ m(t)`. -/
theorem ouMean_hasDerivAt (θ m0 t : ℝ) :
    HasDerivAt (ouMean θ m0) (-θ * ouMean θ m0 t) t := by
  unfold ouMean
  have h : HasDerivAt (fun t : ℝ => -θ * t) (-θ) t := by
    simpa using (hasDerivAt_id t).const_mul (-θ)
  have h2 := (h.exp).const_mul m0
  convert h2 using 1
  ring

/-- The variance satisfies the affine moment ODE `v'(t) = -2θ v(t) + σ²`
(requires `θ ≠ 0` to identify the constant term). -/
theorem ouVar_hasDerivAt (θ σ2 v0 t : ℝ) (hθ : θ ≠ 0) :
    HasDerivAt (ouVar θ σ2 v0) (-(2 * θ) * ouVar θ σ2 v0 t + σ2) t := by
  unfold ouVar stationaryVar
  have h : HasDerivAt (fun t : ℝ => -(2 * θ) * t) (-(2 * θ)) t := by
    simpa using (hasDerivAt_id t).const_mul (-(2 * θ))
  have h2 := ((h.exp).const_mul (v0 - σ2 / (2 * θ))).const_add (σ2 / (2 * θ))
  convert h2 using 1
  field_simp
  ring

private theorem ouExp_tendsto (θ : ℝ) (hθ : 0 < θ) :
    Tendsto (fun t : ℝ => Real.exp (-θ * t)) atTop (𝓝 0) := by
  have h1 : Tendsto (fun t : ℝ => θ * t) atTop atTop :=
    Filter.Tendsto.const_mul_atTop hθ tendsto_id
  have he : (fun t : ℝ => -θ * t) = fun t => -(θ * t) := by funext t; ring
  have hb : Tendsto (fun t : ℝ => -θ * t) atTop atBot := by
    rw [he]; exact tendsto_neg_atTop_atBot.comp h1
  exact Real.tendsto_exp_atBot.comp hb

/-- As `t → ∞` the mean relaxes to `0`. -/
theorem ouMean_tendsto (θ m0 : ℝ) (hθ : 0 < θ) :
    Tendsto (ouMean θ m0) atTop (𝓝 0) := by
  unfold ouMean
  have := (ouExp_tendsto θ hθ).const_mul m0
  simpa using this

/-- As `t → ∞` the variance relaxes to the stationary value `σ²/(2θ)`. -/
theorem ouVar_tendsto (θ σ2 v0 : ℝ) (hθ : 0 < θ) :
    Tendsto (ouVar θ σ2 v0) atTop (𝓝 (stationaryVar θ σ2)) := by
  unfold ouVar
  have h2 : Tendsto (fun t : ℝ => Real.exp (-(2 * θ) * t)) atTop (𝓝 0) :=
    ouExp_tendsto (2 * θ) (by linarith)
  have h3 := (h2.const_mul (v0 - stationaryVar θ σ2)).const_add (stationaryVar θ σ2)
  simpa using h3

/-- The stationary variance is the unique fixed point of the variance ODE's
right-hand side `r ↦ -2θ r + σ²`. -/
theorem stationaryVar_is_fixed_point (θ σ2 : ℝ) (hθ : θ ≠ 0) :
    -(2 * θ) * stationaryVar θ σ2 + σ2 = 0 := by
  unfold stationaryVar
  field_simp
  ring

end Geometry.DiffusionSDE