/-
Copyright (c) 2025. All rights reserved.
Formal additive prime decomposition framework: definitions.
-/
import Mathlib

/-!
# Additive Prime Decomposition Framework: Core Definitions

This file defines the core concepts for a certified additive prime decomposition
framework. The key abstractions are:

* `TwoPrimeRepresentable` — a number is a sum of two primes
* `ThreePrimeRepresentable` — a number is a sum of three primes
* `GoldbachUpTo` — binary Goldbach conjecture holds up to a bound
* `AdditiveBasisCertificate` — a certificate structure for verified decompositions
* `RepresentsAsSumFrom` — general k-fold additive representation from a set
* `goldbachPairsUpTo` / `CoveredEvens` — graph-theoretic covering reformulation
* `findGoldbachPair` — verified search algorithm

## Design Philosophy

The framework separates structural/parity obstructions from computational
verification. Certificates are first-class objects that can be independently
generated and verified, enabling modular extension of verified ranges.
-/

open Finset Nat

namespace AdditiveGoldbach

/-! ## Core representation predicates -/

/-- A natural number is two-prime representable if it equals a sum of two primes. -/
def TwoPrimeRepresentable (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

/-- A natural number is three-prime representable if it equals a sum of three primes. -/
def ThreePrimeRepresentable (n : ℕ) : Prop :=
  ∃ p q r : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ Nat.Prime r ∧ p + q + r = n

/-- Binary Goldbach holds up to N: every even n with 4 ≤ n ≤ N is two-prime representable. -/
def GoldbachUpTo (N : ℕ) : Prop :=
  ∀ n, 4 ≤ n → n ≤ N → Even n → TwoPrimeRepresentable n

/-- General k-fold additive representation from a set. -/
def RepresentsAsSumFrom (s : Set ℕ) (k : ℕ) (n : ℕ) : Prop :=
  ∃ f : Fin k → ℕ, (∀ i, f i ∈ s) ∧ (∑ i, f i) = n

/-! ## Certificate structure -/

/-- An `AdditiveBasisCertificate` packages a witness function together with
soundness proofs. Given such a certificate, one can extract verified prime-pair
decompositions for any number in its domain. -/
structure AdditiveBasisCertificate where
  /-- The carrier set of primes used -/
  carrier : Finset ℕ
  /-- Witness function: given n, optionally returns a prime pair (p, q) with p + q = n -/
  witness : ℕ → Option (ℕ × ℕ)
  /-- Left component of any witness is prime -/
  sound_prime_left : ∀ n p q, witness n = some (p, q) → Nat.Prime p
  /-- Right component of any witness is prime -/
  sound_prime_right : ∀ n p q, witness n = some (p, q) → Nat.Prime q
  /-- Witness pair sums to n -/
  sound_sum : ∀ n p q, witness n = some (p, q) → p + q = n

/-! ## Verified search algorithm -/

/-- Search for a Goldbach pair by iterating over candidate primes.
    For even n, searches for p from 2 upward such that both p and n-p are prime. -/
def findGoldbachPairAux (n : ℕ) (fuel : ℕ) (k : ℕ) : Option (ℕ × ℕ) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
    if k > n then none
    else if decide (Nat.Prime k) then
      if decide (Nat.Prime (n - k)) then
        if k + (n - k) == n then some (k, n - k)
        else findGoldbachPairAux n fuel (k + 1)
      else findGoldbachPairAux n fuel (k + 1)
    else findGoldbachPairAux n fuel (k + 1)

/-- Find a Goldbach pair for n by searching from p = 2 upward. -/
def findGoldbachPair (n : ℕ) : Option (ℕ × ℕ) :=
  findGoldbachPairAux n n 2

/-! ## Graph-theoretic covering reformulation -/

/-- The set of primes below N+1, as a Finset. -/
def primesBelow (N : ℕ) : Finset ℕ :=
  (Finset.range (N + 1)).filter Nat.Prime

/-- All ordered pairs of primes whose sum is at most N. -/
def goldbachPairsUpTo (N : ℕ) : Finset (ℕ × ℕ) :=
  ((primesBelow N).product (primesBelow N)).filter (fun pq => pq.1 + pq.2 ≤ N)

/-- The set of even numbers covered by prime-pair sums up to N. -/
def CoveredEvens (N : ℕ) : Set ℕ :=
  {n | ∃ p q, (p, q) ∈ goldbachPairsUpTo N ∧ p + q = n}

/-! ## Least Goldbach prime (for conjectures) -/

/-- The least prime p such that n - p is also prime, if one exists. -/
def leastGoldbachPrime (n : ℕ) : Option ℕ :=
  match findGoldbachPair n with
  | some (p, _) => some p
  | none => none

/-! ## Decidability instances -/

instance (n : ℕ) : Decidable (TwoPrimeRepresentable n) :=
  decidable_of_iff
    (∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
      Nat.Prime p ∧ Nat.Prime q ∧ p + q = n)
    ⟨fun ⟨p, _, q, _, hp, hq, hpq⟩ => ⟨p, q, hp, hq, hpq⟩,
     fun ⟨p, q, hp, hq, hpq⟩ => ⟨p, Finset.mem_range.mpr (by omega),
      q, Finset.mem_range.mpr (by omega), hp, hq, hpq⟩⟩

end AdditiveGoldbach