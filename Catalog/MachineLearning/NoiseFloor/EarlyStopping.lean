/-
# The Noise-Floor Principle, Part VII: early stopping versus ridge

Round-6 hypothesis closure, Phase A, cycle 4.

Gradient flow on a quadratic loss with data covariance spectrum `mu`, stopped at
time `tau`, is the spectral filter

  `gradFlowFilter mu tau i = 1 - exp (- mu i * tau)`,

the continuous-time idealisation of early stopping.  Folklore says "early
stopping is ridge with `lam = 1/tau`".  We make the folklore precise **and show
it is one-sided**:

* `gradFlow_le_four_mul_ridge` — early stopping at time `tau` is never worse
  than four times the matched ridge `lam = 1/tau`, for every spectrum, every
  signal and every noise level;
* `ridge_can_be_arbitrarily_worse` — the converse fails badly: on an explicit
  one-mode problem the matched ridge costs more than `100×` early stopping.

Both filters obey the Part II floor (`gradFlow_ge_noiseFloor`), so the
comparison is a statement about *how* the two families approach the same
irreducible limit: the exponential filter kills the bias of well-conditioned
modes at an exponential rate, while ridge only kills it polynomially.

## Main results

* `one_sub_exp_le_two_mul`   — `1 - e^{-u} ≤ 2u/(1+u)` (uniform in `u ≥ 0`)
* `exp_neg_le_one_div`       — `e^{-u} ≤ 1/(1+u)`
* `gradFlow_le_four_mul_ridge`, `gradFlow_ge_noiseFloor`
* `ridge_can_be_arbitrarily_worse`
-/
import Mathlib
import MachineLearning.NoiseFloor.EffectiveDimension
import MachineLearning.NoiseFloor.NoiseFloorPrinciple

namespace Catalog.MachineLearning.NoiseFloor

open Finset

variable {ι : Type*} [Fintype ι]

/-- Gradient-flow (early stopping) spectral filter at time `tau`. -/
noncomputable def gradFlowFilter (mu : ι → ℝ) (tau : ℝ) : ι → ℝ :=
  fun i => 1 - Real.exp (-(mu i * tau))

section Scalar

/-- `e^{-u} ≤ 1/(1+u)` for `u ≥ 0`: the exponential filter has smaller bias than
the matched ridge filter. -/
lemma exp_neg_le_one_div {u : ℝ} (hu : 0 ≤ u) : Real.exp (-u) ≤ 1 / (1 + u) := by
  have h1 : 0 < 1 + u := by linarith
  have h2 : 1 + u ≤ Real.exp u := by
    have := Real.add_one_le_exp u
    linarith
  rw [Real.exp_neg, one_div]
  gcongr

/-- `1 - e^{-u} ≤ 2u/(1+u)` for `u ≥ 0`: the exponential filter has at most twice
the shrinkage weight of the matched ridge filter. -/
lemma one_sub_exp_le_two_mul {u : ℝ} (hu : 0 ≤ u) :
    1 - Real.exp (-u) ≤ 2 * u / (1 + u) := by
  have h1 : 0 < 1 + u := by linarith
  rcases le_total u 1 with h | h
  · have hlin : 1 - u ≤ Real.exp (-u) := by
      have := Real.add_one_le_exp (-u)
      linarith
    rw [le_div_iff₀ h1]
    nlinarith
  · have hpos : 0 < Real.exp (-u) := Real.exp_pos _
    rw [le_div_iff₀ h1]
    nlinarith

/-- Nonnegativity of the exponential filter weight. -/
lemma one_sub_exp_nonneg {u : ℝ} (hu : 0 ≤ u) : 0 ≤ 1 - Real.exp (-u) := by
  have : Real.exp (-u) ≤ 1 := by
    rw [Real.exp_le_one_iff]
    linarith
  linarith

/-- Per-mode comparison of early stopping with matched ridge. -/
lemma mode_gradFlow_le_four_ridge {x b u : ℝ} (hx : 0 ≤ x) (hb : 0 ≤ b) (hu : 0 ≤ u) :
    x * (1 - (1 - Real.exp (-u))) ^ 2 + b * (1 - Real.exp (-u)) ^ 2
      ≤ 4 * (x * (1 - u / (1 + u)) ^ 2 + b * (u / (1 + u)) ^ 2) := by
  have h1 : 0 < 1 + u := by linarith
  have hbias : (1 : ℝ) - u / (1 + u) = 1 / (1 + u) := by
    field_simp
    ring
  have he : Real.exp (-u) ≤ 1 / (1 + u) := exp_neg_le_one_div hu
  have he0 : 0 < Real.exp (-u) := Real.exp_pos _
  have hsq1 : (Real.exp (-u)) ^ 2 ≤ (1 / (1 + u)) ^ 2 := by nlinarith [he0.le]
  have ht : 1 - Real.exp (-u) ≤ 2 * (u / (1 + u)) := by
    have := one_sub_exp_le_two_mul hu
    rw [mul_div_assoc] at this
    exact this
  have ht0 : 0 ≤ 1 - Real.exp (-u) := one_sub_exp_nonneg hu
  have hsq2 : (1 - Real.exp (-u)) ^ 2 ≤ 4 * (u / (1 + u)) ^ 2 := by nlinarith
  have e1 : x * (1 - (1 - Real.exp (-u))) ^ 2 = x * (Real.exp (-u)) ^ 2 := by ring_nf
  rw [e1, hbias]
  nlinarith [mul_le_mul_of_nonneg_left hsq1 hx, mul_le_mul_of_nonneg_left hsq2 hb,
    sq_nonneg (1 / (1 + u)), mul_nonneg hx (sq_nonneg (1 / (1 + u)))]

end Scalar

section Comparison

variable {a mu : ι → ℝ} {b tau : ℝ}

omit [Fintype ι] in
/-- The matched ridge filter, in the `u = mu·tau` parametrisation. -/
lemma ridgeFilter_matched (hmu : ∀ i, 0 ≤ mu i) (htau : 0 < tau) (i : ι) :
    ridgeFilter mu (1 / tau) i = (mu i * tau) / (1 + mu i * tau) := by
  have h1 : 0 < 1 + mu i * tau := by
    have := hmu i
    positivity
  have hd : 0 < mu i + 1 / tau := by
    have := hmu i
    positivity
  rw [ridgeFilter, div_eq_div_iff hd.ne' h1.ne']
  field_simp
  ring

/-- **Early stopping never loses much.**  Gradient flow stopped at `tau` has risk
at most four times that of the matched ridge `lam = 1/tau`, uniformly over
spectra, signals and noise levels. -/
theorem gradFlow_le_four_mul_ridge (ha : ∀ i, 0 ≤ a i) (hb : 0 ≤ b)
    (hmu : ∀ i, 0 ≤ mu i) (htau : 0 < tau) :
    filterRisk a b (gradFlowFilter mu tau) ≤ 4 * filterRisk a b (ridgeFilter mu (1 / tau)) := by
  rw [filterRisk, filterRisk, Finset.mul_sum]
  refine Finset.sum_le_sum fun i _ => ?_
  have hu : 0 ≤ mu i * tau := mul_nonneg (hmu i) htau.le
  have hgf : gradFlowFilter mu tau i = 1 - Real.exp (-(mu i * tau)) := rfl
  rw [hgf, ridgeFilter_matched hmu htau i]
  exact mode_gradFlow_le_four_ridge (ha i) hb hu

/-- Early stopping obeys the noise-floor principle. -/
theorem gradFlow_ge_noiseFloor (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) (mu : ι → ℝ) (tau : ℝ) :
    noiseFloor a b ≤ filterRisk a b (gradFlowFilter mu tau) :=
  filterRisk_ge_noiseFloor ha hb _

end Comparison

section Separation

/-- Auxiliary numeric bound: `e^{20} ≥ 24200`. -/
lemma exp_twenty_large : (24200 : ℝ) ≤ Real.exp 20 := by
  have h1 : (2.718 : ℝ) < Real.exp 1 := by
    have := Real.exp_one_gt_d9
    linarith
  have h2 : ((2.718 : ℝ)) ^ (20 : ℕ) ≤ (Real.exp 1) ^ (20 : ℕ) := by
    apply pow_le_pow_left₀ (by norm_num) h1.le
  have h3 : (Real.exp 1) ^ (20 : ℕ) = Real.exp 20 := by
    rw [← Real.exp_nat_mul]
    norm_num
  rw [h3] at h2
  have h4 : (24200 : ℝ) ≤ (2.718 : ℝ) ^ (20 : ℕ) := by norm_num
  linarith

/-- **The converse fails: ridge can be dramatically worse than early stopping.**
One mode, covariance eigenvalue `1`, signal power `a = e^{20}`, noise `b = 1`,
stopping time `tau = 10` and matched `lam = 1/10`.  Early stopping pays
`1 + (1 - e^{-10})^2 ≤ 2`, while ridge pays at least `e^{20}/121 ≥ 200`.

Hence the four-fold domination of `gradFlow_le_four_mul_ridge` is genuinely
one-sided: the exponential filter is the strictly better *family*, even though
both families are floored by the same `noiseFloor`. -/
theorem ridge_can_be_arbitrarily_worse :
    100 * filterRisk (fun _ : Fin 1 => Real.exp 20) 1 (gradFlowFilter (fun _ => 1) 10)
      ≤ filterRisk (fun _ : Fin 1 => Real.exp 20) 1 (ridgeFilter (fun _ => 1) (1 / 10)) := by
  have hgf : filterRisk (fun _ : Fin 1 => Real.exp 20) 1 (gradFlowFilter (fun _ => 1) 10)
      = Real.exp 20 * (Real.exp (-(1 * 10))) ^ 2 + 1 * (1 - Real.exp (-(1 * 10))) ^ 2 := by
    rw [filterRisk]
    simp only [Finset.univ_unique, Finset.sum_singleton, gradFlowFilter]
    ring_nf
  have hridge : filterRisk (fun _ : Fin 1 => Real.exp 20) 1 (ridgeFilter (fun _ => 1) (1 / 10))
      = Real.exp 20 * (1 - (1 : ℝ) / (1 + 1 / 10)) ^ 2 + 1 * ((1 : ℝ) / (1 + 1 / 10)) ^ 2 := by
    rw [filterRisk]
    simp only [Finset.univ_unique, Finset.sum_singleton, ridgeFilter]
  rw [hgf, hridge]
  have hexp10 : Real.exp (-(1 * 10)) = (Real.exp 20)⁻¹ * Real.exp 10 := by
    rw [← Real.exp_neg]
    rw [← Real.exp_add]
    norm_num
  have hpos20 : (0 : ℝ) < Real.exp 20 := Real.exp_pos _
  have hpos10 : (0 : ℝ) < Real.exp 10 := Real.exp_pos _
  have hsq : Real.exp 20 * (Real.exp (-(1 * 10))) ^ 2 = 1 := by
    rw [show (-(1 * 10) : ℝ) = -10 by norm_num, ← Real.exp_nat_mul]
    rw [show ((2 : ℕ) : ℝ) * (-10) = -20 by norm_num, Real.exp_neg]
    field_simp
  have hbound : (1 : ℝ) - Real.exp (-(1 * 10)) ≤ 1 := by
    have := Real.exp_pos (-(1 * 10))
    linarith
  have hbound0 : (0 : ℝ) ≤ 1 - Real.exp (-(1 * 10)) := by
    have : Real.exp (-(1 * 10)) ≤ 1 := by
      rw [Real.exp_le_one_iff]
      norm_num
    linarith
  have hgfle : Real.exp 20 * (Real.exp (-(1 * 10))) ^ 2 + 1 * (1 - Real.exp (-(1 * 10))) ^ 2
      ≤ 2 := by
    rw [hsq]
    nlinarith
  have hridgege : (200 : ℝ)
      ≤ Real.exp 20 * (1 - (1 : ℝ) / (1 + 1 / 10)) ^ 2 + 1 * ((1 : ℝ) / (1 + 1 / 10)) ^ 2 := by
    have hcoef : (1 - (1 : ℝ) / (1 + 1 / 10)) ^ 2 = 1 / 121 := by norm_num
    rw [hcoef]
    have := exp_twenty_large
    nlinarith [sq_nonneg ((1 : ℝ) / (1 + 1 / 10))]
  calc 100 * (Real.exp 20 * (Real.exp (-(1 * 10))) ^ 2 + 1 * (1 - Real.exp (-(1 * 10))) ^ 2)
      ≤ 100 * 2 := mul_le_mul_of_nonneg_left hgfle (by norm_num)
    _ ≤ Real.exp 20 * (1 - (1 : ℝ) / (1 + 1 / 10)) ^ 2 + 1 * ((1 : ℝ) / (1 + 1 / 10)) ^ 2 := by
        norm_num at hridgege ⊢
        linarith

end Separation

end Catalog.MachineLearning.NoiseFloor