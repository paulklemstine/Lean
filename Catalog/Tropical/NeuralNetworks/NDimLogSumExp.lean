import Mathlib

/-! # N-Dimensional LogSumExp Bounds and SoftMax Convergence
Dequantization theorem connecting tropical max-plus algebra to log-sum-exp.
-/

noncomputable section

open Real

namespace NDimLogSumExp

private theorem logsumexp_le (a b : ℝ) (_ : a ≤ b) :
    log (exp a + exp b) = b + log (1 + exp (a - b)) := by
  have hfac : exp a + exp b = exp b * (1 + exp (a - b)) := by
    have h1 : exp a = exp (b + (a - b)) := by congr 1; ring
    rw [h1, exp_add b (a - b)]; ring_nf
  rw [hfac]
  have h1 : exp b ≠ 0 := ne_of_gt (exp_pos b)
  have h2 : (1 + exp (a - b)) ≠ 0 := by linarith [exp_pos (a - b)]
  rw [log_mul h1 h2, log_exp]

private theorem logsumexp_ge (a b : ℝ) (_ : b ≤ a) :
    log (exp a + exp b) = a + log (1 + exp (b - a)) := by
  have hfac : exp a + exp b = exp a * (1 + exp (b - a)) := by
    have h1 : exp b = exp (a + (b - a)) := by congr 1; ring
    rw [h1, exp_add a (b - a)]; ring_nf
  rw [hfac]
  have h1 : exp a ≠ 0 := ne_of_gt (exp_pos a)
  have h2 : (1 + exp (b - a)) ≠ 0 := by linarith [exp_pos (b - a)]
  rw [log_mul h1 h2, log_exp]

private theorem exp_neg_abs_le_one (x : ℝ) : exp (-|x|) ≤ (1 : ℝ) := by
  rw [exp_le_one_iff]; linarith [abs_nonneg x]

theorem logsumexp_two_point (a b : ℝ) :
    log (exp a + exp b) = max a b + log (1 + exp (-|a - b|)) := by
  cases le_total a b with
  | inl hab =>
    rw [max_eq_right hab, logsumexp_le a b hab]
    congr 1; congr 1; congr 1
    rw [abs_sub_comm, abs_of_nonneg (sub_nonneg.mpr hab)]; ring_nf
  | inr hba =>
    rw [max_eq_left hba, logsumexp_ge a b hba]
    congr 1; congr 1; congr 1
    rw [abs_of_nonneg (sub_nonneg.mpr hba)]; ring_nf

theorem logsumexp_lower (x₁ x₂ : ℝ) :
    max x₁ x₂ ≤ log (exp x₁ + exp x₂) := by
  rw [logsumexp_two_point x₁ x₂]
  exact le_add_of_nonneg_right (log_nonneg (by linarith [exp_pos (-|x₁ - x₂|)]))

theorem logsumexp_upper (x₁ x₂ : ℝ) :
    log (exp x₁ + exp x₂) ≤ max x₁ x₂ + log 2 := by
  rw [logsumexp_two_point x₁ x₂]
  have := log_le_log (by linarith [exp_pos (-|x₁ - x₂|)]) (show (1:ℝ) + exp (-|x₁ - x₂|) ≤ 2 by linarith [exp_neg_abs_le_one (x₁ - x₂)])
  linarith

theorem logsumexp_gap_nonneg (x₁ x₂ : ℝ) :
    0 ≤ log (exp x₁ + exp x₂) - max x₁ x₂ :=
  sub_nonneg.mpr (logsumexp_lower x₁ x₂)

theorem logsumexp_gap_le (x₁ x₂ : ℝ) :
    log (exp x₁ + exp x₂) - max x₁ x₂ ≤ log 2 := by linarith [logsumexp_upper x₁ x₂]

/-- |(1/c)·LSE(cx) - max(x)| ≤ log(2)/c: dequantization error bound -/
theorem scaled_logsumexp_dequant (x₁ x₂ : ℝ) (c : ℝ) (hc : 0 < c) :
    |(1/c) * log (exp (c * x₁) + exp (c * x₂)) - max x₁ x₂| ≤ log 2 / c := by
  have h_cmax : c * max x₁ x₂ = max (c * x₁) (c * x₂) := mul_max_of_nonneg x₁ x₂ hc.le
  rw [show (1/c) * log (exp (c * x₁) + exp (c * x₂)) - max x₁ x₂ =
      (1/c) * (log (exp (c * x₁) + exp (c * x₂)) - max (c * x₁) (c * x₂)) from by
    rw [← h_cmax]; field_simp]
  rw [abs_of_nonneg (mul_nonneg (one_div_nonneg.mpr hc.le) (logsumexp_gap_nonneg (c * x₁) (c * x₂)))]
  -- Goal: (1/c) * gap ≤ log 2 / c
  -- = gap/c ≤ log2/c = gap * (1/c) ≤ log2 * (1/c)
  -- Equivalent to gap ≤ log2 (mul both sides by c > 0)
  show (1 / c) * (log (exp (c * x₁) + exp (c * x₂)) - max (c * x₁) (c * x₂)) ≤ log 2 / c
  have h_gap := logsumexp_gap_le (c * x₁) (c * x₂)
  -- gap * (1/c) ≤ log 2 * (1/c)  by mul_le_mul_of_nonneg_left gap_le (1/c ≥ 0)
  -- Then rewrite log 2 * (1/c) = log 2 / c
  have h_mul := mul_le_mul_of_nonneg_left h_gap (one_div_nonneg.mpr hc.le)
  -- h_mul : gap * (1/c) ≤ log 2 * (1/c)
  -- Need to show this matches goal form
  -- In Lean: (1 / c) * gap ≤ log 2 / c
  -- Since 1/c = c⁻¹ * 1 and log 2 / c = log 2 * c⁻¹
  -- We need: c⁻¹ * gap ≤ log 2 * c⁻¹  ⟺ h_mul
  -- But Lean represents 1/c as 1 * c⁻¹ and log2/c as log2 * c⁻¹
  convert h_mul using 1; field_simp

theorem softmax_prob_sum (x₁ x₂ : ℝ) (c : ℝ) (_hc : 0 < c) :
    exp (c * x₁) / (exp (c * x₁) + exp (c * x₂)) +
    exp (c * x₂) / (exp (c * x₁) + exp (c * x₂)) = 1 := by
  field_simp [add_pos (exp_pos (c * x₁)) (exp_pos (c * x₂))]

theorem softmax_winner_advantage (x₁ x₂ : ℝ) (h : x₁ ≤ x₂) (c : ℝ) (hc : 0 < c) :
    (1 : ℝ) / 2 * (exp (c * x₁) + exp (c * x₂)) ≤ exp (c * x₂) := by
  have h₁ : exp (c * x₁) ≤ exp (c * x₂) := exp_le_exp.mpr (mul_le_mul_of_nonneg_left h hc.le)
  calc _ ≤ (1 : ℝ) / 2 * (exp (c * x₂) + exp (c * x₂)) :=
    mul_le_mul_of_nonneg_left (add_le_add h₁ le_rfl) (by positivity)
  _ = exp (c * x₂) := by ring_nf

theorem softmax_loser_disadvantage (x₁ x₂ : ℝ) (h : x₁ < x₂) (c : ℝ) (hc : 0 < c) :
    exp (c * x₁) ≤ (1 : ℝ) / 2 * (exp (c * x₁) + exp (c * x₂)) := by
  have h₁ : exp (c * x₁) ≤ exp (c * x₂) := exp_le_exp.mpr (mul_le_mul_of_nonneg_left h.le hc.le)
  have h₂ : (2 : ℝ) * exp (c * x₁) ≤ exp (c * x₁) + exp (c * x₂) := by
    calc _ = exp (c * x₁) + exp (c * x₁) := by ring_nf
    _ ≤ exp (c * x₁) + exp (c * x₂) := add_le_add le_rfl h₁
  calc exp (c * x₁) = (1 : ℝ) / 2 * (2 * exp (c * x₁)) := by ring_nf
  _ ≤ (1 : ℝ) / 2 * (exp (c * x₁) + exp (c * x₂)) :=
    mul_le_mul_of_nonneg_left h₂ (by positivity)

end NDimLogSumExp
