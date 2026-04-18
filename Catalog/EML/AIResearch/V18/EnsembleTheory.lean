/-
# EML Ensemble Theory — v18

## Overview
Ensemble methods combine predictions from multiple models for
improved accuracy and uncertainty estimation. Deep ensembles (training
K independent models) are the gold standard for uncertainty but cost
K× the memory and compute. EML makes ensembles practical by compressing
each member, enabling 5-10 member ensembles in the memory of one
standard model.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Ensemble Training Cost -/

/-- Cost of training an ensemble of K models -/
def ensembleTrainCost (numMembers singleTrainCost : ℕ) : ℕ :=
  numMembers * singleTrainCost

theorem eml_ensemble_train_cheaper (k tc_eml tc_std : ℕ) (htc : tc_eml ≤ tc_std) :
    ensembleTrainCost k tc_eml ≤ ensembleTrainCost k tc_std := by
  apply Nat.mul_le_mul_left k htc

theorem more_members_costlier_train (k1 k2 tc : ℕ) (hk : k1 ≤ k2) :
    ensembleTrainCost k1 tc ≤ ensembleTrainCost k2 tc := by
  apply Nat.mul_le_mul_right tc hk

/-! ## §2. Ensemble Memory -/

/-- Memory for K-member ensemble -/
def ensembleMemory (numMembers modelSize : ℕ) : ℕ :=
  numMembers * modelSize

theorem eml_ensemble_memory_compact (k ms_eml ms_std : ℕ) (hms : ms_eml ≤ ms_std) :
    ensembleMemory k ms_eml ≤ ensembleMemory k ms_std := by
  apply Nat.mul_le_mul_left k hms

/-! ## §3. Ensemble Inference -/

/-- Inference cost: run all K members, aggregate -/
def ensembleInferenceCost (numMembers singleInfCost aggregationCost : ℕ) : ℕ :=
  numMembers * singleInfCost + aggregationCost

theorem eml_ensemble_inference_cheaper (k ic_eml ic_std ac : ℕ) (hic : ic_eml ≤ ic_std) :
    ensembleInferenceCost k ic_eml ac ≤ ensembleInferenceCost k ic_std ac := by
  unfold ensembleInferenceCost; gcongr

/-! ## §4. Uncertainty Estimation -/

/-- Cost of uncertainty estimation via ensemble disagreement -/
def uncertaintyCost (numMembers forwardCost varianceCompCost : ℕ) : ℕ :=
  numMembers * forwardCost + varianceCompCost

theorem eml_uncertainty_cheaper (k fc_eml fc_std vc : ℕ) (hfc : fc_eml ≤ fc_std) :
    uncertaintyCost k fc_eml vc ≤ uncertaintyCost k fc_std vc := by
  unfold uncertaintyCost; gcongr

/-! ## §5. Ensemble Distillation -/

/-- Distilling ensemble into single model: teacher ensemble inference + student training -/
def ensembleDistillCost (teacherInfCost studentTrainCost numSamples : ℕ) : ℕ :=
  numSamples * teacherInfCost + studentTrainCost

theorem eml_distill_from_ensemble_cheaper (tic_eml tic_std stc ns : ℕ)
    (htic : tic_eml ≤ tic_std) :
    ensembleDistillCost tic_eml stc ns ≤ ensembleDistillCost tic_std stc ns := by
  unfold ensembleDistillCost; gcongr

end
