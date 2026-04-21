/-! # CatalogBuild.Pythagorean.Berggren.BerggrenGaussianBridge

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22
-/

import Mathlib

/-- [Section: ## Section 1: Gaussian Norm and Pythagorean Equation] -/
theorem gaussian_norm_eq_sum_sq (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt).norm = a ^ 2 + b ^ 2 := by
  simp [Zsqrtd.norm_def]; ring


theorem pyth_iff_gaussian_norm (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ (⟨a, b⟩ : GaussianInt).norm = c ^ 2 := by
  rw [gaussian_norm_eq_sum_sq]


/-- [Section: ## Section 3: PPT Parametrization] -/
theorem parametric_ppt (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring


/-- [Section: ## Section 4: Berggren Steps Preserve PPTs] -/
theorem berggrenA_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by nlinarith


theorem berggrenB_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by nlinarith


theorem berggrenC_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by nlinarith


/-- [Section: ## Section 5: PPT ↔ Gaussian Integer] -/
theorem ppt_gaussian_rep (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    ∃ z : GaussianInt, z.norm = c ^ 2 ∧ z.re = a ∧ z.im = b :=
  ⟨⟨a, b⟩, by rw [gaussian_norm_eq_sum_sq]; exact h, rfl, rfl⟩


theorem root_gaussian : (⟨3, 4⟩ : GaussianInt).norm = 5 ^ 2 := by
  simp [Zsqrtd.norm_def]


theorem root_is_square : (⟨2, 1⟩ : GaussianInt) * ⟨2, 1⟩ = ⟨3, 4⟩ := by decide


theorem norm_generator : (⟨2, 1⟩ : GaussianInt).norm = 5 := by
  simp [Zsqrtd.norm_def]


/-- [Section: ## Section 6: Norm Preservation] -/
theorem mul_i_preserves_norm (z : GaussianInt) :
    ((⟨0, 1⟩ : GaussianInt) * z).norm = z.norm := by
  rw [gaussian_norm_mul]; simp [Zsqrtd.norm_def]


/-- [Section: ## Section 7: Sum of Two Squares] -/
theorem sum_two_squares_iff_norm (n : ℤ) :
    (∃ a b : ℤ, a ^ 2 + b ^ 2 = n) ↔ (∃ z : GaussianInt, z.norm = n) := by
  constructor
  · rintro ⟨a, b, hab⟩; exact ⟨⟨a, b⟩, by rw [gaussian_norm_eq_sum_sq]; exact hab⟩
  · rintro ⟨z, hz⟩; exact ⟨z.re, z.im, by rw [← gaussian_norm_eq_sum_sq]; exact hz⟩


/-- [Section: ## Section 8: Bridge Theorem] -/
theorem berggren_gaussian_bridge (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 < c) :
    ∃ z : GaussianInt, z.norm = c ^ 2 ∧ 0 < z.norm := by
  refine ⟨⟨a, b⟩, ?_, ?_⟩
  · rw [gaussian_norm_eq_sum_sq]; exact hpyth
  · rw [gaussian_norm_eq_sum_sq, hpyth]; positivity


theorem hyp_determines_norm (a₁ b₁ a₂ b₂ c : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c ^ 2) (h₂ : a₂ ^ 2 + b₂ ^ 2 = c ^ 2) :
    (⟨a₁, b₁⟩ : GaussianInt).norm = (⟨a₂, b₂⟩ : GaussianInt).norm := by
  simp [gaussian_norm_eq_sum_sq]; linarith


/-- [Section: ## Section 9: Depth-1 Gaussian Integers] -/
theorem depth1_A_gaussian : (⟨5, 12⟩ : GaussianInt).norm = 169 := by simp [Zsqrtd.norm_def]

theorem depth1_B_gaussian : (⟨21, 20⟩ : GaussianInt).norm = 841 := by simp [Zsqrtd.norm_def]

theorem depth1_C_gaussian : (⟨15, 8⟩ : GaussianInt).norm = 289 := by simp [Zsqrtd.norm_def]


theorem depth1_hyps_mod4 : 13 % 4 = 1 ∧ 29 % 4 = 1 ∧ 17 % 4 = 1 := by omega


/-- [Section: ## Section 10: Primes and Gaussian Factorization] -/
theorem depth1_hyps_prime :
    Nat.Prime 5 ∧ Nat.Prime 13 ∧ Nat.Prime 17 ∧ Nat.Prime 29 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide


theorem two_plus_i_norm_prime : Nat.Prime (Zsqrtd.norm (⟨2, 1⟩ : GaussianInt)).natAbs := by
  simp [Zsqrtd.norm_def]; decide


theorem ppt_first_quadrant (a b : ℤ) (ha : 0 < a) (hb : 0 < b) :
    0 < (⟨a, b⟩ : GaussianInt).re ∧ 0 < (⟨a, b⟩ : GaussianInt).im :=
  ⟨ha, hb⟩


theorem norm_conj_eq (a b : ℤ) :
    (⟨a, -b⟩ : GaussianInt).norm = (⟨a, b⟩ : GaussianInt).norm := by
  simp [Zsqrtd.norm_def]

