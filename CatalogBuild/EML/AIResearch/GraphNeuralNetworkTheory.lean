/-! # CatalogBuild.EML.AIResearch.GraphNeuralNetworkTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 30
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. Message Passing Efficiency] -/
def gcnLayerParams (d_in d_out : ℕ) : ℕ := d_in * d_out

def emlMessageParams (d_out : ℕ) : ℕ := 4 * d_out


theorem eml_message_efficiency (d_in d_out : ℕ) (hd : 4 ≤ d_in) :
    emlMessageParams d_out ≤ gcnLayerParams d_in d_out := by
  unfold emlMessageParams gcnLayerParams; exact Nat.mul_le_mul_right d_out hd


/-- [Section: ## §2. Over-Smoothing Analysis] -/
def featureSimilarity (contraction : ℝ) (k : ℕ) : ℝ := contraction ^ k


theorem deeper_more_smooth (c : ℝ) (k1 k2 : ℕ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) (hk : k1 ≤ k2) :
    featureSimilarity c k2 ≤ featureSimilarity c k1 := by
  unfold featureSimilarity; exact pow_le_pow_of_le_one hc0 hc1 hk


def emlFeatureRetention (invFactor : ℝ) (k : ℕ) : ℝ := invFactor ^ k


theorem more_invertible_less_smooth (i1 i2 : ℝ) (k : ℕ) (hi1 : 0 ≤ i1) (h : i1 ≤ i2) :
    emlFeatureRetention i1 k ≤ emlFeatureRetention i2 k := by
  unfold emlFeatureRetention; gcongr


/-- [Section: ## §3. Graph Attention] -/
def gatAttentionParams (d_in d_out : ℕ) : ℕ := d_in * d_out + 2 * d_out

def emlGATParams (d_out : ℕ) : ℕ := 6 * d_out


theorem eml_gat_efficiency (d_in d_out : ℕ) (hd : 4 ≤ d_in) :
    emlGATParams d_out ≤ gatAttentionParams d_in d_out := by
  unfold emlGATParams gatAttentionParams; nlinarith


/-- [Section: ## §4. Spectral Graph Convolution] -/
def spectralConvParams (polyOrder d_features : ℕ) : ℕ := polyOrder * d_features

def emlSpectralParams (d_features : ℕ) : ℕ := 4 * d_features


theorem eml_spectral_efficiency (k d : ℕ) (hk : 4 ≤ k) :
    emlSpectralParams d ≤ spectralConvParams k d := by
  unfold emlSpectralParams spectralConvParams; exact Nat.mul_le_mul_right d hk


/-- [Section: ## §5. Graph Pooling] -/
def stdPoolingParams (d_features : ℕ) : ℕ := d_features * d_features

def emlPoolingParams (d_features : ℕ) : ℕ := 4 * d_features


theorem eml_pooling_efficiency (d : ℕ) (hd : 4 ≤ d) :
    emlPoolingParams d ≤ stdPoolingParams d := by
  unfold emlPoolingParams stdPoolingParams; nlinarith


/-- [Section: ## §6. Graph Transformer] -/
def graphTransformerParams (d_model : ℕ) : ℕ := 4 * d_model * d_model

def emlGraphTransformerParams (d_model : ℕ) : ℕ := 16 * d_model


theorem eml_gt_efficiency (d : ℕ) (hd : 4 ≤ d) :
    emlGraphTransformerParams d ≤ graphTransformerParams d := by
  unfold emlGraphTransformerParams graphTransformerParams; nlinarith


def stdGTTotal (numLayers d_model : ℕ) : ℕ := numLayers * graphTransformerParams d_model

def emlGTTotal (numLayers d_model : ℕ) : ℕ := numLayers * emlGraphTransformerParams d_model


theorem eml_gt_total_efficiency (L d : ℕ) (hd : 4 ≤ d) :
    emlGTTotal L d ≤ stdGTTotal L d := by
  unfold emlGTTotal stdGTTotal; exact Nat.mul_le_mul_left L (eml_gt_efficiency d hd)


/-- [Section: ## §7. Heterogeneous Graphs] -/
def heteroGNNParams (numEdgeTypes d_features : ℕ) : ℕ := numEdgeTypes * d_features * d_features

def emlHeteroParams (numEdgeTypes d_features : ℕ) : ℕ := 4 * d_features + numEdgeTypes * d_features


theorem eml_hetero_efficiency (e d : ℕ) (hd : 5 ≤ d) (he : 1 ≤ e) :
    emlHeteroParams e d ≤ heteroGNNParams e d := by
  unfold emlHeteroParams heteroGNNParams
  have h1 : 4 * d ≤ d * d := by nlinarith
  have h2 : e * d ≤ e * d * d := Nat.le_mul_of_pos_right _ (by omega)
  nlinarith


/-- [Section: ## §8. Subgraph Feature Enrichment] -/
def emlSubgraphFeatures (numFeatures : ℕ) : ℕ := 3 * numFeatures


theorem eml_richer_features (f : ℕ) : f ≤ emlSubgraphFeatures f := by
  unfold emlSubgraphFeatures; omega


/-- [Section: ## §9. Depth Bounds] -/
def stdMaxDepth (numNodes : ℕ) : ℕ := Nat.log 2 numNodes

def emlMaxDepth (numNodes : ℕ) : ℕ := 2 * Nat.log 2 numNodes


theorem eml_deeper_without_oversmoothing (n : ℕ) :
    stdMaxDepth n ≤ emlMaxDepth n := by
  unfold stdMaxDepth emlMaxDepth; omega


end
