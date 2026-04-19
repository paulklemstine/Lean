import Mathlib

/-! # Meta-Cognition Theory

Formalizes meta-cognitive self-evaluation for self-learning systems.
Covers calibration, improvement potential, exploration-exploitation tradeoffs,
overconfidence bounds, and meta-learning rate convergence.
-/

noncomputable section

open Real BigOperators Finset

/-! ## Definitions -/

/-- Meta-cognitive error: absolute difference between estimated and actual performance. -/
def metaCogError (estimated actual : ℝ) : ℝ := |estimated - actual|

/-- A system is ε-calibrated if its self-assessment error is at most ε. -/
def Calibrated (estimated actual ε : ℝ) : Prop :=
  metaCogError estimated actual ≤ ε

/-- Improvement potential: gap between achievable and actual performance. -/
def improvementPotential (achievable actual : ℝ) : ℝ := achievable - actual

/-- Exploration-exploitation value: weighted combination. -/
def explorationValue (exploit explore uncertainty weight : ℝ) : ℝ :=
  exploit + weight * uncertainty * explore

/-- Overconfidence: max(0, estimated - actual). -/
def overconfidence (estimated actual : ℝ) : ℝ := max 0 (estimated - actual)

/-- Cost of self-evaluation for a model with given parameters. -/
def selfEvalCost (params : ℕ) (baseCost : ℝ) : ℝ := baseCost * Real.sqrt (params : ℝ)

/-- Meta-learning rate: convergence of meta-learning toward base rate. -/
def metaLearningRate (baseRate : ℝ) (n : ℕ) : ℝ := baseRate * (1 - 1 / (n + 1 : ℝ))

/-- Standard parameter count. -/
def metaStandardParams (d : ℕ) : ℕ := d * d

/-- EML parameter count. -/
def metaEmlParams (d : ℕ) : ℕ := 4 * d

/-! ## Theorems -/

/-
Meta-cognitive error is nonneg.
-/
theorem metaCogError_nonneg (estimated actual : ℝ) :
    0 ≤ metaCogError estimated actual := by
  exact abs_nonneg _

/-
ε-calibration implies meta-cognitive error ≤ ε.
-/
theorem calibrated_implies_low_error (estimated actual ε : ℝ)
    (hcal : Calibrated estimated actual ε) :
    metaCogError estimated actual ≤ ε := by
  exact hcal

/-
Improvement potential = achievable − actual.
-/
theorem improvement_potential_decomposition (achievable actual : ℝ) :
    improvementPotential achievable actual = achievable - actual := by
  rfl

/-
Higher exploration weight gives higher exploration value.
-/
theorem higher_exploration_weight_higher_value
    (exploit explore uncertainty w₁ w₂ : ℝ)
    (hexp : 0 ≤ explore) (hunc : 0 ≤ uncertainty) (hw : w₁ ≤ w₂) :
    explorationValue exploit explore uncertainty w₁ ≤
    explorationValue exploit explore uncertainty w₂ := by
  unfold explorationValue; nlinarith [ mul_le_mul_of_nonneg_left hw hunc, mul_le_mul_of_nonneg_left hw hexp ] ;

/-
Zero uncertainty gives pure exploitation.
-/
theorem zero_uncertainty_pure_exploitation
    (exploit explore weight : ℝ) :
    explorationValue exploit explore 0 weight = exploit := by
  exact show exploit + weight * 0 * explore = exploit from by ring;

/-
Overconfidence is nonneg.
-/
theorem overconfidence_nonneg (estimated actual : ℝ) :
    0 ≤ overconfidence estimated actual := by
  grind +locals

/-
Perfect calibration (estimated = actual) implies zero overconfidence.
-/
theorem perfect_calibration_no_overconfidence (actual : ℝ) :
    overconfidence actual actual = 0 := by
  exact max_eq_left ( by linarith )

/-
EML reduces self-evaluation cost for d ≥ 5.
-/
theorem eml_self_eval_cheaper (d : ℕ) (baseCost : ℝ)
    (hd : 5 ≤ d) (hbc : 0 < baseCost) :
    selfEvalCost (metaEmlParams d) baseCost ≤
    selfEvalCost (metaStandardParams d) baseCost := by
  exact mul_le_mul_of_nonneg_left ( Real.sqrt_le_sqrt <| mod_cast by unfold metaEmlParams metaStandardParams; nlinarith ) hbc.le

/-
Meta-learning rate is monotone increasing in n.
-/
theorem meta_learning_rate_increases (baseRate : ℝ) (hbr : 0 ≤ baseRate) (n : ℕ) :
    metaLearningRate baseRate n ≤ metaLearningRate baseRate (n + 1) := by
  unfold metaLearningRate;
  gcongr ; norm_num

/-
Meta-learning rate converges to base rate (bounded above).
-/
theorem meta_learning_rate_limit (baseRate : ℝ) (hbr : 0 ≤ baseRate) (n : ℕ) :
    metaLearningRate baseRate n ≤ baseRate := by
  exact mul_le_of_le_one_right hbr ( sub_le_self _ ( by positivity ) )

end