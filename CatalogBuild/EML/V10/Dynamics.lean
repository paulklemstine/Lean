/-! # CatalogBuild.EML.V10.Dynamics

Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 13
-/

import Mathlib

noncomputable section

/-- d(z) > z for all z (no real fixed points). -/
theorem emlDiag_gt_z (z : ℝ) : emlDiag z > z := by
  unfold emlDiag
  by_cases hz : 0 < z
  · have h5 : Real.exp z ≥ 1 + z + z ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity) (Real.summable_pow_div_factorial z))
    nlinarith [Real.log_le_sub_one_of_pos hz, sq_nonneg z]
  · push_neg at hz
    by_cases hz0 : z = 0
    · subst hz0; simp
    · rw [show Real.log z = Real.log (-z) from by rw [← Real.log_neg_eq_log]]
      linarith [Real.exp_pos z,
        Real.log_le_sub_one_of_pos (neg_pos.mpr (lt_of_le_of_ne hz hz0))]



/-- d(z) ≥ z + 1 for all z. -/
theorem emlDiag_ge_z_add_one (z : ℝ) : emlDiag z ≥ z + 1 := by
  unfold emlDiag
  by_cases hz : 0 < z
  · have h5 : Real.exp z ≥ 1 + z + z ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity) (Real.summable_pow_div_factorial z))
    nlinarith [Real.log_le_sub_one_of_pos hz, sq_nonneg (z - 1)]
  · push_neg at hz
    by_cases hz0 : z = 0
    · subst hz0; simp
    · rw [show Real.log z = Real.log (-z) from by rw [← Real.log_neg_eq_log]]
      linarith [Real.exp_pos z,
        Real.log_le_sub_one_of_pos (neg_pos.mpr (lt_of_le_of_ne hz hz0))]



/-- d(z) ≥ 2 for z > 0. -/
theorem emlDiag_ge_two_pos (z : ℝ) (hz : 0 < z) : emlDiag z ≥ 2 := by
  unfold emlDiag
  linarith [Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz]



/-- Strong bound: d(z) ≥ exp(z) − z + 1 for z ≥ 1. -/
theorem emlDiag_strong_bound (z : ℝ) (hz : 1 ≤ z) :
    emlDiag z ≥ Real.exp z - z + 1 := by
  unfold emlDiag
  nlinarith [Real.log_le_sub_one_of_pos (by linarith : 0 < z)]



/-- For z ≥ 2: d(z) ≥ exp(z)/2. -/
theorem emlDiag_ge_half_exp (z : ℝ) (hz : 2 ≤ z) :
    emlDiag z ≥ Real.exp z / 2 := by
  unfold emlDiag
  have h5 : Real.exp z ≥ 1 + z + z ^ 2 / 2 := by
    rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
    exact le_trans (by norm_num [Finset.sum_range_succ])
      (Summable.sum_le_tsum (Finset.range 3)
        (fun i _ => by positivity) (Real.summable_pow_div_factorial z))
  have h2 := Real.log_le_sub_one_of_pos (show 0 < z by linarith)
  -- exp(z)/2 ≤ exp(z) - log(z) iff exp(z)/2 ≥ log(z)
  -- exp(z) ≥ 1 + z + z²/2 ≥ 2z (for z ≥ 2, since 1 - z + z²/2 = ((z-1)²+1)/2 > 0)
  -- So exp(z)/2 ≥ z ≥ z-1 ≥ log(z)
  nlinarith [sq_nonneg (z - 1)]



/-- Orbit linear divergence: dⁿ(z) ≥ z + n. -/
theorem emlDiag_orbit_linear (z : ℝ) (n : ℕ) :
    emlDiagIter n z ≥ z + n := by
  induction n with
  | zero => simp [emlDiagIter]
  | succ n ih =>
    simp only [emlDiagIter]; push_cast
    linarith [emlDiag_ge_z_add_one (emlDiagIter n z)]



/-- After one step from z > 0, all orbit points are ≥ 2. -/
theorem emlDiag_orbit_ge_two (z : ℝ) (hz : 0 < z) (n : ℕ) (hn : 1 ≤ n) :
    emlDiagIter n z ≥ 2 := by
  have h1 : emlDiagIter 1 z ≥ 2 := emlDiag_ge_two_pos z hz
  have hge : emlDiagIter n z ≥ emlDiagIter 1 z := by
    have := (emlDiag_orbit_strictMono z).monotone
    exact this (by omega)
  linarith



/-- g(1) = e. -/
theorem emlGmap_one : emlGmap 1 = Real.exp 1 := by simp [emlGmap, Real.log_one]



/-- g(e) = e − 1. -/
theorem emlGmap_e : emlGmap (Real.exp 1) = Real.exp 1 - 1 := by
  simp [emlGmap, Real.log_exp]



/-- The derivative of g at z > 0 is −1/z. -/
theorem emlGmap_hasDerivAt (z : ℝ) (hz : 0 < z) :
    HasDerivAt emlGmap (-z⁻¹) z := by
  unfold emlGmap
  exact ((hasDerivAt_const z (Real.exp 1)).sub (Real.hasDerivAt_log hz.ne')).congr_deriv (by ring)



/-- g is strictly decreasing on (0,∞). -/
theorem emlGmap_strictAnti : StrictAntiOn emlGmap (Set.Ioi 0) := by
  intro a ha b _ hab
  unfold emlGmap
  linarith [Real.log_lt_log ha hab]



/-- Gap derivative at z > 0. -/
theorem emlGap_deriv (z : ℝ) (hz : 0 < z) :
    HasDerivAt (fun z => Real.exp z - Real.log z - z) (Real.exp z - z⁻¹ - 1) z := by
  exact ((Real.hasDerivAt_exp z).sub (Real.hasDerivAt_log hz.ne')).sub (hasDerivAt_id z)
    |>.congr_deriv (by ring)



/-- For z ≥ 2: d(z) ≥ eᶻ − z. -/
theorem emlDiag_lower_exp (z : ℝ) (hz : 2 ≤ z) :
    emlDiag z ≥ Real.exp z - z := by
  unfold emlDiag
  linarith [Real.log_le_sub_one_of_pos (by linarith : 0 < z)]



end
