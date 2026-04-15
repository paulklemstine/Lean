/-! # CatalogBuild.EML.AIResearch.MultiModalTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 21
-/

import Mathlib

noncomputable section

/-- Standard cross-modal projection: d₁ → d₂ dense matrix -/
def stdCrossModalParams (d_vision d_text : ℕ) : ℕ := d_vision * d_text


/-- EML cross-modal projection: 4 params per output dim -/
def emlCrossModalParams (d_text : ℕ) : ℕ := 4 * d_text


theorem eml_cross_modal_compact (dv dt : ℕ) (hv : 4 ≤ dv) :
    emlCrossModalParams dt ≤ stdCrossModalParams dv dt := by
  unfold emlCrossModalParams stdCrossModalParams; exact Nat.mul_le_mul_right dt hv


/-- InfoNCE-style contrastive similarity -/
def contrastiveSim (logit temperature : ℝ) : ℝ := Real.exp (logit / temperature)


theorem contrastive_sim_pos (l t : ℝ) (_ht : t ≠ 0) :
    0 < contrastiveSim l t := by
  unfold contrastiveSim; exact Real.exp_pos _


theorem higher_temp_flatter (z t1 t2 : ℝ) (hz : 0 ≤ z) (ht1 : 0 < t1) (ht : t1 ≤ t2) :
    contrastiveSim z t2 ≤ contrastiveSim z t1 := by
  unfold contrastiveSim; apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_left hz ht1 ht


/-- Early fusion: concatenate then project -/
def earlyFusionParams (d1 d2 d_fused : ℕ) : ℕ := (d1 + d2) * d_fused


theorem eml_fusion_compact (d1 d2 df : ℕ) (h : 4 ≤ d1 + d2) :
    emlFusionParams df ≤ earlyFusionParams d1 d2 df := by
  unfold emlFusionParams earlyFusionParams; exact Nat.mul_le_mul_right df h


/-- Standard ViT patch embedding + transformer -/
def vitEncoderParams (patchDim d_model numLayers : ℕ) : ℕ :=
  patchDim * d_model + numLayers * d_model * d_model


/-- EML vision encoder -/
def emlVitEncoderParams (d_model numLayers : ℕ) : ℕ :=
  4 * d_model + numLayers * 4 * d_model


theorem eml_vit_cheaper (pd dm nL : ℕ) (hpd : 4 ≤ pd) (hdm : 4 ≤ dm) :
    emlVitEncoderParams dm nL ≤ vitEncoderParams pd dm nL := by
  unfold emlVitEncoderParams vitEncoderParams
  have h1 : 4 * dm ≤ pd * dm := Nat.mul_le_mul_right dm hpd
  have h2 : nL * 4 ≤ nL * dm := Nat.mul_le_mul_left nL hdm
  have h3 : nL * 4 * dm ≤ nL * dm * dm := Nat.mul_le_mul_right dm h2
  omega


/-- Cross-attention between modalities -/
def multiModalAttnParams (d1 d2 : ℕ) : ℕ := 3 * d1 * d2 + d2 * d2


/-- EML multi-modal attention -/
def emlMultiModalAttnParams (d2 : ℕ) : ℕ := 16 * d2


theorem eml_mm_attn_cheaper (d1 d2 : ℕ) (hd1 : 4 ≤ d1) (hd2 : 4 ≤ d2) :
    emlMultiModalAttnParams d2 ≤ multiModalAttnParams d1 d2 := by
  unfold emlMultiModalAttnParams multiModalAttnParams; nlinarith


/-- Total cost for K modalities sharing a joint embedding space -/
def stdJointEmbeddingParams (numModalities avgModDim d_joint : ℕ) : ℕ :=
  numModalities * avgModDim * d_joint


def emlJointEmbeddingParams (numModalities d_joint : ℕ) : ℕ :=
  numModalities * 4 * d_joint


theorem eml_joint_embedding_cheaper (k avgD dj : ℕ) (hd : 4 ≤ avgD) :
    emlJointEmbeddingParams k dj ≤ stdJointEmbeddingParams k avgD dj := by
  unfold emlJointEmbeddingParams stdJointEmbeddingParams
  have : k * 4 ≤ k * avgD := Nat.mul_le_mul_left k hd
  exact Nat.mul_le_mul_right dj this


/-- Late fusion: separate encoders + small fusion layer -/
def lateFusionParams (enc1 enc2 fusionParams : ℕ) : ℕ := enc1 + enc2 + fusionParams


theorem eml_late_fusion_cheaper (e1_eml e1_std e2_eml e2_std f_eml f_std : ℕ)
    (h1 : e1_eml ≤ e1_std) (h2 : e2_eml ≤ e2_std) (hf : f_eml ≤ f_std) :
    lateFusionParams e1_eml e2_eml f_eml ≤ lateFusionParams e1_std e2_std f_std := by
  unfold lateFusionParams; omega


/-- Effective params with modality dropout (training robustness) -/
def modalityDropoutCost (activeModalities costPerModality : ℕ) : ℕ :=
  activeModalities * costPerModality


theorem fewer_modalities_cheaper (active1 active2 cost : ℕ) (ha : active1 ≤ active2) :
    modalityDropoutCost active1 cost ≤ modalityDropoutCost active2 cost := by
  unfold modalityDropoutCost; exact Nat.mul_le_mul_right cost ha


end
