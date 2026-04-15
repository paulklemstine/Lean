/-! # CatalogBuild.Algebra.Diophantine.QuadraticDiophantine

Auto-generated from theorem catalog database.
Domain: Algebra/Diophantine
Declarations: 8
-/

import Mathlib

/-- [Section: ## Irrationality of √2 as a Diophantine Statement] -/
theorem no_integer_sqrt2 : ∀ x y : ℕ, 0 < x → 0 < y → x ^ 2 ≠ 2 * y ^ 2 := by
  -- Assume that $x^2 = 2y^2$ for some positive integers $x$ and $y$.
  intro x y hx hy h_eq
  have h_sqrt : (x : ℝ) = y * Real.sqrt 2 := by
    rw [ ← sq_eq_sq₀ ] <;> ring <;> norm_num ; norm_cast ; linarith;
  exact irrational_sqrt_two <| ⟨ x / y, by push_cast [ h_sqrt ] ; rw [ mul_div_cancel_left₀ _ <| by positivity ] ⟩


/-- A primitive Pythagorean triple has gcd(a, b) = 1. -/
def IsPrimitivePythagoreanTriple (a b c : ℕ) : Prop :=
  IsPythagoreanTriple a b c ∧ Nat.Coprime a b ∧ 0 < a ∧ 0 < b ∧ 0 < c


/-- [Section: ## Pythagorean Triples] -/
theorem parametric_is_pythagorean (m n : ℕ) (hmn : n < m) :
    IsPythagoreanTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  exact Eq.symm ( by nlinarith [ Nat.sub_add_cancel ( Nat.pow_le_pow_left hmn.le 2 ) ] )


/-- [Section: ## Sum of Two Squares] -/
theorem not_sum_two_squares_of_three_mod_four (n : ℕ) (hn : n % 4 = 3) :
    ¬∃ a b : ℕ, a ^ 2 + b ^ 2 = n := by
  exact fun ⟨ a, b, h ⟩ => by have := congr_arg ( · % 4 ) h; norm_num [ Nat.add_mod, Nat.pow_mod, hn ] at this; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> contradiction;


/-- [Section: ## FLT for n = 4 (Diophantine formulation)] -/
theorem flt4_diophantine : ∀ x y z : ℕ, 0 < x → 0 < y → 0 < z →
    x ^ 4 + y ^ 4 ≠ z ^ 4 := by
  exact fun h' => by have := fermatLastTheoremFour; aesop;


/-- x² - 2y² = 1 has infinitely many solutions. Here we prove that (3,2) is a solution. -/
theorem pell_sqrt2_base_solution : (3 : ℤ) ^ 2 - 2 * (2 : ℤ) ^ 2 = 1 := by ring


/-- [Section: ## Pell's Equation] -/
theorem pell_sqrt2_recurrence (x y : ℤ) (h : x ^ 2 - 2 * y ^ 2 = 1) :
    (3 * x + 4 * y) ^ 2 - 2 * (2 * x + 3 * y) ^ 2 = 1 := by
  grobner


theorem pell_composition (D x y a b : ℤ) (h1 : x ^ 2 - D * y ^ 2 = 1)
    (h2 : a ^ 2 - D * b ^ 2 = 1) :
    (x * a + D * y * b) ^ 2 - D * (x * b + y * a) ^ 2 = 1 := by
  linear_combination' h1 * h2
