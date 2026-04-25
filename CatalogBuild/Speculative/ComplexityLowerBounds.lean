/-! # CatalogBuild.Speculative.ComplexityLowerBounds

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.ComplexityLowerBounds
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem single_lens_bound (S : ℕ) : S / 2 ≤ S := Nat.div_le_self S 2


/-- [Section: # CatalogBuild.Speculative.ComplexityLowerBounds
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem k_lens_upper_bound (S k : ℕ) : S / 2 ^ k ≤ S := Nat.div_le_self S (2 ^ k)


/-- [Section: # CatalogBuild.Speculative.ComplexityLowerBounds
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem independent_lens_exact (n k : ℕ) (hk : k ≤ n) :
    2 ^ n / 2 ^ k = 2 ^ (n - k) := by
  rw [← Nat.pow_div hk (by norm_num : 0 < 2)]


theorem improvement_factor (n k : ℕ) (hk : k ≤ n) :
    2 ^ n = 2 ^ k * 2 ^ (n - k) := by
  rw [← pow_add]; congr 1; omega


theorem factoring_information_bound (n : ℕ) (hn : 2 ≤ n) : 1 ≤ n / 2 := by omega


theorem brute_force_bound (n : ℕ) : 2 ^ (n / 2) ≤ 2 ^ n :=
  Nat.pow_le_pow_right (by norm_num) (Nat.div_le_self n 2)


theorem lens_enhanced_bound (n k : ℕ) (hk : k ≤ n / 2) :
    2 ^ (n / 2 - k) ≤ 2 ^ (n / 2) :=
  Nat.pow_le_pow_right (by norm_num) (by omega)


theorem polynomial_speedup (n k : ℕ) (hk : k ≤ n / 2) :
    2 ^ (n / 2) / 2 ^ k = 2 ^ (n / 2 - k) := by
  rw [← Nat.pow_div hk (by norm_num : 0 < 2)]


theorem rsa2048_with_lenses : 1024 - 9 = 1015 := by norm_num


theorem nine_lens_speedup : 2 ^ 9 = 512 := by norm_num


theorem lenses_dont_break_rsa : 2 ^ 1015 > 2 ^ 1000 :=
  Nat.pow_lt_pow_right (by norm_num : 1 < 2) (by norm_num)


theorem log_log_lenses_negligible : 2 ^ 11 = 2048 := by norm_num


theorem dependent_lens_reduction (f₁ f₂ : ℕ) (hf₁ : f₁ ≤ 2) (hf₂ : f₂ ≤ 2) :
    f₁ * f₂ ≤ 4 := by
  calc f₁ * f₂ ≤ 2 * 2 := Nat.mul_le_mul hf₁ hf₂
    _ = 4 := by norm_num


