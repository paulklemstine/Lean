/-! # CatalogBuild.Speculative.SciFi.FermiParadox_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

noncomputable section

/-- [Section: ## Exponential Growth
N(t) = N₀ · e^(rt) — the fundamental growth equation for colonization.] -/
theorem exp_growth_increasing (r : ℝ) (hr : 0 < r) (N₀ : ℝ) (hN₀ : 0 < N₀) :
    StrictMono (fun t => N₀ * Real.exp (r * t)) := by
  exact fun t t' h => mul_lt_mul_of_pos_left ( Real.exp_lt_exp.mpr ( mul_lt_mul_of_pos_left h hr ) ) hN₀


theorem exp_growth_unbounded (r : ℝ) (hr : 0 < r) (N₀ : ℝ) (hN₀ : 0 < N₀)
    (M : ℝ) : ∃ t : ℝ, M < N₀ * Real.exp (r * t) := by
  exact ⟨ ( M / N₀ + 1 ) / r, by nlinarith [ Real.add_one_le_exp ( r * ( ( M / N₀ + 1 ) / r ) ), mul_div_cancel₀ ( M / N₀ + 1 ) hr.ne', mul_div_cancel₀ M hN₀.ne' ] ⟩


/-- The Drake equation: N is linear in L (civilization lifetime). -/
theorem drake_linear_in_L (R fp ne fl fi fc : ℝ) :
    ∀ L₁ L₂ : ℝ, (R * fp * ne * fl * fi * fc * (2 * L₁)) =
    2 * (R * fp * ne * fl * fi * fc * L₁) := by
  intro L₁ L₂
  ring


/-- [Section: ## Bayesian Reasoning and the Great Filter
Bayes' theorem: P(A|B) = P(B|A) · P(A) / P(B)] -/
theorem great_filter_bayesian
    (p_behind p_ahead : ℝ)
    (p_silence_behind p_silence_ahead : ℝ)
    (h_prior : p_behind + p_ahead = 1)
    (h_nonneg_b : 0 ≤ p_behind) (h_nonneg_a : 0 ≤ p_ahead)
    (h_more_silent : p_silence_ahead > p_silence_behind)
    (h_pos_b : 0 < p_silence_behind) (h_pos_a : 0 < p_silence_ahead)
    (h_pos_behind : 0 < p_behind) (h_pos_ahead : 0 < p_ahead)
    (p_silence : ℝ)
    (h_total : p_silence = p_silence_behind * p_behind + p_silence_ahead * p_ahead)
    (h_pos_silence : 0 < p_silence) :
    p_silence_ahead * p_ahead / p_silence > p_ahead := by
  field_simp;
  nlinarith


end
