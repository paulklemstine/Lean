/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Internal sets, overspill, and the exact scope of induction in an ultrapower of `ℕ`

This file builds on `Novelty.NonstandardArithmetic`, which specializes Mathlib's
filter germs to the hyperfilter on `ℕ` and records the basic transfer lemmas.

We introduce *internal subsets* of the ultrapower `HyperNat` as germs of
sequences of subsets of `ℕ`, with membership given by `Germ.LiftRel (· ∈ ·)`
(so that membership is automatically well defined on germs).  With that
definition we prove the two classical spilling principles

* `overspill`  : an internal set containing every standard natural contains an
  unlimited one;
* `underspill` : an internal set containing every unlimited hypernatural
  contains a standard one;

and we determine exactly which classical facts about `ℕ` survive:

* the **least number principle** survives for internal sets
  (`internal_least_element`) and fails for the external set of unlimited
  elements (`no_least_unlimited`);
* **induction** survives for internal sets (`internal_induction`) and fails for
  the external predicate "is standard" (`external_induction_fails`);
* consequently neither the standard cut nor the unlimited part is internal
  (`standard_not_internal`, `unlimited_not_internal`).
-/

import Novelty.NonstandardArithmetic
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-! ## Internal sets -/

/-- An *internal subset* of the ultrapower is a germ of a sequence of ordinary
subsets of `ℕ`. -/
abbrev InternalSet := Filter.Germ (Filter.hyperfilter ℕ : Filter ℕ) (Set ℕ)

/-- Membership of a hypernatural in an internal set, defined by lifting the
ordinary membership relation to germs; this is automatically independent of the
chosen representatives. -/
def InternalMem (H : HyperNat) (A : InternalSet) : Prop :=
  Filter.Germ.LiftRel (· ∈ ·) H A

@[inherit_doc] infix:50 " ∈* " => InternalMem

/-- Complement of an internal set. -/
noncomputable def InternalSet.compl (A : InternalSet) : InternalSet := Filter.Germ.map (fun s => sᶜ) A

/-- Membership in a represented internal set is pointwise membership on an
ultrafilter-large set of indices. -/
theorem internalMem_coe (f : ℕ → ℕ) (A : ℕ → Set ℕ) :
    (f : HyperNat) ∈* (A : InternalSet) ↔ ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), f i ∈ A i :=
  Filter.Germ.liftRel_coe

/-- Since the germs are taken along an ultrafilter, membership in the complement
is the negation of membership. -/
theorem internalMem_compl (H : HyperNat) (A : InternalSet) :
    H ∈* A.compl ↔ ¬ (H ∈* A) := by
  refine Filter.Germ.inductionOn H (fun f => Filter.Germ.inductionOn A (fun A => ?_))
  show (f : HyperNat) ∈* ((fun i => (A i)ᶜ : ℕ → Set ℕ) : InternalSet) ↔ _
  rw [internalMem_coe, internalMem_coe]
  exact Ultrafilter.eventually_not

/-! ## Standard and unlimited elements -/

/-- A hypernatural is *standard* when it is the image of an ordinary natural. -/
def IsStandard (H : HyperNat) : Prop := ∃ n : ℕ, H = standard n

/-- A hypernatural is *unlimited* when it dominates every standard natural. -/
def IsUnlimited (H : HyperNat) : Prop := ∀ n : ℕ, standard n < H

theorem isUnlimited_omega : IsUnlimited omega := standard_lt_omega

theorem not_isStandard_of_isUnlimited {H : HyperNat} (h : IsUnlimited H) : ¬ IsStandard H := by
  rintro ⟨n, rfl⟩
  exact lt_irrefl _ (h n)

theorem isStandard_standard (n : ℕ) : IsStandard (standard n) := ⟨n, rfl⟩

/-- The constant sequence representing a standard natural. -/
theorem standard_eq_coe (n : ℕ) : standard n = ((fun _ : ℕ => n : ℕ → ℕ) : HyperNat) := rfl

/-- Being unlimited is a pointwise "tends to infinity along the ultrafilter"
statement. -/
theorem isUnlimited_coe {f : ℕ → ℕ} :
    IsUnlimited (f : HyperNat) ↔ ∀ n : ℕ, ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), n < f i := by
  constructor
  · intro h n
    have := h n
    rw [standard_eq_coe, Filter.Germ.coe_lt] at this
    exact this
  · intro h n
    rw [standard_eq_coe, Filter.Germ.coe_lt]
    exact h n

/-- Every cofinite set of indices is large; a convenient repackaging of
`Nat.hyperfilter_le_atTop`. -/
theorem eventually_ge_hyperfilter (m : ℕ) :
    ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), m ≤ i :=
  Nat.hyperfilter_le_atTop (Filter.eventually_ge_atTop m)

/-! ## Overspill and underspill -/

open Classical in
/-- **Overspill.** An internal set containing every standard natural must
contain an unlimited hypernatural.  The witness is built by a diagonal
argument: at index `i` one takes the largest element of `A i` below `i`. -/
theorem overspill (A : InternalSet) (h : ∀ n : ℕ, standard n ∈* A) :
    ∃ H : HyperNat, IsUnlimited H ∧ H ∈* A := by
  refine Filter.Germ.inductionOn A (fun A hA => ?_) h
  -- `hA n` says that `n ∈ A i` for almost all `i`
  have hA' : ∀ n : ℕ, ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), n ∈ A i := by
    intro n
    have := hA n
    rw [standard_eq_coe, internalMem_coe] at this
    exact this
  classical
  set f : ℕ → ℕ := fun i => Nat.findGreatest (fun k => k ∈ A i) i with hf
  refine ⟨(f : HyperNat), ?_, ?_⟩
  · rw [isUnlimited_coe]
    intro n
    filter_upwards [hA' (n + 1), eventually_ge_hyperfilter (n + 1)] with i h1 h2
    exact Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (Nat.le_findGreatest h2 h1)
  · rw [internalMem_coe]
    filter_upwards [hA' 1, eventually_ge_hyperfilter 1] with i h1 h2
    exact Nat.findGreatest_spec h2 h1

/-- **Underspill.** An internal set containing every unlimited hypernatural
must already contain a standard natural. -/
theorem underspill (A : InternalSet) (h : ∀ H : HyperNat, IsUnlimited H → H ∈* A) :
    ∃ n : ℕ, standard n ∈* A := by
  by_contra hc
  push_neg at hc
  have hcompl : ∀ n : ℕ, standard n ∈* A.compl := by
    intro n
    exact (internalMem_compl _ _).mpr (hc n)
  obtain ⟨H, hH, hmem⟩ := overspill A.compl hcompl
  exact (internalMem_compl H A).mp hmem (h H hH)

/-- The standard cut is **not** an internal set: no internal set has exactly the
standard naturals as members. -/
theorem standard_not_internal :
    ¬ ∃ A : InternalSet, ∀ H : HyperNat, (H ∈* A ↔ IsStandard H) := by
  rintro ⟨A, hA⟩
  obtain ⟨H, hH, hmem⟩ := overspill A (fun n => (hA _).mpr (isStandard_standard n))
  exact not_isStandard_of_isUnlimited hH ((hA H).mp hmem)

/-! ## The least number principle -/

open Classical in
/-- **The least number principle survives for internal sets.**  A nonempty
internal set has a least element. -/
theorem internal_least_element (A : InternalSet) (h : ∃ H : HyperNat, H ∈* A) :
    ∃ H₀ : HyperNat, H₀ ∈* A ∧ ∀ K : HyperNat, K ∈* A → H₀ ≤ K := by
  obtain ⟨H, hH⟩ := h
  refine Filter.Germ.inductionOn A (fun A hA => ?_) hH
  refine Filter.Germ.inductionOn H (fun g hg => ?_) hA
  rw [internalMem_coe] at hg
  refine ⟨((fun i => sInf (A i) : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [internalMem_coe]
    filter_upwards [hg] with i hi
    exact Nat.sInf_mem ⟨g i, hi⟩
  · intro K hK
    refine Filter.Germ.inductionOn K (fun k hk => ?_) hK
    rw [internalMem_coe] at hk
    rw [Filter.Germ.coe_le]
    filter_upwards [hk] with i hi
    exact Nat.sInf_le hi

/-- **The least number principle fails for the external set of unlimited
elements**: below every unlimited hypernatural there is a smaller unlimited
one. -/
theorem no_least_unlimited (H : HyperNat) (hH : IsUnlimited H) :
    ∃ K : HyperNat, IsUnlimited K ∧ K < H := by
  refine Filter.Germ.inductionOn H (fun f hf => ?_) hH
  rw [isUnlimited_coe] at hf
  refine ⟨((fun i => f i - 1 : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [isUnlimited_coe]
    intro n
    filter_upwards [hf (n + 1)] with i hi
    omega
  · rw [Filter.Germ.coe_lt]
    filter_upwards [hf 0] with i hi
    omega

/-- Combining the previous two results: the unlimited part of the ultrapower is
an external set. -/
theorem unlimited_not_internal :
    ¬ ∃ A : InternalSet, ∀ H : HyperNat, (H ∈* A ↔ IsUnlimited H) := by
  rintro ⟨A, hA⟩
  obtain ⟨H₀, hmem, hmin⟩ :=
    internal_least_element A ⟨omega, (hA omega).mpr isUnlimited_omega⟩
  obtain ⟨K, hK, hlt⟩ := no_least_unlimited H₀ ((hA H₀).mp hmem)
  exact absurd (hmin K ((hA K).mpr hK)) (not_le.mpr hlt)

/-! ## Induction -/

open Classical in
/-- **Induction survives for internal sets.**  If an internal set contains `0`
and is closed under the successor of *every* hypernatural, it is everything. -/
theorem internal_induction (A : InternalSet) (h0 : standard 0 ∈* A)
    (hstep : ∀ H : HyperNat, H ∈* A → H + 1 ∈* A) : ∀ H : HyperNat, H ∈* A := by
  by_contra hc
  push_neg at hc
  obtain ⟨H, hH⟩ := hc
  refine Filter.Germ.inductionOn H (fun h hh => ?_) hH
  refine Filter.Germ.inductionOn A (fun A h0 hstep hh => ?_) h0 hstep hh
  classical
  rw [internalMem_coe] at hh
  rw [standard_eq_coe, internalMem_coe] at h0
  -- on a large set of indices, `0 ∈ A i` while `h i ∉ A i`
  have hnot : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), h i ∉ A i :=
    Ultrafilter.eventually_not.mpr hh
  -- the largest element of `A i` below `h i` is a pointwise witness of failure
  set c : ℕ → ℕ := fun i => Nat.findGreatest (fun k => k ∈ A i) (h i) with hc
  have hcmem : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), c i ∈ A i := by
    filter_upwards [h0] with i hi
    exact Nat.findGreatest_spec (Nat.zero_le _) hi
  have hcsucc : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), c i + 1 ∉ A i := by
    filter_upwards [h0, hnot] with i hi hni
    have hle : c i ≤ h i := Nat.findGreatest_le _
    have hne : c i ≠ h i := by
      intro hEq
      exact hni (hEq ▸ Nat.findGreatest_spec (Nat.zero_le _) hi)
    refine Nat.findGreatest_is_greatest (P := fun k => k ∈ A i) (n := h i) ?_ ?_
    · simp only [hc]; omega
    · omega
  have hmem : (c : HyperNat) ∈* (A : InternalSet) := (internalMem_coe _ _).mpr hcmem
  have hstep' := hstep (c : HyperNat) hmem
  rw [← transfer_successor c, internalMem_coe] at hstep'
  have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
    filter_upwards [hstep', hcsucc] with i h1 h2 using h2 h1
  rw [Filter.eventually_false_iff_eq_bot] at hfalse
  exact Filter.NeBot.ne inferInstance hfalse

/-- **Induction fails for external predicates.**  "Being standard" is preserved
by `0` and by successors, yet fails for `omega`. -/
theorem external_induction_fails :
    IsStandard (standard 0) ∧ (∀ H : HyperNat, IsStandard H → IsStandard (H + 1)) ∧
      ¬ (∀ H : HyperNat, IsStandard H) := by
  refine ⟨isStandard_standard 0, ?_, ?_⟩
  · rintro H ⟨n, rfl⟩
    exact ⟨n + 1, by
      show standard n + 1 = standard (n + 1)
      simp [standard, Nat.cast_add]⟩
  · intro hall
    exact not_isStandard_of_isUnlimited isUnlimited_omega (hall omega)

end NonstandardArithmetic