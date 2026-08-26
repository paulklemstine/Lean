import Mathlib
import Computation.SpectralUnfoldingGapStatistics

/-!
# Poisson versus GUE gap statistics, and where the unfolded quadratic spectrum sits

Building on `Computation.SpectralUnfoldingGapStatistics`, this file formalizes the two
universality classes of nearest-neighbour spacing distributions used to classify
spectra after unfolding, and proves that the unfolded deterministic quadratic
spectrum belongs to neither.

* `poissonGapPdf s = exp (-s)` — uncorrelated (integrable / Poisson) levels;
* `gueGapPdf s = (32/π²) s² exp (-(4/π) s²)` — the Wigner surmise for the GUE (β = 2).

Main results.

* `poisson_pdf_integral_one`, `poisson_pdf_mean_one`,
  `gue_pdf_integral_one`, `gue_pdf_mean_one` : both are genuine probability
  densities on `(0,∞)` **with mean spacing one**, i.e. both are already unfolded.
  The GUE computations rest on the two Gaussian moment integrals
  `integral_sq_mul_gaussian` and `integral_cube_mul_gaussian`, proved here from the
  fundamental theorem of calculus on `(0,∞)`.
* `gue_level_repulsion` : quadratic level repulsion — on `(0, 1/4]` the GUE density
  is strictly below the Poisson density.
* `gue_ne_poisson_rescaled` : no rescaling of the GUE surmise is the Poisson density;
  the two classes are genuinely different, not related by a change of units.
* `poisson_small_gap_prob_pos`, `gue_small_gap_prob_pos` : both classes put positive
  mass on arbitrarily small spacings, whereas
  `unfoldedQuad_no_small_gaps` : the unfolded quadratic spectrum has *no* spacing
  below `1`.  Hence the deterministic quadratic spectrum is neither Poisson nor GUE:
  it is rigid.
-/

namespace Catalog.Computation.SpectralPoissonGUE

open Real MeasureTheory Set Filter
open scoped Topology

/-! ## Two Gaussian moment integrals -/

lemma tendsto_pow_mul_gaussian {b : ℝ} (hb : 0 < b) (k : ℕ) :
    Tendsto (fun x : ℝ => x ^ k * Real.exp (-b * x ^ 2)) atTop (𝓝 0) := by
  have hdiv : Tendsto (fun x : ℝ => x / 2) atTop atTop :=
    tendsto_id.atTop_div_const (by norm_num)
  have hexp : Tendsto (fun x : ℝ => Real.exp (-(1 / 2) * x)) atTop (𝓝 0) := by
    refine (tendsto_exp_neg_atTop_nhds_zero.comp hdiv).congr fun x => ?_
    simp only [Function.comp_apply]
    rw [show -(x / 2) = -(1 / 2) * x by ring]
  have h := (rpow_mul_exp_neg_mul_sq_isLittleO_exp_neg hb (k : ℝ)).tendsto_zero_of_tendsto hexp
  refine h.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x _
  rw [Real.rpow_natCast]

lemma integrableOn_pow_mul_gaussian {b : ℝ} (hb : 0 < b) (k : ℕ) :
    IntegrableOn (fun x : ℝ => x ^ k * Real.exp (-b * x ^ 2)) (Ioi 0) := by
  have h := integrableOn_rpow_mul_exp_neg_mul_sq hb
    (s := (k : ℝ)) (by exact_mod_cast Nat.cast_nonneg' k |>.trans_lt' (by norm_num))
  refine h.congr_fun (fun x hx => ?_) measurableSet_Ioi
  rw [Real.rpow_natCast]

/-- `∫₀^∞ x³ e^{-b x²} dx = 1/(2b²)`. -/
lemma integral_cube_mul_gaussian {b : ℝ} (hb : 0 < b) :
    ∫ x in Ioi (0 : ℝ), x ^ 3 * Real.exp (-b * x ^ 2) = 1 / (2 * b ^ 2) := by
  have hb' : b ≠ 0 := ne_of_gt hb
  set F : ℝ → ℝ := fun x => -(x ^ 2 / (2 * b) + 1 / (2 * b ^ 2)) * Real.exp (-b * x ^ 2) with hF
  have hderiv : ∀ x ∈ Ici (0 : ℝ), HasDerivAt F (x ^ 3 * Real.exp (-b * x ^ 2)) x := by
    intro x _
    have h1 : HasDerivAt (fun y : ℝ => -(y ^ 2 / (2 * b) + 1 / (2 * b ^ 2)))
        (-(2 * x ^ 1 / (2 * b))) x :=
      (((hasDerivAt_pow 2 x).div_const (2 * b)).add_const (1 / (2 * b ^ 2))).neg
    have h2 : HasDerivAt (fun y : ℝ => Real.exp (-b * y ^ 2))
        (Real.exp (-b * x ^ 2) * (-b * (2 * x ^ 1))) x :=
      (((hasDerivAt_pow 2 x).const_mul (-b))).exp
    have := h1.mul h2
    convert this using 1
    field_simp
    ring
  have hint : IntegrableOn (fun x : ℝ => x ^ 3 * Real.exp (-b * x ^ 2)) (Ioi 0) :=
    integrableOn_pow_mul_gaussian hb 3
  have hlim : Tendsto F atTop (𝓝 0) := by
    have e1 := (tendsto_pow_mul_gaussian hb 2).const_mul (-(1 / (2 * b)))
    have e2 := (tendsto_pow_mul_gaussian hb 0).const_mul (-(1 / (2 * b ^ 2)))
    have e3 := e1.add e2
    rw [mul_zero, mul_zero, add_zero] at e3
    refine e3.congr fun x => ?_
    simp only [hF]
    ring
  have hres := integral_Ioi_of_hasDerivAt_of_tendsto' hderiv hint hlim
  rw [hres, hF]
  simp

/-- `∫₀^∞ x² e^{-b x²} dx = √(π/b)/(4b)`. -/
lemma integral_sq_mul_gaussian {b : ℝ} (hb : 0 < b) :
    ∫ x in Ioi (0 : ℝ), x ^ 2 * Real.exp (-b * x ^ 2) = Real.sqrt (π / b) / (4 * b) := by
  have hb' : b ≠ 0 := ne_of_gt hb
  set G : ℝ → ℝ := fun x => -(x / (2 * b)) * Real.exp (-b * x ^ 2) with hG
  have hderiv : ∀ x ∈ Ici (0 : ℝ),
      HasDerivAt G (x ^ 2 * Real.exp (-b * x ^ 2)
        - (1 / (2 * b)) * Real.exp (-b * x ^ 2)) x := by
    intro x _
    have h1 : HasDerivAt (fun y : ℝ => -(y / (2 * b))) (-(1 / (2 * b))) x := by
      simpa using ((hasDerivAt_id x).div_const (2 * b)).neg
    have h2 : HasDerivAt (fun y : ℝ => Real.exp (-b * y ^ 2))
        (Real.exp (-b * x ^ 2) * (-b * (2 * x ^ 1))) x :=
      (((hasDerivAt_pow 2 x).const_mul (-b))).exp
    have := h1.mul h2
    convert this using 1
    field_simp
    ring
  have hint2 : IntegrableOn (fun x : ℝ => x ^ 2 * Real.exp (-b * x ^ 2)) (Ioi 0) :=
    integrableOn_pow_mul_gaussian hb 2
  have hint0 : IntegrableOn (fun x : ℝ => Real.exp (-b * x ^ 2)) (Ioi 0) := by
    have := integrableOn_pow_mul_gaussian hb 0
    simpa using this
  have hintc : IntegrableOn (fun x : ℝ => (1 / (2 * b)) * Real.exp (-b * x ^ 2)) (Ioi 0) :=
    hint0.const_mul _
  have hint : IntegrableOn (fun x : ℝ => x ^ 2 * Real.exp (-b * x ^ 2)
      - (1 / (2 * b)) * Real.exp (-b * x ^ 2)) (Ioi 0) := hint2.sub hintc
  have hlim : Tendsto G atTop (𝓝 0) := by
    have e1 := (tendsto_pow_mul_gaussian hb 1).const_mul (-(1 / (2 * b)))
    rw [mul_zero] at e1
    refine e1.congr fun x => ?_
    simp only [hG]
    ring
  have hzero := integral_Ioi_of_hasDerivAt_of_tendsto' hderiv hint hlim
  have hG0 : G 0 = 0 := by simp only [hG]; simp
  rw [hG0, sub_zero] at hzero
  rw [MeasureTheory.integral_sub hint2 hintc] at hzero
  rw [MeasureTheory.integral_const_mul, integral_gaussian_Ioi] at hzero
  have : ∫ x in Ioi (0 : ℝ), x ^ 2 * Real.exp (-b * x ^ 2)
      = (1 / (2 * b)) * (Real.sqrt (π / b) / 2) := by linarith
  rw [this]
  field_simp
  ring

/-- `∫₀^∞ x⁴ e^{-b x²} dx = 3√(π/b)/(8b²)`. -/
lemma integral_pow4_mul_gaussian {b : ℝ} (hb : 0 < b) :
    ∫ x in Ioi (0 : ℝ), x ^ 4 * Real.exp (-b * x ^ 2)
      = 3 * Real.sqrt (π / b) / (8 * b ^ 2) := by
  have hb' : b ≠ 0 := ne_of_gt hb
  set H : ℝ → ℝ := fun x => -(x ^ 3 / (2 * b) + 3 * x / (4 * b ^ 2)) * Real.exp (-b * x ^ 2)
    with hH
  have hderiv : ∀ x ∈ Ici (0 : ℝ),
      HasDerivAt H (x ^ 4 * Real.exp (-b * x ^ 2)
        - (3 / (4 * b ^ 2)) * Real.exp (-b * x ^ 2)) x := by
    intro x _
    have h1 : HasDerivAt (fun y : ℝ => -(y ^ 3 / (2 * b) + 3 * y / (4 * b ^ 2)))
        (-(3 * x ^ 2 / (2 * b) + 3 / (4 * b ^ 2))) x := by
      have ha : HasDerivAt (fun y : ℝ => y ^ 3 / (2 * b)) (3 * x ^ 2 / (2 * b)) x := by
        simpa using (hasDerivAt_pow 3 x).div_const (2 * b)
      have hbb : HasDerivAt (fun y : ℝ => 3 * y / (4 * b ^ 2)) (3 / (4 * b ^ 2)) x := by
        simpa using ((hasDerivAt_id x).const_mul (3 : ℝ)).div_const (4 * b ^ 2)
      simpa using (ha.add hbb).neg
    have h2 : HasDerivAt (fun y : ℝ => Real.exp (-b * y ^ 2))
        (Real.exp (-b * x ^ 2) * (-b * (2 * x ^ 1))) x :=
      (((hasDerivAt_pow 2 x).const_mul (-b))).exp
    have hmul := h1.mul h2
    convert hmul using 1
    field_simp
    ring
  have hint4 : IntegrableOn (fun x : ℝ => x ^ 4 * Real.exp (-b * x ^ 2)) (Ioi 0) :=
    integrableOn_pow_mul_gaussian hb 4
  have hint0 : IntegrableOn (fun x : ℝ => Real.exp (-b * x ^ 2)) (Ioi 0) := by
    have := integrableOn_pow_mul_gaussian hb 0
    simpa using this
  have hintc : IntegrableOn (fun x : ℝ => (3 / (4 * b ^ 2)) * Real.exp (-b * x ^ 2)) (Ioi 0) :=
    hint0.const_mul _
  have hint : IntegrableOn (fun x : ℝ => x ^ 4 * Real.exp (-b * x ^ 2)
      - (3 / (4 * b ^ 2)) * Real.exp (-b * x ^ 2)) (Ioi 0) := hint4.sub hintc
  have hlim : Tendsto H atTop (𝓝 0) := by
    have e1 := (tendsto_pow_mul_gaussian hb 3).const_mul (-(1 / (2 * b)))
    have e2 := (tendsto_pow_mul_gaussian hb 1).const_mul (-(3 / (4 * b ^ 2)))
    have e3 := e1.add e2
    rw [mul_zero, mul_zero, add_zero] at e3
    refine e3.congr fun x => ?_
    simp only [hH]
    ring
  have hzero := integral_Ioi_of_hasDerivAt_of_tendsto' hderiv hint hlim
  have hH0 : H 0 = 0 := by simp only [hH]; simp
  rw [hH0, sub_zero] at hzero
  rw [MeasureTheory.integral_sub hint4 hintc] at hzero
  rw [MeasureTheory.integral_const_mul, integral_gaussian_Ioi] at hzero
  have hval : ∫ x in Ioi (0 : ℝ), x ^ 4 * Real.exp (-b * x ^ 2)
      = (3 / (4 * b ^ 2)) * (Real.sqrt (π / b) / 2) := by linarith
  rw [hval]
  field_simp
  ring

/-! ## The two universality classes -/

/-- Poisson (uncorrelated levels) nearest-neighbour spacing density. -/
noncomputable def poissonGapPdf (s : ℝ) : ℝ := Real.exp (-s)

/-- The Wigner surmise for the GUE (`β = 2`) nearest-neighbour spacing density. -/
noncomputable def gueGapPdf (s : ℝ) : ℝ := 32 / π ^ 2 * s ^ 2 * Real.exp (-(4 / π) * s ^ 2)

lemma gueGapPdf_nonneg (s : ℝ) : 0 ≤ gueGapPdf s := by
  have hpi : 0 < π := Real.pi_pos
  unfold gueGapPdf
  positivity

lemma poissonGapPdf_pos (s : ℝ) : 0 < poissonGapPdf s := Real.exp_pos _

/-- The Poisson density is normalized. -/
theorem poisson_pdf_integral_one : ∫ s in Ioi (0 : ℝ), poissonGapPdf s = 1 := by
  unfold poissonGapPdf
  rw [integral_exp_neg_Ioi]
  simp

/-- The Poisson density has mean spacing one. -/
theorem poisson_pdf_mean_one : ∫ s in Ioi (0 : ℝ), s * poissonGapPdf s = 1 := by
  have hΓ : Real.Gamma 2 = ∫ x in Ioi (0 : ℝ), Real.exp (-x) * x ^ (2 - 1 : ℝ) :=
    Real.Gamma_eq_integral (show (0 : ℝ) < 2 by norm_num)
  have h2 : Real.Gamma 2 = 1 := by
    have hcast : (2 : ℝ) = ((1 : ℕ) + 1) := by norm_num
    rw [hcast, Real.Gamma_nat_eq_factorial]
    norm_num
  have heq : ∫ s in Ioi (0 : ℝ), s * poissonGapPdf s
      = ∫ x in Ioi (0 : ℝ), Real.exp (-x) * x ^ (2 - 1 : ℝ) := by
    refine setIntegral_congr_fun measurableSet_Ioi fun x _ => ?_
    simp only [poissonGapPdf]
    rw [show (2 - 1 : ℝ) = ((1 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
    ring
  rw [heq, ← hΓ, h2]

/-- The GUE (Wigner surmise) density is normalized. -/
theorem gue_pdf_integral_one : ∫ s in Ioi (0 : ℝ), gueGapPdf s = 1 := by
  have hpi : 0 < π := Real.pi_pos
  have hb : 0 < 4 / π := by positivity
  have hrewrite : ∀ s : ℝ, gueGapPdf s = (32 / π ^ 2) * (s ^ 2 * Real.exp (-(4 / π) * s ^ 2)) := by
    intro s; rw [gueGapPdf]; ring
  simp only [hrewrite]
  rw [MeasureTheory.integral_const_mul, integral_sq_mul_gaussian hb]
  have hsq : Real.sqrt (π / (4 / π)) = π / 2 := by
    have : π / (4 / π) = (π / 2) ^ 2 := by field_simp; ring
    rw [this, Real.sqrt_sq (by positivity)]
  rw [hsq]
  field_simp
  ring

/-- The GUE (Wigner surmise) density has mean spacing one: it is already unfolded. -/
theorem gue_pdf_mean_one : ∫ s in Ioi (0 : ℝ), s * gueGapPdf s = 1 := by
  have hpi : 0 < π := Real.pi_pos
  have hb : 0 < 4 / π := by positivity
  have hrewrite : ∀ s : ℝ,
      s * gueGapPdf s = (32 / π ^ 2) * (s ^ 3 * Real.exp (-(4 / π) * s ^ 2)) := by
    intro s; rw [gueGapPdf]; ring
  simp only [hrewrite]
  rw [MeasureTheory.integral_const_mul, integral_cube_mul_gaussian hb]
  field_simp
  ring

/-! ## Level repulsion: GUE ≠ Poisson -/

/-- **Quadratic level repulsion.**  On `(0, 1/4]` the GUE spacing density is strictly
smaller than the Poisson one: small spacings are suppressed. -/
theorem gue_level_repulsion (s : ℝ) (hs0 : 0 < s) (hs : s ≤ 1 / 4) :
    gueGapPdf s < poissonGapPdf s := by
  have hpi : (3.14 : ℝ) < π := Real.pi_gt_d2
  have hexp1 : Real.exp (-(4 / π) * s ^ 2) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    have : 0 < 4 / π := by positivity
    nlinarith [sq_nonneg s]
  have hexp2 : 1 - s ≤ Real.exp (-s) := by
    have := Real.add_one_le_exp (-s)
    linarith
  have hcoef : 32 / π ^ 2 * s ^ 2 ≤ 32 / (3.14 : ℝ) ^ 2 * s ^ 2 := by
    have h1 : (3.14 : ℝ) ^ 2 ≤ π ^ 2 := by nlinarith
    have h2 : 0 < (3.14 : ℝ) ^ 2 := by norm_num
    have := div_le_div_of_nonneg_left (by norm_num : (0:ℝ) ≤ 32) h2 h1
    nlinarith [sq_nonneg s]
  have hs2 : s ^ 2 ≤ s / 4 := by nlinarith
  calc gueGapPdf s = (32 / π ^ 2 * s ^ 2) * Real.exp (-(4 / π) * s ^ 2) := by
        rw [gueGapPdf]
    _ ≤ (32 / π ^ 2 * s ^ 2) * 1 := by
        apply mul_le_mul_of_nonneg_left hexp1
        have : 0 < π := Real.pi_pos
        positivity
    _ = 32 / π ^ 2 * s ^ 2 := by ring
    _ ≤ 32 / (3.14 : ℝ) ^ 2 * s ^ 2 := hcoef
    _ < 1 - s := by nlinarith
    _ ≤ Real.exp (-s) := hexp2
    _ = poissonGapPdf s := rfl

/-- **The two universality classes are not related by a change of scale.**  For every
`c > 0` the rescaled GUE surmise `s ↦ c · p_GUE(c s)` differs from the Poisson density
at some point: GUE statistics cannot be produced from Poisson statistics by unfolding. -/
theorem gue_ne_poisson_rescaled (c : ℝ) (hc : 0 < c) :
    ∃ s : ℝ, 0 < s ∧ c * gueGapPdf (c * s) ≠ poissonGapPdf s := by
  have hpi : (3.14 : ℝ) < π := Real.pi_gt_d2
  refine ⟨min (1 / 2) (1 / (8 * (1 + c) ^ 3)), ?_, ?_⟩
  · have : 0 < 1 / (8 * (1 + c) ^ 3) := by positivity
    exact lt_min (by norm_num) this
  · set s : ℝ := min (1 / 2) (1 / (8 * (1 + c) ^ 3)) with hs
    have hs0 : 0 < s := lt_min (by norm_num) (by positivity)
    have hs1 : s ≤ 1 / 2 := min_le_left _ _
    have hs2 : s ≤ 1 / (8 * (1 + c) ^ 3) := min_le_right _ _
    have hexp : Real.exp (-(4 / π) * (c * s) ^ 2) ≤ 1 := by
      apply Real.exp_le_one_iff.mpr
      have : 0 < 4 / π := by positivity
      nlinarith [sq_nonneg (c * s)]
    have hupper : c * gueGapPdf (c * s) ≤ 4 * c ^ 3 * s ^ 2 := by
      have hcoef : 32 / π ^ 2 ≤ 4 := by
        have h1 : (9 : ℝ) ≤ π ^ 2 := by nlinarith
        rw [div_le_iff₀ (by positivity)]
        linarith
      calc c * gueGapPdf (c * s)
          = (c * (32 / π ^ 2) * (c * s) ^ 2) * Real.exp (-(4 / π) * (c * s) ^ 2) := by
            rw [gueGapPdf]; ring
        _ ≤ (c * (32 / π ^ 2) * (c * s) ^ 2) * 1 := by
            apply mul_le_mul_of_nonneg_left hexp
            have : 0 < π := Real.pi_pos
            positivity
        _ = c ^ 3 * s ^ 2 * (32 / π ^ 2) := by ring
        _ ≤ c ^ 3 * s ^ 2 * 4 :=
            mul_le_mul_of_nonneg_left hcoef (by positivity)
        _ = 4 * c ^ 3 * s ^ 2 := by ring
    have hsmall : 4 * c ^ 3 * s ^ 2 ≤ s / 2 := by
      have hc3 : c ^ 3 ≤ (1 + c) ^ 3 := by nlinarith [sq_nonneg c, hc.le]
      have hden : 0 < 8 * (1 + c) ^ 3 := by positivity
      have hkey : s * (8 * (1 + c) ^ 3) ≤ 1 := by
        rw [← le_div_iff₀ hden]
        exact hs2
      nlinarith [hs0.le, sq_nonneg s]
    have hlower : 1 / 2 ≤ poissonGapPdf s := by
      have h1 : 1 - s ≤ Real.exp (-s) := by
        have := Real.add_one_le_exp (-s)
        linarith
      rw [poissonGapPdf]
      linarith
    intro hcon
    rw [hcon] at hupper
    linarith

/-! ## Small-gap probabilities: the rigid picket fence is in neither class -/

/-- The Poisson spacing CDF: `∫₀^t e^{-s} ds = 1 - e^{-t}`. -/
theorem poisson_cdf_eq (t : ℝ) (ht : 0 ≤ t) :
    ∫ s in Ioc (0 : ℝ) t, poissonGapPdf s = 1 - Real.exp (-t) := by
  simp only [poissonGapPdf]
  rw [← intervalIntegral.integral_of_le ht]
  have hftc : ∫ s in (0 : ℝ)..t, Real.exp (-s) = -Real.exp (-t) - (-Real.exp (-0)) := by
    apply intervalIntegral.integral_eq_sub_of_hasDerivAt
    · intro x _
      simpa using ((hasDerivAt_neg x).exp).neg
    · exact Continuous.intervalIntegrable (by fun_prop) _ _
  rw [hftc]
  simp only [neg_zero, Real.exp_zero]
  ring

/-- Poisson statistics put positive mass on spacings below any `t > 0`. -/
theorem poisson_small_gap_prob_pos (t : ℝ) (ht : 0 < t) :
    0 < ∫ s in Ioc (0 : ℝ) t, poissonGapPdf s := by
  rw [poisson_cdf_eq t ht.le]
  have : Real.exp (-t) < 1 := by
    rw [Real.exp_lt_one_iff]
    linarith
  linarith

/-- GUE statistics also put positive mass on spacings below any `t > 0` (level repulsion
suppresses, but does not forbid, small spacings). -/
theorem gue_small_gap_prob_pos (t : ℝ) (ht : 0 < t) :
    0 < ∫ s in Ioc (0 : ℝ) t, gueGapPdf s := by
  have hpi : 0 < π := Real.pi_pos
  have hb : 0 < 4 / π := by positivity
  have hcont : Continuous gueGapPdf := by
    unfold gueGapPdf
    fun_prop
  have hint : IntervalIntegrable gueGapPdf volume 0 t :=
    hcont.intervalIntegrable _ _
  rw [← intervalIntegral.integral_of_le ht.le]
  apply intervalIntegral.intervalIntegral_pos_of_pos_on hint
  · intro x hx
    have hx0 : 0 < x := hx.1
    unfold gueGapPdf
    have := Real.exp_pos (-(4 / π) * x ^ 2)
    positivity
  · exact ht

open Catalog.Computation.SpectralUnfolding in
/-- **The unfolded deterministic quadratic spectrum is neither Poisson nor GUE.**  It has
no spacing below `1` at all, while both universality classes assign positive probability
to spacings below any positive threshold. -/
theorem unfoldedQuad_no_small_gaps (n : ℕ) (hn : 0 < n) (t : ℝ) (ht : t < 1) :
    gapCDF unfoldedQuad n t = 0 ∧ 0 < ∫ s in Ioc (0 : ℝ) (1 / 2), poissonGapPdf s
      ∧ 0 < ∫ s in Ioc (0 : ℝ) (1 / 2), gueGapPdf s :=
  ⟨unfoldedQuad_gapCDF_eq_zero n hn t ht,
    poisson_small_gap_prob_pos _ (by norm_num),
    gue_small_gap_prob_pos _ (by norm_num)⟩

/-! ## The spacing variance separates rigid, GUE and Poisson statistics -/

/-- Second moment of the Poisson spacing density: `∫₀^∞ s² e^{-s} ds = 2`. -/
theorem poisson_pdf_second_moment : ∫ s in Ioi (0 : ℝ), s ^ 2 * poissonGapPdf s = 2 := by
  have hΓ : Real.Gamma 3 = ∫ x in Ioi (0 : ℝ), Real.exp (-x) * x ^ (3 - 1 : ℝ) :=
    Real.Gamma_eq_integral (show (0 : ℝ) < 3 by norm_num)
  have h3 : Real.Gamma 3 = 2 := by
    have hcast : (3 : ℝ) = ((2 : ℕ) + 1) := by norm_num
    rw [hcast, Real.Gamma_nat_eq_factorial]
    norm_num
  have heq : ∫ s in Ioi (0 : ℝ), s ^ 2 * poissonGapPdf s
      = ∫ x in Ioi (0 : ℝ), Real.exp (-x) * x ^ (3 - 1 : ℝ) := by
    refine setIntegral_congr_fun measurableSet_Ioi fun x _ => ?_
    simp only [poissonGapPdf]
    rw [show (3 - 1 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
    ring
  rw [heq, ← hΓ, h3]

/-- Second moment of the Wigner surmise: `∫₀^∞ s² p_GUE(s) ds = 3π/8`. -/
theorem gue_pdf_second_moment : ∫ s in Ioi (0 : ℝ), s ^ 2 * gueGapPdf s = 3 * π / 8 := by
  have hpi : 0 < π := Real.pi_pos
  have hb : 0 < 4 / π := by positivity
  have hrewrite : ∀ s : ℝ,
      s ^ 2 * gueGapPdf s = (32 / π ^ 2) * (s ^ 4 * Real.exp (-(4 / π) * s ^ 2)) := by
    intro s; rw [gueGapPdf]; ring
  simp only [hrewrite]
  rw [MeasureTheory.integral_const_mul, integral_pow4_mul_gaussian hb]
  have hsq : Real.sqrt (π / (4 / π)) = π / 2 := by
    have h : π / (4 / π) = (π / 2) ^ 2 := by field_simp; ring
    rw [h, Real.sqrt_sq (by positivity)]
  rw [hsq]
  field_simp
  ring

/-- **The spacing variance orders the three regimes.**  A rigid (picket-fence) spectrum
has variance `0`, the GUE surmise has variance `3π/8 - 1 ≈ 0.178`, and Poisson statistics
have variance `1`: level repulsion strictly reduces spacing fluctuations, but does not
eliminate them. -/
theorem variance_ordering :
    (0 : ℝ) < (∫ s in Ioi (0 : ℝ), s ^ 2 * gueGapPdf s) - 1 ∧
      (∫ s in Ioi (0 : ℝ), s ^ 2 * gueGapPdf s) - 1
        < (∫ s in Ioi (0 : ℝ), s ^ 2 * poissonGapPdf s) - 1 := by
  rw [gue_pdf_second_moment, poisson_pdf_second_moment]
  have h1 : (3.14 : ℝ) < π := Real.pi_gt_d2
  have h2 : π < 3.15 := Real.pi_lt_d2
  constructor <;> linarith

end Catalog.Computation.SpectralPoissonGUE