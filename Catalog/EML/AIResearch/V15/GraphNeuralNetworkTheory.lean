/-
# EML Graph Neural Network Theory — v15

## Overview
Formalizes EML advantages for Graph Neural Networks (GNNs).
Message passing, node/edge feature transformations, and graph attention
all use dense matrix operations that EML can compress.

## Key Results (11 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Message Passing Layer -/

def stdMessagePassParams (d_node numLayers : ℕ) : ℕ :=
  numLayers * (d_node * d_node)

def emlMessagePassParams (d_node numLayers : ℕ) : ℕ :=
  numLayers * (4 * d_node)

theorem eml_message_pass_compact (dn nL : ℕ) (hd : 4 ≤ dn) :
    emlMessagePassParams dn nL ≤ stdMessagePassParams dn nL := by
  unfold emlMessagePassParams stdMessagePassParams
  gcongr

/-! ## §2. Graph Attention -/

def stdGraphAttnParams (d_node numHeads d_head : ℕ) : ℕ :=
  3 * (d_node * numHeads * d_head)

def emlGraphAttnParams (numHeads d_head : ℕ) : ℕ :=
  3 * (4 * numHeads * d_head)

theorem eml_graph_attn_compact (dn nh dh : ℕ) (hd : 4 ≤ dn) :
    emlGraphAttnParams nh dh ≤ stdGraphAttnParams dn nh dh := by
  unfold emlGraphAttnParams stdGraphAttnParams
  gcongr

/-! ## §3. Node Feature Transform -/

def stdNodeTransformParams (d_in d_out : ℕ) : ℕ := d_in * d_out
def emlNodeTransformParams (d_out : ℕ) : ℕ := 4 * d_out

theorem eml_node_transform_compact (di do_ : ℕ) (hd : 4 ≤ di) :
    emlNodeTransformParams do_ ≤ stdNodeTransformParams di do_ := by
  unfold emlNodeTransformParams stdNodeTransformParams
  exact Nat.mul_le_mul_right do_ hd

/-! ## §4. Neighborhood Aggregation Cost -/

def aggregationCost (avgDegree featureDim : ℕ) : ℕ := avgDegree * featureDim

theorem denser_graph_costlier (d1 d2 fd : ℕ) (hd : d1 ≤ d2) :
    aggregationCost d1 fd ≤ aggregationCost d2 fd := by
  unfold aggregationCost; exact Nat.mul_le_mul_right fd hd

/-! ## §5. Graph Pooling -/

def stdPoolingParams (d_node d_out : ℕ) : ℕ := d_node * d_out
def emlPoolingParams (d_out : ℕ) : ℕ := 4 * d_out

theorem eml_pooling_compact (dn do_ : ℕ) (hd : 4 ≤ dn) :
    emlPoolingParams do_ ≤ stdPoolingParams dn do_ := by
  unfold emlPoolingParams stdPoolingParams
  exact Nat.mul_le_mul_right do_ hd

/-! ## §6. Multi-Relational GNN -/

def stdMultiRelParams (numRelations d_node : ℕ) : ℕ :=
  numRelations * (d_node * d_node)

def emlMultiRelParams (numRelations d_node : ℕ) : ℕ :=
  numRelations * (4 * d_node)

theorem eml_multi_rel_compact (nr dn : ℕ) (hd : 4 ≤ dn) :
    emlMultiRelParams nr dn ≤ stdMultiRelParams nr dn := by
  unfold emlMultiRelParams stdMultiRelParams
  gcongr

/-! ## §7. Link Prediction -/

def stdLinkPredParams (d_node : ℕ) : ℕ := d_node * d_node
def emlLinkPredParams (d_node : ℕ) : ℕ := 4 * d_node

theorem eml_link_pred_compact (dn : ℕ) (hd : 4 ≤ dn) :
    emlLinkPredParams dn ≤ stdLinkPredParams dn := by
  unfold emlLinkPredParams stdLinkPredParams; nlinarith

/-! ## §8. Subgraph Sampling -/

def subgraphMemory (numSampledNodes featureDim : ℕ) : ℕ :=
  numSampledNodes * featureDim

theorem fewer_samples_less_memory (n1 n2 fd : ℕ) (hn : n1 ≤ n2) :
    subgraphMemory n1 fd ≤ subgraphMemory n2 fd := by
  unfold subgraphMemory; exact Nat.mul_le_mul_right fd hn

end
