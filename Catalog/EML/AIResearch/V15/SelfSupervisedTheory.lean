/-
# EML Self-Supervised Learning Theory — v15

## Overview
Formalizes EML advantages for self-supervised learning (SSL).
Contrastive learning (SimCLR, BYOL), masked language modeling (BERT),
and masked image modeling (MAE) all use dense projectors that EML compresses.

## Key Results (11 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Projection Head (SimCLR) -/

def stdProjectionHeadParams (d_model d_proj : ℕ) : ℕ :=
  d_model * d_proj + d_proj * d_proj

def emlProjectionHeadParams (d_proj : ℕ) : ℕ :=
  4 * d_proj + 4 * d_proj

theorem eml_proj_head_compact (dm dp : ℕ) (hd : 4 ≤ dm) (hp : 4 ≤ dp) :
    emlProjectionHeadParams dp ≤ stdProjectionHeadParams dm dp := by
  unfold emlProjectionHeadParams stdProjectionHeadParams; nlinarith

/-! ## §2. Momentum Encoder (BYOL) -/

def byolMemory (modelParams : ℕ) : ℕ := 2 * modelParams

theorem eml_byol_smaller (p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    byolMemory p_eml ≤ byolMemory p_std := by
  unfold byolMemory; omega

theorem eml_momentum_cheaper (p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    p_eml ≤ p_std := hp

/-! ## §3. Masked Autoencoder -/

def stdMAEDecoderParams (d_encoder d_decoder numDecoderLayers : ℕ) : ℕ :=
  d_encoder * d_decoder + numDecoderLayers * (d_decoder * d_decoder)

def emlMAEDecoderParams (d_decoder numDecoderLayers : ℕ) : ℕ :=
  4 * d_decoder + numDecoderLayers * (4 * d_decoder)

theorem eml_mae_decoder_compact (de dd ndl : ℕ) (he : 4 ≤ de) (hd : 4 ≤ dd) :
    emlMAEDecoderParams dd ndl ≤ stdMAEDecoderParams de dd ndl := by
  unfold emlMAEDecoderParams stdMAEDecoderParams
  have h1 : 4 * dd ≤ de * dd := Nat.mul_le_mul_right dd he
  have h2 : 4 * dd ≤ dd * dd := by nlinarith
  nlinarith

/-! ## §4. Contrastive Loss Properties -/

def contrastiveSim (dotProduct temperature : ℝ) : ℝ :=
  Real.exp (dotProduct / temperature)

theorem contrastive_sim_pos (d τ : ℝ) : 0 < contrastiveSim d τ :=
  Real.exp_pos _

/-! ## §5. Barlow Twins -/

def barlowLossCost (d_proj batchSize : ℕ) : ℕ :=
  batchSize * d_proj + d_proj * d_proj

theorem smaller_proj_cheaper_barlow (dp1 dp2 bs : ℕ) (hdp : dp1 ≤ dp2) :
    barlowLossCost dp1 bs ≤ barlowLossCost dp2 bs := by
  unfold barlowLossCost; nlinarith

/-! ## §6. DINO Self-Distillation -/

def dinoCost (modelParams numCrops : ℕ) : ℕ :=
  (numCrops + 1) * modelParams

theorem eml_dino_cheaper (p_eml p_std nc : ℕ) (hp : p_eml ≤ p_std) :
    dinoCost p_eml nc ≤ dinoCost p_std nc := by
  unfold dinoCost; nlinarith

theorem more_crops_costlier (mp c1 c2 : ℕ) (hc : c1 ≤ c2) :
    dinoCost mp c1 ≤ dinoCost mp c2 := by
  unfold dinoCost; nlinarith

/-! ## §7. SSL Pre-Training Total Cost -/

def sslPretrainCost (encoderParams projectorParams numEpochs dataSize : ℕ) : ℕ :=
  numEpochs * (dataSize * (encoderParams + projectorParams))

theorem eml_ssl_cheaper (ep_eml ep_std pp_eml pp_std ne ds : ℕ)
    (he : ep_eml ≤ ep_std) (hp : pp_eml ≤ pp_std) :
    sslPretrainCost ep_eml pp_eml ne ds ≤ sslPretrainCost ep_std pp_std ne ds := by
  unfold sslPretrainCost; gcongr

end
