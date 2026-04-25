/-! # CatalogBuild.EML.AIResearch.RobustnessTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 17
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.RobustnessTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 17] -/
theorem larger_margin_more_robust (m1 m2 L : ℝ) (hL : 0 < L) (hm : m1 ≤ m2) :
    certifiedRadius m1 L ≤ certifiedRadius m2 L := by
  unfold certifiedRadius; exact div_le_div_of_nonneg_right hm (le_of_lt hL)


/-- [Section: # CatalogBuild.EML.AIResearch.RobustnessTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 17] -/
theorem smaller_lipschitz_more_robust (m L1 L2 : ℝ)
    (hm : 0 < m) (hL1 : 0 < L1) (hL : L1 ≤ L2) :
    certifiedRadius m L2 ≤ certifiedRadius m L1 := by
  unfold certifiedRadius; exact div_le_div_of_nonneg_left (le_of_lt hm) hL1 hL


/-- [Section: # CatalogBuild.EML.AIResearch.RobustnessTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 17] -/
def stdAdvTrainingCost (samples pgdSteps fwdCost : ℕ) : ℕ :=
  samples * pgdSteps * fwdCost


def emlAdvTrainingCost (samples pgdSteps emlFwdCost : ℕ) : ℕ :=
  samples * pgdSteps * emlFwdCost


theorem eml_adv_training_cheaper (n k c_eml c_std : ℕ) (hc : c_eml ≤ c_std) :
    emlAdvTrainingCost n k c_eml ≤ stdAdvTrainingCost n k c_std := by
  unfold emlAdvTrainingCost stdAdvTrainingCost
  exact Nat.mul_le_mul_left (n * k) hc


def emlEnergy (logitSum : ℝ) : ℝ := -Real.log (Real.exp logitSum)


theorem eml_energy_simplified (s : ℝ) : emlEnergy s = -s := by
  unfold emlEnergy; simp [Real.log_exp]


def binCalibrationError (confidence accuracy : ℝ) : ℝ := |confidence - accuracy|


theorem perfect_calibration (p : ℝ) : binCalibrationError p p = 0 := by
  unfold binCalibrationError; simp


theorem calibration_triangle (c a m : ℝ) :
    binCalibrationError c a ≤ binCalibrationError c m + binCalibrationError m a := by
  unfold binCalibrationError; exact abs_sub_le c m a


def safetyMargin (currentState unsafeBoundary : ℝ) : ℝ := unsafeBoundary - currentState


theorem positive_margin_safe (s b : ℝ) (h : s < b) : 0 < safetyMargin s b := by
  unfold safetyMargin; linarith


def emlResponseTime (depth : ℕ) (opTime : ℝ) : ℝ := ↑depth * opTime


theorem deeper_slower (d1 d2 : ℕ) (t : ℝ) (ht : 0 ≤ t) (hd : d1 ≤ d2) :
    emlResponseTime d1 t ≤ emlResponseTime d2 t := by
  unfold emlResponseTime; exact mul_le_mul_of_nonneg_right (by exact_mod_cast hd) ht


def robustnessAccuracyTradeoff (baseAcc robustnessLevel tradeoffRate : ℝ) : ℝ :=
  baseAcc - tradeoffRate * robustnessLevel


theorem robustness_costs_accuracy (acc rate r1 r2 : ℝ)
    (hr : 0 ≤ rate) (h : r1 ≤ r2) :
    robustnessAccuracyTradeoff acc r2 rate ≤ robustnessAccuracyTradeoff acc r1 rate := by
  unfold robustnessAccuracyTradeoff; nlinarith


theorem eml_better_tradeoff (acc r rate_eml rate_std : ℝ)
    (hr : 0 ≤ r) (hrate : rate_eml ≤ rate_std) :
    robustnessAccuracyTradeoff acc r rate_std ≤ robustnessAccuracyTradeoff acc r rate_eml := by
  unfold robustnessAccuracyTradeoff; nlinarith


end
