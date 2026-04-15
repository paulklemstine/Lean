/-! # CatalogBuild.EML.AIResearch.ContinualLearning

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 16
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. Catastrophic Forgetting Bounds] -/
def standardForgetting (overlap : ℝ) (taskDifficulty : ℕ) : ℝ :=
  overlap * ↑taskDifficulty


def emlForgetting (overlap invertibilityFactor : ℝ) (taskDifficulty : ℕ) : ℝ :=
  overlap * (1 - invertibilityFactor) * ↑taskDifficulty


theorem eml_less_forgetting (overlap invFactor : ℝ) (td : ℕ)
    (hoverlap : 0 ≤ overlap) (hinv : 0 ≤ invFactor) (hinv1 : invFactor ≤ 1) :
    emlForgetting overlap invFactor td ≤ standardForgetting overlap td := by
  unfold emlForgetting standardForgetting
  have htd : (0 : ℝ) ≤ ↑td := Nat.cast_nonneg _
  nlinarith [mul_nonneg hoverlap htd]


/-- [Section: ## §2. Elastic Weight Consolidation] -/
def ewcPenalty (fisher paramShift : ℝ) : ℝ := fisher * paramShift ^ 2


def emlEWCCost (d w : ℕ) (avgFisher avgShift : ℝ) : ℝ :=
  ↑(4 * d * w) * ewcPenalty avgFisher avgShift


def stdEWCCost (d w : ℕ) (avgFisher avgShift : ℝ) : ℝ :=
  ↑(d * w * w) * ewcPenalty avgFisher avgShift


theorem eml_cheaper_ewc (d w : ℕ) (f s : ℝ) (hw : 5 ≤ w) (hf : 0 ≤ f) :
    emlEWCCost d w f s ≤ stdEWCCost d w f s := by
  unfold emlEWCCost stdEWCCost ewcPenalty
  apply mul_le_mul_of_nonneg_right _ (by positivity)
  have h1 : 4 * d * w ≤ d * w * w := by nlinarith [mul_le_mul_of_nonneg_left hw (Nat.zero_le d)]
  exact_mod_cast h1


/-- [Section: ## §3. Task Capacity] -/
def taskCapacity (totalParams paramsPerTask : ℕ) : ℕ := totalParams / paramsPerTask


theorem eml_more_tasks (totalParams emlPerTask stdPerTask : ℕ)
    (heml : 0 < emlPerTask) (h : emlPerTask ≤ stdPerTask) :
    taskCapacity totalParams stdPerTask ≤ taskCapacity totalParams emlPerTask := by
  unfold taskCapacity; exact Nat.div_le_div_left h heml


/-- [Section: ## §4. Memory Replay Buffer] -/
def replayBufferSize (paramsPerTask numTasks : ℕ) : ℕ := paramsPerTask * numTasks


theorem eml_smaller_replay (d w numTasks : ℕ) (hw : 5 ≤ w) :
    replayBufferSize (4 * d * w) numTasks ≤ replayBufferSize (d * w * w) numTasks := by
  unfold replayBufferSize; apply Nat.mul_le_mul_right
  nlinarith [mul_le_mul_of_nonneg_left hw (Nat.zero_le d)]


/-- [Section: ## §5. Progressive Network Growth] -/
def emlGrowthCost (newWidth : ℕ) : ℕ := 4 * newWidth

def stdGrowthCost (existingWidth newWidth : ℕ) : ℕ := existingWidth * newWidth


theorem eml_cheaper_growth (existingWidth newWidth : ℕ) (hw : 4 ≤ existingWidth) :
    emlGrowthCost newWidth ≤ stdGrowthCost existingWidth newWidth := by
  unfold emlGrowthCost stdGrowthCost; exact Nat.mul_le_mul_right newWidth hw


/-- [Section: ## §6. Knowledge Transfer] -/
def transferBenefit (sharedFraction : ℝ) (baseCost : ℕ) : ℝ :=
  (1 - sharedFraction) * ↑baseCost


theorem more_sharing_less_cost (s1 s2 : ℝ) (c : ℕ) (h : s1 ≤ s2) :
    transferBenefit s2 c ≤ transferBenefit s1 c := by
  unfold transferBenefit; nlinarith [Nat.cast_nonneg (α := ℝ) c]


end
