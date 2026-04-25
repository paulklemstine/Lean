import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over ℚ_p.

Mathematical Concept: Use Hensel's lemma and p-adic valuation to construct
a factoring oracle.
-/

/-
The original statement is false: primes n > 1 cannot be written as a * b
   with both a, b > 1. For example, n = 2 is a counterexample.
   We comment it out and provide a corrected version below.

theorem pAdic_factoring_oracle_ORIGINAL {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry

Corrected version: A composite number n > 1 (i.e., not prime) can always be
non-trivially factored into two factors both greater than 1. The `p`-adic context
is retained in the hypotheses for compatibility with the original statement,
though the proof is purely number-theoretic.

The key insight is that `¬ Nat.Prime n` combined with `n > 1` means `n` is composite,
so by definition it has a non-trivial divisor.
-/
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n / k, by rw [ Nat.mul_div_cancel' hk₁ ], by nlinarith [ Nat.div_mul_cancel hk₁ ], by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩