/-! # CatalogBuild.Speculative.ArithmeticUniverse.Foundations

Auto-generated from theorem catalog database.
Domain: Speculative/ArithmeticUniverse
Declarations: 6
-/

import Mathlib

/-- **Prime Irreducibility**: A prime cannot be written as a product of
two numbers both greater than 1. Primes are the atoms. -/
theorem oracle_primes_irreducible :
    ∀ p : ℕ, Nat.Prime p → ¬∃ a b : ℕ, 1 < a ∧ 1 < b ∧ p = a * b := by
  grind +suggestions



/-- **Gauss's Summation**: The sum 0 + 1 + 2 + ⋯ + n = n(n+1)/2.
The Oracle of Sums reveals that arithmetic progressions fold into
simple closed forms. -/
theorem oracle_sums_gauss :
    ∀ n : ℕ, 2 * (∑ i ∈ Finset.range (n + 1), i) = n * (n + 1) := by
  intro n; induction n <;> norm_num [Finset.sum_range_succ] at * <;> linarith



/-- **Fermat's Little Theorem**: If p is prime and p ∤ a, then a^(p-1) ≡ 1 (mod p).
The Oracle of Congruences reveals that the multiplicative group mod p is cyclic. -/
theorem oracle_congruences_fermat :
    ∀ p a : ℕ, Nat.Prime p → ¬(p ∣ a) → a ^ (p - 1) ≡ 1 [MOD p] := by
  intro p a hp ha
  haveI := Fact.mk hp
  simpa [← ZMod.natCast_eq_natCast_iff] using
    ZMod.pow_card_sub_one_eq_one (by rwa [← ZMod.natCast_eq_zero_iff] at ha)



/-- **Bézout's Identity**: For any a, b, gcd(a, b) can be expressed as
an integer linear combination of a and b. The Oracle of Divisibility
reveals that the GCD is not just abstractly defined — it is constructible. -/
theorem oracle_divisibility_bezout :
    ∀ a b : ℕ, ∃ x y : ℤ, (Nat.gcd a b : ℤ) = a * x + b * y :=
  fun a b => ⟨Nat.gcdA a b, Nat.gcdB a b, by linarith [Nat.gcd_eq_gcd_ab a b]⟩



/-- **Sum of squares formula**: 1² + 2² + ⋯ + n² = n(n+1)(2n+1)/6.
The Oracle of Sums goes deeper. -/
theorem oracle_sums_squares :
    ∀ n : ℕ, 6 * (∑ i ∈ Finset.range (n + 1), i ^ 2) = n * (n + 1) * (2 * n + 1) := by
  intro n; induction n <;> norm_num [Finset.sum_range_succ] at * <;> linarith



/-- **GCD divides both**: gcd(a,b) divides a and b. -/
theorem oracle_gcd_divides :
    ∀ a b : ℕ, Nat.gcd a b ∣ a ∧ Nat.gcd a b ∣ b :=
  fun a b => ⟨Nat.gcd_dvd_left _ _, Nat.gcd_dvd_right _ _⟩


