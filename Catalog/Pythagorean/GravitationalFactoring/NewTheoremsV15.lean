import Mathlib

/-!
# New Theorems — v15

## Overview

New formally verified results for the Gravitational Factoring research program.

## Main Results

* `sophie_germain_mod3` — If p > 3 is Sophie Germain, then p ≡ 2 (mod 3)
* `safe_prime_mod12` — If q > 7 is a safe prime, then q ≡ 11 (mod 12)
* `fermat_num_odd` — Every Fermat number is odd
* `fermat_prime_exp_power_of_two` — If 2^n + 1 is prime and n > 0, then n is a power of 2
* `fermat_product_identity` — Goldbach-Euler identity for Fermat numbers
* `fermat_coprime_adjacent` — Adjacent Fermat numbers are coprime
* `fermat_coprime_general` — All Fermat numbers are pairwise coprime
* `prime_desert_explicit` — Explicit prime deserts of any length
* `goldbach_verified_2000` — Goldbach's conjecture verified up to 2000
* `legendre_verified_200` — Legendre's conjecture verified for n ≤ 200
* `green_tao_10` — An AP of 10 primes
* `chebyshev_bias_mod5` — Chebyshev bias in non-residues mod 5
-/

set_option maxHeartbeats 8000000
set_option maxRecDepth 4096

open Nat BigOperators Finset

/-! ## Sophie Germain and Safe Prime Structure -/

/-
If p > 3 is a Sophie Germain prime (both p and 2p+1 prime), then p ≡ 2 (mod 3).
    Proof: If p ≡ 0 (mod 3), then 3 | p, so p = 3, contradicting p > 3.
    If p ≡ 1 (mod 3), then 2p + 1 ≡ 3 ≡ 0 (mod 3), and 2p+1 > 3, so not prime.
-/
theorem sophie_germain_mod3 (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p)
    (hsg : Nat.Prime (2 * p + 1)) : p % 3 = 2 := by
  have := Nat.mod_lt p three_pos; interval_cases _ : p % 3 <;> simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hp.dvd_iff_eq ] ;
  exact absurd ( Nat.dvd_of_mod_eq_zero ( by norm_num [ *, Nat.add_mod, Nat.mul_mod ] : ( 2 * p + 1 ) % 3 = 0 ) ) ( by rw [ hsg.dvd_iff_eq ] <;> linarith )

/-
If q > 7 is a safe prime, then q ≡ 11 (mod 12).
-/
theorem safe_prime_mod12 (q : ℕ) (hq : Nat.Prime q) (hq7 : 7 < q)
    (hsafe : Nat.Prime ((q - 1) / 2)) : q % 12 = 11 := by
  -- Since q is odd, q ≡ 1 (mod 2).
  have hq_mod_2 : q % 2 = 1 := by
    exact hq.eq_two_or_odd.resolve_left ( by linarith );
  -- Let's consider the possible values of $(q - 1) / 2$ modulo 3.
  have h_cases : ((q - 1) / 2) % 3 = 2 := by
    exact sophie_germain_mod3 _ hsafe ( by omega ) ( by convert hq using 1; omega );
  have := Nat.Prime.eq_two_or_odd hsafe; omega;

/-! ## Fermat Number Theory -/

/-
Every Fermat number F_n = 2^(2^n) + 1 is odd.
-/
theorem fermat_num_odd (n : ℕ) : (2 ^ (2 ^ n) + 1) % 2 = 1 := by
  norm_num [ Nat.add_mod, Nat.pow_mod ]

/-
If 2^n + 1 is prime and n > 0, then n must be a power of 2.
    Proof: If n has an odd factor d > 1, say n = d·m, then
    2^m + 1 divides 2^n + 1 = (2^m)^d + 1 (since x^d + 1 is divisible
    by x + 1 when d is odd). Since 1 < 2^m + 1 < 2^n + 1, this gives
    a nontrivial factor, contradicting primality.
-/
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

/-
The Goldbach–Euler identity for Fermat numbers:
    F_0 · F_1 · ... · F_{n-1} + 2 = F_n.
    This is the key to proving Fermat numbers are pairwise coprime.
-/
theorem fermat_product_identity (n : ℕ) :
    (∏ i ∈ Finset.range n, (2 ^ (2 ^ i) + 1)) + 2 = 2 ^ (2 ^ n) + 1 := by
  induction n <;> simp_all +decide [ Finset.prod_range_succ, pow_succ, pow_mul ];
  grind

/-
Adjacent Fermat numbers are coprime.
-/
theorem fermat_coprime_adjacent (n : ℕ) :
    Nat.Coprime (2 ^ (2 ^ n) + 1) (2 ^ (2 ^ (n + 1)) + 1) := by
  norm_num [ show 2 ^ 2 ^ ( n + 1 ) + 1 = ( 2 ^ 2 ^ n + 1 ) * ( 2 ^ 2 ^ n - 1 ) + 2 by zify ; norm_num ; ring ];
  simp +decide [ parity_simps ]

/-
All Fermat numbers are pairwise coprime.
-/
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

/-! ## Prime Desert — Strengthened -/

/-
For any k ≥ 2, the integers (k+1)! + j for 2 ≤ j ≤ k+1 are all composite.
    This gives a run of k consecutive composites.
-/
theorem prime_desert_explicit (k : ℕ) (hk : 2 ≤ k) (j : ℕ) (hj2 : 2 ≤ j) (hjk : j ≤ k + 1) :
    ¬ Nat.Prime ((k + 1).factorial + j) := by
  exact fun H => absurd ( Nat.dvd_of_mod_eq_zero ( show ( ( k + 1 ) ! + j ) % j = 0 from Nat.mod_eq_zero_of_dvd <| by simpa using Nat.dvd_factorial ( by linarith ) hjk ) ) ( by rw [ H.dvd_iff_eq ] <;> linarith [ Nat.self_le_factorial ( k + 1 ) ] )

/-! ## Goldbach Extension -/

/-- Goldbach's conjecture verified for all even numbers in [4, 2000]:
    every even number ≥ 4 can be written as a sum of two primes. -/
theorem goldbach_verified_2000 :
    ∀ n ∈ Finset.Icc 2 1000,
      ((Finset.range (2 * n + 1)).filter
        (fun p => Nat.Prime p ∧ Nat.Prime (2 * n - p) ∧ p ≤ 2 * n)).Nonempty := by
  native_decide

/-! ## Legendre's Conjecture Evidence -/

/-- Legendre's conjecture: there is always a prime between n² and (n+1)² for n ≤ 200. -/
theorem legendre_verified_200 :
    ∀ n ∈ Finset.Icc 1 200,
      ∃ p ∈ Finset.Ioc (n * n) ((n + 1) * (n + 1)), Nat.Prime p := by
  native_decide

/-! ## Chebyshev Bias Extended -/

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

/-! ## Green-Tao Evidence — Extended -/

/-- An arithmetic progression of 10 primes:
    199, 409, 619, 829, 1039, 1249, 1459, 1669, 1879, 2089
    with common difference 210 = 2·3·5·7. -/
theorem green_tao_10 :
    ∀ i ∈ Finset.range 10, Nat.Prime (199 + 210 * i) := by
  native_decide

/-! ## Linnik's Theorem Evidence -/

/-- Every residue class coprime to 10 contains a prime ≤ 100. -/
theorem linnik_evidence_mod10 :
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 1) ∧
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 3) ∧
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 7) ∧
    (∃ p ∈ Finset.Icc 1 100, Nat.Prime p ∧ p % 10 = 9) := by
  exact ⟨⟨11, by simp; decide⟩, ⟨3, by simp; decide⟩,
         ⟨7, by simp; decide⟩, ⟨19, by simp; decide⟩⟩

/-! ## Prime Counting Bounds -/

/-- π(2000) = 303. -/
theorem prime_count_2000 :
    ((Finset.range 2001).filter Nat.Prime).card = 303 := by native_decide

/-- π(5000) = 669. -/
theorem prime_count_5000 :
    ((Finset.range 5001).filter Nat.Prime).card = 669 := by native_decide

/-! ## Cunningham Chain Modular Analysis -/

/-
In a Cunningham chain, the map p ↦ 2p+1 sends residues mod 3 as:
    0 ↦ 1, 1 ↦ 0, 2 ↦ 2.
    So if any element is ≡ 1 (mod 3), the next is ≡ 0 (mod 3) and composite (if > 3).
-/
theorem cunningham_mod3_analysis :
    (∀ p, p % 3 = 0 → (2 * p + 1) % 3 = 1) ∧
    (∀ p, p % 3 = 1 → (2 * p + 1) % 3 = 0) ∧
    (∀ p, p % 3 = 2 → (2 * p + 1) % 3 = 2) := by
  grind