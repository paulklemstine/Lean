/-! # CatalogBuild.Speculative.EvenPerfectNumbers

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 14
-/

import Mathlib

def isPerfect (n : ℕ) : Prop := σ₁ n = 2 * n


/-- [Section: ### Properties of Perfect Numbers] -/
theorem perfect_ge_six (n : ℕ) (hn : isPerfect n) (hn1 : 1 < n) : 6 ≤ n := by
  exact le_of_not_gt fun h : n < 6 => by revert hn; interval_cases n <;> simp_all +decide [ isPerfect ] ;


theorem no_small_odd_perfect :
    ∀ n, n < 100 → n % 2 = 1 → 1 < n → ¬isPerfect n := by
  -- We use induction on $n$ to check all odd numbers less than 100.
  intro n hn_lt hn_odd hn_gt_one
  interval_cases n <;> simp_all +decide [isPerfect]


/-- [Section: ### σ₁ for Powers of 2] -/
theorem sigma1_two_pow (k : ℕ) : σ₁ (2 ^ k) = 2 ^ (k + 1) - 1 := by
  unfold σ₁;
  norm_num [ Nat.geomSum_eq ]


theorem sigma1_coprime_mul (a b : ℕ) (h : Nat.Coprime a b) :
    σ₁ (a * b) = σ₁ a * σ₁ b := by
  unfold σ₁;
  exact?


/-- [Section: ### The Euclid Direction (already proved in v6, strengthened here)] -/
theorem euclid_direction (p : ℕ) (hp : 2 ≤ p) (hm : Nat.Prime (2 ^ p - 1)) :
    isPerfect (2 ^ (p - 1) * (2 ^ p - 1)) := by
  unfold isPerfect;
  rw [ sigma1_coprime_mul ];
  · unfold σ₁;
    rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.geomSum_eq ];
    zify ; norm_num ; ring;
  · exact Nat.Coprime.pow_left _ ( Nat.prime_two.coprime_iff_not_dvd.mpr <| by simpa [ ← even_iff_two_dvd, Nat.one_le_iff_ne_zero, parity_simps ] using by linarith )


/-- [Section: ### Toward the Euler Direction] -/
theorem even_decomposition (n : ℕ) (hn : 0 < n) (heven : 2 ∣ n) :
    ∃ k m : ℕ, 0 < k ∧ ¬(2 ∣ m) ∧ 0 < m ∧ n = 2 ^ k * m := by
  exact ⟨ Nat.factorization n 2, n / 2 ^ Nat.factorization n 2, Nat.pos_of_ne_zero fun con => by simp_all +decide [ Nat.factorization ], Nat.not_dvd_ordCompl ( by decide ) ( by aesop ), Nat.div_pos ( Nat.le_of_dvd hn ( Nat.ordProj_dvd _ _ ) ) ( pow_pos ( by decide ) _ ), by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ] ⟩


theorem euler_key_equation (k m : ℕ) (hk : 0 < k) (hm_odd : ¬(2 ∣ m)) (hm : 0 < m)
    (hperf : isPerfect (2 ^ k * m)) :
    (2 ^ (k + 1) - 1) * σ₁ m = 2 ^ (k + 1) * m := by
  -- From the definition of perfect numbers, we have σ₁(2^k * m) = 2 * 2^k * m = 2^(k+1) * m.
  have h_sigma_eq : σ₁ (2 ^ k * m) = 2 ^ (k + 1) * m := by
    rw [ hperf, pow_succ', mul_assoc ];
  rw [ ← h_sigma_eq, sigma1_coprime_mul ];
  · rw [ sigma1_two_pow ];
  · exact Nat.Coprime.pow_left _ ( Nat.prime_two.coprime_iff_not_dvd.mpr hm_odd )


theorem euler_m_divisible (k m : ℕ) (hk : 0 < k) (hm : 0 < m)
    (hm_odd : ¬(2 ∣ m))
    (heq : (2 ^ (k + 1) - 1) * σ₁ m = 2 ^ (k + 1) * m) :
    (2 ^ (k + 1) - 1) ∣ m := by
  refine Nat.Coprime.dvd_of_dvd_mul_left ?_ <| heq ▸ dvd_mul_right _ _;
  simp +decide [ Nat.one_le_iff_ne_zero, parity_simps ]


theorem euler_m_is_prime (k m : ℕ) (hk : 0 < k) (hm : 0 < m)
    (hm_odd : ¬(2 ∣ m))
    (heq : (2 ^ (k + 1) - 1) * σ₁ m = 2 ^ (k + 1) * m)
    (hm_eq : m = 2 ^ (k + 1) - 1) :
    Nat.Prime m := by
  -- Since $σ₁(m) = m + 1$, we have that $m$ is prime.
  have h_sigma_m : σ₁ m = m + 1 := by
    nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 zero_lt_two ) ];
  rw [ Nat.prime_def_lt' ];
  unfold σ₁ at h_sigma_m;
  rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self ] at h_sigma_m;
  exact ⟨ Nat.le_of_not_lt fun h => by interval_cases m ; contradiction, fun n hn₁ hn₂ hnm => by have := Nat.mem_properDivisors.mpr ⟨ hnm, hn₂ ⟩ ; linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le x ) this ] ⟩


/-- 6 = 2^1 * 3 = 2^(2-1) * (2^2 - 1) is perfect. -/
theorem six_perfect : isPerfect 6 := by
  unfold isPerfect σ₁; native_decide


/-- 28 = 2^2 * 7 = 2^(3-1) * (2^3 - 1) is perfect. -/
theorem twentyeight_perfect : isPerfect 28 := by
  unfold isPerfect σ₁; native_decide


/-- 496 = 2^4 * 31 = 2^(5-1) * (2^5 - 1) is perfect. -/
theorem four_ninety_six_perfect : isPerfect 496 := by
  unfold isPerfect σ₁; native_decide


/-- 8128 = 2^6 * 127 = 2^(7-1) * (2^7 - 1) is perfect. -/
theorem eight_one_two_eight_perfect : isPerfect 8128 := by
  unfold isPerfect σ₁; native_decide
