/-
  # Semiprime Scaffolding for n² + 1

  This file defines the semiprime predicate and proves basic properties,
  creating the vocabulary needed for future formalization of Iwaniec's theorem
  that infinitely many values n² + 1 have at most 2 prime factors.

  ## Definitions

  - `IsSemiprime`: A number that is a product of exactly two primes.

  ## Key results

  - `IsSemiprime.two_le`: Every semiprime is at least 2.
  - `Nat.Prime.not_isSemiprime`: A prime is never semiprime.
  - `isSemiprime_four`, `isSemiprime_six`: Concrete examples.
-/
import Mathlib

/-- A natural number is semiprime if it is a product of exactly two primes
(not necessarily distinct). -/
def IsSemiprime (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p * q = n

/-
Every semiprime is at least 2.
-/
theorem IsSemiprime.two_le {n : ℕ} (h : IsSemiprime n) : 2 ≤ n := by
  rcases h with ⟨ p, q, hp, hq, rfl ⟩ ; nlinarith [ Nat.Prime.two_le hp, Nat.Prime.two_le hq ]

/-
A prime number is not semiprime: one cannot write a prime as a product
of two primes.
-/
theorem Nat.Prime.not_isSemiprime {p : ℕ} (hp : Nat.Prime p) : ¬ IsSemiprime p := by
  rintro ⟨ q, r, hq, hr, rfl ⟩;
  simp_all +decide [ ← Nat.prime_iff, Nat.prime_mul_iff ];
  cases hp <;> simp_all +decide [ ← Nat.prime_iff ]

/-- 4 is semiprime: 4 = 2 * 2. -/
theorem isSemiprime_four : IsSemiprime 4 :=
  ⟨2, 2, by decide, by decide, by ring⟩

/-- 6 is semiprime: 6 = 2 * 3. -/
theorem isSemiprime_six : IsSemiprime 6 :=
  ⟨2, 3, by decide, by decide, by ring⟩