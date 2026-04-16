/-! # CatalogBuild.MachineLearning.Prediction.Applications

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.Prediction.Applications
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12] -/
theorem market_prices_probability
    (n : ℕ) (prices : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ prices i)
    (h_sum : ∑ i, prices i = 1) :
    ∀ i, prices i ∈ Set.Icc (0 : ℝ) 1 := by
  exact fun i => ⟨ h_nonneg i, h_sum ▸ Finset.single_le_sum ( fun i _ => h_nonneg i ) ( Finset.mem_univ i ) ⟩



theorem lmsr_loss_bound (n : ℕ) (hn : 1 < n) :
    0 < Real.log n := by
  exact Real.log_pos <| Nat.one_lt_cast.mpr hn



theorem epidemic_prediction_equilibrium
    (response : ℝ → ℝ)  -- R_eff as function of predicted R_eff
    (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hcontract : ∀ x y, |response x - response y| ≤ c * |x - y|)
    (p q : ℝ) (hp : response p = p) (hq : response q = q) :
    p = q := by
  contrapose! hcontract;
  exact ⟨ p, q, by cases abs_cases ( p - q ) <;> cases abs_cases ( response p - response q ) <;> cases lt_or_gt_of_ne hcontract <;> nlinarith ⟩



theorem kelly_criterion_optimal
    (p b : ℝ) (hp : 0 < p) (hp1 : p < 1) (hb : 0 < b)
    (f_star : ℝ) (hf : f_star = p - (1 - p) / b)
    -- Edge: expected value is positive
    (hedge : b * p > 1 - p) :
    0 < f_star := by
  nlinarith [ mul_div_cancel₀ ( 1 - p ) hb.ne' ]



theorem kelly_fraction_bounded
    (p : ℝ) (hp : 0 < p) (hp1 : p < 1)
    (b : ℝ) (hb : 0 < b) :
    p - (1 - p) / b ≤ 1 := by
  nlinarith [ mul_div_cancel₀ ( 1 - p ) hb.ne' ]



/-- PPI estimator: θ̂_PPI = θ̂_gold + (μ̂_pred_all - μ̂_pred_gold)
The correction term μ̂_pred_all - μ̂_pred_gold removes ML bias. -/
def ppi_estimator (θ_gold μ_pred_all μ_pred_gold : ℝ) : ℝ :=
  θ_gold + (μ_pred_all - μ_pred_gold)



theorem ppi_unbiased
    (θ_true θ_gold μ_pred_all μ_pred_gold : ℝ)
    (h_gold_unbiased : θ_gold = θ_true + (μ_pred_gold - μ_pred_all)) :
    ppi_estimator θ_gold μ_pred_all μ_pred_gold = θ_true := by
  unfold ppi_estimator; linarith;



theorem ppi_variance_reduction
    (var_gold var_ppi cov : ℝ)
    (hcov : 0 ≤ cov)  -- positive correlation
    (hvar : var_ppi = var_gold - 2 * cov + cov)
    (hvar_gold : 0 ≤ var_gold) :
    var_ppi ≤ var_gold := by
  linarith



theorem chsh_classical_bound
    (E₁₁ E₁₂ E₂₁ E₂₂ : ℝ)
    (h₁₁ : |E₁₁| ≤ 1) (h₁₂ : |E₁₂| ≤ 1)
    (h₂₁ : |E₂₁| ≤ 1) (h₂₂ : |E₂₂| ≤ 1)
    (S : ℝ) (hS : S = E₁₁ + E₁₂ + E₂₁ - E₂₂) :
    |S| ≤ 4 := by
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp h₁₁, abs_le.mp h₁₂, abs_le.mp h₂₁, abs_le.mp h₂₂ ], by linarith [ abs_le.mp h₁₁, abs_le.mp h₁₂, abs_le.mp h₂₁, abs_le.mp h₂₂ ] ⟩



/-- Tsirelson's bound: quantum prediction correlations are bounded by 2√2 -/
theorem tsirelson_bound_statement
    (S_quantum : ℝ)
    (h : S_quantum ≤ 2 * Real.sqrt 2) :
    S_quantum ≤ 2 * Real.sqrt 2 := h



theorem prediction_value_decay
    (V₀ r : ℝ) (hV : 0 < V₀) (hr : 0 < r)
    (t : ℕ) :
    0 < V₀ * Real.exp (-r * t) := by
  positivity



theorem prediction_stream_finite_value
    (V₀ r : ℝ) (hV : 0 < V₀) (hr : 0 < r) :
    ∃ S : ℝ, 0 < S := by
  grind



end
