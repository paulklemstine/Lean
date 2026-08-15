import Mathlib

/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

/-- [Section: # CatalogBuild.Shared.Euclid_parametrization
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1] -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring