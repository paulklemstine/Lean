import Mathlib

/-!
# The Ising Model Critical Temperature

This file formalizes the critical inverse temperature `βc = (1/2) log(1 + √2)`
of the two-dimensional Ising model, characterized by the Kramers–Wannier
self-duality fixed point condition `sinh(2β) = 1`.
-/

noncomputable section

namespace IsingCriticalTemperature

open Real

/-- The critical inverse temperature of the 2D Ising model. -/
noncomputable def isingBetaC : ℝ := (1 / 2) * log (1 + sqrt 2)

/-- The critical temperature of the 2D Ising model. -/
noncomputable def isingTc : ℝ := 2 / log (1 + sqrt 2)

/-- The reciprocal of `1 + √2` equals `√2 - 1`. -/
theorem inv_one_add_sqrt_two : (1 + sqrt 2)⁻¹ = sqrt 2 - 1 := by
  have hs : sqrt 2 * sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  refine inv_eq_of_mul_eq_one_left ?_
  nlinarith [hs]

/-- At the critical inverse temperature, `sinh(2βc) = 1`. -/
theorem sinh_two_isingBetaC : sinh (2 * isingBetaC) = 1 := by
  have hx : (0 : ℝ) < 1 + sqrt 2 := by positivity
  have he : 2 * isingBetaC = log (1 + sqrt 2) := by unfold isingBetaC; ring
  rw [he, Real.sinh_log hx, inv_one_add_sqrt_two]
  ring

/-- The critical inverse temperature is the unique positive solution of
`sinh(2β) = 1`. The hypothesis `0 < β` is kept as part of the intended
statement, but it turns out to be unnecessary since `sinh` is injective on
all of `ℝ`. -/
theorem isingBetaC_unique {β : ℝ} (hβ : 0 < β) (h : sinh (2 * β) = 1) :
    β = isingBetaC := by
  have heq : sinh (2 * β) = sinh (2 * isingBetaC) := by
    rw [h, sinh_two_isingBetaC]
  have h2 : 2 * β = 2 * isingBetaC := Real.sinh_strictMono.injective heq
  linarith

/-- The critical inverse temperature is positive. -/
theorem isingBetaC_pos : 0 < isingBetaC := by
  have h1 : (1 : ℝ) < 1 + sqrt 2 := by
    have := Real.sqrt_pos.mpr (show (0 : ℝ) < 2 by norm_num)
    linarith
  have hl : 0 < log (1 + sqrt 2) := Real.log_pos h1
  unfold isingBetaC
  positivity

/-- The product of the critical temperature and critical inverse temperature
is `1`. -/
theorem isingTc_mul_isingBetaC : isingTc * isingBetaC = 1 := by
  have h1 : (1 : ℝ) < 1 + sqrt 2 := by
    have := Real.sqrt_pos.mpr (show (0 : ℝ) < 2 by norm_num)
    linarith
  have hl : log (1 + sqrt 2) ≠ 0 := ne_of_gt (Real.log_pos h1)
  unfold isingTc isingBetaC
  field_simp

/-- The Kramers–Wannier self-duality fixed point: for `β > 0`, the condition
`sinh(2β)² = 1` holds iff `β` is the critical inverse temperature. -/
theorem dual_fixed_point_iff {β : ℝ} (hβ : 0 < β) :
    sinh (2 * β) ^ 2 = 1 ↔ β = isingBetaC := by
  constructor
  · intro h
    have hpos : 0 < sinh (2 * β) :=
      Mathlib.Meta.Positivity.sinh_pos_of_pos (by linarith)
    have h1 : sinh (2 * β) = 1 := by nlinarith [h, hpos]
    exact isingBetaC_unique hβ h1
  · intro h
    subst h
    simp [sinh_two_isingBetaC]

end IsingCriticalTemperature