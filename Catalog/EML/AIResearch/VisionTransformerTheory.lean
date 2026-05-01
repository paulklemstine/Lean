import Mathlib

/-! # CatalogBuild.EML.AIResearch.VisionTransformerTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 25
-/

noncomputable section

/-- Standard patch embedding: (P²·C) → d_model dense projection -/
def stdPatchEmbedParams (patchSize channels d_model : ℕ) : ℕ :=
  patchSize * patchSize * channels * d_model

/-- EML patch embedding: 4 params per model dimension -/
def emlPatchEmbedParams (d_model : ℕ) : ℕ := 4 * d_model

/-- [Section: # CatalogBuild.EML.AIResearch.VisionTransformerTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 25] -/
theorem eml_patch_embed_compact (p c dm : ℕ) (_hp : 1 ≤ p) (_hc : 1 ≤ c) (hpc : 4 ≤ p * p * c) :
    emlPatchEmbedParams dm ≤ stdPatchEmbedParams p c dm := by
  unfold emlPatchEmbedParams stdPatchEmbedParams
  calc 4 * dm ≤ p * p * c * dm := Nat.mul_le_mul_right dm hpc
    _ = p * (p * c * dm) := by ring_nf
    _ = p * (p * (c * dm)) := by ring_nf
    _ = p * p * (c * dm) := by ring_nf
    _ = p * p * c * dm := by ring_nf

/-- Learnable position encoding: numPatches × d_model parameters -/
def stdPosEncParams (numPatches d_model : ℕ) : ℕ := numPatches * d_model

/-- EML position encoding: sinusoidal with 4 params per dim -/
def emlPosEncParams (d_model : ℕ) : ℕ := 4 * d_model

/-- [Section: # CatalogBuild.EML.AIResearch.VisionTransformerTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 25] -/
theorem eml_pos_enc_compact (np dm : ℕ) (hn : 4 ≤ np) :
    emlPosEncParams dm ≤ stdPosEncParams np dm := by
  unfold emlPosEncParams stdPosEncParams; exact Nat.mul_le_mul_right dm hn

/-- Standard self-attention: Q, K, V projections + output -/
def stdSelfAttnParams (d_model : ℕ) : ℕ := 4 * d_model * d_model

/-- EML self-attention: 4 params per head dimension -/
def emlSelfAttnParams (d_model : ℕ) : ℕ := 16 * d_model

theorem eml_self_attn_compact (dm : ℕ) (hd : 4 ≤ dm) :
    emlSelfAttnParams dm ≤ stdSelfAttnParams dm := by
  unfold emlSelfAttnParams stdSelfAttnParams; nlinarith

/-- Standard FFN: two dense layers with expansion ratio -/
def stdFFNParams (d_model expandRatio : ℕ) : ℕ := 2 * d_model * (expandRatio * d_model)

theorem eml_ffn_compact (dm er : ℕ) (hd : 4 ≤ dm) :
    emlFFNParams dm er ≤ stdFFNParams dm er := by
  unfold emlFFNParams stdFFNParams
  have : 4 * er ≤ 2 * dm * er := by nlinarith
  calc 4 * er * dm = (4 * er) * dm := by ring
    _ ≤ (2 * dm * er) * dm := Nat.mul_le_mul_right dm this
    _ = 2 * dm * (er * dm) := by ring

/-- Standard classification: d_model → numClasses -/
def stdClassHeadParams (d_model numClasses : ℕ) : ℕ := d_model * numClasses

/-- EML classification head -/
def emlClassHeadParams (numClasses : ℕ) : ℕ := 4 * numClasses

theorem eml_class_head_compact (dm nc : ℕ) (hd : 4 ≤ dm) :
    emlClassHeadParams nc ≤ stdClassHeadParams dm nc := by
  unfold emlClassHeadParams stdClassHeadParams; exact Nat.mul_le_mul_right nc hd

/-- Cost of attention within windows -/
def windowAttnCost (numWindows windowSize d_model : ℕ) : ℕ :=
  numWindows * windowSize * windowSize * d_model

/-- Smaller window = cheaper -/
theorem smaller_window_cheaper (nw ws1 ws2 dm : ℕ) (hw : ws1 ≤ ws2) :
    windowAttnCost nw ws1 dm ≤ windowAttnCost nw ws2 dm := by
  unfold windowAttnCost
  have h1 : nw * ws1 ≤ nw * ws2 := Nat.mul_le_mul_left nw hw
  have h2 : nw * ws1 * ws1 ≤ nw * ws2 * ws2 := by
    calc nw * ws1 * ws1 ≤ nw * ws2 * ws1 := Nat.mul_le_mul_right ws1 h1
      _ ≤ nw * ws2 * ws2 := Nat.mul_le_mul_left (nw * ws2) hw
  exact Nat.mul_le_mul_right dm h2

/-- Feature pyramid: features at multiple scales -/
def multiScaleParams (numScales d_model : ℕ) : ℕ := numScales * d_model * d_model

def emlMultiScaleParams (numScales d_model : ℕ) : ℕ := numScales * 4 * d_model

theorem eml_multiscale_cheaper (ns dm : ℕ) (hd : 4 ≤ dm) :
    emlMultiScaleParams ns dm ≤ multiScaleParams ns dm := by
  unfold emlMultiScaleParams multiScaleParams
  have : ns * 4 ≤ ns * dm := Nat.mul_le_mul_left ns hd
  exact Nat.mul_le_mul_right dm this

/-- Swin-style patch merging: combine 4 patches into 1 -/
def patchMergeParams (d_in d_out : ℕ) : ℕ := 4 * d_in * d_out

def emlPatchMergeParams (d_out : ℕ) : ℕ := 4 * d_out

theorem eml_patch_merge_cheaper (di do_ : ℕ) (hd : 1 ≤ di) :
    emlPatchMergeParams do_ ≤ patchMergeParams di do_ := by
  unfold emlPatchMergeParams patchMergeParams
  calc 4 * do_ = 4 * 1 * do_ := by ring
    _ ≤ 4 * di * do_ := by nlinarith

/-- Total ViT: patch embed + pos enc + L×(attn + ffn) + cls head -/
def totalViTParams (L dm er nc np : ℕ) : ℕ :=
  stdPatchEmbedParams 16 3 dm + stdPosEncParams np dm +
  L * (stdSelfAttnParams dm + stdFFNParams dm er) + stdClassHeadParams dm nc

def totalEMLViTParams (L dm er nc : ℕ) : ℕ :=
  emlPatchEmbedParams dm + emlPosEncParams dm +
  L * (emlSelfAttnParams dm + emlFFNParams dm er) + emlClassHeadParams nc

theorem eml_vit_total_cheaper (L dm er nc np : ℕ) (hd : 4 ≤ dm) (hnp : 4 ≤ np)
    (_her : 1 ≤ er) :
    totalEMLViTParams L dm er nc ≤ totalViTParams L dm er nc np := by
  unfold totalEMLViTParams totalViTParams
  have h1 : emlPatchEmbedParams dm ≤ stdPatchEmbedParams 16 3 dm := by
    unfold emlPatchEmbedParams stdPatchEmbedParams; nlinarith
  have h2 : emlPosEncParams dm ≤ stdPosEncParams np dm := eml_pos_enc_compact np dm hnp
  have h3 : emlSelfAttnParams dm ≤ stdSelfAttnParams dm := eml_self_attn_compact dm hd
  have h4 : emlFFNParams dm er ≤ stdFFNParams dm er := eml_ffn_compact dm er hd
  have h5 : emlClassHeadParams nc ≤ stdClassHeadParams dm nc := eml_class_head_compact dm nc hd
  have h6 : L * (emlSelfAttnParams dm + emlFFNParams dm er) ≤
            L * (stdSelfAttnParams dm + stdFFNParams dm er) :=
    Nat.mul_le_mul_left L (Nat.add_le_add h3 h4)
  omega

end