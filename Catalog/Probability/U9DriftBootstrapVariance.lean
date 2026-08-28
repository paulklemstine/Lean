/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Probability.U9DriftClusterVariance

/-!
# The cluster bootstrap has variance exactly `between / m`

Context (experiment 569, paper 216).  The run reports percentile intervals from a
*cluster bootstrap*: the `m = 128` moduli are resampled with replacement (`NB = 2000`
draws) and the ratio statistic is recomputed from the resampled clusters.  Conjecture
**C3** of `FUTURE_DIRECTIONS.md` asserts that the pair count `n` per modulus is not a
power lever: the spread of the bootstrap distribution is governed by the *cluster* count.

This file closes the structural half of that conjecture, exactly and without asymptotics.
The bootstrap resample space is the finite set of all `m ^ m` index maps
`s : Fin m → Fin m`, each equally likely, and the resampled statistic is the mean of the
resampled cluster values.

Main results.

* `U9Drift.sum_resample_prod` — the marginalisation identity for the resample space:
  `∑_{s} ∏_i F i (s i) = ∏_i ∑_j F i j`.  This is the exact finite-sample form of
  "the resample coordinates are independent".
* `U9Drift.sum_resample_eval` and `U9Drift.sum_resample_eval_pair` — its one- and
  two-coordinate corollaries, `m ^ (m-1) ∑ g` and `m ^ (m-2) (∑ g)(∑ h)`.
* `U9Drift.bootVar_eq` — **the exact bootstrap variance law**: for any cluster values `c`,
  the variance of the resample mean over the whole resample space is `evar c / m`.
  No asymptotics, no approximation: the `1 / m` is exact at every `m`.
* `U9Drift.cluster_bootVar_eq` — applied to a balanced two-level design, the cluster
  bootstrap variance is exactly `betweenVar x / m` and therefore does not involve the
  within-cluster dispersion at all: the pair count `n` enters only through the value of
  `betweenVar`.
* `U9Drift.bootVar_le_totalVar_div` and `U9Drift.clusters_needed_iff` — the design rule in
  the form the follow-up run needs: to reach a target bootstrap standard error `t` one
  needs `m ≥ evar c / t²` clusters, whatever the pair count.
* `U9Drift.bootVar_pos_of_ne` — non-degeneracy: the bootstrap spread vanishes only for a
  constant cluster population, so the interval is never artificially tight.
-/

namespace U9Drift

open Finset

variable {m : ℕ}

/-! ## Marginalisation over the resample space -/

/-- **Exact independence of the resample coordinates.**  Summing a product of
coordinatewise weights over all `m ^ m` resample maps factors as a product of sums. -/
theorem sum_resample_prod (F : Fin m → Fin m → ℝ) :
    ∑ s : Fin m → Fin m, ∏ i, F i (s i) = ∏ i, ∑ j, F i j := by
  classical
  rw [Finset.prod_univ_sum, Fintype.piFinset_univ]

/-- Marginalising all coordinates but one. -/
theorem sum_resample_eval (g : Fin m → ℝ) (k : Fin m) :
    ∑ s : Fin m → Fin m, g (s k) = (m : ℝ) ^ (m - 1) * ∑ i, g i := by
  classical
  have h := sum_resample_prod (m := m) (fun i j => if i = k then g j else 1)
  have hl : ∀ s : Fin m → Fin m,
      (∏ i, if i = k then g (s i) else (1 : ℝ)) = g (s k) := by
    intro s
    simp
  have hr : ∀ i : Fin m, (∑ j, if i = k then g j else (1 : ℝ))
      = if i = k then (∑ j, g j) else (m : ℝ) := by
    intro i
    by_cases hik : i = k
    · simp [hik]
    · simp [hik]
  have hprod : (∏ i : Fin m, if i = k then (∑ j, g j) else (m : ℝ))
      = (∑ j, g j) * (m : ℝ) ^ (m - 1) := by
    rw [← Finset.mul_prod_erase _ _ (Finset.mem_univ k), if_pos rfl]
    congr 1
    rw [Finset.prod_congr rfl (fun i hi => if_neg (Finset.ne_of_mem_erase hi)),
      Finset.prod_const, Finset.card_erase_of_mem (Finset.mem_univ k), Finset.card_univ,
      Fintype.card_fin]
  calc ∑ s : Fin m → Fin m, g (s k)
      = ∑ s : Fin m → Fin m, ∏ i, (if i = k then g (s i) else (1 : ℝ)) := by
        exact (Finset.sum_congr rfl fun s _ => (hl s).symm)
    _ = ∏ i : Fin m, ∑ j, (if i = k then g j else (1 : ℝ)) := h
    _ = ∏ i : Fin m, (if i = k then (∑ j, g j) else (m : ℝ)) :=
        Finset.prod_congr rfl fun i _ => hr i
    _ = (∑ j, g j) * (m : ℝ) ^ (m - 1) := hprod
    _ = (m : ℝ) ^ (m - 1) * ∑ i, g i := by ring

/-- Marginalising all coordinates but two distinct ones. -/
theorem sum_resample_eval_pair (g h : Fin m → ℝ) {k l : Fin m} (hkl : k ≠ l) :
    ∑ s : Fin m → Fin m, g (s k) * h (s l)
      = (m : ℝ) ^ (m - 2) * ((∑ i, g i) * (∑ i, h i)) := by
  classical
  have hmain := sum_resample_prod (m := m)
    (fun i j => if i = k then g j else if i = l then h j else 1)
  have hlk : l ∈ (univ : Finset (Fin m)).erase k := by
    simp [Finset.mem_erase, Ne.symm hkl]
  have hl : ∀ s : Fin m → Fin m,
      (∏ i, if i = k then g (s i) else if i = l then h (s i) else (1 : ℝ))
        = g (s k) * h (s l) := by
    intro s
    rw [← Finset.mul_prod_erase _ _ (Finset.mem_univ k), if_pos rfl]
    congr 1
    rw [Finset.prod_congr rfl
      (fun i hi => if_neg (Finset.ne_of_mem_erase hi) :
        ∀ i ∈ (univ : Finset (Fin m)).erase k,
          (if i = k then g (s i) else if i = l then h (s i) else (1 : ℝ))
            = (if i = l then h (s i) else (1 : ℝ)))]
    simp [hlk]
  have hr : ∀ i : Fin m,
      (∑ j, if i = k then g j else if i = l then h j else (1 : ℝ))
        = if i = k then (∑ j, g j) else if i = l then (∑ j, h j) else (m : ℝ) := by
    intro i
    by_cases hik : i = k
    · simp [hik]
    · by_cases hil : i = l
      · simp [hil]
      · simp [hik, hil]
  have hprod : (∏ i : Fin m,
        if i = k then (∑ j, g j) else if i = l then (∑ j, h j) else (m : ℝ))
      = (∑ j, g j) * ((∑ j, h j) * (m : ℝ) ^ (m - 2)) := by
    rw [← Finset.mul_prod_erase _ _ (Finset.mem_univ k), if_pos rfl]
    congr 1
    rw [Finset.prod_congr rfl
      (fun i hi => if_neg (Finset.ne_of_mem_erase hi) :
        ∀ i ∈ (univ : Finset (Fin m)).erase k,
          (if i = k then (∑ j, g j) else if i = l then (∑ j, h j) else (m : ℝ))
            = (if i = l then (∑ j, h j) else (m : ℝ)))]
    rw [← Finset.mul_prod_erase _ _ hlk, if_pos rfl]
    congr 1
    rw [Finset.prod_congr rfl (fun i hi => if_neg (Finset.ne_of_mem_erase hi)),
      Finset.prod_const, Finset.card_erase_of_mem hlk,
      Finset.card_erase_of_mem (Finset.mem_univ k), Finset.card_univ, Fintype.card_fin]
    congr 1
  calc ∑ s : Fin m → Fin m, g (s k) * h (s l)
      = ∑ s : Fin m → Fin m,
          ∏ i, (if i = k then g (s i) else if i = l then h (s i) else (1 : ℝ)) :=
        (Finset.sum_congr rfl fun s _ => (hl s).symm)
    _ = ∏ i : Fin m, ∑ j, (if i = k then g j else if i = l then h j else (1 : ℝ)) := hmain
    _ = ∏ i : Fin m,
          (if i = k then (∑ j, g j) else if i = l then (∑ j, h j) else (m : ℝ)) :=
        Finset.prod_congr rfl fun i _ => hr i
    _ = (∑ j, g j) * ((∑ j, h j) * (m : ℝ) ^ (m - 2)) := hprod
    _ = (m : ℝ) ^ (m - 2) * ((∑ i, g i) * (∑ i, h i)) := by ring

/-! ## The bootstrap variance law -/

/-- The mean of the resample indexed by `s`. -/
noncomputable def bootMean (c : Fin m → ℝ) (s : Fin m → Fin m) : ℝ :=
  emean fun k => c (s k)

/-- The variance of the resample mean over the whole resample space of `m ^ m` maps,
centred at the population mean (which is the bootstrap expectation of the resample mean). -/
noncomputable def bootVar (c : Fin m → ℝ) : ℝ :=
  (∑ s : Fin m → Fin m, (bootMean c s - emean c) ^ 2) / (m : ℝ) ^ m

/-- Recentring a resample mean. -/
theorem bootMean_sub (hm : 0 < m) (c : Fin m → ℝ) (s : Fin m → Fin m) :
    bootMean c s - emean c = (∑ k, (c (s k) - emean c)) / m := by
  have hmR : ((m : ℝ)) ≠ 0 := by
    have : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    exact ne_of_gt this
  rw [bootMean, emean, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- **The exact bootstrap variance law.**  Over the full resample space the variance of
the resample mean is exactly `evar c / m`: the `1 / m` is an identity, not a limit. -/
theorem bootVar_eq (hm : 0 < m) (c : Fin m → ℝ) : bootVar c = evar c / m := by
  classical
  set d : Fin m → ℝ := fun i => c i - emean c with hd
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hd0 : ∑ i, d i = 0 := sum_sub_emean_eq_zero hm c
  -- expand the square of the resample sum
  have hsq : ∀ s : Fin m → Fin m,
      (∑ k, d (s k)) ^ 2 = ∑ k, ∑ l, d (s k) * d (s l) := by
    intro s
    rw [sq, Finset.sum_mul_sum]
  have hoff : ∀ k l : Fin m, k ≠ l → ∑ s : Fin m → Fin m, d (s k) * d (s l) = 0 := by
    intro k l hkl
    rw [sum_resample_eval_pair d d hkl, hd0]
    ring
  have hdiag : ∀ k : Fin m, ∑ s : Fin m → Fin m, d (s k) * d (s k)
      = (m : ℝ) ^ (m - 1) * ∑ i, d i ^ 2 := by
    intro k
    have := sum_resample_eval (fun i => d i * d i) k
    simpa [sq] using this
  have hmm : (m : ℝ) ^ (m - 1) * (m : ℝ) = (m : ℝ) ^ m := by
    rw [← pow_succ]
    congr 1
    omega
  have hkey : ∑ s : Fin m → Fin m, (∑ k, d (s k)) ^ 2
      = (m : ℝ) ^ m * ∑ i, d i ^ 2 := by
    calc ∑ s : Fin m → Fin m, (∑ k, d (s k)) ^ 2
        = ∑ s : Fin m → Fin m, ∑ k, ∑ l, d (s k) * d (s l) :=
          Finset.sum_congr rfl fun s _ => hsq s
      _ = ∑ k, ∑ l, ∑ s : Fin m → Fin m, d (s k) * d (s l) := by
          rw [Finset.sum_comm]
          exact Finset.sum_congr rfl fun k _ => Finset.sum_comm
      _ = ∑ k : Fin m, ∑ s : Fin m → Fin m, d (s k) * d (s k) := by
          refine Finset.sum_congr rfl fun k _ => ?_
          refine Finset.sum_eq_single k (fun l _ hlk => hoff k l (Ne.symm hlk)) ?_
          intro hk
          exact absurd (Finset.mem_univ k) hk
      _ = ∑ _k : Fin m, (m : ℝ) ^ (m - 1) * ∑ i, d i ^ 2 :=
          Finset.sum_congr rfl fun k _ => hdiag k
      _ = (m : ℝ) ^ m * ∑ i, d i ^ 2 := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
            ← mul_assoc, mul_comm ((m : ℝ)) ((m : ℝ) ^ (m - 1)), hmm]
  have hmpow : ((m : ℝ) ^ m) ≠ 0 := pow_ne_zero _ (ne_of_gt hmR)
  have hterm : ∀ s : Fin m → Fin m,
      (bootMean c s - emean c) ^ 2 = (∑ k, d (s k)) ^ 2 / (m : ℝ) ^ 2 := by
    intro s
    rw [bootMean_sub hm c s, div_pow]
  rw [bootVar, Finset.sum_congr rfl fun s _ => hterm s, ← Finset.sum_div, hkey, evar]
  field_simp
  ring

/-! ## Consequences for the design -/

/-- **Applied to the realised two-level design**: the cluster bootstrap variance is exactly
the between-cluster variance divided by the number of clusters.  The within-cluster
dispersion — hence the pair count `n` — does not appear. -/
theorem cluster_bootVar_eq {n : ℕ} (hm : 0 < m) (x : Fin m → Fin n → ℝ) :
    bootVar (clusterMean x) = betweenVar x / m :=
  bootVar_eq hm (clusterMean x)

/-- Combined with the ANOVA decomposition: the bootstrap variance is at most the total
dispersion over the cluster count, with equality exactly when the design has no
within-cluster dispersion. -/
theorem bootVar_le_totalVar_div {n : ℕ} (hm : 0 < m) (hn : 0 < n) (x : Fin m → Fin n → ℝ) :
    bootVar (clusterMean x) ≤ totalVar x / m := by
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [cluster_bootVar_eq hm x]
  exact div_le_div_of_nonneg_right (between_le_total hm hn x) hmR.le

/-- **The design rule.**  A target bootstrap standard error `t` is met if and only if the
cluster count satisfies `m t² ≥ evar c`; the pair count is irrelevant to this inequality.
Consequently reducing the standard error by a factor `r` costs a factor `r²` in clusters. -/
theorem clusters_needed_iff (hm : 0 < m) (c : Fin m → ℝ) (t : ℝ) :
    bootVar c ≤ t ^ 2 ↔ evar c ≤ (m : ℝ) * t ^ 2 := by
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [bootVar_eq hm c, div_le_iff₀ hmR, mul_comm]

/-- Non-degeneracy: the bootstrap spread is zero only for a constant cluster population,
so two differing moduli already force a strictly positive interval width. -/
theorem bootVar_pos_of_ne (hm : 0 < m) {c : Fin m → ℝ} {a b : Fin m} (hab : c a ≠ c b) :
    0 < bootVar c := by
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [bootVar_eq hm c, evar]
  refine div_pos (div_pos ?_ hmR) hmR
  have hnonneg : ∀ i ∈ (univ : Finset (Fin m)), 0 ≤ (c i - emean c) ^ 2 :=
    fun i _ => sq_nonneg _
  rcases lt_or_eq_of_le (Finset.sum_nonneg hnonneg) with h | h
  · exact h
  · exfalso
    have hzero := (Finset.sum_eq_zero_iff_of_nonneg hnonneg).mp h.symm
    have ha : c a - emean c = 0 := by
      have := hzero a (Finset.mem_univ a)
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    have hb : c b - emean c = 0 := by
      have := hzero b (Finset.mem_univ b)
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    exact hab (by linarith)

/-- The bootstrap variance of a constant population is zero: the converse of
`bootVar_pos_of_ne`, showing the criterion is sharp. -/
theorem bootVar_eq_zero_of_const (hm : 0 < m) (c : Fin m → ℝ) (v : ℝ) (hc : ∀ i, c i = v) :
    bootVar c = 0 := by
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hmean : emean c = v := by
    rw [emean, Finset.sum_congr rfl fun i _ => hc i, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
  rw [bootVar_eq hm c, evar, Finset.sum_congr rfl fun i _ => by
    rw [hc i, hmean, sub_self]]
  simp

end U9Drift