/-! # CatalogBuild.Bridges.SatakeEMLBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 9
-/

import Mathlib

noncomputable section

/-- softMax(c, x₁, x₂) = (1/c) · log(exp(c·x₁) + exp(c·x₂))
The "soft maximum" with temperature c > 0. -/
def softMax (c : ℝ) (x₁ x₂ : ℝ) : ℝ :=
  (1 / c) * log (exp (c * x₁) + exp (c * x₂))


/-- log(exp(a) + exp(b)) = max(a, b) + log(1 + exp(-|a - b|))
The LogSumExp decomposition: the soft maximum equals the hard maximum
plus a correction term that vanishes as |a-b| → ∞. -/
theorem logsumexp_two_point (a b : ℝ) :
    log (exp a + exp b) = max a b + log (1 + exp (-|a - b|)) := by
  cases le_total a b with
  | inl hab =>
    rw [max_eq_right hab, logsumexp_le a b hab]
    congr 1; congr 1; congr 1
    rw [abs_sub_comm, abs_of_nonneg (sub_nonneg.mpr hab)]
    ring
  | inr hba =>
    rw [max_eq_left hba, logsumexp_ge a b hba]
    congr 1; congr 1; congr 1
    rw [abs_of_nonneg (sub_nonneg.mpr hba)]
    ring


/-- softMax(c, a, a) = a + (log 2)/c
Temperature-scaled extension of logsumexp_same. -/
theorem softMax_same (c : ℝ) (hc : 0 < c) (a : ℝ) :
    softMax c a a = a + (1 / c) * log 2 := by
  unfold softMax
  have h2 : exp (c * a) + exp (c * a) = 2 * exp (c * a) := by ring
  rw [h2]
  have hne1 : (2 : ℝ) ≠ 0 := two_ne_zero
  have hne2 : exp (c * a) ≠ 0 := ne_of_gt (exp_pos (c * a))
  rw [log_mul hne1 hne2, log_exp]
  field_simp; ring


/-- softMax(c, x₁, x₂) = max(x₁, x₂) + (1/c)·log(1+exp(-c·|x₁-x₂|))
Explicit decomposition of the soft maximum. -/
theorem softMax_decomposition (c : ℝ) (hc : 0 < c) (x₁ x₂ : ℝ) :
    softMax c x₁ x₂ = max x₁ x₂ + (1 / c) * log (1 + exp (-c * |x₁ - x₂|)) := by
  unfold softMax
  rw [logsumexp_two_point (c * x₁) (c * x₂)]
  have hmax : max (c * x₁) (c * x₂) = c * max x₁ x₂ :=
    (mul_max_of_nonneg x₁ x₂ hc.le).symm
  have habs : |c * x₁ - c * x₂| = c * |x₁ - x₂| := abs_sub_mul_of_pos c x₁ x₂ hc
  rw [hmax, habs]
  field_simp


/-- The soft max is always at least the hard max. -/
theorem softMax_ge_max (c : ℝ) (hc : 0 < c) (x₁ x₂ : ℝ) :
    max x₁ x₂ ≤ softMax c x₁ x₂ := by
  rw [softMax_decomposition c hc]
  apply le_add_of_nonneg_right
  apply mul_nonneg
  · positivity
  · apply log_nonneg
    linarith [exp_pos (-c * |x₁ - x₂|)]

private theorem exp_neg_mul_abs_le_one (c d : ℝ) (hc : 0 < c) :
    exp (-c * |d|) ≤ 1 := by
  rw [exp_le_one_iff]
  exact mul_nonpos_of_nonpos_of_nonneg (le_of_lt (show -c < (0 : ℝ) by linarith)) (abs_nonneg d)


/-- Upper bound on the softMax-hardmax gap:
softMax(c, x₁, x₂) - max(x₁, x₂) ≤ (1/c) * log 2 -/
theorem softMax_gap_upper (c : ℝ) (hc : 0 < c) (x₁ x₂ : ℝ) :
    softMax c x₁ x₂ - max x₁ x₂ ≤ (1 / c) * log 2 := by
  rw [softMax_decomposition c hc]
  have : max x₁ x₂ + (1 / c) * log (1 + exp (-c * |x₁ - x₂|)) - max x₁ x₂ =
         (1 / c) * log (1 + exp (-c * |x₁ - x₂|)) := by ring
  rw [this]
  apply mul_le_mul_of_nonneg_left
  · apply log_le_log
    · linarith [exp_pos (-c * |x₁ - x₂|)]
    · linarith [exp_neg_mul_abs_le_one c (x₁ - x₂) hc]
  · exact le_of_lt (one_div_pos.mpr hc)


/-- The soft Satake image for GL₂ decomposition:
n · softMax(c, x₁, x₂) = n · max(x₁, x₂) + (n/c) · log(1 + exp(-c·|x₁-x₂|)) -/
theorem soft_satake_decomp (c : ℝ) (n : ℕ) (x₁ x₂ : ℝ) (hc : 0 < c) :
    (n : ℝ) * softMax c x₁ x₂ =
    (n : ℝ) * max x₁ x₂ + ((n : ℝ) / c) * log (1 + exp (-c * |x₁ - x₂|)) := by
  rw [softMax_decomposition c hc]
  ring


/-- The gap between soft and hard Satake images for GL₂:
n · softMax - n · max ≤ (n/c) · log 2 -/
theorem satake_soft_gap (c : ℝ) (n : ℕ) (x₁ x₂ : ℝ) (hc : 0 < c) :
    (n : ℝ) * softMax c x₁ x₂ - (n : ℝ) * max x₁ x₂ ≤ ((n : ℝ) / c) * log 2 := by
  have hgap := softMax_gap_upper c hc x₁ x₂
  have hn : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  have h1 : (n : ℝ) * (softMax c x₁ x₂ - max x₁ x₂) ≤ (n : ℝ) * ((1 / c) * log 2) :=
    mul_le_mul_of_nonneg_left hgap hn
  have h2 : (n : ℝ) * softMax c x₁ x₂ - (n : ℝ) * max x₁ x₂ =
            (n : ℝ) * (softMax c x₁ x₂ - max x₁ x₂) := by ring
  have h3 : (n : ℝ) * ((1 / c) * log 2) = ((n : ℝ) / c) * log 2 := by ring
  linarith


/-- The soft Satake image is at least the hard Satake image. -/
theorem soft_satake_ge_hard (c : ℝ) (n : ℕ) (x₁ x₂ : ℝ) (hc : 0 < c) :
    (n : ℝ) * max x₁ x₂ ≤ (n : ℝ) * softMax c x₁ x₂ :=
  mul_le_mul_of_nonneg_left (softMax_ge_max c hc x₁ x₂) (Nat.cast_nonneg n)


end
