/-! # CatalogBuild.Pythagorean.Core.SumOfSquaresFilter

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3
-/

import Mathlib

/-- 2 is a sum of two squares: 2 = 1² + 1². -/
theorem two_is_sum_two_squares : IsSumTwoSquares 2 := by
  exact ⟨1, 1, by norm_num⟩




/-- [Section: # CatalogBuild.Pythagorean.Core.SumOfSquaresFilter
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3] -/
theorem prime_3mod4_not_sum_two_squares (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    ¬ IsSumTwoSquares (p : ℤ) := by
  rintro ⟨ a, b, h ⟩ ; replace h := congrArg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ c, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ d, rfl | rfl ⟩ <;> ring_nf at * <;> norm_cast at * <;> simp_all +decide ;




/-- Any perfect square is a sum of two squares. -/
theorem square_is_sum_two_squares (n : ℤ) : IsSumTwoSquares (n ^ 2) := by
  exact ⟨n, 0, by ring⟩


