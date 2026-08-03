/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Kernel-checked small cases for t-fold sumsets

These examples provide concise computational evidence for the deterministic
cardinality obstruction.  They are derived from the proved general theorems,
rather than an untrusted external search.
-/
import Pythagorean.TFoldSumsetAvoidance

open Finset Pointwise
open TFoldSumsetAvoidance
open Pythagorean.TFoldSumsetAvoidance

namespace Pythagorean.TFoldSumsetComputationalEvidence

/-- The first six interval cardinalities, checked uniformly from the general
cardinality theorem. -/
theorem initialInterval_first_six_cards :
    (initialInterval 0).card = 0 ∧
    (initialInterval 1).card = 1 ∧
    (initialInterval 2).card = 2 ∧
    (initialInterval 3).card = 3 ∧
    (initialInterval 4).card = 4 ∧
    (initialInterval 5).card = 5 := by
  constructor
  · exact initialInterval_card 0
  constructor
  · exact initialInterval_card 1
  constructor
  · exact initialInterval_card 2
  constructor
  · exact initialInterval_card 3
  constructor
  · exact initialInterval_card 4
  · exact initialInterval_card 5

/-- A two-fold small case: no two nonempty sets of cardinality at least three
can have their sumset contained in an initial interval of length three. -/
theorem no_two_by_three_sumset_in_three
    (A B : Finset ℤ) (hA : A.Nonempty) (hB : B.Nonempty)
    (hAc : 3 ≤ A.card) (hBc : 3 ≤ B.card) :
    ¬ sumsetList [A, B] ⊆ initialInterval 3 := by
  exact initialInterval_avoids_uniform_tfold 3 2 3 (by norm_num) [A, B]
    (by norm_num) (by simp [hA, hB]) (by simp [hAc, hBc])

/-- A three-fold small case: no three nonempty sets of cardinality at least two
can have their sumset contained in an initial interval of length three. -/
theorem no_three_by_two_sumset_in_three
    (A B C : Finset ℤ) (hA : A.Nonempty) (hB : B.Nonempty) (hC : C.Nonempty)
    (hAc : 2 ≤ A.card) (hBc : 2 ≤ B.card) (hCc : 2 ≤ C.card) :
    ¬ sumsetList [A, B, C] ⊆ initialInterval 3 := by
  exact initialInterval_avoids_uniform_tfold 3 3 2 (by norm_num) [A, B, C]
    (by norm_num) (by simp [hA, hB, hC]) (by simp [hAc, hBc, hCc])

end Pythagorean.TFoldSumsetComputationalEvidence