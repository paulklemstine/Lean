import Algebra.PosetFlow.HallMobius

/-!
# The Möbius function is the reduced Euler characteristic of the open interval

This file synthesises the two main computations of this development:

* `PosetFlow.alternatingSum_orderComplex_eq_zero_of_conePoint` (a cone is acyclic),
* `PosetFlow.chainAltSum_eq_neg_mu` (Philip Hall's theorem).

Removing the two endpoints identifies the chains from `x` to `y` with the faces of
the order complex of the open interval `(x, y)`.  Hence Hall's theorem becomes the
classical statement that the Möbius function of an interval is (up to sign) the
reduced Euler characteristic of the order complex of its interior, and the cone
argument yields a vanishing criterion for the Möbius function.

## Main results

* `PosetFlow.alternatingSum_openInterval_eq_neg_mu` : for `x < y` in a finite poset,
  the alternating face sum of the order complex of the open interval `(x, y)` is
  `-μ x y`.
* `PosetFlow.mu_eq_zero_of_conePoint_openInterval` : if the open interval `(x, y)`
  has an element comparable with all of its elements, then `μ x y = 0`.  In
  particular this applies to the refinement posets of chains of the chain
  replacement, whose least element is a cone point.
-/

namespace PosetFlow

open Finset IncidenceAlgebra

variable {P : Type*} [PartialOrder P] [Fintype P] [DecidableEq P] [DecidableLE P]
variable [LocallyFiniteOrder P]

/-- The open interval `(x, y)` of a finite poset, as a type. -/
abbrev openInterval (x y : P) : Type _ := {a : P // a ∈ Finset.Ioo x y}

variable {x y : P}

/-- Adjoining the two endpoints to a face of the order complex of the open interval
`(x, y)` produces a chain from `x` to `y`. -/
private def addEnds (x y : P) (F : Finset (openInterval x y)) : Finset P :=
  insert x (insert y (F.image Subtype.val))

omit [Fintype P] [DecidableLE P] in
private theorem mem_addEnds {F : Finset (openInterval x y)} {a : P} :
    a ∈ addEnds x y F ↔ a = x ∨ a = y ∨ ∃ b ∈ F, (b : P) = a := by
  simp [addEnds, Finset.mem_insert, Finset.mem_image, eq_comm]

private theorem addEnds_mem_chainFinsets (hxy : x < y) {F : Finset (openInterval x y)}
    (hF : IsOrderChain F) : addEnds x y F ∈ chainFinsets x y := by
  have hbdd : ∀ a ∈ addEnds x y F, x ≤ a ∧ a ≤ y := by
    intro a ha
    rcases mem_addEnds.1 ha with rfl | rfl | ⟨b, _, rfl⟩
    · exact ⟨le_refl _, le_of_lt hxy⟩
    · exact ⟨le_of_lt hxy, le_refl _⟩
    · obtain ⟨h1, h2⟩ := Finset.mem_Ioo.1 b.2
      exact ⟨le_of_lt h1, le_of_lt h2⟩
  rw [mem_chainFinsets]
  refine ⟨mem_addEnds.2 (Or.inl rfl), mem_addEnds.2 (Or.inr (Or.inl rfl)), hbdd, ?_⟩
  intro a ha b hb
  rcases mem_addEnds.1 ha with rfl | rfl | ⟨u, hu, rfl⟩
  · exact Or.inl (hbdd b hb).1
  · exact Or.inr (hbdd b hb).2
  · rcases mem_addEnds.1 hb with rfl | rfl | ⟨v, hv, rfl⟩
    · exact Or.inr (hbdd _ ha).1
    · exact Or.inl (hbdd _ ha).2
    · rcases hF u hu v hv with h | h
      · exact Or.inl h
      · exact Or.inr h

omit [Fintype P] [DecidableLE P] in
private theorem card_addEnds (hxy : x < y) (F : Finset (openInterval x y)) :
    (addEnds x y F).card = F.card + 2 := by
  have himg : (F.image Subtype.val).card = F.card :=
    Finset.card_image_of_injective _ Subtype.val_injective
  have hy : y ∉ F.image Subtype.val := by
    intro hy
    obtain ⟨b, _, hb⟩ := Finset.mem_image.1 hy
    have hlt := (Finset.mem_Ioo.1 b.2).2
    rw [hb] at hlt
    exact lt_irrefl y hlt
  have hx : x ∉ insert y (F.image Subtype.val) := by
    intro hx
    rcases Finset.mem_insert.1 hx with h | h
    · exact absurd h (ne_of_lt hxy)
    · obtain ⟨b, _, hb⟩ := Finset.mem_image.1 h
      have hlt := (Finset.mem_Ioo.1 b.2).1
      rw [hb] at hlt
      exact lt_irrefl x hlt
  rw [addEnds, Finset.card_insert_of_notMem hx, Finset.card_insert_of_notMem hy, himg]

/-- **The Möbius function as a reduced Euler characteristic.**  For `x < y` in a
finite poset, the alternating sum over the faces of the order complex of the open
interval `(x, y)` (the empty face included) equals `-μ x y`. -/
theorem alternatingSum_openInterval_eq_neg_mu (hxy : x < y) :
    ∑ F ∈ orderComplex (openInterval x y), (-1 : ℤ) ^ F.card = -mu ℤ x y := by
  rw [← chainAltSum_eq_neg_mu, chainAltSum]
  refine Finset.sum_nbij (addEnds x y) ?_ ?_ ?_ ?_
  · intro F hF
    rw [mem_orderComplex] at hF
    exact addEnds_mem_chainFinsets hxy hF
  · -- injectivity
    intro F _ F' _ heq
    have himg : F.image Subtype.val = F'.image Subtype.val := by
      apply Finset.Subset.antisymm
      · intro a ha
        obtain ⟨b, hb, rfl⟩ := Finset.mem_image.1 ha
        have hmem : (b : P) ∈ addEnds x y F' := by
          rw [← heq]; exact mem_addEnds.2 (Or.inr (Or.inr ⟨b, hb, rfl⟩))
        rcases mem_addEnds.1 hmem with h | h | ⟨c, hc, hcb⟩
        · exfalso
          have hlt := (Finset.mem_Ioo.1 b.2).1
          rw [h] at hlt
          exact lt_irrefl x hlt
        · exfalso
          have hlt := (Finset.mem_Ioo.1 b.2).2
          rw [h] at hlt
          exact lt_irrefl y hlt
        · exact Finset.mem_image.2 ⟨c, hc, hcb⟩
      · intro a ha
        obtain ⟨b, hb, rfl⟩ := Finset.mem_image.1 ha
        have hmem : (b : P) ∈ addEnds x y F := by
          rw [heq]; exact mem_addEnds.2 (Or.inr (Or.inr ⟨b, hb, rfl⟩))
        rcases mem_addEnds.1 hmem with h | h | ⟨c, hc, hcb⟩
        · exfalso
          have hlt := (Finset.mem_Ioo.1 b.2).1
          rw [h] at hlt
          exact lt_irrefl x hlt
        · exfalso
          have hlt := (Finset.mem_Ioo.1 b.2).2
          rw [h] at hlt
          exact lt_irrefl y hlt
        · exact Finset.mem_image.2 ⟨c, hc, hcb⟩
    ext b
    constructor
    · intro hb
      obtain ⟨c, hc, hcb⟩ := Finset.mem_image.1 (himg ▸ Finset.mem_image_of_mem Subtype.val hb)
      exact Subtype.val_injective hcb ▸ hc
    · intro hb
      obtain ⟨c, hc, hcb⟩ :=
        Finset.mem_image.1 (himg.symm ▸ Finset.mem_image_of_mem Subtype.val hb)
      exact Subtype.val_injective hcb ▸ hc
  · -- surjectivity
    intro C hC
    rw [Finset.mem_coe, mem_chainFinsets] at hC
    obtain ⟨h1, h2, h3, h4⟩ := hC
    refine ⟨C.subtype (fun a => a ∈ Finset.Ioo x y), ?_, ?_⟩
    · rw [Finset.mem_coe, mem_orderComplex]
      intro u hu v hv
      exact h4 u (Finset.mem_subtype.1 hu) v (Finset.mem_subtype.1 hv)
    · apply Finset.Subset.antisymm
      · intro a ha
        rcases mem_addEnds.1 ha with rfl | rfl | ⟨b, hb, rfl⟩
        · exact h1
        · exact h2
        · exact Finset.mem_subtype.1 hb
      · intro a ha
        by_cases hax : a = x
        · exact mem_addEnds.2 (Or.inl hax)
        by_cases hay : a = y
        · exact mem_addEnds.2 (Or.inr (Or.inl hay))
        · have hmem : a ∈ Finset.Ioo x y :=
            Finset.mem_Ioo.2 ⟨lt_of_le_of_ne (h3 a ha).1 (Ne.symm hax),
              lt_of_le_of_ne (h3 a ha).2 hay⟩
          exact mem_addEnds.2 (Or.inr (Or.inr ⟨⟨a, hmem⟩, Finset.mem_subtype.2 ha, rfl⟩))
  · intro F hF
    rw [card_addEnds hxy, pow_add]
    simp

/-- **A vanishing criterion for the Möbius function.**  If the open interval
`(x, y)` contains an element comparable with all of its elements, then `μ x y = 0`:
the order complex of the interval is a cone, hence acyclic. -/
theorem mu_eq_zero_of_conePoint_openInterval (hxy : x < y) (z : openInterval x y)
    (hz : ∀ w : openInterval x y, z ≤ w ∨ w ≤ z) : mu ℤ x y = 0 := by
  have h := alternatingSum_orderComplex_eq_zero_of_conePoint z hz
  rw [alternatingSum_openInterval_eq_neg_mu hxy] at h
  exact neg_eq_zero.1 h

end PosetFlow