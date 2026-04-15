/-! # CatalogBuild.TestRescan.lean.TestRescan

Auto-generated from theorem catalog database.
Domain: TestRescan.lean
Declarations: 3
-/

import Mathlib.Data.Int.Basic

/-- The square of any integer is non-negative. -/
theorem square_nonneg (n : Int) : 0 ≤ n ^ 2 := by
  exact sq_nonneg n

/-- The sum of two squares is non-negative. -/

theorem sum_sq_nonneg (a b : Int) : 0 ≤ a ^ 2 + b ^ 2 := by
  exact add_nonneg (sq_nonneg a) (sq_nonneg b)

/-- Double of an even number is divisible by four. -/

theorem double_even_div_four (n : Int) (h : Even n) : Even (2 * n) := by
  obtain ⟨k, hk⟩ := h
  use k
  rw [hk]
  ring

