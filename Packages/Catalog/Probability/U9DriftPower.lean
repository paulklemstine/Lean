/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Probability.U9DriftIntervals

/-!
# Power arithmetic for the band-9 replication: how many clusters, and what a
  direction-stable split-half is worth

Context (experiment 569, paper 216).  Two quantitative claims of the round-74 ledger are
audited here.

**(1) "Decisive resolution still needs the 10–30× power run."**  A cluster bootstrap over
`m` independent `N`-clusters has half width `c/√m` for a calibration constant `c` fixed by
the per-cluster dispersion; the realised run had `m = 128` clusters and half width
`0.04555`, which calibrates `c = 0.04555·√128`.  To make the interval exclude `1` at the
replication's own point estimate `0.99`, the half width must drop below `0.01`.

* `U9Drift.ten_times_the_clusters_is_not_enough` — `10×` the clusters (`m ≤ 1280`) provably
  cannot get there;
* `U9Drift.thirty_times_the_clusters_suffices` — `30×` the clusters (`m ≥ 3840`) provably
  does.

So the ledger's "10–30×" ask is exactly right, and the interval `[10×, 30×]` is the
narrowest decade-scale bracket consistent with the `√m` law (the exact threshold is
`m ≥ 2656`, `U9Drift.exact_cluster_threshold`).

**(2) "Every CI covers 1 but every split-half points the same way."**  Under the null the
sign of each split-half is a fair coin, so `k` split-halves agreeing has probability
`2^{1-k}`:

* `U9Drift.card_allSame` / `U9Drift.direction_stability_pvalue` — exactly `2` of the `2^k`
  sign patterns are constant;
* `U9Drift.four_split_halves_are_not_significant` — with `k = 4` the null probability is
  `1/8`, well above `0.05`: direction stability at that depth is *not* evidence;
* `U9Drift.split_halves_needed_for_significance` — one needs `k ≥ 6` agreeing split-halves
  before the sign test even reaches the `5%` level.

Finally `U9Drift.pilot_effect_size_would_have_been_resolved` records the diagnostic
consequence: the replication's precision `0.04555` was already fine enough that a true
ratio at the pilot's point estimate `0.947` would have produced an interval excluding `1`.
-/

namespace U9Drift

open Real Finset

/-! ## The `√m` cluster-bootstrap scaling law -/

/-- Half width of a cluster-bootstrap interval over `m` clusters, with calibration
constant `c` (the per-cluster dispersion times the coverage factor). -/
noncomputable def clusterHalfWidth (c : ℝ) (m : ℕ) : ℝ := c / Real.sqrt m

theorem clusterHalfWidth_pos {c : ℝ} {m : ℕ} (hc : 0 < c) (hm : 0 < m) :
    0 < clusterHalfWidth c m :=
  div_pos hc (Real.sqrt_pos.mpr (by exact_mod_cast hm))

/-- The precision criterion in closed form: `c/√m < δ` iff `m > (c/δ)²`. -/
theorem clusterHalfWidth_lt_iff {c δ : ℝ} {m : ℕ} (hc : 0 < c) (hm : 0 < m) (hδ : 0 < δ) :
    clusterHalfWidth c m < δ ↔ c ^ 2 < δ ^ 2 * m := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hs : 0 < Real.sqrt m := Real.sqrt_pos.mpr hmR
  rw [clusterHalfWidth, div_lt_iff₀ hs]
  constructor
  · intro h
    have h2 : c ^ 2 < (δ * Real.sqrt m) ^ 2 := by nlinarith
    rwa [mul_pow, Real.sq_sqrt hmR.le] at h2
  · intro h
    refine lt_of_sq_lt_sq_nonneg hc.le (by positivity) ?_
    rwa [mul_pow, Real.sq_sqrt hmR.le]

/-- Quadratic cost of precision: quartering the cluster count doubles the half width. -/
theorem clusterHalfWidth_four_mul {c : ℝ} (m : ℕ) :
    clusterHalfWidth c (4 * m) = clusterHalfWidth c m / 2 := by
  have h4 : ((4 * m : ℕ) : ℝ) = 4 * (m : ℝ) := by push_cast; ring
  rw [clusterHalfWidth, clusterHalfWidth, h4,
    show (4 : ℝ) * (m : ℝ) = 2 ^ 2 * (m : ℝ) by ring,
    Real.sqrt_mul (by positivity) (m : ℝ), Real.sqrt_sq (by norm_num)]
  rw [div_div]
  ring_nf

/-- More clusters never hurt. -/
theorem clusterHalfWidth_antitone {c : ℝ} (hc : 0 ≤ c) {m n : ℕ} (hm : 0 < m) (hmn : m ≤ n) :
    clusterHalfWidth c n ≤ clusterHalfWidth c m := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  have h1 : Real.sqrt m ≤ Real.sqrt n :=
    Real.sqrt_le_sqrt (by exact_mod_cast hmn)
  exact div_le_div_of_nonneg_left hc (Real.sqrt_pos.mpr hmR) h1

/-! ## Calibration from the realised run -/

/-- The calibration constant implied by the realised run: `128` clusters delivered half
width `0.04555`. -/
noncomputable def cCal : ℝ := 0.04555 * Real.sqrt 128

theorem cCal_pos : 0 < cCal := by
  have : (0:ℝ) < Real.sqrt 128 := Real.sqrt_pos.mpr (by norm_num)
  unfold cCal; positivity

theorem cCal_sq : cCal ^ 2 = 0.04555 ^ 2 * 128 := by
  rw [cCal, mul_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 128)]

/-- The calibration reproduces the realised half width at `m = 128`. -/
theorem clusterHalfWidth_cCal_128 : clusterHalfWidth cCal 128 = rep1e6.halfWidth := by
  have hs : Real.sqrt ((128 : ℕ) : ℝ) ≠ 0 := by
    have : (0:ℝ) < Real.sqrt ((128 : ℕ) : ℝ) := Real.sqrt_pos.mpr (by norm_num)
    exact ne_of_gt this
  have : rep1e6.halfWidth = 0.04555 := by show ((1.0101 : ℝ) - 0.919) / 2 = _; norm_num
  rw [this, clusterHalfWidth, cCal]
  push_cast
  field_simp

/-- **`10×` the clusters is provably not enough** to make the interval exclude `1` at the
replication's own point estimate (`half width < 0.01` required). -/
theorem ten_times_the_clusters_is_not_enough {m : ℕ} (hm : 0 < m) (hle : m ≤ 1280) :
    ¬ clusterHalfWidth cCal m < 0.01 := by
  rw [clusterHalfWidth_lt_iff cCal_pos hm (by norm_num), cCal_sq]
  push_neg
  have : (m : ℝ) ≤ 1280 := by exact_mod_cast hle
  nlinarith

/-- **`30×` the clusters provably suffices.** -/
theorem thirty_times_the_clusters_suffices {m : ℕ} (hm : 3840 ≤ m) :
    clusterHalfWidth cCal m < 0.01 := by
  have hm0 : 0 < m := lt_of_lt_of_le (by norm_num) hm
  rw [clusterHalfWidth_lt_iff cCal_pos hm0 (by norm_num), cCal_sq]
  have : (3840 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  nlinarith

/-- The exact threshold: `2656` clusters (`20.75×` the realised `128`) is the least cluster
count that resolves a `1%` deviation. -/
theorem exact_cluster_threshold :
    clusterHalfWidth cCal 2656 < 0.01 ∧ ¬ clusterHalfWidth cCal 2655 < 0.01 := by
  constructor
  · rw [clusterHalfWidth_lt_iff cCal_pos (by norm_num) (by norm_num), cCal_sq]
    norm_num
  · rw [clusterHalfWidth_lt_iff cCal_pos (by norm_num) (by norm_num), cCal_sq]
    push_neg
    norm_num

/-- Diagnostic consequence of the realised precision: had the true ratio been at the
pilot's point estimate `0.947`, the replication interval would have excluded `1`.  (The
interval is the realised half width `0.04555` placed at the hypothesised centre.) -/
theorem pilot_effect_size_would_have_been_resolved {c₀ : ℝ} (h : c₀ ≤ 0.947) :
    c₀ + rep1e6.halfWidth < 1 := by
  have : rep1e6.halfWidth = 0.04555 := by show ((1.0101 : ℝ) - 0.919) / 2 = _; norm_num
  rw [this]; linarith

/-! ## What a direction-stable split-half is worth -/

/-- The sign patterns of `k` split-halves that all point the same way. -/
def allSame (k : ℕ) : Finset (Fin k → Bool) :=
  Finset.univ.filter (fun f => ∀ i j, f i = f j)

/-- Exactly two of the `2^k` sign patterns are constant. -/
theorem card_allSame {k : ℕ} (hk : 0 < k) : (allSame k).card = 2 := by
  have hset : allSame k = {fun _ => false, fun _ => true} := by
    ext f
    simp only [allSame, mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    constructor
    · intro h
      rcases Bool.eq_false_or_eq_true (f ⟨0, hk⟩) with hb | hb
      · right; funext i; rw [h i ⟨0, hk⟩, hb]
      · left; funext i; rw [h i ⟨0, hk⟩, hb]
    · rintro (rfl | rfl) <;> intro i j <;> rfl
  have hne : (fun _ => false : Fin k → Bool) ≠ (fun _ => true) := by
    intro h
    have := congrFun h ⟨0, hk⟩
    simp at this
  rw [hset, card_insert_of_notMem (by simpa using hne), card_singleton]

theorem card_univ_patterns (k : ℕ) :
    (Finset.univ : Finset (Fin k → Bool)).card = 2 ^ k := by
  simp

/-- **The direction-stability p-value.**  Under the null (each split-half sign a fair
coin), `k` split-halves agreeing has probability `2/2^k = 2^{1-k}`. -/
theorem direction_stability_pvalue {k : ℕ} (hk : 0 < k) :
    ((allSame k).card : ℚ) / (Finset.univ : Finset (Fin k → Bool)).card = 2 / 2 ^ k := by
  rw [card_allSame hk, card_univ_patterns]
  push_cast
  ring

/-- With four agreeing split-halves the null probability is `1/8`: direction stability at
that depth is not significant at the `5%` level. -/
theorem four_split_halves_are_not_significant :
    ((allSame 4).card : ℚ) / (Finset.univ : Finset (Fin 4 → Bool)).card = 1 / 8 ∧
      (1 : ℚ) / 20 < 1 / 8 := by
  refine ⟨?_, by norm_num⟩
  rw [direction_stability_pvalue (by norm_num)]
  norm_num

/-- One needs at least six agreeing split-halves before the sign test reaches the `5%`
level. -/
theorem split_halves_needed_for_significance (k : ℕ) :
    (2 : ℚ) / 2 ^ k ≤ 1 / 20 ↔ 6 ≤ k := by
  constructor
  · intro h
    by_contra hk
    push_neg at hk
    interval_cases k <;> norm_num at h
  · intro hk
    have h64 : (64 : ℚ) ≤ 2 ^ k := by
      calc (64 : ℚ) = 2 ^ 6 := by norm_num
        _ ≤ 2 ^ k := by
            apply pow_le_pow_right₀ (by norm_num) hk
    have hpos : (0:ℚ) < 2 ^ k := by positivity
    rw [div_le_div_iff₀ hpos (by norm_num)]
    linarith

end U9Drift