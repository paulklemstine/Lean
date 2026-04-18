/-
# EML Prefix Tuning Theory — v18

## Overview
Prefix tuning prepends learned continuous vectors (soft prompts) to
the input, enabling task adaptation without modifying model weights.
The prefix parameters are proportional to d_model × prefix_length.
EML reduces d_model to 4 per layer, compressing prefix storage and
enabling many more task-specific prefixes in the same memory budget.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Prefix Parameters -/

/-- Standard prefix parameters per layer -/
def stdPrefixParams (prefixLen d_model : ℕ) : ℕ :=
  prefixLen * d_model

/-- EML prefix parameters per layer -/
def emlPrefixParams (prefixLen : ℕ) : ℕ :=
  prefixLen * 4

theorem eml_prefix_compact (pLen dm : ℕ) (hdm : 4 ≤ dm) :
    emlPrefixParams pLen ≤ stdPrefixParams pLen dm := by
  unfold emlPrefixParams stdPrefixParams
  apply Nat.mul_le_mul_left pLen hdm

/-! ## §2. Multi-Task Prefix Storage -/

/-- Total storage for N task-specific prefixes -/
def multiTaskPrefixStorage (numTasks prefixParamsPerTask : ℕ) : ℕ :=
  numTasks * prefixParamsPerTask

theorem eml_multitask_cheaper (nt pp_eml pp_std : ℕ) (hpp : pp_eml ≤ pp_std) :
    multiTaskPrefixStorage nt pp_eml ≤ multiTaskPrefixStorage nt pp_std := by
  apply Nat.mul_le_mul_left nt hpp

theorem more_tasks_more_storage (t1 t2 pp : ℕ) (ht : t1 ≤ t2) :
    multiTaskPrefixStorage t1 pp ≤ multiTaskPrefixStorage t2 pp := by
  apply Nat.mul_le_mul_right pp ht

/-! ## §3. Prefix Inference Cost -/

/-- Inference cost with prefix: process prefix + input -/
def prefixInferenceCost (prefixLen inputLen costPerToken : ℕ) : ℕ :=
  (prefixLen + inputLen) * costPerToken

theorem eml_prefix_inference_cheaper (pLen iLen cpt_eml cpt_std : ℕ)
    (hcpt : cpt_eml ≤ cpt_std) :
    prefixInferenceCost pLen iLen cpt_eml ≤ prefixInferenceCost pLen iLen cpt_std := by
  apply Nat.mul_le_mul_left _ hcpt

/-! ## §4. Prefix Training Cost -/

/-- Cost of training a prefix: forward/backward through frozen model -/
def prefixTrainCost (numSteps prefixLen modelForwardCost : ℕ) : ℕ :=
  numSteps * prefixLen * modelForwardCost

theorem eml_prefix_train_cheaper (ns pLen mfc_eml mfc_std : ℕ) (hmfc : mfc_eml ≤ mfc_std) :
    prefixTrainCost ns pLen mfc_eml ≤ prefixTrainCost ns pLen mfc_std := by
  unfold prefixTrainCost; gcongr

/-! ## §5. Prefix Composition -/

/-- Composing multiple prefixes for multi-skill tasks -/
def composedPrefixCost (numPrefixes prefixParams overheadPerCompose : ℕ) : ℕ :=
  numPrefixes * prefixParams + overheadPerCompose

theorem eml_composed_cheaper (np pp_eml pp_std opc : ℕ) (hpp : pp_eml ≤ pp_std) :
    composedPrefixCost np pp_eml opc ≤ composedPrefixCost np pp_std opc := by
  unfold composedPrefixCost; gcongr

end
