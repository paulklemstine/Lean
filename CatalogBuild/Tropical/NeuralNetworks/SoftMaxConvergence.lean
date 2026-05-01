/-! # CatalogBuild.Tropical.NeuralNetworks.SoftMaxConvergence

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 3
-/

import Mathlib
import Tropical.NeuralNetworks.NDimLogSumExp

noncomputable section

/-- Convergence: ∀ ε > 0, ∃ N > 0, ∀ c ≥ N, |softMax c x₁ x₂ - max x₁ x₂| < ε -/
theorem softMax_convergence (x₁ x₂ : ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∃ N : ℝ, 0 < N ∧ ∀ c : ℝ, N ≤ c → |softMax c x₁ x₂ - max x₁ x₂| < ε := by
  use (log 2) / ε + 1
  refine ⟨add_pos (div_pos (log_pos one_lt_two) hε) one_pos, ?_⟩
  intro c hc
  have h_c_pos : 0 < c := by linarith [show (0 : ℝ) < log 2 / ε + 1 from add_pos (div_pos (log_pos one_lt_two) hε) one_pos]
  have h_bound : |softMax c x₁ x₂ - max x₁ x₂| ≤ log 2 / c :=
    NDimLogSumExp.scaled_logsumexp_dequant x₁ x₂ c h_c_pos
  have h_key : log 2 / c < ε := by
    rw [div_lt_iff₀ h_c_pos]
    have h1 : c * ε ≥ ((log 2) / ε + 1) * ε := mul_le_mul_of_nonneg_right hc (le_of_lt hε)
    have h2 : ((log 2) / ε + 1) * ε = log 2 + ε := by field_simp
    linarith
  exact lt_of_le_of_lt h_bound h_key


/-- Filter form of convergence: softMax tends to hardMax as c → ∞ -/
theorem softMax_tendsto (x₁ x₂ : ℝ) :
    Tendsto (fun c => softMax c x₁ x₂) atTop (𝓝 (max x₁ x₂)) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨N, -, hN⟩ := softMax_convergence x₁ x₂ ε hε
  exact ⟨N, hN⟩


/-- The error bound log(2)/c is strictly decreasing in c (higher temperature → tighter) -/
theorem softMax_gap_decreasing (c₁ c₂ : ℝ) (hc₁ : 0 < c₁) (hc₂ : c₁ < c₂) :
    (1 / c₂) * log 2 < (1 / c₁) * log 2 := by
  have h_log_pos : (0 : ℝ) < log 2 := log_pos one_lt_two
  have h_div : 1 / c₂ < 1 / c₁ := one_div_lt_one_div_of_lt hc₁ hc₂
  have h1 : 0 < (1:ℝ) / c₁ := one_div_pos.mpr hc₁
  have h2 : 0 < (1:ℝ) / c₂ := one_div_pos.mpr (lt_trans hc₁ hc₂)
  nlinarith


end
