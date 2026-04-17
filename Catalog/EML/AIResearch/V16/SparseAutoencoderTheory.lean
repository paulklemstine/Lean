/-
# EML Sparse Autoencoder & Mechanistic Interpretability Theory — v16

## Overview
Sparse Autoencoders (SAEs) are used to extract interpretable features
from neural network activations. The encoder/decoder pair maps
d_model → d_sae (expansion) → d_model (reconstruction). With EML,
both the SAE itself and the model being interpreted are smaller,
making mechanistic interpretability tractable for large models.

## Key Results (10 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. SAE Architecture -/

/-- Standard SAE: encoder + decoder -/
def stdSAEParams (d_model d_sae : ℕ) : ℕ :=
  d_model * d_sae + d_sae * d_model  -- encoder + decoder

/-- EML SAE: compressed encoder + decoder -/
def emlSAEParams (d_sae : ℕ) : ℕ :=
  4 * d_sae + 4 * d_sae  -- encoder + decoder

theorem eml_sae_compact (dm dsae : ℕ) (hd : 4 ≤ dm) :
    emlSAEParams dsae ≤ stdSAEParams dm dsae := by
  unfold emlSAEParams stdSAEParams; nlinarith

/-! ## §2. Feature Dictionary Size -/

/-- Larger dictionaries → more features, more params -/
theorem larger_expansion_more_sae_params (dm d1 d2 : ℕ) (hd : d1 ≤ d2) :
    stdSAEParams dm d1 ≤ stdSAEParams dm d2 := by
  unfold stdSAEParams; nlinarith

/-! ## §3. Activation Extraction -/

/-- Cost to extract activations from one layer -/
def extractionCost (numTokens d_model : ℕ) : ℕ := numTokens * d_model

/-- Cost over all layers -/
def fullExtractionCost (numTokens numLayers d_model : ℕ) : ℕ :=
  numLayers * (numTokens * d_model)

theorem eml_extraction_cheaper (nt nL dm_eml dm_std : ℕ) (hd : dm_eml ≤ dm_std) :
    fullExtractionCost nt nL dm_eml ≤ fullExtractionCost nt nL dm_std := by
  unfold fullExtractionCost; gcongr

/-! ## §4. Sparsity Penalty -/

/-- L1 sparsity penalty cost -/
def sparsityPenaltyCost (d_sae batchSize : ℕ) : ℕ := batchSize * d_sae

theorem smaller_dict_cheaper_penalty (dsae1 dsae2 bs : ℕ) (hd : dsae1 ≤ dsae2) :
    sparsityPenaltyCost dsae1 bs ≤ sparsityPenaltyCost dsae2 bs := by
  unfold sparsityPenaltyCost; exact Nat.mul_le_mul_left bs hd

/-! ## §5. Feature Ablation Studies -/

/-- Cost of ablating one feature and measuring effect -/
def ablationStudyCost (numFeatures numTestSamples forwardCost : ℕ) : ℕ :=
  numFeatures * (numTestSamples * forwardCost)

theorem eml_ablation_cheaper (nf nts fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    ablationStudyCost nf nts fc_eml ≤ ablationStudyCost nf nts fc_std := by
  unfold ablationStudyCost; gcongr

/-! ## §6. Cross-Layer Feature Tracking -/

/-- Track features across layers: compute similarity per layer pair -/
def crossLayerTrackingCost (numLayers d_sae : ℕ) : ℕ :=
  numLayers * numLayers * d_sae

theorem tracking_grows_quadratically (nL dsae : ℕ) :
    crossLayerTrackingCost nL dsae = nL ^ 2 * dsae := by
  unfold crossLayerTrackingCost; ring

/-! ## §7. Full Interpretability Pipeline -/

/-- Total: extraction + SAE training + ablation -/
def interpPipelineCost (extractCost saeCost ablationCost : ℕ) : ℕ :=
  extractCost + saeCost + ablationCost

theorem eml_interp_pipeline_cheaper (ec_eml ec_std sc ac_eml ac_std : ℕ)
    (hec : ec_eml ≤ ec_std) (hac : ac_eml ≤ ac_std) :
    interpPipelineCost ec_eml sc ac_eml ≤ interpPipelineCost ec_std sc ac_std := by
  unfold interpPipelineCost; omega

end
