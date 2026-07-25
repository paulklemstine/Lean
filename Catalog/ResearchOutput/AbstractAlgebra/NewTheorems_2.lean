import Mathlib

/-! # CatalogBuild.Speculative.Other.NewTheorems_2

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16
-/

/-- In a right triangle with integer sides, a + b > c. -/
theorem ppt_sum_of_sides (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : c < a + b := by
  nlinarith [sq_nonneg (a + b - c), sq_nonneg (a - b)]

/-- The hypotenuse strictly exceeds each leg. -/
theorem ppt_c_gt_a (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : a < c := by
  nlinarith [sq_nonneg b, sq_nonneg (c - a)]

/-- [Section: # CatalogBuild.Speculative.Other.NewTheorems_2
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16] -/
theorem ppt_c_gt_b (a b c : ℤ) (ha : 0 < a) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : b < c := by
  nlinarith [sq_nonneg a, sq_nonneg (c - b)]

/-- [Section: # CatalogBuild.Speculative.Other.NewTheorems_2
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16] -/
theorem pyth_product_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    Even (a * b) := by
      by_contra! h_even; have := congr_arg ( · % 4 ) h; rcases Int.even_or_odd' a with ⟨ b₁, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b₂, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ b₃, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;
      · grind;
      · exact absurd h_even ( by simp +decide [ parity_simps ] )

/-- (a+b)² = c² + 2ab for any Pythagorean triple. -/
theorem sum_of_legs_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + b) ^ 2 = c ^ 2 + 2 * a * b := by nlinarith

/-- (a-b)² = c² - 2ab for any Pythagorean triple. -/
theorem diff_of_legs_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - b) ^ 2 = c ^ 2 - 2 * a * b := by nlinarith

/-- The incircle identity: 2·ab = (a+b-c)(a+b+c) for any Pythagorean triple.
Since r = (a+b-c)/2 is the inradius, this encodes K = r·s. -/
theorem pythagorean_incircle (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 * (a * b) = (a + b - c) * (a + b + c) := by nlinarith

/-- There are infinitely many Pythagorean triples: for each n > 0,
(2n+1, 2n²+2n, 2n²+2n+1) is a Pythagorean triple. -/
theorem infinite_pythagorean_triples (n : ℕ) :
    (2 * n + 1) ^ 2 + (2 * n ^ 2 + 2 * n) ^ 2 = (2 * n ^ 2 + 2 * n + 1) ^ 2 := by
  ring

theorem pyth_mod8_structure (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : Odd a) (hb : Even b) : c ^ 2 % 8 = 1 := by
      replace h := congr_arg ( · % 8 ) h; obtain ⟨ m, rfl ⟩ := ha; obtain ⟨ n, rfl ⟩ := hb; ring_nf at *; norm_num [ Int.add_emod, Int.mul_emod ] at *;
      norm_num [ sq, Int.add_emod, Int.mul_emod ] at *; have := Int.emod_nonneg m ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg n ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos m ( by norm_num : ( 0 : ℤ ) < 8 ) ; have := Int.emod_lt_of_pos n ( by norm_num : ( 0 : ℤ ) < 8 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 0 : ℤ ) < 8 ) ; interval_cases m % 8 <;> interval_cases n % 8 <;> interval_cases c % 8 <;> trivial;

theorem pyth_mod3_divides (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (3 : ℤ) ∣ a * b := by
      by_contra h_contra;
      exact h_contra <| Int.dvd_of_emod_eq_zero <| by have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.mul_emod, Int.add_emod ] at this ⊢; have := Int.emod_nonneg a three_pos.ne'; have := Int.emod_nonneg b three_pos.ne'; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial;

theorem pyth_mod5_divides (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (5 : ℤ) ∣ a * b * c := by
      rw [ Int.dvd_iff_emod_eq_zero ] ; replace h := congr_arg ( · % 5 ) h ; norm_num [ sq, Int.add_emod, Int.mul_emod ] at h ⊢ ; have := Int.emod_nonneg a ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg b ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by decide : ( 5 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos b ( by decide : ( 5 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos c ( by decide : ( 5 : ℤ ) > 0 ) ; interval_cases a % 5 <;> interval_cases b % 5 <;> interval_cases c % 5 <;> trivial;

/-- From a²+(2k)²=c², we get c²-4k²=a². -/
theorem pell_from_pyth (a k c : ℤ) (h : a ^ 2 + (2 * k) ^ 2 = c ^ 2) :
    c ^ 2 - 4 * k ^ 2 = a ^ 2 := by linarith

/-- The Gaussian norm satisfies N(z) = 0 iff z = 0. -/
theorem gaussian_norm_eq_zero (a b : ℤ) : a ^ 2 + b ^ 2 = 0 ↔ a = 0 ∧ b = 0 := by
  constructor
  · intro h
    have ha : a ^ 2 = 0 := by nlinarith [sq_nonneg b]
    have hb : b ^ 2 = 0 := by nlinarith [sq_nonneg a]
    exact ⟨by nlinarith [sq_abs a], by nlinarith [sq_abs b]⟩
  · rintro ⟨rfl, rfl⟩; ring

theorem ppt_hypotenuse_lower_bound (a b c : ℕ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hcop : Nat.Coprime a b) :
    5 ≤ c := by
      exact le_of_not_gt fun hc : c < 5 => by interval_cases c <;> have := Nat.le_of_lt_succ ( show a < 6 by nlinarith only [ h ] ) <;> have := Nat.le_of_lt_succ ( show b < 6 by nlinarith only [ h ] ) <;> interval_cases a <;> interval_cases b <;> trivial;

/-- Vieta involution: a² + (c-b)² = 2c(c-b). -/
theorem vieta_pythagorean (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + (c - b) ^ 2 = 2 * c * (c - b) := by nlinarith

/-- The arithmetic progression property: in the family (2n+1, 2n²+2n, 2n²+2n+1),
the hypotenuse exceeds the even leg by exactly 1. -/
theorem consecutive_leg_hyp (n : ℕ) :
    2 * n ^ 2 + 2 * n + 1 = (2 * n ^ 2 + 2 * n) + 1 := by ring