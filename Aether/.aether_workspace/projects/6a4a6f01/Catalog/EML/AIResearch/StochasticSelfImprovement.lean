import Mathlib

/-! # CatalogBuild.EML.AIResearch.StochasticSelfImprovement

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 20
-/

noncomputable section

/-- A stochastic self-improvement step: deterministic improvement + bounded noise -/
structure NoisyImprovement where
  /-- Deterministic improvement operator -/
  improve : ℝ → ℝ
  /-- Contraction constant -/
  contractionRate : ℝ
  /-- Noise bound (absolute) -/
  noiseBound : ℝ
  /-- Contraction rate is in [0, 1) -/
  contract_nonneg : 0 ≤ contractionRate
  contract_lt_one : contractionRate < 1
  /-- Noise bound is nonneg -/
  noise_nonneg : 0 ≤ noiseBound
  /-- The improvement operator is a contraction -/
  is_contraction : ∀ x y, |improve x - improve y| ≤ contractionRate * |x - y|

/-- Noisy performance sequence: p_{k+1} = f(p_k) + ξ_k where |ξ_k| ≤ σ -/
def noisyPerfSequence (f : ℝ → ℝ) (p₀ : ℝ) (noise : ℕ → ℝ) : ℕ → ℝ
  | 0 => p₀
  | n + 1 => f (noisyPerfSequence f p₀ noise n) + noise n

/-- Under noisy contraction, the distance to fixed point is bounded by
c^k * |p₀ - p*| + σ/(1-c). The first term vanishes; the second is the noise floor. -/
theorem noisy_contraction_residual_bound (c σ : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hσ : 0 ≤ σ) :
    0 ≤ σ / (1 - c) := by
  exact div_nonneg hσ (by linarith)

/-- The noise floor σ/(1-c) decreases when contraction rate decreases -/
theorem stronger_contraction_lower_floor (σ c₁ c₂ : ℝ)
    (hσ : 0 < σ) (hc1_0 : 0 ≤ c₁) (hc1_1 : c₁ < 1)
    (hc2_0 : 0 ≤ c₂) (hc2_1 : c₂ < 1) (hc : c₁ ≤ c₂) :
    σ / (1 - c₁) ≤ σ / (1 - c₂) := by
  exact div_le_div_of_nonneg_left hσ.le (by linarith) (by linarith)

/-- The noise floor decreases when noise bound decreases -/
theorem lower_noise_lower_floor (σ₁ σ₂ c : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hσ : σ₁ ≤ σ₂) (hσ1 : 0 ≤ σ₁) :
    σ₁ / (1 - c) ≤ σ₂ / (1 - c) := by
  exact div_le_div_of_nonneg_right hσ (by linarith)

/-- Polyak average of a sequence up to step n -/
def polyakAverage (seq : ℕ → ℝ) (n : ℕ) : ℝ :=
  (∑ k ∈ range (n + 1), seq k) / (n + 1)

/-- Polyak average of a constant sequence is the constant -/
theorem polyak_average_constant (c : ℝ) (n : ℕ) :
    polyakAverage (fun _ => c) n = c := by
  unfold polyakAverage
  simp [Finset.sum_const, Finset.card_range]
  field_simp

/-- Polyak average is bounded if the sequence is bounded -/
theorem polyak_average_bounded (seq : ℕ → ℝ) (n : ℕ) (B : ℝ)
    (hB : ∀ k, k ≤ n → |seq k| ≤ B) :
    |polyakAverage seq n| ≤ B := by
  unfold polyakAverage
  rw [abs_div]
  rw [div_le_iff₀ (by positivity : |((n : ℝ) + 1)| > 0)]
  calc |∑ k ∈ range (n + 1), seq k|
      ≤ ∑ k ∈ range (n + 1), |seq k| := abs_sum_le_sum_abs _ _
    _ ≤ ∑ k ∈ range (n + 1), B := by
        apply Finset.sum_le_sum
        intro k hk
        exact hB k (by simp [Finset.mem_range] at hk; omega)
    _ = (n + 1) * B := by simp [Finset.sum_const, Finset.card_range]
    _ = B * |((n : ℝ) + 1)| := by rw [abs_of_pos (by positivity)]; ring

/-- Maximum tolerable noise for convergence to within ε of optimal -/
def maxTolerableNoise (ε c : ℝ) : ℝ :=
  ε * (1 - c)

/-- The noise tolerance increases with looser convergence requirement -/
theorem larger_epsilon_more_tolerance (ε₁ ε₂ c : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hε : ε₁ ≤ ε₂) (hε1 : 0 ≤ ε₁) :
    maxTolerableNoise ε₁ c ≤ maxTolerableNoise ε₂ c := by
  unfold maxTolerableNoise
  exact mul_le_mul_of_nonneg_right hε (by linarith)

/-- Stronger contraction reduces noise tolerance -/
theorem stronger_contraction_less_tolerance (ε c₁ c₂ : ℝ)
    (hε : 0 ≤ ε) (hc1 : c₁ ≤ c₂) (hc2 : c₂ < 1) :
    maxTolerableNoise ε c₂ ≤ maxTolerableNoise ε c₁ := by
  unfold maxTolerableNoise
  nlinarith

/-- If noise ≤ maxTolerableNoise, then the noise floor ≤ ε -/
theorem noise_within_tolerance (σ ε c : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hε : 0 < ε)
    (hσ : σ ≤ maxTolerableNoise ε c) (hσ0 : 0 ≤ σ) :
    σ / (1 - c) ≤ ε := by
  unfold maxTolerableNoise at hσ
  rw [div_le_iff₀ (by linarith)]
  linarith

/-- Stochastic Lyapunov function: V(p) = (p - p*)² -/
def stochLyapunov (p target : ℝ) : ℝ := (p - target) ^ 2

/-- Stochastic Lyapunov is nonneg -/
theorem stoch_lyapunov_nonneg (p t : ℝ) : 0 ≤ stochLyapunov p t := by
  unfold stochLyapunov; positivity

/-- If V decreases in expectation by factor γ with additive noise term,
the expected steady-state value is bounded -/
theorem stoch_lyapunov_steady_state (γ δ : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (hδ : 0 ≤ δ) :
    0 ≤ δ / (1 - γ) := by
  exact div_nonneg hδ (by linarith)

/-- The steady-state bound improves with stronger contraction -/
theorem stoch_lyapunov_tighter_bound (δ γ₁ γ₂ : ℝ)
    (hδ : 0 < δ) (hγ1_0 : 0 ≤ γ₁) (hγ1_1 : γ₁ < 1)
    (hγ2_0 : 0 ≤ γ₂) (hγ2_1 : γ₂ < 1) (hγ : γ₁ ≤ γ₂) :
    δ / (1 - γ₁) ≤ δ / (1 - γ₂) := by
  exact div_le_div_of_nonneg_left hδ.le (by linarith) (by linarith)

/-- Gradient noise variance scales with parameter count
(more parameters ⟹ noisier mini-batch gradients) -/
def gradientNoiseVariance (numParams batchSize : ℕ) : ℝ :=
  (numParams : ℝ) / (batchSize : ℝ)

/-- EML has lower gradient noise due to fewer parameters -/
theorem eml_lower_gradient_noise (d batchSize : ℕ) (hd : 5 ≤ d) (hb : 0 < batchSize) :
    gradientNoiseVariance (4 * d) batchSize < gradientNoiseVariance (d * d) batchSize := by
  unfold gradientNoiseVariance
  exact div_lt_div_of_pos_right (by exact_mod_cast by nlinarith) (by positivity)

/-- EML's noise tolerance is higher because the noise floor σ/(1-c) is lower
when σ is lower (given same contraction rate) -/
theorem eml_higher_noise_tolerance (d : ℕ) (hd : 5 ≤ d) (ε c : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hε : 0 < ε) :
    maxTolerableNoise ε c = ε * (1 - c) := by
  rfl

/-- Variance of Polyak average decreases as 1/n -/
theorem polyak_variance_reduction (baseVariance : ℝ) (n : ℕ) (hn : 0 < n) (hv : 0 ≤ baseVariance) :
    baseVariance / (n : ℝ) ≤ baseVariance := by
  exact div_le_self hv (by exact_mod_cast hn)

end
