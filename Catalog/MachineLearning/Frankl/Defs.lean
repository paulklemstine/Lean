/-
  # Frankl's Union-Closed Conjecture — Core Definitions

  This module provides the foundational definitions for studying
  Frankl's union-closed families conjecture in a finite-set setting.

  ## Main definitions

  * `Frankl.UnionClosed` — a family closed under pairwise union
  * `Frankl.ground` — the union of all members
  * `Frankl.appearsIn` — the subfamily containing a given element
  * `Frankl.element_frequency` — how many members contain an element
  * `Frankl.IsMaximalMember` — maximality w.r.t. inclusion
  * `Frankl.maximalMembers` — the finset of all maximal members
  * `Frankl.dualFamily` — complement-dual relative to a ground set
-/
import Mathlib

namespace Frankl

variable {α : Type*} [DecidableEq α]

/-- A family `F` of finite sets is **union-closed** if for every two members
    `A, B ∈ F`, the union `A ∪ B` also belongs to `F`. -/
def UnionClosed (F : Finset (Finset α)) : Prop :=
  ∀ ⦃A B⦄, A ∈ F → B ∈ F → A ∪ B ∈ F

/-- The **ground set** of a family `F` is the union of all its members. -/
def ground (F : Finset (Finset α)) : Finset α :=
  F.biUnion id

/-- The subfamily of `F` consisting of all sets that contain `x`. -/
def appearsIn (x : α) (F : Finset (Finset α)) : Finset (Finset α) :=
  F.filter (fun A => x ∈ A)

/-- The **element frequency** of `x` in `F`: the number of members of `F` containing `x`. -/
def element_frequency (x : α) (F : Finset (Finset α)) : Nat :=
  (appearsIn x F).card

/-- A member `M` of `F` is **maximal** if no strictly larger member of `F` contains it. -/
def IsMaximalMember (F : Finset (Finset α)) (M : Finset α) : Prop :=
  M ∈ F ∧ ∀ A ∈ F, M ⊆ A → A = M

/-- The finset of all maximal members of `F`. -/
def maximalMembers (F : Finset (Finset α)) : Finset (Finset α) :=
  F.filter (fun M => ∀ A ∈ F, M ⊆ A → A = M)

/-- The **dual family** of `F` relative to a ground set `U`:
    complement each member within `U`. -/
def dualFamily (U : Finset α) (F : Finset (Finset α)) : Finset (Finset α) :=
  F.image fun A => U \ A

/-! ## Basic API lemmas -/

theorem appearsIn_subset (x : α) (F : Finset (Finset α)) :
    appearsIn x F ⊆ F :=
  Finset.filter_subset _ _

theorem mem_appearsIn (x : α) (F : Finset (Finset α)) (A : Finset α) :
    A ∈ appearsIn x F ↔ A ∈ F ∧ x ∈ A := by
  simp [appearsIn, Finset.mem_filter]

theorem element_frequency_le_card (x : α) (F : Finset (Finset α)) :
    element_frequency x F ≤ F.card :=
  Finset.card_le_card (appearsIn_subset x F)

theorem mem_ground (F : Finset (Finset α)) (x : α) :
    x ∈ ground F ↔ ∃ A ∈ F, x ∈ A := by
  simp [ground, Finset.mem_biUnion]

theorem maximalMembers_subset (F : Finset (Finset α)) :
    maximalMembers F ⊆ F :=
  Finset.filter_subset _ _

theorem mem_maximalMembers (F : Finset (Finset α)) (M : Finset α) :
    M ∈ maximalMembers F ↔ IsMaximalMember F M := by
  simp [maximalMembers, IsMaximalMember, Finset.mem_filter]

theorem element_frequency_pos_of_mem_ground
    (F : Finset (Finset α)) (x : α) (hx : x ∈ ground F) :
    0 < element_frequency x F := by
  rw [mem_ground] at hx
  obtain ⟨A, hAF, hxA⟩ := hx
  exact Finset.card_pos.mpr ⟨A, (mem_appearsIn x F A).mpr ⟨hAF, hxA⟩⟩

theorem ground_subset_of_mem {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (A : Finset α) (hA : A ∈ F) :
    A ⊆ ground F := by
  intro x hx
  rw [mem_ground]
  exact ⟨A, hA, hx⟩

/-- Every nonempty member of a union-closed family yields a nonempty ground set. -/
theorem ground_nonempty_of_nonempty_member
    (F : Finset (Finset α)) (hne : ∃ A ∈ F, A.Nonempty) :
    (ground F).Nonempty := by
  obtain ⟨A, hAF, ⟨x, hx⟩⟩ := hne
  exact ⟨x, (mem_ground F x).mpr ⟨A, hAF, hx⟩⟩

/-- In a union-closed family with a nonempty member, `F` itself is nonempty. -/
theorem family_nonempty_of_nonempty_member
    (F : Finset (Finset α)) (hne : ∃ A ∈ F, A.Nonempty) :
    F.Nonempty := by
  obtain ⟨A, hAF, _⟩ := hne
  exact ⟨A, hAF⟩

/-
Every member of `F` is contained in some maximal member.
-/
theorem exists_maximal_containing
    (F : Finset (Finset α)) (A : Finset α) (hA : A ∈ F) :
    ∃ M, IsMaximalMember F M ∧ A ⊆ M := by
  -- We pick a maximal element by Finset induction on cardinality
  have : ∃ M ∈ F, A ⊆ M ∧ ∀ B ∈ F, M ⊆ B → B = M := by
    by_contra h
    push_neg at h
    -- For every member containing A, there's a strictly larger member
    -- But F is finite, so this is impossible
    -- We prove this by strong induction on |ground F| - |M|
    -- By repeatedly applying the hypothesis `h`, we can construct an infinite sequence of distinct sets in `F` containing `A`.
    have h_seq : ∀ n : ℕ, ∃ B ∈ F, A ⊆ B ∧ B.card ≥ n := by
      intro n
      induction' n with n ih;
      · exact ⟨ A, hA, Finset.Subset.refl _, Nat.zero_le _ ⟩;
      · obtain ⟨ B, hB₁, hB₂, hB₃ ⟩ := ih; obtain ⟨ C, hC₁, hC₂, hC₃ ⟩ := h B hB₁ hB₂; exact ⟨ C, hC₁, hB₂.trans hC₂, Nat.succ_le_of_lt ( lt_of_le_of_lt hB₃ ( Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ hC₂, by aesop ⟩ ) ) ) ⟩ ;
    contrapose! h_seq;
    exact ⟨ F.sup ( fun B => B.card ) + 1, fun B hB hAB => Nat.lt_succ_of_le ( Finset.le_sup ( f := fun B => B.card ) hB ) ⟩
  obtain ⟨M, hMF, hAM, hMax⟩ := this
  exact ⟨M, ⟨hMF, hMax⟩, hAM⟩

end Frankl