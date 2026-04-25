/-! # CatalogBuild.EML.AIResearch.ContinualLearningTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.ContinualLearningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13] -/
theorem eml_replay_smaller (p_eml p_std ne es : ℕ) (hp : p_eml ≤ p_std) :
    replayBufferSize p_eml ne es ≤ replayBufferSize p_std ne es := by
  unfold replayBufferSize; omega


/-- [Section: ## §2. Elastic Weight Consolidation] -/
def ewcCost (modelParams : ℕ) : ℕ := 2 * modelParams


/-- [Section: # CatalogBuild.EML.AIResearch.ContinualLearningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13] -/
theorem eml_ewc_cheaper (p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    ewcCost p_eml ≤ ewcCost p_std := by
  unfold ewcCost; omega


theorem ewc_penalty_nonneg (fw pc : ℝ) (hfw : 0 ≤ fw) :
    0 ≤ ewcPenalty fw pc := by
  unfold ewcPenalty; exact mul_nonneg hfw (sq_nonneg _)


def totalAdapterParams (numTasks adapterParamsPerTask : ℕ) : ℕ :=
  numTasks * adapterParamsPerTask


theorem eml_multitask_adapters_cheaper (nt a_eml a_std : ℕ) (ha : a_eml ≤ a_std) :
    totalAdapterParams nt a_eml ≤ totalAdapterParams nt a_std := by
  unfold totalAdapterParams; exact Nat.mul_le_mul_left nt ha


/-- [Section: ## §4. Progressive Networks] -/
def progressiveNetParams (baseParams growthPerTask numTasks : ℕ) : ℕ :=
  baseParams + numTasks * growthPerTask


theorem more_tasks_more_params (bp gpt t1 t2 : ℕ) (ht : t1 ≤ t2) :
    progressiveNetParams bp gpt t1 ≤ progressiveNetParams bp gpt t2 := by
  unfold progressiveNetParams; nlinarith


theorem eml_progressive_cheaper (bp_eml bp_std g_eml g_std nt : ℕ)
    (hb : bp_eml ≤ bp_std) (hg : g_eml ≤ g_std) :
    progressiveNetParams bp_eml g_eml nt ≤ progressiveNetParams bp_std g_std nt := by
  unfold progressiveNetParams; nlinarith


/-- [Section: ## §5. Forgetting Risk] -/
def forgettingRisk (modelParams dataOverlap : ℕ) : ℕ := modelParams * dataOverlap


theorem fewer_params_less_forgetting (p1 p2 d : ℕ) (hp : p1 ≤ p2) :
    forgettingRisk p1 d ≤ forgettingRisk p2 d := by
  unfold forgettingRisk; exact Nat.mul_le_mul_right d hp


/-- [Section: ## §6. Consolidation] -/
def consolidationCost (teacherParams studentParams dataSize : ℕ) : ℕ :=
  (teacherParams + studentParams) * dataSize


theorem eml_consolidation_cheaper (tp sp_eml sp_std ds : ℕ) (hs : sp_eml ≤ sp_std) :
    consolidationCost tp sp_eml ds ≤ consolidationCost tp sp_std ds := by
  unfold consolidationCost; nlinarith


end
