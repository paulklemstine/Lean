import Physics.PlanckFoamTopology

/-!
# Coarse graining the Planck foam: a renormalisation tower

Physically, a Planck foam observed at a coarser resolution should look like a
foam with fewer branch points.  Mathematically this is the statement that
shrinking the branch locus `S ↦ S'` (with `S' ⊆ S`) is realised by a canonical
continuous surjection of foams.

## Main results

* `PlanckFoam.foamCollapse` — the coarse-graining map `Foam X S ι → Foam X S' ι`
  for `S' ⊆ S`, together with `continuous_foamCollapse`,
  `foamCollapse_surjective` and `proj_foamCollapse` (it commutes with the
  macroscopic projection).
* `PlanckFoam.foamCollapse_comp` — functoriality: the coarse grainings compose,
  so branch loci form a renormalisation tower.
* `PlanckFoam.foamCollapse_injective_iff` — the coarse graining loses
  information **exactly** when it erases a branch point.
* `PlanckFoam.homeomorphFoamEmpty` — the bottom of the tower: a foam with empty
  branch locus is just smooth spacetime.
-/

open Set Topology

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι] {S S' : Set X}

/-- Coarse graining: erase the branch points of `S` that are not in `S'`. -/
def foamCollapse (S S' : Set X) (h : S' ⊆ S) : Foam X S ι → Foam X S' ι :=
  Quotient.lift (fun a : X × ι => sheet S' a.2 a.1) (by
    rintro ⟨x, i⟩ ⟨y, j⟩ ⟨rfl, hc⟩
    exact sheet_eq_sheet.2 ⟨rfl, hc.imp id fun hxS hxS' => hxS (h hxS')⟩)

@[simp] theorem foamCollapse_sheet (h : S' ⊆ S) (i : ι) (x : X) :
    foamCollapse (ι := ι) S S' h (sheet S i x) = sheet S' i x := rfl

theorem foamCollapse_surjective (h : S' ⊆ S) :
    Function.Surjective (foamCollapse (ι := ι) S S' h) := by
  intro u
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  exact ⟨sheet S i x, rfl⟩

@[simp] theorem proj_foamCollapse (h : S' ⊆ S) (u : Foam X S ι) :
    proj S' ι (foamCollapse S S' h u) = proj S ι u := by
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  rfl

/-- Functoriality of coarse graining: branch loci form a renormalisation tower. -/
theorem foamCollapse_comp {S'' : Set X} (h₁ : S' ⊆ S) (h₂ : S'' ⊆ S') :
    (foamCollapse (ι := ι) S' S'' h₂) ∘ (foamCollapse (ι := ι) S S' h₁)
      = foamCollapse (ι := ι) S S'' (h₂.trans h₁) := by
  funext u
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  rfl

/-- **Information loss under coarse graining.** With at least two sheets, the
coarse graining `Foam X S ι → Foam X S' ι` is injective exactly when it erases
no branch point. -/
theorem foamCollapse_injective_iff [Nontrivial ι] (h : S' ⊆ S) :
    Function.Injective (foamCollapse (ι := ι) S S' h) ↔ S = S' := by
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  constructor
  · intro hinj
    refine Subset.antisymm (fun x hx => ?_) h
    by_contra hx'
    refine sheet_ne_sheet hij hx (hinj ?_)
    simp only [foamCollapse_sheet]
    exact sheet_eq_sheet_of_notMem hx'
  · rintro rfl
    intro u v huv
    obtain ⟨i', x, rfl⟩ := exists_sheet u
    obtain ⟨j', y, rfl⟩ := exists_sheet v
    simp only [foamCollapse_sheet] at huv
    exact huv

variable [DiscreteTopology ι]

theorem continuous_foamCollapse (h : S' ⊆ S) :
    Continuous (foamCollapse (ι := ι) S S' h) :=
  continuous_def.2 fun W hW => (isOpen_iff _).2 fun i => by
    simpa using (isOpen_iff W).1 hW i

/-- The bottom of the renormalisation tower: with no branch points the foam is
homeomorphic to the underlying smooth space. -/
noncomputable def homeomorphFoamEmpty [Nonempty ι] : Foam X (∅ : Set X) ι ≃ₜ X where
  toFun := proj (∅ : Set X) ι
  invFun := sheet (∅ : Set X) (Classical.arbitrary ι)
  left_inv := by
    intro u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    exact sheet_eq_sheet_of_notMem (by simp)
  right_inv := fun _ => rfl
  continuous_toFun := continuous_proj
  continuous_invFun := continuous_sheet _

/-- Coarse graining all the way down recovers the macroscopic projection. -/
theorem homeomorphFoamEmpty_foamCollapse [Nonempty ι] (u : Foam X S ι) :
    homeomorphFoamEmpty (foamCollapse (ι := ι) S ∅ (empty_subset S) u) = proj S ι u := by
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  rfl

end PlanckFoam