import Physics.PlanckFoamTopology

/-!
# Planck foam is a local homeomorphism but not a covering space

The macroscopic projection `proj : Foam X S ι → X` looks like an ordinary
smooth-space projection *locally*: with a closed branch locus every point of the
foam has a neighbourhood mapped homeomorphically onto an open set of `X`
(`isLocalHomeomorph_proj`).  Nevertheless the foam is **not** a covering space of
spacetime whenever the branch locus is nonempty with empty interior
(`not_isCoveringMap_proj`): the fibre jumps from `|ι|` points over a Planck
branch point to a single point over its neighbours, which no local
trivialisation can accommodate.

This is the precise sense in which Wheeler foam is not a "multi-sheeted
spacetime": it is a locally Euclidean structure whose sheet number is not locally
constant.
-/

open Set Topology

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι]
  [DiscreteTopology ι] {S : Set X}

/-- The macroscopic projection is an open map. -/
theorem isOpenMap_proj : IsOpenMap (proj S ι) := by
  intro W hW
  have hEq : proj S ι '' W = ⋃ i : ι, {x : X | sheet S i x ∈ W} := by
    ext x
    simp only [mem_image, mem_iUnion, mem_setOf_eq]
    constructor
    · rintro ⟨u, huW, rfl⟩
      obtain ⟨i, y, rfl⟩ := exists_sheet u
      exact ⟨i, huW⟩
    · rintro ⟨i, hi⟩
      exact ⟨sheet S i x, hi, rfl⟩
  rw [hEq]
  exact isOpen_iUnion fun i => (isOpen_iff W).1 hW i

/-- **Local smoothness.** With a closed branch locus the projection is a local
homeomorphism: locally the foam is indistinguishable from spacetime. -/
theorem isLocalHomeomorph_proj (hS : IsClosed S) [Nonempty ι] :
    IsLocalHomeomorph (proj S ι) := by
  refine isLocalHomeomorph_iff_isOpenEmbedding_restrict.2 fun u => ?_
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  have hopen : IsOpen (range (sheet S i : X → Foam X S ι)) := by
    simpa using (sheet_isOpenEmbedding hS i).isOpen_range
  refine ⟨range (sheet S i), hopen.mem_nhds ⟨x, rfl⟩, ?_⟩
  have hEq : (range (sheet S i : X → Foam X S ι)).restrict (proj S ι)
      = ((sheet_isOpenEmbedding hS i).isEmbedding.toHomeomorph).symm := by
    funext v
    obtain ⟨y, hy⟩ := v.2
    have hv : v = ((sheet_isOpenEmbedding hS i).isEmbedding.toHomeomorph) y := by
      exact Subtype.ext hy.symm
    rw [hv]
    simp [Set.restrict]
  rw [hEq]
  exact Homeomorph.isOpenEmbedding _

omit [DiscreteTopology ι] in
/-- **No covering structure.** If there is a branch point and the branch locus
has empty interior, the projection is not a covering map: the number of Planck
sheets is not locally constant. -/
theorem not_isCoveringMap_proj [Nontrivial ι] (hS : S.Nonempty) (hint : interior S = ∅) :
    ¬ IsCoveringMap (proj S ι) := by
  obtain ⟨x, hx⟩ := hS
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  intro hcov
  have hEvenX := hcov x
  obtain ⟨hdisc, U, hxU, hU, hfU, H, hH⟩ := hcov x
  -- the neighbourhood `U` must contain a point which is not a branch point
  have hexists : ∃ y ∈ U, y ∉ S := by
    by_contra hcon
    push_neg at hcon
    have : x ∈ interior S := mem_interior.2 ⟨U, hcon, hU, hxU⟩
    rw [hint] at this
    exact this
  obtain ⟨y, hyU, hyS⟩ := hexists
  have hEvenY : IsEvenlyCovered (proj S ι) y (proj S ι ⁻¹' {x}) :=
    ⟨hdisc, U, hyU, hU, hfU, H, hH⟩
  -- the fibres over `x` and over `y` are then in bijection
  have hxy : (proj S ι ⁻¹' {x}) ≃ (proj S ι ⁻¹' {y}) :=
    (hEvenX.fiberHomeomorph.symm.trans hEvenY.fiberHomeomorph).toEquiv
  haveI : Subsingleton (proj S ι ⁻¹' {y}) := subsingleton_fiber_of_notMem hyS
  haveI : Subsingleton (proj S ι ⁻¹' {x}) := hxy.subsingleton
  have hEq : (⟨sheet S i x, rfl⟩ : proj S ι ⁻¹' {x}) = ⟨sheet S j x, rfl⟩ :=
    Subsingleton.elim _ _
  exact sheet_ne_sheet hij hx (congrArg Subtype.val hEq)

end PlanckFoam