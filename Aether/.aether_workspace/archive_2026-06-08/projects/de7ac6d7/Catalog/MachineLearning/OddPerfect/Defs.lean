/-
# Odd Perfect Numbers: Definitions and Basic API

This file establishes the foundational definitions and basic lemmas for the
formal obstruction theory of odd perfect numbers.

## Main definitions

* `OddPerfect.sigma₁` — the sum-of-divisors function σ₁(n) = Σ_{d | n} d
* `OddPerfect.IsPerfect` — n is perfect iff σ₁(n) = 2n and n > 0
* `OddPerfect.IsOddPerfect` — n is an odd perfect number
* `OddPerfect.sigmaPP` — the prime-power sigma factor: 1 + p + p² + ⋯ + pᵃ
* `OddPerfect.rad` — the radical of n: product of distinct prime factors
-/
import Mathlib

open Finset Nat BigOperators

namespace OddPerfect

/-! ## Core Definitions -/

/-- The sum-of-divisors function σ₁(n) = Σ_{d | n} d. -/
noncomputable def sigma₁ (n : ℕ) : ℕ := n.divisors.sum id

/-- A natural number n > 0 is perfect if σ₁(n) = 2n. We include positivity
    in the definition to avoid the degenerate case n = 0. -/
def IsPerfect (n : ℕ) : Prop := sigma₁ n = 2 * n ∧ 0 < n

/-- A natural number is an odd perfect number if it is odd and perfect. -/
def IsOddPerfect (n : ℕ) : Prop := Odd n ∧ IsPerfect n

/-- The prime-power sigma factor: sigmaPP p a = 1 + p + p² + ⋯ + pᵃ.
    This equals σ₁(p^a) when p is prime. -/
def sigmaPP (p a : ℕ) : ℕ := ∑ i ∈ Finset.range (a + 1), p ^ i

/-- The radical of n: the product of its distinct prime divisors. -/
noncomputable def rad (n : ℕ) : ℕ := ∏ q ∈ n.factorization.support, q

/-! ## Basic sigma₁ properties -/

theorem sigma₁_eq_sum_divisors (n : ℕ) : sigma₁ n = n.divisors.sum id := rfl

theorem sigma₁_eq_arith (n : ℕ) : sigma₁ n = ArithmeticFunction.sigma 1 n := by
  simp [sigma₁, ArithmeticFunction.sigma_one_apply]

/-- σ₁ is multiplicative on coprime arguments. -/
theorem sigma₁_mul_coprime {a b : ℕ} (hcop : Nat.Coprime a b) :
    sigma₁ (a * b) = sigma₁ a * sigma₁ b := by
  simp only [sigma₁_eq_arith]
  exact ArithmeticFunction.isMultiplicative_sigma.map_mul_of_coprime hcop

theorem sigma₁_one : sigma₁ 1 = 1 := by
  simp [sigma₁]

theorem sigma₁_zero : sigma₁ 0 = 0 := by
  simp [sigma₁]

/-! ## sigmaPP properties -/

@[simp]
theorem sigmaPP_zero (p : ℕ) : sigmaPP p 0 = 1 := by
  simp [sigmaPP]

theorem sigmaPP_succ (p a : ℕ) : sigmaPP p (a + 1) = sigmaPP p a + p ^ (a + 1) := by
  simp [sigmaPP, Finset.sum_range_succ]

theorem sigmaPP_one (p : ℕ) : sigmaPP p 1 = 1 + p := by
  simp [sigmaPP, Finset.sum_range_succ]

theorem one_le_sigmaPP (p a : ℕ) : 1 ≤ sigmaPP p a := by
  have : sigmaPP p a ≥ p ^ 0 := Finset.single_le_sum (fun i _ => Nat.zero_le _)
    (Finset.mem_range.mpr (Nat.zero_lt_succ a))
  simp at this; omega

theorem sigmaPP_pos (p a : ℕ) : 0 < sigmaPP p a := by
  have := one_le_sigmaPP p a; omega

/-- σ₁(p^a) = sigmaPP p a for prime p. -/
theorem sigma₁_prime_pow {p : ℕ} (hp : Nat.Prime p) (a : ℕ) :
    sigma₁ (p ^ a) = sigmaPP p a := by
  simp only [sigma₁, sigmaPP]
  rw [Nat.divisors_prime_pow hp]
  simp [Finset.sum_map]

/-! ## IsPerfect basic properties -/

theorem IsPerfect.sigma_eq {n : ℕ} (h : IsPerfect n) : sigma₁ n = 2 * n := h.1

theorem IsPerfect.pos {n : ℕ} (h : IsPerfect n) : 0 < n := h.2

theorem IsPerfect.ne_zero {n : ℕ} (h : IsPerfect n) : n ≠ 0 :=
  Nat.pos_iff_ne_zero.mp h.pos

theorem IsPerfect.one_lt {n : ℕ} (h : IsPerfect n) : 1 < n := by
  have h0 := h.pos
  have hs := h.sigma_eq
  by_contra hle; push_neg at hle
  have : n = 1 := by omega
  subst this; unfold sigma₁ at hs; simp at hs

/-
Connection to Mathlib's Nat.Perfect.
-/
theorem isPerfect_iff_nat_perfect {n : ℕ} (hn : 0 < n) :
    IsPerfect n ↔ Nat.Perfect n := by
  simp [IsPerfect, Nat.Perfect];
  unfold sigma₁; simp +decide [ two_mul, add_comm, Finset.sum_add_distrib ] ;
  rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self, add_comm ] ; aesop

end OddPerfect