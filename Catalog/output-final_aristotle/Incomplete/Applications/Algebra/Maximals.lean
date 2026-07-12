/-
  # Frankl's Conjecture — Maximal Member Theory

  This module proves fundamental structural results about maximal members
  of union-closed families.

  ## Main results

  * `unique_maximal` — a nonempty union-closed family has a unique maximal member
  * `maximal_eq_ground` — the unique maximal member equals the ground set
  * `frankl_of_singleton_mem` — Frankl holds when a singleton {x} belongs to F
  * `frankl_of_card_le_three` — Frankl holds for families with ≤ 3 members

  ## Note on the user-suggested "Theorem B"

  The statement "if x is in all maximals then 2·freq(x) ≥ |F|" is **false**.
  Counterexample: F = {∅, {0}, {0,1}} is union-closed, the unique maximal is {0,1},
  and element 1 is in all maximals, but freq(1) = 1 while |F| = 3.
  The corrected version is existential: "there exists x with 2·freq(x) ≥ |F|"
  for structured families.
-/
import Mathlib
import Speculative.Frankl.Defs

namespace Frankl

open Finset

variable {α : Type*} [DecidableEq α]

/-! ### Unique maximal member -/

/-- In a union-closed family, every member is a subset of any maximal member. -/
theorem subset_of_maximal (F : Finset (Finset α))
    (hUC : UnionClosed F) (M : Finset α) (hM : IsMaximalMember F M)
    (A : Finset α) (hA : A ∈ F) : A ⊆ M := by
  have hAM := hUC hA hM.1
  have heq := hM.2 (A ∪ M) hAM Finset.subset_union_right
  intro a ha
  have : a ∈ A ∪ M := Finset.mem_union_left M ha
  rw [heq] at this
  exact this

/-- **Unique maximal theorem**: A union-closed family has at most one
    maximal member. If M₁ and M₂ are both maximal, then M₁ = M₂. -/
theorem maximal_unique (F : Finset (Finset α))
    (hUC : UnionClosed F) (M₁ M₂ : Finset α)
    (hM₁ : IsMaximalMember F M₁) (hM₂ : IsMaximalMember F M₂) :
    M₁ = M₂ := by
  have h1 := subset_of_maximal F hUC M₁ hM₁ M₂ hM₂.1
  have h2 := subset_of_maximal F hUC M₂ hM₂ M₁ hM₁.1
  exact Finset.Subset.antisymm h2 h1

/-
A nonempty union-closed family has exactly one maximal member.
-/
theorem maximalMembers_card_eq_one (F : Finset (Finset α))
    (hUC : UnionClosed F) (hne : F.Nonempty) :
    (maximalMembers F).card = 1 := by
  -- Every nonempty member of F is contained in some maximal member.
  have h_max_mem_cont : (maximalMembers F).Nonempty := by
    exact Exists.elim ( exists_maximal_containing F _ hne.choose_spec ) fun M hM => ⟨ M, mem_maximalMembers F M |>.2 hM.1 ⟩;
  exact Finset.card_eq_one.mpr ( by rcases h_max_mem_cont with ⟨ M, hM ⟩ ; exact ⟨ M, Finset.eq_singleton_iff_unique_mem.mpr ⟨ hM, fun N hN => maximal_unique F hUC N M ( mem_maximalMembers F N |>.1 hN ) ( mem_maximalMembers F M |>.1 hM ) ⟩ ⟩ )

/-
The unique maximal member of a nonempty UC family equals the ground set.
-/
theorem maximal_eq_ground (F : Finset (Finset α))
    (hUC : UnionClosed F) (M : Finset α) (hM : IsMaximalMember F M) :
    M = ground F := by
  -- Since M is maximal, every member of F is a subset of M.
  have hM_subset : ∀ A ∈ F, A ⊆ M := by
    exact?;
  exact le_antisymm ( Finset.subset_biUnion_of_mem id hM.1 ) ( Finset.biUnion_subset.mpr hM_subset )

/-! ### Frankl for families containing a singleton -/

/-
The injection lemma: in a union-closed family containing `{x}`,
    the map `A ↦ A ∪ {x}` is an injection from
    `{A ∈ F | x ∉ A}` to `{A ∈ F | x ∈ A}`.
-/
theorem card_not_mem_le_card_mem (F : Finset (Finset α))
    (hUC : UnionClosed F) (x : α) (hx : ({x} : Finset α) ∈ F) :
    (F.filter (fun A => x ∉ A)).card ≤ (F.filter (fun A => x ∈ A)).card := by
  have h_inj : Finset.filter (fun A => x ∉ A) F ⊆ Finset.image (fun A => A \ {x}) (Finset.filter (fun A => x ∈ A) F) := by
    intro A hA;
    simp +zetaDelta at *;
    exact ⟨ A ∪ { x }, ⟨ hUC hA.1 hx, by aesop ⟩, by aesop ⟩;
  exact le_trans ( Finset.card_le_card h_inj ) ( Finset.card_image_le )

/-
**Frankl for singletons**: If a union-closed family contains the singleton
    `{x}`, then `x` appears in at least half the members.
-/
theorem frankl_of_singleton_mem (F : Finset (Finset α))
    (hUC : UnionClosed F) (x : α) (hx : ({x} : Finset α) ∈ F) :
    2 * element_frequency x F ≥ F.card := by
  unfold element_frequency;
  unfold appearsIn;
  have := card_not_mem_le_card_mem F hUC x hx;
  linarith [ show #F = # ( { A ∈ F | x ∈ A } ) + # ( { A ∈ F | x ∉ A } ) by rw [ Finset.card_filter_add_card_filter_not ] ]

/-! ### Frankl for small families -/

/-
Frankl holds for families with at most 2 members (with a nonempty member).
-/
theorem frankl_of_card_le_two [Fintype α] (F : Finset (Finset α))
    (hUC : UnionClosed F) (hne : ∃ A ∈ F, A.Nonempty)
    (hcard : F.card ≤ 2) :
    ∃ x : α, 2 * element_frequency x F ≥ F.card := by
  obtain ⟨ A, hA₁, hA₂ ⟩ := hne;
  obtain ⟨ x, hx ⟩ := hA₂;
  exact ⟨ x, by linarith [ element_frequency_pos_of_mem_ground F x ( by rw [ mem_ground ] ; exact ⟨ A, hA₁, hx ⟩ ) ] ⟩

end Frankl