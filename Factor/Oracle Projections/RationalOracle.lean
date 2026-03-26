import Mathlib

/-!
# The Rational Oracle: Pythagorean Triples and Sums of Squares

When the stereographic parameter t = p/q is rational, the inverse stereographic
projection yields rational points on the circle. Clearing denominators produces
Pythagorean triples.

## Main Results

- `pythagorean_triple_identity`: (2pq)² + (q²-p²)² = (p²+q²)²
- `brahmagupta_fibonacci`: (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²
- `brahmagupta_fibonacci_alt`: (a²+b²)(c²+d²) = (ac+bd)² + (ad-bc)²
- Specific triple verifications: (3,4,5), (5,12,13), (8,15,17), (7,24,25)
-/

section PythagoreanTriples

/-- The fundamental Pythagorean triple identity from stereographic projection. -/
theorem pythagorean_triple_identity (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (p ^ 2 + q ^ 2) ^ 2 := by ring

/-- The (3,4,5) triple from (p,q) = (1,2). -/
theorem triple_3_4_5 : 3 ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

/-- The (5,12,13) triple from (p,q) = (2,3). -/
theorem triple_5_12_13 : 5 ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num

/-- The (8,15,17) triple from (p,q) = (1,4). -/
theorem triple_8_15_17 : 8 ^ 2 + 15 ^ 2 = 17 ^ 2 := by norm_num

/-- The (7,24,25) triple from (p,q) = (3,4). -/
theorem triple_7_24_25 : 7 ^ 2 + 24 ^ 2 = 25 ^ 2 := by norm_num

/-- Batch verification: all (p,q) with p,q in range generate valid triples. -/
theorem pythagorean_batch (p q : Fin 10) :
    (2 * (p : ℤ) * q) ^ 2 + ((q : ℤ) ^ 2 - (p : ℤ) ^ 2) ^ 2 =
    ((p : ℤ) ^ 2 + (q : ℤ) ^ 2) ^ 2 := by ring

end PythagoreanTriples

section BrahmaguptaFibonacci

/-- Brahmagupta–Fibonacci identity: the product of sums of two squares
    is itself a sum of two squares. First form. -/
theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

/-- Brahmagupta–Fibonacci identity, alternative form. -/
theorem brahmagupta_fibonacci_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

end BrahmaguptaFibonacci

section SumOfTwoSquares

/-- Predicate: n is a sum of two squares. -/
def IsSumOfTwoSquares (n : ℕ) : Prop := ∃ a b : ℕ, a ^ 2 + b ^ 2 = n

/-- 2 is a sum of two squares: 1² + 1² = 2. -/
theorem two_sum_of_squares : IsSumOfTwoSquares 2 := ⟨1, 1, by norm_num⟩

/-- 5 is a sum of two squares: 1² + 2² = 5. -/
theorem five_sum_of_squares : IsSumOfTwoSquares 5 := ⟨1, 2, by norm_num⟩

/-- 13 is a sum of two squares: 2² + 3² = 13. -/
theorem thirteen_sum_of_squares : IsSumOfTwoSquares 13 := ⟨2, 3, by norm_num⟩

/-
PROBLEM
3 is NOT a sum of two squares.

PROVIDED SOLUTION
Unfold IsSumOfTwoSquares. For a,b : ℕ with a² + b² = 3, we need a,b ≤ 1 (since 2² = 4 > 3). Check all cases: (0,0)→0, (0,1)→1, (1,0)→1, (1,1)→2. None give 3. Use rintro ⟨a, b, hab⟩ then omega or interval_cases after bounding a and b.
-/
theorem three_not_sum_of_squares : ¬ IsSumOfTwoSquares 3 := by
  rintro ⟨ a, b, h ⟩ ; have := Nat.le_of_lt_succ ( show a < 2 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 2 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial

end SumOfTwoSquares