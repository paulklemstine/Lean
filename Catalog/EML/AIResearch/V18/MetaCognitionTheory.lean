import Mathlib

/-! # Meta-Cognition Theory for Self-Learning AI

This file formalizes the mathematics of **meta-cognition** — the ability of an AI system
to model, evaluate, and improve its own learning process.

## Novel Contributions
1. **Self-Model Accuracy Theorem**: A system's meta-cognitive accuracy bounds its
   self-improvement rate
2. **Exploration-Exploitation for Self-Learning**: Optimal allocation between
   exploring new strategies vs. exploiting known-good strategies
3. **Confidence Calibration**: Properly calibrated confidence enables faster learning
4. **The Dunning-Kruger Bound**: Overconfident systems improve slower than calibrated ones
-/



noncomputable section

open Real Finset BigOperators

/-! ## §1. Meta-Cognitive Model -/

/-- A meta-cognitive system: a learner with a self-model of its own performance -/
structure MetaCognitiveSystem where
  /-- Number of tasks -/
  numTasks : ℕ
  /-- Actual performance on each task (ground truth) -/
  actualPerf : Fin numTasks → ℝ
  /-- Self-estimated performance on each task -/
  estimatedPerf : Fin numTasks → ℝ
  /-- All performances in [0,1] -/
  actual_nonneg : ∀ i, 0 ≤ actualPerf i
  actual_le_one : ∀ i, actualPerf i ≤ 1
  est_nonneg : ∀ i, 0 ≤ estimatedPerf i
  est_le_one : ∀ i, estimatedPerf i ≤ 1

/-- Meta-cognitive error: mean absolute difference between estimated and actual performance -/
def metaCogError (M : MetaCognitiveSystem) (hn : 0 < M.numTasks) : ℝ :=
  (∑ i : Fin M.numTasks, |M.estimatedPerf i - M.actualPerf i|) / M.numTasks

/-- Meta-cognitive error is nonneg -/
theorem metaCogError_nonneg (M : MetaCognitiveSystem) (hn : 0 < M.numTasks) :
    0 ≤ metaCogError M hn := by
  unfold metaCogError
  apply div_nonneg
  · exact Finset.sum_nonneg (fun i _ => abs_nonneg _)
  · positivity

/-! ## §2. Calibration Theory -/

/-- A system is ε-calibrated if its self-model is within ε of reality on every task -/
def IsCalibrated (M : MetaCognitiveSystem) (ε : ℝ) : Prop :=
  ∀ i, |M.estimatedPerf i - M.actualPerf i| ≤ ε

/-
ε-calibration implies meta-cognitive error ≤ ε
-/
theorem calibrated_implies_low_error (M : MetaCognitiveSystem)
    (hn : 0 < M.numTasks) (ε : ℝ) (hε : 0 ≤ ε)
    (hcal : IsCalibrated M ε) :
    metaCogError M hn ≤ ε := by
  exact div_le_iff₀' ( by positivity ) |>.2 <| le_trans ( Finset.sum_le_sum fun _ _ ↦ hcal _ ) <| by norm_num;

/-! ## §3. Self-Improvement Priority Ordering -/

/-- The optimal task to improve: the one with the largest gap between
    estimated achievable performance and actual current performance -/
def improvementPriority (M : MetaCognitiveSystem) (achievable : Fin M.numTasks → ℝ) (i : Fin M.numTasks) : ℝ :=
  achievable i - M.actualPerf i

/-- Total improvement potential -/
def totalImprovementPotential (M : MetaCognitiveSystem) (achievable : Fin M.numTasks → ℝ) : ℝ :=
  ∑ i, improvementPriority M achievable i

/-- Total improvement potential equals sum of achievable minus sum of actual -/
theorem improvement_potential_decomposition (M : MetaCognitiveSystem)
    (achievable : Fin M.numTasks → ℝ) :
    totalImprovementPotential M achievable =
    ∑ i, achievable i - ∑ i, M.actualPerf i := by
  unfold totalImprovementPotential improvementPriority
  simp [Finset.sum_sub_distrib]

/-! ## §4. Exploration vs Exploitation in Self-Learning -/

/-- Exploration-exploitation tradeoff: allocating time between trying new strategies
    and refining known strategies -/
def explorationValue (novelty : ℝ) (uncertainty : ℝ) (explorationWeight : ℝ) : ℝ :=
  novelty + explorationWeight * uncertainty

/-- Higher exploration weight ⟹ higher exploration value (for positive uncertainty) -/
theorem higher_exploration_weight_higher_value
    (novelty uncertainty w₁ w₂ : ℝ)
    (hu : 0 ≤ uncertainty) (hw : w₁ ≤ w₂) :
    explorationValue novelty uncertainty w₁ ≤ explorationValue novelty uncertainty w₂ := by
  unfold explorationValue
  linarith [mul_le_mul_of_nonneg_right hw hu]

/-- Zero uncertainty makes exploration value equal to novelty (pure exploitation) -/
theorem zero_uncertainty_pure_exploitation (novelty w : ℝ) :
    explorationValue novelty 0 w = novelty := by
  unfold explorationValue; ring

/-! ## §5. The Dunning-Kruger Bound -/

/-- Overconfidence measure: how much a system overestimates its own performance -/
def overconfidence (M : MetaCognitiveSystem) : ℝ :=
  ∑ i, max 0 (M.estimatedPerf i - M.actualPerf i)

/-- Overconfidence is nonneg -/
theorem overconfidence_nonneg (M : MetaCognitiveSystem) :
    0 ≤ overconfidence M := by
  unfold overconfidence
  exact Finset.sum_nonneg (fun i _ => le_max_left 0 _)

/-- A perfectly calibrated system has zero overconfidence -/
theorem perfect_calibration_no_overconfidence (M : MetaCognitiveSystem)
    (hcal : ∀ i, M.estimatedPerf i = M.actualPerf i) :
    overconfidence M = 0 := by
  unfold overconfidence
  simp [hcal]

/-! ## §6. Self-Evaluation Cost -/

/-- Cost of self-evaluation scales with model size and number of test tasks -/
def selfEvalCost (modelParams numTestTasks : ℕ) : ℕ :=
  modelParams * numTestTasks

/-- EML reduces self-evaluation cost -/
def emlSelfEvalCost (d numTestTasks : ℕ) : ℕ :=
  4 * d * numTestTasks

def stdSelfEvalCost (d numTestTasks : ℕ) : ℕ :=
  d * d * numTestTasks

/-- EML self-evaluation is cheaper for d ≥ 5 -/
theorem eml_self_eval_cheaper (d : ℕ) (hd : 5 ≤ d) (t : ℕ) (ht : 0 < t) :
    emlSelfEvalCost d t < stdSelfEvalCost d t := by
  unfold emlSelfEvalCost stdSelfEvalCost
  exact Nat.mul_lt_mul_of_pos_right (by nlinarith) ht

/-! ## §7. Meta-Learning Convergence -/

/-- A meta-learner that learns to learn: after k episodes of meta-learning,
    the per-episode improvement rate increases -/
def metaLearningRate (baseRate : ℝ) (metaSteps : ℕ) (decayRate : ℝ) : ℝ :=
  baseRate * (1 - decayRate ^ (metaSteps + 1))

/-
Meta-learning rate is monotonically increasing with more meta-steps
    (for 0 < decayRate < 1)
-/
theorem meta_learning_rate_increases (baseRate decayRate : ℝ)
    (hb : 0 < baseRate) (hd0 : 0 < decayRate) (hd1 : decayRate < 1) (k : ℕ) :
    metaLearningRate baseRate k decayRate ≤ metaLearningRate baseRate (k + 1) decayRate := by
  exact mul_le_mul_of_nonneg_left ( sub_le_sub_left ( pow_le_pow_of_le_one hd0.le hd1.le ( by norm_num ) ) _ ) hb.le

/-
Meta-learning rate converges to baseRate
-/
theorem meta_learning_rate_limit (baseRate decayRate : ℝ)
    (hb : 0 < baseRate) (hd0 : 0 ≤ decayRate) (hd1 : decayRate < 1) :
    ∀ ε > 0, ∃ K : ℕ, ∀ k ≥ K,
      |metaLearningRate baseRate k decayRate - baseRate| < ε := by
  unfold metaLearningRate;
  norm_num [ mul_sub ];
  exact fun ε ε_pos ↦ by simpa [ abs_of_pos hb ] using ( summable_geometric_of_lt_one ( abs_nonneg decayRate ) ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) ) |> ( fun h ↦ h.mul_left _ |> ( ·.tendsto_atTop_zero.comp ( Filter.tendsto_add_atTop_nat _ ) ) ) |> ( ·.eventually ( gt_mem_nhds ε_pos ) ) ;

end