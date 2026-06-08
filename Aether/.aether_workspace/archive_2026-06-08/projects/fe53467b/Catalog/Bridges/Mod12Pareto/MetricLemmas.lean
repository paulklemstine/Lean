/-
  Mod-12 Pareto Rigidity: Metric Lemmas
  ======================================

  Fundamental properties of the cyclic distance on ZMod 12:
  - cycDist_self: distance from any element to itself is zero
  - cycDist_symm: cyclic distance is symmetric
  - cycDist_add_right_invariant: cyclic distance is invariant under translation
  - cycDist_le_six: distance is bounded by 6

  These lemmas form the "atomic engine" for all transposition-invariance results.
-/
import Mathlib
import Bridges.Mod12Pareto.Defs

open Finset BigOperators

/-! ## Basic properties of rawDist -/

theorem rawDist_self (a : pc) : rawDist a a = 0 := by
  simp [rawDist]

theorem rawDist_bounded (a b : pc) : rawDist a b < 12 := by
  simp only [rawDist, pc]
  exact ZMod.val_lt (a - b)

theorem rawDist_add_right (a b t : pc) : rawDist (a + t) (b + t) = rawDist a b := by
  simp [rawDist, add_sub_add_right_eq_sub]

/-! ## Core cycDist lemmas -/

/-
The cyclic distance from any pitch class to itself is zero.
-/
theorem cycDist_self (a : pc) : cycDist a a = 0 := by
  native_decide +revert

/-
Cyclic distance is symmetric.
-/
theorem cycDist_symm (a b : pc) : cycDist a b = cycDist b a := by
  native_decide +revert

/-
The fundamental invariance lemma: cyclic distance is preserved under translation.
    This is the atomic engine for all transposition-invariance results.
-/
theorem cycDist_add_right_invariant (a b t : pc) :
    cycDist (a + t) (b + t) = cycDist a b := by
  native_decide +revert

/-
Cyclic distance is bounded by 6 (half of 12).
-/
theorem cycDist_le_six (a b : pc) : cycDist a b ≤ 6 := by
  native_decide +revert