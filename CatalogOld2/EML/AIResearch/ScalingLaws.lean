/-! # CatalogBuild.EML.AIResearch.ScalingLaws

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 45
-/

import Mathlib

noncomputable section

def scalingLaw (A alpha L_inf : ℝ) (N : ℕ) : ℝ := A * (↑N : ℝ) ^ (-alpha) + L_inf


theorem loss_bounded_below (A alpha L_inf : ℝ) (N : ℕ) (hA : 0 ≤ A) (hN : 0 < N)
    (halpha : 0 ≤ alpha) :
    L_inf ≤ scalingLaw A alpha L_inf N := by
  unfold scalingLaw
  linarith [mul_nonneg hA (rpow_nonneg (by positivity : (0 : ℝ) ≤ ↑N) (-alpha))]


def totalCompute (N D : ℕ) : ℕ := 6 * N * D

def chinchillaData (N : ℕ) : ℕ := 20 * N

def emlOptimalData (N : ℕ) : ℕ := 10 * N


theorem eml_less_data (N : ℕ) : emlOptimalData N ≤ chinchillaData N := by
  unfold emlOptimalData chinchillaData; omega


theorem eml_compute_savings (N : ℕ) :
    totalCompute N (emlOptimalData N) ≤ totalCompute N (chinchillaData N) := by
  unfold totalCompute emlOptimalData chinchillaData; nlinarith


theorem compute_linear_N (N1 N2 D : ℕ) (h : N1 ≤ N2) :
    totalCompute N1 D ≤ totalCompute N2 D := by
  unfold totalCompute; nlinarith


def capabilityThreshold (taskComplexity : ℕ) : ℕ := 2 ^ taskComplexity


theorem harder_tasks_bigger_models (c1 c2 : ℕ) (h : c1 ≤ c2) :
    capabilityThreshold c1 ≤ capabilityThreshold c2 := by
  unfold capabilityThreshold; exact Nat.pow_le_pow_right (by omega) h


def emlEffectiveCapacity (d w : ℕ) : ℕ := 3 ^ d * w

def mlpEffectiveCapacity (d w : ℕ) : ℕ := d * w


theorem eml_capacity_advantage (d w : ℕ) (hd : 2 ≤ d) (hw : 1 ≤ w) :
    mlpEffectiveCapacity d w ≤ emlEffectiveCapacity d w := by
  exact Nat.mul_le_mul_right _ ( Nat.le_of_lt ( Nat.recOn d ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; nlinarith ) )


def dominates (accA accB : ℝ) (paramsA paramsB : ℕ) : Prop :=
  accB ≤ accA ∧ paramsA ≤ paramsB


theorem dominates_trans (a1 a2 a3 : ℝ) (p1 p2 p3 : ℕ)
    (h12 : dominates a1 a2 p1 p2) (h23 : dominates a2 a3 p2 p3) :
    dominates a1 a3 p1 p3 := by
  exact ⟨le_trans h23.1 h12.1, le_trans h12.2 h23.2⟩


def emlFlops (d w : ℕ) : ℕ := 4 * d * w + 2 * d

def mlpFlops (d w : ℕ) : ℕ := d * w * w


theorem eml_flop_efficiency (d w : ℕ) (hw : 5 ≤ w) (hd : 0 < d) :
    emlFlops d w ≤ mlpFlops d w := by
  exact Nat.le_of_not_lt fun h => by unfold emlFlops mlpFlops at h; nlinarith [ mul_le_mul_left' hw d ] ;


def standardSamples (params : ℕ) (targetAcc : ℝ) : ℝ := ↑params / targetAcc


def emlSamples (params : ℕ) (targetAcc efficiencyFactor : ℝ) : ℝ :=
  ↑params / (targetAcc * efficiencyFactor)


theorem eml_data_efficiency (p : ℕ) (a eff : ℝ) (ha : 0 < a) (heff : 1 ≤ eff) :
    emlSamples p a eff ≤ standardSamples p a := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by nlinarith )


/-- EML parameters grow linearly: O(d) vs O(d²) for dense. -/
theorem eml_param_scaling_linear (d : ℕ) (hd : 5 ≤ d) :
    emlParams d ≤ denseParams d d := by
  unfold emlParams denseParams; nlinarith


/-- The compression factor for square layers is (d+1)/4. -/
theorem eml_compression_factor_sq (d : ℕ) (_hd : 1 ≤ d) :
    emlParams d * (d + 1) ≤ denseParams d d * 4 := by
  unfold emlParams denseParams; nlinarith


/-- Bits per float32 weight. -/
def bitsPerFloat32 : ℕ := 32


/-- Memory for a dense layer with float32 weights (in bits). -/
def denseMemoryBits (d_in d_out : ℕ) : ℕ := denseParams d_in d_out * bitsPerFloat32


/-- Memory for a crystallized EML layer with b bits per integer weight. -/
def emlMemoryBitsB (d_out bitsPerWeight : ℕ) : ℕ := emlParams d_out * bitsPerWeight


/-- FLOPs for dense matrix-vector multiply: 2 × d_in × d_out. -/
def denseFLOPs (d_in d_out : ℕ) : ℕ := 2 * d_in * d_out


/-- FLOPs for EML layer inference: 6 × d_out (mul, add, exp, mul, add, log per neuron). -/
def emlFLOPs (d_out : ℕ) : ℕ := 6 * d_out


/-- EML MoE has fewer parameters for d_model ≥ 4. -/
theorem eml_moe_param_savings (n d_model d_ff : ℕ) (hd : 4 ≤ d_model) :
    emlMoEParams n d_ff ≤ stdMoEParams n d_model d_ff := by
  unfold emlMoEParams stdMoEParams
  have h1 : 4 * d_ff ≤ 2 * d_model * d_ff := by nlinarith
  have h2 : 4 ≤ d_model := hd
  calc n * (4 * d_ff) + n * 4
      ≤ n * (2 * d_model * d_ff) + n * d_model := by
        apply Nat.add_le_add
        · exact Nat.mul_le_mul_left n h1
        · exact Nat.mul_le_mul_left n h2
    _ = _ := rfl


/-- Standard attention head parameters: 3 × d_model × d_head (Q, K, V projections). -/
def stdAttentionParams (d_model d_head : ℕ) : ℕ := 3 * d_model * d_head


/-- EML attention head: 3 × 4 × d_head (EML projections for Q, K, V). -/
def emlAttentionParams (d_head : ℕ) : ℕ := 3 * 4 * d_head


/-- EML attention uses fewer parameters for d_model ≥ 4. -/
theorem eml_attention_compression (d_model d_head : ℕ) (hd : 4 ≤ d_model) :
    emlAttentionParams d_head ≤ stdAttentionParams d_model d_head := by
  unfold emlAttentionParams stdAttentionParams; nlinarith


/-- Multi-head attention savings scale with number of heads. -/
theorem eml_multihead_savings (n_heads d_model d_head : ℕ) (hd : 4 ≤ d_model) :
    n_heads * emlAttentionParams d_head ≤ n_heads * stdAttentionParams d_model d_head :=
  Nat.mul_le_mul_left n_heads (eml_attention_compression d_model d_head hd)


/-- Standard transformer block parameters (attention + FFN). -/
def stdTransformerBlock (d_model d_head n_heads d_ff : ℕ) : ℕ :=
  n_heads * stdAttentionParams d_model d_head + 2 * denseParams d_model d_ff


/-- EML transformer block parameters. -/
def emlTransformerBlock (d_head n_heads d_ff : ℕ) : ℕ :=
  n_heads * emlAttentionParams d_head + 2 * emlParams d_ff


/-- EML transformer block uses fewer parameters (d_model ≥ 5). -/
theorem eml_transformer_compression (d_model d_head n_heads d_ff : ℕ)
    (hd : 5 ≤ d_model) :
    emlTransformerBlock d_head n_heads d_ff ≤
    stdTransformerBlock d_model d_head n_heads d_ff := by
  unfold emlTransformerBlock stdTransformerBlock
  apply Nat.add_le_add
  · exact eml_multihead_savings n_heads d_model d_head (by omega)
  · apply Nat.mul_le_mul_left
    unfold emlParams denseParams; nlinarith


/-- LLaMA 7B approximate config. -/
def llama7b_d_model : ℕ := 4096

def llama7b_d_head : ℕ := 128

def llama7b_n_heads : ℕ := 32

def llama7b_d_ff : ℕ := 11008

def llama7b_n_layers : ℕ := 32


/-- Standard LLaMA attention params per layer. -/
def llama7b_std_attn : ℕ := stdAttentionParams llama7b_d_model llama7b_d_head * llama7b_n_heads


/-- EML LLaMA attention params per layer. -/
def llama7b_eml_attn : ℕ := emlAttentionParams llama7b_d_head * llama7b_n_heads


/-- EML attention is 1024× smaller than standard for LLaMA-scale. -/
theorem llama_attention_ratio :
    llama7b_std_attn / llama7b_eml_attn = 1024 := by native_decide


/-- EML transformer block compression for LLaMA dimensions. -/
theorem llama_block_compression :
    emlTransformerBlock llama7b_d_head llama7b_n_heads llama7b_d_ff ≤
    stdTransformerBlock llama7b_d_model llama7b_d_head llama7b_n_heads llama7b_d_ff :=
  eml_transformer_compression _ _ _ _ (by norm_num [llama7b_d_model])


end
