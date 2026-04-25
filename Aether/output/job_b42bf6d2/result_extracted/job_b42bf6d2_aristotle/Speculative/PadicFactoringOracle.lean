import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over Q_p.

## Mathematical Concept
Use Hensel's lemma and p-adic valuation to construct a factoring oracle.

## Note on the original statement
The original theorem `pAdic_factoring_oracle` claimed that **every** `n > 1` can be
written as `a * b` with `a > 1` and `b > 1`. This is false for prime numbers:
e.g. `n = 2` has no such factorization. We comment out the original and provide
a corrected version for **composite** numbers.
-/

/-- The original statement is **false**: it claims every `n > 1` factors as `a * b` with
`a > 1` and `b > 1`, but this fails for every prime number (e.g. `n = 2`).
A prime `p` satisfies `p > 1` yet its only factorizations are `1 * p` and `p * 1`,
neither of which has both factors `> 1`. -/

/-
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
sorry

**Corrected statement**: A composite number `n` (i.e. `n > 1` and `¬ n.Prime`)
admits a nontrivial factorization into two factors both strictly greater than 1.
This is the mathematically correct version of the "factoring oracle" idea:
for composite numbers, a nontrivial splitting always exists.
-/
theorem pAdic_factoring_oracle_corrected (n : ℕ) (hn : n > 1) (hc : ¬ n.Prime) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n / k, by rw [ Nat.mul_div_cancel' hk₁ ], by nlinarith, by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩ ;