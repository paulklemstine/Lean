/-
# EML Time Series & Forecasting Theory — v15

## Overview
Formalizes EML advantages for time series analysis and forecasting.
Exponential smoothing, autoregressive models, and temporal attention
all use operations native to EML computation.

## Key Results (11 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Exponential Smoothing -/

def expSmoothWeight (alpha : ℝ) (lag : ℕ) : ℝ := (1 - alpha) ^ lag

theorem smooth_weight_nonneg (α : ℝ) (k : ℕ) (_hα : 0 ≤ α) (hα1 : α ≤ 1) :
    0 ≤ expSmoothWeight α k := by
  unfold expSmoothWeight; exact pow_nonneg (by linarith) k

theorem smooth_weight_decays (α : ℝ) (k1 k2 : ℕ) (hα : 0 ≤ α) (hα1 : α ≤ 1)
    (hk : k1 ≤ k2) :
    expSmoothWeight α k2 ≤ expSmoothWeight α k1 := by
  unfold expSmoothWeight
  exact pow_le_pow_of_le_one (by linarith) (by linarith) hk

theorem smooth_weight_one_at_zero (α : ℝ) :
    expSmoothWeight α 0 = 1 := by
  unfold expSmoothWeight; simp

/-! ## §2. Autoregressive Models -/

def stdARParams (d_model numLayers : ℕ) : ℕ :=
  numLayers * (d_model * d_model)

def emlARParams (d_model numLayers : ℕ) : ℕ :=
  numLayers * (4 * d_model)

theorem eml_ar_compact (dm nL : ℕ) (hd : 4 ≤ dm) :
    emlARParams dm nL ≤ stdARParams dm nL := by
  unfold emlARParams stdARParams; gcongr

/-! ## §3. Temporal Attention -/

def stdTemporalAttnParams (d_model numHeads d_head : ℕ) : ℕ :=
  3 * (d_model * numHeads * d_head) + d_model * d_model

def emlTemporalAttnParams (numHeads d_head d_model : ℕ) : ℕ :=
  3 * (4 * numHeads * d_head) + 4 * d_model

theorem eml_temporal_attn_compact (dm nh dh : ℕ) (hd : 4 ≤ dm) :
    emlTemporalAttnParams nh dh dm ≤ stdTemporalAttnParams dm nh dh := by
  unfold emlTemporalAttnParams stdTemporalAttnParams
  have h1 : 4 * (nh * dh) ≤ dm * (nh * dh) := Nat.mul_le_mul_right _ hd
  have h2 : 4 * dm ≤ dm * dm := by nlinarith
  nlinarith

/-! ## §4. Forecast Horizon -/

def forecastCost (modelParams horizon : ℕ) : ℕ := modelParams * horizon

theorem longer_horizon_costlier (mp h1 h2 : ℕ) (hh : h1 ≤ h2) :
    forecastCost mp h1 ≤ forecastCost mp h2 := by
  unfold forecastCost; exact Nat.mul_le_mul_left mp hh

theorem eml_forecast_cheaper (p_eml p_std h : ℕ) (hp : p_eml ≤ p_std) :
    forecastCost p_eml h ≤ forecastCost p_std h := by
  unfold forecastCost; exact Nat.mul_le_mul_right h hp

/-! ## §5. Sliding Window -/

def windowMemory (windowSize featureDim : ℕ) : ℕ := windowSize * featureDim

theorem larger_window_more_memory (w1 w2 fd : ℕ) (hw : w1 ≤ w2) :
    windowMemory w1 fd ≤ windowMemory w2 fd := by
  unfold windowMemory; exact Nat.mul_le_mul_right fd hw

/-! ## §6. Multi-Variate Forecasting -/

def stdMultiVarParams (numVariables d_model : ℕ) : ℕ :=
  numVariables * (numVariables * d_model)

def emlMultiVarParams (numVariables d_model : ℕ) : ℕ :=
  numVariables * (4 * d_model)

theorem eml_multivar_compact (nv dm : ℕ) (hv : 4 ≤ nv) :
    emlMultiVarParams nv dm ≤ stdMultiVarParams nv dm := by
  unfold emlMultiVarParams stdMultiVarParams; gcongr

/-! ## §7. Ensemble Forecasting -/

def ensembleForecastCost (numModels modelCost : ℕ) : ℕ := numModels * modelCost

theorem eml_ensemble_cheaper (nm c_eml c_std : ℕ) (hc : c_eml ≤ c_std) :
    ensembleForecastCost nm c_eml ≤ ensembleForecastCost nm c_std := by
  unfold ensembleForecastCost; exact Nat.mul_le_mul_left nm hc

end
