/-
# C-Branch GCD Analysis (V12)

## Key Result:
For the C-branch (a_n, b_n, c_n) = ((2n+1)(2n+3), 4(n+1), 4n²+8n+5),
gcd(a_n, b_n) = 1 for all n.

## Proof sketch:
- a_n = (2n+1)(2n+3) is always odd (product of two odd numbers)
- b_n = 4(n+1) is always even
- Since a_n is odd, gcd(a_n, b_n) must be odd
- Any odd prime p dividing gcd must divide both (2n+1)(2n+3) and (n+1)
- If p | (n+1), then 2(n+1) ≡ 0 (mod p), so 2n+1 ≡ -1 and 2n+3 ≡ 1 (mod p)
- So p | (-1)·1 = -1, contradiction since p > 1

This resolves Direction 44 from the V11 research paper.

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

/-! ## C-Branch Definition -/

/-- The C-branch odd leg -/
def C_odd (n : ℕ) : ℤ := (2 * ↑n + 1) * (2 * ↑n + 3)

/-- The C-branch even leg -/
def C_even (n : ℕ) : ℤ := 4 * (↑n + 1)

/-! ## Main Result -/

/-
The C-branch legs are always coprime
-/
theorem C_branch_coprime (n : ℕ) : Int.gcd (C_odd n) (C_even n) = 1 := by
  unfold C_odd C_even;
  norm_cast;
  norm_num [ ( by ring : 2 * n + 3 = 2 * n + 1 + 2 ), ( by ring : 4 * ( n + 1 ) = 2 * ( 2 * ( n + 1 ) ) ), Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  norm_num [ ( by ring : 2 * n + 1 + 2 = 2 * ( n + 1 ) + 1 ) ];
  norm_num [ ( by ring : 2 * n + 1 = n + ( n + 1 ) ) ]

/-! ## Verification for small values -/

theorem C_branch_coprime_vals :
    Int.gcd (C_odd 0) (C_even 0) = 1 ∧
    Int.gcd (C_odd 1) (C_even 1) = 1 ∧
    Int.gcd (C_odd 2) (C_even 2) = 1 ∧
    Int.gcd (C_odd 3) (C_even 3) = 1 ∧
    Int.gcd (C_odd 4) (C_even 4) = 1 ∧
    Int.gcd (C_odd 5) (C_even 5) = 1 := by native_decide