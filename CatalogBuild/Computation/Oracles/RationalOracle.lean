/-! # CatalogBuild.Computation.Oracles.RationalOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 5
-/

import Mathlib

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


/-- [Section: # The Rational Oracle: Pythagorean Triples and Sums of Squares
When the stereographic parameter t = p/q is rational, the inverse stereographic
projection yields rational points on the circle. Clearing denominators produces
Pythagorean triples.
## Main Results
- `pythagorean_triple_identity`: (2pq)² + (q²-p²)² = (p²+q²)²
- `brahmagupta_fibonacci`: (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²
- `brahmagupta_fibonacci_alt`: (a²+b²)(c²+d²) = (ac+bd)² + (ad-bc)²
- Specific triple verifications: (3,4,5), (5,12,13), (8,15,17), (7,24,25)] -/
theorem three_not_sum_of_squares : ¬ IsSumOfTwoSquares 3 := by
  rintro ⟨ a, b, h ⟩ ; have := Nat.le_of_lt_succ ( show a < 2 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 2 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial

