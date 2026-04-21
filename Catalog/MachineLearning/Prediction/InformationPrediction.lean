/-! # CatalogBuild.MachineLearning.Prediction.InformationPrediction

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 7
-/

import Mathlib

noncomputable section

/-- Mutual information is non-negative when conditioning reduces entropy -/
theorem mutual_information_nonneg (H_X H_X_given_Y : ℝ)
    (h : H_X_given_Y ≤ H_X) :
    0 ≤ mutualInformation H_X H_X_given_Y :=
  sub_nonneg.mpr h




/-- Mutual information ≤ H(X): you can't predict more than there is -/
theorem mutual_information_le_entropy (H_X H_X_given_Y : ℝ)
    (h : 0 ≤ H_X_given_Y) :
    mutualInformation H_X H_X_given_Y ≤ H_X :=
  sub_le_self _ h




/-- Predictability equals compressibility -/
theorem prediction_compression_duality
    (n : ℕ) (H_source : ℝ)
    (predictability compressibility : ℝ)
    (hp : predictability = Real.log n - H_source)
    (hc : compressibility = Real.log n - H_source) :
    predictability = compressibility := by
  rw [hp, hc]




/-- The rate-distortion function: minimum bits needed to predict with distortion ≤ D -/
noncomputable def rateDistortion (H_source D : ℝ) : ℝ :=
  max 0 (H_source - D)




/-- Zero distortion requires full entropy -/
theorem lossless_prediction_cost (H_source : ℝ) (hH : 0 ≤ H_source) :
    rateDistortion H_source 0 = H_source := by
  simp [rateDistortion, sub_zero, hH]




/-- Allowing more distortion reduces information cost -/
theorem more_distortion_less_cost (H_source D₁ D₂ : ℝ) (hD : D₁ ≤ D₂) :
    rateDistortion H_source D₂ ≤ rateDistortion H_source D₁ := by
  simp only [rateDistortion]
  exact max_le_max le_rfl (sub_le_sub_left hD _)




/-- If distortion ≥ entropy, prediction is free -/
theorem free_prediction_high_distortion (H_source D : ℝ) (hD : H_source ≤ D) :
    rateDistortion H_source D = 0 := by
  simp [rateDistortion, sub_nonpos.mpr hD]




end
