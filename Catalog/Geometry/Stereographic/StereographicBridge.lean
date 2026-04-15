/-! # CatalogBuild.Geometry.Stereographic.StereographicBridge

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 6
-/

import Mathlib

noncomputable section

/-- x-coordinate of inverse stereographic projection. -/
def stereoX (t : ℝ) : ℝ := 2 * t / (1 + t ^ 2)


/-- y-coordinate of inverse stereographic projection. -/
def stereoY (t : ℝ) : ℝ := (1 - t ^ 2) / (1 + t ^ 2)


theorem stereo_inv_on_circle (t : ℝ) :
    stereoX t ^ 2 + stereoY t ^ 2 = 1 := by
      unfold stereoX stereoY; rw [ div_pow, div_pow ] ; rw [ ← add_div, div_eq_iff ] <;> nlinarith [ one_plus_sq_ne_zero t ] ;


theorem stereo_y_upper_bound (t : ℝ) : stereoY t ≤ 1 := by
  exact div_le_one_of_le₀ ( by nlinarith ) ( by nlinarith )


theorem stereo_y_lower_bound (t : ℝ) : -1 ≤ stereoY t := by
  rw [ stereoY ] ; rw [ le_div_iff₀ ] <;> nlinarith [ sq_nonneg t ] ;


theorem stereo_frozen_crystal :
    {t : ℝ | stereoX t / (1 + stereoY t) = t} = Set.univ := by
      exact Set.eq_univ_of_forall fun t => stereo_round_trip t


end
