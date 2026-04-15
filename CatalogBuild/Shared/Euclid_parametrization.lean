/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 1
-/

import Mathlib

/-- **Theorem 3.5**: Euclid's parametrization always produces Pythagorean triples -/
theorem euclid_parametrization (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring

