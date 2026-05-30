/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.AutoResearch.ModPSpectralFingerprint.Defs

/-!
# CRT-Based Recovery of Bounded Integers from Mod-p Data

## Overview

This file proves the foundational theorem that bounded integers are uniquely
determined by their residues modulo sufficiently many distinct primes.
This is the algebraic core of the mod-p spectral fingerprint theory.

## Main Results

- `prod_primes_dvd_of_agree`: If two integers agree mod each prime in a set,
  then the product of those primes divides their difference.
- `bounded_int_unique_of_agree`: The main CRT recovery theorem — bounded integers
  agreeing on sufficiently many primes must be equal.
- `fingerprint_determines_bounded_int`: Corollary packaging the result for
  the fingerprint framework.

## Proof Strategy

The key argument is:
1. If a ≡ b (mod p) for each prime p in S, then ∏ p ∈ S, p divides (a - b)
   (since the primes are coprime, their product divides the difference).
2. If |a - b| < ∏ p ∈ S, p and ∏ p ∈ S, p divides (a - b), then a = b.
-/

open Finset BigOperators

namespace ModPSpectralFingerprint

/-! ## §1. Products of distinct primes divide the difference -/

/-
If z is divisible by each prime in a set of distinct primes,
    then z is divisible by their product.
-/
theorem prod_distinct_primes_dvd {z : ℤ} {ps : Finset ℕ}
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hdvd : ∀ p ∈ ps, (p : ℤ) ∣ z) :
    (∏ p ∈ ps, (p : ℤ)) ∣ z := by
  apply Finset.prod_dvd_of_coprime;
  · intro p hp q hq hpq; have := Nat.coprime_primes ( hprimes p hp ) ( hprimes q hq ) ; aesop;
  · assumption

/-- Key lemma: if two integers agree modulo every prime in a finite set,
    then the product of those primes divides their difference. -/
theorem prod_dvd_diff_of_agree {a b : ℤ} {ps : Finset ℕ}
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : agreeOnFingerprint a b ps) :
    (∏ p ∈ ps, (p : ℤ)) ∣ (a - b) := by
  exact prod_distinct_primes_dvd hprimes (fun p hp => hagree p hp)

/-! ## §2. Bounded integers determined by sufficient mod-p data -/

/-
If an integer z has |z| < M and M ∣ z, then z = 0.
-/
theorem eq_zero_of_dvd_of_lt {z : ℤ} {M : ℤ}
    (hM : M > 0) (hdvd : M ∣ z) (hlt : z.natAbs < M.natAbs) : z = 0 := by
  obtain ⟨ k, rfl ⟩ := hdvd;
  simp_all +decide [ Int.natAbs_mul, ne_of_gt ]

/-
**CRT Recovery Theorem**: Two bounded integers agreeing modulo
    sufficiently many distinct primes must be equal.

    This is the algebraic heart of the mod-p spectral fingerprint theory.
    If |a|, |b| ≤ B and they agree mod p for all p in S where ∏ S > 2B,
    then a = b.
-/
theorem bounded_int_unique_of_agree {a b : ℤ} {B : ℕ} {ps : Finset ℕ}
    (ha : a.natAbs ≤ B) (hb : b.natAbs ≤ B)
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : agreeOnFingerprint a b ps)
    (hsuff : (∏ p ∈ ps, p) > 2 * B) :
    a = b := by
  contrapose! hsuff;
  have := prod_dvd_diff_of_agree hprimes hagree;
  zify;
  exact Int.le_of_dvd ( abs_pos.mpr ( sub_ne_zero.mpr hsuff ) ) ( by simpa using this ) |> le_trans <| by cases abs_cases ( a - b ) <;> cases abs_cases a <;> cases abs_cases b <;> linarith;

/-! ## §3. Application to fingerprint framework -/

/-- Fingerprints determine bounded integers: if two BoundedInt values
    have the same mod-p residues for primes whose product exceeds 2B,
    they are equal. -/
theorem fingerprint_determines_bounded_int {B : ℕ} {ps : Finset ℕ}
    (x y : BoundedInt B)
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : agreeOnFingerprint x.val y.val ps)
    (hsuff : (∏ p ∈ ps, p) > 2 * B) :
    x.val = y.val :=
  bounded_int_unique_of_agree x.bound y.bound hprimes hagree hsuff

/-! ## §4. Counting primes: sufficient primes exist -/

/-
For any bound B, there exist finitely many primes whose product exceeds 2B.
    This follows from the divergence of the sum of reciprocals of primes
    (or more simply, from the infinitude of primes).
-/
theorem exists_sufficient_primes (B : ℕ) :
    ∃ ps : Finset ℕ, (∀ p ∈ ps, Nat.Prime p) ∧ (∏ p ∈ ps, p) > 2 * B := by
  -- By the infinitude of primes, there exists a prime $p$ such that $p > 2B$.
  obtain ⟨p, hp_prime, hp_gt⟩ : ∃ p, Nat.Prime p ∧ p > 2 * B := by
    exact Exists.imp ( by tauto ) ( Nat.exists_infinite_primes ( 2 * B + 1 ) )
  use {p}
  simp [hp_prime, hp_gt]

end ModPSpectralFingerprint