import Mathlib

/-! # CatalogBuild.EML.AIResearch.SparseAutoencoderTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 15
-/

noncomputable section

/-- Standard SAE: encoder + decoder -/
def stdSAEParams (d_model d_sae : ℕ) : ℕ :=
  d_model * d_sae + d_sae * d_model  -- encoder + decoder

/-- EML SAE: compressed encoder + decoder -/
def emlSAEParams (d_sae : ℕ) : ℕ :=
  4 * d_sae + 4 * d_sae  -- encoder + decoder

/-- [Section: ## §1. SAE Architecture] -/
theorem eml_sae_compact (dm dsae : ℕ) (hd : 4 ≤ dm) :
    emlSAEParams dsae ≤ stdSAEParams dm dsae := by
  unfold emlSAEParams stdSAEParams; nlinarith

/-- Larger dictionaries → more features, more params -/
theorem larger_expansion_more_sae_params (dm d1 d2 : ℕ) (hd : d1 ≤ d2) :
    stdSAEParams dm d1 ≤ stdSAEParams dm d2 := by
  unfold stdSAEParams; nlinarith

/-- Cost to extract activations from one layer -/
def extractionCost (numTokens d_model : ℕ) : ℕ := numTokens * d_model

/-- Cost over all layers -/
def fullExtractionCost (numTokens numLayers d_model : ℕ) : ℕ :=
  numLayers * (numTokens * d_model)

/-- [Section: ## §3. Activation Extraction] -/
theorem eml_extraction_cheaper (nt nL dm_eml dm_std : ℕ) (hd : dm_eml ≤ dm_std) :
    fullExtractionCost nt nL dm_eml ≤ fullExtractionCost nt nL dm_std := by
  unfold fullExtractionCost; gcongr

/-- L1 sparsity penalty cost -/
def sparsityPenaltyCost (d_sae batchSize : ℕ) : ℕ := batchSize * d_sae

/-- [Section: ## §4. Sparsity Penalty] -/
theorem smaller_dict_cheaper_penalty (dsae1 dsae2 bs : ℕ) (hd : dsae1 ≤ dsae2) :
    sparsityPenaltyCost dsae1 bs ≤ sparsityPenaltyCost dsae2 bs := by
  unfold sparsityPenaltyCost; exact Nat.mul_le_mul_left bs hd

/-- Cost of ablating one feature and measuring effect -/
def ablationStudyCost (numFeatures numTestSamples forwardCost : ℕ) : ℕ :=
  numFeatures * (numTestSamples * forwardCost)

/-- [Section: ## §5. Feature Ablation Studies] -/
theorem eml_ablation_cheaper (nf nts fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    ablationStudyCost nf nts fc_eml ≤ ablationStudyCost nf nts fc_std := by
  unfold ablationStudyCost; gcongr

/-- Track features across layers: compute similarity per layer pair -/
def crossLayerTrackingCost (numLayers d_sae : ℕ) : ℕ :=
  numLayers * numLayers * d_sae

/-- [Section: ## §6. Cross-Layer Feature Tracking] -/
theorem tracking_grows_quadratically (nL dsae : ℕ) :
    crossLayerTrackingCost nL dsae = nL ^ 2 * dsae := by
  unfold crossLayerTrackingCost; ring

/-- Total: extraction + SAE training + ablation -/
def interpPipelineCost (extractCost saeCost ablationCost : ℕ) : ℕ :=
  extractCost + saeCost + ablationCost

/-- [Section: ## §7. Full Interpretability Pipeline] -/
theorem eml_interp_pipeline_cheaper (ec_eml ec_std sc ac_eml ac_std : ℕ)
    (hec : ec_eml ≤ ec_std) (hac : ac_eml ≤ ac_std) :
    interpPipelineCost ec_eml sc ac_eml ≤ interpPipelineCost ec_std sc ac_std := by
  unfold interpPipelineCost; omega

end