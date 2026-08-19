/-
# The Poisson spectrum of a finite abelian group

The converse of Poisson summation (`Catalog.Pythagorean.FourierPoissonConverse`) turns the
*analytic* condition `PoissonSet S` into a *decidable combinatorial* condition: `S` is empty,
or `S` contains `0` and is closed under subtraction.  This file exploits that reduction.

Main results:

* `FourierFA.poissonSet_iff_comb` : the decidable criterion, valid for every finset of every
  finite abelian group.
* Complete determination of the **Poisson spectrum** (the family of all Poisson sets) of
  `ZMod 4`, `ZMod 5`, `ZMod 6`, `ZMod 8` and of the Klein four-group `ZMod 2 × ZMod 2`,
  each verified exhaustively over all `2^{|G|}` subsets.
* `FourierFA.card_poissonSets_zmod6`, `FourierFA.card_poissonSets_zmod8` : the number of
  nonempty Poisson sets of `ZMod n` equals the number of divisors of `n` (`n = 6, 8`).
* `FourierFA.poissonSpectrum_distinguishes_zmod4_klein` : `ZMod 4` and the Klein four-group
  have the same order but a different number of Poisson sets (`4` versus `6`).  Hence the
  Poisson spectrum is a genuine isomorphism invariant, not a function of `|G|`: Poisson
  summation "sees" the isomorphism type of the group.
-/

import Mathlib
import Pythagorean.FourierPoissonCoset

open Finset Fintype ComplexConjugate
open scoped Classical

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-- **Decidable criterion for Poisson summation.**  Combining the classification of Poisson
sets with the finiteness of `G`, the analytic identity `(P_S)` is equivalent to a finite,
checkable combinatorial condition. -/
theorem poissonSet_iff_comb (S : Finset G) :
    PoissonSet S ↔ (S = ∅ ∨ ((0 : G) ∈ S ∧ ∀ x ∈ S, ∀ y ∈ S, x - y ∈ S)) := by
  rcases S.eq_empty_or_nonempty with rfl | hS
  · simp [poissonSet_empty]
  · rw [poissonSet_iff_zero_mem_and_sub_mem hS]
    constructor
    · exact fun h => Or.inr h
    · rintro (rfl | h)
      · exact absurd hS (by simp)
      · exact h

/-! ## The Poisson spectrum of small groups

Each statement below is an exhaustive verification over all subsets of the group. -/

set_option maxRecDepth 40000 in
/-- The Poisson sets of `ZMod 4` are `∅`, `{0}`, `{0,2}` and `ZMod 4`. -/
theorem poissonSet_zmod4_iff (S : Finset (ZMod 4)) :
    PoissonSet S ↔ (S = ∅ ∨ S = {0} ∨ S = {0, 2} ∨ S = Finset.univ) := by
  rw [poissonSet_iff_comb]
  revert S
  decide

set_option maxRecDepth 40000 in
/-- `ZMod 5` has prime order, so its only Poisson sets are the trivial ones. -/
theorem poissonSet_zmod5_iff (S : Finset (ZMod 5)) :
    PoissonSet S ↔ (S = ∅ ∨ S = {0} ∨ S = Finset.univ) := by
  rw [poissonSet_iff_comb]
  revert S
  decide

set_option maxRecDepth 40000 in
/-- The Poisson sets of `ZMod 6`. -/
theorem poissonSet_zmod6_iff (S : Finset (ZMod 6)) :
    PoissonSet S ↔ (S = ∅ ∨ S = {0} ∨ S = {0, 3} ∨ S = {0, 2, 4} ∨ S = Finset.univ) := by
  rw [poissonSet_iff_comb]
  revert S
  decide

set_option maxRecDepth 100000 in
/-- The Poisson sets of `ZMod 8`.  In particular `{0,1,4}` (the squares mod `8`) is absent,
reproving `not_poissonSet_squares_zmod8` by exhaustion. -/
theorem poissonSet_zmod8_iff (S : Finset (ZMod 8)) :
    PoissonSet S ↔ (S = ∅ ∨ S = {0} ∨ S = {0, 4} ∨ S = {0, 2, 4, 6} ∨ S = Finset.univ) := by
  rw [poissonSet_iff_comb]
  revert S
  decide

set_option maxRecDepth 40000 in
set_option synthInstance.maxSize 1000 in
/-- The Poisson sets of the Klein four-group: there are **six**, one more than the number of
subsets of `ZMod 4` that are Poisson, although both groups have order `4`. -/
theorem poissonSet_klein_iff (S : Finset (ZMod 2 × ZMod 2)) :
    PoissonSet S ↔ (S = ∅ ∨ S = {0} ∨ S = {0, (1, 0)} ∨ S = {0, (0, 1)} ∨ S = {0, (1, 1)}
      ∨ S = Finset.univ) := by
  rw [poissonSet_iff_comb]
  revert S
  decide

/-! ## Counting: the Poisson spectrum is an isomorphism invariant -/

set_option maxRecDepth 40000 in
/-- `ZMod 4` has exactly `4` Poisson sets. -/
theorem card_poissonSets_zmod4 :
    ((Finset.univ : Finset (Finset (ZMod 4))).filter (fun S => PoissonSet S)).card = 4 := by
  have hcongr : ((Finset.univ : Finset (Finset (ZMod 4))).filter (fun S => PoissonSet S))
      = ((Finset.univ : Finset (Finset (ZMod 4))).filter
          (fun S => S = ∅ ∨ S = {0} ∨ S = {0, 2} ∨ S = Finset.univ)) :=
    Finset.filter_congr (fun S _ => poissonSet_zmod4_iff S)
  rw [hcongr]
  decide

set_option maxRecDepth 40000 in
set_option synthInstance.maxSize 1000 in
/-- The Klein four-group has exactly `6` Poisson sets. -/
theorem card_poissonSets_klein :
    ((Finset.univ : Finset (Finset (ZMod 2 × ZMod 2))).filter (fun S => PoissonSet S)).card
      = 6 := by
  have hcongr :
      ((Finset.univ : Finset (Finset (ZMod 2 × ZMod 2))).filter (fun S => PoissonSet S))
      = ((Finset.univ : Finset (Finset (ZMod 2 × ZMod 2))).filter
          (fun S => S = ∅ ∨ S = {0} ∨ S = {0, (1, 0)} ∨ S = {0, (0, 1)} ∨ S = {0, (1, 1)}
            ∨ S = Finset.univ)) :=
    Finset.filter_congr (fun S _ => poissonSet_klein_iff S)
  rw [hcongr]
  decide

set_option synthInstance.maxSize 1000 in
/-- **The Poisson spectrum separates groups of equal order.**  `ZMod 4` and `ZMod 2 × ZMod 2`
both have four elements, yet they admit a different number of Poisson sets.  Consequently the
number of exact Poisson summation formulas available on a finite abelian group is not
determined by its cardinality; it is a genuine isomorphism invariant. -/
theorem poissonSpectrum_distinguishes_zmod4_klein :
    Fintype.card (ZMod 4) = Fintype.card (ZMod 2 × ZMod 2) ∧
    ((Finset.univ : Finset (Finset (ZMod 4))).filter (fun S => PoissonSet S)).card
      ≠ ((Finset.univ : Finset (Finset (ZMod 2 × ZMod 2))).filter
          (fun S => PoissonSet S)).card := by
  refine ⟨by simp, ?_⟩
  rw [card_poissonSets_zmod4, card_poissonSets_klein]
  omega

set_option maxRecDepth 40000 in
/-- For `ZMod 6` the nonempty Poisson sets are in bijection with the divisors of `6`. -/
theorem card_poissonSets_zmod6 :
    ((Finset.univ : Finset (Finset (ZMod 6))).filter (fun S => S.Nonempty ∧ PoissonSet S)).card
      = (Nat.divisors 6).card := by
  have hcongr :
      ((Finset.univ : Finset (Finset (ZMod 6))).filter (fun S => S.Nonempty ∧ PoissonSet S))
      = ((Finset.univ : Finset (Finset (ZMod 6))).filter
          (fun S => S = {0} ∨ S = {0, 3} ∨ S = {0, 2, 4} ∨ S = Finset.univ)) := by
    refine Finset.filter_congr (fun S _ => ?_)
    rw [poissonSet_zmod6_iff S]
    constructor
    · rintro ⟨hne, (rfl | h)⟩
      · exact absurd hne (by simp)
      · exact h
    · intro h
      refine ⟨?_, Or.inr h⟩
      rcases h with rfl | rfl | rfl | rfl <;> exact ⟨0, by decide⟩
  rw [hcongr]
  decide

set_option maxRecDepth 100000 in
/-- For `ZMod 8` the nonempty Poisson sets are in bijection with the divisors of `8`. -/
theorem card_poissonSets_zmod8 :
    ((Finset.univ : Finset (Finset (ZMod 8))).filter (fun S => S.Nonempty ∧ PoissonSet S)).card
      = (Nat.divisors 8).card := by
  have hcongr :
      ((Finset.univ : Finset (Finset (ZMod 8))).filter (fun S => S.Nonempty ∧ PoissonSet S))
      = ((Finset.univ : Finset (Finset (ZMod 8))).filter
          (fun S => S = {0} ∨ S = {0, 4} ∨ S = {0, 2, 4, 6} ∨ S = Finset.univ)) := by
    refine Finset.filter_congr (fun S _ => ?_)
    rw [poissonSet_zmod8_iff S]
    constructor
    · rintro ⟨hne, (rfl | h)⟩
      · exact absurd hne (by simp)
      · exact h
    · intro h
      refine ⟨?_, Or.inr h⟩
      rcases h with rfl | rfl | rfl | rfl <;> exact ⟨0, by decide⟩
  rw [hcongr]
  decide

end FourierFA