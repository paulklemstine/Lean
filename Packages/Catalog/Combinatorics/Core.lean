/-
# Core definitions for agreement subtrees of phylogenetic trees

NOTE (restored module).  `Novelty/AgreementSubtreesMultiple.lean` and
`Novelty/AgreementSubtreesCounting.lean` are written against this module, which was missing
from the catalogue, so neither of them compiled.  This file restores the four basic notions
they use: split systems, their restriction to a retained leaf set, agreement of two trees on a
leaf set, and common agreement of a whole family.

A phylogenetic tree on a leaf set is recorded by the finite family of *split sides* it
displays; restricting the tree to a subset `A` of the leaves intersects every displayed split
with `A`.  Agreement of two trees on `A` then means that they display the same splits after
restriction.
-/
import Mathlib

open Finset

namespace AgreementSubtrees

/-- A **split system**: the finite family of split sides displayed by a phylogenetic tree on a
leaf set of type `α`. -/
abbrev SplitSystem (α : Type*) : Type _ := Finset (Finset α)

/-- **Restriction** of a split system to the retained leaf set `A`: every displayed split side
is intersected with `A`. -/
def restrict {α : Type*} [DecidableEq α] (T : SplitSystem α) (A : Finset α) : SplitSystem α :=
  T.image (fun s => s ∩ A)

/-- Two trees **agree on** the leaf set `A` when their restrictions to `A` coincide. -/
def AgreeOn {α : Type*} [DecidableEq α] (T U : SplitSystem α) (A : Finset α) : Prop :=
  restrict T A = restrict U A

/-- A family `F` of trees has a **common agreement subtree** on `A`: all the trees indexed by
`F` restrict to one and the same split system on `A`. -/
def CommonAgreement {α ι : Type*} [DecidableEq α] (F : Finset ι) (T : ι → SplitSystem α)
    (A : Finset α) : Prop :=
  ∃ R : SplitSystem α, ∀ i ∈ F, restrict (T i) A = R

/-- Agreement is reflexive. -/
theorem agreeOn_refl {α : Type*} [DecidableEq α] (T : SplitSystem α) (A : Finset α) :
    AgreeOn T T A := rfl

/-- Agreement is symmetric. -/
theorem agreeOn_symm {α : Type*} [DecidableEq α] {T U : SplitSystem α} {A : Finset α}
    (h : AgreeOn T U A) : AgreeOn U T A := Eq.symm h

/-- Agreement is transitive. -/
theorem agreeOn_trans {α : Type*} [DecidableEq α] {T U V : SplitSystem α} {A : Finset α}
    (h₁ : AgreeOn T U A) (h₂ : AgreeOn U V A) : AgreeOn T V A := Eq.trans h₁ h₂

/-- Restricting twice is restricting once, provided the second leaf set is contained in the
first. -/
theorem restrict_restrict {α : Type*} [DecidableEq α] (T : SplitSystem α) {A A' : Finset α}
    (h : A' ⊆ A) : restrict (restrict T A) A' = restrict T A' := by
  unfold restrict
  rw [Finset.image_image]
  refine Finset.image_congr fun s _ => ?_
  simp only [Function.comp_apply, Finset.inter_assoc, Finset.inter_eq_right.mpr h]

/-- Common agreement is inherited by smaller leaf sets. -/
theorem commonAgreement_subset {α ι : Type*} [DecidableEq α] {F : Finset ι}
    {T : ι → SplitSystem α} {A A' : Finset α} (h : A' ⊆ A) (hc : CommonAgreement F T A) :
    CommonAgreement F T A' := by
  obtain ⟨R, hR⟩ := hc
  refine ⟨restrict R A', fun i hi => ?_⟩
  rw [← restrict_restrict (T i) h, hR i hi]

/-- `IsAgreementThreshold m k n` says that any `k` phylogenetic trees on a common leaf set of
at least `m` leaves admit a common agreement subtree on at least `n` leaves. -/
def IsAgreementThreshold (m k n : ℕ) : Prop :=
  ∀ (α : Type) [DecidableEq α] (L : Finset α) (T : Fin k → SplitSystem α),
    m ≤ L.card → ∃ A ⊆ L, n ≤ A.card ∧ CommonAgreement (Finset.univ : Finset (Fin k)) T A

/-- **Quartet transfer.**  A threshold forcing an agreement subtree on `n ≥ 4` leaves forces in
particular an agreement subtree on four leaves — a common quartet. -/
theorem agreementThreshold_implies_quartetThreshold {m k n : ℕ} (hn : 4 ≤ n)
    (h : IsAgreementThreshold m k n) : IsAgreementThreshold m k 4 := by
  intro α inst L T hm
  obtain ⟨A, hAL, hAn, hA⟩ := h α L T hm
  obtain ⟨A', hA'A, hA'card⟩ :=
    Finset.exists_subset_card_eq (show 4 ≤ A.card from le_trans hn hAn)
  exact ⟨A', hA'A.trans hAL, by omega, commonAgreement_subset hA'A hA⟩

/-- A common agreement on `F` makes every two members of `F` agree. -/
theorem commonAgreement_agreeOn {α ι : Type*} [DecidableEq α] {F : Finset ι}
    {T : ι → SplitSystem α} {A : Finset α} (h : CommonAgreement F T A) :
    ∀ i ∈ F, ∀ j ∈ F, AgreeOn (T i) (T j) A := by
  obtain ⟨R, hR⟩ := h
  exact fun i hi j hj => by rw [AgreeOn, hR i hi, hR j hj]

end AgreementSubtrees