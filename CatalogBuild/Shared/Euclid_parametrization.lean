/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1
-/

import Mathlib

/-- [Section: ## Euclid Parametrization] -/
theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring

