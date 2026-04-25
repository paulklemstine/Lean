/-! # CatalogBuild.EML.AIResearch.ModelMergingTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Linear interpolation between two parameter vectors -/
def interpWeight (α w1 w2 : ℝ) : ℝ := (1 - α) * w1 + α * w2


/-- [Section: ## §1. Weight Interpolation] -/
theorem interp_at_zero (w1 w2 : ℝ) : interpWeight 0 w1 w2 = w1 := by
  unfold interpWeight; ring


/-- [Section: # CatalogBuild.EML.AIResearch.ModelMergingTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13] -/
theorem interp_at_one (w1 w2 : ℝ) : interpWeight 1 w1 w2 = w2 := by
  unfold interpWeight; ring


theorem interp_convex (α w1 w2 : ℝ) (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hw : w1 ≤ w2) : interpWeight α w1 w2 ∈ Set.Icc w1 w2 := by
  unfold interpWeight
  constructor
  · nlinarith
  · nlinarith


/-- Cost to merge n models: load + interpolate per parameter -/
def mergeCost (numModels modelParams : ℕ) : ℕ :=
  numModels * modelParams


theorem more_models_costlier (n1 n2 mp : ℕ) (hn : n1 ≤ n2) :
    mergeCost n1 mp ≤ mergeCost n2 mp := by
  unfold mergeCost; exact Nat.mul_le_mul_right mp hn


/-- Task vector: difference between fine-tuned and base model -/
def taskVectorSize (modelParams : ℕ) : ℕ := modelParams


/-- Total storage for k task vectors -/
def taskVectorStorage (numTasks modelParams : ℕ) : ℕ :=
  numTasks * modelParams


/-- [Section: ## §3. Task Arithmetic] -/
theorem eml_task_storage_cheaper (nt p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    taskVectorStorage nt p_eml ≤ taskVectorStorage nt p_std := by
  unfold taskVectorStorage; exact Nat.mul_le_mul_left nt hp


/-- After trimming low-magnitude weights, remaining count -/
def tiesRemainingParams (totalParams trimPercent : ℕ) : ℕ :=
  totalParams * (100 - trimPercent) / 100


/-- [Section: ## §4. TIES-Merging: Trim, Elect, Merge] -/
theorem trimming_reduces (tp trim : ℕ) (ht : trim ≤ 100) :
    tiesRemainingParams tp trim ≤ tp := by
  unfold tiesRemainingParams
  calc tp * (100 - trim) / 100 ≤ tp * 100 / 100 := by
        apply Nat.div_le_div_right; gcongr; omega
    _ = tp := by omega


/-- After randomly dropping parameters, sparsified count -/
def dareSparsifiedParams (totalParams dropRate : ℕ) : ℕ :=
  totalParams * (100 - dropRate) / 100


/-- [Section: ## §5. DARE: Drop And REscale] -/
theorem dare_reduces (tp dr : ℕ) (hd : dr ≤ 100) :
    dareSparsifiedParams tp dr ≤ tp := by
  unfold dareSparsifiedParams
  calc tp * (100 - dr) / 100 ≤ tp * 100 / 100 := by
        apply Nat.div_le_div_right; gcongr; omega
    _ = tp := by omega


end
