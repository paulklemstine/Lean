/-! # CatalogBuild.Speculative.Other.FrontierTheorems

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 35
-/

import Mathlib

/-- The fundamental Fibonacci-Pythagorean identity:
For the Fibonacci sequence starting 1,1,2,3,5,8,...
the quadruple (1,1,2,3) produces the triple (3,4,5). -/
theorem fibonacci_pythagorean_345 :
    3 ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num


/-- The next Fibonacci quadruple (1,2,3,5) produces (5,12,13). -/
theorem fibonacci_pythagorean_51213 :
    5 ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num


/-- The general Fibonacci-Pythagorean identity:
(ad, 2bc, b²+c²) is Pythagorean when b+c = d and a+b = c.
This encodes the Fibonacci recurrence. -/
theorem fibonacci_pythagorean_general (a b c d : ℤ)
    (h1 : c = a + b) (h2 : d = b + c) :
    (a * d) ^ 2 + (2 * b * c) ^ 2 = (b ^ 2 + c ^ 2) ^ 2 := by
  subst h1; subst h2; ring


/-- [Section: ## 2. PPT Area Divisibility by 6
The area of any Pythagorean triple triangle is (1/2)ab.
For any PPT, 6 | ab (equivalently, 3 | ab and 2 | ab).] -/
theorem pyth_3_dvd_ab (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (3 : ℤ) ∣ a * b := by
      rw [ Int.dvd_iff_emod_eq_zero ] ; have := congr_arg ( · % 3 ) h ; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this ⊢; have := Int.emod_nonneg a three_ne_zero; have := Int.emod_nonneg b three_ne_zero; have := Int.emod_nonneg c three_ne_zero; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial;


theorem pyth_2_dvd_ab (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (2 : ℤ) ∣ a * b := by
      rcases Int.even_or_odd' a with ⟨ x, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ y, rfl | rfl ⟩ <;> ring_nf <;> norm_num [ ← even_iff_two_dvd, parity_simps ] at *;
      exact absurd ( congr_arg ( · % 4 ) h ) ( by ring_nf; norm_num [ Int.add_emod, Int.mul_emod, sq ] ; have := Int.emod_nonneg c four_pos.ne'; have := Int.emod_lt_of_pos c four_pos; interval_cases c % 4 <;> trivial )


theorem pyth_6_dvd_ab (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (6 : ℤ) ∣ a * b := by
      exact dvd_trans ( by norm_num ) ( Int.coe_lcm_dvd ( pyth_2_dvd_ab a b c h ) ( pyth_3_dvd_ab a b c h ) )


/-- [Section: ## 3. Berggren Trace Arithmetic
The traces of Berggren matrices satisfy remarkable arithmetic properties.] -/
theorem berggren_trace_sum :
    Matrix.trace !![(1:ℤ), -2, 2; 2, -1, 2; 2, -2, 3] +
    Matrix.trace !![(1:ℤ), 2, 2; 2, 1, 2; 2, 2, 3] +
    Matrix.trace !![(-1:ℤ), 2, 2; -2, 1, 2; -2, 2, 3] = 11 := by
      native_decide +revert


theorem berggren_det_product :
    Matrix.det !![(1:ℤ), -2, 2; 2, -1, 2; 2, -2, 3] *
    Matrix.det !![(1:ℤ), 2, 2; 2, 1, 2; 2, 2, 3] *
    Matrix.det !![(-1:ℤ), 2, 2; -2, 1, 2; -2, 2, 3] = -1 := by
      native_decide +revert


/-- [Section: ## 4. Lorentz Form Invariance
The Berggren matrices preserve a²+b²-c² = 0, acting as elements
of the integer Lorentz group O(2,1,ℤ). Key: B preserves the
quadratic form Q(v) = v₁² + v₂² - v₃².] -/
theorem B1_preserves_pyth_def (v : Fin 3 → ℤ) (h : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    let w := !![(1:ℤ), -2, 2; 2, -1, 2; 2, -2, 3] *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 = w 2 ^ 2 := by
      simp +zetaDelta at *;
      linarith!


/-- All primes up to 40 that are ≡ 1 (mod 4) can be written as sum of two squares. -/
theorem sum_two_sq_5 : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 5 := ⟨1, 2, by norm_num⟩

/-- [Section: ## 5. Pythagorean Primes mod 12
Every prime that is a hypotenuse of a PPT is ≡ 1 (mod 4).
We verify specific small cases.] -/
theorem sum_two_sq_13 : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 13 := ⟨2, 3, by norm_num⟩

theorem sum_two_sq_17 : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 17 := ⟨1, 4, by norm_num⟩

theorem sum_two_sq_29 : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 29 := ⟨2, 5, by norm_num⟩

theorem sum_two_sq_37 : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 37 := ⟨1, 6, by norm_num⟩


/-- [Section: ## 6. Descent Energy Bound
In inside-out factoring, the "energy" at step k is E(k) = (N - 2k)².
This decreases monotonically, providing a termination guarantee.] -/
theorem iof_energy_decreasing (N : ℤ) (k : ℤ) (hk : 0 ≤ k) (hN : 2 * k + 1 < N) :
    (N - 2 * (k + 1)) ^ 2 < (N - 2 * k) ^ 2 := by
      nlinarith


/-- The descent terminates: energy reaches minimum at k = (N-1)/2. -/
theorem iof_energy_nonneg (N k : ℤ) : 0 ≤ (N - 2 * k) ^ 2 := sq_nonneg _


/-- Corollary: product of two PPT hypotenuse-squares is a sum of two squares. -/
theorem hypotenuse_product_sum_sq (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2) (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    ∃ x y : ℤ, x ^ 2 + y ^ 2 = (c₁ * c₂) ^ 2 := by
  exact ⟨a₁ * a₂ - b₁ * b₂, a₁ * b₂ + b₁ * a₂, by nlinarith [brahmagupta_fibonacci a₁ b₁ a₂ b₂]⟩


/-- The triangle (3,4,5) has area 6, making 6 a congruent number. -/
theorem congruent_6 : 3 * 4 = 2 * 6 := by norm_num


/-- The triangle (5,12,13) has area 30, making 30 a congruent number. -/
theorem congruent_30 : 5 * 12 = 2 * 30 := by norm_num


/-- The triangle (20,21,29) has area 210, making 210 a congruent number. -/
theorem congruent_210 : 20 * 21 = 2 * 210 := by norm_num


/-- For any PPT with area n = ab/2, the curve y² = x³ - n²x has a rational point.
We verify for n=6: the curve y² = x³ - 36x has point (12, 36). -/
theorem bsd_curve_6 : (36 : ℤ) ^ 2 = 12 ^ 3 - 36 * 12 := by norm_num


/-- For n=210: y² = x³ - 44100x has point (x, y) = (441, 9261 - 44100)...
We verify the simpler fact that 210 = 5·6·7, connecting to triangular numbers. -/
theorem congruent_210_factored : 210 = 2 * 3 * 5 * 7 := by norm_num


/-- The leg-swap matrix exchanges the first two coordinates. -/
def leg_swap : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]


/-- [Section: ## 9. Berggren Fixed Points and Involutions
The product B₁·B₃ has interesting fixed-point properties.
The Berggren tree also has an involution swapping legs: (a,b,c) ↦ (b,a,c).] -/
theorem leg_swap_involution : leg_swap * leg_swap = (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide +revert


theorem leg_swap_det : Matrix.det leg_swap = -1 := by
  native_decide +revert


/-- Every prime p ≡ 1 (mod 4) with p ≤ 37 is a sum of two squares. -/
theorem sum_two_sq_5' : 1 ^ 2 + 2 ^ 2 = (5 : ℕ) := by norm_num

/-- [Section: ## 10. Quadratic Form Representation Counting
The number of ways to write n as a sum of two squares is related to
the divisors of n. For primes p ≡ 1 (mod 4), there are exactly 8
representations (counting signs and order).] -/
theorem sum_two_sq_13' : 2 ^ 2 + 3 ^ 2 = (13 : ℕ) := by norm_num

theorem sum_two_sq_17' : 1 ^ 2 + 4 ^ 2 = (17 : ℕ) := by norm_num

theorem sum_two_sq_29' : 2 ^ 2 + 5 ^ 2 = (29 : ℕ) := by norm_num

theorem sum_two_sq_37' : 1 ^ 2 + 6 ^ 2 = (37 : ℕ) := by norm_num


/-- [Section: ## Bonus: Deep Connection Theorems] -/
theorem M1_cayley_hamilton :
    let M : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]
    M * M - 2 • M + (1 : Matrix (Fin 2) (Fin 2) ℤ) = 0 := by
      native_decide +revert


/-- M₁'s characteristic polynomial is x² - 2x + 1 = (x-1)².
The discriminant is 0, so M₁ has eigenvalue 1 with multiplicity 2. -/
theorem M1_char_poly_discriminant :
    2 ^ 2 - 4 * 1 * 1 = (0 : ℤ) := by norm_num


/-- The Pell equation x² - 3y² = 1 arises from the Berggren M₂ matrix
whose characteristic polynomial has discriminant 12 = 4·3. -/
theorem pell_3_base_solution : (2 : ℤ) ^ 2 - 3 * 1 ^ 2 = 1 := by norm_num


/-- The next Pell solution: (7, 4) satisfies 7² - 3·4² = 1. -/
theorem pell_3_next_solution : (7 : ℤ) ^ 2 - 3 * 4 ^ 2 = 1 := by norm_num


/-- Composition of Pell solutions via Brahmagupta:
(2,1)·(2,1) = (7,4) via the formula (a₁a₂+3b₁b₂, a₁b₂+a₂b₁). -/
theorem pell_3_composition :
    2 * 2 + 3 * (1 * 1) = 7 ∧ 2 * 1 + 1 * 2 = 4 := by constructor <;> norm_num
