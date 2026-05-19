/-
Copyright (c) 2025. All rights reserved.
Formal additive prime decomposition theory: definitions and core predicates.
-/
import Mathlib

/-!
# Goldbach-type Additive Prime Decompositions: Definitions

This file defines the core predicates for Goldbach-type additive decompositions of
natural numbers into primes and semiprimes, along with computable witness finsets
and representation counts.

## Main Definitions

* `IsSemiprime` — a number is a product of exactly two primes
* `GoldbachPair` — a certified decomposition of `n` as `p + q` with both prime
* `HasGoldbachDecomposition` — existential Goldbach property
* `OddVinogradovTriple` — decomposition into three primes
* `HasOddVinogradovDecomposition` — existential ternary Goldbach property
* `ChenPair`, `HasChenDecomposition` — prime + semiprime decomposition
* `PrimeOrSemiprime`, `HasWeakChenDecomposition` — relaxed Chen-type decomposition
* `goldbachWitnesses` — computable finset of all Goldbach pairs for `n`
* `goldbachCount` — the number of ordered Goldbach representations
-/

open Finset Nat

namespace Goldbach

/-- A natural number is semiprime if it is a product of exactly two primes. -/
def IsSemiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n

/-- `GoldbachPair n p q` asserts that `p` and `q` are primes summing to `n`. -/
def GoldbachPair (n p q : ℕ) : Prop :=
  Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

/-- A natural number has a Goldbach decomposition if it can be written as
a sum of two primes. -/
def HasGoldbachDecomposition (n : ℕ) : Prop :=
  ∃ p q : ℕ, GoldbachPair n p q

/-- `ChenPair n p s` asserts that `p` is prime, `s` is semiprime, and `p + s = n`. -/
def ChenPair (n p s : ℕ) : Prop :=
  Nat.Prime p ∧ IsSemiprime s ∧ p + s = n

/-- A natural number has a Chen decomposition if it can be written as
a sum of a prime and a semiprime. -/
def HasChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, ChenPair n p s

/-- `OddVinogradovTriple n a b c` asserts that `a`, `b`, `c` are primes summing to `n`. -/
def OddVinogradovTriple (n a b c : ℕ) : Prop :=
  Nat.Prime a ∧ Nat.Prime b ∧ Nat.Prime c ∧ a + b + c = n

/-- A natural number has an odd Vinogradov decomposition if it can be written as
a sum of three primes. -/
def HasOddVinogradovDecomposition (n : ℕ) : Prop :=
  ∃ a b c : ℕ, OddVinogradovTriple n a b c

/-- A number is either prime or semiprime. This is used for weak Chen-type
decompositions where the second summand need not be strictly semiprime. -/
def PrimeOrSemiprime (n : ℕ) : Prop :=
  Nat.Prime n ∨ IsSemiprime n

/-- Weak Chen decomposition: `n = p + s` where `p` is prime and `s` is
either prime or semiprime. -/
def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ PrimeOrSemiprime s ∧ p + s = n

/-- The finset of primes up to `n`. -/
def primeCandidates (n : ℕ) : Finset ℕ := (Finset.range (n + 1)).filter Nat.Prime

/-- The finset of all ordered pairs `(p, q)` of primes with `p + q = n`. -/
def goldbachWitnesses (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n)

/-- The Goldbach representation count: number of ordered pairs of primes
summing to `n`. -/
noncomputable def goldbachCount (n : ℕ) : ℕ := (goldbachWitnesses n).card

instance (n : ℕ) : DecidablePred (fun pq : ℕ × ℕ =>
    Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n) :=
  fun _ => inferInstance

end Goldbach