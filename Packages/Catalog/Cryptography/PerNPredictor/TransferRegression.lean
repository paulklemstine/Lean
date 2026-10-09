import Mathlib

/-!
# Shape transfer versus level refit: the exact law behind "transfer R² = corr²"

Exp 476 fits the per-`N` predictor `rate ≈ a + b·QR` on one population (scale)
and *transfers* it to another.  The reported phenomenon is

* **shape transfers perfectly**: transferring the slope `b` and refitting only
  the level `a` on the target gives `R² = 0.2719`, against the target's own
  `corr² = 0.2717`;
* **level tracks each population**: the intercept must be refit per scale.

This file proves the exact finite-sample algebra of that experiment, for an
arbitrary finite data set `(xᵢ, yᵢ)_{i ∈ s}`.

* `sse_decomp` — the residual sum of squares of any affine predictor splits
  into a *level* term and a *shape* term.
* `level_refit_optimal` — for any transferred slope, refitting the level to the
  target mean is optimal ("level tracks each population").
* `transferR2_formula` — **the transfer law**:
  `R²_transfer(b) = corr² − (b − β̂)²·Sxx/Syy`, where `β̂` is the target OLS slope.
* `transferR2_le_corrSq`, `transferR2_eq_corrSq_iff` — transfer can never beat
  the target's `corr²`, and matches it iff the transferred slope is the target
  slope.  `affineR2_le_corrSq`: no affine predictor at all beats `corr²`.
* `corrSq_le_one` — Cauchy–Schwarz, derived from nonnegativity of the refit SSE.
* `transfer_gap_le_iff` — a gap tolerance `ε` is equivalent to a slope band
  `(b − β̂)² ≤ ε·Syy/Sxx`.
* `reported_pair_impossible` — **critic theorem**: no data set and no affine
  predictor can produce an in-sample transfer `R²` that rounds to `0.2719`
  while the same sample's `corr²` rounds to `0.2717`.  The reported pair
  therefore cannot be two in-sample statistics of one target sample.
-/

namespace PerNPredictor

open Finset

variable {ι : Type*} (s : Finset ι) (x y : ι → ℝ)

/-- Sample mean. -/
noncomputable def mean (f : ι → ℝ) : ℝ := (∑ i ∈ s, f i) / s.card

/-- Centered sum of squares `Σ (fᵢ − f̄)²`. -/
noncomputable def Sxx (f : ι → ℝ) : ℝ := ∑ i ∈ s, (f i - mean s f) ^ 2

/-- Centered cross sum `Σ (xᵢ − x̄)(yᵢ − ȳ)`. -/
noncomputable def Sxy : ℝ := ∑ i ∈ s, (x i - mean s x) * (y i - mean s y)

/-- Residual sum of squares of the affine predictor `a + b·x`. -/
noncomputable def sse (a b : ℝ) : ℝ := ∑ i ∈ s, (y i - (a + b * x i)) ^ 2

/-- Target OLS slope. -/
noncomputable def olsSlope : ℝ := Sxy s x y / Sxx s x

/-- Squared sample correlation. -/
noncomputable def corrSq : ℝ := Sxy s x y ^ 2 / (Sxx s x * Sxx s y)

/-- `R²` of an affine predictor evaluated on the target sample. -/
noncomputable def affineR2 (a b : ℝ) : ℝ := 1 - sse s x y a b / Sxx s y

/-- Transfer `R²`: slope `b` transferred, level refit to the target means. -/
noncomputable def transferR2 (b : ℝ) : ℝ := affineR2 s x y (mean s y - b * mean s x) b

theorem sum_sub_mean (f : ι → ℝ) (hs : s.Nonempty) : ∑ i ∈ s, (f i - mean s f) = 0 := by
  have hn : (s.card : ℝ) ≠ 0 := by exact_mod_cast hs.card_pos.ne'
  rw [sum_sub_distrib, sum_const, nsmul_eq_mul, mean]
  field_simp
  ring

/-- **Level/shape decomposition** of the residual sum of squares. -/
theorem sse_decomp (hs : s.Nonempty) (a b : ℝ) :
    sse s x y a b = s.card * (mean s y - a - b * mean s x) ^ 2
      + (Sxx s y - 2 * b * Sxy s x y + b ^ 2 * Sxx s x) := by
  have hx := sum_sub_mean s x hs
  have hy := sum_sub_mean s y hs
  set c := mean s y - a - b * mean s x
  have key : ∀ i ∈ s, (y i - (a + b * x i)) ^ 2 =
      (y i - mean s y) ^ 2 - 2 * b * ((x i - mean s x) * (y i - mean s y))
        + b ^ 2 * (x i - mean s x) ^ 2
        + 2 * c * ((y i - mean s y) - b * (x i - mean s x)) + c ^ 2 := by
    intro i _; simp only [c]; ring
  rw [sse, sum_congr rfl key, sum_add_distrib, sum_add_distrib, sum_add_distrib, sum_sub_distrib,
    ← mul_sum, ← mul_sum, ← mul_sum, sum_sub_distrib, ← mul_sum, hx, hy, sum_const, nsmul_eq_mul,
    Sxx, Sxx, Sxy]
  ring

/-- The SSE after refitting the level, for a transferred slope `b`. -/
theorem sse_refit (hs : s.Nonempty) (b : ℝ) :
    sse s x y (mean s y - b * mean s x) b = Sxx s y - 2 * b * Sxy s x y + b ^ 2 * Sxx s x := by
  rw [sse_decomp s x y hs]; ring

/-- **Level tracks each population.** For any slope, the target-mean level is
optimal: no other intercept gives a smaller residual. -/
theorem level_refit_optimal (hs : s.Nonempty) (a b : ℝ) :
    sse s x y (mean s y - b * mean s x) b ≤ sse s x y a b := by
  rw [sse_refit s x y hs, sse_decomp s x y hs]
  have : (0 : ℝ) ≤ s.card * (mean s y - a - b * mean s x) ^ 2 := by positivity
  linarith

/-- Completing the square in the slope. -/
theorem sse_refit_complete (hs : s.Nonempty) (hxx : 0 < Sxx s x) (b : ℝ) :
    sse s x y (mean s y - b * mean s x) b
      = Sxx s x * (b - olsSlope s x y) ^ 2 + (Sxx s y - Sxy s x y ^ 2 / Sxx s x) := by
  rw [sse_refit s x y hs, olsSlope]
  field_simp
  ring

theorem sse_nonneg (a b : ℝ) : 0 ≤ sse s x y a b :=
  sum_nonneg fun _ _ => sq_nonneg _

/-- **Cauchy–Schwarz**, read off from the nonnegativity of the refit SSE at the
OLS slope: `Sxy² ≤ Sxx·Syy`. -/
theorem sxy_sq_le (hs : s.Nonempty) (hxx : 0 < Sxx s x) :
    Sxy s x y ^ 2 ≤ Sxx s x * Sxx s y := by
  have h := sse_refit_complete s x y hs hxx (olsSlope s x y)
  have h0 := sse_nonneg s x y (mean s y - olsSlope s x y * mean s x) (olsSlope s x y)
  rw [h, sub_self] at h0
  have : Sxy s x y ^ 2 / Sxx s x ≤ Sxx s y := by nlinarith
  rw [div_le_iff₀ hxx] at this
  linarith

theorem corrSq_le_one (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y) :
    corrSq s x y ≤ 1 := by
  rw [corrSq, div_le_one (by positivity)]
  exact sxy_sq_le s x y hs hxx

/-- **The transfer law.** `R²_transfer(b) = corr² − (b − β̂)²·Sxx/Syy`. -/
theorem transferR2_formula (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y) (b : ℝ) :
    transferR2 s x y b = corrSq s x y - (b - olsSlope s x y) ^ 2 * Sxx s x / Sxx s y := by
  rw [transferR2, affineR2, sse_refit_complete s x y hs hxx, corrSq]
  field_simp
  ring

/-- In-sample OLS `R²` equals `corr²`. -/
theorem ols_R2_eq_corrSq (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y) :
    transferR2 s x y (olsSlope s x y) = corrSq s x y := by
  rw [transferR2_formula s x y hs hxx hyy]; simp

/-- Transfer can never beat the target's own `corr²`. -/
theorem transferR2_le_corrSq (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y)
    (b : ℝ) : transferR2 s x y b ≤ corrSq s x y := by
  rw [transferR2_formula s x y hs hxx hyy]
  have : 0 ≤ (b - olsSlope s x y) ^ 2 * Sxx s x / Sxx s y := by positivity
  linarith

/-- **Perfect shape transfer is rigid**: transfer `R²` equals `corr²` iff the
transferred slope is exactly the target OLS slope. -/
theorem transferR2_eq_corrSq_iff (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y)
    (b : ℝ) : transferR2 s x y b = corrSq s x y ↔ b = olsSlope s x y := by
  rw [transferR2_formula s x y hs hxx hyy]
  constructor
  · intro h
    have h1 : (b - olsSlope s x y) ^ 2 * Sxx s x / Sxx s y = 0 := by linarith
    rw [div_eq_zero_iff, mul_eq_zero] at h1
    rcases h1 with (h1 | h1) | h1
    · exact sub_eq_zero.mp (pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h1)
    · exact absurd h1 hxx.ne'
    · exact absurd h1 hyy.ne'
  · rintro rfl; simp

/-- No affine predictor whatsoever (any level, any slope) beats `corr²` on the
target sample. -/
theorem affineR2_le_corrSq (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y)
    (a b : ℝ) : affineR2 s x y a b ≤ corrSq s x y := by
  have h1 := transferR2_le_corrSq s x y hs hxx hyy b
  have h2 := level_refit_optimal s x y hs a b
  rw [transferR2, affineR2] at h1
  rw [affineR2]
  have : sse s x y (mean s y - b * mean s x) b / Sxx s y ≤ sse s x y a b / Sxx s y :=
    div_le_div_of_nonneg_right h2 hyy.le
  linarith

/-- **Gap tolerance = slope band.** The transfer loses at most `ε` of `corr²`
iff the transferred slope lies in the band `(b − β̂)² ≤ ε·Syy/Sxx`. -/
theorem transfer_gap_le_iff (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y)
    (b ε : ℝ) :
    corrSq s x y - transferR2 s x y b ≤ ε ↔
      (b - olsSlope s x y) ^ 2 ≤ ε * Sxx s y / Sxx s x := by
  rw [transferR2_formula s x y hs hxx hyy, sub_sub_cancel, div_le_iff₀ hyy,
    le_div_iff₀ hxx]

/-- **Critic theorem: the reported pair is not an in-sample pair.**  For every
finite data set with nondegenerate spreads and every affine predictor, it is
impossible that its target `R²` rounds (to four decimals) to `0.2719` while the
same sample's `corr²` rounds to `0.2717`. -/
theorem reported_pair_impossible (hs : s.Nonempty) (hxx : 0 < Sxx s x) (hyy : 0 < Sxx s y)
    (a b : ℝ) :
    ¬ (|affineR2 s x y a b - 0.2719| ≤ 0.00005 ∧ |corrSq s x y - 0.2717| ≤ 0.00005) := by
  rintro ⟨h1, h2⟩
  have h := affineR2_le_corrSq s x y hs hxx hyy a b
  rw [abs_le] at h1 h2
  norm_num at h1 h2
  linarith [h1.1, h2.2]

end PerNPredictor