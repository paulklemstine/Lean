/-! # CatalogBuild.EML.AIResearch.PrefixTuningTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 11
-/

import Mathlib

noncomputable section

/-- Standard prefix parameters per layer -/
def stdPrefixParams (prefixLen d_model : ℕ) : ℕ :=
  prefixLen * d_model


/-- EML prefix parameters per layer -/
def emlPrefixParams (prefixLen : ℕ) : ℕ :=
  prefixLen * 4


/-- [Section: ## §1. Prefix Parameters] -/
theorem eml_prefix_compact (pLen dm : ℕ) (hdm : 4 ≤ dm) :
    emlPrefixParams pLen ≤ stdPrefixParams pLen dm := by
  unfold emlPrefixParams stdPrefixParams
  apply Nat.mul_le_mul_left pLen hdm


/-- Total storage for N task-specific prefixes -/
def multiTaskPrefixStorage (numTasks prefixParamsPerTask : ℕ) : ℕ :=
  numTasks * prefixParamsPerTask


/-- [Section: ## §2. Multi-Task Prefix Storage] -/
theorem eml_multitask_cheaper (nt pp_eml pp_std : ℕ) (hpp : pp_eml ≤ pp_std) :
    multiTaskPrefixStorage nt pp_eml ≤ multiTaskPrefixStorage nt pp_std := by
  apply Nat.mul_le_mul_left nt hpp


/-- [Section: # CatalogBuild.EML.AIResearch.PrefixTuningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 11] -/
theorem more_tasks_more_storage (t1 t2 pp : ℕ) (ht : t1 ≤ t2) :
    multiTaskPrefixStorage t1 pp ≤ multiTaskPrefixStorage t2 pp := by
  apply Nat.mul_le_mul_right pp ht


/-- Inference cost with prefix: process prefix + input -/
def prefixInferenceCost (prefixLen inputLen costPerToken : ℕ) : ℕ :=
  (prefixLen + inputLen) * costPerToken


/-- [Section: ## §3. Prefix Inference Cost] -/
theorem eml_prefix_inference_cheaper (pLen iLen cpt_eml cpt_std : ℕ)
    (hcpt : cpt_eml ≤ cpt_std) :
    prefixInferenceCost pLen iLen cpt_eml ≤ prefixInferenceCost pLen iLen cpt_std := by
  apply Nat.mul_le_mul_left _ hcpt


/-- Cost of training a prefix: forward/backward through frozen model -/
def prefixTrainCost (numSteps prefixLen modelForwardCost : ℕ) : ℕ :=
  numSteps * prefixLen * modelForwardCost


/-- [Section: ## §4. Prefix Training Cost] -/
theorem eml_prefix_train_cheaper (ns pLen mfc_eml mfc_std : ℕ) (hmfc : mfc_eml ≤ mfc_std) :
    prefixTrainCost ns pLen mfc_eml ≤ prefixTrainCost ns pLen mfc_std := by
  unfold prefixTrainCost; gcongr


/-- Composing multiple prefixes for multi-skill tasks -/
def composedPrefixCost (numPrefixes prefixParams overheadPerCompose : ℕ) : ℕ :=
  numPrefixes * prefixParams + overheadPerCompose


end
