/-! # CatalogBuild.EML.AIResearch.SyntheticDataTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 11
-/

import Mathlib

noncomputable section

/-- Cost of generating N synthetic samples -/
def syntheticGenCost (numSamples genCostPerSample : ℕ) : ℕ :=
  numSamples * genCostPerSample


/-- [Section: ## §1. Generation Cost] -/
theorem eml_synthetic_cheaper (ns gc_eml gc_std : ℕ) (hgc : gc_eml ≤ gc_std) :
    syntheticGenCost ns gc_eml ≤ syntheticGenCost ns gc_std := by
  -- Since $gc_eml \leq gc_std$, multiplying both sides by $ns$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ns hgc


/-- Filter synthetic data: run classifier on each sample -/
def filterCost (numGenerated classifierCost : ℕ) : ℕ :=
  numGenerated * classifierCost


/-- [Section: ## §2. Quality Filtering] -/
theorem eml_filter_cheaper (ng cc_eml cc_std : ℕ) (hcc : cc_eml ≤ cc_std) :
    filterCost ng cc_eml ≤ filterCost ng cc_std := by
  -- Since $cc_eml \leq cc_std$, multiplying both sides by $ng$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ng hcc


/-- Self-instruct: generate instruction + response + verify -/
def selfInstructCost (numInstructions genCost verifyCost : ℕ) : ℕ :=
  numInstructions * (genCost + verifyCost)


/-- [Section: ## §3. Self-Instruct Pipeline] -/
theorem eml_self_instruct_cheaper (ni gc_eml gc_std vc_eml vc_std : ℕ)
    (hgc : gc_eml ≤ gc_std) (hvc : vc_eml ≤ vc_std) :
    selfInstructCost ni gc_eml vc_eml ≤ selfInstructCost ni gc_std vc_std := by
  exact Nat.mul_le_mul_left _ ( Nat.add_le_add hgc hvc )


/-- Augmentation: apply K transformations to each of N samples -/
def augmentationCost (numSamples numTransforms transformCost : ℕ) : ℕ :=
  numSamples * numTransforms * transformCost


/-- [Section: ## §4. Data Augmentation] -/
theorem eml_augmentation_cheaper (ns nt tc_eml tc_std : ℕ) (htc : tc_eml ≤ tc_std) :
    augmentationCost ns nt tc_eml ≤ augmentationCost ns nt tc_std := by
  -- Since $tc_eml \leq tc_std$, multiplying both sides by $ns * nt$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left; exact htc


/-- Generate teacher labels for student training -/
def distillDataCost (numSamples teacherCost : ℕ) : ℕ :=
  numSamples * teacherCost


/-- [Section: ## §5. Distillation Data] -/
theorem eml_distill_data_cheaper (ns tc_eml tc_std : ℕ) (htc : tc_eml ≤ tc_std) :
    distillDataCost ns tc_eml ≤ distillDataCost ns tc_std := by
  -- Since $tc_eml \leq tc_std$, multiplying both sides by $ns$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ns htc


/-- Full pipeline: generate + filter + augment -/
def syntheticPipelineCost (genCost filterCost augCost : ℕ) : ℕ :=
  genCost + filterCost + augCost


end
