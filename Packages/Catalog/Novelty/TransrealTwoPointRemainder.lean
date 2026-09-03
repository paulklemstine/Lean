/-
Copyright (c) 2025 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Novelty.TransrealExoticTopology

/-!
# Classification of two-point-remainder transreal compactifications

`Novelty.TransrealEndCompactification` shows that a transreal compactification
whose infinities are *oriented* ends is the natural topology, and
`Novelty.TransrealExoticTopology` shows that without orientation there are other
models.  This file closes the gap by classifying **all** transreal
compactifications in which no exceptional point other than nullity is isolated:
there are exactly two, the natural topology and its flip.

## Main result

`Transreal.classification_of_isCompactification`: if `t` is compact Hausdorff,
`fin` is a `t`-open embedding, `{null}` is `t`-open, and neither `{pinf}` nor
`{ninf}` is `t`-open, then

```
t = Transreal.instTopologicalSpace  ∨  t = Transreal.flipTopology
```

This is the promised statement that a two-point-remainder compactification of
the (two-ended, locally compact) line is the **end compactification**, up to the
one ambiguity that cannot be removed, namely which end is called `+∞`.

## Method

* `Transreal.mem_closure_range_fin_of_not_isOpen`: a non-isolated remainder point
  is a limit of finite values — this converts "no extra isolated points" into
  end data.
* `Transreal.orientation_or_flip`: the unoriented ends argument
  (`Transreal.exists_rays_aux`) then forces the two infinities to take the two
  ends of the line, in one of the two possible orders.
* `Transreal.isCompactification_flipInduced` and
  `Transreal.mem_closure_flipInduced_iff`: transport along the flip involution
  converts the second order into the first, so the uniqueness theorem applies in
  both cases.
-/

namespace Transreal

open Set Topology Filter

variable {t : TopologicalSpace Transreal}

/-! ### Non-isolated remainder points are ends -/

/-- A remainder point that is **not isolated** is a limit of finite values.  In a
two-point remainder there is nowhere else for it to be a limit of. -/
theorem mem_closure_range_fin_of_not_isOpen (h : IsCompactification t)
    (hp : ¬ IsOpen[t] ({pinf} : Set Transreal)) :
    pinf ∈ @closure Transreal t (range fin) := by
  letI := t
  haveI := h.t2Space
  by_contra hcon
  have hopen : IsOpen ((closure (range fin))ᶜ) := isClosed_closure.isOpen_compl
  have hclosed : IsClosed ({ninf, null} : Set Transreal) :=
    (isClosed_singleton (x := ninf)).union (isClosed_singleton (x := null))
  have hW : IsOpen ((closure (range fin))ᶜ \ {ninf, null}) := hopen.sdiff hclosed
  have hmem : pinf ∈ (closure (range fin))ᶜ \ {ninf, null} := by
    refine ⟨hcon, ?_⟩
    rintro (h1 | h1) <;> cases h1
  have hsub : (closure (range fin))ᶜ \ {ninf, null} = {pinf} := by
    apply Set.Subset.antisymm
    · rintro a ⟨ha1, ha2⟩
      cases a with
      | fin x => exact absurd (subset_closure (Set.mem_range_self x)) ha1
      | pinf => rfl
      | ninf => exact absurd (Or.inl rfl) ha2
      | null => exact absurd (Or.inr rfl) ha2
    · rintro a rfl
      exact hmem
  rw [hsub] at hW
  exact hp hW

/-- The same statement for `ninf`. -/
theorem ninf_mem_closure_range_fin_of_not_isOpen (h : IsCompactification t)
    (hn : ¬ IsOpen[t] ({ninf} : Set Transreal)) :
    ninf ∈ @closure Transreal t (range fin) := by
  letI := t
  haveI := h.t2Space
  by_contra hcon
  have hopen : IsOpen ((closure (range fin))ᶜ) := isClosed_closure.isOpen_compl
  have hclosed : IsClosed ({pinf, null} : Set Transreal) :=
    (isClosed_singleton (x := pinf)).union (isClosed_singleton (x := null))
  have hW : IsOpen ((closure (range fin))ᶜ \ {pinf, null}) := hopen.sdiff hclosed
  have hmem : ninf ∈ (closure (range fin))ᶜ \ {pinf, null} := by
    refine ⟨hcon, ?_⟩
    rintro (h1 | h1) <;> cases h1
  have hsub : (closure (range fin))ᶜ \ {pinf, null} = {ninf} := by
    apply Set.Subset.antisymm
    · rintro a ⟨ha1, ha2⟩
      cases a with
      | fin x => exact absurd (subset_closure (Set.mem_range_self x)) ha1
      | pinf => exact absurd (Or.inl rfl) ha2
      | ninf => rfl
      | null => exact absurd (Or.inr rfl) ha2
    · rintro a rfl
      exact hmem
  rw [hsub] at hW
  exact hn hW

/-- Being a limit of finite values upgrades, in a compact Hausdorff model, to
being a limit of finite values of arbitrarily large modulus: the point is an
*end*, not an interior limit. -/
theorem far_of_mem_closure_range_fin (h : IsCompactification t) {a : Transreal}
    (ha : a ∈ @closure Transreal t (range fin)) (hafin : a ∉ range fin) :
    ∀ W : Set Transreal, IsOpen[t] W → a ∈ W → ∀ c : ℝ, ∃ x : ℝ, c < |x| ∧ fin x ∈ W := by
  letI := t
  haveI := h.t2Space
  intro W hW haW c
  have hcont : Continuous (fin : ℝ → Transreal) := h.isOpenEmbedding_fin.continuous
  have hL : IsClosed (fin '' Icc (-|c|) |c|) := (isCompact_Icc.image hcont).isClosed
  have hW' : IsOpen (W \ fin '' Icc (-|c|) |c|) := hW.sdiff hL
  have haW' : a ∈ W \ fin '' Icc (-|c|) |c| := by
    refine ⟨haW, ?_⟩
    rintro ⟨x, -, rfl⟩
    exact hafin ⟨x, rfl⟩
  obtain ⟨y, hy1, x, rfl⟩ := mem_closure_iff.1 ha _ hW' haW'
  refine ⟨x, ?_, hy1.1⟩
  have hxnot : x ∉ Icc (-|c|) |c| := fun hx => hy1.2 ⟨x, hx, rfl⟩
  have hc : c ≤ |c| := le_abs_self c
  rcases not_and_or.1 hxnot with hlow | hhigh
  · push_neg at hlow
    have : |c| < -x := by linarith
    have h2 : -x ≤ |x| := neg_le_abs x
    linarith
  · push_neg at hhigh
    have h2 : x ≤ |x| := le_abs_self x
    linarith

/-! ### The two possible orientations -/

/-- **The ends of the line take the two remainder points, in one of two orders.**
If no exceptional point other than nullity is isolated, then either `pinf` is the
positive end and `ninf` the negative one, or the other way round. -/
theorem orientation_or_flip (h : IsCompactification t)
    (hp : ¬ IsOpen[t] ({pinf} : Set Transreal))
    (hn : ¬ IsOpen[t] ({ninf} : Set Transreal)) :
    (pinf ∈ @closure Transreal t (fin '' Ioi 0) ∧
        ninf ∈ @closure Transreal t (fin '' Iio 0)) ∨
      (pinf ∈ @closure Transreal t (fin '' Iio 0) ∧
        ninf ∈ @closure Transreal t (fin '' Ioi 0)) := by
  letI := t
  have hfarP := far_of_mem_closure_range_fin h
    (mem_closure_range_fin_of_not_isOpen h hp) pinf_notMem_range_fin
  have hfarN := far_of_mem_closure_range_fin h
    (ninf_mem_closure_range_fin_of_not_isOpen h hn) ninf_notMem_range_fin
  obtain ⟨M, U, V, hU, hV, hpU, hnV, hUV, -, -, hcase⟩ := exists_rays_aux h hfarP hfarN
  -- In either branch, a neighbourhood of an infinity meets the ray it owns.
  have key : ∀ (A B : Set Transreal) (a : Transreal),
      IsOpen A → a ∈ A → Disjoint A B →
      (∀ W : Set Transreal, IsOpen W → a ∈ W → ∀ c : ℝ, ∃ x : ℝ, c < |x| ∧ fin x ∈ W) →
      (∀ x : ℝ, M < x → fin x ∈ A) → (∀ x : ℝ, x < -M → fin x ∈ B) →
      a ∈ closure (fin '' Ioi (0 : ℝ)) := by
    intro A B a hA haA hAB hfar hrayA hrayB
    refine mem_closure_iff.2 ?_
    intro W hW haW
    obtain ⟨x, hx, hxW⟩ := hfar (W ∩ A) (hW.inter hA) ⟨haW, haA⟩ (max M 0)
    have hM : M ≤ max M 0 := le_max_left _ _
    have h0 : (0 : ℝ) ≤ max M 0 := le_max_right _ _
    rcases lt_abs.1 hx with hpos | hneg
    · exact ⟨fin x, hxW.1, x, by simp only [Set.mem_Ioi]; linarith, rfl⟩
    · exfalso
      have hxlt : x < -M := by linarith
      exact (Set.disjoint_left.1 hAB hxW.2) (hrayB x hxlt)
  have key' : ∀ (A B : Set Transreal) (a : Transreal),
      IsOpen A → a ∈ A → Disjoint A B →
      (∀ W : Set Transreal, IsOpen W → a ∈ W → ∀ c : ℝ, ∃ x : ℝ, c < |x| ∧ fin x ∈ W) →
      (∀ x : ℝ, M < x → fin x ∈ B) → (∀ x : ℝ, x < -M → fin x ∈ A) →
      a ∈ closure (fin '' Iio (0 : ℝ)) := by
    intro A B a hA haA hAB hfar hrayB hrayA
    refine mem_closure_iff.2 ?_
    intro W hW haW
    obtain ⟨x, hx, hxW⟩ := hfar (W ∩ A) (hW.inter hA) ⟨haW, haA⟩ (max M 0)
    have hM : M ≤ max M 0 := le_max_left _ _
    have h0 : (0 : ℝ) ≤ max M 0 := le_max_right _ _
    rcases lt_abs.1 hx with hpos | hneg
    · exfalso
      have hxgt : M < x := by linarith
      exact (Set.disjoint_left.1 hAB hxW.2) (hrayB x hxgt)
    · exact ⟨fin x, hxW.1, x, by simp only [Set.mem_Iio]; linarith, rfl⟩
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨key U V pinf hU hpU hUV hfarP h1 h2,
      key' V U ninf hV hnV hUV.symm hfarN h1 h2⟩
  · exact Or.inr ⟨key' U V pinf hU hpU hUV hfarP h1 h2,
      key V U ninf hV hnV hUV.symm hfarN h1 h2⟩

/-! ### Transport along the flip -/

/-- The flip of a topology on the carrier. -/
def flipInduced (t : TopologicalSpace Transreal) : TopologicalSpace Transreal :=
  TopologicalSpace.induced flipInf t

theorem flipInduced_flipInduced (t : TopologicalSpace Transreal) :
    flipInduced (flipInduced t) = t := by
  have h : flipInf ∘ flipInf = id := funext fun a => flipInf_involutive a
  rw [flipInduced, flipInduced, induced_compose, h, induced_id]

theorem flipInduced_instTopologicalSpace : flipInduced instTopologicalSpace = flipTopology := rfl

theorem isInducing_flipInduced (t : TopologicalSpace Transreal) :
    @IsInducing Transreal Transreal (flipInduced t) t flipInf :=
  @IsInducing.mk Transreal Transreal (flipInduced t) t flipInf rfl

theorem isEmbedding_flipInduced (t : TopologicalSpace Transreal) :
    @IsEmbedding Transreal Transreal (flipInduced t) t flipInf :=
  @IsEmbedding.mk Transreal Transreal (flipInduced t) t flipInf (isInducing_flipInduced t)
    flipInf_injective

theorem isOpenEmbedding_flipInduced (t : TopologicalSpace Transreal) :
    @IsOpenEmbedding Transreal Transreal (flipInduced t) t flipInf :=
  @IsOpenEmbedding.mk Transreal Transreal (flipInduced t) t flipInf (isEmbedding_flipInduced t)
    (by rw [flipInf_surjective.range_eq]; exact isOpen_univ)

theorem isClosedEmbedding_flipInduced (t : TopologicalSpace Transreal) :
    @IsClosedEmbedding Transreal Transreal (flipInduced t) t flipInf :=
  @IsClosedEmbedding.mk Transreal Transreal (flipInduced t) t flipInf (isEmbedding_flipInduced t)
    (by rw [flipInf_surjective.range_eq]; exact isClosed_univ)

/-- The flip of a transreal compactification is a transreal compactification. -/
theorem isCompactification_flipInduced (h : IsCompactification t) :
    IsCompactification (flipInduced t) where
  compactSpace :=
    @IsClosedEmbedding.compactSpace Transreal Transreal (flipInduced t) t h.compactSpace flipInf
      (isClosedEmbedding_flipInduced t)
  t2Space :=
    @IsEmbedding.t2Space Transreal Transreal (flipInduced t) t h.t2Space flipInf
      (isEmbedding_flipInduced t)
  isOpenEmbedding_fin := by
    refine @IsOpenEmbedding.of_comp ℝ Transreal Transreal flipInf _ (flipInduced t) t
      fin (isOpenEmbedding_flipInduced t) ?_
    have hcomp : flipInf ∘ (fin : ℝ → Transreal) = fin := rfl
    rw [hcomp]
    exact h.isOpenEmbedding_fin
  isOpen_null := by
    refine isOpen_induced_iff.2 ⟨{null}, h.isOpen_null, ?_⟩
    ext a
    cases a <;> simp

/-- Closures transport along the flip. -/
theorem mem_closure_flipInduced_iff (t : TopologicalSpace Transreal) (a : Transreal)
    (S : Set Transreal) :
    a ∈ @closure Transreal (flipInduced t) S ↔ flipInf a ∈ @closure Transreal t (flipInf '' S) := by
  rw [@IsInducing.closure_eq_preimage_closure_image Transreal Transreal flipInf t
    (flipInduced t) (isInducing_flipInduced t) S]
  exact Iff.rfl

theorem flipInf_image_fin_image (S : Set ℝ) : flipInf '' (fin '' S) = fin '' S := by
  ext a
  constructor
  · rintro ⟨b, ⟨x, hx, rfl⟩, rfl⟩
    exact ⟨x, hx, rfl⟩
  · rintro ⟨x, hx, rfl⟩
    exact ⟨fin x, ⟨x, hx, rfl⟩, rfl⟩

/-! ### The classification -/

/-- **Classification of two-point-remainder transreal compactifications.**  Let
`t` be a compact Hausdorff topology on the four-constructor carrier for which the
finite fragment is an open copy of the line, nullity is isolated, and neither
infinity is isolated.  Then `t` is the natural topology `EReal ⊔ {Φ}` or its
flip — the same topology with the roles of `+∞` and `-∞` exchanged.

Equivalently: a compactification of the line with two-point remainder in which
both remainder points are limit points is the **end compactification**, the only
residual freedom being which end is labelled `+∞`. -/
theorem classification_of_isCompactification (h : IsCompactification t)
    (hp : ¬ IsOpen[t] ({pinf} : Set Transreal))
    (hn : ¬ IsOpen[t] ({ninf} : Set Transreal)) :
    t = instTopologicalSpace ∨ t = flipTopology := by
  rcases orientation_or_flip h hp hn with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl (topology_eq_of_isCompactification h h1 h2)
  · refine Or.inr ?_
    -- transport the flipped orientation along the flip and apply uniqueness
    have hcomp : IsCompactification (flipInduced t) := isCompactification_flipInduced h
    have hp' : pinf ∈ @closure Transreal (flipInduced t) (fin '' Ioi 0) := by
      rw [mem_closure_flipInduced_iff, flipInf_image_fin_image]
      exact h2
    have hn' : ninf ∈ @closure Transreal (flipInduced t) (fin '' Iio 0) := by
      rw [mem_closure_flipInduced_iff, flipInf_image_fin_image]
      exact h1
    have hstd : flipInduced t = instTopologicalSpace :=
      topology_eq_of_isCompactification hcomp hp' hn'
    calc t = flipInduced (flipInduced t) := (flipInduced_flipInduced t).symm
      _ = flipInduced instTopologicalSpace := by rw [hstd]
      _ = flipTopology := flipInduced_instTopologicalSpace

/-- The classification is sharp: both alternatives occur, and they are distinct. -/
theorem classification_alternatives_distinct :
    (IsCompactification instTopologicalSpace ∧ IsCompactification flipTopology) ∧
      flipTopology ≠ instTopologicalSpace :=
  ⟨⟨isCompactification_instTopologicalSpace, isCompactification_flipTopology⟩, flipTopology_ne⟩

/-- In the natural topology `ninf` is not a limit of positive finite values. -/
theorem ninf_notMem_closure_pos :
    ninf ∉ @closure Transreal instTopologicalSpace (fin '' Ioi (0 : ℝ)) := by
  intro hmem
  obtain ⟨y, hy1, hy2⟩ :=
    (@mem_closure_iff Transreal instTopologicalSpace _ _).1 hmem (finiteSide (Iio (0 : EReal)))
      (isOpen_finiteSide isOpen_Iio) (by simp)
  obtain ⟨x, hx, rfl⟩ := hy2
  rw [fin_mem_finiteSide, Set.mem_Iio, show (0 : EReal) = ((0 : ℝ) : EReal) by simp,
    EReal.coe_lt_coe_iff] at hy1
  have : (0 : ℝ) < x := hx
  linarith

/-- **The oriented uniqueness theorem, restated as a classification.**  Adding
either orientation condition to the hypotheses of
`Transreal.classification_of_isCompactification` selects the natural topology. -/
theorem eq_instTopologicalSpace_of_not_isOpen_of_orientation (h : IsCompactification t)
    (hp : ¬ IsOpen[t] ({pinf} : Set Transreal))
    (hn : ¬ IsOpen[t] ({ninf} : Set Transreal))
    (horient : pinf ∈ @closure Transreal t (fin '' Ioi 0)) :
    t = instTopologicalSpace := by
  rcases classification_of_isCompactification h hp hn with hstd | hflip
  · exact hstd
  · exfalso
    subst hflip
    rw [show flipTopology = flipInduced instTopologicalSpace from rfl,
      mem_closure_flipInduced_iff, flipInf_image_fin_image, flipInf_pinf] at horient
    exact ninf_notMem_closure_pos horient


/-! ### The guard is canonical among end compactifications -/

/-- Composing the repaired reciprocal with the flip repairs it by the flipped
value. -/
theorem flipInf_comp_recipAt (v : Transreal) : flipInf ∘ recipAt v = recipAt (flipInf v) := by
  funext y
  by_cases hy : y = 0
  · simp [Function.comp, recipAt, hy]
  · simp [Function.comp, recipAt, hy]

/-- No value repairs the reciprocal in the flip model either. -/
theorem flip_no_continuous_repair (v : Transreal) :
    ¬ @ContinuousAt ℝ Transreal _ flipTopology (recipAt v) 0 := by
  intro hc
  have h1 : @ContinuousAt ℝ Transreal _ instTopologicalSpace (flipInf ∘ recipAt v) 0 :=
    (@IsInducing.continuousAt_iff ℝ Transreal Transreal (recipAt v) flipInf flipTopology _
      instTopologicalSpace (isInducing_flipInduced instTopologicalSpace) (x := 0)).1 hc
  rw [flipInf_comp_recipAt] at h1
  exact no_continuous_repair (flipInf v) h1

/-- **The guard's necessity is canonical among end compactifications.**  In every
transreal compactification whose two infinities are genuine ends — equivalently,
by `Transreal.classification_of_isCompactification`, in the natural topology and
in its flip — no value at the origin makes the reciprocal continuous.  The
exotic circle model of `Novelty.TransrealExoticTopology` is therefore the *only*
way the guard can be dispensed with, and it pays for it by making one infinity
an isolated point rather than an end. -/
theorem no_continuous_repair_of_classification (h : IsCompactification t)
    (hp : ¬ IsOpen[t] ({pinf} : Set Transreal))
    (hn : ¬ IsOpen[t] ({ninf} : Set Transreal)) (v : Transreal) :
    ¬ @ContinuousAt ℝ Transreal _ t (recipAt v) 0 := by
  rcases classification_of_isCompactification h hp hn with rfl | rfl
  · exact no_continuous_repair v
  · exact flip_no_continuous_repair v

end Transreal