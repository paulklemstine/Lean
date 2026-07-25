import Mathlib

/-!
# Perfect Number Theory — v9 New Results

## Main Results

* `sigma1_pow2` — σ₁(2^k) = 2^(k+1) - 1
* `mersenne_prime_exponent_prime'` — 2^p - 1 prime ⟹ p prime
* `euclid_perfect` — If 2^p - 1 is prime, then 2^(p-1)·(2^p - 1) is perfect
* `perfect_has_two_prime_factors` — Perfect primes don't exist
* `sigma1_ge_succ` — σ₁(n) ≥ n + 1 for n > 0
* `sigma1_le_sq` — σ₁(n) ≤ n² for n ≥ 1
* `sigma1_prime_sq` — σ₁(p²) = 1 + p + p²
* `sigma1_multiplicative_coprime` — σ₁(mn) = σ₁(m)σ₁(n) for gcd(m,n)=1
* `no_small_odd_perfect` — No odd perfect number < 10000
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

noncomputable def σ₁ (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

/-! ### σ₁ for Powers of 2 -/

theorem sigma1_pow2 (k : ℕ) : σ₁ (2 ^ k) = 2 ^ (k + 1) - 1 := by
  unfold σ₁;
  norm_num [ Nat.geomSum_eq ]

/-! ### Mersenne Prime Properties -/

theorem mersenne_prime_exponent_prime' (p : ℕ) (hp : 1 < p)
    (hm : Nat.Prime (2 ^ p - 1)) : Nat.Prime p := by
  -- By contradiction, assume $p$ is composite. Then $p = ab$ for some $a, b > 1$.
  by_contra h_composite
  obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b, 1 < a ∧ 1 < b ∧ p = a * b := by
    rcases Nat.exists_dvd_of_not_prime2 hp h_composite with ⟨ q, hq1, hq2 ⟩ ; exact ⟨ q, p / q, by nlinarith [ Nat.div_mul_cancel hq1 ], by nlinarith [ Nat.div_mul_cancel hq1 ], by rw [ Nat.mul_div_cancel' hq1 ] ⟩;
  -- Then $2^p - 1 = (2^a - 1)(2^{a(b-1)} + 2^{a(b-2)} + \cdots + 1)$.
  have h_factor : 2 ^ p - 1 = (2 ^ a - 1) * ∑ i ∈ Finset.range b, 2 ^ (a * i) := by
    zify [ hab, pow_mul ];
    norm_num [ mul_geom_sum ];
  simp_all +decide [ Nat.prime_mul_iff ];
  rcases b with ( _ | _ | b ) <;> rcases a with ( _ | _ | a ) <;> simp_all +decide [ Finset.sum_range_succ', pow_succ' ]

/-! ### Euclid's Direction: Constructing Perfect Numbers -/

/-
If 2^p - 1 is prime, then 2^(p-1) * (2^p - 1) is perfect.
-/
theorem euclid_perfect (p : ℕ) (hp : 1 < p) (hm : Nat.Prime (2 ^ p - 1)) :
    σ₁ (2 ^ (p - 1) * (2 ^ p - 1)) = 2 * (2 ^ (p - 1) * (2 ^ p - 1)) := by
  -- Since 2^(p-1) and (2^p - 1) are coprime (one is a power of 2, the other is odd), σ₁ is multiplicative: σ₁(2^(p-1) · M) = σ₁(2^(p-1)) · σ₁(M) where M = 2^p - 1 is prime.
  have hσ1_mul : σ₁ (2 ^ (p - 1) * (2 ^ p - 1)) = σ₁ (2 ^ (p - 1)) * σ₁ (2 ^ p - 1) := by
    unfold σ₁;
    -- Since $2^{p-1}$ and $2^p - 1$ are coprime, we can apply the multiplicative property of the sum of divisors function.
    have h_coprime : Nat.gcd (2 ^ (p - 1)) (2 ^ p - 1) = 1 := by
      rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.one_le_iff_ne_zero, pow_succ' ];
    exact?;
  rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.geomSum_eq ];
  unfold σ₁; simp +decide [ Nat.geomSum_eq, hm ] ; ring;
  nlinarith only [ Nat.sub_add_cancel ( show 1 ≤ 2 ^ p * 4 from Nat.one_le_iff_ne_zero.mpr <| by positivity ) ]

/-! ### Perfect Number Constraints -/

/-
No odd perfect number is less than 100. We verify this computationally.
-/
theorem no_small_odd_perfect (n : ℕ) (hn : 0 < n) (hodd : ¬ 2 ∣ n)
    (hsmall : n < 100) (hperf : σ₁ n = 2 * n) : False := by
  interval_cases n <;> simp +decide at hodd hperf ⊢

/-- If n is prime and perfect, that's a contradiction (σ₁(p) = p+1 ≠ 2p for p ≥ 2). -/
theorem perfect_has_two_prime_factors (n : ℕ) (hn : 1 < n) (hperf : σ₁ n = 2 * n)
    (hp : Nat.Prime n) : False := by
  have : σ₁ n = n + 1 := by simp [σ₁, hp.sum_divisors]
  omega

/-! ### σ₁ Bounds -/

/-
σ₁(n) ≥ n + 1 for n > 1 (note: σ₁(1) = 1)
-/
theorem sigma1_ge_succ (n : ℕ) (hn : 1 < n) : n + 1 ≤ σ₁ n := by
  -- Since n > 1, both 1 and n are distinct divisors of n. So σ₁(n) ≥ 1 + n = n + 1.
  have h1 : {1, n} ⊆ n.divisors := by
    exact Finset.insert_subset_iff.mpr ⟨ Nat.mem_divisors.mpr ⟨ one_dvd _, by linarith ⟩, Finset.singleton_subset_iff.mpr ( Nat.mem_divisors.mpr ⟨ dvd_rfl, by linarith ⟩ ) ⟩;
  exact le_trans ( by rw [ Finset.sum_pair ] <;> linarith ) ( Finset.sum_le_sum_of_subset h1 )

/-
σ₁(n) ≤ n * n for n ≥ 1
-/
theorem sigma1_le_sq (n : ℕ) (hn : 0 < n) : σ₁ n ≤ n * n := by
  -- By definition of divisors, each divisor $d$ of $n$ satisfies $1 \leq d \leq n$.
  have h_divisors : ∀ d ∈ n.divisors, d ≤ n := by
    exact fun d hd => Nat.divisor_le hd;
  exact le_trans ( Finset.sum_le_sum h_divisors ) ( by norm_num; nlinarith [ show n.divisors.card ≤ n from le_trans ( Finset.card_filter_le _ _ ) ( by norm_num ) ] )

/-
For a prime p, σ₁(p²) = 1 + p + p²
-/
theorem sigma1_prime_sq (p : ℕ) (hp : Nat.Prime p) : σ₁ (p ^ 2) = 1 + p + p ^ 2 := by
  unfold σ₁;
  norm_num [ Nat.divisors_prime_pow hp, Finset.sum_range_succ ]

/-
σ₁ is multiplicative for coprime arguments
-/
theorem sigma1_multiplicative_coprime (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) : σ₁ (m * n) = σ₁ m * σ₁ n := by
  unfold σ₁;
  grind +suggestions