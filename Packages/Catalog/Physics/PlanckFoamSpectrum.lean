import Physics.PlanckFoamCovering

/-!
# The sheet-number spectrum and the exact covering dichotomy for Planck foam

This file closes the covering-space question left open in
`Physics.PlanckFoamCovering`.  There we proved that the macroscopic projection
`proj : Foam X S ι → X` is always a local homeomorphism (for a closed branch
locus) but is never a covering map when the branch locus is nonempty with empty
interior.  Here we determine the covering locus *exactly*:

* the **sheet-number function** `sheetNumber S ι x = Nat.card (proj ⁻¹' {x})`
  equals `Nat.card ι` on the branch locus and `1` off it
  (`sheetNumber_of_mem`, `sheetNumber_of_notMem`), and it is upper
  semicontinuous exactly because the branch locus is closed
  (`upperSemicontinuous_sheetNumber`);
* the **sheet index** `foamIndex` is a globally continuous ι-valued "which
  Planck branch am I on" observable **iff** the branch locus is clopen;
* **the dichotomy**: `proj` is a covering map **iff** `S` is clopen
  (`isCoveringMap_proj_iff_isClopen`).  On a connected spacetime this forces
  `S = ∅` (no foam) or `S = univ` (uniformly foamy space)
  (`isCoveringMap_proj_iff_of_connected`).

Physically: a multi-sheeted spacetime is a *bona fide* covering space only in
the degenerate regimes where the Planck branching is either absent or
everywhere-dense-and-open.  A genuine Wheeler foam — branch points isolated in a
smooth background — is a locally Euclidean, non-covering, non-Hausdorff space,
and the obstruction is precisely the failure of local constancy of the sheet
number on the topological boundary of the branch locus.
-/

open Set Topology

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι]
  [DiscreteTopology ι] {S : Set X}

/-! ### The sheet-number spectrum -/

/-- The **sheet number** at `x`: how many Planck branches sit over the
macroscopic point `x`. -/
noncomputable def sheetNumber (S : Set X) (ι : Type*) [TopologicalSpace ι] (x : X) : ℕ :=
  Nat.card (proj S ι ⁻¹' {x})

omit [DiscreteTopology ι] in
theorem sheetNumber_of_mem {x : X} (hx : x ∈ S) : sheetNumber S ι x = Nat.card ι :=
  card_fiber_of_mem hx

omit [DiscreteTopology ι] in
theorem sheetNumber_of_notMem [Nonempty ι] {x : X} (hx : x ∉ S) : sheetNumber S ι x = 1 := by
  haveI := subsingleton_fiber_of_notMem (ι := ι) hx
  haveI : Nonempty (proj S ι ⁻¹' {x}) := ⟨⟨sheet S (Classical.arbitrary ι) x, rfl⟩⟩
  simp [sheetNumber]

omit [DiscreteTopology ι] in
theorem sheetNumber_le [Finite ι] [Nonempty ι] (x : X) : sheetNumber S ι x ≤ Nat.card ι := by
  by_cases hx : x ∈ S
  · exact (sheetNumber_of_mem hx).le
  · rw [sheetNumber_of_notMem hx]
    exact Nat.one_le_iff_ne_zero.2 (by simpa using Nat.card_pos.ne')

omit [DiscreteTopology ι] in
/-- **Upper semicontinuity of the sheet number.** With a closed branch locus the
number of Planck branches can only jump *up* in the limit: it is `1` on the open
smooth region and `|ι|` on the closed branch locus. -/
theorem upperSemicontinuous_sheetNumber [Finite ι] [Nonempty ι] (hS : IsClosed S) :
    UpperSemicontinuous (sheetNumber S ι) := by
  intro x y hy
  by_cases hx : x ∈ S
  · filter_upwards with z
    exact lt_of_le_of_lt (sheetNumber_le z) (by rwa [sheetNumber_of_mem hx] at hy)
  · filter_upwards [hS.isOpen_compl.mem_nhds hx] with z hz
    rwa [sheetNumber_of_notMem hz, ← sheetNumber_of_notMem (ι := ι) hx]

/-! ### The sheet index observable -/

open Classical in
/-- The **sheet index**: on a branch point it records which Planck sheet a foam
point lies on, and off the branch locus it takes the default value `i₀`.  It is
well defined precisely because non-branch points have singleton fibres. -/
noncomputable def foamIndex (S : Set X) (i₀ : ι) : Foam X S ι → ι :=
  Quotient.lift (fun p : X × ι => if p.1 ∈ S then p.2 else i₀) (by
    rintro ⟨x, i⟩ ⟨y, j⟩ ⟨rfl, h⟩
    dsimp only
    by_cases hx : x ∈ S
    · rw [if_pos hx, if_pos hx]
      exact h.resolve_right (not_not.2 hx)
    · rw [if_neg hx, if_neg hx])

open Classical in
omit [DiscreteTopology ι] in
@[simp] theorem foamIndex_sheet (i₀ i : ι) (x : X) :
    foamIndex S i₀ (sheet S i x) = if x ∈ S then i else i₀ := rfl

/-- With a clopen branch locus the sheet index is a continuous observable: the
"which branch" question has a globally consistent answer. -/
theorem continuous_foamIndex (hS : IsClopen S) (i₀ : ι) :
    Continuous (foamIndex S i₀) := by
  classical
  refine continuous_def.2 fun U _ => (isOpen_iff _).2 fun k => ?_
  have hEq : {x : X | foamIndex S i₀ (sheet S k x) ∈ U}
      = (if k ∈ U then S else ∅) ∪ (if i₀ ∈ U then Sᶜ else ∅) := by
    ext x
    by_cases hx : x ∈ S <;> by_cases hk : k ∈ U <;> by_cases hi : i₀ ∈ U <;>
      simp [hx, hk, hi]
  show IsOpen {x : X | foamIndex S i₀ (sheet S k x) ∈ U}
  rw [hEq]
  refine IsOpen.union ?_ ?_
  · split
    · exact hS.isOpen
    · exact isOpen_empty
  · split
    · exact hS.1.isOpen_compl
    · exact isOpen_empty

/-- The sheet inclusions assemble into a continuous map `X × ι → Foam X S ι`
(the sheet index type is discrete). -/
theorem continuous_sheet_uncurry :
    Continuous (fun p : X × ι => sheet S p.2 p.1) := by
  refine continuous_iff_continuousAt.2 fun p => ?_
  have hmem : (univ : Set X) ×ˢ ({p.2} : Set ι) ∈ 𝓝 p :=
    (isOpen_univ.prod (isOpen_discrete _)).mem_nhds ⟨mem_univ _, rfl⟩
  refine ContinuousAt.congr (f := fun q : X × ι => sheet S p.2 q.1)
    ((continuous_sheet p.2).comp continuous_fst).continuousAt ?_
  filter_upwards [hmem] with q hq
  have hq2 : q.2 = p.2 := hq.2
  rw [hq2]

/-! ### The covering dichotomy -/

omit [DiscreteTopology ι] in
/-- Over the branch locus a foam point is reconstructed from its macroscopic
position together with its sheet index. -/
theorem sheet_foamIndex_proj (i₀ : ι) (u : Foam X S ι) (hu : proj S ι u ∈ S) :
    sheet S (foamIndex S i₀ u) (proj S ι u) = u := by
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  have hx : x ∈ S := hu
  simp [hx]

omit [DiscreteTopology ι] in
/-- Off the branch locus a foam point is determined by its macroscopic position
alone. -/
theorem sheet_proj_of_notMem (i₀ : ι) (u : Foam X S ι) (hu : proj S ι u ∉ S) :
    sheet S i₀ (proj S ι u) = u := by
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  have hx : x ∉ S := hu
  exact sheet_eq_sheet_of_notMem hx

/-- Over a clopen branch locus the foam is globally trivial with fibre `ι`:
`proj ⁻¹' S ≃ₜ S × ι`, compatibly with the projections. -/
noncomputable def foamHomeoOverBranch (hS : IsClopen S) (i₀ : ι) :
    (proj S ι ⁻¹' S) ≃ₜ S × ι where
  toFun u := (⟨proj S ι u.1, u.2⟩, foamIndex S i₀ u.1)
  invFun p := ⟨sheet S p.2 (p.1 : X), p.1.2⟩
  left_inv u := Subtype.ext (sheet_foamIndex_proj i₀ u.1 u.2)
  right_inv p := by
    refine Prod.ext (Subtype.ext rfl) ?_
    have hx : (p.1 : X) ∈ S := p.1.2
    simp [hx]
  continuous_toFun :=
    Continuous.prodMk (Continuous.subtype_mk (continuous_proj.comp continuous_subtype_val) _)
      ((continuous_foamIndex hS i₀).comp continuous_subtype_val)
  continuous_invFun :=
    Continuous.subtype_mk
      (continuous_sheet_uncurry.comp (continuous_subtype_val.prodMap continuous_id)) _

/-- Off a clopen branch locus the foam is a single sheet:
`proj ⁻¹' Sᶜ ≃ₜ Sᶜ × PUnit`. -/
def foamHomeoOverSmooth (i₀ : ι) :
    (proj S ι ⁻¹' Sᶜ) ≃ₜ (Sᶜ : Set X) × Unit where
  toFun u := (⟨proj S ι u.1, u.2⟩, ())
  invFun p := ⟨sheet S i₀ (p.1 : X), p.1.2⟩
  left_inv u := Subtype.ext (sheet_proj_of_notMem i₀ u.1 u.2)
  right_inv _ := Prod.ext (Subtype.ext rfl) rfl
  continuous_toFun :=
    Continuous.prodMk (Continuous.subtype_mk (continuous_proj.comp continuous_subtype_val) _)
      continuous_const
  continuous_invFun :=
    Continuous.subtype_mk ((continuous_sheet i₀).comp (continuous_subtype_val.comp
      continuous_fst)) _

/-- **Clopen branch locus ⇒ covering map.** -/
theorem isCoveringMap_proj_of_isClopen [Nonempty ι] (hS : IsClopen S) :
    IsCoveringMap (proj S ι) := by
  classical
  intro x
  by_cases hx : x ∈ S
  · have hev : IsEvenlyCovered (proj S ι) x ι :=
      ⟨inferInstance, S, hx, hS.2, hS.2.preimage continuous_proj,
        foamHomeoOverBranch hS (Classical.arbitrary ι), fun _ => rfl⟩
    exact hev.to_isEvenlyCovered_preimage
  · have hev : IsEvenlyCovered (proj S ι) x PUnit :=
      ⟨inferInstance, Sᶜ, hx, hS.1.isOpen_compl, hS.1.isOpen_compl.preimage continuous_proj,
        foamHomeoOverSmooth (Classical.arbitrary ι), fun _ => rfl⟩
    exact hev.to_isEvenlyCovered_preimage

omit [DiscreteTopology ι] in
/-- **Covering map ⇒ clopen branch locus.** -/
theorem isClopen_of_isCoveringMap_proj [Nontrivial ι] (h : IsCoveringMap (proj S ι)) :
    IsClopen S := by
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  have key : ∀ x : X, ∃ U : Set X, IsOpen U ∧ x ∈ U ∧ ∀ y ∈ U,
      Nonempty ((proj S ι ⁻¹' {x}) ≃ (proj S ι ⁻¹' {y})) := by
    intro x
    obtain ⟨hdisc, U, hxU, hU, hfU, H, hH⟩ := h x
    refine ⟨U, hU, hxU, fun y hy => ⟨?_⟩⟩
    have hEvenX : IsEvenlyCovered (proj S ι) x (proj S ι ⁻¹' {x}) :=
      ⟨hdisc, U, hxU, hU, hfU, H, hH⟩
    have hEvenY : IsEvenlyCovered (proj S ι) y (proj S ι ⁻¹' {x}) :=
      ⟨hdisc, U, hy, hU, hfU, H, hH⟩
    exact (hEvenX.fiberHomeomorph.symm.trans hEvenY.fiberHomeomorph).toEquiv
  refine ⟨?_, ?_⟩
  · rw [← isOpen_compl_iff, isOpen_iff_forall_mem_open]
    intro x hx
    obtain ⟨U, hU, hxU, hbij⟩ := key x
    refine ⟨U, fun y hy hyS => ?_, hU, hxU⟩
    obtain ⟨e⟩ := hbij y hy
    haveI : Subsingleton (proj S ι ⁻¹' {x}) := subsingleton_fiber_of_notMem hx
    haveI : Subsingleton (proj S ι ⁻¹' {y}) := e.symm.subsingleton
    exact sheet_ne_sheet hij hyS (congrArg Subtype.val
      (Subsingleton.elim (⟨sheet S i y, rfl⟩ : proj S ι ⁻¹' {y}) ⟨sheet S j y, rfl⟩))
  · rw [isOpen_iff_forall_mem_open]
    intro x hx
    obtain ⟨U, hU, hxU, hbij⟩ := key x
    refine ⟨U, fun y hy => ?_, hU, hxU⟩
    by_contra hyS
    obtain ⟨e⟩ := hbij y hy
    haveI : Subsingleton (proj S ι ⁻¹' {y}) := subsingleton_fiber_of_notMem hyS
    haveI : Subsingleton (proj S ι ⁻¹' {x}) := e.subsingleton
    exact sheet_ne_sheet hij hx (congrArg Subtype.val
      (Subsingleton.elim (⟨sheet S i x, rfl⟩ : proj S ι ⁻¹' {x}) ⟨sheet S j x, rfl⟩))

/-- **The exact covering dichotomy.** -/
theorem isCoveringMap_proj_iff_isClopen [Nontrivial ι] :
    IsCoveringMap (proj S ι) ↔ IsClopen S :=
  ⟨isClopen_of_isCoveringMap_proj, isCoveringMap_proj_of_isClopen⟩

/-- On a connected spacetime the only covering foams are the degenerate ones. -/
theorem isCoveringMap_proj_iff_of_connected [Nontrivial ι] [PreconnectedSpace X] :
    IsCoveringMap (proj S ι) ↔ S = ∅ ∨ S = univ := by
  rw [isCoveringMap_proj_iff_isClopen]
  exact isClopen_iff

end PlanckFoam