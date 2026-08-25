import Mathlib

/-!
# Edge-kernel refinement of a positional hit profile

This file formalises the *mathematical* content behind the experimental finding of
exp588 ("edge-kernel refinement"): a positional hit profile on a normalised window
`x ∈ [0,1]` that is empirically described by a **flat bulk plus a narrow left-edge
spike** cannot be a pure power law, and every statistic used to detect the spike is
governed by rigid monotonicity properties of the one-parameter power-law family.

The analytic object is the *harmonic-type kernel*

  `ker b x = (1 + x) ^ (-b)`,   `x ∈ [0,1]`,

whose normalised cumulative mass ("edge fraction at `t`") is

  `edgeFrac b t = (∫ x in 0..t, ker b x) / (∫ x in 0..1, ker b x)`.

## Main results

* `Pythagorean.EdgeKernel.headMass_eq` — closed form `∫₀ᵗ (1+x)^{-b} dx = ((1+t)^{1-b}-1)/(1-b)`.
* `Pythagorean.EdgeKernel.edgeFrac_strictMono` — **rigidity of the single-law family**:
  `b ↦ edgeFrac b t` is strictly increasing for every interior `t`. Hence the exponent
  is *identified* by any single edge-mass measurement (`edgeFrac_injective`).
* `Pythagorean.EdgeKernel.edgeFrac_gt_of_pos` — a decreasing kernel always over-weights the
  left decile: `edgeFrac b t > t` for `b > 0`, with equality exactly for the flat kernel.
* `Pythagorean.EdgeKernel.edgeFrac_tendsto_one` — the spike limit: `edgeFrac b t → 1` as
  `b → ∞`.
* `Pythagorean.EdgeKernel.exists_edgeFrac_eq` — **a single measured edge fraction can never
  refute a power law**: every value in `(edgeFrac b₀ t, 1)` is attained by some exponent.
  (This is why the experiment needed a *shape* comparison, not just the left-decile number.)
* `Pythagorean.EdgeKernel.twoComp_ne_single` — **the falsifiability theorem**: for `A,K > 0`
  and `b₁ ≠ b₂` the two-component profile `A(1+x)^{-b₁} + K(1+x)^{-b₂}` is *not* equal to
  `C (1+x)^{-b}` for any `C, b`, on any window containing `0`, `√2 - 1`, `1`. A pure power
  law is therefore known-wrong for a genuine bulk+spike profile.
* `Pythagorean.EdgeKernel.twoComp_edgeFrac_eq_mix` — the normalised two-component profile is
  exactly the two-point mixture of the normalised components, with explicit weight.
* `Pythagorean.EdgeKernel.mix_effective_exponent_gt_bulk` — **effective-exponent inflation**:
  the single exponent that reproduces the mixture's edge fraction is strictly larger than
  the bulk exponent (the mechanism by which a pooled single-law fit is dragged steeper by a
  narrow edge spike).
* `Pythagorean.EdgeKernel.mixFrac_tendsto_spike` — in the narrow-spike limit `b₂ → ∞` the
  edge fraction converges to `w + (1-w) * edgeFrac b₁ t`, i.e. the spike weight `w` is
  identified by the excess over the bulk prediction.
-/

namespace Pythagorean.EdgeKernel

open MeasureTheory intervalIntegral Filter Topology

/-! ## The harmonic-type kernel and its cumulative mass -/

/-- The positional kernel `x ↦ (1+x)^{-b}` on the normalised window. -/
noncomputable def ker (b x : ℝ) : ℝ := (1 + x) ^ (-b)

@[simp] lemma ker_zero_arg (b : ℝ) : ker b 0 = 1 := by
  simp [ker]

lemma ker_pos (b : ℝ) {x : ℝ} (hx : 0 ≤ x) : 0 < ker b x :=
  Real.rpow_pos_of_pos (by linarith) _

lemma ker_cont (b : ℝ) : ContinuousOn (ker b) (Set.Ici (0 : ℝ)) := by
  intro x hx
  simp only [Set.mem_Ici] at hx
  exact ContinuousAt.continuousWithinAt
    (ContinuousAt.rpow_const (by fun_prop) (Or.inl (by linarith)))

lemma ker_int (b : ℝ) {a c : ℝ} (ha : 0 ≤ a) (hc : 0 ≤ c) :
    IntervalIntegrable (ker b) volume a c := by
  apply ContinuousOn.intervalIntegrable
  refine (ker_cont b).mono ?_
  intro y hy
  rw [Set.mem_uIcc] at hy
  simp only [Set.mem_Ici]
  rcases hy with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> linarith

/-- Additivity of the exponent turns into multiplicativity of the kernel. -/
lemma ker_add_mul (b c : ℝ) {x : ℝ} (hx : 0 ≤ x) : ker (b + c) x = ker b x * ker c x := by
  rw [ker, ker, ker, ← Real.rpow_add (by linarith : (0:ℝ) < 1 + x)]
  ring_nf

/-- For a nonnegative exponent the kernel is antitone in the position. -/
lemma ker_antitone (c : ℝ) (hc : 0 ≤ c) {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) :
    ker c y ≤ ker c x :=
  Real.rpow_le_rpow_of_nonpos (by linarith) (by linarith) (neg_nonpos.mpr hc)

/-- For a positive exponent the kernel is strictly antitone in the position. -/
lemma ker_strictAnti (c : ℝ) (hc : 0 < c) {x y : ℝ} (hx : 0 ≤ x) (hxy : x < y) :
    ker c y < ker c x :=
  Real.rpow_lt_rpow_of_neg (by linarith) (by linarith) (neg_neg_iff_pos.mpr hc)

/-- Mass of the kernel on the initial segment `[0,t]`. -/
noncomputable def headMass (b t : ℝ) : ℝ := ∫ x in (0:ℝ)..t, ker b x

/-- Mass of the kernel on the terminal segment `[t,1]`. -/
noncomputable def tailMass (b t : ℝ) : ℝ := ∫ x in t..(1:ℝ), ker b x

lemma headMass_pos (b : ℝ) {t : ℝ} (ht : 0 < t) : 0 < headMass b t := by
  refine intervalIntegral.intervalIntegral_pos_of_pos_on (ker_int b le_rfl ht.le) ?_ ht
  intro x hx
  exact ker_pos b (le_of_lt (by simpa using hx.1))

lemma tailMass_pos (b : ℝ) {t : ℝ} (ht0 : 0 ≤ t) (ht : t < 1) : 0 < tailMass b t := by
  refine intervalIntegral.intervalIntegral_pos_of_pos_on (ker_int b ht0 zero_le_one) ?_ ht
  intro x hx
  exact ker_pos b (by linarith [hx.1])

lemma headMass_add_tailMass (b : ℝ) {t : ℝ} (ht0 : 0 ≤ t) :
    headMass b t + tailMass b t = headMass b 1 :=
  intervalIntegral.integral_add_adjacent_intervals (ker_int b le_rfl ht0)
    (ker_int b ht0 zero_le_one)

lemma hasDerivAt_headMass_antideriv (b : ℝ) (hb : b ≠ 1) {x : ℝ} (hx : 0 ≤ x) :
    HasDerivAt (fun y : ℝ => ((1 + y) ^ (1 - b) - 1) / (1 - b)) (ker b x) x := by
  have h1 : (1:ℝ) + x ≠ 0 := by linarith
  have hd : HasDerivAt (fun y : ℝ => (1 + y) ^ (1 - b)) ((1 - b) * (1 + x) ^ (1 - b - 1)) x := by
    have := (Real.hasDerivAt_rpow_const (p := 1 - b) (Or.inl h1)).comp x
      ((hasDerivAt_id x).const_add 1)
    simpa using this
  have hres := (hd.sub_const 1).div_const (1 - b)
  convert hres using 1
  have hb' : (1:ℝ) - b ≠ 0 := by intro h; apply hb; linarith
  field_simp [ker]
  ring_nf
  rfl

/-- Closed form for the cumulative kernel mass (the case `b ≠ 1`). -/
theorem headMass_eq (b : ℝ) (hb : b ≠ 1) {t : ℝ} (ht : 0 ≤ t) :
    headMass b t = ((1 + t) ^ (1 - b) - 1) / (1 - b) := by
  have := intervalIntegral.integral_eq_sub_of_hasDerivAt
    (f := fun y : ℝ => ((1 + y) ^ (1 - b) - 1) / (1 - b)) (f' := ker b) (a := 0) (b := t)
    (fun x hx => hasDerivAt_headMass_antideriv b hb
      (by rw [Set.uIcc_of_le ht] at hx; exact hx.1))
    (ker_int b le_rfl ht)
  simp [headMass, this]

@[simp] lemma headMass_zero_exp (t : ℝ) : headMass 0 t = t := by
  simp [headMass, ker]

/-! ## The normalised edge fraction -/

/-- Fraction of the kernel mass carried by the initial segment `[0,t]` of the window. -/
noncomputable def edgeFrac (b t : ℝ) : ℝ := headMass b t / headMass b 1

@[simp] lemma edgeFrac_zero_exp (t : ℝ) : edgeFrac 0 t = t := by
  simp [edgeFrac, headMass_zero_exp t, headMass_zero_exp 1]

lemma edgeFrac_pos (b : ℝ) {t : ℝ} (ht : 0 < t) : 0 < edgeFrac b t :=
  div_pos (headMass_pos b ht) (headMass_pos b one_pos)

lemma edgeFrac_lt_one (b : ℝ) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) : edgeFrac b t < 1 := by
  rw [edgeFrac, div_lt_one (headMass_pos b one_pos), ← headMass_add_tailMass b ht0]
  linarith [tailMass_pos b ht0 ht1]

/-! ### Monotone likelihood ratio: rigidity of the single-law family -/

/-- On the head `[0,t]`, steepening the exponent by `c` costs at most the factor `ker c t`. -/
lemma headMass_le_of_add (b : ℝ) {c t : ℝ} (hc : 0 ≤ c) (ht : 0 ≤ t) :
    ker c t * headMass b t ≤ headMass (b + c) t := by
  rw [headMass, headMass, ← intervalIntegral.integral_const_mul]
  refine intervalIntegral.integral_mono_on ht ((ker_int b le_rfl ht).const_mul _)
    (ker_int (b + c) le_rfl ht) ?_
  intro x hx
  have hx0 : 0 ≤ x := hx.1
  have h1 : ker c t ≤ ker c x := ker_antitone c hc hx0 hx.2
  rw [ker_add_mul b c hx0]
  nlinarith [ker_pos b hx0]

/-- On the tail `[t,1]`, steepening the exponent by `c` costs *strictly more* than `ker c t`. -/
lemma tailMass_lt_of_add (b : ℝ) {c t : ℝ} (hc : 0 < c) (ht0 : 0 ≤ t) (ht1 : t < 1) :
    tailMass (b + c) t < ker c t * tailMass b t := by
  set m : ℝ := (t + 1) / 2 with hm
  have htm : t < m := by rw [hm]; linarith
  have hm1 : m < 1 := by rw [hm]; linarith
  have hm0 : 0 ≤ m := by linarith
  have hsplit : ∀ b' : ℝ, tailMass b' t = (∫ x in t..m, ker b' x) + ∫ x in m..(1:ℝ), ker b' x := by
    intro b'
    exact (intervalIntegral.integral_add_adjacent_intervals (ker_int b' ht0 hm0)
      (ker_int b' hm0 zero_le_one)).symm
  have hA : (∫ x in t..m, ker (b + c) x) ≤ ker c t * ∫ x in t..m, ker b x := by
    rw [← intervalIntegral.integral_const_mul]
    refine intervalIntegral.integral_mono_on htm.le (ker_int (b + c) ht0 hm0)
      ((ker_int b ht0 hm0).const_mul _) ?_
    intro x hx
    have hx0 : 0 ≤ x := le_trans ht0 hx.1
    have h1 : ker c x ≤ ker c t := ker_antitone c hc.le ht0 hx.1
    rw [ker_add_mul b c hx0]
    nlinarith [ker_pos b hx0]
  have hB : (∫ x in m..(1:ℝ), ker (b + c) x) < ker c t * ∫ x in m..(1:ℝ), ker b x := by
    have hlt : ker c m < ker c t := ker_strictAnti c hc ht0 htm
    have h1 : (∫ x in m..(1:ℝ), ker (b + c) x) ≤ ker c m * ∫ x in m..(1:ℝ), ker b x := by
      rw [← intervalIntegral.integral_const_mul]
      refine intervalIntegral.integral_mono_on hm1.le (ker_int (b + c) hm0 zero_le_one)
        ((ker_int b hm0 zero_le_one).const_mul _) ?_
      intro x hx
      have hx0 : 0 ≤ x := le_trans hm0 hx.1
      have h1 : ker c x ≤ ker c m := ker_antitone c hc.le hm0 hx.1
      rw [ker_add_mul b c hx0]
      nlinarith [ker_pos b hx0]
    have hpos : 0 < ∫ x in m..(1:ℝ), ker b x :=
      intervalIntegral.intervalIntegral_pos_of_pos_on (ker_int b hm0 zero_le_one)
        (fun x hx => ker_pos b (by linarith [hx.1])) hm1
    nlinarith
  rw [hsplit (b + c), hsplit b]
  nlinarith

/-- **Rigidity.** For each interior `t` the edge fraction is a strictly increasing
function of the exponent. -/
theorem edgeFrac_strictMono {b₁ b₂ t : ℝ} (hb : b₁ < b₂) (ht0 : 0 < t) (ht1 : t < 1) :
    edgeFrac b₁ t < edgeFrac b₂ t := by
  obtain ⟨c, hc0, rfl⟩ : ∃ c, 0 < c ∧ b₂ = b₁ + c := ⟨b₂ - b₁, by linarith, by ring⟩
  have h1 := headMass_le_of_add b₁ hc0.le ht0.le
  have h2 := tailMass_lt_of_add b₁ hc0 ht0.le ht1
  have hH1 : 0 < headMass b₁ t := headMass_pos b₁ ht0
  have hH2 : 0 < headMass (b₁ + c) t := headMass_pos _ ht0
  have hT1 : 0 < tailMass b₁ t := tailMass_pos b₁ ht0.le ht1
  have hT2 : 0 < tailMass (b₁ + c) t := tailMass_pos _ ht0.le ht1
  rw [edgeFrac, edgeFrac, ← headMass_add_tailMass b₁ ht0.le,
    ← headMass_add_tailMass (b₁ + c) ht0.le,
    div_lt_div_iff₀ (by linarith) (by linarith)]
  nlinarith [ker_pos c ht0.le]

/-- The exponent is identified by a single edge-fraction measurement. -/
theorem edgeFrac_injective {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) :
    Function.Injective (fun b => edgeFrac b t) := by
  intro b₁ b₂ h
  rcases lt_trichotomy b₁ b₂ with hlt | heq | hgt
  · exact absurd h (ne_of_lt (edgeFrac_strictMono hlt ht0 ht1))
  · exact heq
  · exact absurd h.symm (ne_of_lt (edgeFrac_strictMono hgt ht0 ht1))

/-- Any decreasing kernel over-weights the initial segment relative to its length. -/
theorem edgeFrac_gt_of_pos {b t : ℝ} (hb : 0 < b) (ht0 : 0 < t) (ht1 : t < 1) :
    t < edgeFrac b t := by
  have := edgeFrac_strictMono hb ht0 ht1
  rwa [edgeFrac_zero_exp t] at this

/-! ### The spike limit and non-falsifiability of a single measurement -/

/-- The closed form of the edge fraction in terms of the exponent (`b ≠ 1`). -/
theorem edgeFrac_eq (b : ℝ) (hb : b ≠ 1) {t : ℝ} (ht : 0 ≤ t) :
    edgeFrac b t = ((1 + t) ^ (1 - b) - 1) / ((2 : ℝ) ^ (1 - b) - 1) := by
  have hb' : (1 : ℝ) - b ≠ 0 := fun h => hb (by linarith)
  have h1 : headMass b 1 = ((2 : ℝ) ^ (1 - b) - 1) / (1 - b) := by
    rw [headMass_eq b hb zero_le_one]; norm_num
  have hpos := headMass_pos b one_pos
  rw [h1] at hpos
  have hden : (2 : ℝ) ^ (1 - b) - 1 ≠ 0 := by
    intro h; rw [h] at hpos; simp at hpos
  rw [edgeFrac, h1, headMass_eq b hb ht]
  field_simp

/-- **Spike limit.** As the exponent grows, all the mass concentrates at the left edge. -/
theorem edgeFrac_tendsto_one {t : ℝ} (ht0 : 0 < t) :
    Tendsto (fun b => edgeFrac b t) atTop (𝓝 1) := by
  have hlin : Tendsto (fun b : ℝ => 1 - b) atTop atBot := by
    simpa [sub_eq_add_neg] using tendsto_atBot_add_const_left atTop (1 : ℝ) tendsto_neg_atTop_atBot
  have h1 : Tendsto (fun b : ℝ => (1 + t) ^ (1 - b)) atTop (𝓝 0) :=
    (tendsto_rpow_atBot_of_base_gt_one (1 + t) (by linarith)).comp hlin
  have h2 : Tendsto (fun b : ℝ => (2 : ℝ) ^ (1 - b)) atTop (𝓝 0) :=
    (tendsto_rpow_atBot_of_base_gt_one 2 (by norm_num)).comp hlin
  have hq : Tendsto (fun b : ℝ => ((1 + t) ^ (1 - b) - 1) / ((2 : ℝ) ^ (1 - b) - 1)) atTop
      (𝓝 (((0 : ℝ) - 1) / ((0 : ℝ) - 1))) :=
    (h1.sub tendsto_const_nhds).div (h2.sub tendsto_const_nhds) (by norm_num)
  rw [show ((0 : ℝ) - 1) / ((0 : ℝ) - 1) = 1 by norm_num] at hq
  refine hq.congr' ?_
  filter_upwards [eventually_gt_atTop (1 : ℝ)] with b hb
  exact (edgeFrac_eq b (ne_of_gt hb) ht0.le).symm

/-- The edge fraction depends continuously on the exponent (on the range `b > 1`). -/
lemma edgeFrac_continuousOn {t : ℝ} (ht0 : 0 ≤ t) :
    ContinuousOn (fun b => edgeFrac b t) (Set.Ioi (1 : ℝ)) := by
  have hcong : Set.EqOn (fun b => edgeFrac b t)
      (fun b => ((1 + t) ^ (1 - b) - 1) / ((2 : ℝ) ^ (1 - b) - 1)) (Set.Ioi 1) :=
    fun b hb => edgeFrac_eq b (ne_of_gt (Set.mem_Ioi.mp hb)) ht0
  refine ContinuousOn.congr ?_ hcong
  have c1 : Continuous fun b : ℝ => (1 + t) ^ (1 - b) :=
    (continuous_iff_continuousAt.2 fun _ =>
      Real.continuousAt_const_rpow (a := 1 + t) (ne_of_gt (by linarith))).comp (by fun_prop)
  have c2 : Continuous fun b : ℝ => (2 : ℝ) ^ (1 - b) :=
    (continuous_iff_continuousAt.2 fun _ =>
      Real.continuousAt_const_rpow (a := 2) (by norm_num)).comp (by fun_prop)
  refine ((c1.sub continuous_const).continuousOn).div
    ((c2.sub continuous_const).continuousOn) ?_
  intro b hb
  have h : (2 : ℝ) ^ (1 - b) < 1 :=
    Real.rpow_lt_one_of_one_lt_of_neg (by norm_num) (by simp only [Set.mem_Ioi] at hb; linarith)
  intro hzero
  rw [sub_eq_zero] at hzero
  linarith

/-- **A single edge-mass number cannot refute a power law.** Every value above the edge
fraction of a given law (and below `1`) is realised by a steeper law. -/
theorem exists_edgeFrac_eq {t b₀ α : ℝ} (ht0 : 0 < t) (hb₀ : 1 < b₀)
    (hα₁ : edgeFrac b₀ t < α) (hα₂ : α < 1) :
    ∃ b, b₀ < b ∧ edgeFrac b t = α := by
  obtain ⟨B, hBα, hBb₀⟩ :
      ∃ B, α < edgeFrac B t ∧ b₀ < B := by
    have h := (edgeFrac_tendsto_one ht0).eventually (eventually_gt_nhds hα₂)
    obtain ⟨B, hB⟩ := (h.and (eventually_gt_atTop b₀)).exists
    exact ⟨B, hB.1, hB.2⟩
  have hsub : Set.Icc b₀ B ⊆ Set.Ioi (1 : ℝ) := fun x hx => lt_of_lt_of_le hb₀ hx.1
  have hcont : ContinuousOn (fun b => edgeFrac b t) (Set.Icc b₀ B) :=
    (edgeFrac_continuousOn ht0.le).mono hsub
  have hmem : α ∈ Set.Icc (edgeFrac b₀ t) (edgeFrac B t) := ⟨hα₁.le, hBα.le⟩
  obtain ⟨b, hbmem, hb⟩ := intermediate_value_Icc hBb₀.le hcont hmem
  refine ⟨b, ?_, hb⟩
  rcases eq_or_lt_of_le hbmem.1 with heq | hlt
  · exact absurd (heq ▸ hb) (ne_of_lt hα₁)
  · exact hlt

/-! ## Two-component profiles -/

/-- A two-component ("flat bulk + narrow edge spike") positional profile. -/
noncomputable def twoComp (A K b₁ b₂ x : ℝ) : ℝ := A * ker b₁ x + K * ker b₂ x

/-- **Falsifiability theorem.** A genuine two-component profile is not a pure power law:
no rescaled single kernel agrees with it on the three sample points `0`, `√2-1`, `1`. -/
theorem twoComp_ne_single {A K b₁ b₂ : ℝ} (hA : 0 < A) (hK : 0 < K) (hb : b₁ ≠ b₂) :
    ¬ ∃ C b : ℝ, ∀ x ∈ Set.Icc (0 : ℝ) 1, twoComp A K b₁ b₂ x = C * ker b x := by
  rintro ⟨C, b, h⟩
  have hs2 : (1 : ℝ) < Real.sqrt 2 := by
    have : Real.sqrt 1 < Real.sqrt 2 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    simpa using this
  have hs2' : Real.sqrt 2 ≤ 2 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  set p : ℝ → ℝ := fun β => (Real.sqrt 2) ^ (-β) with hp
  have hkers : ∀ β : ℝ, ker β (Real.sqrt 2 - 1) = p β := by
    intro β; rw [ker, hp]; ring_nf
  have hker1 : ∀ β : ℝ, ker β 1 = p β * p β := by
    intro β
    rw [ker, hp, ← Real.mul_rpow (Real.sqrt_nonneg 2) (Real.sqrt_nonneg 2),
      Real.mul_self_sqrt (by norm_num)]
    norm_num
  have h0 := h 0 (by constructor <;> norm_num)
  have hmid := h (Real.sqrt 2 - 1) ⟨by linarith, by linarith⟩
  have h1 := h 1 (by constructor <;> norm_num)
  rw [twoComp, ker_zero_arg, ker_zero_arg, ker_zero_arg] at h0
  rw [twoComp, hkers, hkers, hkers] at hmid
  rw [twoComp, hker1, hker1, hker1] at h1
  have hC : A + K = C := by linarith
  have h3 : (A + K) * (A * p b₁ ^ 2 + K * p b₂ ^ 2) = (A * p b₁ + K * p b₂) ^ 2 := by
    calc (A + K) * (A * p b₁ ^ 2 + K * p b₂ ^ 2)
        = C * (A * (p b₁ * p b₁) + K * (p b₂ * p b₂)) := by rw [← hC]; ring
      _ = C * (C * (p b * p b)) := by rw [← h1]
      _ = (C * p b) * (C * p b) := by ring
      _ = (A * p b₁ + K * p b₂) * (A * p b₁ + K * p b₂) := by rw [← hmid]
      _ = (A * p b₁ + K * p b₂) ^ 2 := by ring
  have hkey : A * K * (p b₁ - p b₂) ^ 2 = 0 := by linear_combination h3
  have hsq : (p b₁ - p b₂) ^ 2 = 0 := by
    have hAK : 0 < A * K := by positivity
    rcases mul_eq_zero.mp hkey with h' | h'
    · exact absurd h' (ne_of_gt hAK)
    · exact h'
  have hpe : p b₁ = p b₂ := by
    have := (pow_eq_zero_iff (n := 2) (by norm_num)).mp hsq
    linarith
  rcases lt_trichotomy b₁ b₂ with hlt | heq | hgt
  · have : p b₂ < p b₁ := Real.rpow_lt_rpow_of_exponent_lt hs2 (by linarith)
    linarith [hpe]
  · exact hb heq
  · have : p b₁ < p b₂ := Real.rpow_lt_rpow_of_exponent_lt hs2 (by linarith)
    linarith [hpe]

/-- Mixture of the two normalised components with weight `w` on the steep one. -/
noncomputable def mixFrac (w b₁ b₂ t : ℝ) : ℝ :=
  (1 - w) * edgeFrac b₁ t + w * edgeFrac b₂ t

/-- The normalised two-component profile is exactly a two-point mixture, with the weight
given by the relative total mass of the steep component. -/
theorem twoComp_edgeFrac_eq_mix {A K b₁ b₂ t : ℝ} (hA : 0 < A) (hK : 0 < K)
    (ht0 : 0 ≤ t) :
    (∫ x in (0:ℝ)..t, twoComp A K b₁ b₂ x) / (∫ x in (0:ℝ)..1, twoComp A K b₁ b₂ x)
      = mixFrac (K * headMass b₂ 1 / (A * headMass b₁ 1 + K * headMass b₂ 1)) b₁ b₂ t := by
  have hsplit : ∀ s : ℝ, 0 ≤ s →
      (∫ x in (0:ℝ)..s, twoComp A K b₁ b₂ x) = A * headMass b₁ s + K * headMass b₂ s := by
    intro s hs
    rw [headMass, headMass, ← intervalIntegral.integral_const_mul,
      ← intervalIntegral.integral_const_mul, ← intervalIntegral.integral_add
      ((ker_int b₁ le_rfl hs).const_mul _) ((ker_int b₂ le_rfl hs).const_mul _)]
    rfl
  have hH₁ : 0 < headMass b₁ 1 := headMass_pos b₁ one_pos
  have hH₂ : 0 < headMass b₂ 1 := headMass_pos b₂ one_pos
  have hD : 0 < A * headMass b₁ 1 + K * headMass b₂ 1 := by positivity
  rw [hsplit t ht0, hsplit 1 zero_le_one, mixFrac, edgeFrac, edgeFrac]
  field_simp
  ring

/-- A spike strictly increases the edge fraction above the bulk value. -/
theorem mixFrac_gt_bulk {w b₁ b₂ t : ℝ} (hw0 : 0 < w) (hb : b₁ < b₂)
    (ht0 : 0 < t) (ht1 : t < 1) : edgeFrac b₁ t < mixFrac w b₁ b₂ t := by
  have := edgeFrac_strictMono hb ht0 ht1
  rw [mixFrac]
  nlinarith

/-- A spike keeps the edge fraction strictly below the pure-spike value. -/
theorem mixFrac_lt_spike {w b₁ b₂ t : ℝ} (hw1 : w < 1) (hb : b₁ < b₂)
    (ht0 : 0 < t) (ht1 : t < 1) : mixFrac w b₁ b₂ t < edgeFrac b₂ t := by
  have := edgeFrac_strictMono hb ht0 ht1
  rw [mixFrac]
  nlinarith

/-- **Effective-exponent inflation.** A single power law calibrated to the edge fraction of
a bulk+spike profile necessarily reports an exponent strictly steeper than the bulk. -/
theorem mix_effective_exponent_gt_bulk {w b₁ b₂ b t : ℝ} (hw0 : 0 < w)
    (hb : b₁ < b₂) (ht0 : 0 < t) (ht1 : t < 1)
    (hfit : edgeFrac b t = mixFrac w b₁ b₂ t) : b₁ < b := by
  have hgt : edgeFrac b₁ t < edgeFrac b t := by
    rw [hfit]; exact mixFrac_gt_bulk hw0 hb ht0 ht1
  rcases lt_trichotomy b₁ b with h | h | h
  · exact h
  · exact absurd (h ▸ rfl : edgeFrac b₁ t = edgeFrac b t) (ne_of_lt hgt)
  · exact absurd (edgeFrac_strictMono h ht0 ht1) (not_lt.mpr hgt.le)

/-- ... and strictly flatter than the spike: the fitted exponent is a genuine compromise. -/
theorem mix_effective_exponent_lt_spike {w b₁ b₂ b t : ℝ} (hw1 : w < 1)
    (hb : b₁ < b₂) (ht0 : 0 < t) (ht1 : t < 1)
    (hfit : edgeFrac b t = mixFrac w b₁ b₂ t) : b < b₂ := by
  have hlt : edgeFrac b t < edgeFrac b₂ t := by
    rw [hfit]; exact mixFrac_lt_spike hw1 hb ht0 ht1
  rcases lt_trichotomy b b₂ with h | h | h
  · exact h
  · exact absurd (h ▸ rfl : edgeFrac b t = edgeFrac b₂ t) (ne_of_lt hlt)
  · exact absurd (edgeFrac_strictMono h ht0 ht1) (not_lt.mpr hlt.le)

/-- **Narrow-spike limit.** As the spike sharpens, the edge fraction of the mixture tends to
`w + (1-w) · (bulk edge fraction)`: the spike weight is identified by the excess mass. -/
theorem mixFrac_tendsto_spike {w b₁ t : ℝ} (ht0 : 0 < t) :
    Tendsto (fun b₂ => mixFrac w b₁ b₂ t) atTop (𝓝 ((1 - w) * edgeFrac b₁ t + w)) := by
  have h := (tendsto_const_nhds (x := w) (f := atTop (α := ℝ))).mul (edgeFrac_tendsto_one ht0)
  simpa [mixFrac] using tendsto_const_nhds.add h

end Pythagorean.EdgeKernel