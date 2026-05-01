/-! # CatalogBuild.Computation.CompressionBounds

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15
-/

import Mathlib

noncomputable section

/-- [Section: # Compression Pipeline — Formal Error Bounds
Formalizes the mathematical guarantees for each stage of the compression pipeline:
1. **Quantization**: per-element error ≤ scale/2
2. **Pruning**: error bounded by removed weight magnitudes
3. **Crystallization**: sin²(πw) penalty vanishes at integers
4. **Distillation**: KL divergence is non-negative
5. **Pipeline composition**: total error bounded by sum of stage errors] -/
theorem symmetric_quant_error (w scale : ℝ) (hscale : 0 < scale) :
    |w - ↑(round (w / scale)) * scale| ≤ scale / 2 := by
  rw [ abs_le ] ; constructor <;> nlinarith [ Int.floor_le ( w / scale + 1 / 2 ), Int.lt_floor_add_one ( w / scale + 1 / 2 ), abs_le.mp ( abs_sub_round ( w / scale ) ), mul_div_cancel₀ w hscale.ne' ]


/-- Stochastic quantization: floor and ceil bracket the value. -/
theorem stochastic_quant_bracket (w : ℝ) :
    (⌊w⌋ : ℝ) ≤ w ∧ w ≤ (⌈w⌉ : ℝ) :=
  ⟨Int.floor_le w, Int.le_ceil w⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Pruning Bounds
-- ═══════════════════════════════════════════════════════════════


/-- Magnitude pruning: zeroing a weight introduces error equal to that weight. -/
theorem prune_error_single (w : ℝ) : |w - 0| = |w| := by simp


/-- Pruning only non-important weights: if |w| ≤ τ, then the error ≤ τ. -/
theorem prune_error_threshold (w τ : ℝ) (hτ : 0 ≤ τ) (hw : |w| ≤ τ) :
    |w - 0| ≤ τ := by simpa using hw


theorem total_prune_error (n : ℕ) (ws : Fin n → ℝ) (mask : Fin n → Bool)
    (τ : ℝ) (hτ : 0 ≤ τ)
    (h_small : ∀ i, mask i = false → |ws i| ≤ τ) :
    ∑ i, |ws i - if mask i then ws i else 0| ≤ n * τ := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show |ws i - if mask i = true then ws i else 0| ≤ τ by aesop ) ( by norm_num )

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Crystallization
-- ═══════════════════════════════════════════════════════════════


/-- The crystallization penalty sin²(πw) is zero at integers. -/
theorem crystal_penalty_int' (n : ℤ) : sin (π * ↑n) ^ 2 = 0 := by
  rw [sq_eq_zero_iff, mul_comm]; exact sin_int_mul_pi n


/-- The crystallization penalty is bounded by 1. -/
theorem crystal_penalty_le_one' (w : ℝ) : sin (π * w) ^ 2 ≤ 1 :=
  sin_sq_le_one _


/-- The crystallization penalty is non-negative. -/
theorem crystal_penalty_nonneg' (w : ℝ) : 0 ≤ sin (π * w) ^ 2 :=
  sq_nonneg _


/-- Rounding error for crystallization. -/
theorem crystal_round_error' (w : ℝ) : |w - ↑(round w)| ≤ 1 / 2 :=
  abs_sub_round w


theorem kl_nonneg_two (p q : ℝ) (hp : 0 < p) (hp1 : p < 1)
    (hq : 0 < q) (hq1 : q < 1) :
    p * log (p / q) + (1 - p) * log ((1 - p) / (1 - q)) ≥ 0 := by
  -- Apply Jensen's inequality for the convex function $f(x) = x \log x$.
  have h_jensen : ∀ x y : ℝ, 0 < x → 0 < y → x * Real.log (x / y) ≥ x - y := by
    intro x y hx hy; rw [ Real.log_div hx.ne' hy.ne' ];
    have := Real.log_le_sub_one_of_pos ( div_pos hy hx );
    rw [ Real.log_div ] at this <;> nlinarith [ mul_div_cancel₀ y hx.ne' ];
  linarith [ h_jensen p q hp hq, h_jensen ( 1 - p ) ( 1 - q ) ( by linarith ) ( by linarith ) ]


theorem pipeline_error_bound' (f g h k : ℝ → ℝ) (x : ℝ) :
    |f x - k x| ≤ |f x - g x| + |g x - h x| + |h x - k x| := by
  cases abs_cases ( f x - k x ) <;> cases abs_cases ( f x - g x ) <;> cases abs_cases ( g x - h x ) <;> cases abs_cases ( h x - k x ) <;> linarith


theorem pipeline_k_stages (n : ℕ) (stages : Fin (n + 1) → ℝ → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (h_bounded : ∀ i : Fin n, ∀ x,
      |stages i.castSucc x - stages i.succ x| ≤ ε) (x : ℝ) :
    |stages 0 x - stages (Fin.last n) x| ≤ n * ε := by
  induction' n with n ih;
  · norm_num;
  · convert le_trans _ ( add_le_add ( ih ( fun i x => stages i.castSucc x ) ( fun i x => h_bounded i.castSucc x ) ) ( h_bounded ( Fin.last n ) x ) ) using 1;
    · push_cast; ring;
    · exact abs_sub_le _ _ _

-- ═══════════════════════════════════════════════════════════════
-- Section 6: VRAM Reduction
-- ═══════════════════════════════════════════════════════════════


/-- VRAM model: bits_per_param * num_nonzero_params. -/
def vramUsage' (bits : ℕ) (numParams : ℕ) (sparsity : ℝ) : ℝ :=
  (bits : ℝ) * (numParams : ℝ) * (1 - sparsity)


/-- Quantization reduces VRAM proportionally to bit reduction. -/
theorem vram_quant_reduction' (n : ℕ) (b₁ b₂ : ℕ) (hb : b₂ ≤ b₁) :
    vramUsage' b₂ n 0 ≤ vramUsage' b₁ n 0 := by
  simp [vramUsage']
  exact mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hb) (Nat.cast_nonneg n)


theorem vram_combined_savings' (n : ℕ) (s : ℝ) (hs : 0 ≤ s) (hs1 : s ≤ 1)
    (b_orig b_quant : ℕ) (hb : b_quant ≤ b_orig) :
    vramUsage' b_quant n s ≤ vramUsage' b_orig n 0 := by
  unfold vramUsage';
  gcongr;
  linarith


end
