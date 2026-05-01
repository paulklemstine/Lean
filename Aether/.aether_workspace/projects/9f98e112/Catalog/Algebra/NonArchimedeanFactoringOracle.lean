import Mathlib

/-! # Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors integers by analyzing the Newton polygon
of a polynomial over ℚ_p.

## Main results

* `pAdic_factoring_oracle_composite` — every composite `n > 1` factors non-trivially.
* `pAdic_factoring_oracle_dichotomy` — every `n > 1` is prime or factors non-trivially.

## Note on the original statement

The original statement
```
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```
is **false**: any prime `n > 1` (e.g. `n = 2`) is a counterexample, since it cannot
be written as a product of two factors each exceeding 1.

The corrected versions below add the hypothesis that `n` is composite, or state the
prime-vs-composite dichotomy.
-/

/-
Every composite number `n > 1` admits a non-trivial factorization.
-/
theorem pAdic_factoring_oracle_composite (n : ℕ) (hn : n > 1) (hnp : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hnp with ⟨ a, ha₁, ha₂ ⟩ ; exact ⟨ a, n / a, by rw [ Nat.mul_div_cancel' ha₁ ], by nlinarith, by nlinarith [ Nat.div_mul_cancel ha₁ ] ⟩

/-
Every natural number `n > 1` is either prime or admits a non-trivial factorization.
-/
theorem pAdic_factoring_oracle_dichotomy (n : ℕ) (hn : n > 1) :
    Nat.Prime n ∨ ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  by_contra h;
  exact h <| Or.inr <| by exact pAdic_factoring_oracle_composite n hn <| fun h' => h <| Or.inl h';