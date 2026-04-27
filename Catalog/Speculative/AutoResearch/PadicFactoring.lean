import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon of a polynomial over Q_p.

## Main Result

Every composite number n > 1 admits a non-trivial factorization into two factors,
each greater than 1.

## Note on the Original Statement

The original statement claimed this for all n > 1, but that is false: prime numbers
are counterexamples. The corrected version adds the hypothesis that n is not prime.
-/

/- The original statement is false: it claims every n > 1 has a non-trivial factorization,
   but prime numbers (e.g. n = 2) are counterexamples. A prime p > 1 cannot be written as
   a * b with both a > 1 and b > 1.

theorem pAdic_factoring_oracle_ORIGINAL {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry
-/

/-- **Corrected version**: A composite number n > 1 (i.e., n > 1 and n is not prime)
    admits a non-trivial factorization into two factors, each greater than 1.

    Modification: Added hypothesis `hc : ¬ Nat.Prime n` to exclude primes,
    which are precisely the numbers > 1 that do not admit such a factorization.

    The parameter `p` is retained for compatibility with the original signature,
    though the proof does not depend on p-adic machinery — the result is purely
    number-theoretic. -/
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨k, hk₁, hk₂⟩
  exact ⟨k, n / k, by rw [Nat.mul_div_cancel' hk₁], by nlinarith,
    by nlinarith [Nat.div_mul_cancel hk₁]⟩
