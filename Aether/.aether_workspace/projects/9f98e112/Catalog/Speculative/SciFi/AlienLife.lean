import Mathlib

/-! # CatalogBuild.Speculative.SciFi.AlienLife

Unified from AlienLife and AlienLife_2.
Probability theory for detection, Poisson processes, and combinatorial growth.
-/}

noncomputable section

/-- Probability of never matching after n independent trials tends to 0. -/
theorem no_match_prob_tendsto_zero (k : ℕ) (A : ℕ) (hA : 1 < A) (hk : 0 < k) :
    Filter.Tendsto (fun n => (1 - (1 : ℝ) / A ^ k) ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one
    (sub_nonneg.2 <| div_le_self zero_le_one <| one_le_pow₀ <| mod_cast hA.le)
    (sub_lt_self _ <| by positivity)

/-- The per-trial miss probability is strictly less than 1. -/
theorem trial_prob_lt_one (k : ℕ) (A : ℕ) (hA : 1 < A) (hk : 0 < k) :
    (1 : ℝ) - 1 / (A : ℝ) ^ k < 1 := by
  exact sub_lt_self _ (by positivity)

/-- The per-trial miss probability is nonnegative. -/
theorem trial_prob_nonneg (k : ℕ) (A : ℕ) (hA : 1 < A) (hk : 0 < k) :
    0 ≤ (1 : ℝ) - 1 / (A : ℝ) ^ k := by
  exact sub_nonneg.2 <| div_le_self zero_le_one <| mod_cast Nat.one_le_pow _ _ hA.le

/-- CDF of the nearest-neighbor distance in a 3D Poisson process. -/
def poissonNearestCDF (ρ r : ℝ) : ℝ :=
  1 - Real.exp (-(4 * Real.pi * ρ * r ^ 3 / 3))

theorem poissonNearestCDF_zero (ρ : ℝ) : poissonNearestCDF ρ 0 = 0 := by
  unfold poissonNearestCDF; norm_num

theorem poissonNearestCDF_tendsto_one (ρ : ℝ) (hρ : 0 < ρ) :
    Filter.Tendsto (poissonNearestCDF ρ) Filter.atTop (nhds 1) := by
  exact le_trans (tendsto_const_nhds.sub <| Real.tendsto_exp_atBot.comp <|
    Filter.tendsto_neg_atTop_atBot.comp <| Filter.Tendsto.atTop_div_const (by positivity) <|
    Filter.Tendsto.const_mul_atTop (by positivity) <| Filter.tendsto_pow_atTop (by positivity))
    (by norm_num)

/-- Miss probability strictly decreases with more trials. -/
theorem miss_probability_decreases (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    StrictAnti (fun n : ℕ => (1 - p) ^ n) := by
  exact fun n m hnm => pow_lt_pow_right_of_lt_one₀ (by linarith) (by linarith) hnm

/-- Miss probability vanishes in the limit. -/
theorem miss_probability_vanishes (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    Filter.Tendsto (fun n : ℕ => (1 - p) ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one (by linarith) (by linarith)

/-- Hit probability approaches certainty. -/
theorem hit_probability_approaches_one (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    Filter.Tendsto (fun n : ℕ => 1 - (1 - p) ^ n) Filter.atTop (nhds 1) := by
  exact le_trans (tendsto_const_nhds.sub (tendsto_pow_atTop_nhds_zero_of_lt_one (by linarith) (by linarith)))
    (by norm_num)

/-- Poisson void probability is always < 1 for positive rate. -/
theorem poisson_void_probability (lam : ℝ) (hlam : 0 < lam) :
    Real.exp (-lam) < 1 := by
  aesop

/-- Poisson detection limit tends to 1. -/
theorem poisson_detection_limit :
    Filter.Tendsto (fun x : ℝ => 1 - Real.exp (-x)) Filter.atTop (nhds 1) := by
  simpa using tendsto_const_nhds.sub (Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot)

/-- Arrangements grow monotonically. -/
theorem arrangements_grow (k : ℕ) (hk : 0 < k) :
    StrictMono (fun n : ℕ => n ^ k) := by
  exact fun a b h => Nat.pow_lt_pow_left h hk.ne'

/-- Factorial eventually beats exponential growth. -/
theorem factorial_beats_exponential :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 2 ^ n < n.factorial := by
  exact ⟨4, fun n hn => by induction hn <;> norm_num [Nat.factorial_succ, pow_succ'] at *; nlinarith⟩

end
