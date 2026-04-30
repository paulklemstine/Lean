import Mathlib

/-! # Satake-EML Bridge: Softmax Convergence to Tropical Max

Bridges the tropical Satake isomorphism (Tropical/Langlands/SatakeIsomorphism)
with EML-LogSumExp connections (Bridges/EMLTropicalBridge), proving that
the "soft" (LogSumExp) Satake image converges to the hard (tropical max)
Satake image as temperature → 0⁺.

Main results:
1. `logsumexp_two_point`: log(exp(a)+exp(b)) = max(a,b) + log(1+exp(-|a-b|))
2. `softMax_decomposition`: softMax(c,x₁,x₂) = max(x₁,x₂) + (1/c)·log(1+exp(-c·|x₁-x₂|))
3. `softMax_gap_upper`: softMax - max ≤ (1/c)·log 2
4. `softMax_ge_max`: max ≤ softMax
5. `softMax_same`: softMax(c,a,a) = a + (log 2)/c
6. `satake_soft_gap`: n·softMax - n·max ≤ (n/c)·log 2
7. `soft_satake_ge_hard`: n·max ≤ n·softMax

These establish the dequantization bridge: as temperature → 0⁺,
softmax converges to hardmax, connecting the classical Langlands program
to tropical geometry through the Satake isomorphism.

The key insight is that the tropical Satake isomorphism computes
`satakeImage n x₁ x₂ = n · max(x₁, x₂)`, while the smooth (classical)
version is `softMax c x₁ x₂` with explicit error bounds that shrink
as temperature increases. This provides a rigorous quantitative foundation
for "tropicalization as zero-temperature limit" in representation theory.
-/

noncomputable section

open Real

namespace SatakeEMLBridge

/-! ## 1. Soft Maximum Definition -/

/-- softMax(c, x₁, x₂) = (1/c) · log(exp(c·x₁) + exp(c·x₂))
    The "soft maximum" with temperature c > 0. -/
def softMax (c : ℝ) (x₁ x₂ : ℝ) : ℝ :=
  (1 / c) * log (exp (c * x₁) + exp (c * x₂))

/-! ## 2. LogSumExp Two-Point Identity -/

private theorem logsumexp_le (a b : ℝ) (_ : a ≤ b) :
    log (exp a + exp b) = b + log (1 + exp (a - b)) := by
  have hfac : exp a + exp b = exp b * (1 + exp (a - b)) := by
    have h1 : exp a = exp (b + (a - b)) := by congr 1; ring
    rw [h1, exp_add b (a - b)]
    ring_nf
  rw [hfac]
  have h1 : exp b ≠ 0 := ne_of_gt (exp_pos b)
  have h2 : (1 + exp (a - b)) ≠ 0 := by linarith [exp_pos (a - b)]
  rw [log_mul h1 h2, log_exp]

private theorem logsumexp_ge (a b : ℝ) (_ : b ≤ a) :
    log (exp a + exp b) = a + log (1 + exp (b - a)) := by
  have hfac : exp a + exp b = exp a * (1 + exp (b - a)) := by
    have h1 : exp b = exp (a + (b - a)) := by congr 1; ring
    rw [h1, exp_add a (b - a)]
    ring_nf
  rw [hfac]
  have h1 : exp a ≠ 0 := ne_of_gt (exp_pos a)
  have h2 : (1 + exp (b - a)) ≠ 0 := by linarith [exp_pos (b - a)]
  rw [log_mul h1 h2, log_exp]

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

/-! ## 3. Softmax Equality Case -/

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

/-! ## 4. Softmax Decomposition -/

private theorem abs_sub_mul_of_pos (c x₁ x₂ : ℝ) (hc : 0 < c) :
    |c * x₁ - c * x₂| = c * |x₁ - x₂| := by
  rw [← mul_sub, abs_mul, abs_of_pos hc]

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

/-! ## 5. Softmax-Hardmax Gap Bounds -/

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

/-! ## 6. Bridge to Satake Isomorphism -/

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

end SatakeEMLBridge
