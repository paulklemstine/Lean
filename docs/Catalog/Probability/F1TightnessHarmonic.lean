import Mathlib
import Probability.F1TightnessCore
import Probability.PositionalRateLinkHarmonic

/-!
# The measured harmonic profile forces the F1 slack (paper 250, continuum layer)

`Probability.F1TightnessCore` shows that the slack factor of the paper-225
master inequality is `X = C₀ / c_asc = (1+Λ)/(2Λ)`, and that `X > 1` strictly
whenever the positional profile is front-loaded and non-flat.  Here we feed in
the *measured* profile shape of the papers 228–242 chain: the harmonic (`1/x`)
law on a window of ratio `r`, whose CDF `harmCDF r u = log(1+(r−1)u)/log r` was
established in `Probability.PositionalRateLinkHarmonic`.

Main results.

* `integral_harmCDF`, `meanPos_harmonic` — the mean probe position of the
  harmonic law, computed as `∫₀¹ (1 − F_r)`, equals
  `E(r) = 1/log r − 1/(r−1)`.
* `log_gt_pade` — the Padé inequality `log r > 2(r−1)/(r+1)` for `r > 1`
  (a derivative argument), which is exactly the statement `E(r) < 1/2`.
* `harmMeanPos_lt_half`, `harmMeanPos_pos` — the harmonic mean position lies
  strictly in `(0, 1/2)` for every window ratio `r > 1`.
* `harmonic_forces_slack` — consequently the continuum shape parameter
  `Λ(r) = E/(1−E)` is `< 1` and the slack factor `X = (1+Λ)/(2Λ) = 1/(2E)`
  is `> 1`: **the slack is profile-forced**, for every window ratio, with no
  reference to any policy.
* `harmMeanPos_tendsto_zero`, `harmonic_slack_tendsto_atTop` — the slack
  factor diverges as the window ratio grows: the wider the scan window, the
  more the master bound overshoots.
* `measured_meanPos`, `measured_slack` — the booked numbers: the measured
  `Λ = 0.765671` corresponds to mean position `E ≈ 0.43365 < 1/2` and slack
  `X ≈ 1.15302`.
-/

open Set Filter Real PositionalRateLink

namespace F1Tightness

/-! ## The continuum parameter map -/

/-- Continuum shape parameter attached to a mean probe position `E ∈ (0,1)`:
`Λ = c_asc / c_desc = E / (1 − E)`. -/
noncomputable def contLam (E : ℝ) : ℝ := E / (1 - E)

/-- Continuum slack factor attached to a mean probe position: `X = C₀/c_asc
= (1/2)/E`. -/
noncomputable def contGapX (E : ℝ) : ℝ := 1 / (2 * E)

theorem contLam_pos {E : ℝ} (h0 : 0 < E) (h1 : E < 1) : 0 < contLam E :=
  div_pos h0 (by linarith)

/-- The continuum map satisfies the same identity as the discrete one:
`X = (1+Λ)/(2Λ)`. -/
theorem contGapX_eq_gapOfLam {E : ℝ} (h0 : 0 < E) (h1 : E < 1) :
    contGapX E = gapOfLam (contLam E) := by
  have h1' : (0:ℝ) < 1 - E := by linarith
  unfold contGapX gapOfLam contLam
  rw [div_eq_div_iff (by positivity) (by positivity)]
  field_simp
  ring

/-- Front-loading (`E < 1/2`) is exactly `Λ < 1`. -/
theorem contLam_lt_one {E : ℝ} (h0 : 0 < E) (h1 : E < 1 / 2) : contLam E < 1 := by
  have h1' : (0:ℝ) < 1 - E := by linarith
  unfold contLam
  rw [div_lt_one h1']
  linarith

/-! ## The Padé inequality `log r > 2(r−1)/(r+1)` -/

/-- For `r > 1` the logarithm dominates its `(1,1)` Padé approximant.  This is
the analytic core: it says that the harmonic profile is strictly front-loaded on
every window. -/
theorem log_gt_pade {r : ℝ} (hr : 1 < r) : 2 * (r - 1) / (r + 1) < Real.log r := by
  set f : ℝ → ℝ := fun x => Real.log x - 2 * (x - 1) / (x + 1) with hf
  have hmono : StrictMonoOn f (Set.Ici 1) := by
    refine strictMonoOn_of_deriv_pos (convex_Ici 1) ?_ ?_
    · apply ContinuousOn.sub
      · exact Real.continuousOn_log.mono (by
          intro x hx
          simp only [Set.mem_Ici] at hx
          simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
          linarith)
      · apply ContinuousOn.div (by fun_prop) (by fun_prop)
        intro x hx
        simp only [Set.mem_Ici] at hx
        linarith
    · intro x hx
      rw [interior_Ici] at hx
      simp only [Set.mem_Ioi] at hx
      have hx0 : x ≠ 0 := by linarith
      have hx1 : x + 1 ≠ 0 := by linarith
      have hd : HasDerivAt f (1 / x - 4 / (x + 1) ^ 2) x := by
        have hlog : HasDerivAt Real.log (1 / x) x := by
          simpa [one_div] using Real.hasDerivAt_log hx0
        have hnum : HasDerivAt (fun y : ℝ => 2 * (y - 1)) 2 x := by
          simpa using ((hasDerivAt_id x).sub_const 1).const_mul 2
        have hden : HasDerivAt (fun y : ℝ => y + 1) 1 x := (hasDerivAt_id x).add_const 1
        have hdiv : HasDerivAt (fun y : ℝ => 2 * (y - 1) / (y + 1))
            ((2 * (x + 1) - 2 * (x - 1) * 1) / (x + 1) ^ 2) x := hnum.div hden hx1
        have heq : (2 * (x + 1) - 2 * (x - 1) * 1) / (x + 1) ^ 2 = 4 / (x + 1) ^ 2 := by
          field_simp
          ring
        rw [heq] at hdiv
        exact hlog.sub hdiv
      rw [hd.deriv]
      have hpos : 0 < (x - 1) ^ 2 / (x * (x + 1) ^ 2) :=
        div_pos (by nlinarith) (by positivity)
      have hid : 1 / x - 4 / (x + 1) ^ 2 = (x - 1) ^ 2 / (x * (x + 1) ^ 2) := by
        field_simp
        ring
      rw [hid]
      exact hpos
  have h := hmono (Set.self_mem_Ici) (Set.mem_Ici.2 hr.le) hr
  simp only [hf, Real.log_one] at h
  norm_num at h
  linarith

/-! ## The harmonic mean position -/

/-- Mean probe position of the harmonic law on a window of ratio `r`:
`E(r) = 1/log r − 1/(r−1)`. -/
noncomputable def harmMeanPos (r : ℝ) : ℝ := 1 / Real.log r - 1 / (r - 1)

/-- The primitive used to integrate `harmCDF`. -/
private noncomputable def harmPrim (r u : ℝ) : ℝ :=
  ((1 + (r - 1) * u) * (Real.log (1 + (r - 1) * u) - 1)) / ((r - 1) * Real.log r)

private theorem harmPrim_hasDerivAt {r u : ℝ} (hr : 1 < r) (hu : 0 ≤ u) :
    HasDerivAt (harmPrim r) (harmCDF r u) u := by
  have hc : (0:ℝ) < r - 1 := by linarith
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hpos : (0:ℝ) < 1 + (r - 1) * u := by nlinarith
  have h1 : HasDerivAt (fun t : ℝ => 1 + (r - 1) * t) (r - 1) u := by
    simpa using ((hasDerivAt_id u).const_mul (r - 1)).const_add 1
  have h2 : HasDerivAt (fun t : ℝ => Real.log (1 + (r - 1) * t))
      ((r - 1) / (1 + (r - 1) * u)) u := by
    simpa [div_eq_mul_inv, mul_comm] using h1.log hpos.ne'
  have h3 : HasDerivAt (fun t : ℝ => Real.log (1 + (r - 1) * t) - 1)
      ((r - 1) / (1 + (r - 1) * u)) u := h2.sub_const 1
  have h4 : HasDerivAt
      (fun t : ℝ => (1 + (r - 1) * t) * (Real.log (1 + (r - 1) * t) - 1))
      ((r - 1) * (Real.log (1 + (r - 1) * u) - 1)
        + (1 + (r - 1) * u) * ((r - 1) / (1 + (r - 1) * u))) u := h1.mul h3
  have h5 := h4.div_const ((r - 1) * Real.log r)
  have hval : ((r - 1) * (Real.log (1 + (r - 1) * u) - 1)
        + (1 + (r - 1) * u) * ((r - 1) / (1 + (r - 1) * u))) / ((r - 1) * Real.log r)
      = harmCDF r u := by
    rw [harmCDF]
    field_simp
    ring
  rw [hval] at h5
  exact h5

/-- The integral of the harmonic CDF over the window. -/
theorem integral_harmCDF {r : ℝ} (hr : 1 < r) :
    ∫ u in (0:ℝ)..1, harmCDF r u
      = (r * Real.log r - r + 1) / ((r - 1) * Real.log r) := by
  have hc : (0:ℝ) < r - 1 := by linarith
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hcont : ContinuousOn (harmCDF r) (Set.uIcc 0 1) := by
    have : Set.uIcc (0:ℝ) 1 = Set.Icc 0 1 := by
      rw [Set.uIcc_of_le]; norm_num
    rw [this]
    apply ContinuousOn.div _ continuousOn_const (fun x _ => hlogr.ne')
    apply ContinuousOn.log (by fun_prop)
    intro x hx
    have hx0 : 0 ≤ x := hx.1
    nlinarith
  have hderiv : ∀ u ∈ Set.uIcc (0:ℝ) 1, HasDerivAt (harmPrim r) (harmCDF r u) u := by
    intro u hu
    have : Set.uIcc (0:ℝ) 1 = Set.Icc 0 1 := by rw [Set.uIcc_of_le]; norm_num
    rw [this] at hu
    exact harmPrim_hasDerivAt hr hu.1
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv (hcont.intervalIntegrable)]
  have h1 : harmPrim r 1 = (r * (Real.log r - 1)) / ((r - 1) * Real.log r) := by
    unfold harmPrim
    have : (1:ℝ) + (r - 1) * 1 = r := by ring
    rw [this]
  have h0 : harmPrim r 0 = (-1) / ((r - 1) * Real.log r) := by
    unfold harmPrim
    norm_num
  rw [h1, h0, div_sub_div_same]
  congr 1
  ring

/-- **Mean probe position of the harmonic law.**  Computed from the measured
CDF as `∫₀¹ (1 − F_r)`, it is `E(r) = 1/log r − 1/(r−1)`. -/
theorem meanPos_harmonic {r : ℝ} (hr : 1 < r) :
    (∫ u in (0:ℝ)..1, (1 - harmCDF r u)) = harmMeanPos r := by
  have hc : (0:ℝ) < r - 1 := by linarith
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hcont : ContinuousOn (harmCDF r) (Set.uIcc 0 1) := by
    have huI : Set.uIcc (0:ℝ) 1 = Set.Icc 0 1 := by rw [Set.uIcc_of_le]; norm_num
    rw [huI]
    apply ContinuousOn.div _ continuousOn_const (fun x _ => hlogr.ne')
    apply ContinuousOn.log (by fun_prop)
    intro x hx
    have hx0 : 0 ≤ x := hx.1
    nlinarith
  rw [intervalIntegral.integral_sub intervalIntegrable_const hcont.intervalIntegrable,
    integral_harmCDF hr]
  simp only [intervalIntegral.integral_const, smul_eq_mul, sub_zero, mul_one]
  unfold harmMeanPos
  field_simp
  ring

/-- The harmonic mean position is positive. -/
theorem harmMeanPos_pos {r : ℝ} (hr : 1 < r) : 0 < harmMeanPos r := by
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hc : (0:ℝ) < r - 1 := by linarith
  have hlt : Real.log r < r - 1 := by
    have := Real.log_lt_sub_one_of_pos (by linarith : (0:ℝ) < r) (by linarith : r ≠ 1)
    linarith
  unfold harmMeanPos
  rw [sub_pos, div_lt_div_iff₀ hc hlogr]
  linarith

/-- **Front-loadedness of the harmonic law**: the mean probe position is
strictly below the flat value `1/2`, for every window ratio. -/
theorem harmMeanPos_lt_half {r : ℝ} (hr : 1 < r) : harmMeanPos r < 1 / 2 := by
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hc : (0:ℝ) < r - 1 := by linarith
  have hpade := log_gt_pade hr
  have key : 2 * (r - 1) < (r + 1) * Real.log r := by
    rw [div_lt_iff₀ (by linarith : (0:ℝ) < r + 1)] at hpade
    linarith
  have hgoal : 1 / Real.log r < 1 / 2 + 1 / (r - 1) := by
    rw [div_add_div _ _ (by norm_num : (2:ℝ) ≠ 0) (ne_of_gt hc),
      div_lt_div_iff₀ hlogr (by positivity)]
    nlinarith
  unfold harmMeanPos
  linarith

theorem harmMeanPos_lt_one {r : ℝ} (hr : 1 < r) : harmMeanPos r < 1 := by
  have := harmMeanPos_lt_half hr; linarith

/-- **Profile-forced slack.**  For every window ratio `r > 1` the measured
harmonic shape gives `Λ < 1` and a slack factor `X = 1/(2E) > 1`: the master
bound overshoots, whatever the policy. -/
theorem harmonic_forces_slack {r : ℝ} (hr : 1 < r) :
    contLam (harmMeanPos r) < 1 ∧
      contGapX (harmMeanPos r) = gapOfLam (contLam (harmMeanPos r)) ∧
      1 < contGapX (harmMeanPos r) := by
  have h0 := harmMeanPos_pos hr
  have h1 := harmMeanPos_lt_half hr
  have h1' := harmMeanPos_lt_one hr
  refine ⟨contLam_lt_one h0 h1, contGapX_eq_gapOfLam h0 h1', ?_⟩
  unfold contGapX
  rw [lt_div_iff₀ (by positivity)]
  linarith

/-! ## Wide windows: the slack diverges -/

theorem harmMeanPos_tendsto_zero : Tendsto harmMeanPos atTop (nhds 0) := by
  have h1 : Tendsto (fun r : ℝ => 1 / Real.log r) atTop (nhds 0) := by
    simpa [one_div] using Real.tendsto_log_atTop.inv_tendsto_atTop
  have h2 : Tendsto (fun r : ℝ => 1 / (r - 1)) atTop (nhds 0) := by
    simpa [one_div] using (tendsto_atTop_add_const_right atTop (-1) tendsto_id).inv_tendsto_atTop
  unfold harmMeanPos
  simpa using h1.sub h2

/-- The slack factor diverges with the window ratio: the wider the scan window,
the larger the overshoot of the master bound. -/
theorem harmonic_slack_tendsto_atTop :
    Tendsto (fun r => contGapX (harmMeanPos r)) atTop atTop := by
  have hpos : ∀ᶠ r : ℝ in atTop, 0 < 2 * harmMeanPos r := by
    filter_upwards [eventually_gt_atTop (1:ℝ)] with r hr
    have := harmMeanPos_pos hr
    linarith
  have h2 : Tendsto (fun r : ℝ => 2 * harmMeanPos r) atTop (nhdsWithin 0 (Set.Ioi 0)) := by
    apply tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within
    · simpa using harmMeanPos_tendsto_zero.const_mul 2
    · filter_upwards [hpos] with r hr using hr
  have heq : (fun r => contGapX (harmMeanPos r))
      = (fun x : ℝ => x⁻¹) ∘ (fun r => 2 * harmMeanPos r) := by
    funext r
    simp [contGapX, Function.comp, one_div]
  rw [heq]
  exact tendsto_inv_nhdsGT_zero.comp h2

/-! ## The measured numbers -/

/-- The measured shape parameter `Λ = 0.765671` corresponds to mean probe
position `E = Λ/(1+Λ) ≈ 0.43365`, strictly front-loaded. -/
theorem measured_meanPos :
    |LamMeas / (1 + LamMeas) - 43365 / 100000| < 1 / 100000 ∧
      LamMeas / (1 + LamMeas) < 1 / 2 := by
  unfold LamMeas
  constructor
  · rw [abs_lt]; constructor <;> norm_num
  · norm_num

/-- ... and hence to the booked slack factor `X = 1/(2E) ≈ 1.15302`. -/
theorem measured_slack :
    |contGapX (LamMeas / (1 + LamMeas)) - 115302 / 100000| < 1 / 100000 := by
  unfold contGapX LamMeas
  rw [abs_lt]
  constructor <;> norm_num

end F1Tightness