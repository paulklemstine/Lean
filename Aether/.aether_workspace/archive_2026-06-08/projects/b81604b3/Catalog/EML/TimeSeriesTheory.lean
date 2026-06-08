import Mathlib

/-! # CatalogBuild.EML.AIResearch.TimeSeriesTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 47
-/

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.TimeSeriesTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 29] -/
def expSmoothing (alpha x_t s_prev : ℝ) : ℝ := alpha * x_t + (1 - alpha) * s_prev

/-- [Section: # CatalogBuild.EML.AIResearch.TimeSeriesTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 47] -/
def expWeight (alpha : ℝ) (k : ℕ) : ℝ := alpha * (1 - alpha) ^ k

theorem weights_decay (alpha : ℝ) (k1 k2 : ℕ) (ha0 : 0 ≤ alpha) (ha1 : alpha ≤ 1)
    (hk : k1 ≤ k2) :
    expWeight alpha k2 ≤ expWeight alpha k1 := by
  unfold expWeight
  apply mul_le_mul_of_nonneg_left _ ha0
  exact pow_le_pow_of_le_one (by linarith) (by linarith) hk

theorem no_smoothing (x s : ℝ) : expSmoothing 0 x s = s := by
  unfold expSmoothing; ring

theorem full_smoothing (x s : ℝ) : expSmoothing 1 x s = x := by
  unfold expSmoothing; ring

def stdTemporalParams (inputDim hiddenDim numLayers : ℕ) : ℕ :=
  numLayers * (4 * inputDim * hiddenDim + 4 * hiddenDim * hiddenDim)

def emlTemporalParams (inputDim numLayers : ℕ) : ℕ := numLayers * 4 * inputDim

theorem eml_temporal_efficient (d h L : ℕ) (hh : 1 ≤ h) :
    emlTemporalParams d L ≤ stdTemporalParams d h L := by
  unfold emlTemporalParams stdTemporalParams
  have h1 : 4 * d ≤ 4 * d * h := Nat.le_mul_of_pos_right _ (by omega)
  have h2 : 4 * d * h ≤ 4 * d * h + 4 * h * h := Nat.le_add_right _ _
  calc L * 4 * d = L * (4 * d) := by ring_nf
    _ ≤ L * (4 * d * h) := Nat.mul_le_mul_left L h1
    _ ≤ L * (4 * d * h + 4 * h * h) := Nat.mul_le_mul_left L h2

def anomalyScore (predicted actual : ℝ) : ℝ := (predicted - actual) ^ 2

theorem perfect_prediction_no_anomaly (x : ℝ) : anomalyScore x x = 0 := by
  unfold anomalyScore; ring

theorem anomaly_nonneg (p a : ℝ) : 0 ≤ anomalyScore p a := by
  unfold anomalyScore; exact sq_nonneg _

def horizonError (baseError growthRate : ℝ) (horizon : ℕ) : ℝ :=
  baseError * growthRate ^ horizon

theorem longer_horizon_more_error (e g : ℝ) (h1 h2 : ℕ) (he : 0 ≤ e)
    (hg : 1 ≤ g) (hh : h1 ≤ h2) :
    horizonError e g h1 ≤ horizonError e g h2 := by
  unfold horizonError; gcongr; exact hg

theorem eml_slower_error_growth (e g_eml g_std : ℝ) (h : ℕ) (he : 0 ≤ e)
    (hg_eml : 0 ≤ g_eml) (hg : g_eml ≤ g_std) :
    horizonError e g_eml h ≤ horizonError e g_std h := by
  unfold horizonError; gcongr

def fusionProjectParams (numInputs inputDim outputDim : ℕ) : ℕ :=
  numInputs * inputDim * outputDim

def emlFusionProjectParams (numInputs inputDim : ℕ) : ℕ :=
  numInputs * 4 * inputDim

theorem eml_fusion_cheaper (n d o : ℕ) (ho : 4 ≤ o) :
    emlFusionProjectParams n d ≤ fusionProjectParams n d o := by
  unfold emlFusionProjectParams fusionProjectParams
  have h1 : n * 4 ≤ n * o := Nat.mul_le_mul_left n ho
  calc n * 4 * d ≤ n * o * d := Nat.mul_le_mul_right d h1
    _ = n * d * o := by ring_nf

def cusumStat (prevStat deviation threshold : ℝ) : ℝ :=
  max 0 (prevStat + deviation - threshold)

theorem cusum_nonneg (s d t : ℝ) : 0 ≤ cusumStat s d t := by
  unfold cusumStat; exact le_max_left 0 _

theorem cusum_resets (t : ℝ) (ht : 0 ≤ t) : cusumStat 0 0 t = 0 := by
  unfold cusumStat; simp; linarith

def combinedForecast (w1 f1 w2 f2 : ℝ) : ℝ := w1 * f1 + w2 * f2

theorem equal_weight_average (f1 f2 : ℝ) :
    combinedForecast (1/2) f1 (1/2) f2 = (f1 + f2) / 2 := by
  unfold combinedForecast; ring

theorem single_forecast (f1 f2 : ℝ) :
    combinedForecast 1 f1 0 f2 = f1 := by
  unfold combinedForecast; ring

def arParams (order : ℕ) : ℕ := order + 1

def emlARParams (order : ℕ) : ℕ := 4 * order

theorem eml_ar_richer (p : ℕ) (hp : 2 ≤ p) : arParams p ≤ emlARParams p := by
  unfold arParams emlARParams; omega

def fourierParams (numHarmonics : ℕ) : ℕ := 2 * numHarmonics

def emlSeasonalParams (numHarmonics : ℕ) : ℕ := 4 * numHarmonics

theorem eml_seasonal_richer (k : ℕ) : fourierParams k ≤ emlSeasonalParams k := by
  unfold fourierParams emlSeasonalParams; omega

/-- [Section: ## §1. Exponential Smoothing] -/
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

/-- [Section: ## §2. Autoregressive Models] -/
def stdARParams (d_model numLayers : ℕ) : ℕ :=
  numLayers * (d_model * d_model)

theorem eml_ar_compact (dm nL : ℕ) (hd : 4 ≤ dm) :
    emlARParams dm nL ≤ stdARParams dm nL := by
  unfold emlARParams stdARParams; gcongr

/-- [Section: ## §3. Temporal Attention] -/
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

/-- [Section: ## §4. Forecast Horizon] -/
def forecastCost (modelParams horizon : ℕ) : ℕ := modelParams * horizon

theorem longer_horizon_costlier (mp h1 h2 : ℕ) (hh : h1 ≤ h2) :
    forecastCost mp h1 ≤ forecastCost mp h2 := by
  unfold forecastCost; exact Nat.mul_le_mul_left mp hh

theorem eml_forecast_cheaper (p_eml p_std h : ℕ) (hp : p_eml ≤ p_std) :
    forecastCost p_eml h ≤ forecastCost p_std h := by
  unfold forecastCost; exact Nat.mul_le_mul_right h hp

/-- [Section: ## §5. Sliding Window] -/
def windowMemory (windowSize featureDim : ℕ) : ℕ := windowSize * featureDim

theorem larger_window_more_memory (w1 w2 fd : ℕ) (hw : w1 ≤ w2) :
    windowMemory w1 fd ≤ windowMemory w2 fd := by
  unfold windowMemory; exact Nat.mul_le_mul_right fd hw

/-- [Section: ## §6. Multi-Variate Forecasting] -/
def stdMultiVarParams (numVariables d_model : ℕ) : ℕ :=
  numVariables * (numVariables * d_model)

def emlMultiVarParams (numVariables d_model : ℕ) : ℕ :=
  numVariables * (4 * d_model)

theorem eml_multivar_compact (nv dm : ℕ) (hv : 4 ≤ nv) :
    emlMultiVarParams nv dm ≤ stdMultiVarParams nv dm := by
  unfold emlMultiVarParams stdMultiVarParams; gcongr

/-- [Section: ## §7. Ensemble Forecasting] -/
def ensembleForecastCost (numModels modelCost : ℕ) : ℕ := numModels * modelCost

end