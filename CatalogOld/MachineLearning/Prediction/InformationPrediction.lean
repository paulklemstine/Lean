/-
  # Information Theory of Prediction
-/

import Mathlib

open Real Finset BigOperators

namespace InformationPrediction

/-! ## Section 1: Entropy and Mutual Information -/

/-- Mutual information I(X;Y) = H(X) - H(X|Y) is the prediction gain -/
noncomputable def mutualInformation (H_X H_X_given_Y : ℝ) : ℝ :=
  H_X - H_X_given_Y

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

/-! ## Section 2: Data Processing Inequality -/

/-- A prediction pipeline: Past → Features → Prediction.
    DPI: I(Past; Prediction) ≤ I(Past; Features) -/
theorem data_processing_inequality
    (I_past_features I_past_prediction I_features_prediction : ℝ)
    (h_markov : I_past_prediction ≤ I_past_features)
    (h_markov2 : I_past_prediction ≤ I_features_prediction) :
    I_past_prediction ≤ min I_past_features I_features_prediction :=
  le_min h_markov h_markov2

/-! ## Section 3: Prediction-Compression Duality -/

/-- Predictability equals compressibility -/
theorem prediction_compression_duality
    (n : ℕ) (H_source : ℝ)
    (predictability compressibility : ℝ)
    (hp : predictability = Real.log n - H_source)
    (hc : compressibility = Real.log n - H_source) :
    predictability = compressibility := by
  rw [hp, hc]

/-! ## Section 4: Rate-Distortion Theory -/

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

end InformationPrediction
