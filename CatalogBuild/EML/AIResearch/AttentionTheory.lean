/-! # CatalogBuild.EML.AIResearch.AttentionTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13
-/

import Mathlib

noncomputable section

def tempAttention (qk T : ℝ) (d : ℕ) : ℝ := Real.exp (qk / (T * Real.sqrt ↑d))


theorem higher_temp_smoother (qk T1 T2 : ℝ) (d : ℕ)
    (hqk : 0 ≤ qk) (hT1 : 0 < T1) (hT : T1 ≤ T2) (hd : (0 : ℝ) < Real.sqrt ↑d) :
    tempAttention qk T2 d ≤ tempAttention qk T1 d := by
  unfold tempAttention
  apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_left hqk (by positivity)
    (mul_le_mul_of_nonneg_right hT (le_of_lt hd))

/-! ## §2. Multi-Head Attention Efficiency -/


def standardMHAParams (numHeads d_model d_k : ℕ) : ℕ :=
  numHeads * (3 * d_model * d_k + d_k * d_model)


def emlMHAParams (numHeads d_k : ℕ) : ℕ := numHeads * (4 * d_k + 4 * d_k)


theorem eml_mha_efficiency (numHeads d_model d_k : ℕ) (hd : 8 ≤ d_model) :
    emlMHAParams numHeads d_k ≤ standardMHAParams numHeads d_model d_k := by
  unfold emlMHAParams standardMHAParams
  apply Nat.mul_le_mul_left; nlinarith

/-! ## §3. Attention Head Diversity -/


def headDiversity (numHeads : ℕ) : ℝ := 1 / Real.sqrt ↑numHeads


theorem more_heads_more_diverse (h1 h2 : ℕ) (hh1 : 0 < h1) (h : h1 ≤ h2) :
    headDiversity h2 ≤ headDiversity h1 := by
  unfold headDiversity; gcongr

/-! ## §4. Context Window and Memory -/


def standardAttentionMem (seqLen : ℕ) : ℕ := seqLen * seqLen

def emlLinearAttentionMem (seqLen d : ℕ) : ℕ := seqLen * d


theorem eml_attention_memory_savings (n d : ℕ) (hd : d ≤ n) :
    emlLinearAttentionMem n d ≤ standardAttentionMem n := by
  unfold emlLinearAttentionMem standardAttentionMem; exact Nat.mul_le_mul_left n hd

/-! ## §5. Key-Query Dimension Scaling -/


def emlKeyParams (d_k : ℕ) : ℕ := 4 * d_k

def stdKeyParams (d_model d_k : ℕ) : ℕ := d_model * d_k


theorem eml_key_efficiency (d_model d_k : ℕ) (hd : 4 ≤ d_model) :
    emlKeyParams d_k ≤ stdKeyParams d_model d_k := by
  unfold emlKeyParams stdKeyParams; exact Nat.mul_le_mul_right d_k hd


end
