/-! # CatalogBuild.MachineLearning.Neural.QuantizationBounds

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 9
-/

import Mathlib

noncomputable section

/-- Uniform quantization: round x to the nearest multiple of δ. -/
def uniformQuantize (δ : ℝ) (x : ℝ) : ℝ :=
  δ * ⌊x / δ + 1/2⌋



/-- [Section: ## Section 1: Uniform Quantization] -/
theorem quantize_error_bound (δ : ℝ) (hδ : 0 < δ) (x : ℝ) :
    |x - uniformQuantize δ x| ≤ δ / 2 := by
  exact abs_le.mpr ⟨ by nlinarith [ Int.floor_le ( x / δ + 1 / 2 ), Int.lt_floor_add_one ( x / δ + 1 / 2 ), mul_div_cancel₀ x hδ.ne', show uniformQuantize δ x = δ * ⌊x / δ + 1 / 2⌋ from rfl ], by nlinarith [ Int.floor_le ( x / δ + 1 / 2 ), Int.lt_floor_add_one ( x / δ + 1 / 2 ), mul_div_cancel₀ x hδ.ne', show uniformQuantize δ x = δ * ⌊x / δ + 1 / 2⌋ from rfl ] ⟩



/-- Frobenius norm squared of quantization error for a matrix. -/
def quantErrorFrobSq (n m : ℕ) (δ : ℝ) (W : Fin n → Fin m → ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin m, (W i j - uniformQuantize δ (W i j)) ^ 2



/-- [Section: # CatalogBuild.MachineLearning.Neural.QuantizationBounds
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 10] -/
theorem quantError_frobenius_bound (n m : ℕ) (δ : ℝ) (hδ : 0 < δ)
    (W : Fin n → Fin m → ℝ) :
    quantErrorFrobSq n m δ W ≤ ↑(n * m) * (δ / 2) ^ 2 := by
  -- Apply the bound from quantize_error_bound to each term in the double sum. Each term $(W i j - uniformQuantize δ (W i j))^2$ is at most $(δ / 2)^2$.
  have h_term_bound : ∀ i j, (W i j - uniformQuantize δ (W i j))^2 ≤ (δ / 2)^2 := by
    exact fun i j => by simpa using pow_le_pow_left₀ ( abs_nonneg _ ) ( quantize_error_bound _ hδ _ ) 2;
  convert Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => h_term_bound i j;
  norm_num [ mul_assoc ]



/-- Frobenius norm bound (non-squared version):
‖W - Q(W)‖_F ≤ δ/2 · √(n·m). -/
theorem quantError_frobenius_norm_bound (n m : ℕ) (δ : ℝ) (hδ : 0 < δ)
    (W : Fin n → Fin m → ℝ) :
    Real.sqrt (quantErrorFrobSq n m δ W) ≤ δ / 2 * Real.sqrt (n * m : ℕ) := by
  rw [← Real.sqrt_sq (by positivity : (0 : ℝ) ≤ δ / 2), ← Real.sqrt_mul (sq_nonneg _)]
  apply Real.sqrt_le_sqrt
  have h := quantError_frobenius_bound n m δ hδ W
  linarith



/-- Adaptive quantization step size: rows with higher entropy get
finer granularity. δ_i = δ_base / (1 + H_i). -/
def adaptiveStepSize (δ_base : ℝ) (entropy : ℝ) : ℝ :=
  δ_base / (1 + entropy)



/-- Adaptive step size is at most the base step size. -/
theorem adaptiveStepSize_le_base (δ_base : ℝ) (hδ : 0 < δ_base)
    (entropy : ℝ) (hH : 0 ≤ entropy) :
    adaptiveStepSize δ_base entropy ≤ δ_base := by
  unfold adaptiveStepSize
  rw [div_le_iff₀ (by linarith : (0 : ℝ) < 1 + entropy)]
  nlinarith



/-- Adaptive step size is positive when base step size is positive. -/
theorem adaptiveStepSize_pos (δ_base : ℝ) (hδ : 0 < δ_base)
    (entropy : ℝ) (hH : 0 ≤ entropy) :
    0 < adaptiveStepSize δ_base entropy := by
  unfold adaptiveStepSize; positivity



theorem kv_cache_score_bound (d : ℕ) (δ : ℝ) (hδ : 0 < δ)
    (q k k' : Fin d → ℝ)
    (hquant : ∀ j, |k' j - k j| ≤ δ / 2)
    (hq_norm : ∑ j : Fin d, q j ^ 2 ≤ 1) :
    (∑ j : Fin d, q j * (k' j - k j)) ^ 2 ≤ (d : ℝ) * (δ / 2) ^ 2 := by
  -- By Cauchy-Schwarz inequality, we have (∑ j, q j * (k' j - k j))² ≤ (∑ j, q j²) * (∑ j, (k' j - k j)²).
  have h_cauchy_schwarz : (∑ j, q j * (k' j - k j)) ^ 2 ≤ (∑ j, q j ^ 2) * (∑ j, (k' j - k j) ^ 2) := by
    exact?;
  exact h_cauchy_schwarz.trans ( by exact le_trans ( mul_le_of_le_one_left ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) hq_norm ) <| le_trans ( Finset.sum_le_sum fun _ _ => show ( k' _ - k _ ) ^ 2 ≤ ( δ/2 ) ^ 2 by nlinarith only [ abs_le.mp <| hquant ‹_› ] ) <| by norm_num )



end
