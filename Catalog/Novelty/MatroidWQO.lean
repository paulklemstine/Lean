/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Bridges.MatroidMinorFiniteBasis
import Geometry.MatroidMinors.Basic

/-!
# Well-quasi-ordering and excluded minors for matroids

This file gives a sound version of the previously incomplete rank-matroid
prototype.  It uses Mathlib's `Matroid` and minor relation directly.  The main
results connect three structures:

* duality is an order automorphism of the minor order;
* excluded minors are minimal elements of the complement of a minor-closed
  class and therefore form an antichain;
* a well-quasi-order makes that antichain finite and gives an avoidance
  characterization of the class.

No well-quasi-ordering conjecture for representable matroids is assumed as a
fact; it is an explicit hypothesis of the final theorem.
-/

open Set Matroid

namespace MatroidMinorTheory

variable {α : Type*}

/-- A class of matroids on `α`, together with its closure under minors. -/
structure MinorClosedClass (α : Type*) where
  mem : Matroid α → Prop
  minor_closed : ∀ ⦃M N : Matroid α⦄, mem M → N ≤m M → mem N

/-- An excluded minor lies outside the class while all strict minors lie in it. -/
def IsExcludedMinor (C : MinorClosedClass α) (M : Matroid α) : Prop :=
  ¬ C.mem M ∧ ∀ ⦃N : Matroid α⦄, N <m M → C.mem N

/-- The set of excluded minors of a minor-closed class. -/
def excludedMinors (C : MinorClosedClass α) : Set (Matroid α) :=
  {M | IsExcludedMinor C M}

/-- Taking duals preserves the minor relation. -/
theorem dual_minor_of_minor {M N : Matroid α} (h : N ≤m M) :
    N✶ ≤m M✶ := by
  exact MatroidMinor.dual_isMinor_dual h

/-- Taking duals reflects as well as preserves the minor relation. -/
theorem dual_minor_iff {M N : Matroid α} : N✶ ≤m M✶ ↔ N ≤m M := by
  exact MatroidMinor.dual_isMinor_iff

/-- Excluded minors are precisely the minimal elements of the complement. -/
theorem excluded_iff_minimalMember (C : MinorClosedClass α) (M : Matroid α) :
    IsExcludedMinor C M ↔
      M ∈ MatroidMinorFiniteBasis.minimalMembers {N | ¬ C.mem N} := by
  simp [IsExcludedMinor, MatroidMinorFiniteBasis.minimalMembers]

/-- Distinct excluded minors are incomparable. -/
theorem excluded_minors_antichain (C : MinorClosedClass α) :
    IsAntichain (· ≤m ·) (excludedMinors C) := by
  rw [show excludedMinors C =
      MatroidMinorFiniteBasis.minimalMembers {N | ¬ C.mem N} from by
        ext M
        exact excluded_iff_minimalMember C M]
  exact MatroidMinorFiniteBasis.minimalMembers_isAntichain _

/-- A well-quasi-ordered minor relation has only finitely many excluded minors. -/
theorem wqo_implies_finite_excluded_minors (C : MinorClosedClass α)
    (hwqo : WellQuasiOrdered ((· ≤m ·) : Matroid α → Matroid α → Prop)) :
    (excludedMinors C).Finite := by
  exact (excluded_minors_antichain C).finite_of_wellQuasiOrdered hwqo

/--
If the minor order is a well-quasi-order, membership in a minor-closed class is
characterized by avoiding its finite set of excluded minors.
-/
theorem wqo_finite_forbidden_characterization (C : MinorClosedClass α)
    (hwqo : WellQuasiOrdered ((· ≤m ·) : Matroid α → Matroid α → Prop)) :
    (excludedMinors C).Finite ∧
      ∀ M, C.mem M ↔ ∀ N ∈ excludedMinors C, ¬ N ≤m M := by
  let S : Set (Matroid α) := {M | C.mem M}
  have hclosed : MatroidMinorFiniteBasis.IsMatroidMinorClosed S := by
    intro M N hM hNM
    exact C.minor_closed hM hNM
  have h := MatroidMinorFiniteBasis.matroid_wqo_gives_finite_excluded_minors
    hwqo S hclosed
  constructor
  · simpa [excludedMinors, IsExcludedMinor,
      MatroidMinorFiniteBasis.IsExcludedMinor, S] using h.1
  · intro M
    simpa [excludedMinors, IsExcludedMinor,
      MatroidMinorFiniteBasis.IsExcludedMinor, S] using h.2 M

end MatroidMinorTheory