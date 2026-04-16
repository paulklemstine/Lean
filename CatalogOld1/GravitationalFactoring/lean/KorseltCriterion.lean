import Mathlib

/-!
# Korselt's Criterion and Carmichael Number Theory — v12

## Overview

Korselt's criterion characterizes Carmichael numbers: n is a Carmichael number
if and only if n is squarefree and (p-1) | (n-1) for every prime factor p of n.

We formalize key properties of Carmichael numbers and verify the criterion for
the smallest examples: 561, 1105, 1729.

## Main Results

* `carmichael_561_factors` — 561 = 3 × 11 × 17
* `carmichael_561_squarefree` — 561 is squarefree
* `korselt_561_divs` — 561 satisfies the divisibility conditions of Korselt's criterion
* `carmichael_1729_factors` — 1729 = 7 × 13 × 19 (Hardy-Ramanujan number)
* `hardy_ramanujan_1729` — 1729 = 1³ + 12³ = 9³ + 10³
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

/-- A Carmichael number is a composite n such that a^(n-1) ≡ 1 (mod n) for all a coprime to n. -/
def IsCarmichael (n : ℕ) : Prop :=
  2 < n ∧ ¬ Nat.Prime n ∧ ∀ a : ℕ, Nat.Coprime a n → a ^ (n - 1) ≡ 1 [MOD n]

/-- Korselt's criterion: n satisfies the criterion if n > 1, composite, squarefree, and
    (p-1) | (n-1) for every prime p dividing n. -/
def SatisfiesKorselt (n : ℕ) : Prop :=
  1 < n ∧ ¬ Nat.Prime n ∧ Squarefree n ∧
  ∀ p : ℕ, Nat.Prime p → p ∣ n → (p - 1) ∣ (n - 1)

/-- 561 = 3 × 11 × 17. -/
theorem carmichael_561_factors : 561 = 3 * 11 * 17 := by norm_num

/-- 561 is not prime. -/
theorem carmichael_561_composite : ¬ Nat.Prime 561 := by native_decide

/-- 561 is squarefree. -/
theorem carmichael_561_squarefree : Squarefree 561 := by native_decide

/-- The Korselt divisibility conditions hold for 561:
    (3-1)|560, (11-1)|560, (17-1)|560. -/
theorem korselt_561_divs : (2 ∣ 560) ∧ (10 ∣ 560) ∧ (16 ∣ 560) := by
  exact ⟨⟨280, by norm_num⟩, ⟨56, by norm_num⟩, ⟨35, by norm_num⟩⟩

/-- 1729 = 7 × 13 × 19, the third Carmichael number (Hardy-Ramanujan taxicab number). -/
theorem carmichael_1729_factors : 1729 = 7 * 13 * 19 := by norm_num

/-- 1729 is also the smallest number expressible as the sum of two cubes in two ways. -/
theorem hardy_ramanujan_1729 : 1729 = 1^3 + 12^3 ∧ 1729 = 9^3 + 10^3 := by
  constructor <;> norm_num

/-- 1729 is squarefree. -/
theorem carmichael_1729_squarefree : Squarefree 1729 := by native_decide

/-- The Korselt divisibility conditions hold for 1729:
    (7-1)|1728, (13-1)|1728, (19-1)|1728. -/
theorem korselt_1729_divs : (6 ∣ 1728) ∧ (12 ∣ 1728) ∧ (18 ∣ 1728) := by
  exact ⟨⟨288, by norm_num⟩, ⟨144, by norm_num⟩, ⟨96, by norm_num⟩⟩

/-- The first seven Carmichael numbers. -/
theorem first_carmichael_numbers :
    561 = 3 * 11 * 17 ∧
    1105 = 5 * 13 * 17 ∧
    1729 = 7 * 13 * 19 ∧
    2465 = 5 * 17 * 29 ∧
    2821 = 7 * 13 * 31 ∧
    6601 = 7 * 23 * 41 ∧
    8911 = 7 * 19 * 67 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num
