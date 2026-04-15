/-! # CatalogBuild.Pythagorean.Core.SumOfSquaresFilter

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3
-/

import Mathlib

theorem two_is_sum_two_squares : IsSumTwoSquares 2 := by
  exact ⟨1, 1, by norm_num⟩

/-
PROBLEM
If p is prime and p ≡ 3 (mod 4), then p is NOT a sum of two squares.

PROVIDED SOLUTION
If p ≡ 3 (mod 4) and p = a² + b², then a² + b² ≡ 3 (mod 4). But squares mod 4 are 0 or 1, so a² + b² mod 4 ∈ {0, 1, 2}, never 3. Contradiction. Work with ZMod 4 or use Nat modular arithmetic. The key step: show that for any integer x, x^2 % 4 ∈ {0, 1}, hence (a^2 + b^2) % 4 ∈ {0, 1, 2} ≠ 3.
-/

theorem prime_3mod4_not_sum_two_squares (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    ¬ IsSumTwoSquares (p : ℤ) := by
  rintro ⟨ a, b, h ⟩ ; replace h := congrArg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ c, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ d, rfl | rfl ⟩ <;> ring_nf at * <;> norm_cast at * <;> simp_all +decide ;

/-
PROBLEM
The Brahmagupta–Fibonacci identity: the product of two sums of two squares
    is again a sum of two squares. This is the "composition law" for Channel 2,
    arising from the norm multiplicativity of Gaussian integers.

PROVIDED SOLUTION
Given m = a² + b² and n = c² + d², then m*n = (ac - bd)² + (ad + bc)² by the Brahmagupta-Fibonacci identity. This follows by ring. Obtain a, b from hm and c, d from hn, then exhibit the witnesses (a*c - b*d) and (a*d + b*c).
-/

theorem square_is_sum_two_squares (n : ℤ) : IsSumTwoSquares (n ^ 2) := by
  exact ⟨n, 0, by ring⟩
