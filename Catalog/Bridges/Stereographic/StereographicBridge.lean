import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.StereographicBridge

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 6
-/


noncomputable section

/-- x-coordinate of inverse stereographic projection. -/
def stereoX (t : ℝ) : ℝ := 2 * t / (1 + t ^ 2)




/-- y-coordinate of inverse stereographic projection. -/
def stereoY (t : ℝ) : ℝ := (1 - t ^ 2) / (1 + t ^ 2)




/-- `1 + t²` never vanishes. -/
theorem one_plus_sq_ne_zero (t : ℝ) : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity

/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicBridge
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 6] -/
theorem stereo_inv_on_circle (t : ℝ) :
    stereoX t ^ 2 + stereoY t ^ 2 = 1 := by
      unfold stereoX stereoY; rw [ div_pow, div_pow ] ; rw [ ← add_div, div_eq_iff ] <;> nlinarith [ one_plus_sq_ne_zero t ] ;




/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicBridge
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 6] -/
theorem stereo_y_upper_bound (t : ℝ) : stereoY t ≤ 1 := by
  exact div_le_one_of_le₀ ( by nlinarith ) ( by nlinarith )




theorem stereo_y_lower_bound (t : ℝ) : -1 ≤ stereoY t := by
  rw [ stereoY ] ; rw [ le_div_iff₀ ] <;> nlinarith [ sq_nonneg t ] ;




/-- Stereographic projection inverts the parametrisation: projecting `(x, y)` back from
the north pole returns the parameter `t`. -/
theorem stereo_round_trip (t : ℝ) : stereoX t / (1 + stereoY t) = t := by
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := one_plus_sq_ne_zero t
  unfold stereoX stereoY
  field_simp
  ring

theorem stereo_frozen_crystal :
    {t : ℝ | stereoX t / (1 + stereoY t) = t} = Set.univ := by
      exact Set.eq_univ_of_forall fun t => stereo_round_trip t




end