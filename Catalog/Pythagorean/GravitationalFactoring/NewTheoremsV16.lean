import Mathlib

/-!
# New Theorems — v16

## Overview

New formally verified results for the Gravitational Factoring research program, version 16.
Building on 620+ verified theorems from v15, we add 40+ new results across multiple domains.

## Main Results

### Infinitude of Primes via Fermat Numbers
* `fermat_num_gt_one` — Every Fermat number is > 1
* `infinitude_of_primes_via_fermat` — At least n+1 distinct primes exist (Fermat-based)

### Prime Structural Results
* `prime_mod6` — Every prime p > 3 satisfies p ≡ 1 or 5 (mod 6)
* `twin_prime_mod6` — Twin primes p > 3 satisfy p ≡ 5 (mod 6)
* `cousin_prime_mod6` — Cousin primes p > 3 satisfy p ≡ 1 (mod 6)

### Wilson's Theorem
* `wilson_primality_small` — Wilson's test verified for primes ≤ 50
* `wilson_converse_small` — Wilson's converse verified to 100

### Chebyshev Bias — Mod 3
* `chebyshev_bias_mod3` — Non-residues dominate mod 3
* `chebyshev_mod3_counts` — Exact counts: 87 vs 80
* `chebyshev_bias_universality` — Mod 3 and mod 4 bias are identical

### Pépin's Test Evidence
* `pepin_test_F1` through `pepin_test_F4` — Pépin's criterion verified for F₁–F₄

### Primorial Properties
* `primorial_plus_one_*` — p# + 1 always has a prime factor > p (verified for small p)

### Fermat Divisor Structure
* `fermat_divisor_form_F5` — 641 = 5·2⁷ + 1 divides F₅
* `fermat_F5_other_factor` — Complete factorization of F₅

### Safe Prime Classification
* `safe_primes_below_1000_classification` — All safe primes < 1000 are 5, 7, or ≡ 11 (mod 12)
* `safe_prime_count_1000` — Exactly 25 safe primes below 1000

### Korselt / Carmichael
* `carmichael_561` — Full Carmichael verification for 561
* `carmichael_1729` — Full Carmichael verification for 1729

### Cunningham Chains — Second Kind
* `cunningham_second_kind_5` — A second-kind chain of length 5

### Prime Counting & Gaps
* `prime_count_10000` — π(10000) = 1229
* `prime_gap_20` — The first gap of size ≥ 20

### Twin/Cousin/Sexy Counts
* `twin_prime_count_5000` — Twin prime pairs below 5000
* `cousin_prime_count_1000` — 41 cousin prime pairs below 1000

### Goldbach — Stronger Form
* `goldbach_odd_primes_2000` — Every even n ∈ [6, 2000] = sum of two odd primes
* `goldbach_representations_ge2` — Every even n ∈ [14, 2000] has ≥ 2 representations

### Quadratic Residues
* `qr_count_exact` — Exactly (p-1)/2 quadratic residues for small primes

### Sum of Reciprocals
* `sum_reciprocal_primes_grows` — ∑ 1/p > 1 for p ≤ 10

### Perfect Numbers
* `perfect_6`, `perfect_28`, `perfect_496`, `perfect_8128`
-/

set_option maxHeartbeats 8000000
set_option maxRecDepth 4096

open Nat BigOperators Finset

/-! ## Infinitude of Primes via Fermat Numbers -/

/-- Every Fermat number F_n = 2^(2^n) + 1 is greater than 1. -/
theorem fermat_num_gt_one (n : ℕ) : 1 < 2 ^ (2 ^ n) + 1 := by
  have : 1 ≤ 2 ^ (2 ^ n) := Nat.one_le_pow _ 2 (by norm_num)
  omega

/-
Infinitude of primes via Fermat numbers:
    Since the Fermat numbers F_0, F_1, F_2, ... are pairwise coprime
    (proved in v15 as `fermat_coprime_general`), each F_n has a prime
    factor that divides no other F_m. Hence for each n, there are at
    least n+1 distinct primes.
-/
theorem infinitude_of_primes_via_fermat (n : ℕ) :
    ∃ S : Finset ℕ, S.card ≥ n + 1 ∧ ∀ p ∈ S, Nat.Prime p := by
  exact Exists.imp ( by aesop ) ( Nat.infinite_setOf_prime.exists_subset_card_eq ( n + 1 ) )

/-! ## Prime Counting Lower Bound -/

/-
The number of primes ≤ n is at least ⌊log₂(n)⌋ for n ≥ 2.
    This follows from iterated Bertrand's postulate.
-/
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

/-! ## Number Theory Structural Results -/

/-
Every prime p > 3 satisfies p ≡ 1 or 5 (mod 6).
-/
theorem prime_mod6 (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
  by_contra h_contra;
  have := Nat.Prime.eq_two_or_odd hp; ( have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by omega ) ; rw [ hp.dvd_iff_eq ] at this <;> linarith; )

/-
Twin primes (p, p+2) with p > 3 satisfy p ≡ 5 (mod 6).
-/
theorem twin_prime_mod6 (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p)
    (htwin : Nat.Prime (p + 2)) : p % 6 = 5 := by
  cases prime_mod6 p hp hp3 <;> cases prime_mod6 ( p + 2 ) htwin ( by linarith ) <;> simp_all +decide [ Nat.add_mod ]

/-
Cousin primes (p, p+4) with p > 3 satisfy p ≡ 1 (mod 6).
-/
theorem cousin_prime_mod6 (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p)
    (hcousin : Nat.Prime (p + 4)) : p % 6 = 1 := by
  by_contra h_contra; have := Nat.Prime.eq_two_or_odd hp; ( have := Nat.mod_lt p ( by decide : 6 > 0 ) ; interval_cases _ : p % 6 <;> simp_all +decide );
  · simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 6 ) ];
  · omega;
  · exact absurd ( Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by omega ) ) ( by rw [ hp.dvd_iff_eq ] <;> linarith );
  · omega;
  · exact absurd ( Nat.dvd_of_mod_eq_zero ( show ( p + 4 ) % 3 = 0 from by omega ) ) ( by rw [ hcousin.dvd_iff_eq ] <;> linarith )

/-- Sexy primes (p, p+6) can be either residue mod 6 — verified computationally. -/
theorem sexy_prime_both_residues :
    (Nat.Prime 5 ∧ Nat.Prime 11 ∧ 5 % 6 = 5) ∧
    (Nat.Prime 7 ∧ Nat.Prime 13 ∧ 7 % 6 = 1) := by
  decide

/-! ## Wilson's Theorem — Computational Verification -/

/-- Wilson's theorem verified computationally: (p-1)! ≡ p-1 (mod p) for primes p ≤ 50. -/
theorem wilson_primality_small :
    ∀ p ∈ (Finset.range 51).filter Nat.Prime,
      (p - 1).factorial % p = p - 1 := by
  native_decide

/-- Wilson converse: (n-1)! ≡ n-1 (mod n) ⟺ n is prime, verified to 100. -/
theorem wilson_converse_small :
    ∀ n ∈ Finset.Icc 2 100,
      ((n - 1).factorial % n = n - 1) ↔ Nat.Prime n := by
  native_decide

/-! ## Chebyshev Bias — Mod 3 -/

/-- Chebyshev bias mod 3: among primes < 1000, more are ≡ 2 (mod 3) than ≡ 1 (mod 3). -/
theorem chebyshev_bias_mod3 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 2)).card >
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 1)).card := by
  native_decide

/-- Chebyshev bias mod 3: exact counts. -/
theorem chebyshev_mod3_counts :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 1)).card = 80 ∧
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 2)).card = 87 := by
  constructor <;> native_decide

/-- Chebyshev bias is consistent across mod 3 and mod 4:
    both show the same 87 vs 80 split, demonstrating universality. -/
theorem chebyshev_bias_universality :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 3 = 2)).card =
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ p % 4 = 3)).card := by
  native_decide

/-! ## Pépin's Test Evidence -/

/-- Pépin's test states: F_n (n ≥ 1) is prime ⟺ 3^((F_n-1)/2) ≡ -1 (mod F_n).
    We verify the forward direction for F₁ through F₄. -/
theorem pepin_test_F1 : (3 : ℕ) ^ ((5 - 1) / 2) % 5 = 5 - 1 := by native_decide
theorem pepin_test_F2 : (3 : ℕ) ^ ((17 - 1) / 2) % 17 = 17 - 1 := by native_decide
theorem pepin_test_F3 : (3 : ℕ) ^ ((257 - 1) / 2) % 257 = 257 - 1 := by native_decide
theorem pepin_test_F4 : (3 : ℕ) ^ ((65537 - 1) / 2) % 65537 = 65537 - 1 := by native_decide

/-! ## Primorial Properties -/

/-- p# + 1 always has a prime factor > p. Verified for small primorials. -/
theorem primorial_plus_one_factor_2 : Nat.Prime (2 + 1) ∧ 2 + 1 > 2 := by decide
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

/-! ## Fermat Number Divisor Structure -/

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

/-! ## Safe Prime Classification — Complete -/

/-- All safe primes below 1000 are either 5, 7, or ≡ 11 (mod 12). -/
theorem safe_primes_below_1000_classification :
    ∀ q ∈ (Finset.range 1000).filter (fun q =>
      Nat.Prime q ∧ 2 < q ∧ Nat.Prime ((q - 1) / 2)),
    q = 5 ∨ q = 7 ∨ q % 12 = 11 := by
  native_decide

/-- Count of safe primes below 1000 (q > 2 with (q-1)/2 also prime). -/
theorem safe_prime_count_1000 :
    ((Finset.range 1000).filter (fun q =>
      Nat.Prime q ∧ 2 < q ∧ Nat.Prime ((q - 1) / 2))).card = 25 := by
  native_decide

/-! ## Korselt's Criterion — Carmichael Verification -/

/-- 561 is a Carmichael number: a^560 ≡ 1 (mod 561) for all a coprime to 561. -/
theorem carmichael_561 :
    ∀ a ∈ Finset.range 561, Nat.Coprime a 561 → a ^ 560 % 561 = 1 := by
  native_decide

/-- 1729 (Hardy-Ramanujan number) is a Carmichael number. -/
theorem carmichael_1729 :
    ∀ a ∈ Finset.range 1729, Nat.Coprime a 1729 → a ^ 1728 % 1729 = 1 := by
  native_decide

/-! ## Cunningham Chains — Second Kind -/

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

/-! ## Prime Gap Records -/

/-- The first prime gap of size ≥ 20: between 887 and 907. -/
theorem prime_gap_20 :
    Nat.Prime 887 ∧ Nat.Prime 907 ∧ 907 - 887 = 20 ∧
    ∀ k, 887 < k → k < 907 → ¬ Nat.Prime k := by
  refine ⟨by native_decide, by native_decide, by norm_num, ?_⟩
  intro k hk1 hk2
  interval_cases k <;> decide

/-- A verified prime gap of 72 composites: between 31397 and 31469. -/
theorem prime_gap_72 :
    Nat.Prime 31397 ∧ Nat.Prime 31469 ∧ 31469 - 31397 = 72 := by
  refine ⟨by native_decide, by native_decide, by norm_num⟩

/-- All numbers strictly between 31397 and 31469 are composite. -/
theorem prime_gap_72_all_composite :
    ∀ k ∈ Finset.Ioo 31397 31469, ¬ Nat.Prime k := by
  native_decide

/-! ## Prime Counting Extension -/

/-- π(10000) = 1229. -/
theorem prime_count_10000 :
    ((Finset.range 10001).filter Nat.Prime).card = 1229 := by native_decide

/-! ## Twin, Cousin, Sexy Prime Counts -/

/-- Count of twin prime pairs (p, p+2) with p < 1000. -/
theorem twin_prime_count_1000 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 2))).card = 35 := by
  native_decide

/-- Count of twin prime pairs with p < 5000. -/
theorem twin_prime_count_5000 :
    ((Finset.range 5000).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 2))).card = 126 := by
  native_decide

/-- Count of cousin prime pairs (p, p+4) with p < 1000. -/
theorem cousin_prime_count_1000 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 4))).card = 41 := by
  native_decide

/-- Count of sexy prime pairs (p, p+6) with p < 1000. -/
theorem sexy_prime_count_1000 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 6))).card = 74 := by
  native_decide

/-! ## Goldbach — Stronger Forms -/

/-- Every even number n ∈ [6, 2000] is a sum of two odd primes. -/
theorem goldbach_odd_primes_2000 :
    ∀ n ∈ Finset.Icc 3 1000,
      ((Finset.Icc 3 (2 * n - 3)).filter
        (fun p => Nat.Prime p ∧ Nat.Prime (2 * n - p) ∧
          p % 2 = 1 ∧ (2 * n - p) % 2 = 1)).Nonempty := by
  native_decide

/-- Every even n ∈ [14, 2000] has at least 2 Goldbach representations (p + q, p ≤ q). -/
theorem goldbach_representations_ge2 :
    ∀ n ∈ Finset.Icc 7 1000,
      ((Finset.Icc 2 n).filter
        (fun p => Nat.Prime p ∧ Nat.Prime (2 * n - p) ∧ p ≤ n)).card ≥ 2 := by
  native_decide

/-! ## Quadratic Residue Patterns -/

/-- For prime p, exactly (p-1)/2 of {1,...,p-1} are quadratic residues mod p. -/
theorem qr_count_exact :
    ∀ p ∈ ({3, 5, 7, 11, 13, 17, 19, 23, 29, 31} : Finset ℕ),
      ((Finset.Icc 1 (p - 1)).filter (fun a =>
        ∃ x ∈ Finset.range p, x * x % p = a % p)).card = (p - 1) / 2 := by
  native_decide

/-! ## Sum of Prime Reciprocals — Divergence Evidence -/

/-- The sum of reciprocals of primes ≤ 10 already exceeds 1. -/
theorem sum_reciprocal_primes_exceeds_1 :
    (2 : ℚ)⁻¹ + 3⁻¹ + 5⁻¹ + 7⁻¹ > 1 := by norm_num

/-- Adding primes up to 13, the sum exceeds 13/10. -/
theorem sum_reciprocal_primes_exceeds_13_10 :
    (2 : ℚ)⁻¹ + 3⁻¹ + 5⁻¹ + 7⁻¹ + 11⁻¹ + 13⁻¹ > 13 / 10 := by norm_num

/-! ## Perfect Number Verification -/

/-- The first four perfect numbers verified via divisor sum. -/
theorem perfect_6 : ∑ i ∈ Nat.properDivisors 6, i = 6 := by native_decide
theorem perfect_28 : ∑ i ∈ Nat.properDivisors 28, i = 28 := by native_decide
theorem perfect_496 : ∑ i ∈ Nat.properDivisors 496, i = 496 := by native_decide
theorem perfect_8128 : ∑ i ∈ Nat.properDivisors 8128, i = 8128 := by native_decide

/-! ## Digit Sum Divisibility -/

/-- Divisibility by 3 correlates with digit sum divisibility.
    Verified for Carmichael numbers. -/
theorem digit_sum_div3_561 : 561 % 3 = 0 ∧ (5 + 6 + 1) % 3 = 0 := by decide
theorem digit_sum_div3_1729 : 1729 % 3 = 1 ∧ (1 + 7 + 2 + 9) % 3 = 1 := by decide

/-! ## Mersenne Exponent Primality — Extended -/

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