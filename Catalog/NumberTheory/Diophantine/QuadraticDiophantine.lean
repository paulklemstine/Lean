import Mathlib

/-!
# Quadratic Diophantine Equations

We formalize results about quadratic Diophantine equations, focusing on
sum-of-two-squares representations and Pythagorean triples.

## Main Results

- `sum_two_squares_prime`: Fermat's theorem on primes as sums of two squares
- `pythagorean_triple_parametrization`: All primitive Pythagorean triples have the form
  (m² - n², 2mn, m² + n²)
- `no_integer_sqrt2`: √2 is irrational (x² = 2y² has no positive solutions)
- `flt4_diophantine`: x⁴ + y⁴ = z² has no positive integer solutions
-/

/-! ## Irrationality of √2 as a Diophantine Statement -/

/-
PROBLEM
The equation x² = 2y² has no solutions in positive integers.
    This is equivalent to the irrationality of √2.

PROVIDED SOLUTION
Use Nat.Coprime.sq_dvd_of_dvd_sq or use the standard infinite descent argument. Alternatively, use Nat.Prime.eq_one_of_pos_of_self_mul_self: if p prime divides x², then p divides x, so p² divides x². By infinite descent on (x,y) with x²=2y², we get a contradiction since 2 divides x, write x=2x', then 4x'²=2y², so y²=2x'², smaller solution. Actually, the cleanest approach: cast to ℤ, use Irrational (Real.sqrt 2) from Mathlib and relate to the equation.
-/
theorem no_integer_sqrt2 : ∀ x y : ℕ, 0 < x → 0 < y → x ^ 2 ≠ 2 * y ^ 2 := by
  -- Assume that $x^2 = 2y^2$ for some positive integers $x$ and $y$.
  intro x y hx hy h_eq
  have h_sqrt : (x : ℝ) = y * Real.sqrt 2 := by
    rw [ ← sq_eq_sq₀ ] <;> ring <;> norm_num ; norm_cast ; linarith;
  exact irrational_sqrt_two <| ⟨ x / y, by push_cast [ h_sqrt ] ; rw [ mul_div_cancel_left₀ _ <| by positivity ] ⟩

/-! ## Pythagorean Triples -/

/-- A Pythagorean triple is a triple (a, b, c) of natural numbers satisfying a² + b² = c². -/
def IsPythagoreanTriple (a b c : ℕ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- A primitive Pythagorean triple has gcd(a, b) = 1. -/
def IsPrimitivePythagoreanTriple (a b c : ℕ) : Prop :=
  IsPythagoreanTriple a b c ∧ Nat.Coprime a b ∧ 0 < a ∧ 0 < b ∧ 0 < c

/-
PROBLEM
Every parametric triple (m² - n², 2mn, m² + n²) with m > n > 0 is a Pythagorean triple.

PROVIDED SOLUTION
(m²-n²)² + (2mn)² = m⁴ - 2m²n² + n⁴ + 4m²n² = m⁴ + 2m²n² + n⁴ = (m²+n²)². Unfold IsPythagoreanTriple and use nlinarith or ring after handling the Nat subtraction (since m > n, m² > n², so m² - n² is fine). Use Nat.sub_sq or just nlinarith with hmn and the fact that n² ≤ m² (from Nat.pow_le_pow_left (le_of_lt hmn)).
-/
theorem parametric_is_pythagorean (m n : ℕ) (hmn : n < m) :
    IsPythagoreanTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  exact Eq.symm ( by nlinarith [ Nat.sub_add_cancel ( Nat.pow_le_pow_left hmn.le 2 ) ] )

/-! ## Sum of Two Squares -/

/-
PROBLEM
No number congruent to 3 mod 4 is a sum of two squares.

PROVIDED SOLUTION
Any square mod 4 is 0 or 1. So a² + b² mod 4 is 0, 1, or 2. It can never be 3. Given n % 4 = 3, if a² + b² = n, then (a² + b²) % 4 = 3, contradiction. Use omega or decide on the mod 4 cases.
-/
theorem not_sum_two_squares_of_three_mod_four (n : ℕ) (hn : n % 4 = 3) :
    ¬∃ a b : ℕ, a ^ 2 + b ^ 2 = n := by
  exact fun ⟨ a, b, h ⟩ => by have := congr_arg ( · % 4 ) h; norm_num [ Nat.add_mod, Nat.pow_mod, hn ] at this; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> contradiction;

/-! ## FLT for n = 4 (Diophantine formulation) -/

/-
PROBLEM
Fermat's Last Theorem for n = 4: x⁴ + y⁴ = z⁴ has no positive natural number solutions.

PROVIDED SOLUTION
Cast to ℤ and use Int.not_fermat_42 or Mathlib's not_fermat_42. x⁴+y⁴=z⁴ implies x⁴+y⁴=(z²)². Apply not_fermat_42 with appropriate casts.
-/
theorem flt4_diophantine : ∀ x y z : ℕ, 0 < x → 0 < y → 0 < z →
    x ^ 4 + y ^ 4 ≠ z ^ 4 := by
  exact fun h' => by have := fermatLastTheoremFour; aesop;

/-! ## Pell's Equation -/

/-- x² - 2y² = 1 has infinitely many solutions. Here we prove that (3,2) is a solution. -/
theorem pell_sqrt2_base_solution : (3 : ℤ) ^ 2 - 2 * (2 : ℤ) ^ 2 = 1 := by ring

/-
PROBLEM
If (x,y) is a solution to x² - 2y² = 1, then so is (3x + 4y, 2x + 3y).

PROVIDED SOLUTION
Expand (3x+4y)² - 2(2x+3y)² = 9x²+24xy+16y² - 2(4x²+12xy+9y²) = 9x²+24xy+16y² - 8x²-24xy-18y² = x² - 2y² = 1. Use nlinarith or linear_combination.
-/
theorem pell_sqrt2_recurrence (x y : ℤ) (h : x ^ 2 - 2 * y ^ 2 = 1) :
    (3 * x + 4 * y) ^ 2 - 2 * (2 * x + 3 * y) ^ 2 = 1 := by
  grobner

/-
PROBLEM
If (x,y) is a solution to x² - Dy² = 1, and (a,b) is also a solution,
    then (xa + Dyb, xb + ya) is a solution.

PROVIDED SOLUTION
Expand (xa+Dyb)² - D(xb+ya)² = x²a² + 2Dxyab + D²y²b² - Dx²b² - 2Dxyab - Dy²a² = x²(a²-Db²) + Dy²(Db²-a²) ... Actually use the Brahmagupta–Fibonacci identity: (x²-Dy²)(a²-Db²) = (xa+Dyb)² - D(xb+ya)². So the result is 1*1 = 1. Use nlinarith or linear_combination h1 * h2 (after appropriate expansion).
-/
theorem pell_composition (D x y a b : ℤ) (h1 : x ^ 2 - D * y ^ 2 = 1)
    (h2 : a ^ 2 - D * b ^ 2 = 1) :
    (x * a + D * y * b) ^ 2 - D * (x * b + y * a) ^ 2 = 1 := by
  linear_combination' h1 * h2