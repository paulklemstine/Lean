import Mathlib

/-!
# Perfect Number Theory and σ₁ Classification (B7, E19)

We formalize the theory of perfect, abundant, and deficient numbers
using the divisor sum function σ₁. This extends the divisor function library
with classification results and connects to the σ₁ approximation question.

## Main Results

* `euclid_euler_direction` — If 2^(p-1)(2^p - 1) with 2^p - 1 prime, then perfect
* `sigma1_multiplicative` — σ₁ is multiplicative
* `sigma1_power_of_two` — σ₁(2^n) = 2^(n+1) - 1
* `mersenne_prime_perfect` — Mersenne primes give even perfect numbers
-/

set_option maxHeartbeats 3200000

open Nat BigOperators Finset

noncomputable def σ₁ (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

/-- σ₁ is multiplicative for coprime arguments. -/
theorem sigma1_mult (m n : ℕ) (h : Nat.Coprime m n) :
    σ₁ (m * n) = σ₁ m * σ₁ n := by
  unfold σ₁; exact Coprime.sum_divisors_mul h

/-
σ₁(2^n) = 2^(n+1) - 1.
-/
theorem sigma1_pow_two (n : ℕ) : σ₁ (2 ^ n) = 2 ^ (n + 1) - 1 := by
  unfold σ₁; simp +decide [ Nat.geomSum_eq ] ;

/-
If M_p = 2^p - 1 is prime, then σ₁(M_p) = 2^p.
-/
theorem sigma1_mersenne_prime (p : ℕ) (hp : Nat.Prime (2 ^ p - 1)) (hp2 : 1 ≤ p) :
    σ₁ (2 ^ p - 1) = 2 ^ p := by
  unfold σ₁; simp +decide [ *, Nat.sum_divisors_eq_sum_properDivisors_add_self ] ;
  rw [ Nat.sub_add_cancel ( Nat.one_le_pow _ _ ( by decide ) ) ]

/-
The Euclid direction of the Euclid-Euler theorem:
    If 2^p - 1 is prime, then 2^(p-1) * (2^p - 1) is perfect.
-/
theorem euclid_perfect (p : ℕ) (hp : 2 ≤ p)
    (hm : Nat.Prime (2 ^ p - 1)) :
    σ₁ (2 ^ (p - 1) * (2 ^ p - 1)) = 2 * (2 ^ (p - 1) * (2 ^ p - 1)) := by
  rw [ sigma1_mult, sigma1_pow_two, sigma1_mersenne_prime ];
  · cases p <;> norm_num [ pow_succ' ] at * ; ring;
  · assumption;
  · grind;
  · exact Nat.Coprime.pow_left _ ( Nat.prime_two.coprime_iff_not_dvd.mpr <| by simpa [ ← even_iff_two_dvd, Nat.one_le_iff_ne_zero, parity_simps ] using by linarith )

/-- σ₁(1) = 1. -/
theorem sigma1_one : σ₁ 1 = 1 := by simp [σ₁]

/-- σ₁(p) = p + 1 for prime p. -/
theorem sigma1_prime (p : ℕ) (hp : Nat.Prime p) : σ₁ p = p + 1 := by
  simp +decide [σ₁]; rw [hp.sum_divisors, add_comm]

/-
For n > 1, σ₁(n) > n (since 1 and n are both divisors).
-/
theorem sigma1_gt (n : ℕ) (hn : 1 < n) : n < σ₁ n := by
  unfold σ₁; rw [ Finset.sum_eq_sum_diff_singleton_add ( Nat.mem_divisors_self n hn.ne_bot ) ] ; linarith [ Finset.single_le_sum ( fun x ( hx : x ∈ n.divisors \ { n } ) ↦ Nat.zero_le x ) ( Finset.mem_sdiff.mpr ⟨ Nat.mem_divisors.mpr ⟨ one_dvd n, by linarith ⟩, by aesop ⟩ : 1 ∈ n.divisors \ { n } ) ] ;

/-
σ₁(n) ≥ n + 1 for n ≥ 2.
-/
theorem sigma1_ge_succ (n : ℕ) (hn : 1 < n) : n + 1 ≤ σ₁ n := by
  exact Nat.succ_le_of_lt ( sigma1_gt n hn )

/-
Primes are deficient: σ₁(p) = p + 1 < 2p.
-/
theorem prime_deficient (p : ℕ) (hp : Nat.Prime p) : σ₁ p < 2 * p := by
  rw [ show σ₁ p = ∑ d ∈ Nat.divisors p, d from rfl, hp.sum_divisors ] ; linarith [ hp.two_le ]

/-
12 is abundant: σ₁(12) = 28 > 24.
-/
theorem twelve_abundant : 2 * 12 < σ₁ 12 := by
  decide +kernel

/-
σ₁ is weakly multiplicative: σ₁(mn) ≥ σ₁(m) for m | mn.
-/
theorem sigma1_monotone_dvd (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    σ₁ m ≤ σ₁ (m * n) := by
  exact Finset.sum_le_sum_of_subset ( fun x hx => Nat.mem_divisors.mpr ⟨ dvd_mul_of_dvd_left ( Nat.dvd_of_mem_divisors hx ) _, by positivity ⟩ )