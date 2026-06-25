/-
# Diffusion Models as SDEs — Part II: The Fokker–Planck Equation

This file derives the **Fokker–Planck (forward Kolmogorov) equation** for the
marginal densities of the Ornstein–Uhlenbeck forward process driving a
score-based diffusion model, and the stationary equation for its limit law.

For the OU SDE `dX = -θ X dt + σ dW` the marginal at time `t` is the Gaussian
`N(m(t), v(t))` with the moments from `OUProcess.lean`.  We write its density in
the (manifestly positive) exp-log form

  p(x,t) = exp( -½ log(2π v(t)) - (x - m(t))² / (2 v(t)) ),

which for `v(t) > 0` coincides with the usual `(2π v)^{-1/2} exp(-(x-m)²/(2v))`.

The Fokker–Planck operator for drift `f(x) = -θ x` and diffusion `σ²/2` is

  L p = -∂ₓ(f·p) + (σ²/2) ∂ₓₓ p = θ ∂ₓ(x·p) + (σ²/2) ∂ₓₓ p.

## Main results

* `gaussian_pos`              — the density is strictly positive.
* `hasDerivAt_gaussian_x`     — first spatial derivative `∂ₓ p = p·(-(x-m)/v)`.
* `hasDerivAt_gaussian_xx`    — second spatial derivative.
* `hasDerivAt_gaussian_t`     — time derivative via the moment chain rule.
* `ou_fokker_planck`          — **the OU marginal solves the Fokker–Planck PDE**.
* `stationary_fokker_planck`  — the stationary Gaussian `N(0, σ²/2θ)` is a
                                stationary solution (`L p_∞ = 0`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the time-dependent Gaussian with OU moments solves a
linear 2nd-order parabolic PDE; the stationary Gaussian kills the FP operator.
Experiment (Experimenter): compute ∂ₜ, ∂ₓ, ∂ₓₓ of the exp-log Gaussian via
`HasDerivAt`; the PDE then reduces to a *polynomial identity* in (x, m, v, θ, σ²)
discharged by `field_simp; ring` (after substituting the moment ODEs).
Analysis (Analyst): the exp-log parametrization is decisive — it turns the
normalization `(2πv)^{-1/2}` into an additive `-½log(2πv)` term whose
t-derivative is `-v'/(2v)`, so no `Real.sqrt` differentiation is needed and the
whole identity is rational.  The cancellation `-m(x-m) - ((x-m)²-v) = v - x(x-m)`
is the algebraic heart of the equation.
Critique (Critic): both PDEs are stated with genuine `deriv`s (not closed-form
placeholders); `ou_fokker_planck` needs `v(t)>0` and `θ≠0`; the stationary
identity is non-vacuous because `σ²/2θ` is the *exact* fixed point, not 0.
Synthesis (PI): the forward Kolmogorov layer; reused for time reversal.
-- !-- Lab Notes -- !--
-/

import Mathlib
import Geometry.DiffusionSDE.OUProcess

namespace Geometry.DiffusionSDE

/-- Gaussian density `N(m, v)` in exp-log form.  For `v > 0` this equals the
standard `(2π v)^{-1/2} · exp(-(x-m)²/(2v))`. -/
noncomputable def gaussianDensity (m v x : ℝ) : ℝ :=
  Real.exp (-(Real.log (2 * Real.pi * v)) / 2 - (x - m) ^ 2 / (2 * v))

/-- The Gaussian density is strictly positive (it is an exponential). -/
theorem gaussian_pos (m v x : ℝ) : 0 < gaussianDensity m v x := Real.exp_pos _

/-- The exp-log density coincides with the standard normalized Gaussian when `v > 0`. -/
theorem gaussianDensity_eq_sqrt (m v x : ℝ) (hv : 0 < v) :
    gaussianDensity m v x = (Real.sqrt (2 * Real.pi * v))⁻¹ * Real.exp (-(x - m) ^ 2 / (2 * v)) := by
  unfold gaussianDensity
  have hpos : 0 < 2 * Real.pi * v := by positivity
  rw [show -(Real.log (2 * Real.pi * v)) / 2 - (x - m) ^ 2 / (2 * v)
        = (-(Real.log (2 * Real.pi * v)) / 2) + (-(x - m) ^ 2 / (2 * v)) from by ring,
      Real.exp_add]
  congr 1
  rw [Real.sqrt_eq_rpow, ← Real.rpow_neg hpos.le, Real.rpow_def_of_pos hpos]
  congr 1
  ring

/-- First spatial derivative: `∂ₓ p = p · (-(x-m)/v)` (the density times the score). -/
theorem hasDerivAt_gaussian_x (m v x : ℝ) (hv : v ≠ 0) :
    HasDerivAt (fun y => gaussianDensity m v y)
      (gaussianDensity m v x * (-(x - m) / v)) x := by
  unfold gaussianDensity
  have hF : HasDerivAt (fun y : ℝ => -(Real.log (2 * Real.pi * v)) / 2 - (y - m) ^ 2 / (2 * v))
      (-(x - m) / v) x := by
    have h1 : HasDerivAt (fun y : ℝ => (y - m) ^ 2) (2 * (x - m)) x := by
      have := ((hasDerivAt_id x).sub_const m).pow 2; simpa using this
    have h3 := (h1.div_const (2 * v))
    have h4 := (hasDerivAt_const x (-(Real.log (2 * Real.pi * v)) / 2)).sub h3
    convert h4 using 1; field_simp; ring
  have hexp := hF.exp
  convert hexp using 1

/-- The first spatial derivative as an explicit function (density × score). -/
noncomputable def gaussianDx (m v x : ℝ) : ℝ := gaussianDensity m v x * (-(x - m) / v)

/-- Second spatial derivative: `∂ₓₓ p = p · ((x-m)² - v)/v²`. -/
theorem hasDerivAt_gaussian_xx (m v x : ℝ) (hv : v ≠ 0) :
    HasDerivAt (fun y => gaussianDx m v y)
      (gaussianDensity m v x * ((x - m) ^ 2 - v) / v ^ 2) x := by
  unfold gaussianDx
  have hg := hasDerivAt_gaussian_x m v x hv
  have hsub : HasDerivAt (fun y : ℝ => (y - m)) 1 x := (hasDerivAt_id x).sub_const m
  have hlin : HasDerivAt (fun y : ℝ => -(y - m) / v) (-1 / v) x := (hsub.neg).div_const v
  have hp := hg.mul hlin
  convert hp using 1; field_simp; ring

/-- Time derivative of a Gaussian with time-varying mean `mf` and variance `vf`
(the two-parameter chain rule):
`∂ₜ p = p · ( (x-m)/v · m' + ((x-m)²-v)/(2v²) · v' )`. -/
theorem hasDerivAt_gaussian_t (mf vf : ℝ → ℝ) (m' v' x t : ℝ)
    (hv : 0 < vf t) (hm : HasDerivAt mf m' t) (hvd : HasDerivAt vf v' t) :
    HasDerivAt (fun s => gaussianDensity (mf s) (vf s) x)
      (gaussianDensity (mf t) (vf t) x *
        ((x - mf t) / vf t * m' + ((x - mf t) ^ 2 - vf t) / (2 * (vf t) ^ 2) * v')) t := by
  unfold gaussianDensity
  have hvne : vf t ≠ 0 := ne_of_gt hv
  have hw : HasDerivAt (fun s => 2 * Real.pi * vf s) (2 * Real.pi * v') t :=
    hvd.const_mul (2 * Real.pi)
  have hwne : 2 * Real.pi * vf t ≠ 0 := by positivity
  have hlog := hw.log hwne
  have hA : HasDerivAt (fun s => -(Real.log (2 * Real.pi * vf s)) / 2)
      (-((2 * Real.pi * v') / (2 * Real.pi * vf t)) / 2) t := (hlog.neg).div_const 2
  have hxm : HasDerivAt (fun s => x - mf s) (-m') t := by
    simpa using (hasDerivAt_const t x).sub hm
  have hxm2 : HasDerivAt (fun s => (x - mf s) ^ 2) (2 * (x - mf t) * (-m')) t := by
    simpa using hxm.pow 2
  have hden : HasDerivAt (fun s => 2 * vf s) (2 * v') t := hvd.const_mul 2
  have hdenne : 2 * vf t ≠ 0 := by positivity
  have hB : HasDerivAt (fun s => (x - mf s) ^ 2 / (2 * vf s))
      ((2 * (x - mf t) * (-m') * (2 * vf t) - (x - mf t) ^ 2 * (2 * v')) / (2 * vf t) ^ 2) t :=
    hxm2.div hden hdenne
  have hexp := (hA.sub hB).exp
  convert hexp using 2; field_simp; ring

/-- The OU marginal density `p(x,t) = N(m(t), v(t))(x)`. -/
noncomputable def ouDensity (θ σ2 m0 v0 x t : ℝ) : ℝ :=
  gaussianDensity (ouMean θ m0 t) (ouVar θ σ2 v0 t) x

/-- **Fokker–Planck equation for the OU marginals.**  With drift `f(x) = -θx`
and diffusion `σ²/2`, the marginal density solves
`∂ₜ p = θ ∂ₓ(x·p) + (σ²/2) ∂ₓₓ p`. -/
theorem ou_fokker_planck (θ σ2 m0 v0 x t : ℝ) (hθ : θ ≠ 0)
    (hv : 0 < ouVar θ σ2 v0 t) :
    deriv (fun s => ouDensity θ σ2 m0 v0 x s) t
      = θ * deriv (fun y => y * ouDensity θ σ2 m0 v0 y t) x
        + (σ2 / 2) * deriv (fun y => deriv (fun z => ouDensity θ σ2 m0 v0 z t) y) x := by
  set m := ouMean θ m0 with hm_def
  set v := ouVar θ σ2 v0 with hv_def
  have hvne : v t ≠ 0 := ne_of_gt hv
  have ht : HasDerivAt (fun s => ouDensity θ σ2 m0 v0 x s)
      (gaussianDensity (m t) (v t) x *
        ((x - m t) / v t * (-θ * m t)
          + ((x - m t) ^ 2 - v t) / (2 * (v t) ^ 2) * (-(2 * θ) * v t + σ2))) t :=
    hasDerivAt_gaussian_t m v (-θ * m t) (-(2 * θ) * v t + σ2) x t hv
      (ouMean_hasDerivAt θ m0 t) (ouVar_hasDerivAt θ σ2 v0 t hθ)
  rw [ht.deriv]
  have hxp : HasDerivAt (fun y => y * ouDensity θ σ2 m0 v0 y t)
      (1 * gaussianDensity (m t) (v t) x
        + x * (gaussianDensity (m t) (v t) x * (-(x - m t) / v t))) x := by
    have := (hasDerivAt_id x).mul (hasDerivAt_gaussian_x (m t) (v t) x hvne)
    simpa [ouDensity] using this
  rw [hxp.deriv]
  have hinner : (fun y => deriv (fun z => ouDensity θ σ2 m0 v0 z t) y)
      = (fun y => gaussianDx (m t) (v t) y) := by
    funext y
    have := (hasDerivAt_gaussian_x (m t) (v t) y hvne).deriv
    simpa [ouDensity, gaussianDx] using this
  rw [hinner, (hasDerivAt_gaussian_xx (m t) (v t) x hvne).deriv]
  field_simp
  ring

/-- **Stationary Fokker–Planck equation.**  The stationary Gaussian
`N(0, σ²/2θ)` annihilates the Fokker–Planck operator: `θ ∂ₓ(x·p_∞) + (σ²/2) ∂ₓₓ p_∞ = 0`. -/
theorem stationary_fokker_planck (θ σ2 x : ℝ) (hθ : 0 < θ) (hσ : 0 < σ2) :
    θ * deriv (fun y => y * gaussianDensity 0 (stationaryVar θ σ2) y) x
      + (σ2 / 2) * deriv (fun y => deriv (fun z => gaussianDensity 0 (stationaryVar θ σ2) z) y) x
      = 0 := by
  have hv : (0 : ℝ) < stationaryVar θ σ2 := by unfold stationaryVar; positivity
  have hvne : stationaryVar θ σ2 ≠ 0 := ne_of_gt hv
  have hxp : HasDerivAt (fun y => y * gaussianDensity 0 (stationaryVar θ σ2) y)
      (1 * gaussianDensity 0 (stationaryVar θ σ2) x
        + x * (gaussianDensity 0 (stationaryVar θ σ2) x * (-(x - 0) / stationaryVar θ σ2))) x := by
    have := (hasDerivAt_id x).mul (hasDerivAt_gaussian_x 0 (stationaryVar θ σ2) x hvne)
    simpa using this
  rw [hxp.deriv]
  have hinner : (fun y => deriv (fun z => gaussianDensity 0 (stationaryVar θ σ2) z) y)
      = (fun y => gaussianDx 0 (stationaryVar θ σ2) y) := by
    funext y
    have := (hasDerivAt_gaussian_x 0 (stationaryVar θ σ2) y hvne).deriv
    simpa [gaussianDx] using this
  rw [hinner, (hasDerivAt_gaussian_xx 0 (stationaryVar θ σ2) x hvne).deriv]
  unfold stationaryVar
  field_simp
  ring

end Geometry.DiffusionSDE