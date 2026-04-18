import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.StereographicDecoder

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 4
-/


noncomputable section

/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicDecoder
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 4] -/
theorem one_square_identity (a b : ℤ) :
    a^2 * b^2 = (a * b)^2 := by
  ring



/-- The stereographic projection maps a point on the unit sphere to the plane.
For the circle S¹ ⊂ ℝ², this maps (x,y) with x²+y²=1 to t = y/(1-x). -/
noncomputable def stereo_proj (x y : ℝ) (hx : x ≠ 1) : ℝ :=
  y / (1 - x)



/-- The inverse stereographic projection maps t ∈ ℝ to a point on S¹.
t ↦ ((t²-1)/(t²+1), 2t/(t²+1)) -/
noncomputable def inv_stereo_proj (t : ℝ) : ℝ × ℝ :=
  ((t^2 - 1) / (t^2 + 1), 2 * t / (t^2 + 1))



theorem rational_stereo_gives_pyth (p q : ℤ) (hq : q ≠ 0) (hp : (p : ℚ) / q ≠ 0) :
    (p^2 - q^2)^2 + (2*p*q)^2 = (p^2 + q^2)^2 := by
  ring


end
