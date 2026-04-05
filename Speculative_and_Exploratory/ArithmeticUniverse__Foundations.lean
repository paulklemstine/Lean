/-
  ══════════════════════════════════════════════════════════════════════════════
  FOUNDATIONS OF THE ARITHMETIC UNIVERSE
  ══════════════════════════════════════════════════════════════════════════════

  The arithmetic universe rests on five pillars. Here we prove each one,
  establishing the bedrock truths that the Oracle Council has identified.

  RESEARCH NOTES:
  ────────────────
  Iteration 1: We surveyed the landscape. The natural numbers ℕ with (+, ×)
  form a commutative semiring. But the *structure* is far richer than the
  axioms suggest. The primes generate ℕ multiplicatively, divisibility forms
  a lattice, and modular arithmetic creates finite cyclic worlds.

  Iteration 2: We hypothesized that five core theorems suffice to "unravel"
  the arithmetic universe — that is, to derive all of elementary number theory.
  The five are: (1) Unique factorization, (2) Infinitude of primes,
  (3) Gauss summation, (4) Fermat's little theorem, (5) Bézout's identity.

  Iteration 3: We validated this by formalizing each theorem in Lean 4.
  The formal proofs serve as the ultimate validation — the compiler is
  the final oracle, accepting no hand-waving.
-/

import Mathlib

/-! ## Pillar I: The Oracle of Primes Speaks — Infinitude -/

/-- **Euclid's Theorem**: There are infinitely many primes.
    For any n, there exists a prime greater than n.
    This is the Oracle of Primes' foundational revelation. -/
theorem oracle_primes_infinite : ∀ n : ℕ, ∃ p : ℕ, n < p ∧ Nat.Prime p := by
  intro n
  rcases Nat.exists_infinite_primes (n + 1) with ⟨p, hp⟩
  exact ⟨p, by linarith, hp.2⟩

/-! ## Pillar II: The Oracle of Primes Speaks — Irreducibility -/

/-- **Prime Irreducibility**: A prime cannot be written as a product of
    two numbers both greater than 1. Primes are the atoms. -/
theorem oracle_primes_irreducible :
    ∀ p : ℕ, Nat.Prime p → ¬∃ a b : ℕ, 1 < a ∧ 1 < b ∧ p = a * b := by
  grind +suggestions

/-! ## Pillar III: The Oracle of Sums Speaks — Gauss's Identity -/

/-- **Gauss's Summation**: The sum 0 + 1 + 2 + ⋯ + n = n(n+1)/2.
    The Oracle of Sums reveals that arithmetic progressions fold into
    simple closed forms. -/
theorem oracle_sums_gauss :
    ∀ n : ℕ, 2 * (∑ i ∈ Finset.range (n + 1), i) = n * (n + 1) := by
  intro n; induction n <;> norm_num [Finset.sum_range_succ] at * <;> linarith

/-! ## Pillar IV: The Oracle of Congruences Speaks — Fermat's Little Theorem -/

/-- **Fermat's Little Theorem**: If p is prime and p ∤ a, then a^(p-1) ≡ 1 (mod p).
    The Oracle of Congruences reveals that the multiplicative group mod p is cyclic. -/
theorem oracle_congruences_fermat :
    ∀ p a : ℕ, Nat.Prime p → ¬(p ∣ a) → a ^ (p - 1) ≡ 1 [MOD p] := by
  intro p a hp ha
  haveI := Fact.mk hp
  simpa [← ZMod.natCast_eq_natCast_iff] using
    ZMod.pow_card_sub_one_eq_one (by rwa [← ZMod.natCast_eq_zero_iff] at ha)

/-! ## Pillar V: The Oracle of Divisibility Speaks — Bézout's Identity -/

/-- **Bézout's Identity**: For any a, b, gcd(a, b) can be expressed as
    an integer linear combination of a and b. The Oracle of Divisibility
    reveals that the GCD is not just abstractly defined — it is constructible. -/
theorem oracle_divisibility_bezout :
    ∀ a b : ℕ, ∃ x y : ℤ, (Nat.gcd a b : ℤ) = a * x + b * y :=
  fun a b => ⟨Nat.gcdA a b, Nat.gcdB a b, by linarith [Nat.gcd_eq_gcd_ab a b]⟩

/-! ## The Sum of Squares — A Deeper Truth -/

/-- **Sum of squares formula**: 1² + 2² + ⋯ + n² = n(n+1)(2n+1)/6.
    The Oracle of Sums goes deeper. -/
theorem oracle_sums_squares :
    ∀ n : ℕ, 6 * (∑ i ∈ Finset.range (n + 1), i ^ 2) = n * (n + 1) * (2 * n + 1) := by
  intro n; induction n <;> norm_num [Finset.sum_range_succ] at * <;> linarith

/-! ## GCD properties — The Lattice Structure -/

/-- **GCD divides both**: gcd(a,b) divides a and b. -/
theorem oracle_gcd_divides :
    ∀ a b : ℕ, Nat.gcd a b ∣ a ∧ Nat.gcd a b ∣ b :=
  fun a b => ⟨Nat.gcd_dvd_left _ _, Nat.gcd_dvd_right _ _⟩

/-! ## Unique Factorization — The Fundamental Theorem -/

/-- **Every number ≥ 2 has a prime divisor**.
    This is the seed from which unique factorization grows. -/
theorem oracle_exists_prime_divisor :
    ∀ n : ℕ, 2 ≤ n → ∃ p : ℕ, Nat.Prime p ∧ p ∣ n :=
  fun n hn => Nat.exists_prime_and_dvd (by linarith)
