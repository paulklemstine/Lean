/-! # CatalogBuild.EML.AIResearch.FoundationModelTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 20
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. Scaling Laws] -/
def chinchillaTokens (params : ℕ) : ℕ := 20 * params

def emlOptTokens (params : ℕ) : ℕ := 10 * params


theorem eml_half_data (N : ℕ) : emlOptTokens N ≤ chinchillaTokens N := by
  unfold emlOptTokens chinchillaTokens; omega


def trainingFLOPs (params tokens : ℕ) : ℕ := 6 * params * tokens


theorem eml_training_flops_savings (N : ℕ) :
    trainingFLOPs N (emlOptTokens N) ≤ trainingFLOPs N (chinchillaTokens N) := by
  unfold trainingFLOPs emlOptTokens chinchillaTokens; nlinarith


/-- [Section: ## §2. Fine-Tuning] -/
def loraParams (d_model r numLayers : ℕ) : ℕ := 2 * numLayers * d_model * r

def emlFinetuneParams (depth width : ℕ) : ℕ := 4 * depth * width


theorem eml_finetune_vs_lora (d_model r L depth width : ℕ)
    (h : 4 * depth * width ≤ 2 * L * d_model * r) :
    emlFinetuneParams depth width ≤ loraParams d_model r L := by
  unfold emlFinetuneParams loraParams; exact h


/-- [Section: ## §3. Emergent Capabilities] -/
def emergenceThreshold (taskComplexity : ℕ) : ℕ := 2 ^ taskComplexity

def emlEmergenceThreshold (taskComplexity : ℕ) : ℕ := taskComplexity


theorem eml_earlier_emergence (c : ℕ) (hc : 2 ≤ c) :
    emlEmergenceThreshold c < emergenceThreshold c := by
  unfold emlEmergenceThreshold emergenceThreshold; exact Nat.lt_two_pow_self


/-- [Section: ## §4. Multi-Modal Fusion] -/
def stdFusionParams (dimA dimB fusionDim : ℕ) : ℕ := (dimA + dimB) * fusionDim

def emlFusionParams (dimA dimB : ℕ) : ℕ := 4 * (dimA + dimB)


theorem eml_fusion_efficiency (dA dB fDim : ℕ) (hf : 4 ≤ fDim) :
    emlFusionParams dA dB ≤ stdFusionParams dA dB fDim := by
  unfold emlFusionParams stdFusionParams
  exact le_trans (Nat.mul_le_mul_right _ hf) (Nat.mul_comm fDim _ ▸ le_refl _)


def unsharedEmbeddingParams (vocabSize d_model : ℕ) : ℕ := 2 * vocabSize * d_model


theorem shared_embedding_saves (v d : ℕ) :
    embeddingParams v d ≤ unsharedEmbeddingParams v d := by
  unfold embeddingParams unsharedEmbeddingParams; nlinarith


/-- [Section: ## §6. Inference Throughput] -/
def modelThroughput (batchSize totalParams : ℕ) : ℝ := ↑batchSize / ↑totalParams


theorem smaller_model_faster (p1 p2 b : ℕ) (hp1 : 0 < p1)
    (hb : 0 < b) (hp : p1 ≤ p2) :
    modelThroughput b p2 ≤ modelThroughput b p1 := by
  unfold modelThroughput
  exact div_le_div_of_nonneg_left (by positivity) (by positivity) (by exact_mod_cast hp)


/-- [Section: ## §7. Carbon Footprint] -/
def carbonCost (flops energyPerFlop : ℕ) : ℕ := flops * energyPerFlop


theorem eml_greener (f_eml f_std e : ℕ) (hf : f_eml ≤ f_std) :
    carbonCost f_eml e ≤ carbonCost f_std e := by
  unfold carbonCost; exact Nat.mul_le_mul_right e hf


end
