/-
Copyright (c) 2025 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Cryptography.Transreal.Topology

/-!
# The transreal carrier as an end compactification: a uniqueness theorem

`Cryptography.Transreal.Topology` topologises the four-constructor carrier

```
Transreal ::= fin ℝ | pinf | ninf | null
```

*by fiat*, as the two-point compactification `EReal` of the line disjointly
unioned with an isolated point for nullity.  The purpose of this file is to show
that this choice is **forced**, and to locate exactly the hypothesis that forces
it.

## The structure of the argument

Write `t` for an arbitrary topology on the carrier.  We call `t` a
*transreal compactification* (`Transreal.IsCompactification`) when

* `t` is compact Hausdorff;
* `fin : ℝ → Transreal` is a `t`-open embedding;
* `{null}` is `t`-open.

These are exactly the axioms of the informal conjecture.  They do **not**
suffice (see `Novelty.TransrealExoticTopology`): the complement of `{null}` is a
compact Hausdorff space containing `ℝ` as an open subspace with a two-point
remainder, but such a space need not be the *end* compactification — one of the
two remainder points may be an isolated point sitting beside a **circle**
(the one-point compactification of the line).

What rules the exotic models out is an *orientation*, i.e. the requirement that
each infinity really is an end of the line:

```
hp : pinf ∈ closure (fin '' Ioi 0)      hn : ninf ∈ closure (fin '' Iio 0)
```

The main theorem `Transreal.topology_eq_of_isCompactification` says that these
two conditions upgrade the axioms to a **complete characterisation**:

```
t = Transreal.instTopologicalSpace ↔ IsCompactification t ∧ hp ∧ hn
```

so every sharpness statement proved in the natural topology is
topology-canonical relative to the ends data, not an artefact of the model.

## The ends argument

The engine is a genuine ends argument for the real line:

* `Transreal.exists_gt_mem_of_isOpen` / `Transreal.exists_lt_mem_of_isOpen`:
  every `t`-neighbourhood of `pinf` (resp. `ninf`) contains **arbitrarily large
  positive** (resp. **arbitrarily large negative**) finite points.  This is the
  statement that the infinities are ends and not merely limit points.
* `Transreal.exists_rays`: separating the two infinities produces a compact
  `t`-closed core inside the finite fragment, hence a radius `M` outside which
  the line is covered by the two separating open sets; connectedness of the
  rays `Ioi M`, `Iio (-M)` forces each ray into a single one of them, and the
  ends property forces the two rays into *different* ones.
* `Transreal.exists_nhd_pinf` / `Transreal.exists_nhd_ninf`: consequently the
  sets `{pinf} ∪ fin '' (Ioi b)` and `{ninf} ∪ fin '' (Iio b)` are
  neighbourhood bases at the two infinities — which is precisely the
  neighbourhood filter of `⊤` and `⊥` in `EReal`.
* Finally a compact-to-Hausdorff comparison upgrades the resulting inequality
  of topologies to equality.
-/

namespace Transreal

open Set Topology Filter

/-! ### The axioms of a transreal compactification -/

/-- A topology `t` on the four-constructor carrier is a *transreal
compactification* when it is compact Hausdorff, makes the finite fragment an
open copy of the line, and isolates nullity.  These are the axioms of the
uniqueness conjecture. -/
structure IsCompactification (t : TopologicalSpace Transreal) : Prop where
  /-- The carrier is `t`-compact. -/
  compactSpace : @CompactSpace Transreal t
  /-- The carrier is `t`-Hausdorff. -/
  t2Space : @T2Space Transreal t
  /-- The finite fragment is an open copy of the line. -/
  isOpenEmbedding_fin : @IsOpenEmbedding ℝ Transreal _ t fin
  /-- Nullity is isolated. -/
  isOpen_null : IsOpen[t] ({null} : Set Transreal)


theorem pinf_ne_ninf : (pinf : Transreal) ≠ ninf := fun h => Transreal.noConfusion h

theorem pinf_notMem_range_fin : (pinf : Transreal) ∉ range fin := by
  rintro ⟨x, hx⟩; cases hx

theorem ninf_notMem_range_fin : (ninf : Transreal) ∉ range fin := by
  rintro ⟨x, hx⟩; cases hx

theorem null_notMem_range_fin : (null : Transreal) ∉ range fin := by
  rintro ⟨x, hx⟩; cases hx


/-! ### The natural topology: it satisfies the axioms, and its neighbourhood filters

Everything in this section is about the *fixed* natural topology
`Transreal.instTopologicalSpace`; no variable topology is in scope. -/

theorem isOpenEmbedding_toSum : IsOpenEmbedding toSum :=
  ⟨isEmbedding_toSum, by rw [toSum_surjective.range_eq]; exact isOpen_univ⟩

theorem tendsto_fin_atTop : Tendsto (fun x : ℝ => fin x) atTop (𝓝 pinf) := by
  rw [isEmbedding_toSum.tendsto_nhds_iff]
  have h1 : Tendsto (fun x : ℝ => ((x : EReal))) atTop (𝓝 (⊤ : EReal)) :=
    EReal.tendsto_coe_nhds_top_iff.2 tendsto_id
  exact (continuous_inl.tendsto _).comp h1

theorem tendsto_fin_atBot : Tendsto (fun x : ℝ => fin x) atBot (𝓝 ninf) := by
  rw [isEmbedding_toSum.tendsto_nhds_iff]
  have h1 : Tendsto (fun x : ℝ => ((x : EReal))) atBot (𝓝 (⊥ : EReal)) :=
    EReal.tendsto_coe_nhds_bot_iff.2 tendsto_id
  exact (continuous_inl.tendsto _).comp h1

/-- In the natural topology `pinf` is a limit of positive finite values: it is the
positive end of the line. -/
theorem pinf_mem_closure : pinf ∈ closure (fin '' Ioi (0 : ℝ)) := by
  refine mem_closure_of_tendsto tendsto_fin_atTop ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
  exact ⟨x, hx, rfl⟩

/-- In the natural topology `ninf` is a limit of negative finite values: it is the
negative end of the line. -/
theorem ninf_mem_closure : ninf ∈ closure (fin '' Iio (0 : ℝ)) := by
  refine mem_closure_of_tendsto tendsto_fin_atBot ?_
  filter_upwards [eventually_lt_atBot (0 : ℝ)] with x hx
  exact ⟨x, hx, rfl⟩

/-- The natural topology is a transreal compactification in the sense of
`Transreal.IsCompactification`. -/
theorem isCompactification_instTopologicalSpace :
    IsCompactification instTopologicalSpace where
  compactSpace := instCompactSpace
  t2Space := instT2Space
  isOpenEmbedding_fin := isOpenEmbedding_fin
  isOpen_null := isOpen_singleton_null

/-- A natural-topology neighbourhood of `pinf` contains a whole tail ray: the
neighbourhood filter of `pinf` is that of `⊤ : EReal`. -/
theorem exists_ray_subset_of_isOpen_pinf {s : Set Transreal} (hs : IsOpen s)
    (ha : pinf ∈ s) : ∃ b : ℝ, insert pinf (fin '' Ioi b) ⊆ s := by
  obtain ⟨b, hb⟩ : ∃ b : ℝ, Ioi (b : EReal) ⊆ Sum.inl ⁻¹' (toSum '' s) :=
    EReal.mem_nhds_top_iff.1
      (IsOpen.mem_nhds ((isOpenEmbedding_toSum.isOpenMap _ hs).preimage continuous_inl)
        ⟨pinf, ha, rfl⟩)
  refine ⟨b, ?_⟩
  rintro a (rfl | ⟨x, hx, rfl⟩)
  · exact ha
  · have hx' : ((x : ℝ) : EReal) ∈ Ioi (b : EReal) := Set.mem_Ioi.2 (EReal.coe_lt_coe_iff.2 hx)
    obtain ⟨y, hy, hy'⟩ := hb hx'
    have hyx : y = fin x := toSum_injective hy'
    rwa [hyx] at hy

/-- A natural-topology neighbourhood of `ninf` contains a whole tail ray: the
neighbourhood filter of `ninf` is that of `⊥ : EReal`. -/
theorem exists_ray_subset_of_isOpen_ninf {s : Set Transreal} (hs : IsOpen s)
    (ha : ninf ∈ s) : ∃ b : ℝ, insert ninf (fin '' Iio b) ⊆ s := by
  obtain ⟨b, hb⟩ : ∃ b : ℝ, Iio (b : EReal) ⊆ Sum.inl ⁻¹' (toSum '' s) :=
    EReal.mem_nhds_bot_iff.1
      (IsOpen.mem_nhds ((isOpenEmbedding_toSum.isOpenMap _ hs).preimage continuous_inl)
        ⟨ninf, ha, rfl⟩)
  refine ⟨b, ?_⟩
  rintro a (rfl | ⟨x, hx, rfl⟩)
  · exact ha
  · have hx' : ((x : ℝ) : EReal) ∈ Iio (b : EReal) := Set.mem_Iio.2 (EReal.coe_lt_coe_iff.2 hx)
    obtain ⟨y, hy, hy'⟩ := hb hx'
    have hyx : y = fin x := toSum_injective hy'
    rwa [hyx] at hy

/-- A natural-topology neighbourhood of a finite point contains the image of an
open set of reals. -/
theorem isOpen_preimage_fin_of_isOpen {s : Set Transreal} (hs : IsOpen s) :
    IsOpen (fin ⁻¹' s) := hs.preimage continuous_fin

/-- In the natural topology, `pinf` is **not** isolated. -/
theorem not_isOpen_singleton_pinf : ¬ IsOpen ({pinf} : Set Transreal) := by
  intro hopen
  obtain ⟨b, hb⟩ := exists_ray_subset_of_isOpen_pinf hopen rfl
  have : fin (b + 1) ∈ ({pinf} : Set Transreal) := hb (Or.inr ⟨b + 1, by simp, rfl⟩)
  simp at this

/-- In the natural topology, `ninf` is **not** isolated. -/
theorem not_isOpen_singleton_ninf : ¬ IsOpen ({ninf} : Set Transreal) := by
  intro hopen
  obtain ⟨b, hb⟩ := exists_ray_subset_of_isOpen_ninf hopen rfl
  have : fin (b - 1) ∈ ({ninf} : Set Transreal) := hb (Or.inr ⟨b - 1, by simp, rfl⟩)
  simp at this


section Ends

variable {t : TopologicalSpace Transreal}

/-! ### The two infinities are ends -/

/-- **The positive end.**  If `pinf` is a limit of positive finite values then
every `t`-neighbourhood of `pinf` contains arbitrarily large positive finite
values.  (The upgrade from "some" to "arbitrarily large" uses only that compact
subsets of the line are `t`-closed.) -/
theorem exists_gt_mem_of_isOpen (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0))
    {W : Set Transreal} (hW : IsOpen[t] W) (hpW : pinf ∈ W) (c : ℝ) :
    ∃ x : ℝ, c < x ∧ fin x ∈ W := by
  letI := t
  haveI := h.t2Space
  have hcont : Continuous (fin : ℝ → Transreal) := h.isOpenEmbedding_fin.continuous
  set d : ℝ := |c| with hd
  have hd0 : 0 ≤ d := abs_nonneg c
  have hL : IsClosed (fin '' Icc (-d) d) := (isCompact_Icc.image hcont).isClosed
  have hW' : IsOpen (W \ fin '' Icc (-d) d) := hW.sdiff hL
  have hpW' : pinf ∈ W \ fin '' Icc (-d) d := by
    refine ⟨hpW, ?_⟩
    rintro ⟨x, -, hx⟩
    cases hx
  obtain ⟨y, hy1, hy2⟩ := mem_closure_iff.1 hp _ hW' hpW'
  obtain ⟨x, hx0, rfl⟩ := hy2
  refine ⟨x, ?_, hy1.1⟩
  have hxnot : x ∉ Icc (-d) d := fun hx => hy1.2 ⟨x, hx, rfl⟩
  have hx0' : (0 : ℝ) < x := hx0
  have : d < x := by
    by_contra hcon
    exact hxnot ⟨by linarith, by linarith⟩
  calc c ≤ |c| := le_abs_self c
    _ = d := hd.symm
    _ < x := this

/-- **The negative end.**  The mirror image of `Transreal.exists_gt_mem_of_isOpen`. -/
theorem exists_lt_mem_of_isOpen (h : IsCompactification t)
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0))
    {W : Set Transreal} (hW : IsOpen[t] W) (hnW : ninf ∈ W) (c : ℝ) :
    ∃ x : ℝ, x < c ∧ fin x ∈ W := by
  letI := t
  haveI := h.t2Space
  have hcont : Continuous (fin : ℝ → Transreal) := h.isOpenEmbedding_fin.continuous
  set d : ℝ := |c| with hd
  have hd0 : 0 ≤ d := abs_nonneg c
  have hL : IsClosed (fin '' Icc (-d) d) := (isCompact_Icc.image hcont).isClosed
  have hW' : IsOpen (W \ fin '' Icc (-d) d) := hW.sdiff hL
  have hnW' : ninf ∈ W \ fin '' Icc (-d) d := by
    refine ⟨hnW, ?_⟩
    rintro ⟨x, -, hx⟩
    cases hx
  obtain ⟨y, hy1, hy2⟩ := mem_closure_iff.1 hn _ hW' hnW'
  obtain ⟨x, hx0, rfl⟩ := hy2
  refine ⟨x, ?_, hy1.1⟩
  have hxnot : x ∉ Icc (-d) d := fun hx => hy1.2 ⟨x, hx, rfl⟩
  have hx0' : x < (0 : ℝ) := hx0
  have : x < -d := by
    by_contra hcon
    exact hxnot ⟨by linarith, by linarith⟩
  have : -d ≤ c := by
    have := neg_abs_le c
    linarith [hd ▸ this]
  linarith

/-! ### The ray partition -/

/-- **The two-point remainder splits the two rays.**  Assume only that each
infinity is *unoriented end data*: every neighbourhood of it contains finite
points of arbitrarily large modulus.  Then there is a radius `M` and a pair of
disjoint open sets, one containing `pinf`, the other `ninf`, neither containing
nullity, such that the two rays `(M, ∞)` and `(-∞, -M)` are separated by them —
in one order or the other.

This is the ends argument proper: a compact `t`-closed core inside the finite
fragment bounds the part of the line that is not yet separated, connectedness of
each ray sends it wholly into one of the two open sets, and the end property
forbids the two rays from choosing the same one. -/
theorem exists_rays_aux (h : IsCompactification t)
    (hfarP : ∀ W : Set Transreal, IsOpen[t] W → pinf ∈ W → ∀ c : ℝ,
      ∃ x : ℝ, c < |x| ∧ fin x ∈ W)
    (hfarN : ∀ W : Set Transreal, IsOpen[t] W → ninf ∈ W → ∀ c : ℝ,
      ∃ x : ℝ, c < |x| ∧ fin x ∈ W) :
    ∃ (M : ℝ) (U V : Set Transreal), IsOpen[t] U ∧ IsOpen[t] V ∧
      pinf ∈ U ∧ ninf ∈ V ∧ Disjoint U V ∧ null ∉ U ∧ null ∉ V ∧
      (((∀ x : ℝ, M < x → fin x ∈ U) ∧ (∀ x : ℝ, x < -M → fin x ∈ V)) ∨
        ((∀ x : ℝ, M < x → fin x ∈ V) ∧ (∀ x : ℝ, x < -M → fin x ∈ U))) := by
  letI := t
  haveI := h.t2Space
  haveI := h.compactSpace
  have hcont : Continuous (fin : ℝ → Transreal) := h.isOpenEmbedding_fin.continuous
  obtain ⟨U0, V0, hU0, hV0, hpU0, hnV0, hUV0⟩ := t2_separation (pinf_ne_ninf)
  -- Enlarge `U0` by nullity so that the uncovered core lies inside the line.
  set U1 : Set Transreal := U0 ∪ {null} with hU1def
  set V1 : Set Transreal := V0 \ {null} with hV1def
  have hnullclosed : IsClosed ({null} : Set Transreal) := isClosed_singleton
  have hU1 : IsOpen U1 := hU0.union h.isOpen_null
  have hV1 : IsOpen V1 := hV0.sdiff hnullclosed
  have hdisj : Disjoint U1 V1 := by
    rw [Set.disjoint_left]
    rintro a (haU | ha) haV
    · exact (Set.disjoint_left.1 hUV0 haU) haV.1
    · exact haV.2 ha
  -- The core is compact and lies inside the finite fragment.
  have hKclosed : IsClosed ((U1 ∪ V1)ᶜ) := (hU1.union hV1).isClosed_compl
  have hKcompact : IsCompact ((U1 ∪ V1)ᶜ) := hKclosed.isCompact
  have hKsub : (U1 ∪ V1)ᶜ ⊆ range fin := by
    intro a ha
    cases a with
    | fin x => exact ⟨x, rfl⟩
    | pinf => exact absurd (Or.inl (Or.inl hpU0)) ha
    | ninf => exact absurd (Or.inr ⟨hnV0, by simp⟩) ha
    | null => exact absurd (Or.inl (Or.inr rfl)) ha
  have himg : fin '' (fin ⁻¹' ((U1 ∪ V1)ᶜ)) = (U1 ∪ V1)ᶜ :=
    Set.image_preimage_eq_of_subset hKsub
  have hS : IsCompact (fin ⁻¹' ((U1 ∪ V1)ᶜ)) := by
    rw [h.isOpenEmbedding_fin.isEmbedding.isCompact_iff, himg]
    exact hKcompact
  obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ∈ fin ⁻¹' ((U1 ∪ V1)ᶜ), |x| ≤ M := by
    obtain ⟨a, ha⟩ := hS.bddAbove
    obtain ⟨b, hb⟩ := hS.bddBelow
    refine ⟨max a (-b), fun x hx => abs_le.2 ⟨?_, ?_⟩⟩
    · have h1 : b ≤ x := hb hx
      have h2 : -b ≤ max a (-b) := le_max_right _ _
      linarith
    · exact le_trans (ha hx) (le_max_left _ _)
  have hcover : ∀ x : ℝ, M < |x| → fin x ∈ U1 ∪ V1 := by
    intro x hx
    by_contra hcon
    exact absurd (hM x hcon) (not_le.2 hx)
  -- Each ray is connected, hence lands entirely in one of the two open sets.
  have hopenU : IsOpen (fin ⁻¹' U1) := hU1.preimage hcont
  have hopenV : IsOpen (fin ⁻¹' V1) := hV1.preimage hcont
  have hdisjpre : Disjoint (fin ⁻¹' U1) (fin ⁻¹' V1) := by
    rw [Set.disjoint_left]
    intro x hx hx'
    exact (Set.disjoint_left.1 hdisj hx) hx'
  have hIoi : Ioi M ⊆ fin ⁻¹' U1 ∨ Ioi M ⊆ fin ⁻¹' V1 := by
    refine IsPreconnected.subset_or_subset hopenU hopenV hdisjpre ?_ isPreconnected_Ioi
    intro x hx
    have hx' : M < |x| := lt_of_lt_of_le hx (le_abs_self x)
    exact hcover x hx'
  have hIio : Iio (-M) ⊆ fin ⁻¹' U1 ∨ Iio (-M) ⊆ fin ⁻¹' V1 := by
    refine IsPreconnected.subset_or_subset hopenU hopenV hdisjpre ?_ isPreconnected_Iio
    intro x hx
    have hx' : M < |x| := by
      have : x < -M := hx
      have : M < -x := by linarith
      calc M < -x := this
        _ ≤ |x| := neg_le_abs x
    exact hcover x hx'
  -- The end property forbids both rays from choosing the same side.
  have hnotUU : ¬ (Ioi M ⊆ fin ⁻¹' U1 ∧ Iio (-M) ⊆ fin ⁻¹' U1) := by
    rintro ⟨h1, h2⟩
    obtain ⟨x, hx, hxV⟩ := hfarN V1 hV1 ⟨hnV0, by simp⟩ M
    rcases lt_abs.1 hx with hpos | hneg
    · exact (Set.disjoint_left.1 hdisj (h1 hpos)) hxV
    · exact (Set.disjoint_left.1 hdisj (h2 (by simp only [Set.mem_Iio]; linarith))) hxV
  have hnotVV : ¬ (Ioi M ⊆ fin ⁻¹' V1 ∧ Iio (-M) ⊆ fin ⁻¹' V1) := by
    rintro ⟨h1, h2⟩
    obtain ⟨x, hx, hxU⟩ := hfarP U1 hU1 (Or.inl hpU0) M
    rcases lt_abs.1 hx with hpos | hneg
    · exact (Set.disjoint_left.1 hdisj hxU) (h1 hpos)
    · exact (Set.disjoint_left.1 hdisj hxU) (h2 (by simp only [Set.mem_Iio]; linarith))
  have hcase : ((Ioi M ⊆ fin ⁻¹' U1) ∧ (Iio (-M) ⊆ fin ⁻¹' V1)) ∨
      ((Ioi M ⊆ fin ⁻¹' V1) ∧ (Iio (-M) ⊆ fin ⁻¹' U1)) := by
    rcases hIoi with h1 | h1 <;> rcases hIio with h2 | h2
    · exact absurd ⟨h1, h2⟩ hnotUU
    · exact Or.inl ⟨h1, h2⟩
    · exact Or.inr ⟨h1, h2⟩
    · exact absurd ⟨h1, h2⟩ hnotVV
  refine ⟨M, U1 \ {null}, V1, hU1.sdiff hnullclosed, hV1, ⟨Or.inl hpU0, by simp⟩,
    ⟨hnV0, by simp⟩, Disjoint.mono_left Set.diff_subset hdisj, by simp,
    fun hc => hc.2 rfl, ?_⟩
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨fun x hx => ⟨h1 hx, by simp⟩, fun x hx => h2 hx⟩
  · exact Or.inr ⟨fun x hx => h1 hx, fun x hx => ⟨h2 hx, by simp⟩⟩

/-- Every neighbourhood of `pinf` contains finite points of arbitrarily large
modulus, given the positive orientation. -/
theorem far_of_pinf_mem_closure (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0)) :
    ∀ W : Set Transreal, IsOpen[t] W → pinf ∈ W → ∀ c : ℝ, ∃ x : ℝ, c < |x| ∧ fin x ∈ W := by
  intro W hW hpW c
  obtain ⟨x, hx, hxW⟩ := exists_gt_mem_of_isOpen h hp hW hpW |c|
  refine ⟨x, ?_, hxW⟩
  have h1 : x ≤ |x| := le_abs_self x
  have h2 : c ≤ |c| := le_abs_self c
  linarith

/-- Every neighbourhood of `ninf` contains finite points of arbitrarily large
modulus, given the negative orientation. -/
theorem far_of_ninf_mem_closure (h : IsCompactification t)
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0)) :
    ∀ W : Set Transreal, IsOpen[t] W → ninf ∈ W → ∀ c : ℝ, ∃ x : ℝ, c < |x| ∧ fin x ∈ W := by
  intro W hW hnW c
  obtain ⟨x, hx, hxW⟩ := exists_lt_mem_of_isOpen h hn hW hnW (-|c|)
  refine ⟨x, ?_, hxW⟩
  have h1 : -x ≤ |x| := neg_le_abs x
  have h2 : c ≤ |c| := le_abs_self c
  linarith

/-- **The ends separate the two rays.**  Under the compactification axioms
together with the two orientation conditions, the ray `(M, ∞)` lands in a
neighbourhood of `pinf` and the ray `(-∞, -M)` in a disjoint neighbourhood of
`ninf`. -/
theorem exists_rays (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0))
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0)) :
    ∃ (M : ℝ) (U V : Set Transreal), IsOpen[t] U ∧ IsOpen[t] V ∧
      pinf ∈ U ∧ ninf ∈ V ∧ Disjoint U V ∧ null ∉ U ∧ null ∉ V ∧
      (∀ x : ℝ, M < x → fin x ∈ U) ∧ (∀ x : ℝ, x < -M → fin x ∈ V) := by
  obtain ⟨M, U, V, hU, hV, hpU, hnV, hUV, hnullU, hnullV, hcase⟩ :=
    exists_rays_aux h (far_of_pinf_mem_closure h hp) (far_of_ninf_mem_closure h hn)
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact ⟨M, U, V, hU, hV, hpU, hnV, hUV, hnullU, hnullV, h1, h2⟩
  · exfalso
    obtain ⟨x, hx, hxU⟩ := exists_gt_mem_of_isOpen h hp hU hpU M
    exact (Set.disjoint_left.1 hUV hxU) (h1 x hx)

/-! ### Neighbourhood bases at the two infinities -/

/-- The sets `{pinf} ∪ fin '' (Ioi b)` are a neighbourhood basis at `pinf`:
this is exactly the neighbourhood filter of `⊤` in `EReal`. -/
theorem exists_nhd_pinf (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0))
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0)) (b : ℝ) :
    ∃ W : Set Transreal, IsOpen[t] W ∧ pinf ∈ W ∧ W ⊆ insert pinf (fin '' Ioi b) := by
  letI := t
  haveI := h.t2Space
  have hcont : Continuous (fin : ℝ → Transreal) := h.isOpenEmbedding_fin.continuous
  obtain ⟨M, U, V, hU, hV, hpU, hnV, hUV, hnullU, hnullV, hrayU, hrayV⟩ :=
    exists_rays h hp hn
  set d : ℝ := max b M with hd
  have hdb : b ≤ d := le_max_left _ _
  have hdM : M ≤ d := le_max_right _ _
  have hL : IsClosed (fin '' Icc (-d) d) := (isCompact_Icc.image hcont).isClosed
  refine ⟨U \ fin '' Icc (-d) d, hU.sdiff hL, ⟨hpU, by rintro ⟨x, -, hx⟩; cases hx⟩, ?_⟩
  rintro a ⟨haU, haL⟩
  cases a with
  | fin x =>
      have hxnot : x ∉ Icc (-d) d := fun hx => haL ⟨x, hx, rfl⟩
      rcases not_and_or.1 hxnot with hlow | hhigh
      · exfalso
        have hx : x < -M := by
          have : ¬ (-d ≤ x) := hlow
          push_neg at this
          linarith
        exact (Set.disjoint_left.1 hUV haU) (hrayV x hx)
      · have hx : d < x := by push_neg at hhigh; exact hhigh
        exact Or.inr ⟨x, lt_of_le_of_lt hdb hx, rfl⟩
  | pinf => exact Or.inl rfl
  | ninf => exact absurd haU (Set.disjoint_left.1 hUV.symm hnV)
  | null => exact absurd haU hnullU

/-- The sets `{ninf} ∪ fin '' (Iio b)` are a neighbourhood basis at `ninf`:
this is exactly the neighbourhood filter of `⊥` in `EReal`. -/
theorem exists_nhd_ninf (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0))
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0)) (b : ℝ) :
    ∃ W : Set Transreal, IsOpen[t] W ∧ ninf ∈ W ∧ W ⊆ insert ninf (fin '' Iio b) := by
  letI := t
  haveI := h.t2Space
  have hcont : Continuous (fin : ℝ → Transreal) := h.isOpenEmbedding_fin.continuous
  obtain ⟨M, U, V, hU, hV, hpU, hnV, hUV, hnullU, hnullV, hrayU, hrayV⟩ :=
    exists_rays h hp hn
  set d : ℝ := max (-b) M with hd
  have hdb : -b ≤ d := le_max_left _ _
  have hdM : M ≤ d := le_max_right _ _
  have hL : IsClosed (fin '' Icc (-d) d) := (isCompact_Icc.image hcont).isClosed
  refine ⟨V \ fin '' Icc (-d) d, hV.sdiff hL, ⟨hnV, by rintro ⟨x, -, hx⟩; cases hx⟩, ?_⟩
  rintro a ⟨haV, haL⟩
  cases a with
  | fin x =>
      have hxnot : x ∉ Icc (-d) d := fun hx => haL ⟨x, hx, rfl⟩
      rcases not_and_or.1 hxnot with hlow | hhigh
      · have hx : x < -d := by push_neg at hlow; exact hlow
        refine Or.inr ⟨x, ?_, rfl⟩
        have : -d ≤ b := by linarith
        exact lt_of_lt_of_le hx this
      · exfalso
        have hx : M < x := by
          push_neg at hhigh
          linarith
        exact (Set.disjoint_left.1 hUV (hrayU x hx)) haV
  | pinf => exact absurd haV (Set.disjoint_left.1 hUV hpU)
  | ninf => exact Or.inl rfl
  | null => exact absurd haV hnullV


/-! ### The uniqueness theorem -/

/-- Every natural-topology open set is `t`-open.  This is the comparison half of
the uniqueness theorem: it is proved by exhibiting, at each of the four kinds of
point, a `t`-neighbourhood inside the given natural-topology open set — the
finite points by the open-embedding axiom, nullity by the isolation axiom, and
the two infinities by the ray bases `exists_nhd_pinf`, `exists_nhd_ninf`
produced by the ends argument. -/
theorem le_of_isCompactification (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0))
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0)) :
    t ≤ instTopologicalSpace := by
  letI := t
  have hcts : @Continuous Transreal Transreal t instTopologicalSpace id := by
    rw [continuous_def]
    intro s hs
    have hmain : ∀ a ∈ s, ∃ W : Set Transreal, IsOpen[t] W ∧ a ∈ W ∧ W ⊆ s := by
      intro a ha
      cases a with
      | fin x =>
          refine ⟨fin '' (fin ⁻¹' s), h.isOpenEmbedding_fin.isOpenMap _
            (isOpen_preimage_fin_of_isOpen hs), ⟨x, ha, rfl⟩, ?_⟩
          rintro _ ⟨y, hy, rfl⟩
          exact hy
      | null => exact ⟨{null}, h.isOpen_null, rfl, by rintro _ rfl; exact ha⟩
      | pinf =>
          obtain ⟨b, hb⟩ := exists_ray_subset_of_isOpen_pinf hs ha
          obtain ⟨W, hW, hpW, hWsub⟩ := exists_nhd_pinf h hp hn b
          exact ⟨W, hW, hpW, hWsub.trans hb⟩
      | ninf =>
          obtain ⟨b, hb⟩ := exists_ray_subset_of_isOpen_ninf hs ha
          obtain ⟨W, hW, hnW, hWsub⟩ := exists_nhd_ninf h hp hn b
          exact ⟨W, hW, hnW, hWsub.trans hb⟩
    have : IsOpen[t] s := by
      rw [isOpen_iff_mem_nhds]
      intro a ha
      obtain ⟨W, hW, haW, hWs⟩ := hmain a ha
      exact Filter.mem_of_superset (hW.mem_nhds haW) hWs
    simpa using this
  exact continuous_id_iff_le.1 hcts

/-- **Uniqueness of the two-point transreal compactification.**  A topology on
the four-constructor carrier is the natural one (`EReal ⊔ {Φ}`) as soon as it is
compact Hausdorff, makes the finite fragment an open copy of the line, isolates
nullity, and orients the two infinities as the two ends of the line.

The two orientation hypotheses are not removable: `Novelty.TransrealExoticTopology`
exhibits a compact Hausdorff topology satisfying all the other requirements yet
differing from the natural one. -/
theorem topology_eq_of_isCompactification (h : IsCompactification t)
    (hp : pinf ∈ @closure Transreal t (fin '' Ioi 0))
    (hn : ninf ∈ @closure Transreal t (fin '' Iio 0)) :
    t = instTopologicalSpace := by
  have hle : t ≤ instTopologicalSpace := le_of_isCompactification h hp hn
  refine le_antisymm hle ?_
  -- The reverse inequality: a compact topology finer than a Hausdorff one is equal
  -- to it, because the identity is then a closed map.
  have hcts : @Continuous Transreal Transreal t instTopologicalSpace id :=
    continuous_id_iff_le.2 hle
  rw [TopologicalSpace.le_def]
  intro s hs
  have hclosed : @IsClosed Transreal t sᶜ := @isClosed_compl_iff Transreal t s |>.2 hs
  have hcompact : @IsCompact Transreal t sᶜ :=
    @IsClosed.isCompact Transreal t sᶜ h.compactSpace hclosed
  have himg : @IsCompact Transreal instTopologicalSpace sᶜ := by
    have h2 := @IsCompact.image Transreal Transreal t instTopologicalSpace sᶜ id hcompact hcts
    simpa using h2
  have hcl : @IsClosed Transreal instTopologicalSpace sᶜ :=
    @IsCompact.isClosed Transreal instTopologicalSpace instT2Space sᶜ himg
  simpa using hcl.isOpen_compl

/-- The characterisation in biconditional form: the natural topology is *exactly*
the compact Hausdorff topology in which the line sits openly, nullity is isolated,
and the infinities are the two ends. -/
theorem topology_eq_iff :
    t = instTopologicalSpace ↔
      IsCompactification t ∧ pinf ∈ @closure Transreal t (fin '' Ioi 0) ∧
        ninf ∈ @closure Transreal t (fin '' Iio 0) := by
  constructor
  · rintro rfl
    exact ⟨isCompactification_instTopologicalSpace, pinf_mem_closure, ninf_mem_closure⟩
  · rintro ⟨h, hp, hn⟩
    exact topology_eq_of_isCompactification h hp hn

end Ends

end Transreal