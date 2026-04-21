/-! # CatalogBuild.Shared.Lucas

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 2
-/

import Mathlib

/-- [Section: # CatalogBuild.Shared.Lucas
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 2] -/
def lucas : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | n + 2 => lucas (n + 1) + lucas n




/-- [Section: # CatalogBuild.Shared.Lucas
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 2] -/
theorem lucas_sub_binary (n : ℕ) (hn : 2 ≤ n) : lucas n < 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | n ) <;> simp +arith +decide [ * ] at *;
  grind +locals



