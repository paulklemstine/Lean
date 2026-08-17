/-
  # How much exotic matter?  Exact energy of a thin-wall warp bubble, and the failure of
  # the linear scaling conjecture `E ~ M v_s c`

  Integrating the Eulerian energy density of `AlcubierreEnergy.lean` over a slice
  `t = const` for a spherically symmetric shape function `f(r_s)` gives

      E = ∫ ρ d³x
        = -(1/(32π)) v_s² ∫ (f'(r))² (y²+z²)/r² d³x
        = -(1/(32π)) v_s² · (8π/3) ∫₀^∞ (f'(r))² r² dr        [angular integral: ∫_{S²}(y²+z²)/r² dΩ = 8π/3]
        = -(v_s²/12) ∫₀^∞ (f'(r))² r² dr .

  The elementary angular average `⟨(y²+z²)/r²⟩ = 2/3` has been performed by hand; the
  functional `radialWarpEnergy` below encodes the resulting one–dimensional integral, and
  everything from there on is proved.

  Main results:

  * `radialWarpEnergy_nonpos` — the total energy of *any* warp profile is nonpositive.
  * `wallShape_hasDerivAt` — the piecewise-linear thin-wall shape function (`f = 1` inside
    the bubble, `f = 0` outside, linear across a wall of thickness `Δ` at radius `R`) is a
    bona fide shape function with the stated derivative.
  * `wall_energy_exact` — the **exact closed form**
        `E(v, R, Δ) = - v² R² / (12 Δ) - v² Δ / 144`.
  * `wall_energy_neg` — it is strictly negative for every nonzero warp speed.
  * `energy_quadratic_scaling` — `E(λ v) = λ² E(v)` for every profile.
  * `linear_energy_scaling_false` — **the conjecture `E ~ M v_s c` is false**: no constant
    (in particular no ship mass `M`, in units `c = G = 1`) can make the total exotic energy
    proportional to the warp speed.  The true growth is quadratic, and `energy_beats_linear`
    shows the energy eventually exceeds *any* linear law.
  * `thin_wall_blowup` — for fixed bubble radius the energy diverges like `1/Δ` as the wall
    is thinned: arbitrarily large negative energy is needed for arbitrarily thin walls.
-/

import Mathlib
import Physics.Spacetime.AlcubierreEnergy

open MeasureTheory Set

namespace Catalog.Physics.Spacetime.Alcubierre

/-- Total exotic energy on a slice `t = const`, as a functional of the radial derivative
`g = f'` of the shape function (the angular integration has been carried out; see the file
header). -/
noncomputable def radialWarpEnergy (v : ℝ) (g : ℝ → ℝ) : ℝ :=
  -(v ^ 2 / 12) * ∫ r in Ioi (0:ℝ), (g r) ^ 2 * r ^ 2

/-- **The total energy of any warp profile is nonpositive.** -/
theorem radialWarpEnergy_nonpos (v : ℝ) (g : ℝ → ℝ) : radialWarpEnergy v g ≤ 0 := by
  have hI : 0 ≤ ∫ r in Ioi (0:ℝ), (g r) ^ 2 * r ^ 2 :=
    setIntegral_nonneg measurableSet_Ioi (fun x _ => by positivity)
  have hv : 0 ≤ v ^ 2 / 12 := by positivity
  rw [radialWarpEnergy]
  nlinarith

/-- **Quadratic homogeneity in the warp speed.**  This holds for every profile, integrable
or not, because the warp speed enters only through the overall factor `v²`. -/
theorem energy_quadratic_scaling (lam v : ℝ) (g : ℝ → ℝ) :
    radialWarpEnergy (lam * v) g = lam ^ 2 * radialWarpEnergy v g := by
  simp only [radialWarpEnergy]
  ring

/-! ## The thin-wall profile -/

/-- Piecewise-linear thin-wall shape function: `f = 1` for `r ≤ R - Δ/2`, `f = 0` for
`r ≥ R + Δ/2`, linear in between. -/
noncomputable def wallShape (R Δ r : ℝ) : ℝ :=
  if r ≤ R - Δ / 2 then 1 else if r < R + Δ / 2 then (R + Δ / 2 - r) / Δ else 0

/-- Its derivative: `-1/Δ` inside the wall, `0` elsewhere. -/
noncomputable def wallShapeDeriv (R Δ r : ℝ) : ℝ :=
  if R - Δ / 2 < r ∧ r < R + Δ / 2 then -1 / Δ else 0

@[simp] theorem wallShape_inner {R Δ r : ℝ} (h : r ≤ R - Δ / 2) : wallShape R Δ r = 1 := by
  simp [wallShape, h]

@[simp] theorem wallShape_outer {R Δ r : ℝ} (h : R + Δ / 2 ≤ r) (hΔ : 0 < Δ) :
    wallShape R Δ r = 0 := by
  have h1 : ¬ (r ≤ R - Δ / 2) := by intro hc; linarith
  have h2 : ¬ (r < R + Δ / 2) := by intro hc; linarith
  simp [wallShape, h1, h2]

/-- The thin-wall profile is a genuine Alcubierre shape function: it interpolates
monotonically from `1` at the centre to `0` outside. -/
theorem wallShape_mem_Icc {R Δ r : ℝ} (hΔ : 0 < Δ) : wallShape R Δ r ∈ Icc (0:ℝ) 1 := by
  unfold wallShape
  split_ifs with h1 h2
  · exact ⟨by norm_num, le_refl 1⟩
  · push_neg at h1
    constructor
    · apply div_nonneg (by linarith) hΔ.le
    · rw [div_le_one hΔ]; linarith
  · exact ⟨le_refl 0, by norm_num⟩

/-- **The thin-wall profile is differentiable away from the two wall edges, with the stated
derivative.** -/
theorem wallShape_hasDerivAt {R Δ r : ℝ} (hΔ : 0 < Δ) (h1 : r ≠ R - Δ / 2)
    (h2 : r ≠ R + Δ / 2) :
    HasDerivAt (wallShape R Δ) (wallShapeDeriv R Δ r) r := by
  rcases lt_trichotomy r (R - Δ / 2) with hlt | heq | hgt
  · -- interior of the bubble: locally constant `1`
    have hev : wallShape R Δ =ᶠ[nhds r] fun _ => (1:ℝ) := by
      filter_upwards [Iio_mem_nhds hlt] with s hs
      exact wallShape_inner (le_of_lt hs)
    have hd : HasDerivAt (fun _ : ℝ => (1:ℝ)) 0 r := hasDerivAt_const r 1
    have hzero : wallShapeDeriv R Δ r = 0 := by
      simp [wallShapeDeriv, not_lt.mpr (le_of_lt hlt)]
    rw [hzero]
    exact hd.congr_of_eventuallyEq hev
  · exact absurd heq h1
  · rcases lt_trichotomy r (R + Δ / 2) with hlt' | heq' | hgt'
    · -- inside the wall: locally linear
      have hev : wallShape R Δ =ᶠ[nhds r] fun s => (R + Δ / 2 - s) / Δ := by
        filter_upwards [Ioo_mem_nhds hgt hlt'] with s hs
        have hs1 : ¬ (s ≤ R - Δ / 2) := by intro hc; linarith [hs.1]
        simp [wallShape, hs1, hs.2]
      have hd : HasDerivAt (fun s : ℝ => (R + Δ / 2 - s) / Δ) (-1 / Δ) r := by
        have : HasDerivAt (fun s : ℝ => R + Δ / 2 - s) (-1) r := by
          simpa using (hasDerivAt_id r).const_sub (R + Δ / 2)
        simpa using this.div_const Δ
      have hval : wallShapeDeriv R Δ r = -1 / Δ := by
        simp [wallShapeDeriv, hgt, hlt']
      rw [hval]
      exact hd.congr_of_eventuallyEq hev
    · exact absurd heq' h2
    · -- outside the bubble: locally zero
      have hev : wallShape R Δ =ᶠ[nhds r] fun _ => (0:ℝ) := by
        filter_upwards [Ioi_mem_nhds hgt'] with s hs
        exact wallShape_outer (le_of_lt hs) hΔ
      have hzero : wallShapeDeriv R Δ r = 0 := by
        simp [wallShapeDeriv, not_lt.mpr (le_of_lt hgt')]
      rw [hzero]
      exact (hasDerivAt_const r (0:ℝ)).congr_of_eventuallyEq hev

/-! ## The exact energy of a thin-wall bubble -/

/-- The integrand of the energy functional for the thin-wall profile is the indicator of the
wall. -/
theorem wall_integrand_eq (R Δ : ℝ) (hΔ : 0 < Δ) :
    (fun r => (wallShapeDeriv R Δ r) ^ 2 * r ^ 2)
      = (Ioo (R - Δ / 2) (R + Δ / 2)).indicator (fun r => r ^ 2 / Δ ^ 2) := by
  funext r
  by_cases hr : r ∈ Ioo (R - Δ / 2) (R + Δ / 2)
  · rw [Set.indicator_of_mem hr]
    have : wallShapeDeriv R Δ r = -1 / Δ := by simp [wallShapeDeriv, hr.1, hr.2]
    rw [this]
    field_simp
  · rw [Set.indicator_of_notMem hr]
    have : wallShapeDeriv R Δ r = 0 := by
      simp only [wallShapeDeriv, mem_Ioo] at *
      simp [hr]
    rw [this]
    ring

/-- **Exact total exotic energy of a thin-wall warp bubble.**
For a bubble of radius `R` with wall thickness `Δ < 2R`,
`E = - v² R² / (12 Δ) - v² Δ / 144`. -/
theorem wall_energy_exact (v R Δ : ℝ) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R) :
    radialWarpEnergy v (wallShapeDeriv R Δ)
      = -(v ^ 2 * R ^ 2) / (12 * Δ) - v ^ 2 * Δ / 144 := by
  have ha : 0 < R - Δ / 2 := by linarith
  have hab : R - Δ / 2 ≤ R + Δ / 2 := by linarith
  have hsub : Ioo (R - Δ / 2) (R + Δ / 2) ⊆ Ioi (0:ℝ) := fun x hx =>
    lt_trans ha hx.1
  have hI : (∫ r in Ioi (0:ℝ), (wallShapeDeriv R Δ r) ^ 2 * r ^ 2)
      = ∫ r in Ioo (R - Δ / 2) (R + Δ / 2), r ^ 2 / Δ ^ 2 := by
    rw [wall_integrand_eq R Δ hΔ, setIntegral_indicator measurableSet_Ioo,
      Set.inter_eq_self_of_subset_right hsub]
  have hIoo : (∫ r in Ioo (R - Δ / 2) (R + Δ / 2), r ^ 2 / Δ ^ 2)
      = ∫ r in (R - Δ / 2)..(R + Δ / 2), r ^ 2 / Δ ^ 2 := by
    rw [intervalIntegral.integral_of_le hab, ← integral_Ioc_eq_integral_Ioo]
  have hval : (∫ r in (R - Δ / 2)..(R + Δ / 2), r ^ 2 / Δ ^ 2)
      = ((R + Δ / 2) ^ 3 - (R - Δ / 2) ^ 3) / (3 * Δ ^ 2) := by
    rw [intervalIntegral.integral_div, integral_pow]
    field_simp
    ring
  rw [radialWarpEnergy, hI, hIoo, hval]
  field_simp
  ring

/-- The thin-wall energy is strictly negative for every nonzero warp speed. -/
theorem wall_energy_neg (v R Δ : ℝ) (hv : v ≠ 0) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R) :
    radialWarpEnergy v (wallShapeDeriv R Δ) < 0 := by
  rw [wall_energy_exact v R Δ hΔ hRΔ]
  have hv2 : 0 < v ^ 2 := pow_two_pos_of_ne_zero hv
  have hR : 0 < R := by linarith
  have h1 : 0 < v ^ 2 * R ^ 2 / (12 * Δ) := by positivity
  have h2 : 0 < v ^ 2 * Δ / 144 := by positivity
  have heq : -(v ^ 2 * R ^ 2) / (12 * Δ) = -(v ^ 2 * R ^ 2 / (12 * Δ)) := by ring
  rw [heq]
  linarith

/-! ## Refuting the conjecture `E ~ M v_s c` -/

/-- **The conjectured linear energy law is false.**
For a fixed bubble geometry there is *no* constant `C` (in particular no multiple of the
ship mass, in units `c = G = 1`) for which the total exotic energy is proportional to the
warp speed: the energy is exactly quadratic in `v_s`. -/
theorem linear_energy_scaling_false (R Δ : ℝ) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R) :
    ¬ ∃ C : ℝ, ∀ v : ℝ, radialWarpEnergy v (wallShapeDeriv R Δ) = C * v := by
  rintro ⟨C, hC⟩
  have h1 : radialWarpEnergy 1 (wallShapeDeriv R Δ) = C := by simpa using hC 1
  have h2 : radialWarpEnergy 2 (wallShapeDeriv R Δ) = C * 2 := hC 2
  have hquad : radialWarpEnergy 2 (wallShapeDeriv R Δ)
      = 4 * radialWarpEnergy 1 (wallShapeDeriv R Δ) := by
    have h := energy_quadratic_scaling 2 1 (wallShapeDeriv R Δ)
    norm_num at h
    linarith [h]
  have hneg : radialWarpEnergy 1 (wallShapeDeriv R Δ) < 0 :=
    wall_energy_neg 1 R Δ one_ne_zero hΔ hRΔ
  rw [h1, h2] at hquad
  linarith

/-- **The exotic energy eventually exceeds every linear law.**  Given any putative
"mass coefficient" `M`, for all sufficiently large warp speeds the required negative energy
exceeds `M v_s` in magnitude — so `E ~ M v_s c` cannot even hold asymptotically. -/
theorem energy_beats_linear (R Δ M : ℝ) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R) (hM : 0 < M) :
    ∃ v0 : ℝ, 0 < v0 ∧ ∀ v : ℝ, v0 < v → M * v < |radialWarpEnergy v (wallShapeDeriv R Δ)| := by
  set K : ℝ := R ^ 2 / (12 * Δ) + Δ / 144 with hK
  have hR : 0 < R := by linarith
  have hKpos : 0 < K := by rw [hK]; positivity
  refine ⟨M / K, by positivity, ?_⟩
  intro v hv
  have hvpos : 0 < v := lt_trans (by positivity) hv
  have hE : radialWarpEnergy v (wallShapeDeriv R Δ) = -(v ^ 2 * K) := by
    rw [wall_energy_exact v R Δ hΔ hRΔ, hK]
    field_simp
    ring
  rw [hE, abs_neg, abs_of_nonneg (by positivity)]
  have : M / K * K < v * K := by
    apply mul_lt_mul_of_pos_right hv hKpos
  have hMK : M < v * K := by
    rwa [div_mul_cancel₀ M (ne_of_gt hKpos)] at this
  nlinarith

/-- **Thin walls cost unboundedly much.**  For a fixed bubble radius, the exotic energy
diverges as `-v² R²/(12Δ)` when the wall thickness `Δ → 0`. -/
theorem thin_wall_blowup (v R B : ℝ) (hv : v ≠ 0) (hR : 0 < R) (hB : 0 < B) :
    ∃ Δ0 : ℝ, 0 < Δ0 ∧ ∀ Δ : ℝ, 0 < Δ → Δ < Δ0 →
      radialWarpEnergy v (wallShapeDeriv R Δ) < -B := by
  have hv2 : 0 < v ^ 2 := pow_two_pos_of_ne_zero hv
  refine ⟨min R (v ^ 2 * R ^ 2 / (12 * B)), by positivity, ?_⟩
  intro Δ hΔ hlt
  have hΔR : Δ < R := lt_of_lt_of_le hlt (min_le_left _ _)
  have hΔB : Δ < v ^ 2 * R ^ 2 / (12 * B) := lt_of_lt_of_le hlt (min_le_right _ _)
  have hRΔ : Δ < 2 * R := by linarith
  rw [wall_energy_exact v R Δ hΔ hRΔ]
  have hkey : B < v ^ 2 * R ^ 2 / (12 * Δ) := by
    rw [lt_div_iff₀ (by positivity)]
    have h12 : (0:ℝ) < 12 * B := by positivity
    rw [lt_div_iff₀ h12] at hΔB
    nlinarith
  have hpos : 0 < v ^ 2 * Δ / 144 := by positivity
  have : -(v ^ 2 * R ^ 2) / (12 * Δ) = -(v ^ 2 * R ^ 2 / (12 * Δ)) := by ring
  rw [this]
  linarith

/-- Summary of the corrected scaling law: with `c = G = 1`, the exotic energy of a
thin-wall Alcubierre bubble of radius `R` and wall thickness `Δ` is exactly
`-(v²/12)(R²/Δ + Δ/12)`, i.e. **quadratic** in the warp speed, **quadratic** in the bubble
radius and **inversely proportional** to the wall thickness. -/
theorem wall_energy_scaling_law (v R Δ : ℝ) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R) :
    radialWarpEnergy v (wallShapeDeriv R Δ)
      = -(v ^ 2 / 12) * (R ^ 2 / Δ + Δ / 12) := by
  rw [wall_energy_exact v R Δ hΔ hRΔ]
  field_simp
  ring

/-! ## Numerical corroboration -/

/-- A concrete instance of the closed form: a bubble of radius `100` with a wall of
thickness `1`, at warp speed `2`, costs exactly `-120001/36 ≈ -3333.36` (in units
`c = G = 1`). -/
theorem wall_energy_numeric_speed_two :
    radialWarpEnergy 2 (wallShapeDeriv 100 1) = -120001 / 36 := by
  rw [wall_energy_exact 2 100 1 (by norm_num) (by norm_num)]
  norm_num

/-- Doubling the warp speed with the same geometry multiplies the cost by exactly four —
the numerical fingerprint of the quadratic (not linear) scaling law. -/
theorem wall_energy_numeric_speed_four :
    radialWarpEnergy 4 (wallShapeDeriv 100 1) = 4 * radialWarpEnergy 2 (wallShapeDeriv 100 1) := by
  rw [wall_energy_exact 4 100 1 (by norm_num) (by norm_num),
    wall_energy_exact 2 100 1 (by norm_num) (by norm_num)]
  norm_num

end Catalog.Physics.Spacetime.Alcubierre