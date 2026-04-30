import Mathlib

/-! # CatalogBuild.Computation.Oracles.RationalOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 5
-/


/-- The fundamental Pythagorean triple identity from stereographic projection. -/
theorem pythagorean_triple_identity (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (p ^ 2 + q ^ 2) ^ 2 := by ring




/-- Batch verification: all (p,q) with p,q in range generate valid triples. -/
theorem pythagorean_batch (p q : Fin 10) :
    (2 * (p : ℤ) * q) ^ 2 + ((q : ℤ) ^ 2 - (p : ℤ) ^ 2) ^ 2 =
    ((p : ℤ) ^ 2 + (q : ℤ) ^ 2) ^ 2 := by ring




/-- Predicate: n is a sum of two squares. -/
def IsSumOfTwoSquares (n : ℕ) : Prop := ∃ a b : ℕ, a ^ 2 + b ^ 2 = n




/-- 2 is a sum of two squares: 1² + 1² = 2. -/
theorem two_sum_of_squares : IsSumOfTwoSquares 2 := ⟨1, 1, by norm_num⟩




/-- [Section: # CatalogBuild.Computation.Oracles.RationalOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 5] -/
theorem three_not_sum_of_squares : ¬ IsSumOfTwoSquares 3 := by
  rintro ⟨ a, b, h ⟩ ; have := Nat.le_of_lt_succ ( show a < 2 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 2 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial



