/-
  # The cheapest possible warp bubble: a sharp variational lower bound on exotic energy

  `AlcubierreEnergyScaling.lean` computed the exotic energy of one particular (piecewise
  linear) thin-wall profile.  The obvious next question — the one that decides whether
  clever engineering could ever tame the energy requirement — is:

      *Over **all** shape functions whose wall lives in the shell `a ≤ r ≤ b`, how small can
      the exotic energy possibly be?*

  A shape function must fall from `f = 1` at the inner edge to `f = 0` at the outer edge, so
  its radial derivative `g = f'` obeys the single normalisation `∫_a^b g = -1`.  The energy
  is `E = -(v²/12) ∫_a^b g(r)² r² dr`.  Minimising `|E|` is therefore the constrained
  variational problem `min ∫ g² r² dr` subject to `∫ g = -1`, whose solution is the
  Cauchy–Schwarz/Euler–Lagrange profile `g ∝ -1/r²`.

  Main results (all proved):

  * `warp_energy_variational_bound` — for **every** admissible profile,
    `∫_a^b g² r² dr ≥ a b / (b - a)`, hence
    `E ≤ -(v²/12) · a b/(b-a) < 0`: **no shape function whatsoever can make the warp bubble
    cheaper than a purely geometric floor**.  The proof is the completion-of-squares form of
    Cauchy–Schwarz, integrated.
  * `optimalProfile_normalised`, `optimalProfile_energy` — the floor is attained exactly by
    `g*(r) = -(ab/(b-a))/r²`, i.e. by the shape function `f*(r) = (a/r)·(b-r)/(b-a)`.
  * `linear_wall_excess` — the piecewise linear wall of `AlcubierreEnergyScaling` costs
    exactly `v² Δ / 36` more than the optimum: the naive profile is within `O(Δ)` of
    optimal, so **the `1/Δ` divergence of the warp energy is unavoidable, not an artefact of
    a bad profile choice** (`thin_wall_divergence_is_universal`).
-/

import Mathlib
import Physics.Spacetime.AlcubierreEnergyScaling

open MeasureTheory Set intervalIntegral

namespace Catalog.Physics.Spacetime.Alcubierre

/-- The geometric floor `λ = a b/(b - a)` for a wall occupying the shell `a ≤ r ≤ b`. -/
noncomputable def energyFloor (a b : ℝ) : ℝ := a * b / (b - a)

theorem energyFloor_pos {a b : ℝ} (ha : 0 < a) (hab : a < b) : 0 < energyFloor a b := by
  rw [energyFloor]
  exact div_pos (mul_pos ha (lt_trans ha hab)) (by linarith)

/-- `1/r²` is continuous on the shell. -/
theorem continuousOn_inv_sq {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    ContinuousOn (fun r : ℝ => 1 / r ^ 2) (Set.uIcc a b) := by
  rw [Set.uIcc_of_le hab.le]
  apply ContinuousOn.div continuousOn_const (by fun_prop)
  intro r hr
  have : 0 < r := lt_of_lt_of_le ha hr.1
  positivity

theorem intervalIntegrable_inv_sq {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    IntervalIntegrable (fun r : ℝ => 1 / r ^ 2) volume a b :=
  (continuousOn_inv_sq ha hab).intervalIntegrable

/-- `∫_a^b r⁻² dr = 1/a - 1/b`, the reciprocal of the geometric floor. -/
theorem integral_inv_sq {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    (∫ r in a..b, 1 / r ^ 2) = 1 / energyFloor a b := by
  have hb : 0 < b := lt_trans ha hab
  have hderiv : ∀ r ∈ Set.uIcc a b, HasDerivAt (fun r : ℝ => -(r⁻¹)) (1 / r ^ 2) r := by
    intro r hr
    rw [Set.uIcc_of_le hab.le] at hr
    have hr0 : r ≠ 0 := ne_of_gt (lt_of_lt_of_le ha hr.1)
    have h := (hasDerivAt_inv hr0).neg
    simpa [one_div] using h
  have hval := intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv
    (intervalIntegrable_inv_sq ha hab)
  rw [hval, energyFloor]
  have hane : a ≠ 0 := ne_of_gt ha
  have hbne : b ≠ 0 := ne_of_gt hb
  have habne : b - a ≠ 0 := by intro hc; linarith [sub_eq_zero.mp hc]
  field_simp
  ring

/-! ## The sharp lower bound -/

/-- **No warp profile can beat the geometric floor.**

Let the bubble wall live in the shell `a ≤ r ≤ b` with `0 < a < b`, and let `g = f'` be the
radial derivative of any admissible shape function, i.e. an integrable function with
`∫_a^b g = -1` (so that `f` drops from `1` to `0` across the wall) whose energy integrand is
integrable.  Then

    ∫_a^b g(r)² r² dr  ≥  a b / (b - a) .

Equivalently the exotic energy satisfies `E ≤ -(v²/12)·ab/(b-a)`. -/
theorem warp_energy_variational_bound {a b : ℝ} (ha : 0 < a) (hab : a < b) (g : ℝ → ℝ)
    (hg : IntervalIntegrable g volume a b)
    (hg2 : IntervalIntegrable (fun r => (g r) ^ 2 * r ^ 2) volume a b)
    (hnorm : (∫ r in a..b, g r) = -1) :
    energyFloor a b ≤ ∫ r in a..b, (g r) ^ 2 * r ^ 2 := by
  set lam := energyFloor a b with hlam
  have hlampos : 0 < lam := energyFloor_pos ha hab
  have hinv : IntervalIntegrable (fun r : ℝ => 1 / r ^ 2) volume a b :=
    intervalIntegrable_inv_sq ha hab
  -- the completed square is pointwise nonnegative on the shell
  have hnonneg : ∀ r ∈ Set.uIcc a b,
      0 ≤ (g r) ^ 2 * r ^ 2 + 2 * lam * g r + lam ^ 2 * (1 / r ^ 2) := by
    intro r hr
    rw [Set.uIcc_of_le hab.le] at hr
    have hr0 : 0 < r := lt_of_lt_of_le ha hr.1
    have hid : (g r) ^ 2 * r ^ 2 + 2 * lam * g r + lam ^ 2 * (1 / r ^ 2)
        = (g r * r + lam / r) ^ 2 := by
      field_simp
      ring
    rw [hid]
    positivity
  have hsum_int : IntervalIntegrable
      (fun r => (g r) ^ 2 * r ^ 2 + 2 * lam * g r + lam ^ 2 * (1 / r ^ 2)) volume a b :=
    ((hg2.add (hg.const_mul (2 * lam))).add (hinv.const_mul (lam ^ 2)))
  have hI : 0 ≤ ∫ r in a..b,
      ((g r) ^ 2 * r ^ 2 + 2 * lam * g r + lam ^ 2 * (1 / r ^ 2)) := by
    apply intervalIntegral.integral_nonneg hab.le
    intro r hr
    exact hnonneg r (by rw [Set.uIcc_of_le hab.le]; exact hr)
  have hsplit : (∫ r in a..b, ((g r) ^ 2 * r ^ 2 + 2 * lam * g r + lam ^ 2 * (1 / r ^ 2)))
      = (∫ r in a..b, (g r) ^ 2 * r ^ 2) + 2 * lam * (∫ r in a..b, g r)
        + lam ^ 2 * (∫ r in a..b, 1 / r ^ 2) := by
    rw [intervalIntegral.integral_add (hg2.add (hg.const_mul (2 * lam)))
      (hinv.const_mul (lam ^ 2)), intervalIntegral.integral_add hg2 (hg.const_mul (2 * lam)),
      intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul]
  rw [hsplit, hnorm, integral_inv_sq ha hab] at hI
  have hlam2 : lam ^ 2 * (1 / lam) = lam := by field_simp
  rw [hlam2] at hI
  linarith

/-! ## The optimal profile attains the floor -/

/-- The Euler–Lagrange optimum `g*(r) = -(ab/(b-a))/r²`: the radial derivative of the
cheapest possible warp shape function `f*(r) = (a/r)(b-r)/(b-a)`. -/
noncomputable def optimalProfileDeriv (a b : ℝ) (r : ℝ) : ℝ := -(energyFloor a b) / r ^ 2

/-- The optimal profile is admissible: its integral across the wall is `-1`, i.e. it takes
the shape function from `1` down to `0`. -/
theorem optimalProfile_normalised {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    (∫ r in a..b, optimalProfileDeriv a b r) = -1 := by
  have hfun : (fun r => optimalProfileDeriv a b r)
      = fun r => (-(energyFloor a b)) * (1 / r ^ 2) := by
    funext r; rw [optimalProfileDeriv]; ring
  rw [hfun, intervalIntegral.integral_const_mul, integral_inv_sq ha hab]
  have := energyFloor_pos ha hab
  field_simp

/-- The optimal profile attains the geometric floor exactly. -/
theorem optimalProfile_energy {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    (∫ r in a..b, (optimalProfileDeriv a b r) ^ 2 * r ^ 2) = energyFloor a b := by
  have hpos := energyFloor_pos ha hab
  have hfun : (fun r => (optimalProfileDeriv a b r) ^ 2 * r ^ 2)
      = fun r => (energyFloor a b) ^ 2 * (1 / r ^ 2) := by
    funext r
    rcases eq_or_ne r 0 with rfl | hr
    · simp [optimalProfileDeriv]
    · rw [optimalProfileDeriv]
      field_simp
  rw [hfun, intervalIntegral.integral_const_mul, integral_inv_sq ha hab]
  field_simp

/-- **Sharpness.**  The bound of `warp_energy_variational_bound` is attained, so
`ab/(b-a)` is exactly the minimal exotic-energy integral of a wall confined to the shell. -/
theorem warp_energy_floor_is_sharp {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    IsLeast {I : ℝ | ∃ g : ℝ → ℝ, IntervalIntegrable g volume a b ∧
        IntervalIntegrable (fun r => (g r) ^ 2 * r ^ 2) volume a b ∧
        (∫ r in a..b, g r) = -1 ∧ I = ∫ r in a..b, (g r) ^ 2 * r ^ 2}
      (energyFloor a b) := by
  constructor
  · refine ⟨optimalProfileDeriv a b, ?_, ?_, optimalProfile_normalised ha hab,
      (optimalProfile_energy ha hab).symm⟩
    · have hfun : (optimalProfileDeriv a b)
          = fun r => (-(energyFloor a b)) * (1 / r ^ 2) := by
        funext r; rw [optimalProfileDeriv]; ring
      rw [hfun]
      exact (intervalIntegrable_inv_sq ha hab).const_mul _
    · have hfun : (fun r => (optimalProfileDeriv a b r) ^ 2 * r ^ 2)
          = fun r => (energyFloor a b) ^ 2 * (1 / r ^ 2) := by
        funext r
        rcases eq_or_ne r 0 with rfl | hr
        · simp [optimalProfileDeriv]
        · rw [optimalProfileDeriv]
          field_simp
      rw [hfun]
      exact (intervalIntegrable_inv_sq ha hab).const_mul _
  · rintro I ⟨g, hg, hg2, hnorm, rfl⟩
    exact warp_energy_variational_bound ha hab g hg hg2 hnorm

/-! ## Comparison with the linear wall: the `1/Δ` divergence is universal -/

/-- The geometric floor of a wall of thickness `Δ` at radius `R` is `R²/Δ - Δ/4`. -/
theorem energyFloor_wall (R Δ : ℝ) (hΔ : 0 < Δ) :
    energyFloor (R - Δ / 2) (R + Δ / 2) = R ^ 2 / Δ - Δ / 4 := by
  rw [energyFloor]
  have h : (R + Δ / 2) - (R - Δ / 2) = Δ := by ring
  rw [h]
  field_simp
  ring

/-- **The piecewise-linear wall is nearly optimal.**  Its energy integral exceeds the
geometric floor by exactly `Δ/3`, i.e. its total energy exceeds the optimum by exactly
`v²Δ/36` — a correction of order `Δ`, negligible against the `R²/Δ` main term. -/
theorem linear_wall_excess (R Δ : ℝ) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R) (v : ℝ) :
    (-(v ^ 2 / 12) * energyFloor (R - Δ / 2) (R + Δ / 2))
      - radialWarpEnergy v (wallShapeDeriv R Δ) = v ^ 2 * Δ / 36 := by
  rw [wall_energy_scaling_law v R Δ hΔ hRΔ, energyFloor_wall R Δ hΔ]
  ring

/-- **The thin-wall divergence is universal.**  For *every* admissible shape function whose
wall is confined to the shell of thickness `Δ` at radius `R`, the magnitude of the exotic
energy is at least `(v²/12)(R²/Δ - Δ/4)`.  No engineering of the profile can avoid the
`1/Δ` blow-up as the wall is thinned. -/
theorem thin_wall_divergence_is_universal (R Δ v : ℝ) (hΔ : 0 < Δ) (hRΔ : Δ < 2 * R)
    (g : ℝ → ℝ)
    (hg : IntervalIntegrable g volume (R - Δ / 2) (R + Δ / 2))
    (hg2 : IntervalIntegrable (fun r => (g r) ^ 2 * r ^ 2) volume (R - Δ / 2) (R + Δ / 2))
    (hnorm : (∫ r in (R - Δ / 2)..(R + Δ / 2), g r) = -1) :
    (v ^ 2 / 12) * (R ^ 2 / Δ - Δ / 4)
      ≤ (v ^ 2 / 12) * ∫ r in (R - Δ / 2)..(R + Δ / 2), (g r) ^ 2 * r ^ 2 := by
  have ha : 0 < R - Δ / 2 := by linarith
  have hab : R - Δ / 2 < R + Δ / 2 := by linarith
  have hbound := warp_energy_variational_bound ha hab g hg hg2 hnorm
  rw [energyFloor_wall R Δ hΔ] at hbound
  have hv : 0 ≤ v ^ 2 / 12 := by positivity
  exact mul_le_mul_of_nonneg_left hbound hv

end Catalog.Physics.Spacetime.Alcubierre