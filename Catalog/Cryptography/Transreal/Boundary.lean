import Cryptography.Transreal.Transfer

/-!
# The guard, algebraically and topologically

`Cryptography.Transreal.Transfer` shows that the *guarded* fragment — finite
arithmetic together with division by a nowhere-vanishing denominator — transfers
exactly, and that the unguarded extension fails for every T₁ topology on the
four-constructor carrier.  This file explains *why* the guard is the right
notion, by characterising it twice over, once in algebra and once in topology,
and by locating the exact failure of joint continuity.

## Main results

### Algebra: the guard is invertibility

* `Transreal.exists_mul_eq_one_iff`: a transreal has a multiplicative inverse
  **iff** it is a nonzero finite element.  So "denominator nonzero" is not an
  ad-hoc side condition: the guarded denominators are precisely the units of the
  total transreal multiplication.
* `Transreal.exists_add_eq_zero_iff`: a transreal has an additive inverse **iff**
  it is finite.  The finite fragment is exactly the additive-group part.

### Topology: the exact continuity locus of division

* `Transreal.continuousAt_div_fin`: transreal division `(a, b) ↦ a / b` is
  continuous at every pair of finite values with `b ≠ 0`;
* `Transreal.not_continuousAt_div_fin_zero`: and at **no** pair whose
  denominator is `0`.  Together these compute the continuity locus of division
  on the finite square exactly, matching the algebraic characterisation.

### Rigidity: the unique repair value is one, and arithmetic refuses it

* `Transreal.selfDivAt_continuous_iff`: for every T₁ topology, the punctured
  constant `x ↦ x/x` extends continuously **only** by the value `fin 1` —
  whereas total transreal arithmetic is forced to return `null`.  This is the
  cleanest possible statement of the obstruction: the guard fails by exactly one
  point and exactly one value.

### The carrier is not a topological semiring

* `Transreal.add_not_continuousAt_pinf_ninf`,
  `Transreal.mul_not_continuousAt_zero_pinf`: total addition and multiplication
  are not jointly continuous at the indeterminate forms `∞ - ∞` and `0 · ∞`.
  Compactness and Hausdorffness are therefore compatible with total arithmetic
  only at the price of continuity — the same trade-off as at the division
  boundary.
-/

namespace Transreal

open Set Filter Topology

/-! ### Definitional evaluation of mixed products -/

theorem fin_mul_pinf_eq (x : ℝ) :
    fin x * pinf = if x = 0 then null else if 0 < x then pinf else ninf := rfl

theorem fin_mul_ninf_eq (x : ℝ) :
    fin x * ninf = if x = 0 then null else if 0 < x then ninf else pinf := rfl

theorem pinf_mul_fin_eq (y : ℝ) :
    pinf * fin y = if y = 0 then null else if 0 < y then pinf else ninf := rfl

theorem ninf_mul_fin_eq (y : ℝ) :
    ninf * fin y = if y = 0 then null else if 0 < y then ninf else pinf := rfl

/-! ### The guard is invertibility -/

/-- **The guarded denominators are exactly the units.**  A transreal is
invertible for the total multiplication iff it is a nonzero finite element.
Thus the side condition "denominator nonzero" in the transfer principle is
forced by the algebra, not chosen by hand. -/
theorem exists_mul_eq_one_iff (a : Transreal) :
    (∃ b, a * b = fin 1) ↔ ∃ x : ℝ, x ≠ 0 ∧ a = fin x := by
  constructor
  · rintro ⟨b, hb⟩
    cases a with
    | fin x =>
        refine ⟨x, ?_, rfl⟩
        rintro rfl
        cases b with
        | fin y => simp at hb
        | pinf => simp at hb
        | ninf => simp at hb
        | null => simp at hb
    | pinf =>
        exfalso
        cases b with
        | fin y => rw [pinf_mul_fin_eq] at hb; split_ifs at hb
        | pinf => simp at hb
        | ninf => simp at hb
        | null => simp at hb
    | ninf =>
        exfalso
        cases b with
        | fin y => rw [ninf_mul_fin_eq] at hb; split_ifs at hb
        | pinf => simp at hb
        | ninf => simp at hb
        | null => simp at hb
    | null => exact absurd hb (by simp)
  · rintro ⟨x, hx, rfl⟩
    exact ⟨fin x⁻¹, by rw [fin_mul_fin, mul_inv_cancel₀ hx]⟩

/-- **The additive part is exactly the finite fragment.**  A transreal has an
additive inverse iff it is finite. -/
theorem exists_add_eq_zero_iff (a : Transreal) :
    (∃ b, a + b = fin 0) ↔ Finite a := by
  constructor
  · rintro ⟨b, hb⟩
    cases a with
    | fin x => exact ⟨x, rfl⟩
    | pinf => exfalso; cases b <;> simp at hb
    | ninf => exfalso; cases b <;> simp at hb
    | null => exact absurd hb (by simp)
  · rintro ⟨x, rfl⟩
    exact ⟨fin (-x), by simp⟩

/-! ### The exact continuity locus of division on the finite square -/

/-- Guarded division is continuous as a *binary* operation: at every pair of
finite values with nonvanishing denominator the total division map is
continuous. -/
theorem continuousAt_div_fin {x y : ℝ} (hy : y ≠ 0) :
    ContinuousAt (fun p : Transreal × Transreal => p.1 / p.2) (fin x, fin y) := by
  have hφ : IsOpenEmbedding (Prod.map (fin) (fin)) :=
    isOpenEmbedding_fin.prodMap isOpenEmbedding_fin
  have hmap : Filter.map (Prod.map (fin) (fin)) (𝓝 (x, y)) = 𝓝 (fin x, fin y) := by
    simpa [Prod.map] using hφ.map_nhds_eq (x, y)
  have hne : ∀ᶠ p : ℝ × ℝ in 𝓝 (x, y), p.2 ≠ 0 :=
    (continuous_snd.tendsto (x, y)).eventually (eventually_ne_nhds hy)
  have hcont : ContinuousAt (fun p : ℝ × ℝ => p.1 / p.2) (x, y) :=
    continuousAt_fst.div continuousAt_snd hy
  have h1 : Tendsto (fun p : ℝ × ℝ => fin (p.1 / p.2)) (𝓝 (x, y)) (𝓝 (fin (x / y))) :=
    (continuous_fin.tendsto _).comp hcont
  have h2 : Tendsto (fun p : ℝ × ℝ => fin p.1 / fin p.2) (𝓝 (x, y)) (𝓝 (fin x / fin y)) := by
    rw [fin_div_fin_of_ne hy]
    refine h1.congr' ?_
    filter_upwards [hne] with p hp
    exact (fin_div_fin_of_ne hp).symm
  rw [ContinuousAt, ← hmap, Filter.tendsto_map'_iff]
  exact h2

/-- At a vanishing denominator the binary division map is discontinuous, for
*every* finite numerator.  With `continuousAt_div_fin` this determines the
continuity locus of division on the finite square exactly: it is the set of
pairs with invertible second coordinate. -/
theorem not_continuousAt_div_fin_zero (x : ℝ) :
    ¬ ContinuousAt (fun p : Transreal × Transreal => p.1 / p.2) (fin x, fin 0) := by
  intro hc
  have hg : ContinuousAt (fun y : ℝ => ((fin x : Transreal), (fin y : Transreal))) 0 :=
    continuousAt_const.prodMk (continuous_fin.continuousAt)
  have hcomp : ContinuousAt (fun y : ℝ => (fin x : Transreal) / fin y) 0 := by
    have h := ContinuousAt.comp (g := fun p : Transreal × Transreal => p.1 / p.2)
      (f := fun y : ℝ => ((fin x : Transreal), (fin y : Transreal))) (x := (0 : ℝ)) hc hg
    simpa [Function.comp] using h
  by_cases hx : x = 0
  · subst hx
    have hnhds : (fun y : ℝ => (fin (0:ℝ) : Transreal) / fin y) ⁻¹' {null} ∈ 𝓝 (0 : ℝ) :=
      hcomp.preimage_mem_nhds (isOpen_singleton_null.mem_nhds (by simp))
    obtain ⟨ε, hε, hball⟩ := Metric.mem_nhds_iff.1 hnhds
    have hhalf : (0 : ℝ) < ε / 2 := by linarith
    have hmem : (ε / 2 : ℝ) ∈ Metric.ball (0 : ℝ) ε := by
      simp only [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos hhalf]
      linarith
    have hval := hball hmem
    simp only [Set.mem_preimage, Set.mem_singleton_iff] at hval
    rw [fin_div_fin_of_ne (ne_of_gt hhalf), zero_div] at hval
    exact absurd hval (by simp)
  · -- rescale to the pure reciprocal, using `x / y = ((y / x))⁻¹`
    set v : Transreal := fin x / fin 0 with hv
    have hrepr : (fun y : ℝ => (fin x : Transreal) / fin y) =
        (recipAt v) ∘ (fun y : ℝ => y / x) := by
      funext y
      by_cases hy : y = 0
      · subst hy
        simp [recipAt, hv]
      · have hyx : y / x ≠ 0 := div_ne_zero hy hx
        rw [Function.comp_apply, recipAt_of_ne hyx, fin_div_fin_of_ne hy]
        congr 1
        field_simp
    rw [hrepr] at hcomp
    have hinner : ContinuousAt (fun z : ℝ => x * z) 0 :=
      (continuous_const.mul continuous_id).continuousAt
    have hcomp2 := ContinuousAt.comp
      (g := (recipAt v) ∘ (fun y : ℝ => y / x)) (f := fun z : ℝ => x * z) (x := (0 : ℝ))
      (by simpa using hcomp) hinner
    have hid : ((recipAt v) ∘ (fun y : ℝ => y / x)) ∘ (fun z : ℝ => x * z) = recipAt v := by
      funext z
      simp only [Function.comp_apply]
      rw [mul_div_cancel_left₀ z hx]
    rw [hid] at hcomp2
    exact no_continuous_repair v hcomp2

/-! ### Rigidity of the repair value -/

/-- A continuous map on the line that is constant off the origin is constant:
the T₁ separation of the target is all that is needed. -/
theorem eq_of_punctured_const_of_t1 (t : TopologicalSpace Transreal)
    (h1 : @T1Space Transreal t) {h : ℝ → Transreal} (hc : @Continuous ℝ Transreal _ t h)
    {v : Transreal} (hcst : ∀ x : ℝ, x ≠ 0 → h x = v) : h 0 = v := by
  letI := t
  letI := h1
  have hpre : IsClosed (h ⁻¹' {v}) := isClosed_singleton.preimage hc
  have hsub : ({0}ᶜ : Set ℝ) ⊆ h ⁻¹' {v} := fun x hx => hcst x hx
  have hclos : closure ({0}ᶜ : Set ℝ) ⊆ h ⁻¹' {v} := hpre.closure_subset_iff.2 hsub
  have h0 : (0 : ℝ) ∈ h ⁻¹' {v} := by
    apply hclos
    rw [(dense_compl_singleton (0 : ℝ)).closure_eq]
    exact Set.mem_univ 0
  exact h0

/-- Self-division with the value `v` plugged in at the origin. -/
noncomputable def selfDivAt (v : Transreal) (x : ℝ) : Transreal :=
  if x = 0 then v else fin 1

/-- **The unique continuous repair of `0/0` is `1`.**  For every T₁ topology on
the four-constructor carrier, `x ↦ x/x` extends continuously by `v` if and only
if `v = fin 1`.  Total transreal arithmetic returns `null` instead, so the
failure of the unguarded transfer principle is a failure by exactly one value at
exactly one point. -/
theorem selfDivAt_continuous_iff (t : TopologicalSpace Transreal)
    (h1 : @T1Space Transreal t) (v : Transreal) :
    @Continuous ℝ Transreal _ t (selfDivAt v) ↔ v = fin 1 := by
  letI := t
  letI := h1
  constructor
  · intro hc
    have hcst : ∀ x : ℝ, x ≠ 0 → selfDivAt v x = fin 1 := by
      intro x hx
      simp [selfDivAt, hx]
    have := eq_of_punctured_const_of_t1 t h1 hc hcst
    simpa [selfDivAt] using this
  · rintro rfl
    have : selfDivAt (fin 1) = fun _ : ℝ => fin 1 := by
      funext x
      by_cases hx : x = 0 <;> simp [selfDivAt, hx]
    rw [this]
    exact continuous_const

/-- Transreal arithmetic does not take the unique continuous repair value: it
returns `null`, which differs from `fin 1`.  Hence the discontinuity. -/
theorem transreal_selfDiv_ne_repair : (fin (0:ℝ) / fin 0) ≠ fin 1 := by
  rw [zero_div_zero]
  simp

/-- **Distributivity fails on the exceptional constructors.**  Totality is paid
for in algebra as well as in topology: `pinf * (1 + 0) = pinf` while
`pinf * 1 + pinf * 0 = pinf + null = null`.  (Both laws do hold on the finite
fragment, where the transfer principle lives.) -/
theorem not_mul_add_distrib :
    ¬ ∀ a b c : Transreal, a * (b + c) = a * b + a * c := by
  intro h
  have h1 := h pinf (fin 1) (fin 0)
  simp [pinf_mul_fin_eq] at h1

/-! ### Failure of joint continuity of total arithmetic -/

theorem tendsto_fin_atTop : Tendsto (fin : ℝ → Transreal) atTop (𝓝 pinf) := by
  rw [isEmbedding_toSum.isInducing.tendsto_nhds_iff]
  have : (toSum ∘ (fin : ℝ → Transreal)) = fun x : ℝ => Sum.inl (x : EReal) := rfl
  rw [this, toSum_pinf]
  exact (continuous_inl.tendsto _).comp EReal.tendsto_coe_atTop

theorem tendsto_fin_atBot : Tendsto (fin : ℝ → Transreal) atBot (𝓝 ninf) := by
  rw [isEmbedding_toSum.isInducing.tendsto_nhds_iff]
  have : (toSum ∘ (fin : ℝ → Transreal)) = fun x : ℝ => Sum.inl (x : EReal) := rfl
  rw [this, toSum_ninf]
  exact (continuous_inl.tendsto _).comp EReal.tendsto_coe_atBot

/-- **`∞ - ∞` is a genuine discontinuity.**  Total transreal addition is not
continuous at `(pinf, ninf)`: along `t ↦ (t, -t)` the sums are constantly `0`,
yet the limit point is assigned `null`. -/
theorem add_not_continuousAt_pinf_ninf :
    ¬ ContinuousAt (fun p : Transreal × Transreal => p.1 + p.2) (pinf, ninf) := by
  intro hc
  have hpath : Tendsto (fun t : ℝ => ((fin t : Transreal), (fin (-t) : Transreal)))
      atTop (𝓝 (pinf, ninf)) :=
    tendsto_fin_atTop.prodMk_nhds (tendsto_fin_atBot.comp tendsto_neg_atTop_atBot)
  have hlim : Tendsto (fun t : ℝ => (fin t : Transreal) + fin (-t)) atTop (𝓝 (pinf + ninf)) :=
    hc.tendsto.comp hpath
  have hconst : (fun t : ℝ => (fin t : Transreal) + fin (-t)) = fun _ => fin 0 := by
    funext t
    simp
  rw [hconst, pinf_add_ninf] at hlim
  have : (fin (0:ℝ)) = null := tendsto_nhds_unique tendsto_const_nhds hlim
  simp at this

/-- **`0 · ∞` is a genuine discontinuity.**  Total transreal multiplication is
not continuous at `(fin 0, pinf)`: along `t ↦ (1/t, t)` the products are
constantly `1`, yet the limit point is assigned `null`. -/
theorem mul_not_continuousAt_zero_pinf :
    ¬ ContinuousAt (fun p : Transreal × Transreal => p.1 * p.2) (fin 0, pinf) := by
  intro hc
  have hinv : Tendsto (fun t : ℝ => (fin t⁻¹ : Transreal)) atTop (𝓝 (fin 0)) := by
    have : Tendsto (fun t : ℝ => t⁻¹) atTop (𝓝 (0 : ℝ)) := tendsto_inv_atTop_zero
    exact (continuous_fin.tendsto _).comp this
  have hpath : Tendsto (fun t : ℝ => ((fin t⁻¹ : Transreal), (fin t : Transreal)))
      atTop (𝓝 (fin 0, pinf)) :=
    hinv.prodMk_nhds tendsto_fin_atTop
  have hlim : Tendsto (fun t : ℝ => (fin t⁻¹ : Transreal) * fin t) atTop (𝓝 (fin 0 * pinf)) :=
    hc.tendsto.comp hpath
  rw [fin_zero_mul_pinf] at hlim
  have heq : (fun _ : ℝ => (fin 1 : Transreal)) =ᶠ[atTop]
      fun t : ℝ => (fin t⁻¹ : Transreal) * fin t := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    rw [fin_mul_fin, inv_mul_cancel₀ ht.ne']
  have hlim' : Tendsto (fun t : ℝ => (fin t⁻¹ : Transreal) * fin t) atTop (𝓝 (fin 1)) :=
    tendsto_const_nhds.congr' heq
  have : (fin (1:ℝ)) = null := tendsto_nhds_unique hlim' hlim
  simp at this

end Transreal