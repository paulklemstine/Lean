import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.StereographicProjection

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 5
-/


/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicProjection
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 5] -/
theorem stereo_proj_2d_unit_norm (a b : ℝ) (hc : a ^ 2 + b ^ 2 ≠ 0) :
    (2 * a * b / (a ^ 2 + b ^ 2)) ^ 2 +
    ((b ^ 2 - a ^ 2) / (a ^ 2 + b ^ 2)) ^ 2 = 1 := by
  grind



theorem stereo_identity (S b_sq : ℝ) :
    4 * S * b_sq + (b_sq - S) ^ 2 = (b_sq + S) ^ 2 := by
  ring



theorem inverse_stereo_first_component (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 + y ≠ 0) :
    2 * (x / (1 + y)) * 1 / ((x / (1 + y)) ^ 2 + 1 ^ 2) = x := by
  grind



theorem inverse_stereo_second_component (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 + y ≠ 0) :
    (1 ^ 2 - (x / (1 + y)) ^ 2) / ((x / (1 + y)) ^ 2 + 1 ^ 2) = y := by
  grind +ring



theorem stereo_proj_unit_norm_general (S m_n_sq c : ℝ)
    (hc_pos : c ≠ 0) (hc_def : c = S + m_n_sq) :
    (4 * S * m_n_sq + (m_n_sq - S) ^ 2) / c ^ 2 = 1 := by
  grind +ring

