/-! # CatalogBuild.Shared.Tribonacci

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 2
-/

import Mathlib

/-- [Section: # CatalogBuild.Shared.Tribonacci
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 2] -/
def tribonacci : ℕ → ℕ
  | 0 => 0
  | 1 => 0
  | 2 => 1
  | n + 3 => tribonacci (n + 2) + tribonacci (n + 1) + tribonacci n



theorem tribonacci_sub_binary (n : ℕ) : tribonacci n < 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ * ];
  exact lt_of_le_of_lt ( by rw [ show tribonacci ( n + 3 ) = tribonacci ( n + 2 ) + tribonacci ( n + 1 ) + tribonacci n from rfl ] ) ( by linarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), ih ( n + 2 ) ( by linarith ), pow_succ' 2 n, pow_succ' 2 ( n + 1 ), pow_succ' 2 ( n + 2 ) ] )


