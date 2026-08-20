import Physics.PlanckFoamTopology

/-!
# The hidden sheet-permutation gauge group of Planck foam

The Wheeler foam `Foam X S ι` of `Physics.PlanckFoamTopology` carries a
symmetry that is invisible macroscopically: any permutation `σ` of the sheet
index type `ι` relabels the branches over the branch locus and induces a
homeomorphism `sheetPerm σ` of the foam commuting with the projection to `X`.

## Main results

* `PlanckFoam.sheetPerm` — the induced homeomorphism of the foam.
* `PlanckFoam.proj_sheetPerm` — **macroscopic gauge invariance**: sheet
  relabelling is invisible to the projection.
* `PlanckFoam.sheetPermHom` — a group homomorphism `Equiv.Perm ι →*
  Equiv.Perm (Foam X S ι)`, and `PlanckFoam.sheetPermHom_injective`: it is
  **faithful exactly when the branch locus is nonempty**.  So the foam has a
  genuine `Sym ι` gauge group precisely when there is foam.
* `PlanckFoam.observable_gauge_invariant` — every continuous Hausdorff-valued
  observable is gauge invariant when the branch locus has empty interior:
  the gauge group acts trivially on all measurements.
-/

open Set Topology

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι] {S : Set X}

/-- Relabelling of the Planck sheets by a permutation of the index type. -/
def sheetPermFun (S : Set X) (σ : Equiv.Perm ι) : Foam X S ι → Foam X S ι :=
  Quotient.lift (fun a : X × ι => sheet S (σ a.2) a.1) (by
    rintro ⟨x, i⟩ ⟨y, j⟩ ⟨rfl, h⟩
    exact sheet_eq_sheet.2 ⟨rfl, h.imp (fun hij => by rw [hij]) id⟩)

@[simp] theorem sheetPermFun_sheet (σ : Equiv.Perm ι) (i : ι) (x : X) :
    sheetPermFun S σ (sheet S i x) = sheet S (σ i) x := rfl

@[simp] theorem sheetPermFun_one : sheetPermFun S (1 : Equiv.Perm ι) = id := by
  funext u
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  rfl

theorem sheetPermFun_mul (σ τ : Equiv.Perm ι) :
    sheetPermFun S (σ * τ) = sheetPermFun S σ ∘ sheetPermFun S τ := by
  funext u
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  rfl

variable [DiscreteTopology ι]

theorem continuous_sheetPermFun (σ : Equiv.Perm ι) : Continuous (sheetPermFun S σ) :=
  continuous_def.2 fun W hW => (isOpen_iff _).2 fun i => by
    simpa using (isOpen_iff W).1 hW (σ i)

/-- Sheet relabelling as a homeomorphism of the foam. -/
def sheetPerm (σ : Equiv.Perm ι) : Foam X S ι ≃ₜ Foam X S ι where
  toFun := sheetPermFun S σ
  invFun := sheetPermFun S σ⁻¹
  left_inv := by
    intro u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    simp
  right_inv := by
    intro u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    simp
  continuous_toFun := continuous_sheetPermFun σ
  continuous_invFun := continuous_sheetPermFun σ⁻¹

@[simp] theorem sheetPerm_apply (σ : Equiv.Perm ι) (i : ι) (x : X) :
    sheetPerm (S := S) σ (sheet S i x) = sheet S (σ i) x := rfl

/-- **Macroscopic gauge invariance.** Sheet relabelling does not move any point
of the base: the gauge group acts along the Planck fibres only. -/
@[simp] theorem proj_sheetPerm (σ : Equiv.Perm ι) (u : Foam X S ι) :
    proj S ι (sheetPerm (S := S) σ u) = proj S ι u := by
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  rfl

/-- The sheet-permutation action as a group homomorphism into the permutation
group of the foam. -/
def sheetPermHom (S : Set X) (ι : Type*) [TopologicalSpace ι] [DiscreteTopology ι] :
    Equiv.Perm ι →* Equiv.Perm (Foam X S ι) where
  toFun σ := (sheetPerm (S := S) σ).toEquiv
  map_one' := by
    ext u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    rfl
  map_mul' σ τ := by
    ext u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    rfl

@[simp] theorem sheetPermHom_apply (σ : Equiv.Perm ι) (i : ι) (x : X) :
    sheetPermHom S ι σ (sheet S i x) = sheet S (σ i) x := rfl

/-- **Faithfulness of the foam gauge group.** The symmetric group of the sheet
index embeds into the homeomorphism group of the foam exactly when there is at
least one branch point. -/
theorem sheetPermHom_injective (hS : S.Nonempty) :
    Function.Injective (sheetPermHom S ι) := by
  obtain ⟨x, hx⟩ := hS
  refine (injective_iff_map_eq_one _).2 fun σ hσ => ?_
  ext i
  have h : sheet S (σ i) x = sheet S i x := by
    have := congrArg (fun e : Equiv.Perm (Foam X S ι) => e (sheet S i x)) hσ
    simpa using this
  exact (sheet_eq_sheet.1 h).2.resolve_right (not_not.2 hx)

/-- Conversely, with no branch points at all the gauge group acts trivially. -/
theorem sheetPermHom_eq_one_of_empty (hS : S = ∅) (σ : Equiv.Perm ι) :
    sheetPermHom S ι σ = 1 := by
  ext u
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  have hx : x ∉ S := by simp [hS]
  simpa using sheet_eq_sheet_of_notMem (i := σ i) (j := i) hx

/-- **Gauge invariance of observables.** If the branch locus has empty interior,
every continuous Hausdorff-valued observable on the foam is invariant under the
whole sheet-permutation gauge group. -/
theorem observable_gauge_invariant (hS : interior S = ∅) {Y : Type*} [TopologicalSpace Y]
    [T2Space Y] {f : Foam X S ι → Y} (hf : Continuous f) (σ : Equiv.Perm ι)
    (u : Foam X S ι) : f (sheetPerm (S := S) σ u) = f u := by
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  exact eq_of_continuous_t2 hf (by simp [hS])

end PlanckFoam