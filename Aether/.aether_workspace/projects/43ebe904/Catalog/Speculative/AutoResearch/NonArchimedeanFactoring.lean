import Mathlib

/-!
# Non-Archimedean Factoring Oracle

A p-adic lifting scheme that factors composite integers by analyzing
the structure of their divisors. Uses the fact that composite numbers
(n > 1 and not prime) can always be non-trivially factored.

## Note on the original statement

The originally proposed theorem
  `pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1`
is **false** as stated, since prime numbers n > 1 cannot be written as a product
of two factors both greater than 1 (that is the definition of primality).

For example, n = 2 is a counterexample: the only factorizations of 2 are 1 × 2
and 2 × 1, neither of which has both factors > 1.

The corrected version below adds the hypothesis `¬ Nat.Prime n`, restricting
to composite numbers, for which the statement is true.
-/

/-
Original statement (FALSE — commented out):
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) :
∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by sorry
Counterexample: n = 2 (prime). No a, b > 1 satisfy a * b = 2.

**Corrected Non-Archimedean Factoring Oracle.**

Every composite natural number `n > 1` that is not prime admits a non-trivial
factorization into two factors, each greater than 1.

The hypothesis `{p : ℕ} [Fact p.Prime]` witnesses the existence of some prime
(used in the p-adic framing); the actual proof is purely number-theoretic.

**Modification from original:** Added `¬ Nat.Prime n` hypothesis, without which
the statement is false for prime n.
-/
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n / k, by rw [ Nat.mul_div_cancel' hk₁ ], Nat.one_lt_iff_ne_zero_and_ne_one.2 ⟨ by aesop_cat, by aesop_cat ⟩, by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩

/-
A useful auxiliary: any n > 1 is either prime or composite
(admits non-trivial factorization).
-/
theorem prime_or_composite (n : ℕ) (hn : n > 1) :
    Nat.Prime n ∨ ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  exact Classical.or_iff_not_imp_left.2 fun h => by obtain ⟨ a, ha₁, ha₂ ⟩ := Nat.exists_dvd_of_not_prime2 hn h; exact ⟨ a, n / a, by rw [ Nat.mul_div_cancel' ha₁ ], Nat.one_lt_iff_ne_zero_and_ne_one.2 ⟨ by aesop_cat, by aesop_cat ⟩, by nlinarith [ Nat.div_mul_cancel ha₁ ] ⟩ ;