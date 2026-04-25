import Mathlib

/-!
# Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors composite integers. The original statement claimed
that every n > 1 can be written as a product of two factors both greater than 1, but this
is false since prime numbers exist (e.g., n = 2 cannot be so factored).

We provide a corrected version: every **composite** number n > 1 admits such a factorization.
-/

/- The original statement is false: it claims every n > 1 is composite, but primes exist.
   For example, n = 2 is prime and cannot be written as a * b with a > 1 and b > 1.

theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
  ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
sorry
-/

/-- Corrected version: every composite number greater than 1 can be written as
    a product of two factors, each greater than 1. This captures the true content
    of what a "factoring oracle" would provide. -/
theorem pAdic_factoring_oracle_corrected (n : ℕ) (hn : n > 1) (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨k, hk₁, hk₂⟩
  exact ⟨k, n / k, by rw [Nat.mul_div_cancel' hk₁],
    by nlinarith [Nat.div_mul_cancel hk₁], by nlinarith [Nat.div_mul_cancel hk₁]⟩

/-- A counterexample showing the original statement is false: 2 is prime and
    cannot be written as a product of two factors both greater than 1. -/
theorem pAdic_factoring_oracle_counterexample :
    ¬ (∃ a b : ℕ, a * b = 2 ∧ a > 1 ∧ b > 1) :=
  fun ⟨a, b, h₁, h₂, h₃⟩ => by nlinarith
