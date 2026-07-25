import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over Q_p.

## Main Result

The original theorem statement `pAdic_factoring_oracle` claimed that every n > 1
can be written as a * b with both a > 1 and b > 1. This is **false** for primes.

We provide the corrected version `pAdic_factoring_oracle_corrected` which adds
the hypothesis that n is not prime (i.e., n is composite).
-/

-- The original theorem statement is **false**: it claims every n > 1 can be written as a * b
-- with both a > 1 and b > 1. This fails for prime numbers (e.g., n = 2, 3, 5, 7, ...).
-- A prime p > 1 has no factorization p = a * b with both a > 1 and b > 1, by definition.
/-
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry
-/

/-- **Corrected version**: A composite number (n > 1 and not prime) admits a non-trivial
factorization into two factors, each greater than 1.

The proof uses Mathlib's characterization of composite numbers: since n is not prime
and n > 1, there exists a divisor d with 1 < d < n. Then n = d * (n / d) is the
desired factorization with both factors > 1. -/
theorem pAdic_factoring_oracle_corrected (n : ℕ) (hn : n > 1) (hnp : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hnp with ⟨a, ha₁, ha₂⟩
  exact ⟨a, n / a, by rw [Nat.mul_div_cancel' ha₁], by nlinarith,
    by nlinarith [Nat.div_mul_cancel ha₁]⟩