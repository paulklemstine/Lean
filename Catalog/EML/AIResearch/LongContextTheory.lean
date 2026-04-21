/-! # CatalogBuild.EML.AIResearch.LongContextTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 15
-/

import Mathlib

noncomputable section

/-- Standard KV-cache size: 2 (K+V) × numLayers × seqLen × d_head × numHeads -/
def stdKVCacheSize (numLayers seqLen d_head numHeads : ℕ) : ℕ :=
  2 * numLayers * seqLen * d_head * numHeads


/-- EML KV-cache: compressed key/value representations -/
def emlKVCacheSize (numLayers seqLen numHeads : ℕ) : ℕ :=
  2 * numLayers * seqLen * 4 * numHeads


/-- [Section: ## §1. KV-Cache for Long Context] -/
theorem eml_kv_cache_compact (nL sL dh nH : ℕ) (hdh : 4 ≤ dh) :
    emlKVCacheSize nL sL nH ≤ stdKVCacheSize nL sL dh nH := by
  -- Since $dh \geq 4$, we have $4 \leq dh$, which implies $2 * nL * sL * 4 * nH \leq 2 * nL * sL * dh * nH$.
  have h_ineq : 4 ≤ dh := by
    -- Since $dh \geq 4$, we have $4 \leq dh$ by definition.
    exact hdh;
  -- Since $4 \leq dh$, multiplying both sides by $2 * nL * sL * nH$ (which are all positive) preserves the inequality.
  apply mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left h_ineq (by positivity)) (by positivity)


/-- [Section: ## §2. Context Length Scaling] -/
theorem longer_context_more_cache (nL s1 s2 dh nH : ℕ) (hs : s1 ≤ s2) :
    stdKVCacheSize nL s1 dh nH ≤ stdKVCacheSize nL s2 dh nH := by
  exact Nat.mul_le_mul ( Nat.mul_le_mul ( Nat.mul_le_mul_left _ hs ) le_rfl ) le_rfl


/-- Sliding window: only attend to last W tokens -/
def slidingWindowCost (windowSize d_model : ℕ) : ℕ :=
  windowSize * d_model


/-- Full attention cost for comparison -/
def fullAttentionCost (seqLen d_model : ℕ) : ℕ :=
  seqLen * d_model


/-- [Section: ## §3. Sliding Window Attention] -/
theorem sliding_window_cheaper (W sL dm : ℕ) (hW : W ≤ sL) :
    slidingWindowCost W dm ≤ fullAttentionCost sL dm := by
  -- Since $W \leq sL$, multiplying both sides by $dm$ (which is positive) preserves the inequality.
  apply Nat.mul_le_mul_right dm hW


/-- Compress context to fixed-size summary -/
def contextCompressionCost (seqLen compressorCost summarySize : ℕ) : ℕ :=
  seqLen * compressorCost + summarySize


/-- [Section: ## §4. Context Compression / Summarization] -/
theorem eml_compression_cheaper (sL cc_eml cc_std ss : ℕ) (hcc : cc_eml ≤ cc_std) :
    contextCompressionCost sL cc_eml ss ≤ contextCompressionCost sL cc_std ss := by
  -- Since $sL$ is non-negative, multiplying both sides of $cc_eml \leq cc_std$ by $sL$ preserves the inequality.
  have h_mul : sL * cc_eml ≤ sL * cc_std := by
    -- Since $sL$ is a natural number, multiplying both sides of the inequality $cc_eml \leq cc_std$ by $sL$ preserves the inequality.
    apply Nat.mul_le_mul_left sL hcc
  generalize_proofs at *; (exact Nat.add_le_add_right h_mul ss)


/-- Process long context in chunks -/
def chunkedProcessCost (numChunks chunkSize perTokenCost : ℕ) : ℕ :=
  numChunks * chunkSize * perTokenCost


/-- [Section: ## §5. Chunked Processing] -/
theorem eml_chunked_cheaper (nc cs ptc_eml ptc_std : ℕ) (hptc : ptc_eml ≤ ptc_std) :
    chunkedProcessCost nc cs ptc_eml ≤ chunkedProcessCost nc cs ptc_std := by
  -- Since $ptc_eml \leq ptc_std$, multiplying both sides by $nc * cs$ (which is positive) preserves the inequality.
  apply Nat.mul_le_mul_left (nc * cs) hptc


/-- Prefix cache hit: reuse cached KV for shared prefix -/
def prefixCacheSavings (prefixLen d_model numLayers : ℕ) : ℕ :=
  prefixLen * d_model * numLayers


/-- [Section: ## §6. Prefix Caching] -/
theorem longer_prefix_more_savings (p1 p2 dm nL : ℕ) (hp : p1 ≤ p2) :
    prefixCacheSavings p1 dm nL ≤ prefixCacheSavings p2 dm nL := by
  -- Since $p1 \leq p2$, multiplying both sides by $dm$ and $nL$ (which are non-negative) preserves the inequality.
  apply Nat.mul_le_mul_right nL (Nat.mul_le_mul_right dm hp)


/-- Total: encoding + KV-cache + attention -/
def longContextTotalCost (encodeCost cacheCost attentionCost : ℕ) : ℕ :=
  encodeCost + cacheCost + attentionCost


/-- [Section: ## §7. Total Long-Context Cost] -/
theorem eml_long_context_cheaper (ec_eml ec_std cc_eml cc_std ac : ℕ)
    (hec : ec_eml ≤ ec_std) (hcc : cc_eml ≤ cc_std) :
    longContextTotalCost ec_eml cc_eml ac ≤ longContextTotalCost ec_std cc_std ac := by
  -- By adding the inequalities ec_eml ≤ ec_std and cc_eml ≤ cc_std, we get ec_eml + cc_eml ≤ ec_std + cc_std.
  have h_sum : ec_eml + cc_eml ≤ ec_std + cc_std := by
    linarith [hec, hcc];
  -- Since the attention cost is the same in both cases, adding it to both sides of the inequality h_sum preserves the inequality.
  have h_total : ec_eml + cc_eml + ac ≤ ec_std + cc_std + ac := by
    linarith [h_sum];
  -- Apply the inequality h_total to conclude the proof.
  apply h_total


end
