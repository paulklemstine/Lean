/-! # CatalogBuild.Algebra.Foundations.QuadraticForms

Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 11
-/

import Mathlib

/-- The discriminant of the quadratic form ax² + bxy + cy² is b² - 4ac. -/
def form_discriminant (a b c : ℤ) : ℤ := b ^ 2 - 4 * a * c





/-- The form x² + y² has discriminant -4. -/
theorem sum_two_sq_disc : form_discriminant 1 0 1 = -4 := by
  unfold form_discriminant; norm_num





/-- The form x² + xy + y² has discriminant -3. -/
theorem eisenstein_form_disc : form_discriminant 1 1 1 = -3 := by
  unfold form_discriminant; norm_num





/-- [Section: # CatalogBuild.Algebra.Foundations.QuadraticForms
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 11] -/
theorem class_number_neg4 :
    ∀ a b c : ℤ, 0 < a → a ≤ c → -a < b → b ≤ a →
    form_discriminant a b c = -4 → a = 1 ∧ b = 0 ∧ c = 1 := by
      intros a b c ha hc hb hb' h_eq
      have h_a_le_1 : a ≤ 1 := by
        unfold form_discriminant at h_eq ; nlinarith [ show b ^ 2 ≤ a ^ 2 by nlinarith ] ;
      interval_cases a ; interval_cases b <;> unfold form_discriminant at h_eq <;> ( ( have : c ≤ 2 := Int.le_of_lt_add_one ( by nlinarith ) ; interval_cases c <;> trivial ) )





/-- If m and n are both sums of two squares, so is mn. -/
theorem sum_sq_mul_sum_sq (m n : ℤ)
    (hm : ∃ a b : ℤ, m = a ^ 2 + b ^ 2)
    (hn : ∃ c d : ℤ, n = c ^ 2 + d ^ 2) :
    ∃ e f : ℤ, m * n = e ^ 2 + f ^ 2 := by
  obtain ⟨a, b, rfl⟩ := hm
  obtain ⟨c, d, rfl⟩ := hn
  exact ⟨a * c - b * d, a * d + b * c, by linarith [brahmagupta_fibonacci a b c d]⟩





/-- Vieta jumping: if x² + y² = kxy, the companion (ky - x) also satisfies it. -/
theorem vieta_descent (x y k : ℤ) (h : x ^ 2 + y ^ 2 = k * x * y) :
    (k * y - x) ^ 2 + y ^ 2 = k * (k * y - x) * y := by linarith





/-- PPTs are the integral points on a² + b² - c² = 0. -/
theorem berggren_quadric (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 - c ^ 2 = 0 := by linarith





/-- The form a² + b² - c² is preserved by all Berggren matrices (by ring). -/
theorem berggren_form_signature :
    ∀ a b c : ℤ, (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 - (2*a - 2*b + 3*c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by intro a b c; ring





/-- 7 is not a sum of three squares. -/
theorem three_sq_obstruction_7 :
    ∀ a b c : ℕ, a ^ 2 + b ^ 2 + c ^ 2 ≠ 7 := by
  intro a b c h
  have ha : a ≤ 2 := by nlinarith [sq_nonneg b, sq_nonneg c]
  have hb : b ≤ 2 := by nlinarith [sq_nonneg a, sq_nonneg c]
  have hc : c ≤ 2 := by nlinarith [sq_nonneg a, sq_nonneg b]
  interval_cases a <;> interval_cases b <;> interval_cases c <;> omega





/-- 15 is not a sum of three squares (15 ≡ 7 mod 8). -/
theorem three_sq_obstruction_15 :
    ∀ a b c : ℕ, a ^ 2 + b ^ 2 + c ^ 2 ≠ 15 := by
  intro a b c h
  have ha : a ≤ 3 := by nlinarith [sq_nonneg b, sq_nonneg c]
  have hb : b ≤ 3 := by nlinarith [sq_nonneg a, sq_nonneg c]
  have hc : c ≤ 3 := by nlinarith [sq_nonneg a, sq_nonneg b]
  interval_cases a <;> interval_cases b <;> interval_cases c <;> omega





/-- 23 is not a sum of three squares (23 ≡ 7 mod 8). -/
theorem three_sq_obstruction_23 :
    ∀ a b c : ℕ, a ^ 2 + b ^ 2 + c ^ 2 ≠ 23 := by
  intro a b c h
  have ha : a ≤ 4 := by nlinarith [sq_nonneg b, sq_nonneg c]
  have hb : b ≤ 4 := by nlinarith [sq_nonneg a, sq_nonneg c]
  have hc : c ≤ 4 := by nlinarith [sq_nonneg a, sq_nonneg b]
  interval_cases a <;> interval_cases b <;> interval_cases c <;> omega



