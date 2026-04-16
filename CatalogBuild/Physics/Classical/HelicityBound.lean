/-! # CatalogBuild.Physics.Classical.HelicityBound

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 4
-/

import Mathlib

/-- [Section: # CatalogBuild.Physics.Classical.HelicityBound
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 4] -/
theorem two_abs_mul_le_sq_add_sq (a b : ℤ) :
    2 * |a * b| ≤ a^2 + b^2 := by
  cases abs_cases ( a * b ) <;> linarith [ sq_nonneg ( a - b ), sq_nonneg ( a + b ) ]



theorem helicity_bound (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    2 * |a * b| ≤ c^2 := by
  cases abs_cases ( a * b ) <;> nlinarith [ sq_nonneg ( a - b ), sq_nonneg ( a + b ) ]



theorem helicity_bound_tight (a : ℤ) (ha : a ≠ 0) :
    2 * |a * a| = a^2 + a^2 := by
  cases abs_cases ( a * a ) <;> nlinarith [ sq_nonneg a ]



theorem helicity_bound_nat (a b c : ℕ) (h : a^2 + b^2 = c^2) :
    2 * a * b ≤ c^2 := by
  nlinarith [ sq_nonneg ( a - b : ℤ ) ]

