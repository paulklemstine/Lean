/-
  Mathematics of Science Fiction — Chapter 10: Probability and Alien Life
  Infinite monkey theorem, Borel-Cantelli, Poisson nearest-neighbor.
  Author: Paul Klemstine | Soli Deo Gloria
-/
import Mathlib

open MeasureTheory ProbabilityTheory Real BigOperators

noncomputable section

/-! ## The Infinite Monkey Theorem (Combinatorial Core)

  The probability of NOT matching a pattern in n independent trials → 0. -/

/-
The probability of not matching in n independent blocks goes to 0.
-/
theorem no_match_prob_tendsto_zero (k : ℕ) (A : ℕ) (hA : 1 < A) (hk : 0 < k) :
    Filter.Tendsto (fun n => (1 - (1 : ℝ) / A ^ k) ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one ( sub_nonneg.2 <| div_le_self zero_le_one <| one_le_pow₀ <| mod_cast hA.le ) ( sub_lt_self _ <| by positivity )

/-
Each trial probability is in [0, 1).
-/
theorem trial_prob_lt_one (k : ℕ) (A : ℕ) (hA : 1 < A) (hk : 0 < k) :
    (1 : ℝ) - 1 / (A : ℝ) ^ k < 1 := by
  exact sub_lt_self _ ( by positivity )

/-
Each trial probability is non-negative.
-/
theorem trial_prob_nonneg (k : ℕ) (A : ℕ) (hA : 1 < A) (hk : 0 < k) :
    0 ≤ (1 : ℝ) - 1 / (A : ℝ) ^ k := by
  exact sub_nonneg.2 <| div_le_self zero_le_one <| mod_cast Nat.one_le_pow _ _ hA.le

/-! ## Poisson Nearest Neighbor

  For a Poisson process in ℝ³ with density ρ, the CDF of nearest-neighbor distance is
  P(D ≤ r) = 1 - exp(-4πρr³/3). -/

/-- CDF of the nearest-neighbor distance in a 3D Poisson process. -/
def poissonNearestCDF (ρ r : ℝ) : ℝ :=
  1 - Real.exp (-(4 * Real.pi * ρ * r ^ 3 / 3))

/-
The CDF is 0 at r = 0.
-/
theorem poissonNearestCDF_zero (ρ : ℝ) : poissonNearestCDF ρ 0 = 0 := by
  unfold poissonNearestCDF; norm_num;

/-
The CDF approaches 1 as r → ∞ for positive density.
-/
theorem poissonNearestCDF_tendsto_one (ρ : ℝ) (hρ : 0 < ρ) :
    Filter.Tendsto (poissonNearestCDF ρ) Filter.atTop (nhds 1) := by
  exact le_trans ( tendsto_const_nhds.sub <| Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.Tendsto.atTop_div_const ( by positivity ) <| Filter.Tendsto.const_mul_atTop ( by positivity ) <| Filter.tendsto_pow_atTop ( by positivity ) ) <| by norm_num;

end