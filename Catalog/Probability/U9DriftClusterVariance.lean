/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Probability.U9DriftPaired

/-!
# Cluster decomposition of the dispersion: why `128` clusters, not `19.2·10⁶` pairs

Context (experiment 569, paper 216).  The run draws `m = 128` moduli `N` and `n = 150000`
candidate/control pairs inside each, and bootstraps over the `N`-clusters.  The previous
file (`Probability.U9DriftLocalDensity`) shows *why* the between-cluster dispersion is
large; this file proves the exact identity that converts that fact into a design rule.

Main results:

* `U9Drift.sum_sub_emean_eq_zero` — the residuals inside a cluster sum to zero.
* `U9Drift.sum_sq_sub_const` — the bias–variance shift: `∑ (x - c)² = ∑ (x - x̄)² + n(x̄ - c)²`,
  and hence `U9Drift.evar_le_mean_sq_sub` — the empirical variance is the *minimum* over
  centres.
* `U9Drift.anova_decomposition` — for a balanced two-level design the total dispersion
  splits exactly as `total = within + between`.
* `U9Drift.between_le_total` — the between-cluster variance is a lower bound for the total
  dispersion: no amount of within-cluster sampling can shrink it.
* `U9Drift.pairs_cannot_beat_clusters` — the quantitative design rule: whatever the number
  of pairs per cluster, the dispersion of the design is at least the between-cluster
  variance, which by `U9Drift.variance_signProd` is exponentially large in the number of
  small primes.  Only increasing the cluster count `m` helps.
-/

namespace U9Drift

open Finset

/-! ## Residuals and the shift identity -/

theorem sum_sub_emean_eq_zero {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) :
    ∑ j, (f j - emean f) = 0 := by
  have hnR : ((n : ℝ)) ≠ 0 := by
    have : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
    exact ne_of_gt this
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, emean]
  field_simp
  ring

/-- Shifting the centre costs exactly `n (x̄ - c)²`. -/
theorem sum_sq_sub_const {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) (c : ℝ) :
    ∑ j, (f j - c) ^ 2 = (∑ j, (f j - emean f) ^ 2) + (n : ℝ) * (emean f - c) ^ 2 := by
  have hzero := sum_sub_emean_eq_zero hn f
  have hexp : ∀ j : Fin n, (f j - c) ^ 2
      = (f j - emean f) ^ 2 + 2 * (emean f - c) * (f j - emean f) + (emean f - c) ^ 2 := by
    intro j; ring
  rw [Finset.sum_congr rfl fun j _ => hexp j]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hzero,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  ring

/-- The empirical variance is the minimum mean square deviation, attained at the mean. -/
theorem evar_le_mean_sq_sub {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) (c : ℝ) :
    evar f ≤ (∑ j, (f j - c) ^ 2) / n := by
  have hnR : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
  rw [evar, sum_sq_sub_const hn f c, add_div]
  have : 0 ≤ (n : ℝ) * (emean f - c) ^ 2 / n := by positivity
  linarith

/-! ## The balanced two-level (ANOVA) decomposition -/

/-- Mean of cluster `i`. -/
noncomputable def clusterMean {m n : ℕ} (x : Fin m → Fin n → ℝ) (i : Fin m) : ℝ :=
  emean (x i)

/-- Grand mean of a balanced design. -/
noncomputable def grandMean {m n : ℕ} (x : Fin m → Fin n → ℝ) : ℝ :=
  emean (clusterMean x)

/-- Mean within-cluster variance. -/
noncomputable def withinVar {m n : ℕ} (x : Fin m → Fin n → ℝ) : ℝ :=
  emean (fun i => evar (x i))

/-- Between-cluster variance of the cluster means. -/
noncomputable def betweenVar {m n : ℕ} (x : Fin m → Fin n → ℝ) : ℝ :=
  evar (clusterMean x)

/-- Total dispersion of all `m·n` observations about the grand mean. -/
noncomputable def totalVar {m n : ℕ} (x : Fin m → Fin n → ℝ) : ℝ :=
  (∑ i, ∑ j, (x i j - grandMean x) ^ 2) / ((m : ℝ) * n)

/-- **The exact ANOVA identity for a balanced design**: `total = within + between`. -/
theorem anova_decomposition {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (x : Fin m → Fin n → ℝ) :
    totalVar x = withinVar x + betweenVar x := by
  have hmR : (0:ℝ) < (m:ℝ) := by exact_mod_cast hm
  have hnR : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
  have hrow : ∀ i : Fin m, ∑ j, (x i j - grandMean x) ^ 2
      = (∑ j, (x i j - clusterMean x i) ^ 2)
        + (n : ℝ) * (clusterMean x i - grandMean x) ^ 2 := by
    intro i
    exact sum_sq_sub_const hn (x i) (grandMean x)
  have hsum : ∑ i, ∑ j, (x i j - grandMean x) ^ 2
      = (∑ i, ∑ j, (x i j - clusterMean x i) ^ 2)
        + (n : ℝ) * ∑ i, (clusterMean x i - grandMean x) ^ 2 := by
    rw [Finset.sum_congr rfl fun i _ => hrow i, Finset.sum_add_distrib, Finset.mul_sum]
  have hw : withinVar x = (∑ i, ∑ j, (x i j - clusterMean x i) ^ 2) / ((m : ℝ) * n) := by
    simp only [withinVar, emean, evar, clusterMean]
    rw [← Finset.sum_div, div_div, mul_comm]
  have hb : betweenVar x = (∑ i, (clusterMean x i - grandMean x) ^ 2) / m := rfl
  rw [totalVar, hsum, hw, hb]
  field_simp

/-- The between-cluster variance is a floor for the total dispersion. -/
theorem between_le_total {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (x : Fin m → Fin n → ℝ) :
    betweenVar x ≤ totalVar x := by
  rw [anova_decomposition hm hn x]
  have hw : 0 ≤ withinVar x := by
    rw [withinVar, emean]
    apply div_nonneg _ (Nat.cast_nonneg m)
    exact Finset.sum_nonneg fun i _ => evar_nonneg (x i)
  linarith

/-- **The design rule.**  However many pairs are drawn inside each cluster, the dispersion
of the realised design is bounded below by the between-cluster variance; if that variance
exceeds a target `t`, no within-cluster effort can bring the total dispersion below `t`. -/
theorem pairs_cannot_beat_clusters {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (x : Fin m → Fin n → ℝ) {t : ℝ} (ht : t ≤ betweenVar x) : t ≤ totalVar x :=
  le_trans ht (between_le_total hm hn x)

end U9Drift