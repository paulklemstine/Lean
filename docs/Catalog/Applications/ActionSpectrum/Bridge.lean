import Applications.ActionSpectrum.Basic

/-!
# Bridging the computable spectrum with Mathlib's orbit machinery, and Burnside's lemma

The definition `SubsetSpectrum.spec` counts orbits by taking the image of the map
`s ↦ orb G s` on `Finset.powersetCard`.  This file certifies that it really is the number of
orbits of the induced `G`-action on the type of `r`-element subsets:

* `SubsetSpectrum.spec_eq_card_orbitQuotient` :
  `t_r = |(r-subsets)/G|` in Mathlib's `MulAction.orbitRel` sense;
* `SubsetSpectrum.spec_mul_card_eq_sum_fixed` : **Burnside's mass formula** for the spectrum,
  `t_r · |G| = ∑_{g ∈ G} #{ s : |s| = r, g·s = s }`.

Together with the sandwich `C(n,r)/|G| ≤ t_r ≤ C(n,r)` of the basic file this gives an
independent handle on the spectrum: for instance the identity element alone contributes
`C(n,r)` to the right-hand sum.
-/

open Finset

namespace SubsetSpectrum

variable {G X : Type*} [Group G] [MulAction G X] [DecidableEq X] [Fintype G] [Fintype X]

variable (G X) in
/-- The type of `r`-element subsets of `X`, carrying the induced `G`-action. -/
abbrev Subsets (r : ℕ) := {s : Finset X // s.card = r}

variable (r : ℕ)

instance : SMul G (Subsets X r) := ⟨fun g s => ⟨act g s.1, by rw [act_card, s.2]⟩⟩

omit [Fintype G] [Fintype X] in
@[simp] lemma coe_smul_subsets (g : G) (s : Subsets X r) : ((g • s : Subsets X r) : Finset X)
    = act g s.1 := rfl

instance : MulAction G (Subsets X r) where
  one_smul s := Subtype.ext (by simp)
  mul_smul g h s := Subtype.ext (by simp [act_mul])

instance : DecidableEq (Subsets X r) := fun _ _ => decidable_of_iff _ Subtype.ext_iff.symm

instance : DecidableRel (MulAction.orbitRel G (Subsets X r)).r := fun s t =>
  decidable_of_iff (∃ g : G, g • t = s) (by
    constructor
    · rintro ⟨g, hg⟩; exact ⟨g, hg⟩
    · rintro ⟨g, hg⟩; exact ⟨g, hg⟩)

omit [Fintype X] in
/-- The orbit map descends to the orbit quotient. -/
private lemma orb_congr {s t : Subsets X r} (h : (MulAction.orbitRel G (Subsets X r)).r s t) :
    orb G s.1 = orb G t.1 := by
  obtain ⟨g, hg⟩ := h
  have : act g t.1 = s.1 := congrArg Subtype.val hg
  exact orb_eq_of_mem (by
    simp only [orb, Finset.mem_image, mem_univ, true_and]
    exact ⟨g, this⟩)

/-- The `r`-element subsets, as the image of the subtype. -/
private lemma powersetCard_eq_image_val :
    (univ : Finset X).powersetCard r = univ.image (Subtype.val : Subsets X r → Finset X) := by
  ext s
  simp only [mem_powersetCard, Finset.subset_univ, true_and, mem_image, mem_univ]
  constructor
  · intro h; exact ⟨⟨s, h⟩, rfl⟩
  · rintro ⟨⟨t, ht⟩, rfl⟩; exact ht

/-- **The computable spectrum is the orbit count.**  `t_r` equals the cardinality of the
quotient of the `r`-element subsets by the induced `G`-action. -/
theorem spec_eq_card_orbitQuotient :
    spec G X r = Fintype.card (Quotient (MulAction.orbitRel G (Subsets X r))) := by
  set F : Quotient (MulAction.orbitRel G (Subsets X r)) → Finset (Finset X) :=
    Quotient.lift (fun s : Subsets X r => orb G s.1) (fun _ _ h => orb_congr r h) with hF
  have hinj : Function.Injective F := by
    intro q q'
    induction q using Quotient.inductionOn with
    | h s =>
      induction q' using Quotient.inductionOn with
      | h t =>
        intro h
        have h' : orb G s.1 = orb G t.1 := h
        have hmem : t.1 ∈ orb G s.1 := by rw [h']; exact mem_orb_self _
        simp only [orb, Finset.mem_image, mem_univ, true_and] at hmem
        obtain ⟨g, hg⟩ := hmem
        refine Quotient.sound ⟨g⁻¹, Subtype.ext ?_⟩
        show act g⁻¹ t.1 = s.1
        rw [← hg, ← act_mul, inv_mul_cancel, act_one]
  have himg : (univ.image F) = ((univ : Finset X).powersetCard r).image (orb G) := by
    ext O
    simp only [Finset.mem_image, mem_univ, true_and]
    constructor
    · rintro ⟨q, rfl⟩
      induction q using Quotient.inductionOn with
      | h s => exact ⟨s.1, mem_powersetCard.2 ⟨subset_univ _, s.2⟩, rfl⟩
    · rintro ⟨s, hs, rfl⟩
      exact ⟨Quotient.mk _ ⟨s, (mem_powersetCard.1 hs).2⟩, rfl⟩
  calc spec G X r = (univ.image F).card := by rw [spec, himg]
    _ = Fintype.card (Quotient (MulAction.orbitRel G (Subsets X r))) := by
        rw [Finset.card_image_of_injective _ hinj, Finset.card_univ]

/-- **Burnside's mass formula for the subset spectrum**:
`t_r · |G| = ∑_{g ∈ G} #{ s ⊆ X : |s| = r and g·s = s }`. -/
theorem spec_mul_card_eq_sum_fixed :
    spec G X r * Fintype.card G
      = ∑ g : G, (((univ : Finset X).powersetCard r).filter (fun s => act g s = s)).card := by
  rw [spec_eq_card_orbitQuotient,
    ← MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G (Subsets X r)]
  refine Finset.sum_congr rfl ?_
  intro g _
  have hcard : Fintype.card (MulAction.fixedBy (Subsets X r) g)
      = (univ.filter (fun s : Subsets X r => g • s = s)).card := by
    rw [Fintype.card_subtype]
    rfl
  rw [hcard]
  refine Finset.card_bij (fun (s : Subsets X r) _ => s.1) ?_ ?_ ?_
  · intro s hs
    simp only [Finset.mem_filter, mem_univ, true_and] at hs ⊢
    exact ⟨mem_powersetCard.2 ⟨subset_univ _, s.2⟩, congrArg Subtype.val hs⟩
  · intro s _ t _ h
    exact Subtype.ext h
  · intro s hs
    simp only [Finset.mem_filter] at hs
    refine ⟨⟨s, (mem_powersetCard.1 hs.1).2⟩, ?_, rfl⟩
    simp only [Finset.mem_filter, mem_univ, true_and]
    exact Subtype.ext hs.2

end SubsetSpectrum