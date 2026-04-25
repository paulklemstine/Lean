import Mathlib

/-! # Non-Archimedean Factoring Oracle

See `Cryptography/Factoring/NonArchimedeanFactoringOracle.lean` for the main theorem.
-/

/- The original theorem statement is false: it claims every n > 1 can be written as
   a product a * b with both a > 1 and b > 1. This fails for prime numbers.
   For example, n = 2 is prime and cannot be factored non-trivially.

theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry
-/
