/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Novelty.AscentCostLaw

/-!
# The ascent exponent law: `rate(α) = min(3, 1/α)`, with a kink at `α = 1/3`

Cycle 1 (`Novelty.AscentCostLaw`) priced the two schedules exactly.  This second cycle extracts
the *exponent* of the optimal schedule and shows the phase structure of the branch-oracle
economy.

Main results.

* `ascent_exponent_law` : the per-depth logarithmic cost of the best of the two schedules
  converges to `log (min 3 (1/α))`.  Since the cheaper schedule is the one with the smaller
  base, the exponential rate of an ascent guided by an accuracy-`α` ternary branch oracle is
  exactly `min(3, 1/α)`.
* `ascent_rate_eq_three_of_le_third` / `ascent_rate_lt_three_of_gt_third` : the kink.  Below
  `α = 1/3` accuracy buys *nothing* at the level of the exponent (the rate is pinned at `3`,
  the effective-branching refutation of cycle 1 in its sharpest form); above `1/3` the rate is
  `1/α`, strictly decreasing.
* `breakeven_iff` : the breakeven accuracy of cycle 1 is not merely sufficient — it is an exact
  threshold, `win ↔ α > ((1+c)h/F) ^ (1/h)`, with `criticalAccuracy_strictMono_cost` showing
  that a costlier per-step feature strictly raises the accuracy the oracle must reach.
* `sequential_beats_class_hint` : a one-shot class hint keeping a fraction `θ ≥ 1/3` of a
  ternary tree is capped at speedup `1/θ ≤ 3`, while sequential branch hints pass any cap.
* `dfsCost_strictAnti` : within a schedule, accuracy is always worth something (strict monotone
  price), even though — by the exponent law — it is worth nothing to the exponent below `1/3`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 2): the two exact laws of cycle 1 are two branches of one
exponent law with a nonsmooth crossover, and the crossover is at the reciprocal of the branching
factor.

Experiment (Experimenter): `log E / h` evaluated on the closed laws (see
`ComputationalEvidence.md`).  At `α = 0.5`: restart gives `log(10 · 2^10)/10 = 0.92341` at
`h = 10` and `0.78537` at `h = 40`, descending towards `log 2 = 0.69315`, while DFS gives
`1.04109` at `h = 10` and `1.08423` at `h = 40`, ascending towards `log 3 = 1.09861` — the min
tracks `log(1/α) = log 2 < log 3`.  At `α = 0.25 < 1/3` the same computation gives restart rate
`1.61655` at `h = 10` (towards `log 4 = 1.38629`) and DFS rate `1.09704` (towards `log 3`); the
min is `log 3`, i.e. pinned at the branching factor.  The crossover is at `α = 1/3` exactly,
where the two rates coincide at `log 3`.

Analysis (Analyst): the kink is a genuine non-analyticity in `α` of the optimal exponent, and it
sits exactly at the reciprocal branching factor `1/b` with `b = 3`.  Nothing in the argument uses
`b = 3`, so the same statement should hold verbatim with `min (b) (1/α)`; that generalisation is
recorded in `FUTURE_DIRECTIONS.md`.

Critique (Critic): the exponent law needs both costs positive, hence `h ≥ 1` eventually filters
and `0 < α < 1`.  At `α = 1` the restart law is polynomial and its `log`-rate is `0`, consistent
with `min 3 1 = 1` only in the degenerate reading `log 1 = 0`; the theorem is therefore stated
for `α < 1` and the `α = 1` case is covered separately by `restartCost_one` of cycle 1.
-/

namespace AscentCostLaw

open Filter Topology

/-! ### Logarithmic rates -/

/-- `log h / h → 0` along the naturals. -/
theorem tendsto_log_natCast_div_atTop :
    Tendsto (fun h : ℕ => Real.log h / h) atTop (𝓝 0) := by
  have h1 : Tendsto (fun x : ℝ => Real.log x / x) atTop (𝓝 0) :=
    Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  exact h1.comp tendsto_natCast_atTop_atTop

/-- The restart schedule has exponential rate exactly `1/α`. -/
theorem restart_log_rate {α : ℝ} (h0 : 0 < α) :
    Tendsto (fun h : ℕ => Real.log (restartCost α h) / h) atTop (𝓝 (Real.log (1 / α))) := by
  have hlim : Tendsto (fun h : ℕ => Real.log h / h + Real.log (1 / α)) atTop
      (𝓝 (Real.log (1 / α))) := by
    simpa using tendsto_log_natCast_div_atTop.add_const (Real.log (1 / α))
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hαh : (0 : ℝ) < α ^ h := pow_pos h0 h
  unfold restartCost
  rw [Real.log_div (ne_of_gt hh0) (ne_of_gt hαh), Real.log_pow,
    Real.log_div one_ne_zero (ne_of_gt h0), Real.log_one]
  field_simp
  ring

/-- The DFS schedule has exponential rate exactly `3`, for every accuracy `α < 1`. -/
theorem dfs_log_rate {α : ℝ} (h0 : 0 ≤ α) (h1 : α < 1) :
    Tendsto (fun h : ℕ => Real.log (dfsCost α h) / h) atTop (𝓝 (Real.log 3)) := by
  have hK : 0 < failWeight α := failWeight_pos h1
  have hL : (0 : ℝ) < 3 * failWeight α / 4 := by positivity
  have hg : Tendsto (fun h : ℕ => dfsCost α h / (3 : ℝ) ^ h) atTop
      (𝓝 (3 * failWeight α / 4)) := dfsCost_div_pow_tendsto α
  have hlog : Tendsto (fun h : ℕ => Real.log (dfsCost α h / (3 : ℝ) ^ h)) atTop
      (𝓝 (Real.log (3 * failWeight α / 4))) :=
    (Real.continuousAt_log (ne_of_gt hL)).tendsto.comp hg
  have hquot : Tendsto (fun h : ℕ => Real.log (dfsCost α h / (3 : ℝ) ^ h) / h) atTop (𝓝 0) :=
    hlog.div_atTop tendsto_natCast_atTop_atTop
  have hlim : Tendsto (fun h : ℕ => Real.log 3 + Real.log (dfsCost α h / (3 : ℝ) ^ h) / h)
      atTop (𝓝 (Real.log 3)) := by
    simpa using hquot.const_add (Real.log 3)
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have h3 : (0 : ℝ) < (3 : ℝ) ^ h := by positivity
  have hd : 0 < dfsCost α h := lt_of_lt_of_le (by positivity) (dfsCost_ge h0 h1.le hh)
  have hsplit : dfsCost α h = (3 : ℝ) ^ h * (dfsCost α h / (3 : ℝ) ^ h) := by
    field_simp
  rw [hsplit, Real.log_mul (ne_of_gt h3) (ne_of_gt (div_pos hd h3)), Real.log_pow, ← hsplit]
  field_simp

/-! ### The optimal schedule and its exponent -/

/-- The cost of the better of the two exact schedules. -/
noncomputable def minCost (α : ℝ) (h : ℕ) : ℝ := min (dfsCost α h) (restartCost α h)

theorem log_min_eq {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    Real.log (min a b) = min (Real.log a) (Real.log b) := by
  rcases le_total a b with hab | hab
  · rw [min_eq_left hab, min_eq_left (Real.log_le_log ha hab)]
  · rw [min_eq_right hab, min_eq_right (Real.log_le_log hb hab)]

/-- **Ascent exponent law.**  The optimal of the two schedules has exponential rate exactly
`min (3, 1/α)`: the branching base `3` for a weak oracle, the inverse accuracy `1/α` for a strong
one, with the crossover at `α = 1/3`. -/
theorem ascent_exponent_law {α : ℝ} (h0 : 0 < α) (h1 : α < 1) :
    Tendsto (fun h : ℕ => Real.log (minCost α h) / h) atTop
      (𝓝 (Real.log (min 3 (1 / α)))) := by
  have hlim := (dfs_log_rate h0.le h1).min (restart_log_rate h0)
  rw [← log_min_eq (by norm_num) (by positivity)] at hlim
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hK : 0 < failWeight α := failWeight_pos h1
  have hd : 0 < dfsCost α h := lt_of_lt_of_le (by positivity) (dfsCost_ge h0.le h1.le hh)
  have hr : 0 < restartCost α h := restartCost_pos h0 hh
  unfold minCost
  rw [log_min_eq hd hr, min_div_div_right hh0.le]

/-- **Kink, weak side.**  For `α ≤ 1/3` the optimal exponent is pinned at the branching factor
`3`: oracle accuracy is worth nothing at the level of the rate. -/
theorem ascent_rate_eq_three_of_le_third {α : ℝ} (h0 : 0 < α) (hle : α ≤ 1/3) :
    min 3 (1 / α) = 3 := by
  have : (3 : ℝ) ≤ 1 / α := by
    rw [le_div_iff₀ h0]; linarith
  exact min_eq_left this

/-- **Kink, strong side.**  For `α > 1/3` the optimal exponent is `1/α`, strictly below the
branching factor: accuracy converts into a genuinely smaller base. -/
theorem ascent_rate_lt_three_of_gt_third {α : ℝ} (hgt : 1/3 < α) (h1 : α < 1) :
    min 3 (1 / α) = 1 / α ∧ 1 / α < 3 := by
  have h0 : 0 < α := by linarith
  have hlt : 1 / α < 3 := by
    rw [div_lt_iff₀ h0]; linarith
  exact ⟨min_eq_right hlt.le, hlt⟩

/-- The rate is strictly decreasing in accuracy above the kink. -/
theorem ascent_rate_strictAnti_above_third {α β : ℝ} (h0 : 1/3 < α) (hab : α < β) (hb : β < 1) :
    min 3 (1 / β) < min 3 (1 / α) := by
  have hα0 : 0 < α := by linarith
  have hβ0 : 0 < β := by linarith
  have h1 : 1 / β < 1 / α := one_div_lt_one_div_of_lt hα0 hab
  rw [(ascent_rate_lt_three_of_gt_third h0 (by linarith)).1,
    (ascent_rate_lt_three_of_gt_third (by linarith) hb).1]
  exact h1

/-! ### Accuracy always has a price, even where it has no exponent -/

/-- `1 + k ≤ 3 ^ k`, the strict form of the level-sweep bound. -/
theorem one_add_le_three_pow (k : ℕ) : (1 : ℝ) + (k : ℝ) ≤ 3 ^ k := by
  induction k with
  | zero => norm_num
  | succ n ih =>
      have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      have hexp : (3 : ℝ) ^ (n + 1) = 3 ^ n * 3 := by ring
      rw [hexp]
      push_cast
      linarith

/-- Within the DFS schedule, higher accuracy is always strictly cheaper (for `h ≥ 1`). -/
theorem dfsCost_strictAnti {α β : ℝ} (hab : α < β) (hb : β ≤ 1) {h : ℕ}
    (hh : 1 ≤ h) : dfsCost β h < dfsCost α h := by
  have hKlt : failWeight β < failWeight α := by
    unfold failWeight; nlinarith
  have hhr : (1 : ℝ) ≤ (h : ℝ) := by exact_mod_cast hh
  have hstrict : 2 * (h : ℝ) + 3 < (3 : ℝ) ^ (h + 1) := by
    have hhelp : (1 : ℝ) + (h : ℝ) ≤ 3 ^ h := one_add_le_three_pow h
    rw [pow_succ]
    nlinarith
  unfold dfsCost
  nlinarith [mul_pos (sub_pos.mpr hKlt)
    (by linarith : (0:ℝ) < (3:ℝ) ^ (h + 1) - 3 - 2 * (h : ℝ))]

/-! ### Breakeven is an exact threshold -/

/-- The critical accuracy `α* = ((1+c) h / F) ^ (1/h)`. -/
noncomputable def criticalAccuracy (c F : ℝ) (h : ℕ) : ℝ := ((1 + c) * h / F) ^ ((h : ℝ)⁻¹)

theorem criticalAccuracy_pow {c F : ℝ} {h : ℕ} (hh : 1 ≤ h) (ht : 0 ≤ (1 + c) * h / F) :
    (criticalAccuracy c F h) ^ h = (1 + c) * h / F := by
  have hh0 : ((h : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  unfold criticalAccuracy
  rw [← Real.rpow_natCast (((1 + c) * h / F) ^ ((h : ℝ)⁻¹)) h, ← Real.rpow_mul ht,
    inv_mul_cancel₀ hh0, Real.rpow_one]

/-- **Breakeven is an exact threshold.**  With per-step overhead `c` and exact-solver budget
`F > 0`, the guided ascent wins if and only if the oracle accuracy exceeds the explicit critical
accuracy. -/
theorem breakeven_iff {c F : ℝ} (hc : 0 ≤ c) {h : ℕ} (hh : 1 ≤ h) (hF : 0 < F) {α : ℝ}
    (hα : 0 < α) :
    (1 + c) * restartCost α h < F ↔ criticalAccuracy c F h < α := by
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hαh : (0 : ℝ) < α ^ h := pow_pos hα h
  have hnum : (0 : ℝ) ≤ (1 + c) * h / F := by positivity
  have hcrit : (0 : ℝ) ≤ criticalAccuracy c F h := Real.rpow_nonneg hnum _
  have hkey : (1 + c) * restartCost α h < F ↔ (1 + c) * h / F < α ^ h := by
    unfold restartCost
    rw [mul_div_assoc', div_lt_iff₀ hαh, div_lt_iff₀ hF]
    constructor
    · intro hlt; nlinarith
    · intro hlt; nlinarith
  rw [hkey, ← criticalAccuracy_pow hh hnum,
    pow_lt_pow_iff_left₀ hcrit hα.le (by omega)]

/-- A costlier per-step feature strictly raises the accuracy the oracle must reach. -/
theorem criticalAccuracy_strictMono_cost {c c' F : ℝ} (hc : 0 ≤ c) (hcc : c < c') (hF : 0 < F)
    {h : ℕ} (hh : 1 ≤ h) :
    criticalAccuracy c F h < criticalAccuracy c' F h := by
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hbase : (1 + c) * h / F < (1 + c') * h / F := by
    rw [div_lt_div_iff_of_pos_right hF]
    nlinarith
  exact Real.rpow_lt_rpow (by positivity) hbase (by positivity)

/-! ### Sequential hints leave the class-hint cap behind -/

/-- Speedup of a one-shot class hint that keeps a fraction `θ` of the search space. -/
noncomputable def classHintSpeedup (θ : ℝ) : ℝ := 1 / θ

/-- A class hint on a ternary branching keeps at least a third of the tree, so its speedup is
capped by `3` — the `1/θ` saturation of the master law. -/
theorem classHint_cap {θ : ℝ} (hθ0 : 0 < θ) (hθ : 1/3 ≤ θ) : classHintSpeedup θ ≤ 3 := by
  unfold classHintSpeedup
  rw [div_le_iff₀ hθ0]
  linarith

/-- **Sequential hints are a strictly stronger taxonomy class.**  However good a one-shot class
hint is, a sequential branch oracle with any accuracy above `1/3` overtakes it at some depth. -/
theorem sequential_beats_class_hint {α : ℝ} (hlow : 1/3 < α) (θ : ℝ) :
    ∃ h : ℕ, classHintSpeedup θ < hintSpeedup α h :=
  hintSpeedup_exceeds_cap hlow (classHintSpeedup θ)

end AscentCostLaw