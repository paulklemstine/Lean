/-! # CatalogBuild.InformationTheory.ChannelEntropy

Auto-generated from theorem catalog database.
Domain: InformationTheory
Declarations: 12
-/

import Mathlib

lemma sum_divisors_not_div4_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    ∑ d ∈ (Nat.divisors p).filter (fun d => ¬(4 ∣ d)), (d : ℤ) = (p : ℤ) + 1 := by
  rw [ hp.divisors, Finset.sum_eq_add_sum_diff_singleton ] <;> norm_num ; ring;
  · rw [ add_comm, Finset.sum_eq_single 1 ] <;> aesop;
  · grind +ring


theorem r4_odd_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    (8 : ℤ) * ∑ d ∈ (Nat.divisors p).filter (fun d => ¬(4 ∣ d)), (d : ℤ) = 8 * ((p : ℤ) + 1) := by
  have sum_divisors_not_div4_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) : ∑ d ∈ (Nat.divisors p).filter (fun d => ¬(4 ∣ d)), (d : ℤ) = (p : ℤ) + 1 := by
    exact?;
  norm_cast at * ; aesop;


lemma sum_cubed_divisors_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    ∑ d ∈ Nat.divisors p, ((-1 : ℤ) ^ (p + d) * (d : ℤ) ^ 3) = 1 + (p : ℤ) ^ 3 := by
  rw [ hp.sum_divisors, add_comm ] ; simp +decide [ ← Nat.odd_iff, hodd, parity_simps ] ; ring;
  rw [ ← Nat.mod_add_div p 2, hodd ] ; norm_num [ pow_add, pow_mul ] ;


theorem r8_odd_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    (16 : ℤ) * ∑ d ∈ Nat.divisors p, ((-1 : ℤ) ^ (p + d) * (d : ℤ) ^ 3) =
    16 * (1 + (p : ℤ) ^ 3) := by
  rw [ ← sum_cubed_divisors_prime p hp hodd ]


theorem channel_ratio_identity (p : ℤ) (hp : p ≠ -1) :
    (1 + p ^ 3) = (p + 1) * (p ^ 2 - p + 1) := by
  ring


theorem channel_ratio_pos (p : ℕ) (hp : 1 ≤ p) :
    1 ≤ p ^ 2 - p + 1 := by
  grind


lemma chi4_prime_1mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    (if (p : ℤ) % 2 = 0 then (0 : ℤ) else if (p : ℤ) % 4 = 1 then 1 else -1) = 1 := by
  norm_cast; simp +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 4 ), hmod ] ;


lemma chi4_prime_3mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    (if (p : ℤ) % 2 = 0 then (0 : ℤ) else if (p : ℤ) % 4 = 1 then 1 else -1) = -1 := by
  norm_cast; split_ifs <;> omega;


theorem r2_prime_1mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    (4 : ℤ) * ∑ d ∈ Nat.divisors p,
      (if (d : ℤ) % 2 = 0 then (0 : ℤ) else if (d : ℤ) % 4 = 1 then 1 else -1) = 8 := by
  rw [ hp.sum_divisors, mul_comm ] ; norm_cast ; norm_num [ hmod ];
  norm_num [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 4 ), hmod ]


theorem r2_prime_3mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    (4 : ℤ) * ∑ d ∈ Nat.divisors p,
      (if (d : ℤ) % 2 = 0 then (0 : ℤ) else if (d : ℤ) % 4 = 1 then 1 else -1) = 0 := by
  rw [ hp.sum_divisors ] ; norm_cast ; simp +arith +decide [ Nat.add_mod, Nat.mul_mod, hmod ] ;
  norm_num [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 4 ), hmod ]


theorem r4_pos (p : ℕ) : 0 < 8 * ((p : ℤ) + 1) := by
  positivity


theorem r8_gt_r4 (p : ℕ) (hp : 2 ≤ p) :
    8 * ((p : ℤ) + 1) < 16 * (1 + (p : ℤ) ^ 3) := by
  nlinarith [ sq p ]
