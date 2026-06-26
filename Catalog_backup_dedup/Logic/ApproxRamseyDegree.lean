import Mathlib

/-!
# The finite combinatorial core of approximate Ramsey degrees

This file isolates the finite combinatorial skeleton underlying the notion of an
*approximate Ramsey degree*.  We work with three finite types of "homomorphisms"
`HomBA`, `HomCB`, `HomCA` together with a composition map
`comp : HomCB → HomBA → HomCA`.

Given a colouring `χ : HomCA → κ` and a fixed `π : HomCB`, the **palette** of `π`
is the (finite) set of colours that appear among the composites `comp π f` as `f`
ranges over `HomBA`.

A configuration **has degree at most `d`** if for every finite colouring of
`HomCA` there is some `π` whose palette uses at most `d` colours.  This predicate
is *monotone* in `d` (more allowed colours is a weaker requirement), it always
holds for `d = Fintype.card HomCA`, and consequently there is a least such `d`.
-/

namespace ApproxRamsey

/-- A `RamseyStep` packages three finite "hom" types and a composition map.  This
is the data over which the approximate Ramsey degree is defined. -/
structure RamseyStep where
  /-- Homomorphisms from `B` to `A`. -/
  HomBA : Type
  /-- Homomorphisms from `C` to `B`. -/
  HomCB : Type
  /-- Homomorphisms from `C` to `A`. -/
  HomCA : Type
  [fintypeBA : Fintype HomBA]
  [fintypeCB : Fintype HomCB]
  [fintypeCA : Fintype HomCA]
  [nonemptyCB : Nonempty HomCB]
  /-- The composition map `HomCB → HomBA → HomCA`. -/
  comp : HomCB → HomBA → HomCA

section

variable {HomBA HomCB HomCA : Type}
variable [Fintype HomBA] [Fintype HomCB] [Fintype HomCA] [Nonempty HomCB]
variable (comp : HomCB → HomBA → HomCA)

/-- The palette of a fixed `π : HomCB` under a colouring `χ`: the finite set of
colours appearing among `χ (comp π f)` as `f` ranges over `HomBA`. -/
noncomputable def palette {κ : Type} [Fintype κ] (χ : HomCA → κ) (π : HomCB) : Finset κ :=
  letI := Classical.decEq κ
  Finset.image (fun f : HomBA => χ (comp π f)) Finset.univ

/-- The configuration has approximate Ramsey degree at most `d`: every finite
colouring of `HomCA` admits some `π` whose palette uses at most `d` colours. -/
def HasDegreeAtMost (d : ℕ) : Prop :=
  ∀ ⦃κ : Type⦄ [Fintype κ], ∀ χ : HomCA → κ, ∃ π : HomCB,
    Fintype.card (palette comp χ π : Set κ).toFinset ≤ d

omit [Fintype HomCB] [Fintype HomCA] [Nonempty HomCB] in
/-- `HasDegreeAtMost` is monotone in `d`: allowing more colours is a weaker
requirement. -/
theorem hasDegreeAtMost_mono :
    ∀ d d' : ℕ, d ≤ d' → HasDegreeAtMost comp d → HasDegreeAtMost comp d' := by
  exact fun d d' hdd hd κ _ χ => by obtain ⟨ π, hπ ⟩ := hd χ; exact ⟨ π, le_trans hπ hdd ⟩ ;

omit [Fintype HomCB] in
/-- The configuration always has degree at most `Fintype.card HomCA`, since any
palette is a set of colours indexed (through `χ`) by a subset of `HomCA`. -/
theorem hasDegreeAtMost_card :
    HasDegreeAtMost comp (Fintype.card HomCA) := by
  -- To prove the inequality, it suffices to show that the palette is a subset of the image of χ over HomCA.
  have h_palette_subset : ∀ (χ : HomCA → ℕ) (π : HomCB), Finset.image (fun f : HomBA => χ (comp π f)) Finset.univ ⊆ Finset.image χ Finset.univ := by
    exact fun χ π => Finset.image_subset_iff.mpr fun f _ => Finset.mem_image_of_mem _ ( Finset.mem_univ _ );
  intro κ _ χ;
  use Classical.arbitrary HomCB;
  convert Finset.card_le_card ( h_palette_subset ( fun x => Fintype.equivFin κ ( χ x ) ) ( Classical.arbitrary HomCB ) ) |> le_trans <| Finset.card_image_le using 1;
  simp +decide [ palette ];
  fapply Finset.card_bij;
  use fun a ha => Fintype.equivFin κ a;
  · aesop;
  · exact fun a₁ ha₁ a₂ ha₂ h => Fintype.equivFin κ |>.injective <| Fin.ext h;
  · aesop

omit [Fintype HomCB] in
/-- There is a least degree bound. -/
theorem exists_min_degree :
    ∃ d : ℕ, HasDegreeAtMost comp d ∧ ∀ d' < d, ¬ HasDegreeAtMost comp d' := by
  have := Classical.decPred ( fun d => HasDegreeAtMost comp d );
  exact ⟨ Nat.find ( ⟨ Fintype.card HomCA, hasDegreeAtMost_card comp ⟩ : ∃ d, HasDegreeAtMost comp d ), Nat.find_spec ( ⟨ Fintype.card HomCA, hasDegreeAtMost_card comp ⟩ : ∃ d, HasDegreeAtMost comp d ), fun d' hd' => Nat.find_min ( ⟨ Fintype.card HomCA, hasDegreeAtMost_card comp ⟩ : ∃ d, HasDegreeAtMost comp d ) hd' ⟩

end

end ApproxRamsey