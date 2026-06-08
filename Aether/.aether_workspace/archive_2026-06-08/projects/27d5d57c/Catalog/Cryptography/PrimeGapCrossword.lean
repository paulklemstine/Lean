/-
# Prime Gap Crossword: Modular Constraints and Forcing Patterns

This module develops the theory of prime gap constraints viewed through
modular arithmetic. The key insight is that consecutive prime gaps are
not independent — they satisfy rigid residue constraints that dramatically
reduce the space of admissible gap sequences.

## Main results

1. **No prime triple in AP(2)**: The only three consecutive primes forming
   an arithmetic progression with common difference 2 are (3, 5, 7).

2. **Gap mod 6 constraint**: For primes > 3, gaps are ≡ 0, 2, or 4 mod 6.

3. **Three-prime span theorem**: Modular structure of non-adjacent prime gaps.

4. **Generalized triple constraint**: AP of 3 primes with common diff d
   requires 3 ∣ d unless a term equals 3.

5. **Residue exclusion principle**: Euler totient gives coprime counting.

## Novel definitions

- `GapConstraintSystem`: modular constraint framework for gap sequences
- `ResidueExclusionChain`: tracks how sieve primes narrow gap space
- `CrosswordDeterminismConjecture`: formalization of gap predictability
-/

import Mathlib

open Finset Nat

namespace PrimeGapCrossword

/-! ## Core Definitions -/

/-- A gap constraint system over modulus M tracks which gap residues
    are admissible given sieve information. This is the fundamental
    algebraic object underlying the "prime crossword" metaphor. -/
structure GapConstraintSystem (M : ℕ) where
  /-- The sieve primes dividing M -/
  sievePrimes : Finset ℕ
  /-- All sieve primes are prime -/
  sieve_prime : ∀ q ∈ sievePrimes, Nat.Prime q
  /-- All sieve primes divide M -/
  sieve_dvd : ∀ q ∈ sievePrimes, q ∣ M
  /-- M is positive -/
  M_pos : 0 < M

/-- A residue exclusion chain tracks how each successive sieve prime
    eliminates gap candidates. -/
structure ResidueExclusionChain where
  /-- Sequence of sieve primes applied -/
  primes : List ℕ
  /-- Each is prime -/
  all_prime : ∀ q ∈ primes, Nat.Prime q
  /-- Survival counts after applying first k primes -/
  survivalCount : ℕ → ℕ

/-! ## Section 1: The Prime Triple Theorem -/

/-- Among any three values p, p+2, p+4, one is divisible by 3.
    This is the pigeonhole principle: the residues mod 3 of p, p+2, p+4
    cover all three classes {0, 1, 2}. -/
theorem exists_div3_in_ap2_triple (p : ℕ) :
    3 ∣ p ∨ 3 ∣ (p + 2) ∨ 3 ∣ (p + 4) := by omega

/-- **Prime Triple Theorem**: If p, p+2, p+4 are all prime, then p = 3.
    This shows the gap pattern [2,2] is uniquely realized — a fundamental
    constraint of the prime crossword. The proof uses the pigeonhole
    principle mod 3: among p, p+2, p+4, one must be divisible by 3,
    and if it's prime, it must equal 3. -/
theorem prime_triple_forces_three {p : ℕ}
    (hp : Nat.Prime p) (hp2 : Nat.Prime (p + 2)) (hp4 : Nat.Prime (p + 4)) :
    p = 3 := by
  have h3 := exists_div3_in_ap2_triple p
  rcases h3 with h | h | h
  · exact (hp.eq_one_or_self_of_dvd 3 h).elim (by omega) (by omega)
  · have h2 := hp2.eq_one_or_self_of_dvd 3 h; have := hp.two_le; omega
  · have h4 := hp4.eq_one_or_self_of_dvd 3 h; have := hp.two_le; omega

/-- The gap pattern [2, 2] identifies the unique triple (3, 5, 7). -/
theorem gap_pattern_22_unique {p q r : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hpq : q = p + 2) (hqr : r = q + 2) :
    p = 3 ∧ q = 5 ∧ r = 7 := by
  subst hpq; subst hqr
  have hr' : Nat.Prime (p + 4) := by ring_nf at hr ⊢; exact hr
  have h3 := prime_triple_forces_three hp hq hr'
  subst h3; decide

/-! ## Section 2: Gap Mod 6 Constraints -/

/-- For p > 3 prime, p mod 6 ∈ {1, 5}. -/
theorem prime_mod6_large {p : ℕ} (hp : Nat.Prime p) (hp3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
  have h2 : ¬(2 ∣ p) := by
    intro h; exact (hp.eq_one_or_self_of_dvd 2 h).elim (by omega) (by omega)
  have h3 : ¬(3 ∣ p) := by
    intro h; exact (hp.eq_one_or_self_of_dvd 3 h).elim (by omega) (by omega)
  omega

/-- **Gap Mod 6 Constraint**: For consecutive primes p < q with p > 3,
    the gap q - p has residue mod 6 in {0, 2, 4}. -/
theorem gap_mod6_constraint {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp3 : 3 < p) (hpq : p < q) :
    (q - p) % 6 = 0 ∨ (q - p) % 6 = 2 ∨ (q - p) % 6 = 4 := by
  have hq3 : 3 < q := by linarith
  have hp6 := prime_mod6_large hp hp3
  have hq6 := prime_mod6_large hq hq3
  omega

/-! ## Section 3: Three-Prime Span Theorem -/

/-- **Three-prime span**: For primes p < q < r with p > 3,
    r - p ≡ 0 (mod 6) iff p ≡ r (mod 6). -/
theorem three_prime_span_mod6 {p q r : ℕ}
    (hp : Nat.Prime p) (_hq : Nat.Prime q) (hr : Nat.Prime r)
    (hp3 : 3 < p) (hpq : p < q) (hqr : q < r) :
    (r - p) % 6 = 0 ↔ p % 6 = r % 6 := by
  have hpr : p < r := lt_trans hpq hqr
  have hr3 : 3 < r := by linarith
  have hp6 := prime_mod6_large hp hp3
  have hr6 := prime_mod6_large hr hr3
  omega

/-- **Gap pair sum bound**: For three consecutive primes p < q < r with p > 3,
    the span r - p is even and at least 4. -/
theorem gap_pair_sum_bound {p q r : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hp3 : 3 < p) (hpq : p < q) (hqr : q < r) :
    (r - p) % 2 = 0 ∧ 4 ≤ r - p := by
  constructor
  · have : p % 2 = 1 := by rcases hp.eq_two_or_odd with h | h <;> omega
    have : r % 2 = 1 := by rcases hr.eq_two_or_odd with h | h <;> omega
    omega
  · have hq3 : 3 < q := by rcases hq.eq_two_or_odd with h | h <;> omega
    have h1 : 2 ≤ q - p := by
      have : p % 2 = 1 := by rcases hp.eq_two_or_odd with h | h <;> omega
      have : q % 2 = 1 := by rcases hq.eq_two_or_odd with h | h <;> omega
      omega
    have h2 : 2 ≤ r - q := by
      have : q % 2 = 1 := by rcases hq.eq_two_or_odd with h | h <;> omega
      have : r % 2 = 1 := by rcases hr.eq_two_or_odd with h | h <;> omega
      omega
    omega

/-! ## Section 4: Generalized AP constraint -/

/-
**Generalized triple constraint**: If p, p+2d, p+4d are all prime
    and d > 0, then 3 ∣ d or one of the three terms equals 3.

    This is the key structural theorem: arithmetic progressions of primes
    with common difference coprime to 3 are length-limited by pigeonhole.
-/
theorem generalized_triple_constraint {p d : ℕ}
    (hp : Nat.Prime p) (hp2d : Nat.Prime (p + 2 * d)) (hp4d : Nat.Prime (p + 4 * d))
    (_hd : 0 < d) :
    3 ∣ d ∨ p = 3 ∨ p + 2 * d = 3 ∨ p + 4 * d = 3 := by
  by_contra h;
  -- By the pigeonhole principle, one of p, p+2d, p+4d must be divisible by 3.
  have h_div3 : 3 ∣ p ∨ 3 ∣ (p + 2 * d) ∨ 3 ∣ (p + 4 * d) := by
    grind;
  simp_all +decide [ Nat.Prime.dvd_iff_eq ]

/-! ## Section 5: Residue Exclusion Principle -/

/-
The number of residues in {0, ..., q-1} coprime to prime q is q - 1.
-/
theorem coprime_residues_count (q : ℕ) (hq : Nat.Prime q) :
    ((Finset.range q).filter (fun r => Nat.Coprime r q)).card = q - 1 := by
  convert Nat.totient_prime hq using 1;
  exact congr_arg Finset.card ( Finset.filter_congr fun x hx => by rw [ Nat.coprime_comm ] )

/-
**Exclusion composition (CRT)**: For distinct primes p, q, the number
    of residues mod pq coprime to both is (p-1)(q-1).
    This is the multiplicative heart of the sieve.
-/
theorem exclusion_composition (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    ((Finset.range (p * q)).filter (fun r => Nat.Coprime r p ∧ Nat.Coprime r q)).card
    = (p - 1) * (q - 1) := by
  -- This is the multiplicative property of Euler's totient function for distinct primes.
  have h_totient : Nat.totient (p * q) = (p - 1) * (q - 1) := by
    rw [ Nat.totient_mul, Nat.totient_prime hp, Nat.totient_prime hq ];
    simpa [ hpq ] using Nat.coprime_primes hp hq;
  convert h_totient using 1;
  congr 1 with x ; simp +decide [ Nat.coprime_comm, Nat.coprime_mul_iff_right ]

/-! ## Section 6: Bertrand-enhanced gap analysis -/

/-
Bertrand's postulate for primes: every prime p has a prime in (p, 2p).
-/
theorem bertrand_for_primes (p : ℕ) (hp : Nat.Prime p) :
    ∃ q, Nat.Prime q ∧ p < q ∧ q < 2 * p := by
  have := Nat.exists_prime_lt_and_le_two_mul p;
  obtain ⟨ q, hq₁, hq₂, hq₃ ⟩ := this hp.ne_zero; exact ⟨ q, hq₁, hq₂, lt_of_le_of_ne hq₃ fun h => by have := Nat.Prime.eq_two_or_odd hq₁; aesop ⟩ ;

/-! ## Section 7: Primorial and totient -/

/-- The primorial: product of all primes up to n. -/
noncomputable def primorial : ℕ → ℕ
  | 0 => 1
  | n + 1 => if Nat.Prime (n + 1) then (n + 1) * primorial n else primorial n

theorem primorial_pos : ∀ n, 0 < primorial n := by
  intro n; induction n with
  | zero => simp [primorial]
  | succ n ih => simp [primorial]; split <;> [positivity; exact ih]

/-- The primorial has positive totient (since it's positive). -/
theorem totient_primorial_pos (n : ℕ) :
    0 < Nat.totient (primorial n) :=
  (Nat.totient_pos).mpr (primorial_pos n)

/-! ## Section 8: The Crossword Determinism Conjecture -/

/-- **Crossword Determinism Conjecture**: For sufficiently long gap history,
    the sieve constraints mod 30 = 2·3·5 leave at most C admissible
    next-gap values.

    **Testable prediction**: Compute the average number of sieve-admissible
    next gaps mod 30 for all primes up to 10^8. The conjecture predicts
    this average is bounded by a constant ≤ 8 (the number of coprime
    residues mod 30).

    This can be DISPROVED by exhibiting a family of gap histories of
    unbounded length where the number of admissible next gaps remains ≥ 8
    (i.e., the constraints never help). -/
def CrosswordDeterminismConjecture : Prop :=
  ∃ C : ℕ, C ≤ 8 ∧ ∀ p : ℕ, Nat.Prime p → p > 30 →
    ∀ (prevGaps : List ℕ), prevGaps.length ≥ 5 →
      ((Finset.Icc 2 30).filter fun g =>
        g % 2 = 0 ∧ Nat.Coprime (p + g) 30).card ≤ C

end PrimeGapCrossword