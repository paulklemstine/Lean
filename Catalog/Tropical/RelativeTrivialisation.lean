/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sheet numbers and relative trivialisations of tropical coverings

This file develops the *relative* theory of evenly covered neighbourhoods: instead of
trivialising a map `f : E → X` over a neighbourhood produced by the abstract definition of
`IsEvenlyCovered`, we run the trivialisation argument **relative to a prescribed open subset
`U` of the base**, producing a genuine decomposition of `f ⁻¹' V` into disjoint open *sheets*
for some open `V` with `x ∈ V ⊆ U`.

## Main definitions

* `Tropical.Sheets.sheetNumber f x` : the number `Nat.card (f ⁻¹' {x})` of points in the fibre.
* `Tropical.Sheets.SheetSystem f V ι` : a *sheet system* (relative trivialisation) of `f` over
  the set `V`: a family of open partial homeomorphisms `E → X`, all with target `V`, each
  agreeing with `f` on its source, with pairwise disjoint sources covering `f ⁻¹' V`.

## Main results

* `Tropical.Sheets.sheetNumber_eventually_eq_of_isCoveringMapOn`, `isLocallyConstant_sheetNumber`,
  `sheetNumber_const_of_isPreconnected`: local constancy of the sheet number.
* `Tropical.Sheets.lowerSemicontinuousAt_sheetNumber`,
  `upperSemicontinuousAt_sheetNumber`, `continuousAt_sheetNumber`: the semicontinuity package.
* `Tropical.Sheets.fiber_dichotomy`: over a preconnected set on which `f` is a covering map,
  either **all** fibres are empty or **all** fibres are nonempty.
* `Tropical.Sheets.SheetSystem.restrict`: a sheet system may be restricted to an open subset
  of the base.  This is the technical heart of the relative trivialisation.
* `Tropical.Sheets.IsCoveringMapOn.exists_sheetSystem`: **relative trivialisation**.  If `f` is a
  covering map on an open set `U` and `x ∈ U`, then there is an open `V` with `x ∈ V ⊆ U`
  carrying a sheet system indexed by the fibre `f ⁻¹' {x}`.
* `Tropical.Sheets.isCoveringMapOn_iff_exists_sheetSystem`: the resulting *characterisation* of
  `IsCoveringMapOn f U` for open `U`, purely in terms of relative sheet decompositions with no
  reference to any topology on the index type.
-/

open Topology Set

namespace Tropical.Sheets

universe u v

variable {E : Type u} {X : Type v} [TopologicalSpace E] [TopologicalSpace X] {f : E → X}
variable {s : Set X}

/-! ### The sheet number -/

/-- The number of sheets of `f : E → X` over the point `x`, i.e. the cardinality of the fibre.
By the convention of `Nat.card` this is `0` both for an empty and for an infinite fibre. -/
noncomputable def sheetNumber (f : E → X) (x : X) : ℕ := Nat.card (f ⁻¹' {x})

/-- Being evenly covered with fibre `I` is an open condition on the base point. -/
theorem isEvenlyCovered_eventually {I : Type*} [TopologicalSpace I] {x : X}
    (h : IsEvenlyCovered f x I) : ∀ᶠ y in 𝓝 x, IsEvenlyCovered f y I := by
  obtain ⟨inst, U, hxU, hU, hfU, H, hH⟩ := h
  filter_upwards [hU.mem_nhds hxU] with y hy
  exact ⟨inst, U, hy, hU, hfU, H, hH⟩

theorem IsEvenlyCovered.sheetNumber_eq {I : Type*} [TopologicalSpace I] {x : X}
    (h : IsEvenlyCovered f x I) : sheetNumber f x = Nat.card I :=
  (Nat.card_congr h.fiberHomeomorph.toEquiv).symm

theorem IsEvenlyCovered.nonempty_fiber_iff {I : Type*} [TopologicalSpace I] {x : X}
    (h : IsEvenlyCovered f x I) : (f ⁻¹' {x}).Nonempty ↔ Nonempty I := by
  rw [← Set.nonempty_coe_sort]
  exact ⟨fun ⟨e⟩ => ⟨h.fiberHomeomorph.symm e⟩, fun ⟨i⟩ => ⟨h.fiberHomeomorph i⟩⟩

theorem IsEvenlyCovered.sheetNumber_eventually_eq {I : Type*} [TopologicalSpace I] {x : X}
    (h : IsEvenlyCovered f x I) : ∀ᶠ y in 𝓝 x, sheetNumber f y = sheetNumber f x := by
  filter_upwards [isEvenlyCovered_eventually h] with y hy
  rw [IsEvenlyCovered.sheetNumber_eq hy, IsEvenlyCovered.sheetNumber_eq h]

theorem IsEvenlyCovered.eventually_nonempty_fiber_iff {I : Type*} [TopologicalSpace I] {x : X}
    (h : IsEvenlyCovered f x I) :
    ∀ᶠ y in 𝓝 x, ((f ⁻¹' {y}).Nonempty ↔ (f ⁻¹' {x}).Nonempty) := by
  filter_upwards [isEvenlyCovered_eventually h] with y hy
  rw [IsEvenlyCovered.nonempty_fiber_iff hy, IsEvenlyCovered.nonempty_fiber_iff h]

/-! ### Local constancy, semicontinuity and the dichotomy -/

theorem sheetNumber_eventually_eq_of_isCoveringMapOn (hf : IsCoveringMapOn f s) {x : X}
    (hx : x ∈ s) : ∀ᶠ y in 𝓝 x, sheetNumber f y = sheetNumber f x :=
  IsEvenlyCovered.sheetNumber_eventually_eq (hf x hx)

theorem isLocallyConstant_sheetNumber (hf : IsCoveringMapOn f s) :
    IsLocallyConstant fun y : s => sheetNumber f y := by
  rw [IsLocallyConstant.iff_eventually_eq]
  intro y
  exact continuous_subtype_val.continuousAt
    (sheetNumber_eventually_eq_of_isCoveringMapOn hf y.2)

theorem sheetNumber_const_of_isPreconnected (hf : IsCoveringMapOn f s) (hs : IsPreconnected s)
    {x y : X} (hx : x ∈ s) (hy : y ∈ s) : sheetNumber f x = sheetNumber f y := by
  haveI := Subtype.preconnectedSpace hs
  exact (isLocallyConstant_sheetNumber hf).apply_eq_of_preconnectedSpace ⟨x, hx⟩ ⟨y, hy⟩

theorem lowerSemicontinuousAt_sheetNumber (hf : IsCoveringMapOn f s) {x : X} (hx : x ∈ s) :
    LowerSemicontinuousAt (sheetNumber f) x := by
  intro n hn
  filter_upwards [sheetNumber_eventually_eq_of_isCoveringMapOn hf hx] with y hy
  rw [hy]; exact hn

theorem upperSemicontinuousAt_sheetNumber (hf : IsCoveringMapOn f s) {x : X} (hx : x ∈ s) :
    UpperSemicontinuousAt (sheetNumber f) x := by
  intro n hn
  filter_upwards [sheetNumber_eventually_eq_of_isCoveringMapOn hf hx] with y hy
  rw [hy]; exact hn

theorem continuousAt_sheetNumber (hf : IsCoveringMapOn f s) {x : X} (hx : x ∈ s) :
    ContinuousAt (sheetNumber f) x :=
  tendsto_const_nhds.congr' <| by
    filter_upwards [sheetNumber_eventually_eq_of_isCoveringMapOn hf hx] with y hy using hy.symm

/-- **Dichotomy.** Over a preconnected set on which `f` is a covering map, either every fibre
is empty or every fibre is nonempty. -/
theorem fiber_dichotomy (hf : IsCoveringMapOn f s) (hs : IsPreconnected s) :
    (∀ x ∈ s, f ⁻¹' {x} = ∅) ∨ (∀ x ∈ s, (f ⁻¹' {x}).Nonempty) := by
  haveI := Subtype.preconnectedSpace hs
  have hlc : IsLocallyConstant fun y : s => (f ⁻¹' {(y : X)}).Nonempty := by
    rw [IsLocallyConstant.iff_eventually_eq]
    intro y
    have := continuous_subtype_val.continuousAt
      (IsEvenlyCovered.eventually_nonempty_fiber_iff (hf y y.2))
    filter_upwards [this] with z hz
    exact propext hz
  rcases isEmpty_or_nonempty s with he | ⟨⟨x0, hx0⟩⟩
  · exact Or.inl fun x hx => (he.false ⟨x, hx⟩).elim
  by_cases h : (f ⁻¹' {x0}).Nonempty
  · refine Or.inr fun x hx => ?_
    have := hlc.apply_eq_of_preconnectedSpace ⟨x, hx⟩ ⟨x0, hx0⟩
    simpa [h] using this
  · refine Or.inl fun x hx => ?_
    have := hlc.apply_eq_of_preconnectedSpace ⟨x, hx⟩ ⟨x0, hx0⟩
    simp only [h, eq_iff_iff, iff_false] at this
    exact Set.not_nonempty_iff_eq_empty.mp this

/-! ### Sheet systems -/

/-- A **sheet system** (relative trivialisation) of `f : E → X` over the set `V ⊆ X`,
indexed by `ι`: a family of open partial homeomorphisms `E → X`, each with target exactly `V`
and each agreeing with `f` on its source, whose sources are pairwise disjoint and cover
`f ⁻¹' V`.  This is the concrete "stack of sheets over `V`" picture of a covering map. -/
structure SheetSystem (f : E → X) (V : Set X) (ι : Type*) where
  /-- The chart trivialising the `i`-th sheet. -/
  chart : ι → OpenPartialHomeomorph E X
  /-- Every sheet maps onto the whole of `V`. -/
  target_eq : ∀ i, (chart i).target = V
  /-- Every chart is a restriction of `f`. -/
  eqOn : ∀ i, Set.EqOn (chart i) f (chart i).source
  /-- Distinct sheets are disjoint. -/
  disjoint : Pairwise fun i j => Disjoint (chart i).source (chart j).source
  /-- The sheets exhaust the preimage of `V`. -/
  iUnion_source : ⋃ i, (chart i).source = f ⁻¹' V

variable {V : Set X} {ι : Type*}

theorem SheetSystem.isOpen_source (S : SheetSystem f V ι) (i : ι) : IsOpen (S.chart i).source :=
  (S.chart i).open_source

theorem SheetSystem.injOn (S : SheetSystem f V ι) (i : ι) :
    Set.InjOn f (S.chart i).source := fun a ha b hb hab =>
  (S.chart i).injOn ha hb (by rw [S.eqOn i ha, S.eqOn i hb]; exact hab)

theorem SheetSystem.symm_mem_source (S : SheetSystem f V ι) (i : ι) {y : X} (hy : y ∈ V) :
    (S.chart i).symm y ∈ (S.chart i).source :=
  (S.chart i).map_target (by rw [S.target_eq i]; exact hy)

theorem SheetSystem.surjOn (S : SheetSystem f V ι) (i : ι) :
    Set.SurjOn f (S.chart i).source V := by
  intro y hy
  refine ⟨(S.chart i).symm y, S.symm_mem_source i hy, ?_⟩
  rw [← S.eqOn i (S.symm_mem_source i hy)]
  exact (S.chart i).right_inv (by rw [S.target_eq i]; exact hy)

/-- The sheets of a sheet system are detected by openness downstairs. -/
theorem SheetSystem.isOpen_iff (S : SheetSystem f V ι) (i : ι) {W : Set X} (hW : W ⊆ V) :
    IsOpen W ↔ IsOpen (f ⁻¹' W ∩ (S.chart i).source) := by
  have hWt : W ⊆ (S.chart i).target := by rw [S.target_eq i]; exact hW
  have himg : (S.chart i).symm '' W = f ⁻¹' W ∩ (S.chart i).source := by
    rw [(S.chart i).symm_image_eq_source_inter_preimage hWt]
    ext e
    simp only [Set.mem_inter_iff, Set.mem_preimage]
    constructor
    · rintro ⟨h1, h2⟩; refine ⟨?_, h1⟩; rwa [S.eqOn i h1] at h2
    · rintro ⟨h1, h2⟩; refine ⟨h2, ?_⟩; rwa [S.eqOn i h2]
  rw [← himg, (S.chart i).isOpen_symm_image_iff_of_subset_target hWt]

/-- A sheet system over an open set `V` exhibits every point of `V` as evenly covered. -/
theorem SheetSystem.isEvenlyCovered [TopologicalSpace ι] [DiscreteTopology ι]
    (S : SheetSystem f V ι) (hV : IsOpen V) {x : X} (hx : x ∈ V) :
    IsEvenlyCovered f x ι := by
  classical
  rcases isEmpty_or_nonempty ι with hι | hι
  · refine IsEvenlyCovered.of_preimage_eq_empty ι (hV.mem_nhds hx) ?_
    rw [← S.iUnion_source]; simp
  · obtain ⟨i0⟩ := hι
    haveI : Nonempty ι := ⟨i0⟩
    obtain ⟨e0, -, -⟩ := S.surjOn i0 hx
    haveI : Nonempty (X → E) := ⟨fun _ => e0⟩
    refine IsEvenlyCovered.of_trivialization
      (t := IsOpen.trivializationDiscrete (fun i => (S.chart i).source) V hV
        (fun i _ hW => S.isOpen_iff i hW) S.injOn S.surjOn
        (fun i j hij => S.disjoint hij) (by rw [S.iUnion_source])) ?_
    rw [IsOpen.trivializationDiscrete_baseSet]
    exact hx

/-- A sheet system over an open set `V` exhibits every point of `V` as evenly covered by its
own fibre.  No topology on the index type is needed. -/
theorem SheetSystem.isEvenlyCovered_fiber (S : SheetSystem f V ι) (hV : IsOpen V) {x : X}
    (hx : x ∈ V) : IsEvenlyCovered f x (f ⁻¹' {x}) := by
  letI : TopologicalSpace ι := ⊥
  haveI : DiscreteTopology ι := ⟨rfl⟩
  exact (S.isEvenlyCovered hV hx).to_isEvenlyCovered_preimage

/-- The sheet number is constant on the base of a sheet system, equal to the number of sheets. -/
theorem SheetSystem.sheetNumber_eq (S : SheetSystem f V ι) (hV : IsOpen V) {x : X} (hx : x ∈ V) :
    sheetNumber f x = Nat.card ι := by
  letI : TopologicalSpace ι := ⊥
  haveI : DiscreteTopology ι := ⟨rfl⟩
  exact IsEvenlyCovered.sheetNumber_eq (S.isEvenlyCovered hV hx)

/-! ### Building sheet systems out of even coverings -/

open Classical in
/-- The `i`-th sheet chart attached to an explicit even covering `H : f ⁻¹' U ≃ₜ U × I`. -/
noncomputable def evenlyCoveredChart {I : Type*} [TopologicalSpace I] [DiscreteTopology I]
    {U : Set X} (hU : IsOpen U) (hfU : IsOpen (f ⁻¹' U))
    (H : (f ⁻¹' U) ≃ₜ U × I) (hH : ∀ e, ((H e).1 : X) = f e) (e₀ : E) (i : I) :
    OpenPartialHomeomorph E X where
  toFun := f
  invFun y := if hy : y ∈ U then ((H.symm (⟨y, hy⟩, i) : f ⁻¹' U) : E) else e₀
  source := Subtype.val '' ((fun e : f ⁻¹' U => (H e).2) ⁻¹' {i})
  target := U
  map_source' := by rintro e ⟨e', he', rfl⟩; exact e'.2
  map_target' := fun y hy => ⟨H.symm (⟨y, hy⟩, i), by simp, by rw [dif_pos hy]⟩
  left_inv' := by
    rintro e ⟨e', he', rfl⟩
    have h1 : f (e' : E) ∈ U := e'.2
    rw [dif_pos h1]
    congr 1
    have h2 : (⟨f (e' : E), h1⟩ : U) = (H e').1 := by ext; exact (hH e').symm
    rw [h2]
    have h3 : ((H e').1, i) = H e' := by
      simp only [Set.mem_preimage, Set.mem_singleton_iff] at he'
      rw [← he']
    rw [h3, Homeomorph.symm_apply_apply]
  right_inv' := by
    intro y hy
    rw [dif_pos hy]
    have := hH (H.symm (⟨y, hy⟩, i))
    simp at this
    exact this.symm
  open_source := by
    apply hfU.isOpenMap_subtype_val
    exact (H.continuous.snd).isOpen_preimage _ (isOpen_discrete _)
  open_target := hU
  continuousOn_toFun := by
    apply ContinuousOn.mono (s := f ⁻¹' U)
    · exact continuousOn_iff_continuous_restrict.mpr
        (by have : (f ⁻¹' U).restrict f = fun e => ((H e).1 : X) := by funext e; exact (hH e).symm
            rw [this]; fun_prop)
    · rintro e ⟨e', he', rfl⟩; exact e'.2
  continuousOn_invFun := by
    apply continuousOn_iff_continuous_restrict.mpr
    have : (U.restrict fun y => if hy : y ∈ U then ((H.symm (⟨y, hy⟩, i) : f ⁻¹' U) : E) else e₀)
        = fun y : U => ((H.symm (y, i) : f ⁻¹' U) : E) := by
      funext y; simp [Set.restrict]
    rw [this]; fun_prop

/-- Every evenly covered point carries a sheet system over its evenly covered neighbourhood. -/
theorem exists_sheetSystem_of_isEvenlyCovered {I : Type*} [TopologicalSpace I] {x : X}
    (h : IsEvenlyCovered f x I) :
    ∃ V : Set X, x ∈ V ∧ IsOpen V ∧ Nonempty (SheetSystem f V I) := by
  obtain ⟨inst, U, hxU, hU, hfU, H, hH⟩ := h
  refine ⟨U, hxU, hU, ?_⟩
  rcases isEmpty_or_nonempty I with hI | hI
  · have hemp : f ⁻¹' U = ∅ := by
      rw [Set.eq_empty_iff_forall_notMem]
      exact fun e he => hI.false (H ⟨e, he⟩).2
    exact ⟨{ chart := isEmptyElim
             target_eq := isEmptyElim
             eqOn := isEmptyElim
             disjoint := fun i => isEmptyElim i
             iUnion_source := by simp [hemp] }⟩
  · classical
    refine ⟨{ chart := fun i => evenlyCoveredChart hU hfU H hH
                (H.symm (⟨x, hxU⟩, Classical.arbitrary I) : E) i
              target_eq := fun _ => rfl
              eqOn := fun _ => fun _ _ => rfl
              disjoint := ?_
              iUnion_source := ?_ }⟩
    · rintro i j hij
      rw [Set.disjoint_left]
      rintro e ⟨e', he', rfl⟩ ⟨e'', he'', he2⟩
      have hee : e'' = e' := Subtype.ext he2
      subst hee
      simp only [Set.mem_preimage, Set.mem_singleton_iff] at he' he''
      exact hij (he'.symm.trans he'')
    · apply Set.Subset.antisymm
      · rintro e he
        rw [Set.mem_iUnion] at he
        obtain ⟨i, e', he', rfl⟩ := he
        exact e'.2
      · intro e he
        rw [Set.mem_iUnion]
        exact ⟨(H ⟨e, he⟩).2, ⟨e, he⟩, rfl, rfl⟩

/-! ### Relative trivialisation: restricting to an open subset of the base -/

/-- **Restriction of a sheet system to an open subset of the base.**  This is the step that
turns an abstract even covering into a trivialisation over a *prescribed* open piece of the
base: the sheets are cut down by the preimage of `W`, and the new common target is `W ∩ V`. -/
def SheetSystem.restrict (S : SheetSystem f V ι) {W : Set X} (hW : IsOpen W) :
    SheetSystem f (W ∩ V) ι where
  chart i := (S.chart i).trans (OpenPartialHomeomorph.ofSet W hW)
  target_eq i := by
    rw [OpenPartialHomeomorph.trans_target]
    simp [S.target_eq i]
  eqOn i := by
    intro e he
    rw [OpenPartialHomeomorph.trans_source] at he
    simp only [OpenPartialHomeomorph.coe_trans, Function.comp_apply,
      OpenPartialHomeomorph.ofSet_apply, id_eq]
    exact S.eqOn i he.1
  disjoint i j hij := by
    dsimp only
    rw [OpenPartialHomeomorph.trans_source, OpenPartialHomeomorph.trans_source]
    exact (S.disjoint hij).mono Set.inter_subset_left Set.inter_subset_left
  iUnion_source := by
    have hsrc : ∀ i, ((S.chart i).trans (OpenPartialHomeomorph.ofSet W hW)).source
        = (S.chart i).source ∩ f ⁻¹' W := by
      intro i
      rw [OpenPartialHomeomorph.trans_source]
      simp only [OpenPartialHomeomorph.ofSet_source]
      ext e
      simp only [Set.mem_inter_iff, Set.mem_preimage]
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨h1, by rwa [S.eqOn i h1] at h2⟩
      · rintro ⟨h1, h2⟩; exact ⟨h1, by rwa [S.eqOn i h1]⟩
    simp only [hsrc, ← Set.iUnion_inter, S.iUnion_source]
    rw [← Set.preimage_inter]
    congr 1
    exact Set.inter_comm V W

/-- Reindexing a sheet system along an equivalence of index types. -/
def SheetSystem.reindex {κ : Type*} (S : SheetSystem f V ι) (e : κ ≃ ι) : SheetSystem f V κ where
  chart k := S.chart (e k)
  target_eq k := S.target_eq (e k)
  eqOn k := S.eqOn (e k)
  disjoint k l hkl := S.disjoint (fun h => hkl (e.injective h))
  iUnion_source := by
    rw [← S.iUnion_source]
    exact Set.iUnion_congr_of_surjective _ e.surjective fun _ => rfl

/-- **Relative trivialisation theorem.**  If `f` is a covering map on the open set `U` and
`x ∈ U`, then the trivialisation argument can be run *inside* `U`: there is an open
neighbourhood `V` of `x` contained in `U` over which `f ⁻¹' V` decomposes into disjoint open
sheets indexed by the fibre `f ⁻¹' {x}`, each mapped homeomorphically onto `V` by `f`. -/
theorem IsCoveringMapOn.exists_sheetSystem {U : Set X} (hf : IsCoveringMapOn f U) (hU : IsOpen U)
    {x : X} (hx : x ∈ U) :
    ∃ V : Set X, x ∈ V ∧ V ⊆ U ∧ IsOpen V ∧ Nonempty (SheetSystem f V (f ⁻¹' {x})) := by
  obtain ⟨V₀, hxV₀, hV₀, ⟨S⟩⟩ := exists_sheetSystem_of_isEvenlyCovered (hf x hx)
  exact ⟨U ∩ V₀, ⟨hx, hxV₀⟩, Set.inter_subset_left, hU.inter hV₀, ⟨S.restrict hU⟩⟩

/-- **Characterisation of relative covering maps by sheet decompositions.**  For an open base
set `U`, `f` is a covering map on `U` exactly when every point of `U` has an open neighbourhood
inside `U` over which `f` admits a sheet system.  Note that no topology on the index type is
required in either direction. -/
theorem isCoveringMapOn_iff_exists_sheetSystem {U : Set X} (hU : IsOpen U) :
    IsCoveringMapOn f U ↔ ∀ x ∈ U, ∃ (V : Set X) (κ : Type u),
      x ∈ V ∧ V ⊆ U ∧ IsOpen V ∧ Nonempty (SheetSystem f V κ) := by
  constructor
  · intro hf x hx
    obtain ⟨V, hxV, hVU, hV, hS⟩ := IsCoveringMapOn.exists_sheetSystem hf hU hx
    exact ⟨V, (f ⁻¹' {x} : Set E), hxV, hVU, hV, hS⟩
  · intro h x hx
    obtain ⟨V, κ, hxV, -, hV, ⟨S⟩⟩ := h x hx
    exact S.isEvenlyCovered_fiber hV hxV

/-- On the base of a relative trivialisation the sheet number is constant, and it is computed
by the number of sheets. -/
theorem IsCoveringMapOn.sheetNumber_eq_of_sheetSystem {U : Set X} (hU : IsOpen U)
    (S : SheetSystem f U ι) {x : X} (hx : x ∈ U) : sheetNumber f x = Nat.card ι :=
  S.sheetNumber_eq hU hx

end Tropical.Sheets