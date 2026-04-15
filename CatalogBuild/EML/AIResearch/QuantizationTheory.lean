/-! # CatalogBuild.EML.AIResearch.QuantizationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 27
-/

import Mathlib

noncomputable section

def quantStep (lo hi : ℝ) (bits : ℕ) : ℝ := (hi - lo) / ↑(2 ^ bits)


theorem more_bits_finer (lo hi : ℝ) (b1 b2 : ℕ) (h : lo < hi) (hb : b1 ≤ b2) :
    quantStep lo hi b2 ≤ quantStep lo hi b1 := by
  unfold quantStep
  apply div_le_div_of_nonneg_left (by linarith) (by positivity)
  exact_mod_cast Nat.pow_le_pow_right (by omega) hb


def maxQuantError (lo hi : ℝ) (bits : ℕ) : ℝ := quantStep lo hi bits / 2


theorem more_bits_less_error (lo hi : ℝ) (b1 b2 : ℕ) (h : lo < hi) (hb : b1 ≤ b2) :
    maxQuantError lo hi b2 ≤ maxQuantError lo hi b1 := by
  unfold maxQuantError
  exact div_le_div_of_nonneg_right (more_bits_finer lo hi b1 b2 h hb) (by positivity)

/-! ## §2. EML Memory Savings -/


def stdModelMemory (params bits : ℕ) : ℕ := params * bits

def emlModelMemory (emlParams emlBits : ℕ) : ℕ := emlParams * emlBits


theorem eml_memory_savings (p_eml p_std b_eml b_std : ℕ)
    (hp : p_eml ≤ p_std) (hb : b_eml ≤ b_std) :
    emlModelMemory p_eml b_eml ≤ stdModelMemory p_std b_std := by
  unfold emlModelMemory stdModelMemory; exact Nat.mul_le_mul hp hb

/-! ## §3. Mixed-Precision Efficiency -/


def mixedPrecisionCost (sensLayers otherLayers highBits lowBits ppl : ℕ) : ℕ :=
  sensLayers * ppl * highBits + otherLayers * ppl * lowBits


def emlMixedPrecisionCost (sensLayers otherLayers highBits lowBits emlPpl : ℕ) : ℕ :=
  sensLayers * emlPpl * highBits + otherLayers * emlPpl * lowBits


theorem eml_mixed_precision_cheaper (sL oL hB lB pStd pEml : ℕ) (hp : pEml ≤ pStd) :
    emlMixedPrecisionCost sL oL hB lB pEml ≤ mixedPrecisionCost sL oL hB lB pStd := by
  unfold emlMixedPrecisionCost mixedPrecisionCost
  have h1 : sL * pEml ≤ sL * pStd := Nat.mul_le_mul_left sL hp
  have h2 : oL * pEml ≤ oL * pStd := Nat.mul_le_mul_left oL hp
  have h3 : sL * pEml * hB ≤ sL * pStd * hB := Nat.mul_le_mul_right hB h1
  have h4 : oL * pEml * lB ≤ oL * pStd * lB := Nat.mul_le_mul_right lB h2
  omega

/-! ## §4. Weight Pruning -/


def prunedParams (totalParams : ℕ) (sparsity : ℝ) : ℝ := ↑totalParams * (1 - sparsity)


theorem more_sparsity_fewer_params (p : ℕ) (s1 s2 : ℝ) (hs : s1 ≤ s2) :
    prunedParams p s2 ≤ prunedParams p s1 := by
  unfold prunedParams; nlinarith [Nat.cast_nonneg (α := ℝ) p]


theorem eml_pruned_advantage (p_eml p_std : ℕ) (s : ℝ) (hp : p_eml ≤ p_std) (hs1 : s ≤ 1) :
    prunedParams p_eml s ≤ prunedParams p_std s := by
  unfold prunedParams
  apply mul_le_mul_of_nonneg_right (by exact_mod_cast hp) (by linarith)

/-! ## §5. Latency -/


def modelLatency (params : ℕ) : ℕ := params


theorem eml_lower_latency (p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    modelLatency p_eml ≤ modelLatency p_std := hp

/-! ## §6. Activation Properties -/


theorem eml_exp_positive_range (x : ℝ) : 0 < Real.exp x := Real.exp_pos x


theorem eml_exp_monotone (x y : ℝ) (h : x ≤ y) : Real.exp x ≤ Real.exp y :=
  Real.exp_le_exp.mpr h

/-! ## §7. KV-Cache Compression -/


def kvCacheMemory (batchSize seqLen d_model : ℕ) : ℕ := 2 * batchSize * seqLen * d_model

def emlKVCacheMemory (batchSize seqLen d_model comprRatio : ℕ) : ℕ :=
  2 * batchSize * seqLen * d_model / comprRatio


theorem eml_kv_cache_smaller (b s d r : ℕ) :
    emlKVCacheMemory b s d r ≤ kvCacheMemory b s d := by
  unfold emlKVCacheMemory kvCacheMemory; exact Nat.div_le_self _ _

/-! ## §8. Sparse Computation -/


def denseComputeCost (params : ℕ) : ℕ := params

def sparseComputeCost (params sparseRatio : ℕ) : ℕ := params / sparseRatio


theorem sparse_cheaper_than_dense (p r : ℕ) :
    sparseComputeCost p r ≤ denseComputeCost p := by
  unfold sparseComputeCost denseComputeCost; exact Nat.div_le_self _ _


theorem eml_sparse_compounds (p_eml p_std r : ℕ) (hp : p_eml ≤ p_std) :
    sparseComputeCost p_eml r ≤ denseComputeCost p_std := by
  exact le_trans (Nat.div_le_self _ _) hp

/-! ## §9. Quantization-Aware Training -/


def qatCost (params epochs qatOverhead : ℕ) : ℕ := params * epochs * qatOverhead

def emlQATCost (emlParams epochs qatOverhead : ℕ) : ℕ := emlParams * epochs * qatOverhead


theorem eml_qat_cheaper (p_eml p_std e o : ℕ) (hp : p_eml ≤ p_std) :
    emlQATCost p_eml e o ≤ qatCost p_std e o := by
  unfold emlQATCost qatCost
  have : p_eml * e ≤ p_std * e := Nat.mul_le_mul_right e hp
  exact Nat.mul_le_mul_right o this


end
