/-! # CatalogBuild.Geometry.Stereographic.StereographicDecoder

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 4
-/

import Mathlib

noncomputable section

theorem one_square_identity (a b : ℤ) :
    a^2 * b^2 = (a * b)^2 := by
  ring

/-! ## The 2-Square Identity (Dimension 2: Complex numbers / Gaussian integers) -/

/-
PROBLEM
Brahmagupta-Fibonacci: the 2-square identity

PROVIDED SOLUTION
ring
-/

noncomputable def stereo_proj (x y : ℝ) (hx : x ≠ 1) : ℝ :=
  y / (1 - x)

/-- The inverse stereographic projection maps t ∈ ℝ to a point on S¹.
    t ↦ ((t²-1)/(t²+1), 2t/(t²+1)) -/

noncomputable def inv_stereo_proj (t : ℝ) : ℝ × ℝ :=
  ((t^2 - 1) / (t^2 + 1), 2 * t / (t^2 + 1))

/-
PROBLEM
The inverse stereographic projection lands on the unit circle

PROVIDED SOLUTION
Unfold inv_stereo_proj and compute: ((t²-1)/(t²+1))² + (2t/(t²+1))² = ((t²-1)² + 4t²)/(t²+1)² = (t⁴-2t²+1+4t²)/(t²+1)² = (t⁴+2t²+1)/(t²+1)² = (t²+1)²/(t²+1)² = 1. Need to show t²+1 ≠ 0 for reals, which follows from t² ≥ 0.
-/

theorem rational_stereo_gives_pyth (p q : ℤ) (hq : q ≠ 0) (hp : (p : ℚ) / q ≠ 0) :
    (p^2 - q^2)^2 + (2*p*q)^2 = (p^2 + q^2)^2 := by
  ring

end
