/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.SymmetricPowerEuler.Defs

/-!
# Chebyshev Recurrence and Power Sum Identities

This file proves the fundamental recurrence relations for `e1SymmPower`,
`powerSumTwo`, and establishes their connection to the trace-determinant
recursive definitions.

## Main results

- `e1SymmPower_zero`, `e1SymmPower_one`: Base cases.
- `e1SymmPower_recurrence`: e₁(n+2) = (α+β)·e₁(n+1) − (αβ)·e₁(n).
- `symmTraceRec_eq_e1SymmPower`: symmTraceRec(α+β, αβ) n = e1SymmPower n α β.
- `powerSumTwo_eq`: powerSumTwo(α+β, αβ) n = α^n + β^n.

## Mathematical significance

The recurrence is the Clebsch–Gordan decomposition
V ⊗ Sym^n(V) ≅ Sym^{n+1}(V) ⊕ det(V) ⊗ Sym^{n-1}(V)
at the character level.
-/

open Finset BigOperators

/-! ## Base cases for e1SymmPower -/

@[simp] theorem e1SymmPower_zero {R : Type*} [CommRing R] (α β : R) :
    e1SymmPower 0 α β = 1 := by
  simp [e1SymmPower]

@[simp] theorem e1SymmPower_one {R : Type*} [CommRing R] (α β : R) :
    e1SymmPower 1 α β = α + β := by
  simp [e1SymmPower, Finset.sum_range_succ]

/-! ## The Chebyshev recurrence for e1SymmPower -/

/-
**Chebyshev recurrence for symmetric power traces.**
e₁(n+2,α,β) = (α+β)·e₁(n+1,α,β) − (αβ)·e₁(n,α,β).
-/
theorem e1SymmPower_recurrence {R : Type*} [CommRing R] (n : ℕ) (α β : R) :
    e1SymmPower (n + 2) α β =
      (α + β) * e1SymmPower (n + 1) α β - α * β * e1SymmPower n α β := by
  simp only [e1SymmPower, mul_comm, mul_assoc]
  simp +decide [Finset.sum_range_succ', add_mul, mul_add, mul_assoc, mul_comm,
    mul_left_comm, pow_succ']
  simp +decide [mul_assoc, Finset.mul_sum _ _ _, add_assoc,
    add_left_comm, add_comm]
  abel1

/-! ## symmTraceRec equals e1SymmPower -/

theorem symmTraceRec_eq_e1SymmPower {R : Type*} [CommRing R] (n : ℕ) (α β : R) :
    symmTraceRec (α + β) (α * β) n = e1SymmPower n α β := by
  induction' n using Nat.strongRecOn with n ih
  rcases n with ( _ | _ | n ) <;> simp_all +decide
  · rfl
  · rfl
  · rw [show symmTraceRec (α + β) (α * β) (n + 2) =
        (α + β) * symmTraceRec (α + β) (α * β) (n + 1) -
        (α * β) * symmTraceRec (α + β) (α * β) n from rfl,
      ih _ le_rfl, ih _ (Nat.le_succ _), e1SymmPower_recurrence]

/-! ## Power sum identity -/

theorem powerSumTwo_eq {R : Type*} [CommRing R] (n : ℕ) (α β : R) :
    powerSumTwo (α + β) (α * β) n = α ^ n + β ^ n := by
  induction' n using Nat.strongRecOn with n ih
  rcases n with ( _ | _ | n ) <;> simp_all +decide [powerSumTwo]
  · norm_num
  · ring