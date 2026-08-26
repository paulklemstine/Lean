import Cryptography.Transreal.Core

/-!
# The natural Hausdorff topology on the four-constructor carrier

The transreal carrier `Transreal = ℝ ⊔ {±∞} ⊔ {Φ}` carries an obvious topology:
the two-point compactification `EReal` of the line, disjointly union with an
isolated point for nullity.  Formally we take the topology induced by the
bijection

```
toSum : Transreal ≃ EReal ⊕ Unit
```

This is the *natural* topology in a precise sense: it is the unique topology for
which `fin : ℝ → Transreal` is an open embedding, the infinities are the two
ends of the line, and nullity — an element that is not a limit of finite values
under any arithmetic law — is isolated.  We show it is compact Hausdorff.

## Main results

* `Transreal.instT2Space`, `Transreal.instCompactSpace`: the carrier is a
  compact Hausdorff space.
* `Transreal.isOpenEmbedding_fin`: the finite fragment is an open copy of `ℝ`.
* `Transreal.continuous_finArith`, `Transreal.continuous_guarded_div`: the
  **guarded transfer principle** for a single division — continuous real
  functions combined by `+`, `*`, composition, and division by a nowhere-zero
  denominator give continuous transreal-valued maps.
* `Transreal.selfDiv_not_continuous_of_t1`: a *topology-independent*
  obstruction.  Unguarded self-division `x ↦ x / x` is discontinuous for
  **every** T₁ topology on the four-constructor carrier; no choice of topology
  can repair it.
* `Transreal.no_continuous_repair`: in the natural topology, the reciprocal
  `y ↦ 1 / y` cannot be made continuous at `0` by assigning *any* value in the
  carrier — the guard is not a technical artefact but a necessity.
-/

namespace Transreal

open Set Topology

/-- The natural bijection onto the two-point compactification of the line with a
disjoint isolated point. -/
def toSum : Transreal → EReal ⊕ Unit
  | fin x => Sum.inl (x : EReal)
  | pinf => Sum.inl ⊤
  | ninf => Sum.inl ⊥
  | null => Sum.inr ()

@[simp] theorem toSum_fin (x : ℝ) : toSum (fin x) = Sum.inl (x : EReal) := rfl
@[simp] theorem toSum_pinf : toSum pinf = Sum.inl ⊤ := rfl
@[simp] theorem toSum_ninf : toSum ninf = Sum.inl ⊥ := rfl
@[simp] theorem toSum_null : toSum null = Sum.inr () := rfl

theorem toSum_injective : Function.Injective toSum := by
  intro a b h
  cases a <;> cases b <;> simp_all

theorem toSum_surjective : Function.Surjective toSum := by
  rintro (u | u)
  · induction u using EReal.rec with
    | bot => exact ⟨ninf, rfl⟩
    | coe a => exact ⟨fin a, rfl⟩
    | top => exact ⟨pinf, rfl⟩
  · exact ⟨null, rfl⟩

/-- The natural topology on the transreal carrier. -/
instance instTopologicalSpace : TopologicalSpace Transreal :=
  TopologicalSpace.induced toSum inferInstance

theorem isEmbedding_toSum : IsEmbedding toSum := ⟨⟨rfl⟩, toSum_injective⟩

theorem continuous_toSum : Continuous toSum := isEmbedding_toSum.continuous

/-- The four-constructor carrier is Hausdorff. -/
instance instT2Space : T2Space Transreal := isEmbedding_toSum.t2Space

theorem isClosedEmbedding_toSum : IsClosedEmbedding toSum :=
  ⟨isEmbedding_toSum, by
    rw [toSum_surjective.range_eq]
    exact isClosed_univ⟩

/-- The four-constructor carrier is compact: it is `[-∞, ∞] ⊔ {Φ}`. -/
instance instCompactSpace : CompactSpace Transreal :=
  isClosedEmbedding_toSum.compactSpace

/-! ### Basic open sets -/

/-- The transreal points sitting over an extended-real set: the finite side of a
basic open set. -/
def finiteSide (U : Set EReal) : Set Transreal := toSum ⁻¹' (Sum.inl '' U)

@[simp] theorem fin_mem_finiteSide {U : Set EReal} {x : ℝ} :
    fin x ∈ finiteSide U ↔ (x : EReal) ∈ U := by
  simp [finiteSide]

@[simp] theorem pinf_mem_finiteSide {U : Set EReal} : pinf ∈ finiteSide U ↔ ⊤ ∈ U := by
  simp [finiteSide]

@[simp] theorem ninf_mem_finiteSide {U : Set EReal} : ninf ∈ finiteSide U ↔ ⊥ ∈ U := by
  simp [finiteSide]

@[simp] theorem null_not_mem_finiteSide {U : Set EReal} : null ∉ finiteSide U := by
  simp [finiteSide]

theorem isOpen_finiteSide {U : Set EReal} (hU : IsOpen U) : IsOpen (finiteSide U) :=
  (isOpenMap_inl U hU).preimage continuous_toSum

/-- Nullity is an isolated point: it is a limit of nothing. -/
theorem isOpen_singleton_null : IsOpen ({null} : Set Transreal) := by
  have h : ({null} : Set Transreal) = toSum ⁻¹' (Sum.inr '' (univ : Set Unit)) := by
    ext a
    cases a <;> simp
  rw [h]
  exact (isOpenMap_inr _ isOpen_univ).preimage continuous_toSum

/-- Consequently the nullity fibre of any continuous map is open. -/
theorem isOpen_preimage_null {X : Type*} [TopologicalSpace X] {h : X → Transreal}
    (hc : Continuous h) : IsOpen (h ⁻¹' {null}) :=
  isOpen_singleton_null.preimage hc

/-! ### The finite fragment is an open copy of the line -/

theorem continuous_fin : Continuous (fin : ℝ → Transreal) := by
  rw [isEmbedding_toSum.continuous_iff]
  exact continuous_inl.comp continuous_coe_real_ereal

theorem isOpenEmbedding_fin : IsOpenEmbedding (fin : ℝ → Transreal) := by
  refine ⟨⟨?_, fin_injective⟩, ?_⟩
  · refine (IsInducing.of_comp continuous_fin continuous_toSum ?_)
    have : toSum ∘ fin = fun x : ℝ => Sum.inl (x : EReal) := rfl
    rw [this]
    exact IsOpenEmbedding.inl.isInducing.comp EReal.isEmbedding_coe.isInducing
  · have h : Set.range (fin : ℝ → Transreal) = finiteSide (Set.range ((↑) : ℝ → EReal)) := by
      ext a
      cases a <;> simp [eq_comm]
    rw [h]
    exact isOpen_finiteSide EReal.isOpenEmbedding_coe.isOpen_range

/-! ### The guarded transfer principle (single-step form) -/

variable {X : Type*} [TopologicalSpace X]

/-- Transfer of a continuous real function into the finite fragment. -/
theorem continuous_finComp {f : X → ℝ} (hf : Continuous f) :
    Continuous fun x => fin (f x) :=
  continuous_fin.comp hf

/-- Sums transfer. -/
theorem continuous_finAdd {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous fun x => fin (f x) + fin (g x) := by
  simpa using continuous_finComp (hf.add hg)

/-- Products transfer. -/
theorem continuous_finMul {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous fun x => fin (f x) * fin (g x) := by
  simpa using continuous_finComp (hf.mul hg)

/-- **Guarded division transfers.**  If the denominator never vanishes, the
transreal quotient is continuous — indeed it never leaves the finite fragment. -/
theorem continuous_guarded_div {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g)
    (h0 : ∀ x, g x ≠ 0) : Continuous fun x => fin (f x) / fin (g x) := by
  have : (fun x => fin (f x) / fin (g x)) = fun x => fin (f x / g x) := by
    funext x
    exact fin_div_fin_of_ne (h0 x)
  rw [this]
  exact continuous_finComp (hf.div hg h0)

/-! ### The unguarded boundary: topology-independent failure -/

/-- **No T₁ topology repairs unguarded self-division.**  For *every* T₁ topology
on the four-constructor carrier, the map `x ↦ x / x` — which is the constant `1`
off the origin and `null` at the origin — is discontinuous.  In particular no
choice of topology, Hausdorff or not, can make the unguarded fragment
continuous. -/
theorem selfDiv_not_continuous_of_t1 (t : TopologicalSpace Transreal)
    (h1 : @T1Space Transreal t) :
    ¬ @Continuous ℝ Transreal _ t (fun x : ℝ => fin x / fin x) := by
  letI := t
  letI := h1
  intro hc
  have hcl : IsClosed ({fin 1} : Set Transreal) := isClosed_singleton
  have hpre : IsClosed ((fun x : ℝ => fin x / fin x) ⁻¹' {fin 1}) := hcl.preimage hc
  have hsub : ({0}ᶜ : Set ℝ) ⊆ (fun x : ℝ => fin x / fin x) ⁻¹' {fin 1} := by
    intro x hx
    have hx0 : x ≠ 0 := hx
    simp [Set.mem_preimage, fin_div_self, hx0]
  have hclos : closure ({0}ᶜ : Set ℝ) ⊆ (fun x : ℝ => fin x / fin x) ⁻¹' {fin 1} :=
    hpre.closure_subset_iff.2 hsub
  have h0 : (0 : ℝ) ∈ (fun x : ℝ => fin x / fin x) ⁻¹' {fin 1} := by
    apply hclos
    rw [(dense_compl_singleton (0 : ℝ)).closure_eq]
    exact Set.mem_univ 0
  simp at h0

/-- The same obstruction stated for the natural topology, where nullity is
isolated: the nullity fibre of a continuous map is open, but the nullity fibre
of self-division is the non-open singleton `{0}`. -/
theorem selfDiv_not_continuous : ¬ Continuous (fun x : ℝ => fin x / fin x) := by
  intro hc
  have hopen : IsOpen ((fun x : ℝ => fin x / fin x) ⁻¹' {null}) := isOpen_preimage_null hc
  have hfib : ((fun x : ℝ => fin x / fin x) ⁻¹' {null}) = ({0} : Set ℝ) := by
    ext x
    by_cases hx : x = 0 <;> simp [Set.mem_preimage, fin_div_self, hx]
  rw [hfib] at hopen
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.1 hopen 0 rfl
  have hmem : (ε / 2) ∈ Metric.ball (0 : ℝ) ε := by
    simp only [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos (by linarith : (0:ℝ) < ε / 2)]
    linarith
  have := hball hmem
  simp only [Set.mem_singleton_iff] at this
  linarith

/-! ### The unguarded boundary: no value repairs the reciprocal -/

/-- The reciprocal with an arbitrary value `v` plugged in at the origin. -/
noncomputable def recipAt (v : Transreal) (y : ℝ) : Transreal :=
  if y = 0 then v else fin y⁻¹

theorem recipAt_zero (v : Transreal) : recipAt v 0 = v := by simp [recipAt]

theorem recipAt_of_ne {v : Transreal} {y : ℝ} (hy : y ≠ 0) : recipAt v y = fin y⁻¹ := by
  simp [recipAt, hy]

/-- Every neighbourhood of the plugged-in value must contain arbitrarily large
positive **and** arbitrarily large negative finite values.  This is the
quantitative core of the non-repairability theorem. -/
theorem exists_large_of_continuousAt_recipAt {v : Transreal}
    (hc : ContinuousAt (recipAt v) 0)
    {V : Set Transreal} (hV : IsOpen V) (hv : v ∈ V) (M : ℝ) :
    (∃ a, M < a ∧ fin a ∈ V) ∧ (∃ b, b < -M ∧ fin b ∈ V) := by
  have hnhds : recipAt v ⁻¹' V ∈ nhds (0 : ℝ) := by
    refine hc.preimage_mem_nhds ?_
    rw [recipAt_zero]
    exact hV.mem_nhds hv
  obtain ⟨ε, hε, hball⟩ := Metric.mem_nhds_iff.1 hnhds
  set y : ℝ := min (ε / 2) (1 / (|M| + 1)) with hy_def
  have hMpos : (0 : ℝ) < |M| + 1 := by positivity
  have hy_pos : 0 < y := lt_min (by linarith) (by positivity)
  have hy_lt : y < ε := lt_of_le_of_lt (min_le_left _ _) (by linarith)
  have hy_le : y ≤ 1 / (|M| + 1) := min_le_right _ _
  have hy_inv : |M| + 1 ≤ y⁻¹ := by
    rw [le_inv_comm₀ hMpos hy_pos]
    simpa [one_div] using hy_le
  have hMle : M ≤ |M| := le_abs_self M
  constructor
  · refine ⟨y⁻¹, by linarith, ?_⟩
    have hmem : y ∈ Metric.ball (0 : ℝ) ε := by
      simp only [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos hy_pos]
      exact hy_lt
    have := hball hmem
    rwa [Set.mem_preimage, recipAt_of_ne hy_pos.ne'] at this
  · refine ⟨(-y)⁻¹, ?_, ?_⟩
    · rw [inv_neg]
      linarith
    · have hmem : (-y) ∈ Metric.ball (0 : ℝ) ε := by
        simp only [Metric.mem_ball, Real.dist_eq, sub_zero, abs_neg, abs_of_pos hy_pos]
        exact hy_lt
      have := hball hmem
      rwa [Set.mem_preimage, recipAt_of_ne (neg_ne_zero.2 hy_pos.ne')] at this

/-- **No value repairs unguarded division.**  In the natural (compact Hausdorff)
topology on the four-constructor carrier, for *every* `v : Transreal` the map
`y ↦ 1/y` extended by `v` at the origin is discontinuous.  Enlarging the carrier
by two infinities and a nullity is therefore *not* enough to make unguarded
division continuous: the guard `denominator ≠ 0` is necessary, not merely
convenient. -/
theorem no_continuous_repair (v : Transreal) : ¬ ContinuousAt (recipAt v) 0 := by
  intro hc
  cases v with
  | fin r =>
      have hV : IsOpen (finiteSide (Ioo ((r - 1 : ℝ) : EReal) ((r + 1 : ℝ) : EReal))) :=
        isOpen_finiteSide isOpen_Ioo
      have hv : fin r ∈ finiteSide (Ioo ((r - 1 : ℝ) : EReal) ((r + 1 : ℝ) : EReal)) := by
        simp only [fin_mem_finiteSide, Set.mem_Ioo, EReal.coe_lt_coe_iff]
        constructor <;> linarith
      obtain ⟨⟨a, ha, haV⟩, -⟩ := exists_large_of_continuousAt_recipAt hc hV hv (|r| + 1)
      rw [fin_mem_finiteSide] at haV
      have : a < r + 1 := by
        have := haV.2
        exact_mod_cast this
      have : r ≤ |r| := le_abs_self r
      linarith
  | pinf =>
      have hV : IsOpen (finiteSide (Ioi (0 : EReal))) := isOpen_finiteSide isOpen_Ioi
      have hv : pinf ∈ finiteSide (Ioi (0 : EReal)) := by
        simp only [pinf_mem_finiteSide, Set.mem_Ioi]
        exact lt_top_iff_ne_top.2 (by simp)
      obtain ⟨-, ⟨b, hb, hbV⟩⟩ := exists_large_of_continuousAt_recipAt hc hV hv 0
      rw [fin_mem_finiteSide] at hbV
      have hb0 : (0 : ℝ) < b := by
        have := hbV
        rw [Set.mem_Ioi, show (0 : EReal) = ((0 : ℝ) : EReal) by simp,
          EReal.coe_lt_coe_iff] at this
        exact this
      linarith
  | ninf =>
      have hV : IsOpen (finiteSide (Iio (0 : EReal))) := isOpen_finiteSide isOpen_Iio
      have hv : ninf ∈ finiteSide (Iio (0 : EReal)) := by
        simp only [ninf_mem_finiteSide, Set.mem_Iio]
        exact bot_lt_iff_ne_bot.2 (by simp)
      obtain ⟨⟨a, ha, haV⟩, -⟩ := exists_large_of_continuousAt_recipAt hc hV hv 0
      rw [fin_mem_finiteSide] at haV
      have ha0 : a < 0 := by
        have := haV
        rw [Set.mem_Iio, show (0 : EReal) = ((0 : ℝ) : EReal) by simp,
          EReal.coe_lt_coe_iff] at this
        exact this
      linarith
  | null =>
      obtain ⟨⟨a, -, haV⟩, -⟩ :=
        exists_large_of_continuousAt_recipAt hc isOpen_singleton_null rfl 0
      simp at haV

/-- Global form of the non-repairability theorem. -/
theorem no_continuous_repair' (v : Transreal) : ¬ Continuous (recipAt v) :=
  fun hc => no_continuous_repair v hc.continuousAt

/-- The transreal reciprocal is itself one of the repairs covered above (it uses
`v = pinf`), hence discontinuous. -/
theorem recip_fin_not_continuous : ¬ Continuous (fun y : ℝ => fin 1 / fin y) := by
  have h : (fun y : ℝ => fin 1 / fin y) = recipAt pinf := by
    funext y
    by_cases hy : y = 0
    · subst hy
      simp [recipAt, div_fin_zero_of_pos]
    · rw [fin_div_fin_of_ne hy, recipAt_of_ne hy, one_div]
  rw [h]
  exact no_continuous_repair' pinf

end Transreal