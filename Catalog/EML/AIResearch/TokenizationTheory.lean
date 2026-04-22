import Mathlib

/-! # CatalogBuild.EML.AIResearch.TokenizationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 14
-/

noncomputable section

theorem larger_vocab_more_params_std (v1 v2 dm : ℕ) (hv : v1 ≤ v2) :
    stdEmbeddingParams v1 dm ≤ stdEmbeddingParams v2 dm := by
  unfold stdEmbeddingParams; exact Nat.mul_le_mul_right dm hv

/-- Output projection (LM head): d_model × vocab -/
def stdOutputProjParams (d_model vocabSize : ℕ) : ℕ := d_model * vocabSize

/-- EML output projection: 4 × vocab -/
def emlOutputProjParams (vocabSize : ℕ) : ℕ := 4 * vocabSize

/-- [Section: ## §2. Output Projection] -/
theorem eml_output_proj_compact (dm vs : ℕ) (hd : 4 ≤ dm) :
    emlOutputProjParams vs ≤ stdOutputProjParams dm vs := by
  unfold emlOutputProjParams stdOutputProjParams
  exact Nat.mul_le_mul_right vs hd

/-- Softmax cost: one exp per vocab entry -/
def softmaxCost (vocabSize : ℕ) : ℕ := vocabSize

/-- Full output distribution cost: projection + softmax -/
def outputDistributionCost (projCost vocabSize : ℕ) : ℕ :=
  projCost + softmaxCost vocabSize

/-- [Section: ## §3. Softmax over Vocabulary] -/
theorem eml_output_dist_cheaper (pc_eml pc_std vs : ℕ) (hpc : pc_eml ≤ pc_std) :
    outputDistributionCost pc_eml vs ≤ outputDistributionCost pc_std vs := by
  unfold outputDistributionCost softmaxCost; omega

/-- Byte-level: vocab = 256, no tokenizer needed -/
def byteLevelEmlParams : ℕ := emlEmbeddingParams 256

/-- [Section: ## §4. Byte-Level Tokenization] -/
theorem byte_level_small : byteLevelEmlParams = 1024 := by
  unfold byteLevelEmlParams emlEmbeddingParams; norm_num

/-- Standard byte-level with d=768 -/
def byteLevelStdParams (d_model : ℕ) : ℕ := stdEmbeddingParams 256 d_model

theorem byte_level_eml_vs_std (dm : ℕ) (hd : 4 ≤ dm) :
    byteLevelEmlParams ≤ byteLevelStdParams dm := by
  unfold byteLevelEmlParams byteLevelStdParams
  exact eml_embedding_compact 256 dm hd

/-- Multi-modal: text tokens + image tokens + audio tokens -/
def multiModalEmbeddingParams (textVocab imgTokens audioTokens d_model : ℕ) : ℕ :=
  (textVocab + imgTokens + audioTokens) * d_model

/-- [Section: ## §5. Multi-Modal Token Embedding] -/
def emlMultiModalParams (textVocab imgTokens audioTokens : ℕ) : ℕ :=
  (textVocab + imgTokens + audioTokens) * 4

theorem eml_multimodal_embedding_compact (tv it at_ dm : ℕ) (hd : 4 ≤ dm) :
    emlMultiModalParams tv it at_ ≤ multiModalEmbeddingParams tv it at_ dm := by
  unfold emlMultiModalParams multiModalEmbeddingParams
  exact Nat.mul_le_mul_left _ hd

end
