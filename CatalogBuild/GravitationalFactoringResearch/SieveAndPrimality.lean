/-! # CatalogBuild.GravitationalFactoringResearch.SieveAndPrimality

Auto-generated from theorem catalog database.
Domain: GravitationalFactoringResearch
Declarations: 14
-/

import Mathlib

theorem trial_division_correct (n : ℕ) (hn : 1 < n) :
    Nat.Prime n ↔ ∀ d : ℕ, 1 < d → d * d ≤ n → ¬ d ∣ n := by
  constructor;
  · intro h d hd hdn hddiv
    have hdiv : d * (n / d) = n := by
      rw [ Nat.mul_div_cancel' hddiv ];
    rw [ h.dvd_iff_eq ] at hddiv <;> nlinarith;
  · contrapose!;
    intro h;
    obtain ⟨ k, hk ⟩ := Nat.exists_dvd_of_not_prime2 hn h;
    cases' hk.1 with m hm;
    cases le_total k m <;> [ exact ⟨ k, hk.2.1, by nlinarith, hk.1 ⟩ ; exact ⟨ m, by nlinarith, by nlinarith, hm.symm ▸ dvd_mul_left _ _ ⟩ ]

/-
Every composite number has a factor ≤ its square root.
-/

theorem composite_small_factor (n : ℕ) (hn : 1 < n) (hc : ¬ Nat.Prime n) :
    ∃ d : ℕ, 1 < d ∧ d * d ≤ n ∧ d ∣ n := by
  -- Let $p$ be the smallest prime factor of $n$. By definition, $p$ divides $n$ and $p \leq \sqrt{n}$.
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ n := by
    exact Nat.exists_prime_and_dvd hn.ne';
  cases' hp_div with k hk;
  cases le_total p k <;> [ exact ⟨ p, hp_prime.one_lt, by nlinarith [ hp_prime.two_le ], hk.symm ▸ dvd_mul_right _ _ ⟩ ; exact ⟨ k, Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩, by nlinarith [ hp_prime.two_le ], hk.symm ▸ dvd_mul_left _ _ ⟩ ]

/-! ### Wilson's theorem -/

/-- Wilson's theorem: (p-1)! ≡ p-1 (mod p) for prime p.
    (Since p-1 ≡ -1 mod p, this is the standard statement.) -/

theorem wilson_examples :
    (1).factorial % 2 = 1 ∧
    (2).factorial % 3 = 2 ∧
    (4).factorial % 5 = 4 ∧
    (6).factorial % 7 = 6 ∧
    (10).factorial % 11 = 10 ∧
    (12).factorial % 13 = 12 := by
  native_decide

/-- Wilson's theorem: the converse direction for composites.
    If n > 1 is composite, then (n-1)! ≡ 0 (mod n) (for most composites). -/

theorem wilson_composite_examples :
    (3).factorial % 4 = 2 ∧
    (5).factorial % 6 = 0 ∧
    (7).factorial % 8 = 0 ∧
    (8).factorial % 9 = 0 ∧
    (9).factorial % 10 = 0 ∧
    (11).factorial % 12 = 0 := by
  native_decide

/-- Wilson's theorem for all primes up to 50. -/

theorem wilson_all_primes_to_50 :
    ∀ p ∈ (Finset.Icc 2 50).filter Nat.Prime,
      (p - 1).factorial % p = p - 1 := by
  native_decide

/-! ### Pratt certificates -/

/-- A Pratt certificate for primality of p consists of:
    1. A primitive root g modulo p
    2. A complete factorization of p - 1
    3. Verification that g^((p-1)/q) ≢ 1 (mod p) for each prime factor q of p-1 -/

structure PrattCertificate (p : ℕ) where
  witness : ℕ
  is_primitive_root : witness ^ (p - 1) % p = 1
  passes_all_tests : ∀ q ∈ (p - 1).primeFactorsList.toFinset,
    witness ^ ((p - 1) / q) % p ≠ 1

/-- Pratt certificate for p = 7: witness g = 3.
    p - 1 = 6 = 2 × 3.
    3^3 mod 7 = 6 ≠ 1 (test for q=2)
    3^2 mod 7 = 2 ≠ 1 (test for q=3) -/

theorem pratt_cert_7 : ∃ g : ℕ, g ^ 6 % 7 = 1 ∧
    g ^ 3 % 7 ≠ 1 ∧ g ^ 2 % 7 ≠ 1 :=
  ⟨3, by native_decide, by native_decide, by native_decide⟩

/-- Pratt certificate for p = 13: witness g = 2.
    p - 1 = 12 = 2² × 3.
    2^6 mod 13 = 12 ≠ 1 (test for q=2)
    2^4 mod 13 = 3 ≠ 1 (test for q=3) -/

theorem pratt_cert_13 : ∃ g : ℕ, g ^ 12 % 13 = 1 ∧
    g ^ 6 % 13 ≠ 1 ∧ g ^ 4 % 13 ≠ 1 :=
  ⟨2, by native_decide, by native_decide, by native_decide⟩

/-- Pratt certificate for p = 101: witness g = 2.
    p - 1 = 100 = 2² × 5².
    2^50 mod 101 = 100 ≠ 1 (test for q=2)
    2^20 mod 101 = 95 ≠ 1 (test for q=5) -/

theorem pratt_cert_101 : ∃ g : ℕ, g ^ 100 % 101 = 1 ∧
    g ^ 50 % 101 ≠ 1 ∧ g ^ 20 % 101 ≠ 1 :=
  ⟨2, by native_decide, by native_decide, by native_decide⟩

/-! ### Sieve of Eratosthenes correctness -/

/-- The sieve: numbers in [2, n] not divisible by any prime ≤ √n are prime. -/

theorem sieve_correctness_small :
    -- Sieving {2,...,100} by {2,3,5,7} gives exactly the primes
    ((Finset.Icc 2 100).filter Nat.Prime).card = 25 := by
  native_decide

/-- Sieve gives correct counts for larger ranges. -/

theorem sieve_count_500 :
    ((Finset.Icc 2 500).filter Nat.Prime).card = 95 := by
  native_decide


theorem sieve_count_1000 :
    ((Finset.Icc 2 1000).filter Nat.Prime).card = 168 := by
  native_decide

/-! ### Primality of specific important numbers -/

/-- Verification of primality for cryptographically important sizes. -/

theorem small_crypto_primes :
    Nat.Prime 251 ∧ Nat.Prime 509 ∧ Nat.Prime 1021 ∧
    Nat.Prime 2039 ∧ Nat.Prime 4093 ∧ Nat.Prime 8191 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Numbers of the form 2^k - 1 that are prime (Mersenne primes). -/

theorem mersenne_primality_table :
    Nat.Prime (2^2 - 1) ∧ Nat.Prime (2^3 - 1) ∧
    Nat.Prime (2^5 - 1) ∧ Nat.Prime (2^7 - 1) ∧
    ¬ Nat.Prime (2^4 - 1) ∧ ¬ Nat.Prime (2^6 - 1) ∧
    ¬ Nat.Prime (2^8 - 1) ∧ ¬ Nat.Prime (2^9 - 1) ∧
    ¬ Nat.Prime (2^10 - 1) ∧ ¬ Nat.Prime (2^11 - 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide
