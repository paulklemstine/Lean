/-
Copyright (c) 2025 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Novelty.TransrealEndCompactification

/-!
# Exotic compact Hausdorff topologies on the transreal carrier

`Novelty.TransrealEndCompactification` proves that the natural topology
`EReal ⊔ {Φ}` on the four-constructor carrier is the *unique* compact Hausdorff
topology in which the finite fragment is an open copy of the line, nullity is
isolated, **and** the two infinities are the two ends of the line.

This file shows that the last clause cannot be dropped, by constructing two
genuinely different models, and then examines what the sharpness theorems of
`Cryptography.Transreal.Topology` become in the exotic model.

## The circle model

`Transreal.exoticTopology` is the topology induced by the bijection

```
fin x ↦ inl (x : OnePoint ℝ)   ninf ↦ inl ∞   pinf ↦ inr true   null ↦ inr false
```

i.e. the line is compactified by the **single** point `ninf` into a circle, and
both `pinf` and `null` are isolated points sitting beside it.  This is compact
Hausdorff, the finite fragment is an open copy of the line, and nullity is
isolated — so it satisfies every axiom of the uniqueness conjecture as literally
stated (`Transreal.isCompactification_exoticTopology`) — yet it is *not* the
natural topology (`Transreal.exoticTopology_ne`).

The conjecture is therefore **false as stated**, and the ends hypotheses in
`Transreal.topology_eq_of_isCompactification` are exactly what repairs it.

## What happens to the guard in the circle model

The two sharpness theorems of `Cryptography.Transreal.Topology` behave very
differently under a change of model:

* `Transreal.exotic_selfDiv_not_continuous`: unguarded self-division
  `x ↦ x / x` is still discontinuous.  This was already known to be
  **topology-canonical** (`Transreal.selfDiv_not_continuous_of_t1` holds for
  every T₁ topology), and the circle model confirms it.
* `Transreal.exotic_continuousAt_recipAt_ninf`: the reciprocal `y ↦ 1/y`,
  repaired at the origin by the value `ninf`, **is continuous** in the circle
  model.  So `Transreal.no_continuous_repair` — "no value repairs unguarded
  division" — is *model-dependent*: it is a theorem about the ends structure of
  the natural topology, not about the four-constructor carrier as such.
* `Transreal.exotic_repair_unique`: in the circle model the repairing value is
  unique, namely `ninf`; the exotic model repairs the reciprocal in exactly one
  way.

## The flip model

Even adding the density requirement (no exceptional point other than nullity is
isolated) does not restore uniqueness: `Transreal.flipTopology`, the natural
topology read through the involution exchanging `pinf` and `ninf`, is a compact
Hausdorff transreal compactification with **no** isolated exceptional points,
in which both infinities are ends, and which still differs from the natural
topology (`Transreal.flipTopology_ne`).  Uniqueness holds only after the two
ends are *oriented*, which is what the main theorem assumes.
-/

namespace Transreal

open Set Topology Filter

/-! ### The circle model -/

/-- The exotic bijection: the line together with `ninf` is a circle
(the one-point compactification of `ℝ`), while `pinf` and `null` are two extra
isolated points. -/
def toCircle : Transreal → OnePoint ℝ ⊕ Bool
  | fin x => Sum.inl (x : OnePoint ℝ)
  | ninf => Sum.inl OnePoint.infty
  | pinf => Sum.inr true
  | null => Sum.inr false

@[simp] theorem toCircle_fin (x : ℝ) : toCircle (fin x) = Sum.inl (x : OnePoint ℝ) := rfl
@[simp] theorem toCircle_ninf : toCircle ninf = Sum.inl OnePoint.infty := rfl
@[simp] theorem toCircle_pinf : toCircle pinf = Sum.inr true := rfl
@[simp] theorem toCircle_null : toCircle null = Sum.inr false := rfl

theorem toCircle_injective : Function.Injective toCircle := by
  intro a b h
  cases a <;> cases b <;> simp_all

theorem toCircle_surjective : Function.Surjective toCircle := by
  rintro (u | b)
  · induction u using OnePoint.rec with
    | infty => exact ⟨ninf, rfl⟩
    | coe a => exact ⟨fin a, rfl⟩
  · cases b
    · exact ⟨null, rfl⟩
    · exact ⟨pinf, rfl⟩

/-- **The circle topology.**  The line is compactified by the single point
`ninf`; `pinf` and `null` are isolated. -/
def exoticTopology : TopologicalSpace Transreal :=
  TopologicalSpace.induced toCircle inferInstance

section Circle

attribute [local instance] exoticTopology

theorem isEmbedding_toCircle :
    @IsEmbedding Transreal (OnePoint ℝ ⊕ Bool) exoticTopology _ toCircle :=
  ⟨⟨rfl⟩, toCircle_injective⟩

theorem isOpenEmbedding_toCircle :
    @IsOpenEmbedding Transreal (OnePoint ℝ ⊕ Bool) exoticTopology _ toCircle :=
  ⟨isEmbedding_toCircle, by rw [toCircle_surjective.range_eq]; exact isOpen_univ⟩

theorem isClosedEmbedding_toCircle :
    @IsClosedEmbedding Transreal (OnePoint ℝ ⊕ Bool) exoticTopology _ toCircle :=
  ⟨isEmbedding_toCircle, by rw [toCircle_surjective.range_eq]; exact isClosed_univ⟩

theorem exotic_compactSpace : @CompactSpace Transreal exoticTopology :=
  isClosedEmbedding_toCircle.compactSpace

theorem exotic_t2Space : @T2Space Transreal exoticTopology :=
  isEmbedding_toCircle.t2Space

theorem exotic_isOpenEmbedding_fin :
    @IsOpenEmbedding ℝ Transreal _ exoticTopology fin := by
  refine @IsOpenEmbedding.of_comp ℝ Transreal (OnePoint ℝ ⊕ Bool) toCircle _ exoticTopology _
    fin isOpenEmbedding_toCircle ?_
  have h : toCircle ∘ (fin : ℝ → Transreal) = Sum.inl ∘ (OnePoint.some : ℝ → OnePoint ℝ) := rfl
  rw [h]
  exact IsOpenEmbedding.inl.comp OnePoint.isOpenEmbedding_coe

theorem exotic_isOpen_null : IsOpen[exoticTopology] ({null} : Set Transreal) := by
  refine isOpen_induced_iff.2 ⟨Sum.inr '' {false}, isOpenMap_inr _ (isOpen_discrete _), ?_⟩
  ext a
  cases a <;> simp

/-- In the circle model, `pinf` is an **isolated** point.  This is what makes the
model exotic: `pinf` is no longer an end of the line. -/
theorem exotic_isOpen_pinf : IsOpen[exoticTopology] ({pinf} : Set Transreal) := by
  refine isOpen_induced_iff.2 ⟨Sum.inr '' {true}, isOpenMap_inr _ (isOpen_discrete _), ?_⟩
  ext a
  cases a <;> simp

/-- The circle model satisfies every axiom of the uniqueness conjecture. -/
theorem isCompactification_exoticTopology : IsCompactification exoticTopology where
  compactSpace := exotic_compactSpace
  t2Space := exotic_t2Space
  isOpenEmbedding_fin := exotic_isOpenEmbedding_fin
  isOpen_null := exotic_isOpen_null

/-- …but it is not the natural topology. -/
theorem exoticTopology_ne : exoticTopology ≠ instTopologicalSpace := by
  intro h
  exact not_isOpen_singleton_pinf (h ▸ exotic_isOpen_pinf)

/-- **The conjecture, as literally stated, is false.**  Compactness, the
Hausdorff property, openness of the finite fragment and isolation of nullity do
not determine the topology of the four-constructor carrier. -/
theorem exists_isCompactification_ne :
    ∃ t : TopologicalSpace Transreal, IsCompactification t ∧ t ≠ instTopologicalSpace :=
  ⟨exoticTopology, isCompactification_exoticTopology, exoticTopology_ne⟩

/-! ### Which hypothesis of the uniqueness theorem fails in the circle model -/

/-- In the circle model `pinf` is not a limit of positive finite values: the
first orientation hypothesis fails. -/
theorem exotic_pinf_notMem_closure :
    pinf ∉ @closure Transreal exoticTopology (fin '' Ioi (0 : ℝ)) := by
  intro hmem
  obtain ⟨y, hy1, hy2⟩ :=
    (@mem_closure_iff Transreal exoticTopology _ _).1 hmem {pinf} exotic_isOpen_pinf rfl
  obtain ⟨x, -, rfl⟩ := hy2
  cases hy1

/-- In the circle model `ninf` is the limit of the finite values in **both**
directions: it is the single point compactifying the line into a circle. -/
theorem exotic_tendsto_fin_atTop :
    @Tendsto ℝ Transreal (fun x : ℝ => fin x) atTop (@nhds Transreal exoticTopology ninf) := by
  rw [isEmbedding_toCircle.tendsto_nhds_iff]
  have h1 : Tendsto (fun x : ℝ => (x : OnePoint ℝ)) atTop (𝓝 (OnePoint.infty)) := by
    refine OnePoint.tendsto_coe_infty.mono_left ?_
    rw [Filter.coclosedCompact_eq_cocompact, cocompact_eq_atBot_atTop]
    exact le_sup_right
  exact (continuous_inl.tendsto _).comp h1

theorem exotic_tendsto_fin_atBot :
    @Tendsto ℝ Transreal (fun x : ℝ => fin x) atBot (@nhds Transreal exoticTopology ninf) := by
  rw [isEmbedding_toCircle.tendsto_nhds_iff]
  have h1 : Tendsto (fun x : ℝ => (x : OnePoint ℝ)) atBot (𝓝 (OnePoint.infty)) := by
    refine OnePoint.tendsto_coe_infty.mono_left ?_
    rw [Filter.coclosedCompact_eq_cocompact, cocompact_eq_atBot_atTop]
    exact le_sup_left
  exact (continuous_inl.tendsto _).comp h1

/-- Both ends of the line converge to `ninf` in the circle model. -/
theorem exotic_ninf_mem_closure_pos :
    ninf ∈ @closure Transreal exoticTopology (fin '' Ioi (0 : ℝ)) := by
  refine @mem_closure_of_tendsto Transreal exoticTopology ℝ _ _ _ atTop _
    exotic_tendsto_fin_atTop ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
  exact ⟨x, hx, rfl⟩

theorem exotic_ninf_mem_closure_neg :
    ninf ∈ @closure Transreal exoticTopology (fin '' Iio (0 : ℝ)) := by
  refine @mem_closure_of_tendsto Transreal exoticTopology ℝ _ _ _ atBot _
    exotic_tendsto_fin_atBot ?_
  filter_upwards [eventually_lt_atBot (0 : ℝ)] with x hx
  exact ⟨x, hx, rfl⟩

/-! ### The guard, re-examined in the circle model -/

/-- The reciprocal of the line, valued in the one-point compactification: the
map that sends `0` to the point at infinity. -/
noncomputable def circleRecip (y : ℝ) : OnePoint ℝ :=
  if y = 0 then OnePoint.infty else ((y⁻¹ : ℝ) : OnePoint ℝ)

/-- The reciprocal is continuous into the circle: this is the classical fact
that `1/y → ∞` as `y → 0` from **either** side, once the two ends of the line
have been glued. -/
theorem continuous_circleRecip : Continuous circleRecip := by
  rw [continuous_iff_continuousAt]
  intro y
  rcases eq_or_ne y 0 with rfl | hy
  · have h1 : Tendsto (fun x : ℝ => x⁻¹) (𝓝[≠] (0 : ℝ)) (Filter.cocompact ℝ) := by
      rw [cocompact_eq_atBot_atTop, ← nhdsLT_sup_nhdsGT]
      exact Filter.Tendsto.sup_sup tendsto_inv_nhdsLT_zero tendsto_inv_nhdsGT_zero
    have h2 : Tendsto (fun x : ℝ => ((x⁻¹ : ℝ) : OnePoint ℝ)) (𝓝[≠] (0 : ℝ))
        (𝓝 (OnePoint.infty)) := by
      have h := OnePoint.tendsto_coe_infty (X := ℝ)
      rw [Filter.coclosedCompact_eq_cocompact] at h
      exact h.comp h1
    have h3 : Tendsto circleRecip (𝓝[≠] (0 : ℝ)) (𝓝 (OnePoint.infty)) := by
      refine h2.congr' ?_
      filter_upwards [self_mem_nhdsWithin] with x hx
      simp [circleRecip, show x ≠ 0 from hx]
    have h4 : Tendsto circleRecip (pure (0 : ℝ)) (𝓝 (OnePoint.infty)) := by
      have h := tendsto_pure_nhds circleRecip (0 : ℝ)
      simpa [circleRecip] using h
    have h0 : circleRecip 0 = OnePoint.infty := by simp [circleRecip]
    rw [ContinuousAt, h0, ← nhdsNE_sup_pure (0 : ℝ), Filter.tendsto_sup]
    exact ⟨h3, h4⟩
  · have hcont : ContinuousAt (fun x : ℝ => ((x⁻¹ : ℝ) : OnePoint ℝ)) y :=
      OnePoint.continuous_coe.continuousAt.comp (continuousAt_inv₀ hy)
    refine hcont.congr ?_
    filter_upwards [isOpen_compl_singleton.mem_nhds hy] with x hx
    simp [circleRecip, show x ≠ 0 from hx]

/-- **The guard is repairable in the circle model.**  The reciprocal
`y ↦ 1 / y`, given the value `ninf` at the origin, is a *continuous* map
`ℝ → Transreal` for the exotic compact Hausdorff topology.  Contrast
`Transreal.no_continuous_repair'`, which shows that in the natural topology no
value whatsoever repairs it. -/
theorem exotic_continuous_recipAt_ninf :
    @Continuous ℝ Transreal _ exoticTopology (recipAt ninf) := by
  rw [continuous_induced_rng]
  have h : toCircle ∘ (recipAt ninf) = Sum.inl ∘ circleRecip := by
    funext y
    by_cases hy : y = 0 <;> simp [recipAt, circleRecip, hy, Function.comp]
  rw [h]
  exact continuous_inl.comp continuous_circleRecip

theorem exotic_continuousAt_recipAt_ninf :
    @ContinuousAt ℝ Transreal _ exoticTopology (recipAt ninf) 0 :=
  exotic_continuous_recipAt_ninf.continuousAt

/-- **Non-repairability of unguarded division is model-dependent.**  The theorem
`Transreal.no_continuous_repair` — for every value `v`, the reciprocal repaired
by `v` is discontinuous at the origin — is *false* in the exotic compact
Hausdorff model. -/
theorem exotic_not_no_continuous_repair :
    ¬ ∀ v : Transreal, ¬ @ContinuousAt ℝ Transreal _ exoticTopology (recipAt v) 0 :=
  fun h => h ninf exotic_continuousAt_recipAt_ninf

/-- In the circle model the repairing value is unique: only `ninf` works. -/
theorem exotic_repair_unique {v : Transreal}
    (hv : @ContinuousAt ℝ Transreal _ exoticTopology (recipAt v) 0) : v = ninf := by
  letI := exoticTopology
  haveI := exotic_t2Space
  have heq : (recipAt v) =ᶠ[𝓝[≠] (0 : ℝ)] (recipAt ninf) := by
    filter_upwards [self_mem_nhdsWithin] with x hx
    rw [recipAt_of_ne (show x ≠ 0 from hx), recipAt_of_ne (show x ≠ 0 from hx)]
  have h1 : Tendsto (recipAt v) (𝓝[≠] (0 : ℝ)) (𝓝 v) := by
    have := hv.tendsto
    rw [recipAt_zero] at this
    exact this.mono_left nhdsWithin_le_nhds
  have h2 : Tendsto (recipAt v) (𝓝[≠] (0 : ℝ)) (𝓝 ninf) := by
    have := exotic_continuousAt_recipAt_ninf.tendsto
    rw [recipAt_zero] at this
    exact (this.mono_left nhdsWithin_le_nhds).congr' heq.symm
  exact tendsto_nhds_unique h1 h2

/-- **The self-division obstruction survives.**  In the circle model, as in every
T₁ model, `x ↦ x / x` is discontinuous: this sharpness statement is
topology-canonical, unlike the reciprocal one. -/
theorem exotic_selfDiv_not_continuous :
    ¬ @Continuous ℝ Transreal _ exoticTopology (fun x : ℝ => fin x / fin x) :=
  selfDiv_not_continuous_of_t1 exoticTopology (@T2Space.t1Space _ exoticTopology exotic_t2Space)

end Circle

/-! ### The flip model: orientation really is needed -/

/-- The involution of the carrier exchanging the two infinities and fixing
everything else.  It is a bijection but **not** a homeomorphism of the natural
topology. -/
def flipInf : Transreal → Transreal
  | pinf => ninf
  | ninf => pinf
  | fin x => fin x
  | null => null

@[simp] theorem flipInf_fin (x : ℝ) : flipInf (fin x) = fin x := rfl
@[simp] theorem flipInf_pinf : flipInf pinf = ninf := rfl
@[simp] theorem flipInf_ninf : flipInf ninf = pinf := rfl
@[simp] theorem flipInf_null : flipInf null = null := rfl

theorem flipInf_involutive : Function.Involutive flipInf := by
  intro a; cases a <;> rfl

theorem flipInf_injective : Function.Injective flipInf := flipInf_involutive.injective

theorem flipInf_surjective : Function.Surjective flipInf := flipInf_involutive.surjective

/-- The natural topology read through the flip. -/
def flipTopology : TopologicalSpace Transreal :=
  TopologicalSpace.induced flipInf instTopologicalSpace

section Flip

theorem isInducing_flipInf :
    @IsInducing Transreal Transreal flipTopology instTopologicalSpace flipInf :=
  @IsInducing.mk Transreal Transreal flipTopology instTopologicalSpace flipInf rfl

theorem isEmbedding_flipInf :
    @IsEmbedding Transreal Transreal flipTopology instTopologicalSpace flipInf :=
  @IsEmbedding.mk Transreal Transreal flipTopology instTopologicalSpace flipInf
    isInducing_flipInf flipInf_injective

theorem isOpenEmbedding_flipInf :
    @IsOpenEmbedding Transreal Transreal flipTopology instTopologicalSpace flipInf :=
  @IsOpenEmbedding.mk Transreal Transreal flipTopology instTopologicalSpace flipInf
    isEmbedding_flipInf (by rw [flipInf_surjective.range_eq]; exact isOpen_univ)

theorem flip_isOpenMap : @IsOpenMap Transreal Transreal flipTopology instTopologicalSpace flipInf :=
  @IsOpenEmbedding.isOpenMap Transreal Transreal flipInf flipTopology instTopologicalSpace
    isOpenEmbedding_flipInf

theorem isClosedEmbedding_flipInf :
    @IsClosedEmbedding Transreal Transreal flipTopology instTopologicalSpace flipInf :=
  @IsClosedEmbedding.mk Transreal Transreal flipTopology instTopologicalSpace flipInf
    isEmbedding_flipInf (by rw [flipInf_surjective.range_eq]; exact isClosed_univ)

theorem flip_compactSpace : @CompactSpace Transreal flipTopology :=
  @IsClosedEmbedding.compactSpace Transreal Transreal flipTopology instTopologicalSpace
    instCompactSpace flipInf isClosedEmbedding_flipInf

theorem flip_t2Space : @T2Space Transreal flipTopology :=
  @IsEmbedding.t2Space Transreal Transreal flipTopology instTopologicalSpace instT2Space flipInf
    isEmbedding_flipInf

theorem flip_isOpenEmbedding_fin : @IsOpenEmbedding ℝ Transreal _ flipTopology fin := by
  refine @IsOpenEmbedding.of_comp ℝ Transreal Transreal flipInf _ flipTopology instTopologicalSpace
    fin isOpenEmbedding_flipInf ?_
  have h : flipInf ∘ (fin : ℝ → Transreal) = fin := rfl
  rw [h]
  exact isOpenEmbedding_fin

theorem flip_isOpen_null : IsOpen[flipTopology] ({null} : Set Transreal) := by
  refine isOpen_induced_iff.2 ⟨{null}, isOpen_singleton_null, ?_⟩
  ext a
  cases a <;> simp

/-- The flip model is a transreal compactification. -/
theorem isCompactification_flipTopology : IsCompactification flipTopology where
  compactSpace := flip_compactSpace
  t2Space := flip_t2Space
  isOpenEmbedding_fin := flip_isOpenEmbedding_fin
  isOpen_null := flip_isOpen_null

/-- In the flip model `pinf` is the **negative** end of the line. -/
theorem flip_pinf_mem_closure_neg :
    pinf ∈ @closure Transreal flipTopology (fin '' Iio (0 : ℝ)) := by
  have htend : @Tendsto ℝ Transreal (fun x : ℝ => fin x) atBot
      (@nhds Transreal flipTopology pinf) := by
    rw [@IsEmbedding.tendsto_nhds_iff Transreal Transreal ℝ flipInf flipTopology
      instTopologicalSpace (fun x : ℝ => fin x) atBot pinf isEmbedding_flipInf]
    exact tendsto_fin_atBot
  refine @mem_closure_of_tendsto Transreal flipTopology ℝ _ _ _ atBot _ htend ?_
  filter_upwards [eventually_lt_atBot (0 : ℝ)] with x hx
  exact ⟨x, hx, rfl⟩

/-- In the natural topology `pinf` is *not* a limit of negative finite values. -/
theorem pinf_notMem_closure_neg :
    pinf ∉ @closure Transreal instTopologicalSpace (fin '' Iio (0 : ℝ)) := by
  intro hmem
  obtain ⟨y, hy1, hy2⟩ :=
    (@mem_closure_iff Transreal instTopologicalSpace _ _).1 hmem (finiteSide (Ioi (0 : EReal)))
      (isOpen_finiteSide isOpen_Ioi) (by simp)
  obtain ⟨x, hx, rfl⟩ := hy2
  rw [fin_mem_finiteSide, Set.mem_Ioi, show (0 : EReal) = ((0 : ℝ) : EReal) by simp,
    EReal.coe_lt_coe_iff] at hy1
  exact absurd hx (not_lt.2 hy1.le)

/-- The flip model differs from the natural topology, although *both* infinities
are ends in it: orientation, not merely density, is what the uniqueness theorem
needs. -/
theorem flipTopology_ne : flipTopology ≠ instTopologicalSpace := by
  intro h
  exact pinf_notMem_closure_neg (h ▸ flip_pinf_mem_closure_neg)

/-- In the flip model no exceptional point other than nullity is isolated: the
naive "density" repair of the conjecture still fails. -/
theorem flip_not_isOpen_pinf : ¬ IsOpen[flipTopology] ({pinf} : Set Transreal) := by
  intro hopen
  have h : IsOpen (flipInf '' {pinf}) := flip_isOpenMap _ hopen
  rw [Set.image_singleton, flipInf_pinf] at h
  exact not_isOpen_singleton_ninf h

theorem flip_not_isOpen_ninf : ¬ IsOpen[flipTopology] ({ninf} : Set Transreal) := by
  intro hopen
  have h : IsOpen (flipInf '' {ninf}) := flip_isOpenMap _ hopen
  rw [Set.image_singleton, flipInf_ninf] at h
  exact not_isOpen_singleton_pinf h

/-- **Summary of sharpness.**  There are at least two distinct transreal
compactifications besides the natural one: the circle model, in which `pinf` is
isolated, and the flip model, in which no exceptional point but nullity is
isolated.  Hence neither the bare axioms nor the axioms plus density determine
the topology; the ends orientation in
`Transreal.topology_eq_of_isCompactification` is indispensable. -/
theorem sharpness_of_uniqueness :
    (∃ t : TopologicalSpace Transreal, IsCompactification t ∧ t ≠ instTopologicalSpace) ∧
      (∃ t : TopologicalSpace Transreal, IsCompactification t ∧ t ≠ instTopologicalSpace ∧
        ¬ IsOpen[t] ({pinf} : Set Transreal) ∧ ¬ IsOpen[t] ({ninf} : Set Transreal)) :=
  ⟨exists_isCompactification_ne,
    ⟨flipTopology, isCompactification_flipTopology, flipTopology_ne,
      flip_not_isOpen_pinf, flip_not_isOpen_ninf⟩⟩

end Flip

end Transreal