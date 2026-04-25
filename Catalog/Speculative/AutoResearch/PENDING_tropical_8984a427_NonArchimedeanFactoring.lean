import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over Q_p.

Mathematical Concept: Use Hensel's lemma and p-adic valuation to construct
a factoring oracle.
-/

/-
The original statement is **false**: it claims every n > 1 is composite, but primes
(e.g., n = 2) cannot be written as a product a * b with a > 1 and b > 1.

```
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  sorry
```

**Corrected version below**: We add the hypothesis that n is *not* prime, i.e., n is composite.
Under that additional assumption the conclusion holds and captures the intended "factoring oracle"
idea: given a composite number, one can always extract a non-trivial factorization.
-/
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n / k, by rw [ Nat.mul_div_cancel' hk₁ ], Nat.one_lt_iff_ne_zero_and_ne_one.2 ⟨ by aesop_cat, by aesop_cat ⟩, by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩