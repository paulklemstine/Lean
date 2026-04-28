import Mathlib
import Tropical.NeuralNetworks.NDimLogSumExp

/-! # SoftMax Convergence to Tropical Maximum

Proves softMax → hardMax as temperature → ∞ (dequantization bridge).
-/

noncomputable section

open Real

namespace SoftMaxConvergence

def softMax (c : ℝ) (x₁ x₂ : ℝ) : ℝ :=
  (1 / c) * log (exp (c * x₁) + exp (c * x₂))

/-- The soft max dominates the hard max -/
theorem softMax_ge_max (c : ℝ) (hc : 0 < c) (x₁ x₂ : ℝ) :
    max x₁ x₂ ≤ softMax c x₁ x₂ := by
  have h_lse : max (c * x₁) (c * x₂) ≤ log (exp (c * x₁) + exp (c * x₂)) :=
    NDimLogSumExp.logsumexp_lower (c * x₁) (c * x₂)
  have h_cmax : max (c * x₁) (c * x₂) = c * max x₁ x₂ :=
    (mul_max_of_nonneg x₁ x₂ hc.le).symm
  unfold softMax
  calc max x₁ x₂ = (1 / c) * (c * max x₁ x₂) := by field_simp
  _ ≤ (1 / c) * log (exp (c * x₁) + exp (c * x₂)) :=
    mul_le_mul_of_nonneg_left (h_cmax ▸ h_lse) (one_div_nonneg.mpr hc.le)

/-- softMax gap is at most (1/c)*log(2) -/
theorem softMax_gap_upper (c : ℝ) (hc : 0 < c) (x₁ x₂ : ℝ) :
    softMax c x₁ x₂ - max x₁ x₂ ≤ (1 / c) * log 2 := by
  have h_abs := NDimLogSumExp.scaled_logsumexp_dequant x₁ x₂ c hc
  have h_nonneg : 0 ≤ softMax c x₁ x₂ - max x₁ x₂ := sub_nonneg.mpr (softMax_ge_max c hc x₁ x₂)
  calc softMax c x₁ x₂ - max x₁ x₂
      = |softMax c x₁ x₂ - max x₁ x₂| := (abs_of_nonneg h_nonneg).symm
  _ ≤ log 2 / c := h_abs
  _ = (1 / c) * log 2 := by rw [div_eq_mul_inv]; ring_nf

/-- softMax(c, a, a) = a + (log 2)/c -/
theorem softMax_same (c : ℝ) (hc : 0 < c) (a : ℝ) :
    softMax c a a = a + (1 / c) * log 2 := by
  unfold softMax
  have : exp (c * a) + exp (c * a) = 2 * exp (c * a) := by ring
  rw [this]
  have h1 : (2 : ℝ) ≠ 0 := two_ne_zero
  have h2 : exp (c * a) ≠ 0 := ne_of_gt (exp_pos (c * a))
  rw [log_mul h1 h2, log_exp]
  field_simp; ring

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
    -- log 2 < c * ε because c * ε ≥ log 2 + ε > log 2
    linarith
  exact lt_of_le_of_lt h_bound h_key

end SoftMaxConvergence
