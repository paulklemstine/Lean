import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.CompressionPipeline

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 16
-/


noncomputable section

/-- A compression stage with error bound and compression ratio. -/
structure CompressionStage where
  error_bound : ℝ
  error_nonneg : 0 ≤ error_bound
  compression_ratio : ℝ
  ratio_ge_one : 1 ≤ compression_ratio


/-- Composing two compression stages: errors add, ratios multiply. -/
def CompressionStage.compose (s₁ s₂ : CompressionStage) : CompressionStage where
  error_bound := s₁.error_bound + s₂.error_bound
  error_nonneg := by linarith [s₁.error_nonneg, s₂.error_nonneg]
  compression_ratio := s₁.compression_ratio * s₂.compression_ratio
  ratio_ge_one := by nlinarith [s₁.ratio_ge_one, s₂.ratio_ge_one]


/-- Composition is associative for error bounds. -/
theorem compose_error_assoc (s₁ s₂ s₃ : CompressionStage) :
    (CompressionStage.compose (CompressionStage.compose s₁ s₂) s₃).error_bound =
    (CompressionStage.compose s₁ (CompressionStage.compose s₂ s₃)).error_bound := by
  simp [CompressionStage.compose]; ring


/-- Composition is associative for compression ratios. -/
theorem compose_ratio_assoc (s₁ s₂ s₃ : CompressionStage) :
    (CompressionStage.compose (CompressionStage.compose s₁ s₂) s₃).compression_ratio =
    (CompressionStage.compose s₁ (CompressionStage.compose s₂ s₃)).compression_ratio := by
  simp [CompressionStage.compose]; ring


/-- Lower bit width → higher compression but more error. -/
theorem quant_tradeoff (weight_range : ℝ) (hrange : 0 < weight_range)
    (b₁ b₂ : ℕ) (hb : b₁ ≤ b₂) (hb₁ : 0 < b₁) :
    weight_range / (2 ^ b₂ : ℝ) ≤ weight_range / (2 ^ b₁ : ℝ) := by
  apply div_le_div_of_nonneg_left (le_of_lt hrange)
  · positivity
  · exact_mod_cast Nat.pow_le_pow_right (by norm_num : 1 ≤ 2) hb


/-- Perplexity as a function of cross-entropy loss. -/
def perplexity' (crossEntropyLoss : ℝ) : ℝ :=
  Real.exp crossEntropyLoss


/-- Perplexity is always positive. -/
theorem perplexity_pos' (loss : ℝ) : 0 < perplexity' loss :=
  Real.exp_pos loss


/-- Perplexity is monotone in loss. -/
theorem perplexity_mono' {l₁ l₂ : ℝ} (h : l₁ ≤ l₂) :
    perplexity' l₁ ≤ perplexity' l₂ :=
  Real.exp_le_exp_of_le h


/-- If compression adds ε to the loss, perplexity increases multiplicatively. -/
theorem perplexity_degradation' (baseLoss ε : ℝ) :
    perplexity' (baseLoss + ε) = perplexity' baseLoss * Real.exp ε := by
  unfold perplexity'; exact Real.exp_add baseLoss ε


/-- The perplexity ratio is bounded by e^ε. -/
theorem perplexity_ratio_bound' (baseLoss ε : ℝ) :
    perplexity' (baseLoss + ε) / perplexity' baseLoss = Real.exp ε := by
  rw [perplexity_degradation']
  rw [mul_div_cancel_left₀ _ (ne_of_gt (perplexity_pos' baseLoss))]


/-- For small ε, the perplexity increase is approximately 1 + ε (first-order). -/
theorem perplexity_small_epsilon' (ε : ℝ) :
    1 + ε ≤ Real.exp ε := by
  linarith [add_one_le_exp ε]


/-- Shannon rate-distortion: R(D) = (1/2)log(σ²/D) is non-negative when D ≤ σ². -/
theorem rate_distortion_nonneg' (σ_sq D : ℝ) (hσ : 0 < σ_sq) (hD : 0 < D)
    (hDσ : D ≤ σ_sq) :
    0 ≤ (1 / 2 : ℝ) * Real.log (σ_sq / D) := by
  apply mul_nonneg (by norm_num)
  apply Real.log_nonneg
  rw [le_div_iff₀ hD]; linarith


/-- [Section: ## Section 4: Rate-Distortion Theory] -/
theorem rate_distortion_mono' (σ_sq D₁ D₂ : ℝ)
    (hD₁ : 0 < D₁) (hD₂ : 0 < D₂) (hD : D₁ ≤ D₂) :
    (1 / 2 : ℝ) * Real.log (σ_sq / D₂) ≤ (1 / 2 : ℝ) * Real.log (σ_sq / D₁) := by
  norm_num [ div_eq_mul_inv ];
  by_cases hσ_sq : σ_sq = 0 <;> simp_all +decide [ Real.log_mul, hD₁.ne', hD₂.ne' ];
  linarith [ Real.log_le_log ( by positivity ) hD ]


/-- For N stages each with error ε, total error ≤ N · ε. -/
theorem pipeline_uniform_error' (N : ℕ) (ε : ℝ) :
    (N : ℝ) * ε = ∑ _i : Fin N, ε := by
  simp [Finset.sum_const, nsmul_eq_mul]


/-- The total compression ratio of composed stages is the product. -/
theorem pipeline_compression_ratio' (r₁ r₂ : ℝ) (hr₁ : 1 ≤ r₁) (hr₂ : 1 ≤ r₂) :
    1 ≤ r₁ * r₂ := by
  exact one_le_mul_of_one_le_of_one_le (by linarith) hr₂


/-- Three-stage pipeline (quantize + prune + distill) compression ratio. -/
theorem three_stage_ratio (rq rp rd : ℝ) (hq : 1 ≤ rq) (hp : 1 ≤ rp) (hd : 1 ≤ rd) :
    1 ≤ rq * rp * rd := by
  apply one_le_mul_of_one_le_of_one_le
  · exact one_le_mul_of_one_le_of_one_le (by linarith) hp
  · exact hd


end
