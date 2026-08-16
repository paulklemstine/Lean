/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Transfer principles

Two complementary transfer principles for the ultrapower of `ℕ`.

1. **Quantifier transfer for internal sets** (`forall_internalMem_iff`,
   `exists_internalMem_iff`).  These are the quantifier steps of Łoś' theorem,
   proved by hand at the level of germs: a universally quantified statement
   about *all* hypernaturals is equivalent to a pointwise statement about
   almost all coordinates.  The nontrivial direction needs the axiom of choice
   to assemble a counterexample germ out of coordinatewise counterexamples.
   As an application we re-derive internal induction
   (`internal_induction_of_transfer`) directly from transfer.

2. **Łoś' theorem for arbitrary first-order structures**
   (`ultrapower_sentence_iff`, `ultrapower_elementarilyEquivalent`): an
   ultrapower of a structure satisfies exactly the same sentences as the
   structure itself.  In particular no first-order sentence can distinguish
   `ℕ` from the nonstandard models built here, even though those models are
   uncountable (`NonstandardArithmetic.mk_hyperNat`) and non-Archimedean
   (`NonstandardArithmetic.far_dense`).
-/

import Novelty.NonstandardInternalSets
import Mathlib.ModelTheory.Ultraproducts
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-! ## Quantifier transfer for internal sets -/

/-- **Universal transfer.** Every hypernatural belongs to the internal set `A`
if and only if almost every coordinate of `A` is all of `ℕ`. -/
theorem forall_internalMem_iff (A : ℕ → Set ℕ) :
    (∀ H : HyperNat, H ∈* (A : InternalSet)) ↔
      ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), A i = Set.univ := by
  constructor
  · intro h
    by_contra hc
    rw [← Ultrafilter.eventually_not] at hc
    have hne : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), ∃ x : ℕ, x ∉ A i := by
      filter_upwards [hc] with i hi
      by_contra hx
      push_neg at hx
      exact hi (Set.eq_univ_of_forall hx)
    classical
    -- choose a coordinatewise counterexample (arbitrary where none exists)
    set g : ℕ → ℕ := fun i => if hx : ∃ x : ℕ, x ∉ A i then Classical.choose hx else 0 with hg
    have hgmem : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), g i ∉ A i := by
      filter_upwards [hne] with i hi
      simp only [hg, dif_pos hi]
      exact Classical.choose_spec hi
    have hcontr := (internalMem_coe g A).mp (h (g : HyperNat))
    have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
      filter_upwards [hcontr, hgmem] with i h1 h2 using h2 h1
    rw [Filter.eventually_false_iff_eq_bot] at hfalse
    exact Filter.NeBot.ne inferInstance hfalse
  · intro h H
    refine Filter.Germ.inductionOn H (fun f => ?_)
    rw [internalMem_coe]
    filter_upwards [h] with i hi
    rw [hi]
    exact Set.mem_univ _

/-- **Existential transfer.** The internal set `A` has an element if and only
if almost every coordinate of `A` is nonempty. -/
theorem exists_internalMem_iff (A : ℕ → Set ℕ) :
    (∃ H : HyperNat, H ∈* (A : InternalSet)) ↔
      ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), (A i).Nonempty := by
  constructor
  · rintro ⟨H, hH⟩
    refine Filter.Germ.inductionOn H (fun f hf => ?_) hH
    rw [internalMem_coe] at hf
    filter_upwards [hf] with i hi
    exact ⟨f i, hi⟩
  · intro h
    classical
    set g : ℕ → ℕ := fun i => if hx : (A i).Nonempty then Classical.choose hx else 0 with hg
    refine ⟨(g : HyperNat), ?_⟩
    rw [internalMem_coe]
    filter_upwards [h] with i hi
    simp only [hg, dif_pos hi]
    exact Classical.choose_spec hi

/-- Internal induction, re-derived from quantifier transfer: this exhibits the
induction principle of the nonstandard model as an instance of Łoś' theorem
rather than of a diagonal argument. -/
theorem internal_induction_of_transfer (A : ℕ → Set ℕ)
    (hgood : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), 0 ∈ A i ∧ ∀ k, k ∈ A i → k + 1 ∈ A i) :
    ∀ H : HyperNat, H ∈* (A : InternalSet) := by
  rw [forall_internalMem_iff]
  filter_upwards [hgood] with i hi
  refine Set.eq_univ_of_forall (fun k => ?_)
  induction k with
  | zero => exact hi.1
  | succ n ih => exact hi.2 n ih

/-! ## Łoś' theorem: ultrapowers are elementarily equivalent to their base -/

open FirstOrder Language

/-- **Transfer principle.** For any first-order language `L`, any structure `M`
and any ultrafilter `U`, the ultrapower of `M` satisfies a sentence exactly
when `M` does. -/
theorem ultrapower_sentence_iff {L : FirstOrder.Language} {I : Type*} (U : Ultrafilter I)
    (M : Type*) [L.Structure M] [Nonempty M] (φ : L.Sentence) :
    ((U : Filter I).Product (fun _ : I => M) ⊨ φ) ↔ M ⊨ φ := by
  rw [FirstOrder.Language.Ultraproduct.sentence_realize (M := fun _ : I => M) (u := U) φ]
  exact Filter.eventually_const

/-- The ultrapower is elementarily equivalent to the base structure: no
first-order sentence sees the difference. -/
theorem ultrapower_elementarilyEquivalent {L : FirstOrder.Language} {I : Type*}
    (U : Ultrafilter I) (M : Type*) [L.Structure M] [Nonempty M] :
    ((U : Filter I).Product (fun _ : I => M)) ≅[L] M :=
  FirstOrder.Language.elementarilyEquivalent_iff.mpr (fun φ => ultrapower_sentence_iff U M φ)

end NonstandardArithmetic