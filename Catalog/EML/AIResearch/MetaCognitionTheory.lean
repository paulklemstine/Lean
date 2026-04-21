/-! # CatalogBuild.EML.AIResearch.MetaCognitionTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 6
-/

import Mathlib

noncomputable section

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


/-- A system is ε-calibrated if its self-model is within ε of reality on every task -/
def IsCalibrated (M : MetaCognitiveSystem) (ε : ℝ) : Prop :=
  ∀ i, |M.estimatedPerf i - M.actualPerf i| ≤ ε


/-- The optimal task to improve: the one with the largest gap between
estimated achievable performance and actual current performance -/
def improvementPriority (M : MetaCognitiveSystem) (achievable : Fin M.numTasks → ℝ) (i : Fin M.numTasks) : ℝ :=
  achievable i - M.actualPerf i


/-- Total improvement potential -/
def totalImprovementPotential (M : MetaCognitiveSystem) (achievable : Fin M.numTasks → ℝ) : ℝ :=
  ∑ i, improvementPriority M achievable i


/-- EML reduces self-evaluation cost -/
def emlSelfEvalCost (d numTestTasks : ℕ) : ℕ :=
  4 * d * numTestTasks


/-- [Section: ## §6. Self-Evaluation Cost] -/
def stdSelfEvalCost (d numTestTasks : ℕ) : ℕ :=
  d * d * numTestTasks


end
