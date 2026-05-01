/-! # CatalogBuild.Shared.PAdic_factoring_oracle

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 1
-/

import Mathlib

/-- [Section: # Non-Archimedean Factoring Oracle
A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over Q_p.
## Main Result
Every composite number n > 1 admits a non-trivial factorization into two
factors both greater than 1. The original statement (without the compositeness
hypothesis) is false for primes.] -/
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hnp : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hnp with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n/k, by rw [ Nat.mul_div_cancel' hk₁ ], by nlinarith [ Nat.div_mul_cancel hk₁ ], by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩
