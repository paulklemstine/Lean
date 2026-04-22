import Mathlib

/-! # CatalogBuild.Algebra.Core.GaussianIntegers

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 9
-/


/-- The Gaussian integer norm satisfies N(a + bi) = a² + b². -/
theorem gaussian_norm_eq (a b : ℤ) :
    Zsqrtd.norm (⟨a, b⟩ : GaussianInt) = a ^ 2 + b ^ 2 := by
  simp [Zsqrtd.norm]; ring




/-- A Pythagorean triple a² + b² = c² is equivalent to N(a + bi) = c². -/
theorem gaussian_norm_pyth (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ Zsqrtd.norm (⟨a, b⟩ : GaussianInt) = c ^ 2 := by
  rw [gaussian_norm_eq]




/-- The fundamental factorization: a² + b² = (a + bi)(a - bi) in ℤ[i]. -/
theorem sum_two_sq_factored (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt) * ⟨a, -b⟩ = ⟨a ^ 2 + b ^ 2, 0⟩ := by
  ext <;> simp <;> ring




/-- Squaring a Gaussian integer (m + ni) gives the PPT parametrization:
(m + ni)² = (m² - n²) + (2mn)i, and N((m + ni)²) = (m² + n²)². -/
theorem gaussian_square_parametrization (m n : ℤ) :
    (⟨m, n⟩ : GaussianInt) * ⟨m, n⟩ = ⟨m ^ 2 - n ^ 2, 2 * m * n⟩ := by
  ext <;> simp <;> ring




/-- The norm of (m + ni)² equals (m² + n²)², giving the Euclid parametrization. -/
theorem gaussian_square_norm (m n : ℤ) :
    Zsqrtd.norm ((⟨m, n⟩ : GaussianInt) * ⟨m, n⟩) = (m ^ 2 + n ^ 2) ^ 2 := by
  rw [gaussian_norm_mul, gaussian_norm_eq]; ring




/-- The Euclid parametrization follows from Gaussian integer squaring:
(m² - n²)² + (2mn)² = (m² + n²)². -/
theorem euclid_from_gaussian (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring




/-- r₂(5) includes (1,2), (2,1) and sign variants: 5 = 1² + 2² = 2² + 1². -/
theorem r2_five : (1 : ℤ) ^ 2 + 2 ^ 2 = 5 ∧ 2 ^ 2 + 1 ^ 2 = 5 := by norm_num




/-- A rational prime p ≡ 3 (mod 4) cannot be a sum of two squares.
This is because squares mod 4 are 0 or 1, so a²+b² mod 4 ∈ {0,1,2}. -/
theorem no_sum_two_sq_3mod4 (p : ℕ) (hp : Nat.Prime p) (h3 : p % 4 = 3) :
    ∀ a b : ℕ, a ^ 2 + b ^ 2 ≠ p := by
  intro a b hab
  have : p > 2 := by omega
  have : p % 4 = 1 := by
    rcases Nat.even_or_odd' a with ⟨x, rfl | rfl⟩ <;>
      rcases Nat.even_or_odd' b with ⟨y, rfl | rfl⟩ <;> subst_vars <;> ring_nf <;> norm_num at *
    · exact absurd hp (by
        rw [show (2 * x) ^ 2 + (2 * y) ^ 2 = 2 * (2 * x ^ 2 + 2 * y ^ 2) by ring]
        exact Nat.not_prime_mul (by norm_num) (by nlinarith))
    · cases hp.eq_two_or_odd' <;> simp_all +arith +decide [parity_simps]
  omega




/-- 7 is not a sum of two squares. -/
theorem seven_not_sum_two_sq : ∀ a b : ℕ, a ^ 2 + b ^ 2 ≠ 7 :=
  no_sum_two_sq_3mod4 7 (by norm_num) (by norm_num)



