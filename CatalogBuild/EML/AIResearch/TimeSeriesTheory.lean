/-! # CatalogBuild.EML.AIResearch.TimeSeriesTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 29
-/

import Mathlib

noncomputable section

def expSmoothing (alpha x_t s_prev : ℝ) : ℝ := alpha * x_t + (1 - alpha) * s_prev


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

/-! ## §2. Forecasting Model Efficiency -/


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

/-! ## §3. Anomaly Detection -/


def anomalyScore (predicted actual : ℝ) : ℝ := (predicted - actual) ^ 2


theorem perfect_prediction_no_anomaly (x : ℝ) : anomalyScore x x = 0 := by
  unfold anomalyScore; ring


theorem anomaly_nonneg (p a : ℝ) : 0 ≤ anomalyScore p a := by
  unfold anomalyScore; exact sq_nonneg _

/-! ## §4. Multi-Horizon Forecasting -/


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

/-! ## §5. Temporal Fusion -/


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

/-! ## §6. Change Point Detection -/


def cusumStat (prevStat deviation threshold : ℝ) : ℝ :=
  max 0 (prevStat + deviation - threshold)


theorem cusum_nonneg (s d t : ℝ) : 0 ≤ cusumStat s d t := by
  unfold cusumStat; exact le_max_left 0 _


theorem cusum_resets (t : ℝ) (ht : 0 ≤ t) : cusumStat 0 0 t = 0 := by
  unfold cusumStat; simp; linarith

/-! ## §7. Forecast Combination -/


def combinedForecast (w1 f1 w2 f2 : ℝ) : ℝ := w1 * f1 + w2 * f2


theorem equal_weight_average (f1 f2 : ℝ) :
    combinedForecast (1/2) f1 (1/2) f2 = (f1 + f2) / 2 := by
  unfold combinedForecast; ring


theorem single_forecast (f1 f2 : ℝ) :
    combinedForecast 1 f1 0 f2 = f1 := by
  unfold combinedForecast; ring

/-! ## §8. Autoregressive EML -/


def arParams (order : ℕ) : ℕ := order + 1

def emlARParams (order : ℕ) : ℕ := 4 * order


theorem eml_ar_richer (p : ℕ) (hp : 2 ≤ p) : arParams p ≤ emlARParams p := by
  unfold arParams emlARParams; omega

/-! ## §9. Seasonal EML Encoding -/


def fourierParams (numHarmonics : ℕ) : ℕ := 2 * numHarmonics

def emlSeasonalParams (numHarmonics : ℕ) : ℕ := 4 * numHarmonics


theorem eml_seasonal_richer (k : ℕ) : fourierParams k ≤ emlSeasonalParams k := by
  unfold fourierParams emlSeasonalParams; omega

end


end
