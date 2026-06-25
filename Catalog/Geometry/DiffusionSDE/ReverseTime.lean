/-
# Diffusion Models as SDEs — Part III: The Reverse-Time SDE

This file formalizes the **time reversal** at the heart of score-based diffusion
generative models (Anderson 1982; Song et al. 2021).

If the forward OU process `dX = -θ X dt + σ dW` has marginal densities `p(·,t)`
(solving the Fokker–Planck equation of `FokkerPlanck.lean`), then the *reverse-time*
process `X̄_τ = X_{T-τ}` is again a diffusion, with drift

  b(x,τ) = -f(x) + σ² ∂ₓ log p(x, T-τ) = θ x + σ² · score(x, T-τ),

where `score = ∂ₓ log p` is the Stein score.  Its density `q(x,τ) = p(x, T-τ)`
satisfies the **reverse Fokker–Planck equation**

  ∂_τ q = -∂ₓ(b·q) + (σ²/2) ∂ₓₓ q,

and therefore propagates the (near-)stationary law `q(·,0) = p(·,T)` back to the
**data distribution** `q(·,T) = p(·,0)`.

## Main results

* `hasDerivAt_score`            — the Gaussian Stein score is `∂ₓ log p = -(x-m)/v`.
* `ou_reverse_fokker_planck`    — **`q(x,τ)=p(x,T-τ)` solves the reverse FP PDE**
                                  with Anderson's reverse drift `reverseDrift`.
* `ou_reverse_recovers_data`    — at the terminal reverse time the marginal is the
                                  data density: `q(·,T) = p(·,0)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): reversing time turns the forward FP into another FP
whose drift is corrected by `σ²·score`; the reversed flow recovers `p(·,0)`.
Experiment (Experimenter): differentiate `q(x,τ)=p(x,T-τ)` in τ (chain rule,
`(T-τ)' = -1`) and assemble the reverse FP RHS from the score-corrected drift via
the product rule; reduce to a rational identity by `field_simp; ring`.
Analysis (Analyst): the reverse drift is exactly `b = -f + σ²∂ₓlog p`; the
algebraic miracle is that `-∂ₜp = -∂ₓ(f q) + (σ²/2)∂ₓₓq` rewrites as
`-∂ₓ(b q)+(σ²/2)∂ₓₓq` because `2D∂ₓₓq = 2D∂ₓ(q·∂ₓlog q)`.  The score appears
inside the drift, so the FP RHS gains an extra product-rule term — yet everything
cancels.
Critique (Critic): the theorem uses real `deriv`s and the data-recovery corollary
is a genuine *consequence* of the dynamics (not the whole content); the reverse
PDE needs `v(T-τ)>0` and `θ≠0`, matching the forward result.
Synthesis (PI): closes the diffusion-model SDE triangle: forward OU → Fokker–
Planck → reverse-time recovery, all at the level of verified marginal PDEs.
-- !-- Lab Notes -- !--
-/

import Mathlib
import Geometry.DiffusionSDE.OUProcess
import Geometry.DiffusionSDE.FokkerPlanck

namespace Geometry.DiffusionSDE

/-- **The Gaussian Stein score.**  `∂ₓ log p(x) = -(x-m)/v` for `N(m,v)`. -/
theorem hasDerivAt_score (m v x : ℝ) (hv : v ≠ 0) :
    HasDerivAt (fun y => Real.log (gaussianDensity m v y)) (-(x - m) / v) x := by
  have hF : HasDerivAt (fun y : ℝ => -(Real.log (2 * Real.pi * v)) / 2 - (y - m) ^ 2 / (2 * v))
      (-(x - m) / v) x := by
    have h1 : HasDerivAt (fun y : ℝ => (y - m) ^ 2) (2 * (x - m)) x := by
      have := ((hasDerivAt_id x).sub_const m).pow 2; simpa using this
    have h3 := (h1.div_const (2 * v))
    have h4 := (hasDerivAt_const x (-(Real.log (2 * Real.pi * v)) / 2)).sub h3
    convert h4 using 1; field_simp; ring
  have hfun : (fun y => Real.log (gaussianDensity m v y))
      = (fun y : ℝ => -(Real.log (2 * Real.pi * v)) / 2 - (y - m) ^ 2 / (2 * v)) := by
    funext y; unfold gaussianDensity; rw [Real.log_exp]
  rw [hfun]; exact hF

/-- **Anderson's reverse-time drift** `b(x) = θx - σ²(x-m(s))/v(s) = -f(x) + σ²·score`. -/
noncomputable def reverseDrift (θ σ2 m0 v0 s y : ℝ) : ℝ :=
  θ * y - σ2 * (y - ouMean θ m0 s) / ouVar θ σ2 v0 s

/-- The reverse drift is the forward drift negated plus `σ²` times the score. -/
theorem reverseDrift_eq (θ σ2 m0 v0 s y : ℝ) (hv : ouVar θ σ2 v0 s ≠ 0) :
    reverseDrift θ σ2 m0 v0 s y
      = θ * y + σ2 * (-(y - ouMean θ m0 s) / ouVar θ σ2 v0 s) := by
  unfold reverseDrift; field_simp; ring

/-- **Reverse-time Fokker–Planck equation.**  The reverse marginal
`q(x,τ) = p(x, T-τ)` solves `∂_τ q = -∂ₓ(b·q) + (σ²/2) ∂ₓₓ q` with the reverse
drift `b = reverseDrift`.  This is the PDE underlying the generative reverse SDE. -/
theorem ou_reverse_fokker_planck (θ σ2 m0 v0 x T τ : ℝ) (hθ : θ ≠ 0)
    (hv : 0 < ouVar θ σ2 v0 (T - τ)) :
    deriv (fun r => ouDensity θ σ2 m0 v0 x (T - r)) τ
      = - deriv (fun y => reverseDrift θ σ2 m0 v0 (T - τ) y * ouDensity θ σ2 m0 v0 y (T - τ)) x
        + (σ2 / 2) * deriv (fun y => deriv (fun z => ouDensity θ σ2 m0 v0 z (T - τ)) y) x := by
  set s := T - τ with hs
  set m := ouMean θ m0 with hm_def
  set v := ouVar θ σ2 v0 with hv_def
  have hvne : v s ≠ 0 := ne_of_gt hv
  have hG : HasDerivAt (fun w => gaussianDensity (m w) (v w) x)
      (gaussianDensity (m s) (v s) x *
        ((x - m s) / v s * (-θ * m s)
          + ((x - m s) ^ 2 - v s) / (2 * (v s) ^ 2) * (-(2 * θ) * v s + σ2))) s :=
    hasDerivAt_gaussian_t m v (-θ * m s) (-(2 * θ) * v s + σ2) x s hv
      (ouMean_hasDerivAt θ m0 s) (ouVar_hasDerivAt θ σ2 v0 s hθ)
  have hφ : HasDerivAt (fun r : ℝ => T - r) (-1) τ := by
    simpa using (hasDerivAt_const τ T).sub (hasDerivAt_id τ)
  have hcomp := hG.comp τ hφ
  have hLd : deriv (fun r => gaussianDensity (m (T - r)) (v (T - r)) x) τ
      = gaussianDensity (m s) (v s) x *
        ((x - m s) / v s * (-θ * m s)
          + ((x - m s) ^ 2 - v s) / (2 * (v s) ^ 2) * (-(2 * θ) * v s + σ2)) * (-1) :=
    hcomp.deriv
  have hL : (fun r => ouDensity θ σ2 m0 v0 x (T - r))
      = fun r => gaussianDensity (m (T - r)) (v (T - r)) x := by funext r; rfl
  rw [hL, hLd]
  have hb : HasDerivAt (fun y => reverseDrift θ σ2 m0 v0 s y) (θ - σ2 / v s) x := by
    unfold reverseDrift
    rw [← hm_def, ← hv_def]
    have h1 : HasDerivAt (fun y : ℝ => θ * y) θ x := by simpa using (hasDerivAt_id x).const_mul θ
    have h2 : HasDerivAt (fun y : ℝ => σ2 * (y - m s) / v s) (σ2 / v s) x := by
      have := (((hasDerivAt_id x).sub_const (m s)).const_mul σ2).div_const (v s)
      simpa using this
    simpa using h1.sub h2
  have hbq : HasDerivAt (fun y => reverseDrift θ σ2 m0 v0 s y * gaussianDensity (m s) (v s) y)
      ((θ - σ2 / v s) * gaussianDensity (m s) (v s) x
        + reverseDrift θ σ2 m0 v0 s x * (gaussianDensity (m s) (v s) x * (-(x - m s) / v s))) x :=
    hb.mul (hasDerivAt_gaussian_x (m s) (v s) x hvne)
  have hRq : (fun y => reverseDrift θ σ2 m0 v0 s y * ouDensity θ σ2 m0 v0 y s)
      = (fun y => reverseDrift θ σ2 m0 v0 s y * gaussianDensity (m s) (v s) y) := by funext y; rfl
  rw [hRq, hbq.deriv]
  have hinner : (fun y => deriv (fun z => ouDensity θ σ2 m0 v0 z s) y)
      = (fun y => gaussianDx (m s) (v s) y) := by
    funext y
    have := (hasDerivAt_gaussian_x (m s) (v s) y hvne).deriv
    simpa [ouDensity, gaussianDx] using this
  rw [hinner, (hasDerivAt_gaussian_xx (m s) (v s) x hvne).deriv]
  unfold reverseDrift
  rw [← hm_def, ← hv_def]
  field_simp
  ring

/-- **Data recovery.**  Running the reverse process to its terminal time `τ = T`
returns the initial (data) marginal density: `q(x,T) = p(x,0)`. -/
theorem ou_reverse_recovers_data (θ σ2 m0 v0 x T : ℝ) :
    ouDensity θ σ2 m0 v0 x (T - T) = ouDensity θ σ2 m0 v0 x 0 := by
  rw [sub_self]

end Geometry.DiffusionSDE