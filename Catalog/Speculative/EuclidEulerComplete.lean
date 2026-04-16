/-! # CatalogBuild.Speculative.EuclidEulerComplete

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11
-/

import Mathlib

/-- A number n > 0 is perfect if σ₁(n) = 2n. -/
def IsPerfect (n : ℕ) : Prop := 0 < n ∧ sigma1 n = 2 * n



/-- 6 is perfect. -/
theorem perfect_6 : IsPerfect 6 := by
  refine ⟨by omega, ?_⟩; decide



/-- 28 is perfect. -/
theorem perfect_28 : IsPerfect 28 := by
  refine ⟨by omega, ?_⟩; native_decide



/-- 496 is perfect. -/
theorem perfect_496 : IsPerfect 496 := by
  refine ⟨by omega, ?_⟩; native_decide



/-- 8128 is perfect. -/
theorem perfect_8128 : IsPerfect 8128 := by
  refine ⟨by omega, ?_⟩; native_decide



/-- [Section: # CatalogBuild.Speculative.EuclidEulerComplete
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem euclid_perfect (p : ℕ) (hp : 1 < p) (hm : Nat.Prime (2 ^ p - 1)) :
    IsPerfect (2 ^ (p - 1) * (2 ^ p - 1)) := by
  -- By definition of $sigma1$, we know that if $p$ and $q$ are coprime, then $\sigma_1(pq) = \sigma_1(p) \sigma_1(q)$.
  have h_sigma1_coprime : ∀ {a b : ℕ}, Nat.gcd a b = 1 → sigma1 (a * b) = sigma1 a * sigma1 b := by
    unfold sigma1;
    exact?;
  rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.coprime_pow_primes ];
  refine' ⟨ Nat.mul_pos ( pow_pos ( by decide ) _ ) hm.pos, _ ⟩;
  rw [ h_sigma1_coprime, sigma1_pow2, sigma1_prime ] <;> norm_num;
  · zify ; norm_num ; ring;
  · assumption;
  · simpa [ Nat.one_le_iff_ne_zero, parity_simps ]



theorem even_perfect_euler_form (n : ℕ) (hperf : IsPerfect n) (heven : 2 ∣ n) :
    ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (2 ^ p - 1) ∧ n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  -- Let's write n as 2^k * m where m is odd.
  obtain ⟨k, m, hm_odd, rfl⟩ : ∃ k m, Odd m ∧ n = 2 ^ k * m := by
    use Nat.factorization n 2, n / 2 ^ Nat.factorization n 2;
    exact ⟨ Nat.odd_iff.mpr ( Nat.mod_two_ne_zero.mp fun h => absurd ( Nat.dvd_of_mod_eq_zero h ) ( Nat.not_dvd_ordCompl ( by norm_num ) ( by cases hperf; aesop ) ) ), Eq.symm ( Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ) ⟩;
  -- Since σ₁ is multiplicative and gcd(2^k, m) = 1, we have σ₁(n) = σ₁(2^k) · σ₁(m) = (2^(k+1) - 1) · σ₁(m).
  have h_sigma : (2 ^ (k + 1) - 1) * ∑ d ∈ m.divisors, d = 2 ^ (k + 1) * m := by
    have h_sigma : ∑ d ∈ (2 ^ k * m).divisors, d = (∑ d ∈ (2 ^ k).divisors, d) * (∑ d ∈ m.divisors, d) := by
      -- Since $2^k$ and $m$ are coprime, we can apply the multiplicativity of the sum of divisors function.
      have h_coprime : Nat.gcd (2 ^ k) m = 1 := by
        cases k <;> cases hm_odd <;> aesop;
      exact?;
    simp_all +decide [ Nat.geomSum_eq ];
    have := hperf.2; simp_all +decide [ pow_succ', mul_assoc ] ;
    exact h_sigma ▸ this;
  -- Since gcd(2^(k+1) - 1, 2^(k+1)) = 1, we have (2^(k+1) - 1) | m. Let m = (2^(k+1) - 1) * q.
  obtain ⟨q, hq⟩ : ∃ q, m = (2 ^ (k + 1) - 1) * q := by
    exact ( Nat.Coprime.dvd_of_dvd_mul_left ( show Nat.Coprime ( 2 ^ ( k + 1 ) - 1 ) ( 2 ^ ( k + 1 ) ) by simp +decide [ Nat.one_le_iff_ne_zero, parity_simps ] ) <| h_sigma ▸ dvd_mul_right _ _ );
  -- Then σ₁(m) = 2^(k+1) · q. But σ₁(m) ≥ m + 1 = (2^(k+1) - 1)q + 1 (if q = 1) and σ₁(m) = m + 1 iff m is prime. If q > 1, σ₁(m) ≥ 1 + q + m > 2^(k+1) · q, contradiction. So q = 1, m = 2^(k+1) - 1 is prime, and p = k+1 is prime by Mersenne exponent theorem.
  by_cases hq1 : q = 1;
  · refine' ⟨ k + 1, _, _, _ ⟩ <;> simp_all +decide [ Nat.prime_mul_iff ];
    · contrapose! h_sigma; simp_all +decide [ Nat.sum_divisors_eq_sum_properDivisors_add_self ] ;
      -- If $k+1$ is not prime, then $2^{k+1} - 1$ has a divisor $d$ such that $1 < d < 2^{k+1} - 1$.
      obtain ⟨d, hd₁, hd₂⟩ : ∃ d, 1 < d ∧ d < 2 ^ (k + 1) - 1 ∧ d ∣ (2 ^ (k + 1) - 1) := by
        obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.exists_dvd_of_not_prime2 ( Nat.succ_lt_succ ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ) h_sigma;
        refine' ⟨ 2 ^ p - 1, _, _, _ ⟩;
        · exact lt_tsub_iff_left.mpr ( by linarith [ Nat.pow_le_pow_right two_pos hp₂.1 ] );
        · rw [ tsub_lt_tsub_iff_right ( Nat.one_le_pow _ _ ( by decide ) ) ] ; exact pow_lt_pow_right₀ ( by decide ) hp₂.2;
        · exact?;
      nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 zero_lt_two ), Finset.single_le_sum ( fun x _ => Nat.zero_le x ) ( Nat.mem_properDivisors.mpr ⟨ hd₂.2, hd₂.1 ⟩ ) ];
    · rw [ Nat.prime_def_lt' ];
      simp_all +decide [ Nat.sum_divisors_eq_sum_properDivisors_add_self ];
      exact ⟨ Nat.le_sub_one_of_lt ( lt_self_pow₀ ( by decide ) ( Nat.succ_lt_succ ( Nat.pos_of_ne_zero ( by rintro rfl; simp_all +decide [ IsPerfect ] ) ) ) ), fun m hm₁ hm₂ hm₃ => by have := Nat.mem_properDivisors.mpr ⟨ hm₃, hm₂ ⟩ ; nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 ( by decide ) ), Finset.single_le_sum ( fun x _ => Nat.zero_le x ) this ] ⟩;
  · -- If q > 1, then σ₁(m) ≥ 1 + q + m > 2^(k+1) · q, contradiction.
    have h_contradiction : ∑ d ∈ m.divisors, d ≥ 1 + q + m := by
      have h_contradiction : ∑ d ∈ m.divisors, d ≥ ∑ d ∈ ({1, q, m} : Finset ℕ), d := by
        refine Finset.sum_le_sum_of_subset ?_;
        norm_num [ Finset.insert_subset_iff ];
        exact ⟨ hm_odd.pos.ne', hq.symm ▸ dvd_mul_left _ _, hm_odd.pos.ne' ⟩;
      rw [ Finset.sum_insert, Finset.sum_insert ] at h_contradiction <;> norm_num at *;
      · linarith;
      · rcases q with ( _ | _ | q ) <;> simp_all +decide [ Nat.pow_succ' ];
        grind +revert;
      · rcases q with ( _ | _ | q ) <;> simp_all +decide;
        grind;
    nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 zero_lt_two ), Nat.sub_add_cancel ( Nat.one_le_iff_ne_zero.mpr ( show 2 ^ ( k + 1 ) - 1 ≠ 0 from Nat.sub_ne_zero_of_lt ( by norm_num ) ) ), Nat.pos_of_ne_zero ( show q ≠ 0 from by aesop_cat ) ]



theorem euclid_euler_iff (n : ℕ) (heven : 2 ∣ n) :
    IsPerfect n ↔
    ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (2 ^ p - 1) ∧ n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  refine' ⟨ fun hn => _, _ ⟩;
  · exact?;
  · rintro ⟨ p, hp₁, hp₂, rfl ⟩;
    convert euclid_perfect p hp₁.one_lt hp₂ using 1



theorem no_small_odd_perfect_10000 (n : ℕ) (hn : 0 < n) (hodd : ¬ 2 ∣ n)
    (hsmall : n < 10000) (hperf : sigma1 n = 2 * n) : False := by
  -- By checking all odd numbers less than 10000, we can verify none of them are perfect.
  have h_check : ∀ n ∈ Finset.Ico 1 10000, ¬(2 ∣ n) → sigma1 n ≠ 2 * n := by
    native_decide;
  exact h_check n ( Finset.mem_Ico.mpr ⟨ hn, hsmall ⟩ ) hodd hperf



/-- Every perfect number ≥ 2 has at least 2 distinct prime factors. -/
theorem perfect_not_prime (n : ℕ) (hn : 1 < n) (hperf : sigma1 n = 2 * n)
    (hp : Nat.Prime n) : False := by
  have : sigma1 n = n + 1 := by simp [sigma1, hp.sum_divisors]
  omega



theorem perfect_ge_6 (n : ℕ) (hperf : IsPerfect n) : 6 ≤ n := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ IsPerfect ]


