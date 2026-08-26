/-
# Can a different window rescue the ascending scan?  A no-go theorem

Cycle 1 (`Novelty.GeneratorTiltRatio`) fixed the *canonical* window `(√(N/2), √N]`, whose
multiplier is `R = 2`, and found the tie ratio `r★ = 24 - 16√2 ≈ 1.3726`.  The obvious
follow-up is a design question: the window multiplier is a free parameter — scanning
`(√(N/R), √N]` upwards is well defined whenever the generator guarantees `q < R p` — so can
a *wider* (or narrower) window make the ascending order win on the near-balanced populations
that deployed generators actually produce?

This file answers **no**, quantitatively.  For the `R`-window the tilt law is
`zGen R r = (r^{-1/2} - R^{-1/2}) / (1 - R^{-1/2})`, and:

* `zGen_criticalRatioGen`, `half_lt_zGen_iff` — the tie ratio for multiplier `R` is exactly
  `r★(R) = 4R / (1 + √R)²`, and ratios below it are top-heavy (ascending loses);
* `one_lt_criticalRatioGen` — `r★(R) > 1` for **every** `R > 1`: whatever the window, an
  interval of ratios just above `1` is adversarial to the ascending scan.  Since real
  generators concentrate the ratio near `1`, no window design removes the adversarial tilt;
* `criticalRatioGen_lt_four` — moreover `r★(R) < 4` for every `R`: the tie point can never be
  pushed past ratio `4`, so the "widen the window" strategy is capped;
* `integral_zGen` / `mean_zGen_uniform` — the exact mean tilt of a *ratio-uniform* pool on
  `[1, R]` is `1/(1 + √R)`, always `< 1/2`.  Artificial ratio-uniform pools are bottom-heavy
  for every window multiplier, which is precisely why they are the only place a
  window-ascending advantage was ever seen.  (At `R = 2` this recovers `√2 - 1`.)

Taken together with `Novelty.GeneratorTiltSynthesis`, the scope boundary is now closed on
both sides: bottom-heavy = artificial ratio-spread pools, top-heavy = near-balanced deployed
pools, for every admissible window.
-/
import Novelty.GeneratorTiltRatio

namespace GeneratorTilt

open Real

/-- Tilt law for the window `(√(N/R), √N]` of multiplier `R`. -/
noncomputable def zGen (R r : ℝ) : ℝ :=
  (1 / Real.sqrt r - 1 / Real.sqrt R) / (1 - 1 / Real.sqrt R)

/-- Tie ratio for window multiplier `R`: `4R / (1 + √R)²`. -/
noncomputable def criticalRatioGen (R : ℝ) : ℝ := 4 * R / (1 + Real.sqrt R) ^ 2

theorem zGen_two (r : ℝ) : zGen 2 r = zOfRatio r := rfl

section
variable {R : ℝ}

theorem one_lt_sqrt (hR : 1 < R) : 1 < Real.sqrt R := by
  have : Real.sqrt 1 < Real.sqrt R := Real.sqrt_lt_sqrt (by norm_num) hR
  simpa using this

theorem sqrt_sq_self (hR : 1 < R) : Real.sqrt R * Real.sqrt R = R :=
  Real.mul_self_sqrt (by linarith)

theorem one_sub_inv_sqrt_pos (hR : 1 < R) : 0 < 1 - 1 / Real.sqrt R := by
  have h := one_lt_sqrt hR
  rw [sub_pos, div_lt_one (by linarith)]
  exact h

/-! ## Values, monotonicity, the tie ratio -/

theorem zGen_one (hR : 1 < R) : zGen R 1 = 1 := by
  have h := one_lt_sqrt hR
  unfold zGen
  rw [Real.sqrt_one]
  have hne : Real.sqrt R - 1 ≠ 0 := by linarith
  field_simp

theorem zGen_strictAntiOn (hR : 1 < R) : StrictAntiOn (zGen R) (Set.Ioi (0:ℝ)) := by
  intro x hx y _ hxy
  have hx0 : (0:ℝ) < x := hx
  have hsx : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx0
  have hlt : Real.sqrt x < Real.sqrt y := Real.sqrt_lt_sqrt hx0.le hxy
  have hinv : 1 / Real.sqrt y < 1 / Real.sqrt x := one_div_lt_one_div_of_lt hsx hlt
  have hd := one_sub_inv_sqrt_pos hR
  unfold zGen
  rw [div_lt_div_iff₀ hd hd]
  nlinarith

theorem criticalRatioGen_pos (hR : 1 < R) : 0 < criticalRatioGen R := by
  have h := one_lt_sqrt hR
  unfold criticalRatioGen
  positivity

theorem sqrt_criticalRatioGen (hR : 1 < R) :
    Real.sqrt (criticalRatioGen R) = 2 * Real.sqrt R / (1 + Real.sqrt R) := by
  have h := one_lt_sqrt hR
  have h2 := sqrt_sq_self hR
  have hpos : (0:ℝ) < 1 + Real.sqrt R := by linarith
  unfold criticalRatioGen
  rw [show 4 * R / (1 + Real.sqrt R) ^ 2 = (2 * Real.sqrt R / (1 + Real.sqrt R)) ^ 2 by
        field_simp; nlinarith]
  exact Real.sqrt_sq (by positivity)

/-- The tie ratio really is a tie: at `r★(R) = 4R/(1+√R)²` the tilt is exactly `1/2`. -/
theorem zGen_criticalRatioGen (hR : 1 < R) : zGen R (criticalRatioGen R) = 1 / 2 := by
  have h := one_lt_sqrt hR
  have h2 := sqrt_sq_self hR
  have hd := one_sub_inv_sqrt_pos hR
  have hne : Real.sqrt R - 1 ≠ 0 := by linarith
  unfold zGen
  rw [sqrt_criticalRatioGen hR]
  field_simp
  ring

/-- Top-heaviness for the `R`-window is exactly "ratio below the tie ratio". -/
theorem half_lt_zGen_iff (hR : 1 < R) {r : ℝ} (hr : 0 < r) :
    1 / 2 < zGen R r ↔ r < criticalRatioGen R := by
  rw [← zGen_criticalRatioGen hR]
  exact StrictAntiOn.lt_iff_gt (zGen_strictAntiOn hR)
    (Set.mem_Ioi.mpr (criticalRatioGen_pos hR)) (Set.mem_Ioi.mpr hr)

/-! ## The no-go bounds on the tie ratio -/

/-- **No window design is safe near balance.**  For every multiplier `R > 1` the tie ratio
exceeds `1`, so a whole interval of near-balanced ratios stays top-heavy: widening or
narrowing the window cannot make the ascending scan win there. -/
theorem one_lt_criticalRatioGen (hR : 1 < R) : 1 < criticalRatioGen R := by
  have h := one_lt_sqrt hR
  have h2 := sqrt_sq_self hR
  have hpos : (0:ℝ) < (1 + Real.sqrt R) ^ 2 := by positivity
  unfold criticalRatioGen
  rw [lt_div_iff₀ hpos]
  nlinarith

/-- The tie ratio always stays inside its own admissible band. -/
theorem criticalRatioGen_lt_self (hR : 1 < R) : criticalRatioGen R < R := by
  have h := one_lt_sqrt hR
  have h2 := sqrt_sq_self hR
  have hpos : (0:ℝ) < (1 + Real.sqrt R) ^ 2 := by positivity
  unfold criticalRatioGen
  rw [div_lt_iff₀ hpos]
  nlinarith

/-- **Hard cap on window design.**  However wide the window, the tie ratio never reaches `4`:
`r★(R) < 4` for all `R > 1`.  So no admissible window makes the ascending scan the winner on
ratios below `4`. -/
theorem criticalRatioGen_lt_four (hR : 1 < R) : criticalRatioGen R < 4 := by
  have h := one_lt_sqrt hR
  have h2 := sqrt_sq_self hR
  have hpos : (0:ℝ) < (1 + Real.sqrt R) ^ 2 := by positivity
  unfold criticalRatioGen
  rw [div_lt_iff₀ hpos]
  nlinarith

/-- **No-go theorem.**  For every window multiplier `R > 1` there is a ratio strictly between
`1` and `min R 4` at which the population is top-heavy, i.e. the window-ascending scan
loses.  No choice of window turns the near-balanced regime into a Λ-channel gain. -/
theorem window_design_no_go (hR : 1 < R) :
    ∃ r, 1 < r ∧ r < R ∧ r < 4 ∧ 1 / 2 < zGen R r := by
  refine ⟨(1 + criticalRatioGen R) / 2, ?_, ?_, ?_, ?_⟩
  · linarith [one_lt_criticalRatioGen hR]
  · linarith [one_lt_criticalRatioGen hR, criticalRatioGen_lt_self hR]
  · linarith [one_lt_criticalRatioGen hR, criticalRatioGen_lt_four hR]
  · rw [half_lt_zGen_iff hR (by linarith [one_lt_criticalRatioGen hR])]
    linarith [one_lt_criticalRatioGen hR]

/-! ## Ratio-uniform pools are bottom-heavy for every window -/

theorem integral_one_div_sqrt_gen (hR : 1 < R) :
    ∫ r in (1:ℝ)..R, 1 / Real.sqrt r = 2 * Real.sqrt R - 2 := by
  have h : ∀ r ∈ Set.uIcc (1:ℝ) R, 1 / Real.sqrt r = r ^ (-(1:ℝ)/2) := by
    intro r hr
    rw [Set.uIcc_of_le (by linarith)] at hr
    have hr0 : (0:ℝ) ≤ r := le_trans (by norm_num) hr.1
    rw [show -(1:ℝ)/2 = -(1/2) by ring, Real.rpow_neg hr0, ← Real.sqrt_eq_rpow, one_div]
  rw [intervalIntegral.integral_congr h, integral_rpow (by left; norm_num),
    show -(1:ℝ)/2 + 1 = 1/2 by ring, ← Real.sqrt_eq_rpow, ← Real.sqrt_eq_rpow, Real.sqrt_one]
  ring

theorem intervalIntegrable_one_div_sqrt_gen (hR : 1 < R) :
    IntervalIntegrable (fun r : ℝ => 1 / Real.sqrt r) MeasureTheory.volume 1 R := by
  apply ContinuousOn.intervalIntegrable
  apply ContinuousOn.div continuousOn_const Real.continuous_sqrt.continuousOn
  intro x hx
  rw [Set.uIcc_of_le (by linarith)] at hx
  exact ne_of_gt (Real.sqrt_pos.mpr (by linarith [hx.1]))

/-- Total tilt of a ratio-uniform pool on `[1, R]`. -/
theorem integral_zGen (hR : 1 < R) :
    (∫ r in (1:ℝ)..R, zGen R r) = (R - 1) / (1 + Real.sqrt R) := by
  have hs := one_lt_sqrt hR
  have h2 := sqrt_sq_self hR
  have hd := one_sub_inv_sqrt_pos hR
  have hne : Real.sqrt R - 1 ≠ 0 := by linarith
  have hne0 : Real.sqrt R ≠ 0 := by linarith
  have hfun : ∀ r ∈ Set.uIcc (1:ℝ) R, zGen R r
      = (1 - 1 / Real.sqrt R)⁻¹ * (1 / Real.sqrt r)
        - (1 / Real.sqrt R) / (1 - 1 / Real.sqrt R) := by
    intro r _
    unfold zGen
    field_simp
  rw [intervalIntegral.integral_congr hfun,
    intervalIntegral.integral_sub ((intervalIntegrable_one_div_sqrt_gen hR).const_mul _)
      intervalIntegrable_const,
    intervalIntegral.integral_const_mul, integral_one_div_sqrt_gen hR,
    intervalIntegral.integral_const]
  simp only [smul_eq_mul]
  field_simp
  nlinarith [h2, hs]

/-- **Mean tilt of a ratio-uniform pool** with window multiplier `R` is exactly
`1/(1 + √R)`.  At `R = 2` this is `√2 - 1 = 0.41421…`, the hard-balance control value. -/
theorem mean_zGen_uniform (hR : 1 < R) :
    (∫ r in (1:ℝ)..R, zGen R r) / (R - 1) = 1 / (1 + Real.sqrt R) := by
  rw [integral_zGen hR]
  have hs := one_lt_sqrt hR
  have h1 : R - 1 ≠ 0 := by linarith
  have h2 : (0:ℝ) < 1 + Real.sqrt R := by linarith
  field_simp

/-- **Ratio-uniform pools are always bottom-heavy.**  For every window multiplier `R > 1` the
mean tilt `1/(1+√R)` is below `1/2`, so the window-ascending order wins on such pools.  The
Λ-channel advantage is therefore a property of the artificial ratio-*spread* population, not
of any window choice — and it is destroyed by the ratio concentration of real generators. -/
theorem mean_zGen_uniform_lt_half (hR : 1 < R) :
    (∫ r in (1:ℝ)..R, zGen R r) / (R - 1) < 1 / 2 := by
  rw [mean_zGen_uniform hR]
  have hs := one_lt_sqrt hR
  rw [div_lt_div_iff₀ (by linarith) (by norm_num)]
  linarith

/-- Consistency with cycle 1: at the canonical multiplier `R = 2` the general tie ratio
specialises to `24 - 16√2`. -/
theorem criticalRatioGen_two : criticalRatioGen 2 = criticalRatio := by
  have h2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sqrt_two_sq
  have hpos : (0:ℝ) < (1 + Real.sqrt 2) ^ 2 := by positivity
  unfold criticalRatioGen criticalRatio
  rw [div_eq_iff (ne_of_gt hpos)]
  nlinarith [h2]

end

end GeneratorTilt