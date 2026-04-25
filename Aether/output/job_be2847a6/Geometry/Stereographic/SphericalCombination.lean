import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.SphericalCombination

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 5
-/


/-- The fundamental identity: cos²θ + sin²θ = 1, restated for our use. -/
theorem cos_sq_add_sin_sq_eq_one' (θ : ℝ) : cos θ ^ 2 + sin θ ^ 2 = 1 := by
  have := sin_sq_add_cos_sq θ; linarith




/-- [Section: # CatalogBuild.Geometry.Stereographic.SphericalCombination
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 5] -/
theorem spherical_combination_norm_sq (θ φ : ℝ) :
    (cos φ) ^ 2 * ((cos θ) ^ 2 + (sin θ) ^ 2) + (sin φ) ^ 2 = 1 := by
  norm_num [ Real.cos_sq_add_sin_sq ]




/-- [Section: # CatalogBuild.Geometry.Stereographic.SphericalCombination
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 5] -/
theorem spherical_combination_expanded (θ φ : ℝ) :
    (cos φ * cos θ) ^ 2 + (cos φ * sin θ) ^ 2 + (sin φ) ^ 2 = 1 := by
  convert spherical_combination_norm_sq θ φ using 1 ; ring




theorem gram_schmidt_orthogonality (a : ℝ) : a - a * 1 = 0 := by
  ring




theorem gram_schmidt_inner_product_zero (inner_uv inner_uu : ℝ) (hu : inner_uu = 1) :
    inner_uv - inner_uv * inner_uu = 0 := by
  rw [ hu, mul_one, sub_self ]


