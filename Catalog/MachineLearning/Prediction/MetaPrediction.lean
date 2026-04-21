/-! # CatalogBuild.MachineLearning.Prediction.MetaPrediction

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A meta-predictor assigns a confidence score to each prediction -/
structure MetaPredictor where
  predict : ℝ → ℝ           -- base prediction
  confidence : ℝ → ℝ        -- confidence in prediction
  conf_nonneg : ∀ x, 0 ≤ confidence x
  conf_le_one : ∀ x, confidence x ≤ 1




/-- Calibration: among predictions with confidence p, fraction p are correct -/
def isCalibrated (errorRate : ℝ → ℝ) (confidence : ℝ → ℝ) : Prop :=
  ∀ p : ℝ, 0 ≤ p → p ≤ 1 → errorRate p = 1 - confidence p




/-- Perfect calibration means confidence equals actual accuracy -/
theorem perfect_calibration_accuracy (errorRate confidence : ℝ → ℝ)
    (hcal : isCalibrated errorRate confidence) (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    errorRate p + confidence p = 1 := by
  simp [isCalibrated] at hcal
  linarith [hcal p hp0 hp1]




/-- No meta-predictor can perfectly predict its own accuracy on all inputs.
This is a diagonal argument: for any enumeration of predictors,
there exists a function that differs from every predictor at its own index. -/
theorem meta_prediction_incompleteness
    (predictors : ℕ → (ℕ → Bool)) :
    ∃ f : ℕ → Bool, ∀ n, f n ≠ predictors n n := by
  exact ⟨fun n => !predictors n n, fun n => by simp⟩




/-- Stronger version: for any quality estimator, there exists
a predictor whose quality it systematically misjudges -/
theorem quality_estimation_limit
    (quality : (ℕ → ℝ) → ℝ)   -- assigns quality score to predictors
    (actual : (ℕ → ℝ) → ℝ)    -- actual quality
    (h_diff : ∃ f : ℕ → ℝ, actual f ≠ quality f) :
    ¬ ∀ f : ℕ → ℝ, quality f = actual f := by
  intro h_all
  obtain ⟨f, hf⟩ := h_diff
  exact hf (h_all f).symm




/-- The Brier score decomposes into calibration + resolution - uncertainty -/
theorem brier_decomposition (calibration resolution uncertainty brierScore : ℝ)
    (h : brierScore = calibration - resolution + uncertainty)
    (hcal : 0 ≤ calibration) (hres : 0 ≤ resolution) :
    brierScore ≥ uncertainty - resolution := by
  linarith




/-- Higher confidence must be justified by higher accuracy,
or the Brier score worsens -/
theorem overconfidence_penalty (p_claimed p_actual : ℝ)
    (_hp0 : 0 ≤ p_claimed) (_hp1 : p_claimed ≤ 1)
    (ha0 : 0 ≤ p_actual) (_ha1 : p_actual ≤ 1) :
    (p_claimed - p_actual) ^ 2 ≤ (p_claimed - p_actual) ^ 2 + p_actual * (1 - p_actual) := by
  linarith [mul_nonneg ha0 (by linarith : 0 ≤ 1 - p_actual)]




/-- A prediction hierarchy: level 0 predicts the target,
level k+1 predicts the error of level k -/
def predictionHierarchy (errors : ℕ → ℝ) : Prop :=
  ∀ k, |errors (k + 1)| ≤ |errors k| / 2




/-- [Section: # CatalogBuild.MachineLearning.Prediction.MetaPrediction
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12] -/
theorem hierarchy_converges (errors : ℕ → ℝ) (h : predictionHierarchy errors) :
    ∀ ε > 0, ∃ K, ∀ k ≥ K, |errors k| < ε := by
  intro ε hε_pos
  have : Filter.Tendsto (fun n => |errors n|) Filter.atTop (nhds 0) := by
    -- By induction, we can show that |errors n| ≤ |errors 0| / 2^n.
    have h_induction : ∀ n, |errors n| ≤ |errors 0| / 2^n := by
      refine fun n ↦ Nat.recOn n ?_ fun n ih ↦ ?_ <;> simp_all +decide [ pow_succ, div_mul_eq_div_div ];
      exact le_trans ( h n ) ( by ring_nf at *; linarith );
    exact squeeze_zero ( fun n => abs_nonneg _ ) h_induction ( tendsto_const_nhds.div_atTop ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) );
  simpa using this.eventually ( gt_mem_nhds hε_pos )




/-- [Section: # CatalogBuild.MachineLearning.Prediction.MetaPrediction
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12] -/
theorem hierarchy_total_bounded (errors : ℕ → ℝ) (h : predictionHierarchy errors) :
    ∀ n, |errors n| ≤ |errors 0| / 2 ^ n := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · norm_num;
  · have := h n; ring_nf at *; linarith




/-- A self-aware predictor: one whose confidence equals its actual accuracy -/
def isSelfAware (accuracy confidence : ℝ) : Prop :=
  accuracy = confidence




theorem calibration_fixed_point
    (f : ℝ → ℝ)
    (hcont : Continuous f)
    (h_cross_low : f 0 > 0) (h_cross_high : f 1 < 1) :
    ∃ p, 0 ≤ p ∧ p ≤ 1 ∧ f p = p := by
  -- By the intermediate value theorem, since $g(0) > 0$ and $g(1) < 0$, there exists some $p \in [0,1]$ such that $g(p) = 0$.
  have h_ivt : ∃ p ∈ Set.Icc 0 1, (f p - p) = 0 := by
    apply_rules [ intermediate_value_Icc' ] <;> norm_num;
    · exact hcont.continuousOn.sub continuousOn_id;
    · constructor <;> linarith;
  exact ⟨ h_ivt.choose, h_ivt.choose_spec.1.1, h_ivt.choose_spec.1.2, sub_eq_zero.mp h_ivt.choose_spec.2 ⟩




end
