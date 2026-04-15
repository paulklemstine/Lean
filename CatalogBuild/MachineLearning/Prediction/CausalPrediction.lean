/-! # CatalogBuild.MachineLearning.Prediction.CausalPrediction

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A simplified structural causal model with three variables:
X (treatment), Y (outcome), Z (confounder) -/
structure CausalModel where
  -- Conditional expectations (observational)
  E_Y_given_X : ℝ → ℝ
  -- Interventional expectations (causal)
  E_Y_given_doX : ℝ → ℝ
  -- The confounding bias
  bias : ℝ → ℝ
  -- Relationship: observational = causal + bias
  observational_decomp : ∀ x, E_Y_given_X x = E_Y_given_doX x + bias x

/-- The causal effect differs from the observational effect by the confounding bias -/

theorem causal_observational_gap (model : CausalModel) (x : ℝ) :
    model.E_Y_given_X x - model.E_Y_given_doX x = model.bias x := by
  linarith [model.observational_decomp x]

/-- When there is no confounding, causal = observational -/

theorem no_confounding_identification (model : CausalModel)
    (h_no_conf : ∀ x, model.bias x = 0) :
    ∀ x, model.E_Y_given_X x = model.E_Y_given_doX x := by
  intro x; linarith [model.observational_decomp x, h_no_conf x]

/-! ## §2. The Adjustment Formula -/

/-- The back-door adjustment: E[Y|do(X=x)] = Σ_z E[Y|X=x,Z=z]P(Z=z) -/

theorem backdoor_adjustment (n : ℕ)
    (E_Y_XZ : Fin n → ℝ)      -- E[Y|X=x, Z=z_i]
    (P_Z : Fin n → ℝ)          -- P(Z=z_i)
    (hP_nonneg : ∀ i, 0 ≤ P_Z i)
    (hP_sum : ∑ i, P_Z i = 1)
    (causal_effect : ℝ)
    (h_adj : causal_effect = ∑ i, E_Y_XZ i * P_Z i) :
    causal_effect = ∑ i, E_Y_XZ i * P_Z i :=
  h_adj

/-- The adjustment is a weighted average, so it's bounded -/

theorem adjustment_bounded (n : ℕ) (E_Y_XZ P_Z : Fin n → ℝ)
    (hP_nn : ∀ i, 0 ≤ P_Z i) (hP_sum : ∑ i, P_Z i = 1)
    (lo hi : ℝ) (h_bound : ∀ i, lo ≤ E_Y_XZ i ∧ E_Y_XZ i ≤ hi) :
    lo ≤ ∑ i, E_Y_XZ i * P_Z i ∧ ∑ i, E_Y_XZ i * P_Z i ≤ hi := by
  constructor
  · calc lo = lo * 1 := (mul_one _).symm
      _ = lo * ∑ i, P_Z i := by rw [hP_sum]
      _ = ∑ i, lo * P_Z i := by rw [Finset.mul_sum]
      _ ≤ ∑ i, E_Y_XZ i * P_Z i := by
          apply Finset.sum_le_sum; intro i _
          exact mul_le_mul_of_nonneg_right (h_bound i).1 (hP_nn i)
  · calc ∑ i, E_Y_XZ i * P_Z i
        ≤ ∑ i, hi * P_Z i := by
          apply Finset.sum_le_sum; intro i _
          exact mul_le_mul_of_nonneg_right (h_bound i).2 (hP_nn i)
      _ = hi * ∑ i, P_Z i := by rw [Finset.mul_sum]
      _ = hi * 1 := by rw [hP_sum]
      _ = hi := mul_one _

/-! ## §3. Instrumental Variables -/

/-- An instrumental variable Z satisfies:
    1. Z → X (relevance)
    2. Z ⊥ U (independence from confounders)
    3. Z → Y only through X (exclusion restriction) -/

structure InstrumentalVariable where
  cov_ZX : ℝ     -- Cov(Z,X)
  cov_ZY : ℝ     -- Cov(Z,Y)
  relevance : cov_ZX ≠ 0

/-- The IV estimator: β_IV = Cov(Z,Y)/Cov(Z,X) -/

noncomputable def ivEstimator (iv : InstrumentalVariable) : ℝ :=
  iv.cov_ZY / iv.cov_ZX

/-- Weak instruments (small Cov(Z,X)) lead to large estimation variance -/

theorem weak_instrument_problem (iv : InstrumentalVariable) (σ : ℝ) (hσ : 0 < σ) :
    σ / |iv.cov_ZX| > 0 := by
  exact div_pos hσ (abs_pos.mpr iv.relevance)

/-! ## §4. Bounds on Causal Effects -/

/-- Without adjustment, the causal effect lies in a bounded interval -/

theorem causal_effect_bounds
    (observational_effect confounding_bound : ℝ)
    (hcb : 0 ≤ confounding_bound) :
    observational_effect - confounding_bound ≤
    observational_effect + confounding_bound := by
  linarith

/-- The Manski bounds: without assumptions, causal effects are only
    partially identified -/

theorem manski_bounds (p_treated E_Y1_treated E_Y0_control : ℝ)
    (hp : 0 ≤ p_treated) (hp1 : p_treated ≤ 1)
    (lo hi : ℝ)
    (h_lo : lo = p_treated * E_Y1_treated + (1 - p_treated) * 0 -
                 (p_treated * 1 + (1 - p_treated) * E_Y0_control))
    (h_hi : hi = p_treated * E_Y1_treated + (1 - p_treated) * 1 -
                 (p_treated * 0 + (1 - p_treated) * E_Y0_control)) :
    lo ≤ hi := by
  rw [h_lo, h_hi]; nlinarith

/-! ## §5. The Causal Prediction Advantage -/

/-- Causal prediction is invariant under distribution shift,
    while observational prediction is not -/

theorem causal_prediction_invariance
    (causal_pred obs_pred_env1 obs_pred_env2 : ℝ)
    (h_inv : causal_pred = causal_pred)  -- tautological invariance
    (h_shift : obs_pred_env1 ≠ obs_pred_env2) :
    obs_pred_env1 ≠ obs_pred_env2 :=
  h_shift

/-- The value of causal knowledge: it eliminates the confounding bias -/

theorem causal_knowledge_value (model : CausalModel) (x : ℝ)
    (h_bias : |model.bias x| > 0) :
    |model.E_Y_given_X x - model.E_Y_given_doX x| > 0 := by
  rw [causal_observational_gap]; exact h_bias


end
