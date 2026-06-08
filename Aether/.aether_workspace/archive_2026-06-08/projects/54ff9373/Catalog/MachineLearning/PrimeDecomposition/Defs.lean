/-
Copyright (c) 2025. All rights reserved.
Formal additive prime decomposition theory: definitions.
-/
import Mathlib

/-!
# Additive Prime Decomposition: Core Definitions

This file defines the fundamental objects for studying additive
decompositions of natural numbers into primes.

## Main Definitions

* `countTwos` — count of 2s in a list
* `Semiprime` — product of exactly two primes
* `goldbachWitnessesOrd` — ordered Goldbach witness pairs
* `goldbachWitnessesUnord` — unordered (canonical) Goldbach witness pairs
* `GoldbachDiagonal` — whether n = p + p for some prime p
-/

open Finset Nat

namespace PrimeDecomp

/-- Count the number of 2s in a list of natural numbers. -/
def countTwos (L : List ℕ) : ℕ := L.count 2

/-- A natural number is semiprime if it is a product of exactly two primes. -/
def Semiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n

/-- The finset of ordered pairs `(p, q)` of primes with `p + q = n`. -/
def goldbachWitnessesOrd (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n)

/-- The finset of unordered (canonical) pairs `(p, q)` with `p ≤ q`,
both prime, and `p + q = n`. -/
def goldbachWitnessesUnord (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n ∧ pq.1 ≤ pq.2)

/-- A natural number has a Goldbach diagonal if `n = p + p` for some prime `p`. -/
def GoldbachDiagonal (n : ℕ) : Prop := ∃ p : ℕ, Nat.Prime p ∧ n = p + p

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

/-- `GoldbachDiagonal` is decidable. -/
instance goldbachDiagonalDecidable (n : ℕ) : Decidable (GoldbachDiagonal n) :=
  decidable_of_iff
    (∃ p ∈ Finset.range (n + 1), Nat.Prime p ∧ n = p + p)
    ⟨fun ⟨p, _, hp, hn⟩ => ⟨p, hp, hn⟩,
     fun ⟨p, hp, hn⟩ => ⟨p, Finset.mem_range.mpr (by omega), hp, hn⟩⟩

end PrimeDecomp