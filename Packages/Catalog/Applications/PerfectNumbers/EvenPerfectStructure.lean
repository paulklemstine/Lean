import Archive.Wiedijk100Theorems.PerfectNumbers
import Applications.PerfectNumbers.AbundancyIndex

/-!
# Structure of even perfect numbers

This file states the Euclid--Euler theorem both in Mathlib's `mersenne` notation
and in the traditional form `2^(p-1) * (2^p-1)`.  The final results connect
that structure theorem to the abundancy-index framework.
-/

open ArithmeticFunction
open scoped sigma

namespace PerfectNumbers

/-- Euclid--Euler in `mersenne` notation.  This is the structural starting point
for the traditional exponent formulation below. -/
theorem evenPerfect_iff_mersenneForm {n : ℕ} :
    Even n ∧ n.Perfect ↔
      ∃ k : ℕ, (mersenne (k + 1)).Prime ∧ n = 2 ^ k * mersenne (k + 1) := by
  exact Theorems100.Nat.even_and_perfect_iff

/-- **Euclid--Euler theorem, traditional formulation.**  A natural number is
both even and perfect exactly when it is `2^(p-1) * (2^p-1)` for an exponent
`p` whose Mersenne number is prime. -/
theorem evenPerfect_iff_twoPow_mul_mersennePrime {n : ℕ} :
    Even n ∧ n.Perfect ↔
      ∃ p : ℕ, 0 < p ∧ (2 ^ p - 1).Prime ∧
        n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  constructor
  · intro h
    obtain ⟨k, hkPrime, rfl⟩ := evenPerfect_iff_mersenneForm.mp h
    refine ⟨k + 1, Nat.succ_pos k, ?_, ?_⟩
    · simpa [mersenne] using hkPrime
    · simp [mersenne]
  · rintro ⟨p, hp, hPrime, rfl⟩
    have hpred : p - 1 + 1 = p := Nat.sub_add_cancel hp
    apply evenPerfect_iff_mersenneForm.mpr
    refine ⟨p - 1, ?_, ?_⟩
    · simpa [hpred, mersenne] using hPrime
    · simp [hpred, mersenne]

/-- In the Euclid--Euler representation, the exponent is itself prime. -/
theorem exponent_prime_of_evenPerfect {n : ℕ} (h : Even n ∧ n.Perfect) :
    ∃ p : ℕ, p.Prime ∧ (2 ^ p - 1).Prime ∧
      n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  obtain ⟨p, hp, hM, hn⟩ := evenPerfect_iff_twoPow_mul_mersennePrime.mp h
  refine ⟨p, ?_, hM, hn⟩
  apply Nat.Prime.of_mersenne
  simpa [mersenne] using hM

/-- An even perfect number has exactly two distinct prime factors: `2` and
its associated Mersenne prime. -/
theorem evenPerfect_card_primeFactors {n : ℕ} (h : Even n ∧ n.Perfect) :
    n.primeFactors.card = 2 := by
  obtain ⟨p, hp, hM, rfl⟩ := exponent_prime_of_evenPerfect h
  have hp2 : 2 ≤ p := hp.two_le
  have hpred : p - 1 ≠ 0 := by omega
  rw [Nat.primeFactors_mul (pow_ne_zero _ (by norm_num)) hM.ne_zero,
    Nat.primeFactors_prime_pow hpred Nat.prime_two, hM.primeFactors]
  have hodd : Odd (2 ^ p - 1) := by
    simpa [mersenne] using (show Odd (mersenne p) by simp [hp.ne_zero])
  have hne : 2 ^ p - 1 ≠ 2 := by
    intro heq
    rw [heq] at hodd
    norm_num at hodd
  simp [Ne.symm hne]

/-- The Euclid--Euler representation is equivalently a classification by
abundancy index: among even positive numbers, abundancy `2` has exactly the
Mersenne-prime forms. -/
theorem even_abundancy_eq_two_iff {n : ℕ} (hn : 0 < n) :
    Even n ∧ abundancy n = 2 ↔
      ∃ p : ℕ, 0 < p ∧ (2 ^ p - 1).Prime ∧
        n = 2 ^ (p - 1) * (2 ^ p - 1) := by
  rw [abundancy_eq_two_iff_perfect hn]
  exact evenPerfect_iff_twoPow_mul_mersennePrime

/-- The first four Mersenne-prime exponents give the classical even perfect
numbers `6`, `28`, `496`, and `8128`.  This is kernel-checked small-case
evidence obtained from the general classification rather than exhaustive search. -/
theorem first_four_evenPerfect :
    (Even 6 ∧ Nat.Perfect 6) ∧
    (Even 28 ∧ Nat.Perfect 28) ∧
    (Even 496 ∧ Nat.Perfect 496) ∧
    (Even 8128 ∧ Nat.Perfect 8128) := by
  constructor
  · apply evenPerfect_iff_twoPow_mul_mersennePrime.mpr
    exact ⟨2, by norm_num, by norm_num, by norm_num⟩
  constructor
  · apply evenPerfect_iff_twoPow_mul_mersennePrime.mpr
    exact ⟨3, by norm_num, by norm_num, by norm_num⟩
  constructor
  · apply evenPerfect_iff_twoPow_mul_mersennePrime.mpr
    exact ⟨5, by norm_num, by norm_num, by norm_num⟩
  · apply evenPerfect_iff_twoPow_mul_mersennePrime.mpr
    exact ⟨7, by norm_num, by norm_num, by norm_num⟩

/-- Every number in Euclid--Euler form has abundancy index exactly `2`. -/
theorem abundancy_two_of_mersennePrime {p : ℕ} (hp : 0 < p)
    (hM : (2 ^ p - 1).Prime) :
    abundancy (2 ^ (p - 1) * (2 ^ p - 1)) = 2 := by
  have hpos : 0 < 2 ^ (p - 1) * (2 ^ p - 1) :=
    Nat.mul_pos (pow_pos (by decide) _) hM.pos
  apply (abundancy_eq_two_iff_perfect hpos).mpr
  exact (evenPerfect_iff_twoPow_mul_mersennePrime.mpr
    ⟨p, hp, hM, rfl⟩).2

end PerfectNumbers