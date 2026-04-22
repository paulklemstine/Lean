import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenCBranchGCD

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 4
-/

/-- The C-branch odd leg -/
def C_odd (n : ℕ) : ℤ := (2 * ↑n + 1) * (2 * ↑n + 3)

/-- The C-branch even leg -/
def C_even (n : ℕ) : ℤ := 4 * (↑n + 1)

/-- [Section: ## Main Result] -/
theorem C_branch_coprime (n : ℕ) : Int.gcd (C_odd n) (C_even n) = 1 := by
  unfold C_odd C_even;
  norm_cast;
  norm_num [ ( by ring : 2 * n + 3 = 2 * n + 1 + 2 ), ( by ring : 4 * ( n + 1 ) = 2 * ( 2 * ( n + 1 ) ) ), Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  norm_num [ ( by ring : 2 * n + 1 + 2 = 2 * ( n + 1 ) + 1 ) ];
  norm_num [ ( by ring : 2 * n + 1 = n + ( n + 1 ) ) ]

/-- [Section: ## Verification for small values] -/
theorem C_branch_coprime_vals :
    Int.gcd (C_odd 0) (C_even 0) = 1 ∧
    Int.gcd (C_odd 1) (C_even 1) = 1 ∧
    Int.gcd (C_odd 2) (C_even 2) = 1 ∧
    Int.gcd (C_odd 3) (C_even 3) = 1 ∧
    Int.gcd (C_odd 4) (C_even 4) = 1 ∧
    Int.gcd (C_odd 5) (C_even 5) = 1 := by native_decide

