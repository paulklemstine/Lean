/-! # CatalogBuild.Pythagorean.GravitationalFactoring.NewTheoremsV15

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 19
-/

import Mathlib

/-- [Section: ## Sophie Germain and Safe Prime Structure] -/
theorem sophie_germain_mod3 (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p)
    (hsg : Nat.Prime (2 * p + 1)) : p % 3 = 2 := by
  have := Nat.mod_lt p three_pos; interval_cases _ : p % 3 <;> simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hp.dvd_iff_eq ] ;
  exact absurd ( Nat.dvd_of_mod_eq_zero ( by norm_num [ *, Nat.add_mod, Nat.mul_mod ] : ( 2 * p + 1 ) % 3 = 0 ) ) ( by rw [ hsg.dvd_iff_eq ] <;> linarith )


theorem safe_prime_mod12 (q : ℕ) (hq : Nat.Prime q) (hq7 : 7 < q)
    (hsafe : Nat.Prime ((q - 1) / 2)) : q % 12 = 11 := by
  -- Since q is odd, q ≡ 1 (mod 2).
  have hq_mod_2 : q % 2 = 1 := by
    exact hq.eq_two_or_odd.resolve_left ( by linarith );
  -- Let's consider the possible values of $(q - 1) / 2$ modulo 3.
  have h_cases : ((q - 1) / 2) % 3 = 2 := by
    exact sophie_germain_mod3 _ hsafe ( by omega ) ( by convert hq using 1; omega );
  have := Nat.Prime.eq_two_or_odd hsafe; omega;


/-- [Section: ## Fermat Number Theory] -/
theorem fermat_num_odd (n : ℕ) : (2 ^ (2 ^ n) + 1) % 2 = 1 := by
  norm_num [ Nat.add_mod, Nat.pow_mod ]


theorem fermat_prime_exp_power_of_two (n : ℕ) (hn : 0 < n)
    (hp : Nat.Prime (2 ^ n + 1)) : ∃ k : ℕ, n = 2 ^ k := by
  -- By contradiction, assume that $n$ is not a power of 2.
  by_contra h_not_power_of_two
  obtain ⟨k, m, hm⟩ : ∃ k m : ℕ, n = 2 ^ k * m ∧ m > 1 ∧ Odd m := by
    -- Let $k$ be such that $2^k \mid n$ and $2^{k+1} \nmid n$.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, 2 ^ k ∣ n ∧ ¬2^(k+1) ∣ n := by
      exact ⟨ Nat.factorization n 2, Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hn.ne' ( by decide ) ⟩;
    obtain ⟨ m, rfl ⟩ := hk.1;
    exact ⟨ k, m, rfl, Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩, Nat.odd_iff.mpr <| Nat.mod_two_ne_zero.mp fun contra => hk.2 <| Nat.mul_dvd_mul_left _ <| Nat.dvd_of_mod_eq_zero contra ⟩;
  -- Then $2^n + 1 = (2^{2^k})^m + 1$ is divisible by $2^{2^k} + 1$.
  have h_div : (2 ^ (2 ^ k) + 1) ∣ (2 ^ n + 1) := by
    simpa [ hm.1, pow_mul ] using hm.2.2.nat_add_dvd_pow_add_pow _ 1;
  simp_all +decide [ Nat.dvd_prime ]


theorem fermat_product_identity (n : ℕ) :
    (∏ i ∈ Finset.range n, (2 ^ (2 ^ i) + 1)) + 2 = 2 ^ (2 ^ n) + 1 := by
  induction n <;> simp_all +decide [ Finset.prod_range_succ, pow_succ, pow_mul ];
  grind


theorem fermat_coprime_adjacent (n : ℕ) :
    Nat.Coprime (2 ^ (2 ^ n) + 1) (2 ^ (2 ^ (n + 1)) + 1) := by
  norm_num [ show 2 ^ 2 ^ ( n + 1 ) + 1 = ( 2 ^ 2 ^ n + 1 ) * ( 2 ^ 2 ^ n - 1 ) + 2 by zify ; norm_num ; ring ];
  simp +decide [ parity_simps ]


theorem fermat_coprime_general (m n : ℕ) (hmn : m ≠ n) :
    Nat.Coprime (2 ^ (2 ^ m) + 1) (2 ^ (2 ^ n) + 1) := by
  -- Without loss of generality, assume $m < n$.
  suffices h_wlog : ∀ {m n : ℕ}, m < n → Nat.Coprime (2 ^ (2 ^ m) + 1) (2 ^ (2 ^ n) + 1) by
    cases lt_or_gt_of_ne hmn <;> [ exact h_wlog ‹_› ; exact Nat.Coprime.symm ( h_wlog ‹_› ) ];
  intros m n mn; rw [ Nat.Coprime ] ;
  -- By the properties of Fermat numbers, we know that $2^{2^m} + 1$ divides $2^{2^n} - 1$.
  have h_div : 2 ^ 2 ^ m + 1 ∣ 2 ^ 2 ^ n - 1 := by
    induction mn <;> simp_all +decide [ Nat.pow_succ, pow_mul ];
    · exact ⟨ 2 ^ 2 ^ m - 1, by rw [ ← Nat.sq_sub_sq ] ; ring ⟩;
    · exact dvd_trans ‹_› ( by convert nat_sub_dvd_pow_sub_pow _ 1 2 using 1 ; ring );
  obtain ⟨ k, hk ⟩ := h_div;
  norm_num [ show 2 ^ 2 ^ n + 1 = ( 2 ^ 2 ^ m + 1 ) * k + 2 by linarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( 2 ^ n ) 2 zero_lt_two ) ] ]


/-- [Section: ## Prime Desert — Strengthened] -/
theorem prime_desert_explicit (k : ℕ) (hk : 2 ≤ k) (j : ℕ) (hj2 : 2 ≤ j) (hjk : j ≤ k + 1) :
    ¬ Nat.Prime ((k + 1).factorial + j) := by
  exact fun H => absurd ( Nat.dvd_of_mod_eq_zero ( show ( ( k + 1 ) ! + j ) % j = 0 from Nat.mod_eq_zero_of_dvd <| by simpa using Nat.dvd_factorial ( by linarith ) hjk ) ) ( by rw [ H.dvd_iff_eq ] <;> linarith [ Nat.self_le_factorial ( k + 1 ) ] )


/-- Goldbach's conjecture verified for all even numbers in [4, 2000]:
every even number ≥ 4 can be written as a sum of two primes. -/
theorem goldbach_verified_2000 :
    ∀ n ∈ Finset.Icc 2 1000,
      ((Finset.range (2 * n + 1)).filter
        (fun p => Nat.Prime p ∧ Nat.Prime (2 * n - p) ∧ p ≤ 2 * n)).Nonempty := by
  native_decide


/-- Legendre's conjecture: there is always a prime between n² and (n+1)² for n ≤ 200. -/
theorem legendre_verified_200 :
    ∀ n ∈ Finset.Icc 1 200,
      ∃ p ∈ Finset.Ioc (n * n) ((n + 1) * (n + 1)), Nat.Prime p := by
  native_decide


/-- Chebyshev bias persists mod 4 up to 1000. -/
theorem chebyshev_bias_mod4 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 3)).card >
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 1)).card := by
  native_decide


/-- Chebyshev bias mod 4: exact counts. -/
theorem chebyshev_mod4_counts :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 1)).card = 80 ∧
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 3)).card = 87 := by
  constructor <;> native_decide


/-- Chebyshev bias mod 5: non-residues dominate.
Non-residues mod 5: {2, 3}, Residues: {1, 4}.
89 non-residue primes vs 78 residue primes up to 1000. -/
theorem chebyshev_bias_mod5 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ (p % 5 = 2 ∨ p % 5 = 3))).card >
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ (p % 5 = 1 ∨ p % 5 = 4))).card := by
  native_decide


/-- Chebyshev bias mod 5: exact counts. -/
theorem chebyshev_mod5_counts :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ (p % 5 = 2 ∨ p % 5 = 3))).card = 89 ∧
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ (p % 5 = 1 ∨ p % 5 = 4))).card = 78 := by
  constructor <;> native_decide


/-- An arithmetic progression of 10 primes:
199, 409, 619, 829, 1039, 1249, 1459, 1669, 1879, 2089
with common difference 210 = 2·3·5·7. -/
theorem green_tao_10 :
    ∀ i ∈ Finset.range 10, Nat.Prime (199 + 210 * i) := by
  native_decide


/-- Every residue class coprime to 10 contains a prime ≤ 100. -/
theorem linnik_evidence_mod10 :
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 1) ∧
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 3) ∧
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 7) ∧
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 9) := by
  exact ⟨⟨11, by simp; decide⟩, ⟨3, by simp; decide⟩,
         ⟨7, by simp; decide⟩, ⟨19, by simp; decide⟩⟩


/-- π(2000) = 303. -/
theorem prime_count_2000 :
    ((Finset.range 2001).filter Nat.Prime).card = 303 := by native_decide


/-- π(5000) = 669. -/
theorem prime_count_5000 :
    ((Finset.range 5001).filter Nat.Prime).card = 669 := by native_decide


/-- [Section: ## Cunningham Chain Modular Analysis] -/
theorem cunningham_mod3_analysis :
    (∀ p, p % 3 = 0 → (2 * p + 1) % 3 = 1) ∧
    (∀ p, p % 3 = 1 → (2 * p + 1) % 3 = 0) ∧
    (∀ p, p % 3 = 2 → (2 * p + 1) % 3 = 2) := by
  grind
