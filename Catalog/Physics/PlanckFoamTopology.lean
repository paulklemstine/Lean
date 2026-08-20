import Mathlib

/-!
# Planck foam as a non-Hausdorff topology (core theory)

Wheeler's *spacetime foam* posits that at the Planck length the smooth manifold
picture of spacetime breaks down: at each Planck cell the geometry "branches"
into several locally indistinguishable sheets.  The standard mathematical
caricature of such branching is the *line with two origins*: a locally
Euclidean, T1, but non-Hausdorff space.

This file develops the general construction.  Given a topological space `X`
(macroscopic spacetime), a *branch locus* `S ⊆ X` (the Planck cells at which the
geometry bifurcates) and an index type `ι` of sheets, the **foam**
`Foam X S ι` is the quotient of `X × ι` (with `ι` discrete) by

  `(x, i) ~ (y, j)  ↔  x = y ∧ (i = j ∨ x ∉ S)`.

## Main results

* `PlanckFoam.sheet_eq_sheet` — description of the identifications.
* `PlanckFoam.isOpen_iff` — a set is open iff all of its sheet slices are open.
* `PlanckFoam.t1Space_foam_iff` — the foam is T1 iff `X` is.
* `PlanckFoam.t2Space_foam_iff` — with at least two sheets, the foam is
  Hausdorff **iff** `X` is Hausdorff *and* the branch locus `S` is open.
  Thus a branch locus with empty interior (e.g. a Planck lattice) always
  destroys Hausdorffness, while a "thick" open branch locus never does.
* `PlanckFoam.homeomorphOfSubsingleton` — guarded corner case: with a single
  sheet the foam is homeomorphic to `X`.
* `PlanckFoam.sheet_isOpenEmbedding` — for a closed branch locus every sheet is
  an open embedding, so the foam is *locally* indistinguishable from `X`.
* `PlanckFoam.nhds_branch_not_disjoint`, `PlanckFoam.eq_of_continuous_t2` —
  branch points cannot be separated, and consequently **no continuous
  observable with Hausdorff values distinguishes two branches**.
* `PlanckFoam.separated_of_proj_ne` — non-Hausdorffness is confined to the
  Planck fibres: points with different macroscopic projections are separated.
* `PlanckFoam.not_metrizableSpace` — a foam with non-open branch locus carries
  no metric: there is no Planck-scale distance function.
* `PlanckFoam.compactSpace` — with finitely many sheets, compactness survives.
-/

open Set Topology Filter

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι] {S : Set X}

/-- The foam identification: two points of `X × ι` are identified when they lie
over the same point of `X` and either they are on the same sheet, or the base
point is not a branch point. -/
def foamSetoid (S : Set X) (ι : Type*) : Setoid (X × ι) where
  r a b := a.1 = b.1 ∧ (a.2 = b.2 ∨ a.1 ∉ S)
  iseqv :=
    { refl := fun _ => ⟨rfl, Or.inl rfl⟩
      symm := by
        rintro ⟨x, i⟩ ⟨y, j⟩ ⟨rfl, h⟩
        exact ⟨rfl, h.imp Eq.symm id⟩
      trans := by
        rintro ⟨x, i⟩ ⟨y, j⟩ ⟨z, k⟩ ⟨rfl, h₁⟩ ⟨rfl, h₂⟩
        refine ⟨rfl, ?_⟩
        by_cases hx : x ∈ S
        · exact Or.inl ((h₁.resolve_right (not_not.2 hx)).trans (h₂.resolve_right (not_not.2 hx)))
        · exact Or.inr hx }

/-- Wheeler foam over the space `X` with branch locus `S` and sheet index `ι`. -/
def Foam (X : Type*) [TopologicalSpace X] (S : Set X) (ι : Type*) [TopologicalSpace ι] :
    Type _ := Quotient (foamSetoid S ι)

instance : TopologicalSpace (Foam X S ι) := instTopologicalSpaceQuotient

instance [Nonempty X] [Nonempty ι] : Nonempty (Foam X S ι) :=
  ⟨Quotient.mk (foamSetoid S ι) ⟨Classical.arbitrary X, Classical.arbitrary ι⟩⟩

/-- The `i`-th sheet inclusion `X → Foam X S ι`. -/
def sheet (S : Set X) (i : ι) (x : X) : Foam X S ι := Quotient.mk (foamSetoid S ι) (x, i)

/-- The macroscopic projection collapsing all sheets. -/
def proj (S : Set X) (ι : Type*) [TopologicalSpace ι] : Foam X S ι → X :=
  Quotient.lift Prod.fst (by rintro ⟨x, i⟩ ⟨y, j⟩ ⟨rfl, -⟩; rfl)

@[simp] theorem proj_sheet (i : ι) (x : X) : proj S ι (sheet S i x) = x := rfl

theorem sheet_eq_sheet {x y : X} {i j : ι} :
    sheet S i x = sheet S j y ↔ x = y ∧ (i = j ∨ x ∉ S) :=
  Quotient.eq (r := foamSetoid S ι)

theorem sheet_eq_sheet_of_notMem {x : X} {i j : ι} (hx : x ∉ S) :
    sheet S i x = sheet S j x := sheet_eq_sheet.2 ⟨rfl, Or.inr hx⟩

theorem sheet_ne_sheet {x : X} {i j : ι} (hij : i ≠ j) (hx : x ∈ S) :
    sheet S i x ≠ sheet S j x := fun h => by
  rcases (sheet_eq_sheet.1 h).2 with h' | h'
  · exact hij h'
  · exact h' hx

theorem sheet_injective (i : ι) : Function.Injective (sheet S i) :=
  fun _ _ h => (sheet_eq_sheet.1 h).1

/-- Every point of the foam lies on some sheet. -/
theorem exists_sheet (u : Foam X S ι) : ∃ (i : ι) (x : X), u = sheet S i x := by
  induction u using Quotient.inductionOn with
  | h a => exact ⟨a.2, a.1, rfl⟩

@[simp] theorem iUnion_range_sheet :
    ⋃ i : ι, range (sheet S i) = (univ : Set (Foam X S ι)) := by
  ext u
  simp only [mem_iUnion, mem_range, mem_univ, iff_true]
  obtain ⟨i, x, rfl⟩ := exists_sheet u
  exact ⟨i, x, rfl⟩

/-! ### Planck fibres -/

/-- The fibre of the macroscopic projection over a branch point is a full copy of
the sheet index type: a branch point carries `Nat.card ι` Planck branches. -/
theorem card_fiber_of_mem {x : X} (hx : x ∈ S) :
    Nat.card (proj S ι ⁻¹' {x}) = Nat.card ι := by
  refine (Nat.card_eq_of_bijective
    (fun i : ι => (⟨sheet S i x, rfl⟩ : proj S ι ⁻¹' {x})) ⟨?_, ?_⟩).symm
  · intro i j h
    have hEq : sheet S i x = sheet S j x := congrArg Subtype.val h
    exact (sheet_eq_sheet.1 hEq).2.resolve_right (not_not.2 hx)
  · rintro ⟨u, hu⟩
    obtain ⟨i, y, rfl⟩ := exists_sheet u
    have hy : y = x := hu
    subst hy
    exact ⟨i, rfl⟩

/-- Away from the branch locus the projection is injective: no branching. -/
theorem subsingleton_fiber_of_notMem {x : X} (hx : x ∉ S) :
    Subsingleton (proj S ι ⁻¹' {x}) := by
  refine ⟨?_⟩
  rintro ⟨u, hu⟩ ⟨v, hv⟩
  obtain ⟨i, y, rfl⟩ := exists_sheet u
  obtain ⟨j, z, rfl⟩ := exists_sheet v
  have hy : y = x := hu
  have hz : z = x := hv
  subst hy; subst hz
  exact Subtype.ext (sheet_eq_sheet_of_notMem hx)

/-! ### The slice calculus -/

/-- The `i`-slice of the `i`-sheet image of `T` is `T`. -/
theorem slice_image_self (i : ι) (T : Set X) :
    {z : X | sheet S i z ∈ sheet S i '' T} = T := by
  ext z
  simp only [mem_setOf_eq, mem_image]
  constructor
  · rintro ⟨w, hw, hEq⟩
    exact (sheet_injective i hEq) ▸ hw
  · exact fun hz => ⟨z, hz, rfl⟩

/-- The `k`-slice of the `i`-sheet image of `T` for `i ≠ k` is `T \ S`. -/
theorem slice_image_of_ne {i k : ι} (hik : i ≠ k) (T : Set X) :
    {z : X | sheet S k z ∈ sheet S i '' T} = T \ S := by
  ext z
  simp only [mem_setOf_eq, mem_image, mem_diff]
  constructor
  · rintro ⟨w, hw, hEq⟩
    obtain ⟨rfl, h⟩ := sheet_eq_sheet.1 hEq
    exact ⟨hw, h.resolve_left hik⟩
  · rintro ⟨hz, hzS⟩
    exact ⟨z, hz, sheet_eq_sheet.2 ⟨rfl, Or.inr hzS⟩⟩

variable [DiscreteTopology ι]


/-- A set of the foam is open exactly when each of its sheet slices is open. -/
theorem isOpen_iff (W : Set (Foam X S ι)) :
    IsOpen W ↔ ∀ i : ι, IsOpen {x : X | sheet S i x ∈ W} := by
  rw [show IsOpen W ↔ IsOpen (Quotient.mk (foamSetoid S ι) ⁻¹' W) from Iff.rfl]
  constructor
  · intro h i
    exact h.preimage (by fun_prop : Continuous fun x : X => (x, i))
  · intro h
    have hEq : (Quotient.mk (foamSetoid S ι) ⁻¹' W)
        = ⋃ i : ι, {x : X | sheet S i x ∈ W} ×ˢ ({i} : Set ι) := by
      ext ⟨x, j⟩
      simp [sheet]
    rw [hEq]
    exact isOpen_iUnion fun i => (h i).prod (isOpen_discrete _)

/-- A set of the foam is closed exactly when each of its sheet slices is closed. -/
theorem isClosed_iff (W : Set (Foam X S ι)) :
    IsClosed W ↔ ∀ i : ι, IsClosed {x : X | sheet S i x ∈ W} := by
  simp only [← isOpen_compl_iff, isOpen_iff]
  rfl

theorem continuous_sheet (i : ι) : Continuous (sheet S i) :=
  continuous_def.2 fun W hW => (isOpen_iff W).1 hW i

theorem continuous_proj : Continuous (proj S ι) :=
  continuous_def.2 fun U hU => (isOpen_iff _).2 fun _ => by simpa using hU

omit [DiscreteTopology ι] in
theorem surjective_proj [Nonempty ι] : Function.Surjective (proj S ι) := by
  intro x
  exact ⟨sheet S (Classical.arbitrary ι) x, rfl⟩

/-! ### Local structure: the foam looks like `X` through any single sheet -/

/-- If the branch locus is closed, each sheet is an open map. -/
theorem isOpenMap_sheet (hS : IsClosed S) (i : ι) : IsOpenMap (sheet S i) := by
  intro T hT
  refine (isOpen_iff _).2 fun k => ?_
  by_cases hik : i = k
  · subst hik
    rw [slice_image_self]
    exact hT
  · rw [slice_image_of_ne hik]
    exact hT.sdiff hS

/-- **Local indistinguishability.** With a closed branch locus, every sheet is an
open embedding: an observer confined to one sheet sees exactly `X`. -/
theorem sheet_isOpenEmbedding (hS : IsClosed S) (i : ι) :
    IsOpenEmbedding (sheet S i : X → Foam X S ι) :=
  IsOpenEmbedding.of_continuous_injective_isOpenMap (continuous_sheet i) (sheet_injective i)
    (isOpenMap_sheet hS i)

/-! ### Separation axioms -/

/-- The foam is T1 exactly when the base space is. -/
theorem t1Space_foam_iff [Nonempty ι] : T1Space (Foam X S ι) ↔ T1Space X := by
  constructor
  · intro h
    refine ⟨fun x => ?_⟩
    have hpre : ({x} : Set X) = sheet S (Classical.arbitrary ι) ⁻¹' {sheet S (Classical.arbitrary ι) x} := by
      ext y
      simp only [mem_singleton_iff, mem_preimage]
      exact ⟨fun hy => hy ▸ rfl, fun hy => sheet_injective _ hy⟩
    rw [hpre]
    exact isClosed_singleton.preimage (continuous_sheet _)
  · intro h
    refine ⟨fun u => ?_⟩
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    have himg : ({sheet S i x} : Set (Foam X S ι)) = sheet S i '' {x} := (image_singleton).symm
    rw [himg, isClosed_iff]
    intro k
    by_cases hik : i = k
    · subst hik
      rw [slice_image_self]
      exact isClosed_singleton
    · rw [slice_image_of_ne hik]
      by_cases hxS : x ∈ S
      · rw [show ({x} : Set X) \ S = ∅ from
          Set.diff_eq_empty.2 (Set.singleton_subset_iff.2 hxS)]
        exact isClosed_empty
      · rw [show ({x} : Set X) \ S = {x} by simp [hxS]]
        exact isClosed_singleton

/-- **Key non-separation lemma.** If `x` does not lie in the interior of the
branch locus, then the sheet copies of `x` cannot be separated: their
neighbourhood filters are never disjoint.  (For `x ∈ S` and `i ≠ j` these are two
*distinct* points, so this is a genuine failure of Hausdorffness.) -/
theorem nhds_branch_not_disjoint {x : X} {i j : ι}
    (hx' : x ∉ interior S) : ¬ Disjoint (𝓝 (sheet S i x)) (𝓝 (sheet S j x)) := by
  rw [Filter.disjoint_iff]
  rintro ⟨A, hA, B, hB, hAB⟩
  obtain ⟨WA, hWAsub, hWAopen, hWAmem⟩ := mem_nhds_iff.1 hA
  obtain ⟨WB, hWBsub, hWBopen, hWBmem⟩ := mem_nhds_iff.1 hB
  set U := {y : X | sheet S i y ∈ WA} with hU
  set V := {y : X | sheet S j y ∈ WB} with hV
  have hUo : IsOpen U := (isOpen_iff _).1 hWAopen i
  have hVo : IsOpen V := (isOpen_iff _).1 hWBopen j
  have hsub : U ∩ V ⊆ S := by
    intro y hy
    by_contra hyS
    have h1 : sheet S i y = sheet S j y := sheet_eq_sheet_of_notMem hyS
    exact Set.disjoint_left.1 hAB (hWAsub hy.1) (by rw [h1]; exact hWBsub hy.2)
  exact hx' (mem_interior.2 ⟨U ∩ V, hsub, hUo.inter hVo, ⟨hWAmem, hWBmem⟩⟩)

/-- Points of the foam lying over distinct macroscopic points are always
separated: non-Hausdorffness is confined to the Planck fibres. -/
theorem separated_of_proj_ne [T2Space X] {u v : Foam X S ι} (h : proj S ι u ≠ proj S ι v) :
    ∃ A B : Set (Foam X S ι), IsOpen A ∧ IsOpen B ∧ u ∈ A ∧ v ∈ B ∧ Disjoint A B := by
  obtain ⟨U, V, hU, hV, hxU, hyV, hUV⟩ := t2_separation h
  exact ⟨proj S ι ⁻¹' U, proj S ι ⁻¹' V, hU.preimage continuous_proj,
    hV.preimage continuous_proj, hxU, hyV, hUV.preimage _⟩

/-- **Main separation theorem.** With at least two sheets, the Wheeler foam is
Hausdorff if and only if the base is Hausdorff *and* the branch locus is open. -/
theorem t2Space_foam_iff [Nontrivial ι] :
    T2Space (Foam X S ι) ↔ (T2Space X ∧ IsOpen S) := by
  obtain ⟨i₀, j₀, hij₀⟩ := exists_pair_ne ι
  constructor
  · intro h
    refine ⟨⟨fun x y hxy => ?_⟩, ?_⟩
    · obtain ⟨A, B, hA, hB, hxA, hyB, hAB⟩ :=
        t2_separation (x := sheet S i₀ x) (y := sheet S i₀ y)
          (fun hc => hxy (sheet_injective i₀ hc))
      exact ⟨sheet S i₀ ⁻¹' A, sheet S i₀ ⁻¹' B, hA.preimage (continuous_sheet _),
        hB.preimage (continuous_sheet _), hxA, hyB, hAB.preimage _⟩
    · rw [← interior_eq_iff_isOpen]
      refine Subset.antisymm interior_subset ?_
      intro x hx
      by_contra hxint
      exact nhds_branch_not_disjoint hxint
        ((t2Space_iff_disjoint_nhds.1 h) (sheet_ne_sheet hij₀ hx))
  · rintro ⟨hX, hS⟩
    refine ⟨fun u v huv => ?_⟩
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    obtain ⟨j, y, rfl⟩ := exists_sheet v
    by_cases hxy : x = y
    · subst hxy
      have hxS : x ∈ S := by
        by_contra hxS
        exact huv (sheet_eq_sheet_of_notMem hxS)
      have hij : i ≠ j := fun hc => huv (by rw [hc])
      refine ⟨sheet S i '' S, sheet S j '' S, ?_, ?_, ⟨x, hxS, rfl⟩, ⟨x, hxS, rfl⟩, ?_⟩
      · refine (isOpen_iff _).2 fun k => ?_
        by_cases hik : i = k
        · subst hik; rw [slice_image_self]; exact hS
        · rw [slice_image_of_ne hik, sdiff_self]; exact isOpen_empty
      · refine (isOpen_iff _).2 fun k => ?_
        by_cases hjk : j = k
        · subst hjk; rw [slice_image_self]; exact hS
        · rw [slice_image_of_ne hjk, sdiff_self]; exact isOpen_empty
      · rw [Set.disjoint_left]
        rintro w ⟨a, ha, rfl⟩ ⟨b, hb, hEq⟩
        obtain ⟨rfl, hc⟩ := sheet_eq_sheet.1 hEq
        exact (hc.resolve_left (Ne.symm hij)) hb
    · exact separated_of_proj_ne (by simpa using hxy)

/-- **Guarded corner case.** With a single sheet, the foam is just `X`; the
Hausdorff obstruction genuinely needs branching. -/
noncomputable def homeomorphOfSubsingleton [Subsingleton ι] [Nonempty ι] : Foam X S ι ≃ₜ X where
  toFun := proj S ι
  invFun := sheet S (Classical.arbitrary ι)
  left_inv := by
    intro u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    exact sheet_eq_sheet.2 ⟨rfl, Or.inl (Subsingleton.elim _ _)⟩
  right_inv := fun x => rfl
  continuous_toFun := continuous_proj
  continuous_invFun := continuous_sheet _

/-! ### Consequences for physics: observables and metrics -/

/-- **No Hausdorff observable distinguishes branches.** If `f` is any continuous
map from the foam to a Hausdorff space (a measurement), then `f` takes the same
value on the two branches over any branch point that is not interior to the
branch locus. -/
theorem eq_of_continuous_t2 {Y : Type*} [TopologicalSpace Y] [T2Space Y]
    {f : Foam X S ι → Y} (hf : Continuous f) {x : X} {i j : ι}
    (hx' : x ∉ interior S) : f (sheet S i x) = f (sheet S j x) := by
  by_contra hne
  refine nhds_branch_not_disjoint (S := S) (i := i) (j := j) hx' ?_
  have hd : Disjoint (𝓝 (f (sheet S i x))) (𝓝 (f (sheet S j x))) :=
    t2Space_iff_disjoint_nhds.1 ‹T2Space Y› hne
  exact ((hf.tendsto _).disjoint hd (hf.tendsto _))

/-- With a branch locus that is not open, the foam admits **no metric**: there is
no Planck-scale distance function inducing its topology. -/
theorem not_metrizableSpace [Nontrivial ι] (hS : ¬ IsOpen S) :
    ¬ TopologicalSpace.MetrizableSpace (Foam X S ι) := by
  intro h
  haveI := h
  haveI : T2Space (Foam X S ι) := inferInstance
  exact hS (t2Space_foam_iff.1 ‹_›).2

/-- With finitely many sheets, compactness of the base passes to the foam:
the foam can be compact, T1 and yet non-Hausdorff. -/
theorem compactSpace [CompactSpace X] [Finite ι] : CompactSpace (Foam X S ι) := by
  constructor
  rw [← iUnion_range_sheet (S := S) (ι := ι)]
  exact isCompact_iUnion fun i => isCompact_range (continuous_sheet i)

/-- If the base is connected and some point is *not* a branch point, the foam is
connected: the sheets are glued along the non-branching part. -/
theorem connectedSpace_foam [ConnectedSpace X] [Nonempty ι] (hS : Sᶜ.Nonempty) :
    ConnectedSpace (Foam X S ι) := by
  obtain ⟨x₀, hx₀⟩ := hS
  have hpre : IsPreconnected (univ : Set (Foam X S ι)) := by
    rw [← iUnion_range_sheet (S := S) (ι := ι)]
    refine isPreconnected_iUnion ⟨sheet S (Classical.arbitrary ι) x₀, ?_⟩ (fun i => ?_)
    · simp only [mem_iInter, mem_range]
      exact fun i => ⟨x₀, sheet_eq_sheet_of_notMem hx₀⟩
    · rw [← image_univ]
      exact isPreconnected_univ.image _ (continuous_sheet i).continuousOn
  haveI : PreconnectedSpace (Foam X S ι) := ⟨hpre⟩
  haveI hne : Nonempty (Foam X S ι) := ⟨sheet S (Classical.arbitrary ι) x₀⟩
  exact ⟨hne⟩

end PlanckFoam