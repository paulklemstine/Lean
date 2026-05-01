/-! # CatalogBuild.Cryptography.Factoring.PadicFactoring

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 2
-/

import Mathlib

/-- [Section: # p-Adic Factoring Oracle
## Overview
This file formalizes a "p-adic factoring oracle" theorem. The original statement claimed
that every natural number n > 1 admits a nontrivial factorization a * b = n with a > 1
and b > 1. This is **false** for prime numbers.
We provide:
1. `pAdic_factoring_oracle_false` — a formal disproof of the original (false) statement.
2. `pAdic_factoring_oracle_corrected` — the corrected theorem: every *composite* number
n > 1 has a nontrivial factorization.
## Mathematical context
The original problem was motivated by p-adic methods (Newton polygons, Hensel's lemma)
for integer factorization. While such methods are powerful in algorithmic number theory,
the existence of a nontrivial factorization for composite numbers is a purely
number-theoretic fact that does not require p-adic machinery.] -/
theorem pAdic_factoring_oracle_false :
    ¬ (∀ (p : ℕ) [Fact p.Prime] (n : ℕ), n > 1 →
      ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1) := by
  simp +zetaDelta at *;
  exact ⟨ ⟨ 2, ⟨ Nat.prime_two ⟩ ⟩, 2, by decide, fun a b h₁ h₂ => by nlinarith ⟩


theorem pAdic_factoring_oracle_corrected {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1 := by
  rcases Nat.exists_dvd_of_not_prime2 hn hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, n / k, by rw [ Nat.mul_div_cancel' hk₁ ], Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩, by nlinarith [ Nat.div_mul_cancel hk₁ ] ⟩
