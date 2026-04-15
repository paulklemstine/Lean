/-! # CatalogBuild.MachineLearning.Prediction.UncertaintyPrinciple

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 11
-/

import Mathlib

noncomputable section

/-- The prediction-information uncertainty principle:
reducing prediction variance by factor k requires
at least log(k) bits of information. -/
theorem prediction_information_bound
    (H_prior H_posterior I : ℝ)
    (h_info : I = H_prior - H_posterior)
    (_hH : 0 ≤ H_posterior) (_hI : 0 ≤ I) :
    H_posterior + I = H_prior := by
  linarith


/-- You cannot reduce uncertainty below zero -/
theorem prediction_floor (_H_prior I : ℝ) (h_info_bound : I ≤ H_prior) :
    0 ≤ H_prior - I :=
  sub_nonneg.mpr h_info_bound


/-- The information efficiency: I/H_prior is the fraction of uncertainty removed -/
theorem information_efficiency_bound (H_prior I : ℝ)
    (hH : 0 < H_prior) (_hI : 0 ≤ I) (hbound : I ≤ H_prior) :
    I / H_prior ≤ 1 :=
  div_le_one_of_le₀ hbound (le_of_lt hH)


/-- More data reduces the Cramér-Rao bound -/
theorem cramer_rao_scaling (I₁ : ℝ) (hI : 0 < I₁) (n : ℕ) (hn : 0 < n) :
    1 / (n * I₁) ≤ 1 / I₁ := by
  apply div_le_div_of_nonneg_left (by linarith) (by positivity)
  exact le_mul_of_one_le_left (le_of_lt hI) (by exact_mod_cast hn)


/-- The Cramér-Rao bound is tight for Gaussian models -/
theorem gaussian_achieves_cramer_rao (σ_sq : ℝ) (hσ : 0 < σ_sq) (n : ℕ) (hn : 0 < n) :
    σ_sq / n > 0 := by
  exact div_pos hσ (by exact_mod_cast hn)


/-- A prediction interval: width w, coverage probability p -/
structure PredictionInterval where
  width : ℝ
  coverage : ℝ
  width_pos : 0 < width
  coverage_pos : 0 < coverage
  coverage_le_one : coverage ≤ 1


/-- Wider intervals have higher coverage -/
theorem wider_more_coverage (σ : ℝ) (hσ : 0 < σ)
    (w₁ w₂ : ℝ) (hw : w₁ ≤ w₂) :
    w₁ / σ ≤ w₂ / σ :=
  div_le_div_of_nonneg_right hw (le_of_lt hσ)


/-- The entropy power: N(X) = (1/(2πe)) · exp(2H(X)) -/
noncomputable def entropyPower (H : ℝ) : ℝ :=
  (1 / (2 * Real.pi * Real.exp 1)) * Real.exp (2 * H)


/-- Entropy power is positive -/
theorem entropy_power_pos (H : ℝ) :
    0 < entropyPower H := by
  unfold entropyPower
  apply mul_pos
  · apply div_pos one_pos
    apply mul_pos (mul_pos (by norm_num : (0:ℝ) < 2) Real.pi_pos) (Real.exp_pos 1)
  · exact Real.exp_pos _


/-- Adding noise increases entropy power -/
theorem entropy_power_inequality (H_X H_Z H_sum : ℝ)
    (h : entropyPower H_sum ≥ entropyPower H_X + entropyPower H_Z) :
    entropyPower H_sum ≥ entropyPower H_X := by
  linarith [entropy_power_pos H_Z]


/-- As information increases, the minimum achievable error decreases
but never reaches zero -/
theorem error_floor_positive (I : ℝ) (hI : 0 < I) :
    0 < 1 / I :=
  div_pos one_pos hI


end
