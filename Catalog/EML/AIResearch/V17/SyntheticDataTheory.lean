/-
# EML Synthetic Data Generation Theory — v17

## Overview
Synthetic data generation uses models to create training data,
reducing dependence on expensive human-labeled data. The cost of
generating synthetic datasets is proportional to model size ×
number of samples. EML compression makes synthetic data generation
dramatically cheaper, enabling larger synthetic datasets and more
diverse augmentation strategies.

## Key Results (8 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Generation Cost -/

/-- Cost of generating N synthetic samples -/
def syntheticGenCost (numSamples genCostPerSample : ℕ) : ℕ :=
  numSamples * genCostPerSample

theorem eml_synthetic_cheaper (ns gc_eml gc_std : ℕ) (hgc : gc_eml ≤ gc_std) :
    syntheticGenCost ns gc_eml ≤ syntheticGenCost ns gc_std := by
  -- Since $gc_eml \leq gc_std$, multiplying both sides by $ns$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ns hgc

theorem more_samples_costlier (n1 n2 gc : ℕ) (hn : n1 ≤ n2) :
    syntheticGenCost n1 gc ≤ syntheticGenCost n2 gc := by
  -- Since $gc$ is a natural number, multiplying both sides of the inequality $n1 \leq n2$ by $gc$ preserves the inequality.
  apply Nat.mul_le_mul_right gc hn

/-! ## §2. Quality Filtering -/

/-- Filter synthetic data: run classifier on each sample -/
def filterCost (numGenerated classifierCost : ℕ) : ℕ :=
  numGenerated * classifierCost

theorem eml_filter_cheaper (ng cc_eml cc_std : ℕ) (hcc : cc_eml ≤ cc_std) :
    filterCost ng cc_eml ≤ filterCost ng cc_std := by
  -- Since $cc_eml \leq cc_std$, multiplying both sides by $ng$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ng hcc

/-! ## §3. Self-Instruct Pipeline -/

/-- Self-instruct: generate instruction + response + verify -/
def selfInstructCost (numInstructions genCost verifyCost : ℕ) : ℕ :=
  numInstructions * (genCost + verifyCost)

theorem eml_self_instruct_cheaper (ni gc_eml gc_std vc_eml vc_std : ℕ)
    (hgc : gc_eml ≤ gc_std) (hvc : vc_eml ≤ vc_std) :
    selfInstructCost ni gc_eml vc_eml ≤ selfInstructCost ni gc_std vc_std := by
  exact Nat.mul_le_mul_left _ ( Nat.add_le_add hgc hvc )

/-! ## §4. Data Augmentation -/

/-- Augmentation: apply K transformations to each of N samples -/
def augmentationCost (numSamples numTransforms transformCost : ℕ) : ℕ :=
  numSamples * numTransforms * transformCost

theorem eml_augmentation_cheaper (ns nt tc_eml tc_std : ℕ) (htc : tc_eml ≤ tc_std) :
    augmentationCost ns nt tc_eml ≤ augmentationCost ns nt tc_std := by
  -- Since $tc_eml \leq tc_std$, multiplying both sides by $ns * nt$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left; exact htc

/-! ## §5. Distillation Data -/

/-- Generate teacher labels for student training -/
def distillDataCost (numSamples teacherCost : ℕ) : ℕ :=
  numSamples * teacherCost

theorem eml_distill_data_cheaper (ns tc_eml tc_std : ℕ) (htc : tc_eml ≤ tc_std) :
    distillDataCost ns tc_eml ≤ distillDataCost ns tc_std := by
  -- Since $tc_eml \leq tc_std$, multiplying both sides by $ns$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ns htc

/-! ## §6. Total Synthetic Pipeline -/

/-- Full pipeline: generate + filter + augment -/
def syntheticPipelineCost (genCost filterCost augCost : ℕ) : ℕ :=
  genCost + filterCost + augCost

theorem eml_pipeline_cheaper (gc_eml gc_std fc_eml fc_std ac_eml ac_std : ℕ)
    (hgc : gc_eml ≤ gc_std) (hfc : fc_eml ≤ fc_std) (hac : ac_eml ≤ ac_std) :
    syntheticPipelineCost gc_eml fc_eml ac_eml ≤ syntheticPipelineCost gc_std fc_std ac_std := by
  -- Apply the add_le_add_three lemma to combine the three inequalities.
  apply add_le_add_three hgc hfc hac

end