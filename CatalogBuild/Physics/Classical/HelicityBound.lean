/-! # CatalogBuild.Physics.Classical.HelicityBound

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 4
-/

import Mathlib

theorem two_abs_mul_le_sq_add_sq (a b : ℤ) :
    2 * |a * b| ≤ a^2 + b^2 := by
  cases abs_cases ( a * b ) <;> linarith [ sq_nonneg ( a - b ), sq_nonneg ( a + b ) ]

/-
PROBLEM
Helicity bound: for a Pythagorean triple, 2|ab| ≤ c²

PROVIDED SOLUTION
Rewrite h to get a² + b² = c², then apply two_abs_mul_le_sq_add_sq and use h.
-/

theorem helicity_bound (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    2 * |a * b| ≤ c^2 := by
  cases abs_cases ( a * b ) <;> nlinarith [ sq_nonneg ( a - b ), sq_nonneg ( a + b ) ]

/-
PROBLEM
The helicity bound is tight: equality when a = b

PROVIDED SOLUTION
2 * |a * a| = 2 * a² = a² + a². Use abs_mul_self or sq_abs.
-/

theorem helicity_bound_tight (a : ℤ) (ha : a ≠ 0) :
    2 * |a * a| = a^2 + a^2 := by
  cases abs_cases ( a * a ) <;> nlinarith [ sq_nonneg a ]

/-
PROBLEM
For natural number Pythagorean triples: 2*a*b ≤ c²

PROVIDED SOLUTION
For natural numbers, 0 ≤ (a-b)² gives 2ab ≤ a²+b² = c². Use Nat.sub_sq or tsub, or cast to ℤ and use two_abs_mul_le_sq_add_sq.
-/

theorem helicity_bound_nat (a b c : ℕ) (h : a^2 + b^2 = c^2) :
    2 * a * b ≤ c^2 := by
  nlinarith [ sq_nonneg ( a - b : ℤ ) ]
