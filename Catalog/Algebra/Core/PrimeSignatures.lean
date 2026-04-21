/-! # CatalogBuild.Algebra.Core.PrimeSignatures

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 4
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.Core.PrimeSignatures
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 4] -/
theorem r4_prime_uniform (p : ℕ) (hp : Nat.Prime p) (hodd : Odd p) :
    (∑ d ∈ (Nat.divisors p).filter (fun d => ¬(4 ∣ d)), (d : ℤ)) = (p : ℤ) + 1 := by
  rw [ Finset.sum_eq_add ] <;> norm_num [ hp.ne_zero, hp.ne_one ] ; aesop;
  · exact hp.ne_one;
  · intro c hc1 hc2 hc3 hc4; rw [ Nat.dvd_prime hp ] at hc1; aesop;
  · simp_all +decide [ hp.dvd_iff_eq ];
    grind;
  · norm_num +zetaDelta at *




/-- [Section: # CatalogBuild.Algebra.Core.PrimeSignatures
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 4] -/
theorem signature_gap_constant :
    ∀ p q : ℕ, Nat.Prime p → Nat.Prime q → p % 4 = 1 → q % 4 = 3 → Odd p → Odd q →
    (4 : ℤ) * (∑ d ∈ Nat.divisors p,
      (if (d : ℤ) % 2 = 0 then (0 : ℤ) else if (d : ℤ) % 4 = 1 then 1 else -1)) -
    (4 : ℤ) * (∑ d ∈ Nat.divisors q,
      (if (d : ℤ) % 2 = 0 then (0 : ℤ) else if (d : ℤ) % 4 = 1 then 1 else -1)) = 8 := by
  intro p q hp hq hp4 hq4 hp_odd hq_odd; rw [ hp.sum_divisors, hq.sum_divisors ] ; norm_cast at *; simp +decide [ hp4, hq4, hp_odd, hq_odd ] ; ring;
  norm_num [ Nat.odd_iff.mp hp_odd, Nat.odd_iff.mp hq_odd ]




/-- The ratio r₈(p)/r₄(p) = 2(p² - p + 1), which is twice the Eisenstein norm.
This follows from 16(1+p³)/(8(p+1)) = 2(p²-p+1). -/
theorem channel_ratio_is_twice_eisenstein_norm (p : ℤ) :
    2 * (1 + p ^ 3) = (p + 1) * (2 * p ^ 2 - 2 * p + 2) := by
  ring




/-- The factorization 1 + p³ = (p+1)(p²-p+1). -/
theorem sum_of_cubes_factor (p : ℤ) :
    (1 + p ^ 3) = (p + 1) * (p ^ 2 - p + 1) := by
  ring



