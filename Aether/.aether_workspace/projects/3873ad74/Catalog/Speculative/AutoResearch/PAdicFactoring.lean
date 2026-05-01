import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over ℚ_p.

## Main results

The original proposed theorem `pAdic_factoring_oracle` claimed that every n > 1
admits a non-trivial factorization (a * b = n with a, b > 1). This is **false**:
primes are counterexamples.

We provide two corrected versions:
- `pAdic_factoring_oracle_corrected`: every n > 1 is prime or composite
- `pAdic_factoring_oracle_composite`: every composite n admits a non-trivial factorization
-/

-- The original theorem statement is **false**: it claims every n > 1 is composite,
-- but primes (e.g. n = 2) are a counterexample. No a, b > 1 satisfy a * b = 2.
--
-- theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
--     ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
--   sorry

/-- Every natural number n > 1 is either prime or admits a non-trivial factorization.
    This is the corrected "factoring oracle": given n > 1, we can always decide
    whether n is prime, and if not, produce a non-trivial factorization.

    **Correction**: added `Nat.Prime n` as a disjunct to handle the prime case. -/
theorem pAdic_factoring_oracle_corrected {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    Nat.Prime n ∨ ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  by_cases hp : Nat.Prime n
  · exact Or.inl hp
  · right
    obtain ⟨a, ha₁, ha₂⟩ := Nat.exists_dvd_of_not_prime2 hn hp
    exact ⟨a, n / a, Nat.mul_div_cancel' ha₁,
      Nat.one_lt_iff_ne_zero_and_ne_one.2 ⟨by aesop_cat, by aesop_cat⟩,
      by nlinarith [Nat.div_mul_cancel ha₁]⟩

/-- Every composite number n (n > 1, not prime) admits a non-trivial factorization.

    **Correction**: added hypothesis `¬ Nat.Prime n` to restrict to composite numbers. -/
theorem pAdic_factoring_oracle_composite {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨k, hk₁, hk₂⟩
  exact ⟨k, n / k, Nat.mul_div_cancel' hk₁,
    Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨by aesop_cat, by aesop_cat⟩,
    by nlinarith [Nat.div_mul_cancel hk₁]⟩
