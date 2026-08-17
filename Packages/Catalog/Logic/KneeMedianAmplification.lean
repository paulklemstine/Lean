/-
# Cycle 3: why the centre of a three-seed distribution is the robust reading
# (majority amplification on the quota ladder, NET-48 follow-up)

`Logic.KneeMedianLaw` proved that the quota ladder of a three-seed ensemble reads
`min ≤ median ≤ max`, and `Logic.KneeQuotaScaling` proved that one seed can move a rung by
at most one step.  Both are worst-case statements.  This file supplies the *average-case*
half of the picture, which is what the NET-48 round actually appeals to when it says that
per-seed knees are too noisy to predict but the distribution's centre is stable.

The model is the honest one for a seed sweep: three independent seeds, each of which has
probability `p` of having its knee at or below a fixed budget `b`.  Since
`quotaBudget K m ≤ b ↔ m ≤ #(passSet K b)` (`quotaBudget_le_iff`, proved here in full
generality), the probability that the `m`-th rung of the ladder sits at or below `b` is the
probability that at least `m` of the three seeds pass — the polynomial `quotaProb p m`,
computed here directly from the eight-point sample space.

**Results.**
* `KneeAmplify.quotaProb_three`, `quotaProb_two`, `quotaProb_one` : the three rung
  distribution functions are `p³`, `3p² − 2p³`, `3p − 3p² + p³`.
* `KneeAmplify.quota_ladder_prob` : they are ordered on `[0,1]`, mirroring the
  combinatorial ladder `min ≤ median ≤ max`.
* `KneeAmplify.median_calibrated` and `extremes_not_calibrated` : at `p = 1/2` the median
  rung reads `1/2` while the other rungs read `1/8` and `7/8`.  **The median is the unique
  calibrated rung** — the guarantee rung is systematically pessimistic and the best-case
  rung systematically optimistic, by a factor of four at the symmetric point.
* `KneeAmplify.median_amplifies` / `median_attenuates` / `median_fixed_points` : the median
  strictly amplifies a per-seed majority (`p > 1/2 ⟹ 3p² − 2p³ > p`), strictly attenuates a
  per-seed minority, and has exactly the three fixed points `0, 1/2, 1`.
* `KneeAmplify.median_deriv_at_half` : the derivative of the amplification map at `1/2` is
  `3/2 > 1`; the calibrated point is a *repelling* fixed point, which is the precise sense
  in which three seeds sharpen a majority tendency into a stable centre.
* `KneeAmplify.net48_amplification_example` : the quantitative reading for the round — the
  observed per-seed frequency `2/3` of landing at or below the `7/8` budget becomes `20/27`
  for the three-seed median, while the guarantee rung sees only `8/27`.
-/

import Mathlib
import Logic.KneeQuotaScaling

namespace KneeAmplify

open Finset KneeMedian

/-! ## 1.  Rungs of the ladder as events -/

/-- **A quota budget sits at or below `b` exactly when the quota is met at `b`.**  This is
what makes the rung distribution functions below the honest ones. -/
theorem quotaBudget_le_iff {ι : Type*} [Fintype ι] (K : ι → ℕ) {m b : ℕ}
    (hm : m ≤ Fintype.card ι) : quotaBudget K m ≤ b ↔ m ≤ (passSet K b).card := by
  refine ⟨fun h => ?_, quotaBudget_le_of_card⟩
  exact (card_passSet_quotaBudget hm).trans (card_le_card (passSet_mono K h))

/-! ## 2.  The three-seed sample space -/

/-- The Bernoulli weight of one seed: `p` if it passes, `1 - p` if it does not. -/
noncomputable def wt (p : ℝ) (b : Bool) : ℝ := if b then p else 1 - p

/-- The number of passing seeds in a three-seed outcome. -/
def cnt3 (x : Bool × Bool × Bool) : ℕ :=
  (if x.1 then 1 else 0) + (if x.2.1 then 1 else 0) + (if x.2.2 then 1 else 0)

/-- The probability that at least `m` of three independent seeds pass at a given budget —
equivalently, by `quotaBudget_le_iff`, that the `m`-th rung of the quota ladder sits at or
below that budget. -/
noncomputable def quotaProb (p : ℝ) (m : ℕ) : ℝ :=
  ∑ x : Bool × Bool × Bool, if m ≤ cnt3 x then wt p x.1 * wt p x.2.1 * wt p x.2.2 else 0

/-- The guarantee rung (all three seeds pass): `p³`. -/
theorem quotaProb_three (p : ℝ) : quotaProb p 3 = p ^ 3 := by
  simp [quotaProb, Fintype.sum_prod_type, wt, cnt3]
  ring

/-- The median rung (a majority passes): `3p² − 2p³`. -/
theorem quotaProb_two (p : ℝ) : quotaProb p 2 = 3 * p ^ 2 - 2 * p ^ 3 := by
  simp [quotaProb, Fintype.sum_prod_type, wt, cnt3]
  ring

/-- The best-case rung (at least one seed passes): `3p − 3p² + p³`. -/
theorem quotaProb_one (p : ℝ) : quotaProb p 1 = 3 * p - 3 * p ^ 2 + p ^ 3 := by
  simp [quotaProb, Fintype.sum_prod_type, wt, cnt3]
  ring

/-- **The probabilistic ladder mirrors the combinatorial one.**  The guarantee rung is the
least likely to be met, the best-case rung the most likely. -/
theorem quota_ladder_prob {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    quotaProb p 3 ≤ quotaProb p 2 ∧ quotaProb p 2 ≤ quotaProb p 1 := by
  rw [quotaProb_one, quotaProb_two, quotaProb_three]
  constructor <;>
    nlinarith [sq_nonneg p, sq_nonneg (1 - p), mul_nonneg h0 (sq_nonneg (1 - p)),
      mul_nonneg (sub_nonneg.mpr h1) (sq_nonneg p)]

/-! ## 3.  Calibration and amplification -/

/-- **The median rung is calibrated.**  A per-seed coin flip gives a coin flip for the
three-seed median. -/
theorem median_calibrated : quotaProb (1 / 2) 2 = 1 / 2 := by
  rw [quotaProb_two]; norm_num

/-- **The extreme rungs are not calibrated**, and are wrong by a factor of four in opposite
directions: the guarantee rung reads `1/8`, the best-case rung `7/8`. -/
theorem extremes_not_calibrated :
    quotaProb (1 / 2) 3 = 1 / 8 ∧ quotaProb (1 / 2) 1 = 7 / 8 ∧
      quotaProb (1 / 2) 3 ≠ 1 / 2 ∧ quotaProb (1 / 2) 1 ≠ 1 / 2 := by
  rw [quotaProb_three, quotaProb_one]
  norm_num

/-- **Majority amplification.**  If a single seed is more likely than not to land at or
below a budget, the three-seed median is *strictly more* likely to do so. -/
theorem median_amplifies {p : ℝ} (h : 1 / 2 < p) (h1 : p < 1) : p < quotaProb p 2 := by
  rw [quotaProb_two]
  nlinarith [mul_pos (mul_pos (show (0 : ℝ) < p by linarith)
    (show (0 : ℝ) < 2 * p - 1 by linarith)) (show (0 : ℝ) < 1 - p by linarith)]

/-- **Minority attenuation.**  Symmetrically, a per-seed minority is suppressed. -/
theorem median_attenuates {p : ℝ} (h0 : 0 < p) (h : p < 1 / 2) : quotaProb p 2 < p := by
  rw [quotaProb_two]
  nlinarith [mul_pos (mul_pos h0 (show (0 : ℝ) < 1 - 2 * p by linarith))
    (show (0 : ℝ) < 1 - p by linarith)]

/-- **Exactly three fixed points.**  The amplification map fixes only the two certainties
and the calibrated point: `0`, `1/2`, `1`. -/
theorem median_fixed_points (p : ℝ) : quotaProb p 2 = p ↔ p = 0 ∨ p = 1 / 2 ∨ p = 1 := by
  rw [quotaProb_two]
  constructor
  · intro h
    have hfac : p * ((2 * p - 1) * (1 - p)) = 0 := by nlinarith [h]
    rcases mul_eq_zero.mp hfac with h0 | hrest
    · exact Or.inl h0
    · rcases mul_eq_zero.mp hrest with h1 | h2
      · exact Or.inr (Or.inl (by linarith))
      · exact Or.inr (Or.inr (by linarith))
  · rintro (rfl | rfl | rfl) <;> norm_num

/-- **The calibrated point is repelling.**  The derivative of the amplification map at
`1/2` is `3/2 > 1`, so a tendency in the per-seed distribution is sharpened, not merely
preserved, by reading the median of three seeds. -/
theorem median_deriv_at_half :
    deriv (fun p : ℝ => 3 * p ^ 2 - 2 * p ^ 3) (1 / 2) = 3 / 2 ∧ (1 : ℝ) < 3 / 2 := by
  have hd : ∀ p : ℝ, HasDerivAt (fun p : ℝ => 3 * p ^ 2 - 2 * p ^ 3) (6 * p - 6 * p ^ 2) p := by
    intro p
    have h1 : HasDerivAt (fun p : ℝ => 3 * p ^ 2) (3 * (2 * p)) p := by
      simpa using ((hasDerivAt_pow 2 p).const_mul 3)
    have h2 : HasDerivAt (fun p : ℝ => 2 * p ^ 3) (2 * (3 * p ^ 2)) p := by
      simpa using ((hasDerivAt_pow 3 p).const_mul 2)
    have h3 := h1.sub h2
    convert h3 using 1
    ring
  refine ⟨?_, by norm_num⟩
  rw [(hd (1 / 2)).deriv]
  norm_num

/-- **The reading for the round.**  Take the observed frequency as the per-seed
probability: four of the six recorded seeds (two of three at each context) have their knee
at or below the `7/8` budget, i.e. `p = 2/3`.  Then the three-seed median lands there with
probability `20/27 > 2/3`, while the guarantee rung is met only with probability `8/27`.
Reading the centre is what converts noisy per-seed knees into a stable law. -/
theorem net48_amplification_example :
    quotaProb (2 / 3) 2 = 20 / 27 ∧ quotaProb (2 / 3) 3 = 8 / 27 ∧
      (2 : ℝ) / 3 < 20 / 27 ∧ (8 : ℝ) / 27 < 2 / 3 := by
  rw [quotaProb_two, quotaProb_three]
  norm_num

end KneeAmplify