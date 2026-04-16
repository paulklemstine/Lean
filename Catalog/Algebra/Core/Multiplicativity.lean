/-! # CatalogBuild.Algebra.Core.Multiplicativity

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 8
-/

import Mathlib

noncomputable section

/-- The restricted divisor sum: sum of divisors of n not divisible by 4. -/
noncomputable def sigma1_star (n : ℕ) : ℤ :=
  ∑ d ∈ (Nat.divisors n).filter (fun d => ¬(4 ∣ d)), (d : ℤ)



/-- σ₁*(1) = 1. -/
lemma sigma1_star_one : sigma1_star 1 = 1 := by
  unfold sigma1_star
  simp [Nat.divisors_one]
  decide



/-- [Section: # CatalogBuild.Algebra.Core.Multiplicativity
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 8] -/
lemma sigma1_star_odd_prime (p : ℕ) (hp : Nat.Prime p) (hodd : Odd p) :
    sigma1_star p = (p : ℤ) + 1 := by
  unfold sigma1_star;
  rw [ Finset.sum_eq_add ] <;> norm_num [ hp.ne_zero, hp.ne_one ] ; aesop;
  · exact hp.ne_one;
  · intro c hc1 hc2 hc3 hc4; rw [ Nat.dvd_prime hp ] at hc1; aesop;
  · simp_all +decide [ hp.dvd_iff_eq ];
    grind +ring;
  · norm_num +zetaDelta at *



/-- The signed cubic divisor sum: Σ_{d|n} (-1)^{n+d} d³. -/
noncomputable def sigma3_pm (n : ℕ) : ℤ :=
  ∑ d ∈ Nat.divisors n, ((-1 : ℤ) ^ (n + d) * (d : ℤ) ^ 3)



lemma sigma3_pm_one : sigma3_pm 1 = 1 := by
  unfold sigma3_pm; norm_num;



lemma sigma3_pm_odd_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    sigma3_pm p = 1 + (p : ℤ) ^ 3 := by
  unfold sigma3_pm; rw [ hp.sum_divisors ] ; norm_num [ Nat.even_iff, hodd ] ; ring;
  rw [ ← Nat.mod_add_div p 2, hodd ] ; norm_num [ pow_add, pow_mul ] ; ring;



/-- The four-square representation count is 8 times the restricted divisor sum. -/
theorem r4_eq_8_sigma1_star (n : ℕ) :
    (8 : ℤ) * sigma1_star n = 8 * ∑ d ∈ (Nat.divisors n).filter (fun d => ¬(4 ∣ d)), (d : ℤ) := by
  rfl



/-- The eight-square representation count is 16 times the signed cubic divisor sum. -/
theorem r8_eq_16_sigma3_pm (n : ℕ) :
    (16 : ℤ) * sigma3_pm n = 16 * ∑ d ∈ Nat.divisors n, ((-1 : ℤ) ^ (n + d) * (d : ℤ) ^ 3) := by
  rfl


end
