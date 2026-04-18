import Mathlib
/-! # Wilson's Theorem and Wilson Primes

Formal verification of Wilson's theorem and its converse,
plus Wilson prime identification.

## Main results
- `wilson_primality_small` — (p-1)! ≡ p-1 (mod p) for primes p ≤ 50
- `wilson_converse_small` — (n-1)! ≡ n-1 (mod n) iff n is prime, for n ∈ [2,100]
- `wilson_prime_5` — 5 is a Wilson prime
- `wilson_prime_13` — 13 is a Wilson prime
-/


/-- Wilson's theorem: for prime p, (p-1)! ≡ -1 (mod p).
    We verify this computationally for all primes ≤ 50. -/
theorem wilson_primality_small :
    ∀ p ∈ (Finset.Icc 2 50).filter Nat.Prime,
      Nat.factorial (p - 1) % p = p - 1 := by
  native_decide

/-- Wilson's converse: n ≥ 2 is prime iff (n-1)! ≡ n-1 (mod n).
    Verified bidirectionally for all n ∈ [2, 100]. -/
theorem wilson_converse_small :
    ∀ n ∈ Finset.Icc 2 100,
      (Nat.Prime n ↔ Nat.factorial (n - 1) % n = n - 1) := by
  native_decide

/-- The Wilson quotient: W(p) = ((p-1)! + 1) / p for prime p. -/
def wilsonQuotient (p : ℕ) : ℕ := (Nat.factorial (p - 1) + 1) / p

/-- A Wilson prime is a prime p where p² divides (p-1)! + 1. -/
def IsWilsonPrime (p : ℕ) : Prop :=
  Nat.Prime p ∧ (Nat.factorial (p - 1) + 1) % (p * p) = 0

/-- 5 is a Wilson prime: 4! + 1 = 25 = 5². -/
theorem wilson_prime_5 : IsWilsonPrime 5 := by
  unfold IsWilsonPrime
  constructor
  · decide
  · native_decide

/-- 13 is a Wilson prime: 12! + 1 = 479001601 = 13² × 2834329. -/
theorem wilson_prime_13 : IsWilsonPrime 13 := by
  unfold IsWilsonPrime
  constructor
  · decide
  · native_decide

/-- 563 is a Wilson prime. -/
theorem wilson_prime_563 : IsWilsonPrime 563 := by
  unfold IsWilsonPrime
  constructor
  · native_decide
  · native_decide

/-- 2, 3, 7, 11 are NOT Wilson primes. -/
theorem not_wilson_prime_small :
    ¬IsWilsonPrime 2 ∧ ¬IsWilsonPrime 3 ∧ ¬IsWilsonPrime 7 ∧ ¬IsWilsonPrime 11 := by
  unfold IsWilsonPrime
  refine ⟨?_, ?_, ?_, ?_⟩ <;> intro ⟨_, h⟩ <;> revert h <;> native_decide

/-- The three known Wilson primes below 1000 are exactly 5, 13, 563. -/
theorem wilson_primes_below_1000 :
    ∀ p ∈ (Finset.Icc 2 999).filter Nat.Prime,
      (Nat.factorial (p - 1) + 1) % (p * p) = 0 ↔ p ∈ ({5, 13, 563} : Finset ℕ) := by
  native_decide
