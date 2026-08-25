import Mathlib
import Catalog.NumberTheory.ProfileFormPowerLaw

/-!
# Profile form II: the mixture baseline absorbs the decline, the residual peaks

Context (experiment 579, paper 229; V2 rule).  After dividing the measured
small-`j` hit profile `T` by the mixture-Dickman baseline `M`, the residual
`R = T / M` is **not** monotone: the baseline absorbs almost all of the raw
decline (`M` falls `3.64x` where `T` falls `3.25x`) and what is left is a
concave mid-window hump, `±20 %`, with an interior vertex at `x ≈ 0.59` and end
deficits `0.80` (small-`j` wall) and `0.90`.

This file proves the two structural halves of that statement.

**Absorption.**  The mixture baseline is the uniform scale mixture of
exponential regimes,
`M x = ∫ s in 0..1, exp (-(x s)) = (1 - exp (-x)) / x`
(`dickmanMixtureBaseline_eq_mixtureIntegral`; the same mixture appears in the
catalog file `NumberTheory.ProofRegimeMixturePowerLaw`).  It is squeezed between
`1/(2x)` and `1/x` on `x ≥ 1` (`dickmanMixtureBaseline_bounds`), so the residual
`R = T / M` obeys `A x (1+x)^(-b) ≤ R x ≤ 2 A x (1+x)^(-b)`
(`residual_absorption_bounds`) and consequently declines across the window by a
factor at most `2/3` of the raw decline of `T`
(`residual_decline_le_two_thirds_raw`): the baseline really does eat the
harmonic gradient, whatever the exponent is.

**Peakedness.**  A profile that is strictly larger at an interior point than at
both ends attains its maximum in the interior and is neither monotone nor
antitone (`exists_interiorMax_of_gt_endpoints`, `not_monotoneOn_of_peak`,
`not_antitoneOn_of_peak`).  The fitted quadratic residual
`R̂(x) = 4/5 + (59/90) x - (5/9) x²` — the concave fit with the measured end
values `0.80`, `0.90` and vertex `0.59` — satisfies exactly that
(`residualFit_peak`), with hump ratios `≥ 6/5` over the left end and `≥ 11/10`
over the right end (`residualFit_hump_ratio_left`, `..._right`).

**Consequence.**  Power-law profiles are monotone on the window
(`powerProfile_antitoneOn`, `powerProfile_monotoneOn`), so the residual is *not*
of profile form (`residualFit_ne_powerProfile`); equivalently, an interior peak
in `T / M` forces `M` to be *not* a power-law rescaling of `T`
(`peak_forces_nonPowerLaw_baseline`).  The two layers are therefore separate:
the profile layer has a law, the residual layer is a genuinely new object.
-/

namespace ProfileForm

open Real Set

/-! ## The mixture-Dickman baseline -/

/-- The mixture-Dickman baseline, in closed form. -/
noncomputable def dickmanMixtureBaseline (x : ℝ) : ℝ := (1 - Real.exp (-x)) / x

/-- The baseline is the uniform scale mixture of exponential regimes. -/
theorem dickmanMixtureBaseline_eq_mixtureIntegral {x : ℝ} (hx : x ≠ 0) :
    (∫ s in (0:ℝ)..1, Real.exp (-(x * s))) = dickmanMixtureBaseline x := by
  have hderiv : ∀ s ∈ uIcc (0:ℝ) 1,
      HasDerivAt (fun s : ℝ => -Real.exp (-(x * s)) / x) (Real.exp (-(x * s))) s := by
    intro s _
    have h1 : HasDerivAt (fun s : ℝ => -(x * s)) (-x) s := by
      simpa using ((hasDerivAt_id s).const_mul x).neg
    have h2 : HasDerivAt (fun s : ℝ => Real.exp (-(x * s)))
        (Real.exp (-(x * s)) * (-x)) s := h1.exp
    have h3 := (h2.neg).div_const x
    have : -(Real.exp (-(x * s)) * -x) / x = Real.exp (-(x * s)) := by
      field_simp
    rwa [this] at h3
  have hint : IntervalIntegrable (fun s : ℝ => Real.exp (-(x * s))) MeasureTheory.volume 0 1 := by
    apply Continuous.intervalIntegrable
    fun_prop
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hint]
  simp only [dickmanMixtureBaseline, mul_zero, mul_one, neg_zero, Real.exp_zero]
  field_simp
  ring

theorem dickmanMixtureBaseline_pos {x : ℝ} (hx : 0 < x) : 0 < dickmanMixtureBaseline x := by
  have h1 : Real.exp (-x) < 1 := by
    rw [Real.exp_lt_one_iff]; linarith
  exact div_pos (by linarith) hx

/-- On the window `x ≥ 1` the baseline is squeezed between `1/(2x)` and `1/x`:
it is a `1/x`-shaped, i.e. exponent-one, decline. -/
theorem dickmanMixtureBaseline_bounds {x : ℝ} (hx : 1 ≤ x) :
    1 / (2 * x) ≤ dickmanMixtureBaseline x ∧ dickmanMixtureBaseline x ≤ 1 / x := by
  have hx0 : (0:ℝ) < x := by linarith
  have hexp1 : Real.exp (-x) ≤ Real.exp (-1) := by
    apply Real.exp_le_exp.mpr; linarith
  have he : Real.exp (-1 : ℝ) ≤ 1 / 2 := by
    have h2 : (2:ℝ) < Real.exp 1 := by
      have := Real.exp_one_gt_d9; linarith
    rw [Real.exp_neg, inv_le_comm₀ (Real.exp_pos 1) (by norm_num)]
    linarith
  have hpos : (0:ℝ) < Real.exp (-x) := Real.exp_pos _
  have hnum : (1:ℝ)/2 ≤ 1 - Real.exp (-x) := by nlinarith
  constructor
  · have hsplit : (1:ℝ) / (2 * x) = (1/2) / x := by
      field_simp
    rw [dickmanMixtureBaseline, hsplit]
    gcongr
  · rw [dickmanMixtureBaseline]
    gcongr
    linarith

/-! ## Absorption: the baseline eats the harmonic gradient -/

/-- The beyond-Dickman residual `R = T / M`. -/
noncomputable def residual (A b x : ℝ) : ℝ :=
  powerProfile A b x / dickmanMixtureBaseline x

/-- **Absorption bounds.**  On the window `x ≥ 1` the residual equals
`A x (1+x)^(-b)` up to a factor `2`: dividing by the mixture baseline turns the
exponent `b ≈ 1.1` decline into an almost flat object. -/
theorem residual_absorption_bounds {A b x : ℝ} (hA : 0 < A) (hx : 1 ≤ x) :
    A * x * (1 + x) ^ (-b) ≤ residual A b x ∧
      residual A b x ≤ 2 * (A * x * (1 + x) ^ (-b)) := by
  have hx0 : (0:ℝ) < x := by linarith
  have hb := dickmanMixtureBaseline_bounds hx
  have hMpos : 0 < dickmanMixtureBaseline x := dickmanMixtureBaseline_pos hx0
  have hTpos : 0 < powerProfile A b x := powerProfile_pos hA (by linarith)
  have hT : powerProfile A b x = A * (1 + x) ^ (-b) := rfl
  constructor
  · rw [residual, le_div_iff₀ hMpos, hT]
    have := hb.2
    have hrp : (0:ℝ) < (1 + x) ^ (-b) := Real.rpow_pos_of_pos (by linarith) _
    calc A * x * (1 + x) ^ (-b) * dickmanMixtureBaseline x
        ≤ A * x * (1 + x) ^ (-b) * (1 / x) := by
          apply mul_le_mul_of_nonneg_left hb.2 (by positivity)
      _ = A * (1 + x) ^ (-b) := by field_simp
  · rw [residual, div_le_iff₀ hMpos, hT]
    have hrp : (0:ℝ) < (1 + x) ^ (-b) := Real.rpow_pos_of_pos (by linarith) _
    calc A * (1 + x) ^ (-b)
        = 2 * (A * x * (1 + x) ^ (-b)) * (1 / (2 * x)) := by field_simp
      _ ≤ 2 * (A * x * (1 + x) ^ (-b)) * dickmanMixtureBaseline x := by
          apply mul_le_mul_of_nonneg_left hb.1 (by positivity)

/-- **The mixture absorbs the decline.**  Across the window `[1,3]` the residual
declines by at most two thirds of the raw decline of the profile — for every
amplitude and every exponent. -/
theorem residual_decline_le_two_thirds_raw {A b : ℝ} (hA : 0 < A) :
    residual A b 1 / residual A b 3 ≤
      (2 / 3) * (powerProfile A b 1 / powerProfile A b 3) := by
  have h1 := residual_absorption_bounds (A := A) (b := b) (x := 1) hA le_rfl
  have h3 := residual_absorption_bounds (A := A) (b := b) (x := 3) hA (by norm_num)
  have hp1 : (0:ℝ) < (1 + (1:ℝ)) ^ (-b) := Real.rpow_pos_of_pos (by norm_num) _
  have hp3 : (0:ℝ) < (1 + (3:ℝ)) ^ (-b) := Real.rpow_pos_of_pos (by norm_num) _
  have hR3pos : 0 < residual A b 3 := by
    have : (0:ℝ) < A * 3 * (1 + 3) ^ (-b) := by positivity
    linarith [h3.1]
  have hR1le : residual A b 1 ≤ 2 * (A * 1 * (1 + 1) ^ (-b)) := h1.2
  have hR3ge : A * 3 * (1 + 3) ^ (-b) ≤ residual A b 3 := h3.1
  have hT1 : powerProfile A b 1 = A * (1 + 1) ^ (-b) := rfl
  have hT3 : powerProfile A b 3 = A * (1 + 3) ^ (-b) := rfl
  rw [div_le_iff₀ hR3pos, hT1, hT3]
  have hexpand : 2 / 3 * (A * (1 + 1) ^ (-b) / (A * (1 + 3) ^ (-b))) * residual A b 3
      = (2 * (A * 1 * (1 + 1) ^ (-b))) * (residual A b 3 / (A * 3 * (1 + 3) ^ (-b))) := by
    field_simp
  rw [hexpand]
  have hratio : 1 ≤ residual A b 3 / (A * 3 * (1 + 3) ^ (-b)) := by
    rw [le_div_iff₀ (by positivity)]
    linarith
  have hK : (0:ℝ) ≤ 2 * (A * 1 * (1 + 1) ^ (-b)) := by positivity
  have hmul := mul_le_mul_of_nonneg_left hratio hK
  rw [mul_one] at hmul
  exact le_trans hR1le hmul

/-! ## Peakedness: a general criterion -/

/-- A profile that beats both endpoint values at an interior point attains its
maximum in the interior. -/
theorem exists_interiorMax_of_gt_endpoints {f : ℝ → ℝ} {c : ℝ}
    (hf : ContinuousOn f (Icc (0:ℝ) 1)) (hc : c ∈ Ioo (0:ℝ) 1)
    (h0 : f 0 < f c) (h1 : f 1 < f c) :
    ∃ m ∈ Ioo (0:ℝ) 1, IsMaxOn f (Icc (0:ℝ) 1) m := by
  obtain ⟨m, hm, hmax⟩ := (isCompact_Icc (a := (0:ℝ)) (b := 1)).exists_isMaxOn
    (Set.nonempty_Icc.mpr zero_le_one) hf
  have hcmem : c ∈ Icc (0:ℝ) 1 := Ioo_subset_Icc_self hc
  have hfc : f c ≤ f m := hmax hcmem
  refine ⟨m, ⟨?_, ?_⟩, hmax⟩
  · rcases lt_or_eq_of_le hm.1 with h | h
    · exact h
    · exfalso; rw [← h] at hfc; linarith
  · rcases lt_or_eq_of_le hm.2 with h | h
    · exact h
    · exfalso; rw [h] at hfc; linarith

theorem not_monotoneOn_of_peak {f : ℝ → ℝ} {c : ℝ} (hc : c ∈ Ioo (0:ℝ) 1)
    (h1 : f 1 < f c) : ¬ MonotoneOn f (Icc (0:ℝ) 1) := by
  intro hmono
  have := hmono (Ioo_subset_Icc_self hc) (right_mem_Icc.mpr zero_le_one) hc.2.le
  linarith

theorem not_antitoneOn_of_peak {f : ℝ → ℝ} {c : ℝ} (hc : c ∈ Ioo (0:ℝ) 1)
    (h0 : f 0 < f c) : ¬ AntitoneOn f (Icc (0:ℝ) 1) := by
  intro hanti
  have := hanti (left_mem_Icc.mpr zero_le_one) (Ioo_subset_Icc_self hc) hc.1.le
  linarith

/-! ## The fitted residual: a concave interior hump -/

/-- The fitted beyond-Dickman residual: the concave quadratic with the measured
end deficits `R̂(0) = 0.80`, `R̂(1) = 0.90` and interior vertex `x = 0.59`. -/
noncomputable def residualFit (x : ℝ) : ℝ := 4/5 + (59/90) * x - (5/9) * x ^ 2

@[simp] theorem residualFit_zero : residualFit 0 = 4/5 := by norm_num [residualFit]

@[simp] theorem residualFit_one : residualFit 1 = 9/10 := by norm_num [residualFit]

theorem residualFit_vertex_value : residualFit (59/100) = 17881/18000 := by
  norm_num [residualFit]

/-- Exact concavity identity: the deficit from the vertex is a perfect square. -/
theorem residualFit_vertex_identity (x : ℝ) :
    residualFit (59/100) - residualFit x = (5/9) * (x - 59/100) ^ 2 := by
  simp only [residualFit]; ring

/-- The vertex is the strict global maximum. -/
theorem residualFit_lt_vertex {x : ℝ} (hx : x ≠ 59/100) :
    residualFit x < residualFit (59/100) := by
  have h := residualFit_vertex_identity x
  have hsq : 0 < (x - 59/100) ^ 2 := by
    have : x - 59/100 ≠ 0 := sub_ne_zero.mpr hx
    positivity
  nlinarith

theorem residualFit_le_vertex (x : ℝ) : residualFit x ≤ residualFit (59/100) := by
  rcases eq_or_ne x (59/100) with h | h
  · rw [h]
  · exact (residualFit_lt_vertex h).le

/-- The peak sits `≥ 20 %` above the small-`j` wall end value. -/
theorem residualFit_hump_ratio_left : (6/5) * residualFit 0 ≤ residualFit (59/100) := by
  rw [residualFit_zero, residualFit_vertex_value]; norm_num

/-- The peak sits `≥ 10 %` above the far end value. -/
theorem residualFit_hump_ratio_right : (11/10) * residualFit 1 ≤ residualFit (59/100) := by
  rw [residualFit_one, residualFit_vertex_value]; norm_num

/-- Both ends are deficits: the model over-predicts at the wall and at the far
end of the window. -/
theorem residualFit_endpoints_lt_one : residualFit 0 < 1 ∧ residualFit 1 < 1 := by
  constructor <;> norm_num [residualFit]

/-- **The residual is peaked, not monotone.** -/
theorem residualFit_peak :
    (∃ m ∈ Ioo (0:ℝ) 1, IsMaxOn residualFit (Icc (0:ℝ) 1) m) ∧
      ¬ MonotoneOn residualFit (Icc (0:ℝ) 1) ∧
      ¬ AntitoneOn residualFit (Icc (0:ℝ) 1) := by
  have hc : (59/100 : ℝ) ∈ Ioo (0:ℝ) 1 := by constructor <;> norm_num
  have h0 : residualFit 0 < residualFit (59/100) := residualFit_lt_vertex (by norm_num)
  have h1 : residualFit 1 < residualFit (59/100) := residualFit_lt_vertex (by norm_num)
  have hcont : ContinuousOn residualFit (Icc (0:ℝ) 1) := by
    apply Continuous.continuousOn
    unfold residualFit
    fun_prop
  exact ⟨exists_interiorMax_of_gt_endpoints hcont hc h0 h1,
    not_monotoneOn_of_peak hc h1, not_antitoneOn_of_peak hc h0⟩

/-! ## The residual is not of profile form -/

theorem powerProfile_antitoneOn {A b : ℝ} (hA : 0 < A) (hb : 0 ≤ b) :
    AntitoneOn (powerProfile A b) (Icc (0:ℝ) 1) := by
  intro x hx y hy hxy
  have hx0 : (0:ℝ) < 1 + x := by have := hx.1; linarith
  simp only [powerProfile]
  apply mul_le_mul_of_nonneg_left _ hA.le
  exact Real.rpow_le_rpow_of_nonpos hx0 (by linarith) (by linarith)

theorem powerProfile_monotoneOn {A b : ℝ} (hA : 0 < A) (hb : b ≤ 0) :
    MonotoneOn (powerProfile A b) (Icc (0:ℝ) 1) := by
  intro x hx y hy hxy
  have hx0 : (0:ℝ) < 1 + x := by have := hx.1; linarith
  simp only [powerProfile]
  apply mul_le_mul_of_nonneg_left _ hA.le
  exact Real.rpow_le_rpow hx0.le (by linarith) (by linarith)

/-- **Layer separation.**  The peaked residual is not itself a power-law
profile: no amplitude and exponent reproduce it on the window. -/
theorem residualFit_ne_powerProfile {A b : ℝ} (hA : 0 < A) :
    ¬ ∀ x ∈ Icc (0:ℝ) 1, residualFit x = powerProfile A b x := by
  intro h
  have hpeak := residualFit_peak
  rcases le_or_gt 0 b with hb | hb
  · refine hpeak.2.2 ?_
    intro x hx y hy hxy
    rw [h x hx, h y hy]
    exact powerProfile_antitoneOn hA hb hx hy hxy
  · refine hpeak.2.1 ?_
    intro x hx y hy hxy
    rw [h x hx, h y hy]
    exact powerProfile_monotoneOn hA hb.le hx hy hxy

/-- **An interior peak in `T / M` rules out a power-law baseline.**  If the
baseline were a power-law rescaling of the profile, the residual would be a
power law, hence monotone on the window; the measured interior hump therefore
certifies that the beyond-Dickman layer is genuinely new. -/
theorem peak_forces_nonPowerLaw_baseline {M : ℝ → ℝ} {A b : ℝ} {c : ℝ}
    (hA : 0 < A) (hc : c ∈ Ioo (0:ℝ) 1)
    (hpeak0 : M 0 < M c) (hpeak1 : M 1 < M c) :
    ¬ ∀ x ∈ Icc (0:ℝ) 1, M x = powerProfile A b x := by
  intro h
  rcases le_or_gt 0 b with hb | hb
  · refine not_antitoneOn_of_peak hc hpeak0 ?_
    intro x hx y hy hxy
    rw [h x hx, h y hy]
    exact powerProfile_antitoneOn hA hb hx hy hxy
  · refine not_monotoneOn_of_peak hc hpeak1 ?_
    intro x hx y hy hxy
    rw [h x hx, h y hy]
    exact powerProfile_monotoneOn hA hb.le hx hy hxy

end ProfileForm