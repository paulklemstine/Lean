/-
Copyright (c) 2025. All rights reserved.
Weak Chen decomposition: definitions and bounded verification.
-/
import Mathlib

/-!
# Weak Chen Decomposition: Bounded Verification

A number is *semiprime* if it equals a product of exactly two primes.
A *weak Chen decomposition* of `n` writes `n = p + s` where `p` is prime
and `s` is either prime or semiprime.

We verify computationally that every even number from 4 to 100
admits a weak Chen decomposition.

## Main Results

* `semiprime_4`, `semiprime_6`, `semiprime_9` — basic examples
* `prime_is_prime_or_semiprime` — trivial inclusion
* `weak_chen_4_to_100` — verified for [4, 100]
-/

namespace PrimeDecomp

/-- A natural number is semiprime if it is a product of exactly two primes. -/
def Semiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n

/-- Weak Chen decomposition: `n = p + s` where `p` is prime and `s` is
either prime or semiprime. -/
def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ (Nat.Prime s ∨ Semiprime s) ∧ p + s = n

/-- `Semiprime` is decidable by bounded search. -/
instance semiprimeDecidable (n : ℕ) : Decidable (Semiprime n) :=
  decidable_of_iff
    (∃ a ∈ Finset.range (n + 1), ∃ b ∈ Finset.range (n + 1),
      Nat.Prime a ∧ Nat.Prime b ∧ a * b = n)
    ⟨fun ⟨a, _, b, _, ha, hb, hab⟩ => ⟨a, b, ha, hb, hab⟩,
     fun ⟨a, b, ha, hb, hab⟩ => ⟨a, Finset.mem_range.mpr (by
        have := ha.pos; nlinarith [hb.pos]),
      b, Finset.mem_range.mpr (by
        have := hb.pos; nlinarith [ha.pos]),
      ha, hb, hab⟩⟩

/-- `HasWeakChenDecomposition` is decidable by bounded search. -/
instance hasWeakChenDecidable (n : ℕ) :
    Decidable (HasWeakChenDecomposition n) :=
  decidable_of_iff
    (∃ p ∈ Finset.range (n + 1), ∃ s ∈ Finset.range (n + 1),
      Nat.Prime p ∧ (Nat.Prime s ∨ Semiprime s) ∧ p + s = n)
    ⟨fun ⟨p, _, s, _, hp, hs, hps⟩ => ⟨p, s, hp, hs, hps⟩,
     fun ⟨p, s, hp, hs, hps⟩ => ⟨p, Finset.mem_range.mpr (by omega),
      s, Finset.mem_range.mpr (by omega), hp, hs, hps⟩⟩

/-- 4 is semiprime (= 2 × 2). -/
theorem semiprime_4 : Semiprime 4 := ⟨2, 2, by norm_num, by norm_num, by norm_num⟩

/-- 6 is semiprime (= 2 × 3). -/
theorem semiprime_6 : Semiprime 6 := ⟨2, 3, by norm_num, by norm_num, by norm_num⟩

/-- 9 is semiprime (= 3 × 3). -/
theorem semiprime_9 : Semiprime 9 := ⟨3, 3, by norm_num, by norm_num, by norm_num⟩

/-- Every prime is prime-or-semiprime. -/
theorem prime_is_prime_or_semiprime {p : ℕ} (hp : Nat.Prime p) :
    Nat.Prime p ∨ Semiprime p := Or.inl hp

/-- Every even number in [4, 100] has a weak Chen decomposition.
Verified by exhaustive computation. -/
theorem weak_chen_4_to_100 :
    ∀ n ∈ Finset.Icc 4 100, Even n → HasWeakChenDecomposition n := by
  native_decide

end PrimeDecomp