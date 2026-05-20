/-
  # Frankl's Union-Closed Conjecture — Frequency Potential Formalism

  This module introduces a frequency-potential framework for studying
  Frankl's union-closed families conjecture. The key insight is to view
  a finite union-closed family as a join-semilattice equipped with an
  element-frequency functional, converting Frankl's conjecture into a
  statement about the existence of a "heavy atom."

  ## Main definitions

  * `Frankl.elemFreq` — the frequency (abundance) of an element in a family
  * `Frankl.IsFranklWitness` — an element appearing in ≥ half the sets
  * `Frankl.totalWeight` — the sum of all set sizes in the family
  * `Frankl.IsUnionClosedFamily` — union-closed family with ∅
  * `Frankl.support` — the ground set (union of all members)
-/
import Mathlib

namespace Frankl

open Finset

variable {α : Type*} [DecidableEq α]

/-! ### Core definitions -/

/-- The **element frequency** (abundance) of `a` in the family `F`:
    the number of members of `F` that contain `a`. -/
def elemFreq (F : Finset (Finset α)) (a : α) : ℕ :=
  (F.filter fun s => a ∈ s).card

/-- An element `a` is a **Frankl witness** for `F` if `a` belongs to
    at least half the members of `F`. -/
def IsFranklWitness (F : Finset (Finset α)) (a : α) : Prop :=
  2 * elemFreq F a ≥ F.card

/-- The **total weight** of a family `F`: the sum of all set sizes. -/
def totalWeight (F : Finset (Finset α)) : ℕ :=
  ∑ s ∈ F, s.card

/-- A family `F` is **union-closed** and contains the empty set. -/
def IsUnionClosedFamily (F : Finset (Finset α)) : Prop :=
  ∅ ∈ F ∧ ∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F

/-- The **support** (ground set) of a family: the union of all members. -/
def support (F : Finset (Finset α)) : Finset α :=
  F.biUnion id

/-! ### Basic API lemmas -/

theorem elemFreq_def (F : Finset (Finset α)) (a : α) :
    elemFreq F a = (F.filter fun s => a ∈ s).card := rfl

omit [DecidableEq α] in
theorem totalWeight_def (F : Finset (Finset α)) :
    totalWeight F = ∑ s ∈ F, s.card := rfl

theorem elemFreq_le_card (F : Finset (Finset α)) (a : α) :
    elemFreq F a ≤ F.card :=
  Finset.card_le_card (Finset.filter_subset _ _)

theorem mem_support_iff (F : Finset (Finset α)) (a : α) :
    a ∈ support F ↔ ∃ s ∈ F, a ∈ s := by
  simp [support, Finset.mem_biUnion]

theorem elemFreq_pos_of_mem_support (F : Finset (Finset α)) (a : α)
    (ha : a ∈ support F) : 0 < elemFreq F a := by
  rw [mem_support_iff] at ha
  obtain ⟨s, hsF, has⟩ := ha
  exact Finset.card_pos.mpr ⟨s, Finset.mem_filter.mpr ⟨hsF, has⟩⟩

theorem support_nonempty_of_nonempty_member (F : Finset (Finset α))
    (h : ∃ A ∈ F, A.Nonempty) : (support F).Nonempty := by
  obtain ⟨A, hAF, ⟨x, hx⟩⟩ := h
  exact ⟨x, (mem_support_iff F x).mpr ⟨A, hAF, hx⟩⟩

theorem elemFreq_empty (a : α) : elemFreq (∅ : Finset (Finset α)) a = 0 := by
  simp [elemFreq]

omit [DecidableEq α] in
theorem totalWeight_empty : totalWeight (∅ : Finset (Finset α)) = 0 := by
  simp [totalWeight]

/-- The frequency of `a` in `F` equals the sum of indicator values. -/
theorem elemFreq_eq_sum_indicator (F : Finset (Finset α)) (a : α) :
    elemFreq F a = ∑ s ∈ F, if a ∈ s then 1 else 0 := by
  rw [elemFreq, Finset.card_filter]

end Frankl