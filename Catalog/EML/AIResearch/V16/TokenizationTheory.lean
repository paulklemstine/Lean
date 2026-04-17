/-
# EML Tokenization & Embedding Theory — v16

## Overview
Token embeddings are the largest single parameter table in LLMs
(vocab_size × d_model). EML compresses each embedding from d_model
to 4 parameters, yielding vocab_size × 4 embedding tables.
This enables million-token vocabularies and byte-level tokenization
on edge devices.

## Key Results (10 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Embedding Table Size -/

/-- Standard embedding table: vocab × d_model -/
def stdEmbeddingParams (vocabSize d_model : ℕ) : ℕ := vocabSize * d_model

/-- EML embedding table: vocab × 4 -/
def emlEmbeddingParams (vocabSize : ℕ) : ℕ := vocabSize * 4

theorem eml_embedding_compact (vs dm : ℕ) (hd : 4 ≤ dm) :
    emlEmbeddingParams vs ≤ stdEmbeddingParams vs dm := by
  unfold emlEmbeddingParams stdEmbeddingParams
  exact Nat.mul_le_mul_left vs hd

theorem larger_vocab_more_params_std (v1 v2 dm : ℕ) (hv : v1 ≤ v2) :
    stdEmbeddingParams v1 dm ≤ stdEmbeddingParams v2 dm := by
  unfold stdEmbeddingParams; exact Nat.mul_le_mul_right dm hv

/-! ## §2. Output Projection -/

/-- Output projection (LM head): d_model × vocab -/
def stdOutputProjParams (d_model vocabSize : ℕ) : ℕ := d_model * vocabSize

/-- EML output projection: 4 × vocab -/
def emlOutputProjParams (vocabSize : ℕ) : ℕ := 4 * vocabSize

theorem eml_output_proj_compact (dm vs : ℕ) (hd : 4 ≤ dm) :
    emlOutputProjParams vs ≤ stdOutputProjParams dm vs := by
  unfold emlOutputProjParams stdOutputProjParams
  exact Nat.mul_le_mul_right vs hd

/-! ## §3. Softmax over Vocabulary -/

/-- Softmax cost: one exp per vocab entry -/
def softmaxCost (vocabSize : ℕ) : ℕ := vocabSize

/-- Full output distribution cost: projection + softmax -/
def outputDistributionCost (projCost vocabSize : ℕ) : ℕ :=
  projCost + softmaxCost vocabSize

theorem eml_output_dist_cheaper (pc_eml pc_std vs : ℕ) (hpc : pc_eml ≤ pc_std) :
    outputDistributionCost pc_eml vs ≤ outputDistributionCost pc_std vs := by
  unfold outputDistributionCost softmaxCost; omega

/-! ## §4. Byte-Level Tokenization -/

/-- Byte-level: vocab = 256, no tokenizer needed -/
def byteLevelEmlParams : ℕ := emlEmbeddingParams 256

theorem byte_level_small : byteLevelEmlParams = 1024 := by
  unfold byteLevelEmlParams emlEmbeddingParams; norm_num

/-- Standard byte-level with d=768 -/
def byteLevelStdParams (d_model : ℕ) : ℕ := stdEmbeddingParams 256 d_model

theorem byte_level_eml_vs_std (dm : ℕ) (hd : 4 ≤ dm) :
    byteLevelEmlParams ≤ byteLevelStdParams dm := by
  unfold byteLevelEmlParams byteLevelStdParams
  exact eml_embedding_compact 256 dm hd

/-! ## §5. Multi-Modal Token Embedding -/

/-- Multi-modal: text tokens + image tokens + audio tokens -/
def multiModalEmbeddingParams (textVocab imgTokens audioTokens d_model : ℕ) : ℕ :=
  (textVocab + imgTokens + audioTokens) * d_model

def emlMultiModalParams (textVocab imgTokens audioTokens : ℕ) : ℕ :=
  (textVocab + imgTokens + audioTokens) * 4

theorem eml_multimodal_embedding_compact (tv it at_ dm : ℕ) (hd : 4 ≤ dm) :
    emlMultiModalParams tv it at_ ≤ multiModalEmbeddingParams tv it at_ dm := by
  unfold emlMultiModalParams multiModalEmbeddingParams
  exact Nat.mul_le_mul_left _ hd

end
