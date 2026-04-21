/-! # CatalogBuild.Geometry.Stereographic.MobiusCovariance

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 3
-/

import Mathlib

/-- The S matrix of the modular group. -/
def modS : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]




/-- The T matrix of the modular group. -/
def modT : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]




/-- [Section: # CatalogBuild.Geometry.Stereographic.MobiusCovariance
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 3] -/
theorem sin_int_mul_pi (n : ℤ) : Real.sin (n * Real.pi) = 0 := by
  exact Real.sin_int_mul_pi n



