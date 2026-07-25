import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over ℚ_p.

## Mathematical Concept

Use Hensel's lemma and p-adic valuation to construct a factoring oracle.

## Note on the Original Statement

The original theorem claimed that every `n > 1` can be written as `a * b` with
`a > 1` and `b > 1`. This is false for prime numbers (e.g., `n = 2`).
The corrected version adds the hypothesis that `n` is not prime (i.e., `n` is composite).
-/

/-
The original theorem statement is false: it claims every n > 1 can be written as
   a product a * b with both a > 1 and b > 1. This fails for prime numbers.
   For example, n = 2 is prime and cannot be factored non-trivially.

theorem pAdic_factoring_oracle_original {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry

Corrected version: A composite number (n > 1 and not prime) admits a non-trivial
factorization into two factors both greater than 1. The p-adic parameter is retained
for consistency with the original signature but is not needed for the proof.

The key insight is that `¬ Nat.Prime n` combined with `n > 1` means `n` is composite
by definition, and Mathlib provides `Nat.exists_prime_and_dvd` and related machinery
for extracting factors.
-/
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ n.Prime) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n / k, by rw [ Nat.mul_div_cancel' hk₁ ], Nat.one_lt_iff_ne_zero_and_ne_one.2 ⟨ by aesop_cat, by aesop_cat ⟩, by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩