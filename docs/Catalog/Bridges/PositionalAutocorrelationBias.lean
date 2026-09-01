/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The mean-centring artefact in a hit-position lag profile

Companion to `Catalog.Bridges.ConsecutiveVDependency` (paper 249, hit-position
thread).  That file shows that under *pure density* — independent hits with a
position-dependent rate — the population lag-`k` statistic centred at the true
rate curve is exactly zero, and that the literal (global-mean) reading can only
be perturbed by `O(δ²)`.

The experimental record contains one further observation that neither statement
explains: the measured detrended profile was not scattered around `0` but sat at
a **uniform ≈ −0.01 offset across all twenty lags**, with the mirrored `+0.01`
appearing on controls; 12 of 20 bootstrap intervals excluded zero on the
negative side while the profile stayed far below the `0.05` bar.  A uniform
offset shared by every lag is not sequence structure; the record calls it an
"opposite-sign shared-magnitude artefact".

This file proves that the artefact is *forced by arithmetic alone*.  For **any**
real record `x` of length `n`, once the residuals are taken about the *sample*
mean, the cyclic autocovariances at the `n - 1` nonzero lags must sum to exactly
minus the lag-0 term:

* `cAutocov_total` — `∑_{k} C(k) = 0` over all lags including `k = 0`;
* `cAutocov_nonzero_sum` — hence `∑_{k ≠ 0} C(k) = -C(0)`;
* `mean_autocorrelation_eq_neg_inv` — the **average autocorrelation over the
  nonzero lags equals `-1/(n-1)`**, for every record with nonconstant values;
* `flat_profile_level` — consequently, if a measured profile is flat to within
  `ε`, its level is pinned to within `ε` of `-1/(n-1)`;
* `flat_profile_level_of_window` — the numerical instance: a flat profile on a
  window of `n = 101` positions must sit at `-0.01 ± ε`.

No probability enters: the identity is a property of the centring operator.  So
a small uniform negative offset in a lag profile carries *no evidence at all*
about dependence, and only deviations from the level `-1/(n-1)` — in particular
a lag-1 spike, cf. `ConsecutiveVDependency.markovCorr_eq_lambda_pow` — can.
-/

import Mathlib

open Finset

namespace PositionalAutocorrelationBias

variable {n : ℕ} [NeZero n]

/-- Sample mean of a cyclic record of length `n`. -/
noncomputable def cmean (x : ZMod n → ℝ) : ℝ := (∑ i, x i) / n

/-- Residual about the sample mean. -/
noncomputable def resid (x : ZMod n → ℝ) (i : ZMod n) : ℝ := x i - cmean x

/-- Residuals about the sample mean sum to zero. -/
theorem resid_sum_zero (x : ZMod n → ℝ) : ∑ i, resid x i = 0 := by
  have hn : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne n)
  unfold resid cmean
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, ZMod.card n, nsmul_eq_mul]
  field_simp
  ring

theorem resid_shift_sum (x : ZMod n → ℝ) (i : ZMod n) :
    ∑ k : ZMod n, resid x (i + k) = ∑ j, resid x j :=
  Fintype.sum_equiv (Equiv.addLeft i) _ _ (fun _ => rfl)

/-- Cyclic autocovariance of the record at lag `k`, about the sample mean. -/
noncomputable def cAutocov (x : ZMod n → ℝ) (k : ZMod n) : ℝ :=
  ∑ i, resid x i * resid x (i + k)

/-- Lag-0 autocovariance is the residual sum of squares. -/
theorem cAutocov_zero (x : ZMod n → ℝ) : cAutocov x 0 = ∑ i, resid x i ^ 2 := by
  unfold cAutocov
  exact Finset.sum_congr rfl (fun i _ => by rw [add_zero, sq])

/-- **The whole cyclic lag profile sums to zero.** -/
theorem cAutocov_total (x : ZMod n → ℝ) : ∑ k : ZMod n, cAutocov x k = 0 := by
  unfold cAutocov
  rw [Finset.sum_comm]
  have h : ∀ i : ZMod n, ∑ k : ZMod n, resid x i * resid x (i + k) = 0 := by
    intro i
    rw [← Finset.mul_sum, resid_shift_sum, resid_sum_zero, mul_zero]
  simp [h]

/-- **The nonzero lags must absorb minus the variance.**  Mean-centring alone
forces the sum of the autocovariances over the `n - 1` nonzero lags to equal
`-C(0)`, whatever the record. -/
theorem cAutocov_nonzero_sum (x : ZMod n → ℝ) :
    ∑ k ∈ Finset.univ.erase (0 : ZMod n), cAutocov x k = -cAutocov x 0 := by
  have h := cAutocov_total x
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (0 : ZMod n))] at h
  linarith

/-- Sample autocorrelation at lag `k`. -/
noncomputable def cAutocorr (x : ZMod n → ℝ) (k : ZMod n) : ℝ := cAutocov x k / cAutocov x 0

/-- **The mean-centring artefact.**  For every nonconstant record of length
`n ≥ 2`, the average sample autocorrelation over the `n - 1` nonzero lags is
exactly `-1/(n-1)` — a uniform negative offset produced by the centring
operator, carrying no information about dependence. -/
theorem mean_autocorrelation_eq_neg_inv (x : ZMod n → ℝ) (hvar : cAutocov x 0 ≠ 0) :
    (∑ k ∈ Finset.univ.erase (0 : ZMod n), cAutocorr x k) / (n - 1 : ℝ) = -1 / (n - 1 : ℝ) := by
  have hsum : ∑ k ∈ Finset.univ.erase (0 : ZMod n), cAutocorr x k = -1 := by
    unfold cAutocorr
    rw [← Finset.sum_div, cAutocov_nonzero_sum, neg_div, div_self hvar]
  rw [hsum]

/-- The nonzero lags of a length-`n` cyclic record number `n - 1`. -/
theorem card_nonzero_lags :
    (Finset.univ.erase (0 : ZMod n)).card = n - 1 := by
  rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, ZMod.card n]

/-- **A flat profile is pinned to the artefact level.**  If every nonzero-lag
autocorrelation lies within `ε` of a common level `t`, then `t` is within `ε` of
`-1/(n-1)`.  A flat, slightly negative profile at that level is therefore the
*signature of no dependence*, not weak dependence. -/
theorem flat_profile_level (x : ZMod n → ℝ) (hn : 2 ≤ n) (hvar : cAutocov x 0 ≠ 0)
    (t ε : ℝ) (hflat : ∀ k ∈ Finset.univ.erase (0 : ZMod n), |cAutocorr x k - t| ≤ ε) :
    |t + 1 / (n - 1 : ℝ)| ≤ ε := by
  have hcard : ((Finset.univ.erase (0 : ZMod n)).card : ℝ) = (n : ℝ) - 1 := by
    rw [card_nonzero_lags]
    have : (1 : ℕ) ≤ n := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hne : ((n : ℝ) - 1) ≠ 0 := by
    have : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  have hpos : (0 : ℝ) < (n : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  have hsum : ∑ k ∈ Finset.univ.erase (0 : ZMod n), cAutocorr x k = -1 := by
    unfold cAutocorr
    rw [← Finset.sum_div, cAutocov_nonzero_sum, neg_div, div_self hvar]
  have hdev : |∑ k ∈ Finset.univ.erase (0 : ZMod n), (cAutocorr x k - t)|
      ≤ ((n : ℝ) - 1) * ε := by
    calc |∑ k ∈ Finset.univ.erase (0 : ZMod n), (cAutocorr x k - t)|
        ≤ ∑ k ∈ Finset.univ.erase (0 : ZMod n), |cAutocorr x k - t| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _k ∈ Finset.univ.erase (0 : ZMod n), ε := Finset.sum_le_sum hflat
      _ = ((n : ℝ) - 1) * ε := by
          rw [Finset.sum_const, nsmul_eq_mul, hcard]
  rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, nsmul_eq_mul, hcard] at hdev
  have hrw : (-1 : ℝ) - ((n : ℝ) - 1) * t = -(((n : ℝ) - 1) * (t + 1 / ((n : ℝ) - 1))) := by
    field_simp
    ring
  rw [hrw, abs_neg, abs_mul, abs_of_pos hpos] at hdev
  exact le_of_mul_le_mul_left (by linarith) hpos

/-- **A perfectly flat profile is pinned exactly.**  If all nonzero-lag
autocorrelations of a record coincide, their common value is `-1/(n-1)`.  Cyclic
difference sets realise this extreme case, so the artefact level is attained, not
just approached. -/
theorem constant_profile_eq_neg_inv (x : ZMod n → ℝ) (hn : 2 ≤ n) (hvar : cAutocov x 0 ≠ 0)
    (t : ℝ) (hconst : ∀ k ∈ Finset.univ.erase (0 : ZMod n), cAutocorr x k = t) :
    t = -1 / (n - 1 : ℝ) := by
  have h := flat_profile_level x hn hvar t 0 (fun k hk => by rw [hconst k hk]; simp)
  have h0 : t + 1 / ((n : ℝ) - 1) = 0 := by
    have := abs_nonneg (t + 1 / ((n : ℝ) - 1))
    have := abs_eq_zero.mp (le_antisymm h this)
    exact this
  rw [neg_div]
  linarith

/-- Numerical instance matching the experimental window: on `n = 101` scan
positions a profile flat to within `ε` must sit at level `-0.01` up to `ε`
— exactly the recorded "uniform ≈ −0.01 offset". -/
theorem flat_profile_level_of_window (x : ZMod 101 → ℝ) (hvar : cAutocov x 0 ≠ 0)
    (t ε : ℝ) (hflat : ∀ k ∈ Finset.univ.erase (0 : ZMod 101), |cAutocorr x k - t| ≤ ε) :
    |t + 1 / 100| ≤ ε := by
  have h := flat_profile_level x (by norm_num) hvar t ε hflat
  norm_num at h
  exact h

end PositionalAutocorrelationBias