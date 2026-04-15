/-! # CatalogBuild.EML.SPBIntegers

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16
-/

import Mathlib

/-- [Section: ## Basic Integer SPB Values] -/
theorem spb_neg_integer (a : ℤ) : (1 - a * (-a)) ∣ (a + (-a)) := by simp

theorem spb_zero_left_integer (b : ℤ) : (1 - 0 * b) ∣ (0 + b) := by simp

theorem spb_zero_right_integer (a : ℤ) : (1 - a * 0) ∣ (a + 0) := by simp


theorem spb_two_neg_three_not_int : ¬((1 - 2 * (-3) : ℤ) ∣ (2 + (-3))) := by
  intro ⟨k, hk⟩; omega


theorem spb_three_five_not_int : ¬((1 - 3 * 5 : ℤ) ∣ (3 + 5)) := by
  intro ⟨k, hk⟩; omega


/-- The integer values of spb(1, b) for small b: -/
theorem spb_one_neg_one : (1 + (-1) : ℤ) = 0 * (1 - 1 * (-1)) := by ring

theorem spb_one_zero_val : (1 + 0 : ℤ) = 1 * (1 - 1 * 0) := by ring

theorem spb_one_two_val : (1 + 2 : ℤ) = (-3) * (1 - 1 * 2) := by ring

theorem spb_one_three_val : (1 + 3 : ℤ) = (-2) * (1 - 1 * 3) := by ring


/-- (1 + ai)(1 + bi) = (1 - ab) + (a+b)i gives the norm identity. -/
theorem spb_gaussian_norm (a b : ℤ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring


/-- Machin's formula verification in integer arithmetic.
tan(4·arctan(1/5)) = 120/119, and spb(120/119, -1/239) = 1.
Key: 120·239 - 119 = 119·239 + 120. -/
theorem machin_spb_one : (120 * 239 - 119 : ℤ) = 119 * 239 + 120 := by ring


/-- [Section: ## Machin-Type Identities] -/
theorem machin_denominator_check : 12 * 12 - 5 * 5 = (119 : ℤ) := by ring

theorem machin_final_den : (119 : ℤ) ^ 2 - 120 ^ 2 = -239 := by ring


/-- Euler's formula: arctan(1/2) + arctan(1/3) = π/4.
In SPB: spb(1/2, 1/3) = (1/2 + 1/3)/(1 - 1/6) = (5/6)/(5/6) = 1.
Integer verification: -/
theorem euler_spb_integers : (1 * 3 + 2 * 1 : ℤ) = 1 * (2 * 3 - 1 * 1) := by ring


/-- Hutton's formula: arctan(1/2) + arctan(1/5) + arctan(1/8) = π/4.
Step 1: spb(1/2, 1/5) = (1·5+2·1)/(2·5-1·1) = 7/9.
Step 2: spb(7/9, 1/8) = (7·8+9·1)/(9·8-7·1) = 65/65 = 1.
Integer verification: -/
theorem hutton_step1 : (1 * 5 + 2 * 1 : ℤ) = 7 ∧ (2 * 5 - 1 * 1 : ℤ) = 9 := by omega

theorem hutton_step2 : (7 * 8 + 9 * 1 : ℤ) = 9 * 8 - 7 * 1 := by ring

