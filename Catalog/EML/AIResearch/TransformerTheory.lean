/-! # CatalogBuild.EML.AIResearch.TransformerTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 19
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.TransformerTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 19] -/
def transformerFFNParams (d_model : ℕ) : ℕ := 2 * d_model * (4 * d_model)



/-- [Section: # CatalogBuild.EML.AIResearch.TransformerTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 19] -/
def emlFFNParams (d_model : ℕ) : ℕ := 4 * d_model * 4




theorem eml_ffn_efficiency (d_model : ℕ) (hd : 2 ≤ d_model) :
    emlFFNParams d_model ≤ transformerFFNParams d_model := by
  unfold emlFFNParams transformerFFNParams; nlinarith




def ffnCompressionRatio (d_model : ℕ) : ℕ := transformerFFNParams d_model / emlFFNParams d_model




theorem ffn_compression_512 : 16 ≤ ffnCompressionRatio 512 := by native_decide




def moeGatingParams (d_model numExperts : ℕ) : ℕ := d_model * numExperts



def emlMoeGatingParams (numExperts : ℕ) : ℕ := 4 * numExperts




theorem eml_moe_routing_efficiency (d_model numExperts : ℕ) (hd : 4 ≤ d_model) :
    emlMoeGatingParams numExperts ≤ moeGatingParams d_model numExperts := by
  unfold emlMoeGatingParams moeGatingParams; exact Nat.mul_le_mul_right numExperts hd




def stdInferenceFLOPs (d_model : ℕ) : ℕ :=
  2 * d_model * d_model + 2 * d_model * (4 * d_model)




def emlInferenceFLOPs (d_model : ℕ) : ℕ :=
  4 * d_model + 4 * d_model * 4




theorem eml_inference_efficiency (d_model : ℕ) (hd : 2 ≤ d_model) :
    emlInferenceFLOPs d_model ≤ stdInferenceFLOPs d_model := by
  unfold emlInferenceFLOPs stdInferenceFLOPs; nlinarith




/-- EML transformer layer: EML attention + EML FFN + layer norms. -/
def emlTransformerLayerParams (numHeads d_model d_k : ℕ) : ℕ :=
  numHeads * 8 * d_k + emlFFNParams d_model + 2 * d_model




/-- Standard transformer layer: 4 weight matrices (Q,K,V,O) per head. -/
def transformerLayerParams (numHeads d_model d_k : ℕ) : ℕ :=
  numHeads * 4 * d_model * d_k + transformerFFNParams d_model + 2 * d_model




theorem eml_transformer_layer_efficiency (numHeads d_model d_k : ℕ) (hd : 2 ≤ d_model) :
    emlTransformerLayerParams numHeads d_model d_k ≤ transformerLayerParams numHeads d_model d_k := by
  unfold emlTransformerLayerParams transformerLayerParams;
  unfold emlFFNParams transformerFFNParams;
  nlinarith [ Nat.mul_le_mul_left numHeads ( show 8 ≤ 4 * d_model by linarith ) ]




def stdTransformerTotal (numLayers d_model numHeads d_k vocabSize : ℕ) : ℕ :=
  numLayers * transformerLayerParams numHeads d_model d_k + vocabSize * d_model




def emlTransformerTotal (numLayers d_model numHeads d_k vocabSize : ℕ) : ℕ :=
  numLayers * emlTransformerLayerParams numHeads d_model d_k + vocabSize * d_model




theorem eml_transformer_total_efficiency (numLayers d_model numHeads d_k vocabSize : ℕ)
    (hd : 2 ≤ d_model) :
    emlTransformerTotal numLayers d_model numHeads d_k vocabSize ≤
    stdTransformerTotal numLayers d_model numHeads d_k vocabSize := by
  unfold emlTransformerTotal stdTransformerTotal; gcongr
  exact eml_transformer_layer_efficiency numHeads d_model d_k hd




def stdKVCacheMem (numLayers seqLen d_k numHeads : ℕ) : ℕ :=
  2 * numLayers * seqLen * d_k * numHeads




theorem kv_cache_compression (L n d h c : ℕ) :
    stdKVCacheMem L n d h / c ≤ stdKVCacheMem L n d h := Nat.div_le_self _ _




end
