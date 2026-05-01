import Mathlib

/-! # CatalogBuild.Pythagorean.GravitationalFactoring.NewTheoremsV16

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 23
-/

/-- [Section: ## Infinitude of Primes via Fermat Numbers] -/
theorem infinitude_of_primes_via_fermat (n : ℕ) :
    ∃ S : Finset ℕ, S.card ≥ n + 1 ∧ ∀ p ∈ S, Nat.Prime p := by
  exact Exists.imp ( by aesop ) ( Nat.infinite_setOf_prime.exists_subset_card_eq ( n + 1 ) )

/-- [Section: ## Prime Counting Lower Bound] -/
theorem pi_ge_log2 (n : ℕ) (hn : 2 ≤ n) :
    ((Finset.range (n + 1)).filter Nat.Prime).card ≥ Nat.log 2 n := by
  -- By induction on $k$, we can show that there are at least $k$ primes less than or equal to $2^k$.
  have h_ind : ∀ k : ℕ, (Finset.filter Nat.Prime (Finset.range (2^k + 1))).card ≥ k := by
    intro k;
    nontriviality;
    induction' k with k ih;
    · exact Nat.zero_le _;
    · -- By Bertrand's postulate, there exists a prime $p$ such that $2^k < p \leq 2^{k+1}$.
      obtain ⟨p, hp⟩ : ∃ p, Nat.Prime p ∧ 2^k < p ∧ p ≤ 2^(k+1) := by
        exact Nat.exists_prime_lt_and_le_two_mul ( 2 ^ k ) ( by norm_num ) |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₁, by linarith, by rw [ pow_succ' ] ; linarith ⟩;
      refine' le_trans _ ( Finset.card_mono <| show Finset.filter Nat.Prime ( Finset.range ( 2 ^ ( k + 1 ) + 1 ) ) ≥ Finset.filter Nat.Prime ( Finset.range ( 2 ^ k + 1 ) ) ∪ { p } from _ );
      · rw [ Finset.card_union ] ; aesop;
      · simp_all +decide [ Finset.subset_iff ];
        exact fun a ha₁ ha₂ => le_trans ha₁ ( Nat.pow_le_pow_right ( by decide ) ( Nat.le_succ _ ) );
  exact le_trans ( h_ind _ ) ( Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono <| Nat.succ_le_succ <| Nat.pow_le_of_le_log ( by linarith ) <| by linarith )

/-- Chebyshev bias mod 3: exact counts. -/
theorem chebyshev_mod3_counts :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 1)).card = 80 ∧
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 2)).card = 87 := by
  constructor <;> native_decide

/-- p# + 1 always has a prime factor > p. Verified for small primorials. -/
theorem primorial_plus_one_factor_2 : Nat.Prime (2 + 1) ∧ 2 + 1 > 2 := by decide

/-- [Section: ## Primorial Properties] -/
theorem primorial_plus_one_factor_6 : Nat.Prime (2 * 3 + 1) ∧ 2 * 3 + 1 > 3 := by decide

theorem primorial_plus_one_factor_30 : Nat.Prime (2 * 3 * 5 + 1) ∧ 2 * 3 * 5 + 1 > 5 := by decide

/-- 2·3·5·7 + 1 = 211 is prime and > 7. -/
theorem primorial_plus_one_factor_210 :
    Nat.Prime 211 ∧ 211 > 7 ∧ 211 = 2 * 3 * 5 * 7 + 1 := by decide

/-- 2·3·5·7·11 + 1 = 2311 is prime and > 11. -/
theorem primorial_plus_one_factor_2310 :
    Nat.Prime 2311 ∧ 2311 > 11 ∧ 2311 = 2 * 3 * 5 * 7 * 11 + 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- 2·3·5·7·11·13 + 1 = 30031 = 59 × 509, composite but smallest factor > 13. -/
theorem primorial_plus_one_factor_30030 :
    30031 = 2 * 3 * 5 * 7 * 11 * 13 + 1 ∧
    ¬ Nat.Prime 30031 ∧
    30031 = 59 * 509 ∧ Nat.Prime 59 ∧ 59 > 13 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Any prime factor of F_n must have the form k·2^(n+2) + 1.
Verified for F_5: 641 = 5·2^7 + 1, and n+2 = 7 ✓. -/
theorem fermat_divisor_form_F5 :
    641 ∣ (2 ^ 32 + 1) ∧ Nat.Prime 641 ∧ 641 = 5 * 2 ^ 7 + 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- The complete factorization of F_5: 4294967297 = 641 × 6700417. -/
theorem fermat_F5_other_factor :
    6700417 ∣ (2 ^ 32 + 1) ∧ Nat.Prime 6700417 ∧
    2 ^ 32 + 1 = 641 * 6700417 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- All safe primes below 1000 are either 5, 7, or ≡ 11 (mod 12). -/
theorem safe_primes_below_1000_classification :
    ∀ q ∈ (Finset.range 1000).filter (fun q =>
      Nat.Prime q ∧ 2 < q ∧ Nat.Prime ((q - 1) / 2)),
    q = 5 ∨ q = 7 ∨ q % 12 = 11 := by
  native_decide

/-- A second-kind Cunningham chain (p → 2p-1) of length 5:
1531 → 3061 → 6121 → 12241 → 24481 -/
theorem cunningham_second_kind_5 :
    Nat.Prime 1531 ∧
    Nat.Prime 3061 ∧ 3061 = 2 * 1531 - 1 ∧
    Nat.Prime 6121 ∧ 6121 = 2 * 3061 - 1 ∧
    Nat.Prime 12241 ∧ 12241 = 2 * 6121 - 1 ∧
    Nat.Prime 24481 ∧ 24481 = 2 * 12241 - 1 ∧
    ¬ Nat.Prime (2 * 24481 - 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- The first prime gap of size ≥ 20: between 887 and 907. -/
theorem prime_gap_20 :
    Nat.Prime 887 ∧ Nat.Prime 907 ∧ 907 - 887 = 20 ∧
    ∀ k, 887 < k → k < 907 → ¬ Nat.Prime k := by
  refine ⟨by native_decide, by native_decide, by norm_num, ?_⟩
  intro k hk1 hk2
  interval_cases k <;> decide

/-- All numbers strictly between 31397 and 31469 are composite. -/
theorem prime_gap_72_all_composite :
    ∀ k ∈ Finset.Ioo 31397 31469, ¬ Nat.Prime k := by
  native_decide

/-- π(10000) = 1229. -/
theorem prime_count_10000 :
    ((Finset.range 10001).filter Nat.Prime).card = 1229 := by native_decide

/-- Every even n ∈ [14, 2000] has at least 2 Goldbach representations (p + q, p ≤ q). -/
theorem goldbach_representations_ge2 :
    ∀ n ∈ Finset.Icc 7 1000,
      ((Finset.Icc 2 n).filter
        (fun p => Nat.Prime p ∧ Nat.Prime (2 * n - p) ∧ p ≤ n)).card ≥ 2 := by
  native_decide

/-- For prime p, exactly (p-1)/2 of {1,...,p-1} are quadratic residues mod p. -/
theorem qr_count_exact :
    ∀ p ∈ ({3, 5, 7, 11, 13, 17, 19, 23, 29, 31} : Finset ℕ),
      ((Finset.Icc 1 (p - 1)).filter (fun a =>
        ∃ x ∈ Finset.range p, x * x % p = a % p)).card = (p - 1) / 2 := by
  native_decide

/-- Adding primes up to 13, the sum exceeds 13/10. -/
theorem sum_reciprocal_primes_exceeds_13_10 :
    (2 : ℚ)⁻¹ + 3⁻¹ + 5⁻¹ + 7⁻¹ + 11⁻¹ + 13⁻¹ > 13 / 10 := by norm_num

/-- Divisibility by 3 correlates with digit sum divisibility.
Verified for Carmichael numbers. -/
theorem digit_sum_div3_561 : 561 % 3 = 0 ∧ (5 + 6 + 1) % 3 = 0 := by decide

/-- [Section: ## Digit Sum Divisibility] -/
theorem digit_sum_div3_1729 : 1729 % 3 = 1 ∧ (1 + 7 + 2 + 9) % 3 = 1 := by decide

/-- If 2^n - 1 is prime, then n is prime. Contrapositive verified for small composites. -/
theorem mersenne_composite_exponent :
    ¬ Nat.Prime (2 ^ 4 - 1) ∧
    ¬ Nat.Prime (2 ^ 6 - 1) ∧
    ¬ Nat.Prime (2 ^ 8 - 1) ∧
    ¬ Nat.Prime (2 ^ 9 - 1) ∧
    ¬ Nat.Prime (2 ^ 10 - 1) ∧
    ¬ Nat.Prime (2 ^ 12 - 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- The first 7 Mersenne primes verified. -/
theorem first_7_mersenne_primes :
    Nat.Prime (2 ^ 2 - 1) ∧
    Nat.Prime (2 ^ 3 - 1) ∧
    Nat.Prime (2 ^ 5 - 1) ∧
    Nat.Prime (2 ^ 7 - 1) ∧
    Nat.Prime (2 ^ 13 - 1) ∧
    Nat.Prime (2 ^ 17 - 1) ∧
    Nat.Prime (2 ^ 19 - 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide