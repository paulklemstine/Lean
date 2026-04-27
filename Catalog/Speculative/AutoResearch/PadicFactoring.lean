import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over Q_p.

## Main Results

The original theorem statement `pAdic_factoring_oracle` is **false** as stated:
it claims every n > 1 admits a non-trivial factorization, which fails for primes.

We provide:
- `pAdic_factoring_oracle_corrected`: the corrected version for composite numbers
- `pAdic_factoring_oracle_false`: a formal proof that the original statement is false
-/

/-
The original theorem statement is FALSE. For any prime p > 1, there do not exist
   a, b > 1 with a * b = p. For example, n = 2 is a counterexample: the only
   factorizations of 2 are 1 × 2 and 2 × 1, neither of which has both factors > 1.

theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry

Corrected version: A composite number (n > 1 and not prime) admits a non-trivial
factorization into two factors, each greater than 1. This is the correct formalization
of the idea that a "factoring oracle" can split composite numbers.

The hypothesis `¬ Nat.Prime n` is the essential correction — the original statement
claimed this for all n > 1, which fails for primes.
-/
theorem pAdic_factoring_oracle_corrected {p : ℕ} [Fact p.Prime]
    (n : ℕ) (hn : n > 1) (hcomp : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hcomp with ⟨ k, hk1, hk2 ⟩ ; exact ⟨ k, n / k, Nat.mul_div_cancel' hk1, by nlinarith [ Nat.div_mul_cancel hk1 ], by nlinarith [ Nat.div_mul_cancel hk1 ] ⟩

/-
The original statement is disprovable: n = 2 is a counterexample.
-/
theorem pAdic_factoring_oracle_false :
    ¬ ∀ (p : ℕ) [Fact p.Prime] (n : ℕ), n > 1 →
      ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  simp +zetaDelta at *;
  exact ⟨ ⟨ 2, ⟨ Nat.prime_two ⟩ ⟩, 2, by decide, fun a b h₁ h₂ => by nlinarith ⟩