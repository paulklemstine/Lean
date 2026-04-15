/-! # CatalogBuild.Shared.Euclid_parametrization

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 1
-/

import Mathlib

theorem euclid_parametrization (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring

/-! ## Section 8: Pell Recurrence (Theorem 4.1)

The B-branch hypotenuse sequence satisfies c_{n+2} = 6c_{n+1} - c_n. -/

/-- The hypotenuse along the pure B-branch path. -/
