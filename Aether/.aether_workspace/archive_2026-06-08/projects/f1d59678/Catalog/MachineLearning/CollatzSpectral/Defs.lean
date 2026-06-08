/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Accelerated Collatz Map: Core Definitions and Properties

This file defines the accelerated Collatz map on odd naturals and establishes
its basic structural properties. The accelerated map T sends an odd positive
natural n to (3n+1)/2^{ν₂(3n+1)}, which is always odd and positive.

## Main Definitions

* `collatzNu2` — the 2-adic valuation of 3n+1
* `acceleratedCollatz` — the accelerated Collatz map T(n) = (3n+1)/2^{ν₂(3n+1)}
* `collatzWeight` — the transfer operator weight 2^{-s·ν₂(3n+1)}
* `IsOddPos` — predicate for odd positive naturals

## Main Results

* `three_mul_odd_add_one_even` — 3n+1 is even when n is odd
* `acceleratedCollatz_odd` — T maps odd positives to odd numbers
* `acceleratedCollatz_pos` — T maps odd positives to positive numbers
* `acceleratedCollatz_one` — T(1) = 1, i.e. 1 is a fixed point
-/

import Mathlib

open Finset BigOperators

/-! ## §1. Core Definitions -/

/-- The 2-adic valuation of 3n+1. For odd n, this is ≥ 1. -/
noncomputable def collatzNu2 (n : ℕ) : ℕ := (3 * n + 1).factorization 2

/-- The accelerated Collatz map: T(n) = (3n+1) / 2^{ν₂(3n+1)}.
    For odd positive n, this always yields an odd positive natural. -/
noncomputable def acceleratedCollatz (n : ℕ) : ℕ :=
  (3 * n + 1) / 2 ^ collatzNu2 n

/-- Predicate for odd positive naturals. -/
def IsOddPos (n : ℕ) : Prop := 0 < n ∧ n % 2 = 1

/-- The weight appearing in the transfer operator: 2^{-s·ν₂(3n+1)}. -/
noncomputable def collatzWeight (s : ℝ) (m : ℕ) : ℝ :=
  (2 : ℝ) ^ (-(s * (collatzNu2 m : ℝ)))

/-! ## §2. Basic Arithmetic Lemmas -/

/-
3n+1 is even when n is odd.
-/
theorem three_mul_odd_add_one_even {n : ℕ} (hn : n % 2 = 1) :
    (3 * n + 1) % 2 = 0 := by
  norm_num [ Nat.add_mod, Nat.mul_mod, hn ]

/-
3n+1 is positive when n is positive (or n = 0).
-/
theorem three_mul_add_one_pos (n : ℕ) : 0 < 3 * n + 1 := by
  grind

/-
For odd n > 0, the 2-adic valuation of 3n+1 is at least 1.
-/
theorem collatzNu2_pos {n : ℕ} (hn : IsOddPos n) : 0 < collatzNu2 n := by
  exact Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by exact Nat.mem_primeFactors.mpr ⟨ Nat.prime_two, Nat.dvd_of_mod_eq_zero ( three_mul_odd_add_one_even hn.2 ), by nlinarith [ hn.1 ] ⟩ ) )

/-
2^{ν₂(3n+1)} divides 3n+1 when 3n+1 > 0.
-/
theorem pow_collatzNu2_dvd (n : ℕ) :
    2 ^ collatzNu2 n ∣ (3 * n + 1) := by
  exact Nat.ordProj_dvd _ _

/-
The fundamental factorization: 3n+1 = 2^{ν₂(3n+1)} · acceleratedCollatz n.
-/
theorem collatz_factorization (n : ℕ) :
    3 * n + 1 = 2 ^ collatzNu2 n * acceleratedCollatz n := by
  exact Eq.symm ( Nat.mul_div_cancel' ( pow_collatzNu2_dvd n ) )

/-! ## §3. The Accelerated Map Preserves Odd Positivity -/

/-
The accelerated Collatz map sends odd positives to odd numbers.
-/
theorem acceleratedCollatz_odd {n : ℕ} (hn : IsOddPos n) :
    acceleratedCollatz n % 2 = 1 := by
  -- By collatz_factorization, 3n+1 = 2^ν * T(n) where ν = collatzNu2 n. Since ν = (3n+1).factorization 2, the factor 2^ν is the exact power of 2 dividing 3n+1, so T(n) = (3n+1)/2^ν is odd (not divisible by 2).
  have h_acc_odd : ¬(2 ∣ acceleratedCollatz n) := by
    rw [ Nat.Prime.dvd_iff_one_le_factorization ] <;> norm_num;
    · rw [ show acceleratedCollatz n = ( 3 * n + 1 ) / 2 ^ collatzNu2 n from rfl, Nat.factorization_div ] <;> norm_num;
      · exact Nat.sub_eq_zero_of_le ( Nat.le_refl _ );
      · exact Nat.ordProj_dvd _ _;
    · exact Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.succ_pos _ ) ( pow_collatzNu2_dvd n ) ) ( pow_pos ( by decide ) _ ) );
  exact Nat.mod_two_ne_zero.mp fun h => h_acc_odd <| Nat.dvd_of_mod_eq_zero h

/-
The accelerated Collatz map sends odd positives to positive numbers.
-/
theorem acceleratedCollatz_pos {n : ℕ} (hn : IsOddPos n) :
    0 < acceleratedCollatz n := by
  exact Nat.div_pos ( Nat.le_of_dvd ( three_mul_add_one_pos n ) ( pow_collatzNu2_dvd n ) ) ( pow_pos ( by decide ) _ )

/-- The accelerated Collatz map preserves the IsOddPos predicate. -/
theorem acceleratedCollatz_isOddPos {n : ℕ} (hn : IsOddPos n) :
    IsOddPos (acceleratedCollatz n) :=
  ⟨acceleratedCollatz_pos hn, acceleratedCollatz_odd hn⟩

/-- 1 is a fixed point of the accelerated Collatz map. -/
theorem acceleratedCollatz_one : acceleratedCollatz 1 = 1 := by
  unfold acceleratedCollatz collatzNu2
  norm_num
  have h4 : (4 : ℕ) = 2 ^ 2 := by norm_num
  rw [h4, Nat.Prime.factorization_pow Nat.prime_two, Finsupp.single_eq_same]
  norm_num

/-! ## §4. Iteration and Termination -/

/-- The Collatz conjecture for the accelerated map: every odd positive
    natural eventually reaches 1 under iteration. -/
def CollatzTerminates : Prop :=
  ∀ n : ℕ, IsOddPos n → ∃ k : ℕ, acceleratedCollatz^[k] n = 1

/-- A single orbit terminates if it reaches 1. -/
def OrbitTerminates (n : ℕ) : Prop :=
  ∃ k : ℕ, acceleratedCollatz^[k] n = 1