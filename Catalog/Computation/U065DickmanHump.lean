/-
# U065 — Dickman baseline shape, the two-point hump, and spread calibration

The exp 588b measurement fits an *exact* Dickman baseline `ρ(log v / log B)` to the
smoothness rate of the sieve values `v = j² − N` and reports a residual hump of
log-amplitude `A ≈ 0.1163 ± 0.0360` (z = 3.23) over `t ∈ [0.45, 0.85]`, with a paired
random control that is null.

This file supplies the analytic half of the mechanism.  On the first Dickman branch
`u ∈ [1,2]` the Dickman function is `ρ(u) = 1 − log u`; we verify this is the correct
branch by checking the Dickman delay equation `u ρ'(u) = −ρ(u−1)` there
(`rhoOne_dickman_ode`), and we prove `ρ` is convex (`rhoOne_convexOn`).

Convexity is what makes a *mixture* baseline sit above a *pointwise* one.  For a
symmetric two-point mixture of the effective Dickman argument, `u` with probability
`1/2` and `u − δ` with probability `1/2`, the excess of the mixture average over the
baseline evaluated at the mean argument `u − δ/2` is computed here in closed form:

  `humpAmp u δ = ½ · log (1 + δ² / (4u(u−δ)))`  (`humpAmp_eq`),

strictly positive whenever `δ ≠ 0` (`humpAmp_pos`) and strictly increasing in the
spread `δ` (`humpAmp_strictMonoOn`).

Finally we invert the relation exactly: for any measured amplitude `A > 0` the mixture
spread is recovered in closed form by `calibratedSpread`, which always lands in the
admissible range `(0, u)` and reproduces `A` exactly (`humpAmp_calibratedSpread`).  So
the amplitude of a hump over an exact Dickman baseline *identifies* the spread of the
underlying divisibility mixture, and the identification is scale free: `δ/u` depends on
`A` alone (`calibratedSpread_scale`).
-/
import Mathlib

namespace U065

/-- The Dickman function on its first non-trivial branch `u ∈ [1,2]`. -/
noncomputable def rhoOne (u : ℝ) : ℝ := 1 - Real.log u

/-- On `[1,2]` the function `1 − log u` satisfies the Dickman delay equation
`u · ρ'(u) = −ρ(u−1)` (where `ρ ≡ 1` on `[0,1]`), confirming the branch. -/
theorem rhoOne_dickman_ode {u : ℝ} (hu : 0 < u) :
    HasDerivAt rhoOne (-(1 / u)) u := by
  have hlog : HasDerivAt Real.log (1 / u) u := (Real.hasDerivAt_log hu.ne').congr_deriv (by
    field_simp)
  simpa [rhoOne, sub_eq_add_neg] using (hasDerivAt_const u (1 : ℝ)).sub hlog

/-- The delay equation in its literal form on the first branch: `u · ρ'(u) = −ρ(u−1)`,
where `ρ ≡ 1` on `[0,1]`, so the right-hand side is `−1` for `1 ≤ u ≤ 2`. -/
theorem rhoOne_delay {u : ℝ} (hu : 0 < u) : u * deriv rhoOne u = -1 := by
  rw [(rhoOne_dickman_ode hu).deriv]
  field_simp

/-- The Dickman branch `ρ(u) = 1 − log u` is convex: mixtures of the Dickman argument
raise the average smoothness rate above the rate at the average argument. -/
theorem rhoOne_convexOn : ConvexOn ℝ (Set.Ioi (0 : ℝ)) rhoOne := by
  have h : ConvexOn ℝ (Set.Ioi (0 : ℝ)) (fun u => -Real.log u) :=
    strictConcaveOn_log_Ioi.concaveOn.neg
  have h' : ConvexOn ℝ (Set.Ioi (0 : ℝ)) (fun u => (fun u => -Real.log u) u + 1) :=
    h.add_const 1
  simpa [rhoOne, add_comm, sub_eq_neg_add] using h'

/-- Hump amplitude of a symmetric two-point mixture of the Dickman argument with
spread `δ`: mixture average minus baseline value at the mean argument. -/
noncomputable def humpAmp (u δ : ℝ) : ℝ :=
  (rhoOne u + rhoOne (u - δ)) / 2 - rhoOne (u - δ / 2)

/-- **Closed form of the hump.** -/
theorem humpAmp_eq {u δ : ℝ} (hu : 0 < u) (hud : 0 < u - δ) :
    humpAmp u δ = (1 / 2) * Real.log (1 + δ ^ 2 / (4 * u * (u - δ))) := by
  have hmid : 0 < u - δ / 2 := by linarith
  have hkey : (1 : ℝ) + δ ^ 2 / (4 * u * (u - δ)) = (u - δ / 2) ^ 2 / (u * (u - δ)) := by
    field_simp
    ring
  rw [humpAmp, rhoOne, rhoOne, rhoOne, hkey,
    Real.log_div (by positivity) (by positivity), Real.log_pow,
    Real.log_mul hu.ne' hud.ne']
  push_cast
  ring

/-- The hump is strictly positive for any non-zero spread: a mixture of divisibility
regimes always sits above the exact Dickman baseline. -/
theorem humpAmp_pos {u δ : ℝ} (hu : 0 < u) (hud : 0 < u - δ) (hδ : δ ≠ 0) :
    0 < humpAmp u δ := by
  rw [humpAmp_eq hu hud]
  have hsq : 0 < δ ^ 2 := pow_two_pos_of_ne_zero hδ
  have hpos : 0 < δ ^ 2 / (4 * u * (u - δ)) := by positivity
  have := Real.log_pos (by linarith : (1 : ℝ) < 1 + δ ^ 2 / (4 * u * (u - δ)))
  linarith

/-- A vanishing spread gives no hump: the model is faithful at the null. -/
@[simp] theorem humpAmp_zero {u : ℝ} : humpAmp u 0 = 0 := by
  simp [humpAmp]

/-- The hump amplitude is strictly increasing in the mixture spread on `[0, u)`. -/
theorem humpAmp_strictMonoOn {u : ℝ} (hu : 0 < u) :
    StrictMonoOn (fun δ => humpAmp u δ) (Set.Ico (0 : ℝ) u) := by
  intro a ha b hb hab
  have hua : 0 < u - a := by simp only [Set.mem_Ico] at ha; linarith [ha.2]
  have hub : 0 < u - b := by simp only [Set.mem_Ico] at hb; linarith [hb.2]
  have ha0 : 0 ≤ a := (Set.mem_Ico.mp ha).1
  have hb0 : 0 < b := lt_of_le_of_lt ha0 hab
  simp only
  rw [humpAmp_eq hu hua, humpAmp_eq hu hub]
  have hkey : a ^ 2 / (4 * u * (u - a)) < b ^ 2 / (4 * u * (u - b)) := by
    rw [div_lt_div_iff₀ (by positivity) (by positivity)]
    have hfact : b ^ 2 * (4 * u * (u - a)) - a ^ 2 * (4 * u * (u - b))
        = 4 * u * ((b - a) * (u * (a + b) - a * b)) := by ring
    have hab' : 0 < b - a := by linarith
    have hmix : 0 < u * (a + b) - a * b := by nlinarith
    nlinarith [mul_pos (mul_pos (by linarith : (0:ℝ) < 4 * u) hab') hmix]
  have h1 : (0:ℝ) < 1 + a ^ 2 / (4 * u * (u - a)) := by positivity
  have := Real.log_lt_log h1 (by linarith : 1 + a ^ 2 / (4 * u * (u - a))
      < 1 + b ^ 2 / (4 * u * (u - b)))
  linarith

/-- The mixture spread reconstructed from a measured hump amplitude `A` at Dickman
argument `u`, in closed form. -/
noncomputable def calibratedSpread (u A : ℝ) : ℝ :=
  let s := Real.exp (2 * A) - 1
  2 * u * (Real.sqrt (s ^ 2 + s) - s)

/-- The calibration is scale free: the relative spread `δ/u` depends only on the
measured amplitude. -/
theorem calibratedSpread_scale (u A : ℝ) :
    calibratedSpread u A = u * calibratedSpread 1 A := by
  simp only [calibratedSpread]
  ring

/-- The calibrated spread is admissible: `0 < δ < u` for every positive amplitude. -/
theorem calibratedSpread_mem_Ioo {u A : ℝ} (hu : 0 < u) (hA : 0 < A) :
    calibratedSpread u A ∈ Set.Ioo 0 u := by
  have hs : 0 < Real.exp (2 * A) - 1 := by
    have h1 : (1 : ℝ) + 2 * A ≤ Real.exp (2 * A) := by
      have := Real.add_one_le_exp (2 * A); linarith
    linarith
  set s := Real.exp (2 * A) - 1 with hsdef
  have hnn : 0 ≤ s ^ 2 + s := by positivity
  have hr : Real.sqrt (s ^ 2 + s) ^ 2 = s ^ 2 + s := Real.sq_sqrt hnn
  have hrnn : 0 ≤ Real.sqrt (s ^ 2 + s) := Real.sqrt_nonneg _
  have hgt : s < Real.sqrt (s ^ 2 + s) := by nlinarith
  have hlt : Real.sqrt (s ^ 2 + s) < s + 1 / 2 := by nlinarith
  constructor
  · simp only [calibratedSpread]
    have : 0 < Real.sqrt (s ^ 2 + s) - s := by linarith
    positivity
  · simp only [calibratedSpread]
    nlinarith

/-- **Exact calibration.**  The closed-form spread reproduces the measured amplitude:
the hump amplitude over an exact Dickman baseline identifies the mixture spread. -/
theorem humpAmp_calibratedSpread {u A : ℝ} (hu : 0 < u) (hA : 0 < A) :
    humpAmp u (calibratedSpread u A) = A := by
  have hmem := calibratedSpread_mem_Ioo hu hA
  have hud : 0 < u - calibratedSpread u A := by
    have := hmem.2; linarith
  have hs : 0 < Real.exp (2 * A) - 1 := by
    have h1 : (1 : ℝ) + 2 * A ≤ Real.exp (2 * A) := by
      have := Real.add_one_le_exp (2 * A); linarith
    linarith
  set s := Real.exp (2 * A) - 1 with hsdef
  set r := Real.sqrt (s ^ 2 + s) with hrdef
  have hnn : 0 ≤ s ^ 2 + s := by positivity
  have hr : r ^ 2 = s ^ 2 + s := Real.sq_sqrt hnn
  have hδ : calibratedSpread u A = 2 * u * (r - s) := rfl
  -- the quadratic identity `t² + 2st − s = 0` for `t = r − s`
  have hquad : (r - s) ^ 2 + 2 * s * (r - s) - s = 0 := by nlinarith
  have hud' : 0 < u - 2 * u * (r - s) := by rw [hδ] at hud; exact hud
  have ht2 : 0 < 1 - 2 * (r - s) := by
    have := hud'
    nlinarith
  have hdiv : (2 * u * (r - s)) ^ 2 / (4 * u * (u - 2 * u * (r - s)))
      = (r - s) ^ 2 / (1 - 2 * (r - s)) := by
    rw [div_eq_div_iff (by positivity) (by positivity)]
    ring
  have hval : (r - s) ^ 2 / (1 - 2 * (r - s)) = s := by
    rw [div_eq_iff ht2.ne']
    nlinarith
  have harg : 1 + (calibratedSpread u A) ^ 2 / (4 * u * (u - calibratedSpread u A))
      = Real.exp (2 * A) := by
    rw [hδ, hdiv, hval, hsdef]
    ring
  rw [humpAmp_eq hu hud, harg, Real.log_exp]
  ring

end U065