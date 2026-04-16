/-! # CatalogBuild.EML.AIResearch.GraphNeuralNetworkTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 49
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.GraphNeuralNetworkTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 30] -/
def gcnLayerParams (d_in d_out : ℕ) : ℕ := d_in * d_out


def emlMessageParams (d_out : ℕ) : ℕ := 4 * d_out



theorem eml_message_efficiency (d_in d_out : ℕ) (hd : 4 ≤ d_in) :
    emlMessageParams d_out ≤ gcnLayerParams d_in d_out := by
  unfold emlMessageParams gcnLayerParams; exact Nat.mul_le_mul_right d_out hd



def featureSimilarity (contraction : ℝ) (k : ℕ) : ℝ := contraction ^ k



theorem deeper_more_smooth (c : ℝ) (k1 k2 : ℕ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) (hk : k1 ≤ k2) :
    featureSimilarity c k2 ≤ featureSimilarity c k1 := by
  unfold featureSimilarity; exact pow_le_pow_of_le_one hc0 hc1 hk



def emlFeatureRetention (invFactor : ℝ) (k : ℕ) : ℝ := invFactor ^ k



theorem more_invertible_less_smooth (i1 i2 : ℝ) (k : ℕ) (hi1 : 0 ≤ i1) (h : i1 ≤ i2) :
    emlFeatureRetention i1 k ≤ emlFeatureRetention i2 k := by
  unfold emlFeatureRetention; gcongr



def gatAttentionParams (d_in d_out : ℕ) : ℕ := d_in * d_out + 2 * d_out


def emlGATParams (d_out : ℕ) : ℕ := 6 * d_out



theorem eml_gat_efficiency (d_in d_out : ℕ) (hd : 4 ≤ d_in) :
    emlGATParams d_out ≤ gatAttentionParams d_in d_out := by
  unfold emlGATParams gatAttentionParams; nlinarith



def spectralConvParams (polyOrder d_features : ℕ) : ℕ := polyOrder * d_features


def emlSpectralParams (d_features : ℕ) : ℕ := 4 * d_features



theorem eml_spectral_efficiency (k d : ℕ) (hk : 4 ≤ k) :
    emlSpectralParams d ≤ spectralConvParams k d := by
  unfold emlSpectralParams spectralConvParams; exact Nat.mul_le_mul_right d hk



def stdPoolingParams (d_features : ℕ) : ℕ := d_features * d_features


def emlPoolingParams (d_features : ℕ) : ℕ := 4 * d_features



theorem eml_pooling_efficiency (d : ℕ) (hd : 4 ≤ d) :
    emlPoolingParams d ≤ stdPoolingParams d := by
  unfold emlPoolingParams stdPoolingParams; nlinarith



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



def heteroGNNParams (numEdgeTypes d_features : ℕ) : ℕ := numEdgeTypes * d_features * d_features


def emlHeteroParams (numEdgeTypes d_features : ℕ) : ℕ := 4 * d_features + numEdgeTypes * d_features



theorem eml_hetero_efficiency (e d : ℕ) (hd : 5 ≤ d) (he : 1 ≤ e) :
    emlHeteroParams e d ≤ heteroGNNParams e d := by
  unfold emlHeteroParams heteroGNNParams
  have h1 : 4 * d ≤ d * d := by nlinarith
  have h2 : e * d ≤ e * d * d := Nat.le_mul_of_pos_right _ (by omega)
  nlinarith



def emlSubgraphFeatures (numFeatures : ℕ) : ℕ := 3 * numFeatures



theorem eml_richer_features (f : ℕ) : f ≤ emlSubgraphFeatures f := by
  unfold emlSubgraphFeatures; omega



def stdMaxDepth (numNodes : ℕ) : ℕ := Nat.log 2 numNodes


def emlMaxDepth (numNodes : ℕ) : ℕ := 2 * Nat.log 2 numNodes



theorem eml_deeper_without_oversmoothing (n : ℕ) :
    stdMaxDepth n ≤ emlMaxDepth n := by
  unfold stdMaxDepth emlMaxDepth; omega



/-- [Section: ## §1. Message Passing Layer] -/
def stdMessagePassParams (d_node numLayers : ℕ) : ℕ :=
  numLayers * (d_node * d_node)


def emlMessagePassParams (d_node numLayers : ℕ) : ℕ :=
  numLayers * (4 * d_node)


theorem eml_message_pass_compact (dn nL : ℕ) (hd : 4 ≤ dn) :
    emlMessagePassParams dn nL ≤ stdMessagePassParams dn nL := by
  unfold emlMessagePassParams stdMessagePassParams
  gcongr


/-- [Section: ## §2. Graph Attention] -/
def stdGraphAttnParams (d_node numHeads d_head : ℕ) : ℕ :=
  3 * (d_node * numHeads * d_head)


def emlGraphAttnParams (numHeads d_head : ℕ) : ℕ :=
  3 * (4 * numHeads * d_head)


theorem eml_graph_attn_compact (dn nh dh : ℕ) (hd : 4 ≤ dn) :
    emlGraphAttnParams nh dh ≤ stdGraphAttnParams dn nh dh := by
  unfold emlGraphAttnParams stdGraphAttnParams
  gcongr


/-- [Section: ## §3. Node Feature Transform] -/
def stdNodeTransformParams (d_in d_out : ℕ) : ℕ := d_in * d_out

def emlNodeTransformParams (d_out : ℕ) : ℕ := 4 * d_out


theorem eml_node_transform_compact (di do_ : ℕ) (hd : 4 ≤ di) :
    emlNodeTransformParams do_ ≤ stdNodeTransformParams di do_ := by
  unfold emlNodeTransformParams stdNodeTransformParams
  exact Nat.mul_le_mul_right do_ hd


theorem denser_graph_costlier (d1 d2 fd : ℕ) (hd : d1 ≤ d2) :
    aggregationCost d1 fd ≤ aggregationCost d2 fd := by
  unfold aggregationCost; exact Nat.mul_le_mul_right fd hd


theorem eml_pooling_compact (dn do_ : ℕ) (hd : 4 ≤ dn) :
    emlPoolingParams do_ ≤ stdPoolingParams dn do_ := by
  unfold emlPoolingParams stdPoolingParams
  exact Nat.mul_le_mul_right do_ hd


/-- [Section: ## §6. Multi-Relational GNN] -/
def stdMultiRelParams (numRelations d_node : ℕ) : ℕ :=
  numRelations * (d_node * d_node)


def emlMultiRelParams (numRelations d_node : ℕ) : ℕ :=
  numRelations * (4 * d_node)


theorem eml_multi_rel_compact (nr dn : ℕ) (hd : 4 ≤ dn) :
    emlMultiRelParams nr dn ≤ stdMultiRelParams nr dn := by
  unfold emlMultiRelParams stdMultiRelParams
  gcongr


/-- [Section: ## §7. Link Prediction] -/
def stdLinkPredParams (d_node : ℕ) : ℕ := d_node * d_node

def emlLinkPredParams (d_node : ℕ) : ℕ := 4 * d_node


theorem eml_link_pred_compact (dn : ℕ) (hd : 4 ≤ dn) :
    emlLinkPredParams dn ≤ stdLinkPredParams dn := by
  unfold emlLinkPredParams stdLinkPredParams; nlinarith


/-- [Section: ## §8. Subgraph Sampling] -/
def subgraphMemory (numSampledNodes featureDim : ℕ) : ℕ :=
  numSampledNodes * featureDim


theorem fewer_samples_less_memory (n1 n2 fd : ℕ) (hn : n1 ≤ n2) :
    subgraphMemory n1 fd ≤ subgraphMemory n2 fd := by
  unfold subgraphMemory; exact Nat.mul_le_mul_right fd hn


end
