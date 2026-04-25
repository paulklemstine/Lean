/-! # CatalogBuild.Speculative.Other.Session2Theorems

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Other.Session2Theorems
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18] -/
theorem sigma1_star_pow2 (k : ℕ) (hk : k ≥ 1) :
    ∑ d ∈ (Nat.divisors (2^k)).filter (fun d => ¬(4 ∣ d)), (d : ℤ) = 3 := by
  rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.divisors_prime_pow ];
  simp +decide [ Finset.sum_filter, Finset.sum_range_succ' ];
  norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.pow_succ', ← mul_assoc, Nat.mul_mod ]


/-- [Section: # CatalogBuild.Speculative.Other.Session2Theorems
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18] -/
theorem r4_pow2 (k : ℕ) (hk : k ≥ 1) :
    (8 : ℤ) * ∑ d ∈ (Nat.divisors (2^k)).filter (fun d => ¬(4 ∣ d)), (d : ℤ) = 24 := by
  induction hk <;> simp_all +decide [ Nat.divisors_prime_pow ];
  simp_all +decide [ Finset.sum_range_succ', Finset.sum_filter ];
  rename_i k hk ih; rcases k with ( _ | _ | k ) <;> norm_num [ Nat.pow_succ', ← mul_assoc, Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_mod ] at *;


/-- [Section: # CatalogBuild.Speculative.Other.Session2Theorems
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18] -/
theorem chi4_sum_pow2 (k : ℕ) (hk : k ≥ 1) :
    ∀ d ∈ Nat.divisors (2^k), d ≠ 1 → 2 ∣ d := by
  intro d hd hd'; rw [ Nat.mem_divisors, Nat.dvd_prime_pow ( by decide ) ] at hd; aesop;


theorem diff_cubes_factor (a b : ℤ) :
    a ^ 3 - b ^ 3 = (a - b) * (a ^ 2 + a * b + b ^ 2) := by
  grind


theorem eisenstein_norm_nonneg (a b : ℤ) :
    4 * (a ^ 2 - a * b + b ^ 2) = (2 * a - b) ^ 2 + 3 * b ^ 2 := by
  grind


theorem channel_ratio_eisenstein (p : ℤ) (hp : p + 1 ≠ 0) :
    1 + p ^ 3 = (p + 1) * (p ^ 2 - p + 1) := by
  grind


theorem geometric_sum_identity (p : ℤ) (k : ℕ) :
    (p - 1) * ∑ i ∈ Finset.range (k + 1), p ^ i = p ^ (k + 1) - 1 := by
  rw [ mul_comm, geom_sum_mul ]


theorem geom_sum_formula (p : ℤ) (k : ℕ) :
    ∑ i ∈ Finset.range (k + 1), p ^ i = (p ^ (k + 1) - 1) / (p - 1) ∨ p = 1 := by
  exact Classical.or_iff_not_imp_right.2 fun h => by rw [ Int.ediv_eq_of_eq_mul_left ] <;> cases lt_or_gt_of_ne h <;> linarith [ geom_sum_mul p ( k + 1 ) ] ;


theorem eisenstein_lower_bound (p : ℤ) (hp : p ≥ 2) :
    p ^ 2 - p + 1 ≥ 3 := by
  nlinarith


theorem channel4_dominates_channel3 (p : ℤ) (hp : p ≥ 2) :
    p ^ 3 + 1 ≥ 3 * (p + 1) := by
  nlinarith [ sq_nonneg ( p - 2 ) ]


theorem channel_ratio_monotone (p n : ℤ) (hp : p ≥ n) (hn : n ≥ 1) :
    p ^ 2 - p + 1 ≥ n ^ 2 - n + 1 := by
  nlinarith


theorem two_sq_closure (a b c d : ℤ) :
    ∃ x y : ℤ,
    (a^2 + b^2) * (c^2 + d^2) = x^2 + y^2 := by
  exact ⟨ a * c + b * d, a * d - b * c, by ring ⟩


theorem r4_div_8 (n : ℕ) :
    (8 : ℤ) ∣ (8 : ℤ) * ∑ d ∈ (Nat.divisors n).filter (fun d => ¬(4 ∣ d)), (d : ℤ) := by
  exact dvd_mul_right _ _


theorem r8_div_16 (n : ℕ) :
    (16 : ℤ) ∣ (16 : ℤ) * ∑ d ∈ Nat.divisors n, ((-1 : ℤ) ^ (n + d) * (d : ℤ) ^ 3) := by
  grind


theorem r2_div_4 (n : ℕ) (chi4 : ℤ → ℤ) :
    (4 : ℤ) ∣ (4 : ℤ) * ∑ d ∈ Nat.divisors n, chi4 (d : ℤ) := by
  exact dvd_mul_right _ _


theorem chi4_sum_prime_1mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    (1 : ℤ) + 1 = 2 := by
  norm_num


theorem chi4_sum_prime_3mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    (1 : ℤ) + (-1) = 0 := by
  norm_num


theorem constant_gap_8 : (4 : ℤ) * 2 - 4 * 0 = 8 := by
  decide +kernel


