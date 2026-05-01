import Mathlib

/-! # CatalogBuild.EML.AIResearch.EnsembleTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 10
-/

noncomputable section

/-- Cost of training an ensemble of K models -/
def ensembleTrainCost (numMembers singleTrainCost : ℕ) : ℕ :=
  numMembers * singleTrainCost

/-- [Section: ## §1. Ensemble Training Cost] -/
theorem eml_ensemble_train_cheaper (k tc_eml tc_std : ℕ) (htc : tc_eml ≤ tc_std) :
    ensembleTrainCost k tc_eml ≤ ensembleTrainCost k tc_std := by
  apply Nat.mul_le_mul_left k htc

theorem more_members_costlier_train (k1 k2 tc : ℕ) (hk : k1 ≤ k2) :
    ensembleTrainCost k1 tc ≤ ensembleTrainCost k2 tc := by
  apply Nat.mul_le_mul_right tc hk

/-- Memory for K-member ensemble -/
def ensembleMemory (numMembers modelSize : ℕ) : ℕ :=
  numMembers * modelSize

/-- [Section: ## §2. Ensemble Memory] -/
theorem eml_ensemble_memory_compact (k ms_eml ms_std : ℕ) (hms : ms_eml ≤ ms_std) :
    ensembleMemory k ms_eml ≤ ensembleMemory k ms_std := by
  apply Nat.mul_le_mul_left k hms

/-- Inference cost: run all K members, aggregate -/
def ensembleInferenceCost (numMembers singleInfCost aggregationCost : ℕ) : ℕ :=
  numMembers * singleInfCost + aggregationCost

/-- [Section: ## §3. Ensemble Inference] -/
theorem eml_ensemble_inference_cheaper (k ic_eml ic_std ac : ℕ) (hic : ic_eml ≤ ic_std) :
    ensembleInferenceCost k ic_eml ac ≤ ensembleInferenceCost k ic_std ac := by
  unfold ensembleInferenceCost; gcongr

/-- Cost of uncertainty estimation via ensemble disagreement -/
def uncertaintyCost (numMembers forwardCost varianceCompCost : ℕ) : ℕ :=
  numMembers * forwardCost + varianceCompCost

/-- [Section: ## §4. Uncertainty Estimation] -/
theorem eml_uncertainty_cheaper (k fc_eml fc_std vc : ℕ) (hfc : fc_eml ≤ fc_std) :
    uncertaintyCost k fc_eml vc ≤ uncertaintyCost k fc_std vc := by
  unfold uncertaintyCost; gcongr

/-- [Section: ## §5. Ensemble Distillation] -/
theorem eml_distill_from_ensemble_cheaper (tic_eml tic_std stc ns : ℕ)
    (htic : tic_eml ≤ tic_std) :
    ensembleDistillCost tic_eml stc ns ≤ ensembleDistillCost tic_std stc ns := by
  unfold ensembleDistillCost; gcongr

end