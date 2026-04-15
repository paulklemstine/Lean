/-! # CatalogBuild.MachineLearning.Prediction.KalmanFilter

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 10
-/

import Mathlib

noncomputable section

structure KalmanState where
  estimate : ℝ
  variance : ℝ
  variance_nonneg : 0 ≤ variance


structure SystemModel where
  A : ℝ
  Q : ℝ
  H : ℝ
  R : ℝ
  Q_nonneg : 0 ≤ Q
  R_pos : 0 < R


noncomputable def predict (model : SystemModel) (state : KalmanState) : KalmanState where
  estimate := model.A * state.estimate
  variance := model.A ^ 2 * state.variance + model.Q
  variance_nonneg := by nlinarith [sq_nonneg model.A, state.variance_nonneg, model.Q_nonneg]


noncomputable def kalmanGain (model : SystemModel) (predicted_var : ℝ) : ℝ :=
  (predicted_var * model.H) / (model.H ^ 2 * predicted_var + model.R)

/-- The Kalman gain is non-negative for non-negative variance and positive H -/

theorem kalman_gain_nonneg (model : SystemModel) (P : ℝ) (hP : 0 ≤ P) (hH : 0 ≤ model.H) :
    0 ≤ kalmanGain model P := by
  apply div_nonneg (mul_nonneg hP hH)
  nlinarith [sq_nonneg model.H, model.R_pos]

/-! ## Section 2: The Riccati Equation -/


noncomputable def riccatiStep (model : SystemModel) (P : ℝ) : ℝ :=
  let P_pred := model.A ^ 2 * P + model.Q
  let K := kalmanGain model P_pred
  (1 - K * model.H) * P_pred

/-
PROVIDED SOLUTION
riccatiStep = (1 - K*H) * P_pred where K = P_pred*H / (H²*P_pred + R) and P_pred = A²*P + Q. So 1 - K*H = 1 - P_pred*H² / (H²*P_pred + R) = R / (H²*P_pred + R). The denominator H²*P_pred + R > 0 since R > 0. So riccatiStep = R * P_pred / (H²*P_pred + R) ≥ 0 since R > 0, P_pred ≥ 0 (from A²*P + Q ≥ 0), and denominator > 0. Key steps: show P_pred ≥ 0, show denominator > 0, rewrite as R * P_pred / denom, apply div_nonneg.
-/

theorem riccati_nonneg (model : SystemModel) (P : ℝ) (hP : 0 ≤ P) :
    0 ≤ riccatiStep model P := by
  apply mul_nonneg;
  · unfold kalmanGain;
    field_simp;
    exact sub_nonneg.2 ( div_le_one_of_le₀ ( le_add_of_nonneg_right ( by linarith [ model.R_pos ] ) ) ( by nlinarith [ model.R_pos, show 0 ≤ model.A ^ 2 * P + model.Q by nlinarith [ model.Q_nonneg ] ] ) );
  · nlinarith [ model.Q_nonneg ]

/-- When H = 0 (no observation), variance grows without bound -/

theorem no_observation_variance_grows (model : SystemModel) (hH : model.H = 0)
    (P : ℝ) :
    riccatiStep model P = model.A ^ 2 * P + model.Q := by
  simp [riccatiStep, kalmanGain, hH]

/-! ## Section 3: Filter Properties -/

/-- The Kalman filter is unbiased -/

theorem kalman_unbiased (model : SystemModel) (state : KalmanState)
    (true_state new_true_state measurement : ℝ)
    (h_unbiased : state.estimate = true_state)
    (h_transition : new_true_state = model.A * true_state)
    (h_measurement : measurement = model.H * new_true_state) :
    let predicted := predict model state
    let K := kalmanGain model predicted.variance
    predicted.estimate + K * (measurement - model.H * predicted.estimate) = new_true_state := by
  simp only [predict, kalmanGain, h_unbiased, h_transition, h_measurement]
  ring

/-! ## Section 4: Steady-State Analysis -/

/-- The steady-state Kalman gain for a simple system (A=1, H=1) -/

noncomputable def steadyStateGain (Q R : ℝ) : ℝ :=
  let P := (-R + Real.sqrt (R ^ 2 + 4 * Q * R)) / 2
  P / (P + R)


end
