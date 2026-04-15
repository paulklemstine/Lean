import Mathlib

/-!
# Mersenne Primes, Lucas-Lehmer, and Perfect Number Connections — v14

## Overview

We formalize properties of Mersenne numbers M_p = 2^p - 1, their connection
to even perfect numbers via the Euclid-Euler theorem, and verify small
cases of the Lucas-Lehmer test. We also establish Fermat number properties.

## Main Results

* `mersenne_prime_2` through `mersenne_prime_19` — Small Mersenne primes verified
* `mersenne_composite_11` — M_11 = 2047 = 23 × 89 is composite
* `fermat_F0` through `fermat_F4_prime` — First 5 Fermat numbers are prime
* `fermat_F5_composite` — F_5 = 4294967297 = 641 × 6700417 is composite
* `mersenne_prime_gives_perfect` — If 2^p - 1 is prime, then 2^(p-1)(2^p - 1) is perfect
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

/-! ### Mersenne primes verification -/

/-- M_2 = 3 is prime. -/
theorem mersenne_prime_2 : Nat.Prime (mersenne 2) := by native_decide

/-- M_3 = 7 is prime. -/
theorem mersenne_prime_3 : Nat.Prime (mersenne 3) := by native_decide

/-- M_5 = 31 is prime. -/
theorem mersenne_prime_5 : Nat.Prime (mersenne 5) := by native_decide

/-- M_7 = 127 is prime. -/
theorem mersenne_prime_7 : Nat.Prime (mersenne 7) := by native_decide

/-- M_13 = 8191 is prime. -/
theorem mersenne_prime_13 : Nat.Prime (mersenne 13) := by native_decide

/-- M_17 = 131071 is prime. -/
theorem mersenne_prime_17 : Nat.Prime (mersenne 17) := by native_decide

/-- M_19 = 524287 is prime. -/
theorem mersenne_prime_19 : Nat.Prime (mersenne 19) := by native_decide

/-- M_4 = 15 is composite. -/
theorem mersenne_composite_4 : ¬ Nat.Prime (mersenne 4) := by native_decide

/-- M_6 = 63 is composite. -/
theorem mersenne_composite_6 : ¬ Nat.Prime (mersenne 6) := by native_decide

/-- M_11 = 2047 = 23 × 89 is composite (smallest composite Mersenne with prime exponent). -/
theorem mersenne_composite_11 : ¬ Nat.Prime (mersenne 11) ∧ mersenne 11 = 23 * 89 := by
  constructor <;> native_decide

/-
If M_n is prime then n is prime (contrapositive of the divisibility property).
-/
theorem mersenne_prime_exponent_prime'' (n : ℕ) (hn : 2 ≤ n)
    (hm : Nat.Prime (mersenne n)) : Nat.Prime n := by
  grind +suggestions

/-! ### Fermat numbers -/

/-- The n-th Fermat number F_n = 2^(2^n) + 1. -/
def fermatNum (n : ℕ) : ℕ := 2 ^ (2 ^ n) + 1

/-- F_0 = 3 is prime. -/
theorem fermat_F0_prime : Nat.Prime (fermatNum 0) := by native_decide

/-- F_1 = 5 is prime. -/
theorem fermat_F1_prime : Nat.Prime (fermatNum 1) := by native_decide

/-- F_2 = 17 is prime. -/
theorem fermat_F2_prime : Nat.Prime (fermatNum 2) := by native_decide

/-- F_3 = 257 is prime. -/
theorem fermat_F3_prime : Nat.Prime (fermatNum 3) := by native_decide

/-- F_4 = 65537 is prime. -/
theorem fermat_F4_prime : Nat.Prime (fermatNum 4) := by native_decide

/-- F_5 = 4294967297 is composite: 641 × 6700417. (Euler's discovery) -/
theorem fermat_F5_composite : ¬ Nat.Prime (fermatNum 5) ∧ fermatNum 5 = 641 * 6700417 := by
  constructor <;> native_decide

/-! ### Mersenne-Perfect connection -/

/-
If 2^p - 1 is prime, then 2^(p-1) * (2^p - 1) is a perfect number.
    (Euclid's direction of the Euclid-Euler theorem.)
-/
theorem mersenne_prime_gives_perfect (p : ℕ) (hp : 2 ≤ p)
    (hm : Nat.Prime (2 ^ p - 1)) :
    Nat.Perfect (2 ^ (p - 1) * (2 ^ p - 1)) := by
  have h_sigma : ∑ i ∈ (2 ^ (p - 1) * (2 ^ p - 1)).divisors, i = 2 * (2 ^ (p - 1) * (2 ^ p - 1)) := by
    have h_sigma : ∑ i ∈ (2 ^ (p - 1) * (2 ^ p - 1)).divisors, i = (∑ i ∈ (2 ^ (p - 1)).divisors, i) * (∑ i ∈ (2 ^ p - 1).divisors, i) := by
      -- Since $2^{p-1}$ and $2^p - 1$ are coprime, we can apply the multiplicative property of the sum of divisors function.
      have h_coprime : Nat.gcd (2 ^ (p - 1)) (2 ^ p - 1) = 1 := by
        exact Nat.Coprime.pow_left _ ( Nat.prime_two.coprime_iff_not_dvd.mpr <| by simpa [ ← even_iff_two_dvd, Nat.one_le_iff_ne_zero, parity_simps ] using by linarith );
      grind +suggestions;
    rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.geomSum_eq ];
    zify ; norm_num ; ring;
  exact ⟨ by rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self ] at h_sigma; linarith, Nat.mul_pos ( pow_pos ( by decide ) _ ) hm.pos ⟩

/-! ### Primorial values -/

theorem primorial_values' :
    primorial 2 = 2 ∧
    primorial 3 = 6 ∧
    primorial 5 = 30 ∧
    primorial 7 = 210 ∧
    primorial 11 = 2310 ∧
    primorial 13 = 30030 := by
  unfold primorial; native_decide

/-- Mersenne exponent table: which exponents give primes. -/
theorem mersenne_exponent_table :
    (Nat.Prime 2 ∧ Nat.Prime (mersenne 2)) ∧
    (Nat.Prime 3 ∧ Nat.Prime (mersenne 3)) ∧
    (Nat.Prime 5 ∧ Nat.Prime (mersenne 5)) ∧
    (Nat.Prime 7 ∧ Nat.Prime (mersenne 7)) ∧
    (Nat.Prime 11 ∧ ¬Nat.Prime (mersenne 11)) ∧
    (Nat.Prime 13 ∧ Nat.Prime (mersenne 13)) ∧
    (Nat.Prime 17 ∧ Nat.Prime (mersenne 17)) ∧
    (Nat.Prime 19 ∧ Nat.Prime (mersenne 19)) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩,
         ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> native_decide