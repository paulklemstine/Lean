import Mathlib
import Catalog.Shared.Sigma1

/-! # CatalogBuild.Speculative.PerfectNumbers

Unified from EuclidEulerComplete, EulerDirectionComplete, EvenPerfectNumbers,
PerfectNumberTheory, and PerfectNumberTheory_2.
Euclid–Euler theorem, Mersenne primes, and σ₁ properties.
-/}

/-- A number n > 0 is perfect if σ₁(n) = 2n. -/
def IsPerfect (n : ℕ) : Prop := 0 < n ∧ sigma1 n = 2 * n

-- ---------------------------------------------------------------------------
-- Concrete examples
-- ---------------------------------------------------------------------------

theorem perfect_6 : IsPerfect 6 := by
  refine ⟨by omega, ?_⟩; decide

theorem perfect_28 : IsPerfect 28 := by
  refine ⟨by omega, ?_⟩; native_decide

theorem perfect_496 : IsPerfect 496 := by
  refine ⟨by omega, ?_⟩; native_decide

theorem perfect_8128 : IsPerfect 8128 := by
  refine ⟨by omega, ?_⟩; native_decide

-- ---------------------------------------------------------------------------
-- Basic properties
-- ---------------------------------------------------------------------------

theorem perfect_ge_6 (n : ℕ) (hperf : IsPerfect n) : 6 ≤ n := by
  rcases n with (_ | _ | _ | _ | _ | _ | _ | n) <;> simp_all +arith +decide [IsPerfect]

/-- A prime cannot be perfect (σ₁(p) = p + 1 ≠ 2p). -/
theorem perfect_not_prime (n : ℕ) (hn : 1 < n) (hperf : sigma1 n = 2 * n)
    (hp : Nat.Prime n) : False := by
  have : sigma1 n = n + 1 := by simp [sigma1, hp.sum_divisors]
  omega

/-- No odd perfect number below 10 000. -/
theorem no_small_odd_perfect_10000 (n : ℕ) (hn : 0 < n) (hodd : ¬ 2 ∣ n)
    (hsmall : n < 10000) (hperf : sigma1 n = 2 * n) : False := by
  have h_check : ∀ n ∈ Finset.Ico 1 10000, ¬(2 ∣ n) → sigma1 n ≠ 2 * n := by
    native_decide
  exact h_check n (Finset.mem_Ico.mpr ⟨hn, hsmall⟩) hodd hperf

-- ---------------------------------------------------------------------------
-- σ₁ properties
-- ---------------------------------------------------------------------------

theorem sigma1_prime (p : ℕ) (hp : Nat.Prime p) : sigma1 p = p + 1 := by
  simp [sigma1, hp.sum_divisors]

theorem sigma1_mersenne_prime (p : ℕ) (hp : Nat.Prime (2 ^ p - 1)) (hp2 : 1 ≤ p) :
    sigma1 (2 ^ p - 1) = 2 ^ p := by
  unfold sigma1
  simp +decide [*, Nat.sum_divisors_eq_sum_properDivisors_add_self]
  rw [Nat.sub_add_cancel (Nat.one_le_pow _ _ (by decide))]

theorem sigma1_gt (n : ℕ) (hn : 1 < n) : n < sigma1 n := by
  unfold sigma1
  rw [Finset.sum_eq_sum_diff_singleton_add (Nat.mem_divisors_self n hn.ne_bot)]
  linarith [Finset.single_le_sum (fun x (hx : x ∈ n.divisors \ {n}) ↦ Nat.zero_le x)
    (Finset.mem_sdiff.mpr ⟨Nat.mem_divisors.mpr ⟨one_dvd n, by linarith⟩, by aesop⟩ :
      1 ∈ n.divisors \ {n})]

theorem sigma1_ge_succ (n : ℕ) (hn : 1 < n) : n + 1 ≤ sigma1 n := by
  exact Nat.succ_le_of_lt (sigma1_gt n hn)

theorem twelve_abundant : 2 * 12 < sigma1 12 := by
  decide +kernel

theorem sigma1_monotone_dvd (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    sigma1 m ≤ sigma1 (m * n) := by
  exact Finset.sum_le_sum_of_subset
    (fun x hx => Nat.mem_divisors.mpr ⟨dvd_mul_of_dvd_left (Nat.dvd_of_mem_divisors hx) _, by positivity⟩)

theorem sigma1_le_sq (n : ℕ) (hn : 0 < n) : sigma1 n ≤ n * n := by
  have h_divisors : ∀ d ∈ n.divisors, d ≤ n := by
    exact fun d hd => Nat.divisor_le hd
  exact le_trans (Finset.sum_le_sum h_divisors)
    (by norm_num; nlinarith [show n.divisors.card ≤ n from
      le_trans (Finset.card_filter_le _ _) (by norm_num)])

theorem sigma1_coprime_mul (a b : ℕ) (h : Nat.Coprime a b) :
    sigma1 (a * b) = sigma1 a * sigma1 b := by
  unfold sigma1
  exact Coprime.sum_divisors_mul h

-- ---------------------------------------------------------------------------
-- Mersenne exponent theorem
-- ---------------------------------------------------------------------------

theorem mersenne_prime_exponent_prime (n : ℕ) (hn : 1 < n)
    (hm : Nat.Prime (2 ^ n - 1)) : Nat.Prime n := by
  exact?

-- ---------------------------------------------------------------------------
-- Euler direction lemmas (modular decomposition)
-- ---------------------------------------------------------------------------

theorem even_decomposition (n : ℕ) (hn : 0 < n) (heven : 2 ∣ n) :
    ∃ k m : ℕ, 0 < k ∧ ¬(2 ∣ m) ∧ 0 < m ∧ n = 2 ^ k * m := by
  exact ⟨Nat.factorization n 2, n / 2 ^ Nat.factorization n 2,
    Nat.pos_of_ne_zero fun con => by simp_all +decide [Nat.factorization],
    Nat.not_dvd_ordCompl (by decide) (by aesop),
    Nat.div_pos (Nat.le_of_dvd hn (Nat.ordProj_dvd _ _)) (pow_pos (by decide) _),
    by rw [Nat.mul_div_cancel' (Nat.ordProj_dvd _ _)]⟩

theorem euler_key_equation (k m : ℕ) (hk : 0 < k) (hm_odd : ¬(2 ∣ m)) (hm : 0 < m)
    (hperf : IsPerfect (2 ^ k * m)) :
    (2 ^ (k + 1) - 1) * sigma1 m = 2 ^ (k + 1) * m := by
  have h_sigma_eq : sigma1 (2 ^ k * m) = 2 ^ (k + 1) * m := by
    rw [hperf.2, pow_succ', mul_assoc]
  rw [← h_sigma_eq, sigma1_coprime_mul]
  · rw [sigma1_pow2]
  · exact Nat.Coprime.pow_left _ (Nat.prime_two.coprime_iff_not_dvd.mpr hm_odd)

theorem euler_m_divisible (k m : ℕ) (hk : 0 < k) (hm : 0 < m)
    (hm_odd : ¬(2 ∣ m))
    (heq : (2 ^ (k + 1) - 1) * sigma1 m = 2 ^ (k + 1) * m) :
    (2 ^ (k + 1) - 1) ∣ m := by
  refine Nat.Coprime.dvd_of_dvd_mul_left ?_ (heq ▸ dvd_mul_right _ _)
  simp +decide [Nat.one_le_iff_ne_zero, parity_simps]

theorem euler_m_is_prime (k m : ℕ) (hk : 0 < k) (hm : 0 < m)
    (hm_odd : ¬(2 ∣ m))
    (heq : (2 ^ (k + 1) - 1) * sigma1 m = 2 ^ (k + 1) * m)
    (hm_eq : m = 2 ^ (k + 1) - 1) :
    Nat.Prime m := by
  have h_sigma_m : sigma1 m = m + 1 := by
    nlinarith [Nat.sub_add_cancel (Nat.one_le_pow (k + 1) 2 zero_lt_two)]
  rw [Nat.prime_def_lt']
  unfold sigma1 at h_sigma_m
  rw [Nat.sum_divisors_eq_sum_properDivisors_add_self] at h_sigma_m
  exact ⟨Nat.le_sub_one_of_lt (lt_self_pow₀ (by decide)
    (Nat.succ_lt_succ (Nat.pos_of_ne_zero (by rintro rfl; simp_all +decide [IsPerfect])))),
    fun n hn₁ hn₂ hnm => by
      have := Nat.mem_properDivisors.mpr ⟨hnm, hn₂⟩
      linarith [Finset.single_le_sum (fun x _ => Nat.zero_le x) this]⟩

-- ---------------------------------------------------------------------------
-- Euclid–Euler theorem
-- ---------------------------------------------------------------------------

theorem euclid_perfect (p : ℕ) (hp : 1 < p) (hm : Nat.Prime (2 ^ p - 1)) :
    IsPerfect (2 ^ (p - 1) * (2 ^ p - 1)) := by
  have h_sigma1_coprime : ∀ {a b : ℕ}, Nat.gcd a b = 1 → sigma1 (a * b) = sigma1 a * sigma1 b := by
    intros a b h_coprime
    unfold sigma1
    exact Coprime.sum_divisors_mul h_coprime
  rcases p with (_ | _ | p) <;> simp_all +decide [Nat.coprime_pow_primes]
  refine' ⟨Nat.mul_pos (pow_pos (by decide) _) hm.pos, _⟩
  rw [h_sigma1_coprime, sigma1_pow2, sigma1_prime] <;> norm_num
  · zify; norm_num; ring
  · assumption
  · simpa [Nat.one_le_iff_ne_zero, parity_simps]

theorem even_perfect_euler_form (n : ℕ) (hperf : IsPerfect n) (heven : 2 ∣ n) :
    ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (2 ^ p - 1) ∧ n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  obtain ⟨k, m, hm_odd, rfl⟩ : ∃ k m, Odd m ∧ n = 2 ^ k * m := by
    use Nat.factorization n 2, n / 2 ^ Nat.factorization n 2
    exact ⟨Nat.odd_iff.mpr (Nat.mod_two_ne_zero.mp fun h =>
      absurd (Nat.dvd_of_mod_eq_zero h) (Nat.not_dvd_ordCompl (by norm_num)
        (by cases hperf; aesop))),
      Eq.symm (Nat.mul_div_cancel' (Nat.ordProj_dvd _ _))⟩
  have h_sigma : (2 ^ (k + 1) - 1) * sigma1 m = 2 ^ (k + 1) * m := by
    have h_sigma : sigma1 (2 ^ k * m) = (sigma1 (2 ^ k)) * (sigma1 m) := by
      have h_coprime : Nat.gcd (2 ^ k) m = 1 := by
        cases k <;> cases hm_odd <;> aesop
      exact sigma1_coprime_mul _ _ h_coprime
    simp_all +decide [Nat.geomSum_eq, pow_succ', mul_assoc]
    have := hperf.2
    simp_all +decide [pow_succ', mul_assoc]
  obtain ⟨q, hq⟩ : ∃ q, m = (2 ^ (k + 1) - 1) * q := by
    exact (Nat.Coprime.dvd_of_dvd_mul_left
      (show Nat.Coprime (2 ^ (k + 1) - 1) (2 ^ (k + 1)) by
        simp +decide [Nat.one_le_iff_ne_zero, parity_simps])
      (h_sigma ▸ dvd_mul_right _ _))
  by_cases hq1 : q = 1
  · refine' ⟨k + 1, _, _, _⟩ <;> simp_all +decide [Nat.prime_mul_iff]
    · contrapose! h_sigma
      simp_all +decide [Nat.sum_divisors_eq_sum_properDivisors_add_self]
      obtain ⟨d, hd₁, hd₂⟩ : ∃ d, 1 < d ∧ d < 2 ^ (k + 1) - 1 ∧ d ∣ (2 ^ (k + 1) - 1) := by
        obtain ⟨p, hp₁, hp₂⟩ := Nat.exists_dvd_of_not_prime2
          (Nat.succ_lt_succ (Nat.pos_of_ne_zero (by aesop_cat))) h_sigma
        refine' ⟨2 ^ p - 1, _, _, _⟩
        · exact lt_tsub_iff_left.mpr (by linarith [Nat.pow_le_pow_right two_pos hp₂.1])
        · rw [tsub_lt_tsub_iff_right (Nat.one_le_pow _ _ (by decide))]
          exact pow_lt_pow_right₀ (by decide) hp₂.2
        · exact?
      nlinarith [Nat.sub_add_cancel (Nat.one_le_pow (k + 1) 2 (by decide)),
        Finset.single_le_sum (fun x _ => Nat.zero_le x)
          (Nat.mem_properDivisors.mpr ⟨hd₂.2, hd₂.1⟩)]
    · rw [Nat.prime_def_lt']
      simp_all +decide [Nat.sum_divisors_eq_sum_properDivisors_add_self]
      exact ⟨Nat.le_sub_one_of_lt (lt_self_pow₀ (by decide)
        (Nat.succ_lt_succ (Nat.pos_of_ne_zero (by rintro rfl; simp_all +decide [IsPerfect])))),
        fun n hn₁ hn₂ hnm => by
          have := Nat.mem_properDivisors.mpr ⟨hnm, hn₂⟩
          nlinarith [Nat.sub_add_cancel (Nat.one_le_pow (k + 1) 2 (by decide)),
            Finset.single_le_sum (fun x _ => Nat.zero_le x) this]⟩
  · have h_contradiction : sigma1 m ≥ 1 + q + m := by
      have h_contradiction : sigma1 m ≥ ∑ d ∈ ({1, q, m} : Finset ℕ), d := by
        refine Finset.sum_le_sum_of_subset ?_
        norm_num [Finset.insert_subset_iff]
        exact ⟨hm_odd.pos.ne', hq.symm ▸ dvd_mul_left _ _, hm_odd.pos.ne'⟩
      rw [Finset.sum_insert, Finset.sum_insert] at h_contradiction <;> norm_num at *
      · linarith
      · rcases q with (_ | _ | q) <;> simp_all +decide [Nat.pow_succ'] <;> grind +revert
      · rcases q with (_ | _ | q) <;> simp_all +decide <;> grind
    nlinarith [Nat.sub_add_cancel (Nat.one_le_pow (k + 1) 2 zero_lt_two),
      Nat.sub_add_cancel (Nat.one_le_iff_ne_zero.mpr
        (show 2 ^ (k + 1) - 1 ≠ 0 from Nat.sub_ne_zero_of_lt (by norm_num))),
      Nat.pos_of_ne_zero (show q ≠ 0 from by aesop_cat)]

theorem euclid_euler_iff (n : ℕ) (heven : 2 ∣ n) :
    IsPerfect n ↔
    ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (2 ^ p - 1) ∧ n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  refine' ⟨fun hn => _, _⟩
  · exact even_perfect_euler_form n hn heven
  · rintro ⟨p, hp₁, hp₂, rfl⟩
    convert euclid_perfect p hp₁.one_lt hp₂ using 1
