/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Novelty.AscentCostExponent

/-!
# Universality: the ascent economy at branching factor `b`

Cycles 1–2 priced the ternary ascent and found a phase boundary at accuracy `α = 1/3`.  This
third cycle removes the `3`.  For an arbitrary branching factor `b ≥ 2` and an arbitrary level
waste weight `w ∈ (0, b-1]` the DFS ascent law is

`E_b(h) = h (1 - w/(b-1)) + w (b^(h+1) - b) / (b-1)^2`,

which for `b = 3`, `w = (1-α)(2-α)` is exactly the law of cycle 1 (`dfsCostB_specializes`).

Main results.

* `dfsCostB_eq_rec` : the closed law is the accumulated per-level cost
  `1 + w (b^j - 1)/(b-1)` (one visit, plus a wasted complete subtree of `(b^j-1)/(b-1)` nodes).
* `dfsB_growth_ratio_tendsto` : **effective branching is refuted at every branching factor** —
  the growth ratio is exactly `b`, for every waste weight `w > 0`.
* `restart_dominates_dfsB` / `dfsB_dominates_restart` : **the crossover is exactly at the
  reciprocal branching factor** `α = 1/b`.  Above it, restart-from-root wins by an unbounded
  factor; below it, DFS wins by an unbounded factor.  The `1/3` of cycle 1 was `1/b`.
* `ascent_exponent_law_general` : the optimal exponent is `min (b, 1/α)`, a nonsmooth function of
  accuracy with its kink at `α = 1/b`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 3): the `1/3` boundary is not about ternary trees; it is the
reciprocal of whatever branching factor the search graph has, and the waste weight only moves the
prefactor.  Bold form: no schedule mixing the two ever produces a base strictly between `1/α` and
`b`.

Experiment (Experimenter): with `b = 5`, `w = b - 1 = 4` (blind agent) the law gives
`E_5(6) = 4·(5^7 - 5)/16 = 19530`, exactly the number of internal nodes of a depth-6 5-ary tree,
and `E_5(7)/E_5(6) = 5.00026`; with `w = 0.2` the same ratio is `4.97801` — the base is `5`
either way, the prefactor differs by a factor of `20`.  Restart at `b = 5`: the crossover
accuracy is `0.2`; at `α = 0.15 < 1/5`, `E_restart(8) = 8/0.15^8 = 3.12·10^7` against
`E_5(8) = 1.22·10^5` at `w = 1`, so DFS wins, while at `α = 0.25 > 1/5`, `E_restart(8) =
5.24·10^5` and restart pulls ahead as `h` grows (the ratio falls like `(1/(5·0.25))^h`).

Analysis (Analyst): the argument only uses that the wasted subtree at level `j` has
`Θ(b^j)` nodes and that a restart attempt costs `h` with success probability `α^h`.  Hence the
exponent law `min(b, 1/α)` is a statement about *any* end-verification search with geometric
subtree growth; the ternary case of cycles 1–2 is one point of a one-parameter family.

Critique (Critic): the waste weight must satisfy `w ≤ b - 1` (a level cannot waste more than its
wrong siblings) — otherwise the linear term turns negative and the "cost" can dip below zero at
small `h`, which is not a search cost.  `b ≥ 2` is needed for `b^h ≥ 2` at `h ≥ 1`, used in the
lower bound; a "branching factor" below `2` is not a branching factor.
-/

namespace AscentCostLaw

open Filter Topology

/-! ### The general law -/

/-- Cost of level `j` for branching factor `b` and level waste weight `w`. -/
noncomputable def dfsLevelCostB (b w : ℝ) (j : ℕ) : ℝ := 1 + w * (b ^ j - 1) / (b - 1)

/-- Accumulated general DFS cost. -/
noncomputable def dfsCostBRec (b w : ℝ) : ℕ → ℝ
  | 0 => 0
  | h + 1 => dfsCostBRec b w h + dfsLevelCostB b w (h + 1)

/-- Closed form of the general DFS ascent law. -/
noncomputable def dfsCostB (b w : ℝ) (h : ℕ) : ℝ :=
  h * (1 - w / (b - 1)) + w * (b ^ (h + 1) - b) / (b - 1) ^ 2

/-- **Exact general DFS law.** -/
theorem dfsCostB_eq_rec {b : ℝ} (hb : 1 < b) (w : ℝ) (h : ℕ) :
    dfsCostBRec b w h = dfsCostB b w h := by
  have hb1 : b - 1 ≠ 0 := by linarith
  induction h with
  | zero => simp [dfsCostBRec, dfsCostB]
  | succ n ih =>
      rw [dfsCostBRec, ih]
      simp only [dfsCostB, dfsLevelCostB]
      push_cast
      field_simp
      ring

/-- The ternary law of cycle 1 is the case `b = 3`, `w = (1-α)(2-α)`. -/
theorem dfsCostB_specializes (α : ℝ) (h : ℕ) : dfsCostB 3 (failWeight α) h = dfsCost α h := by
  unfold dfsCostB dfsCost
  norm_num

/-! ### Asymptotics of the general law -/

theorem dfsCostB_div_pow_tendsto {b : ℝ} (hb : 1 < b) (w : ℝ) :
    Tendsto (fun h : ℕ => dfsCostB b w h / b ^ h) atTop (𝓝 (w * b / (b - 1) ^ 2)) := by
  have hb0 : 0 < b := by linarith
  have hb1 : b - 1 ≠ 0 := by linarith
  have hinv0 : (0 : ℝ) ≤ 1 / b := by positivity
  have hinv1 : 1 / b < 1 := by rw [div_lt_one hb0]; exact hb
  have key : ∀ h : ℕ, dfsCostB b w h / b ^ h
      = (1 - w / (b - 1)) * ((h : ℝ) * (1 / b) ^ h) + w * b / (b - 1) ^ 2
        - (w * b / (b - 1) ^ 2) * ((1 / b) ^ h) := by
    intro h
    have hbh : (b : ℝ) ^ h ≠ 0 := by positivity
    unfold dfsCostB
    rw [div_pow, one_pow, pow_succ]
    field_simp
    ring
  simp only [key]
  have t1 : Tendsto (fun h : ℕ => (h : ℝ) * (1 / b) ^ h) atTop (𝓝 0) :=
    tendsto_self_mul_const_pow_of_lt_one hinv0 hinv1
  have t2 : Tendsto (fun h : ℕ => ((1 / b : ℝ)) ^ h) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one hinv0 hinv1
  have := ((t1.const_mul (1 - w / (b - 1))).add_const (w * b / (b - 1) ^ 2)).sub
    (t2.const_mul (w * b / (b - 1) ^ 2))
  simpa using this

/-- **Effective branching refuted at every branching factor.**  Whatever the oracle waste weight,
the general DFS law grows with ratio exactly `b`. -/
theorem dfsB_growth_ratio_tendsto {b w : ℝ} (hb : 1 < b) (hw : 0 < w) :
    Tendsto (fun h : ℕ => dfsCostB b w (h + 1) / dfsCostB b w h) atTop (𝓝 b) := by
  have hb0 : 0 < b := by linarith
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hL : w * b / (b - 1) ^ 2 ≠ 0 :=
    (div_pos (mul_pos hw hb0) (pow_pos hb1 2)).ne'
  have hf : Tendsto (fun h : ℕ => dfsCostB b w h / b ^ h) atTop (𝓝 (w * b / (b - 1) ^ 2)) :=
    dfsCostB_div_pow_tendsto hb w
  have hf' := hf.comp (tendsto_add_atTop_nat 1)
  simp only [Function.comp_def] at hf'
  have hq := (hf'.div hf hL).const_mul b
  rw [div_self hL, mul_one] at hq
  simp only [Pi.div_apply] at hq
  refine hq.congr (fun h => ?_)
  by_cases hB : dfsCostB b w h = 0
  · simp [hB]
  · have hbh : (b : ℝ) ^ h ≠ 0 := by positivity
    field_simp
    ring

/-! ### Two-sided bounds -/

theorem dfsCostB_ge {b w : ℝ} (hb : 2 ≤ b) (hw : 0 < w) (hwb : w ≤ b - 1) {h : ℕ} (hh : 1 ≤ h) :
    w * b / (2 * (b - 1) ^ 2) * b ^ h ≤ dfsCostB b w h := by
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hcast : (0 : ℝ) ≤ (h : ℝ) := Nat.cast_nonneg h
  have hlin : 0 ≤ (h : ℝ) * (1 - w / (b - 1)) := by
    have : w / (b - 1) ≤ 1 := by rw [div_le_one hb1]; linarith
    nlinarith
  have hbh : (2 : ℝ) ≤ b ^ h := by
    calc (2 : ℝ) ≤ b := hb
      _ = b ^ 1 := (pow_one b).symm
      _ ≤ b ^ h := pow_le_pow_right₀ (by linarith) hh
  have hexp : (b : ℝ) ^ (h + 1) - b = b * (b ^ h - 1) := by rw [pow_succ]; ring
  have hkey : b ^ h / 2 ≤ b ^ h - 1 := by linarith
  have hb0 : (0 : ℝ) < b := by linarith
  have hfrac : w * b / (2 * (b - 1) ^ 2) * b ^ h ≤ w * (b ^ (h + 1) - b) / (b - 1) ^ 2 := by
    rw [hexp, div_mul_eq_mul_div,
      div_le_div_iff₀ (mul_pos (by norm_num) (pow_pos hb1 2)) (pow_pos hb1 2)]
    nlinarith [mul_nonneg (mul_pos (mul_pos hw hb0) (pow_pos hb1 2)).le
      (by linarith : (0:ℝ) ≤ b ^ h - 2)]
  unfold dfsCostB
  linarith

theorem dfsCostB_le {b w : ℝ} (hb : 2 ≤ b) (hw : 0 < w) (hwb : w ≤ b - 1) (h : ℕ) :
    dfsCostB b w h ≤ (h : ℝ) + b / (b - 1) * b ^ h := by
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hcast : (0 : ℝ) ≤ (h : ℝ) := Nat.cast_nonneg h
  have hbh : (0 : ℝ) < b ^ h := by positivity
  have hexp : (b : ℝ) ^ (h + 1) - b = b * (b ^ h - 1) := by rw [pow_succ]; ring
  have hlin : (h : ℝ) * (1 - w / (b - 1)) ≤ (h : ℝ) := by
    have : 0 ≤ w / (b - 1) := by positivity
    nlinarith
  have hb0 : (0 : ℝ) < b := by linarith
  have hmain : w * (b ^ (h + 1) - b) / (b - 1) ^ 2 ≤ b / (b - 1) * b ^ h := by
    rw [hexp, div_le_iff₀ (pow_pos hb1 2)]
    have hexpand : b / (b - 1) * b ^ h * (b - 1) ^ 2 = b * b ^ h * (b - 1) := by
      field_simp
    rw [hexpand]
    nlinarith [mul_nonneg hb0.le (mul_nonneg (sub_nonneg.mpr hwb) hbh.le), mul_pos hb0 hw]
  unfold dfsCostB
  linarith

/-! ### The crossover sits at the reciprocal branching factor -/

/-- **Restart dominates above `1/b`.** -/
theorem restart_dominates_dfsB {b w α : ℝ} (hb : 2 ≤ b) (hw : 0 < w) (hwb : w ≤ b - 1)
    (hα : 0 < α) (hcross : 1 / b < α) :
    Tendsto (fun h : ℕ => restartCost α h / dfsCostB b w h) atTop (𝓝 0) := by
  have hb0 : (0 : ℝ) < b := by linarith
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hprod : 1 < α * b := by
    rw [div_lt_iff₀ hb0] at hcross; linarith
  have hCpos : (0 : ℝ) < w * b / (2 * (b - 1) ^ 2) :=
    div_pos (mul_pos hw hb0) (mul_pos (by norm_num) (pow_pos hb1 2))
  have hr1 : 1 / (α * b) < 1 := by rw [div_lt_one (by linarith)]; exact hprod
  have hr0 : (0 : ℝ) ≤ 1 / (α * b) := by positivity
  have hg : Tendsto
      (fun h : ℕ => 2 * (b - 1) ^ 2 / (w * b) * ((h : ℝ) * (1 / (α * b)) ^ h)) atTop
      (𝓝 0) := by
    simpa using
      (tendsto_self_mul_const_pow_of_lt_one hr0 hr1).const_mul (2 * (b - 1) ^ 2 / (w * b))
  refine squeeze_zero' ?_ ?_ hg
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hd : 0 < dfsCostB b w h :=
      lt_of_lt_of_le (mul_pos hCpos (pow_pos hb0 h)) (dfsCostB_ge hb hw hwb hh)
    exact div_nonneg (restartCost_pos hα hh).le hd.le
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hdge := dfsCostB_ge hb hw hwb hh
    have hpos : (0 : ℝ) < w * b / (2 * (b - 1) ^ 2) * b ^ h := mul_pos hCpos (pow_pos hb0 h)
    have hstep : restartCost α h / dfsCostB b w h
        ≤ restartCost α h / (w * b / (2 * (b - 1) ^ 2) * b ^ h) :=
      div_le_div_of_nonneg_left (restartCost_pos hα hh).le hpos hdge
    have heq : restartCost α h / (w * b / (2 * (b - 1) ^ 2) * b ^ h)
        = 2 * (b - 1) ^ 2 / (w * b) * ((h : ℝ) * (1 / (α * b)) ^ h) := by
      have hαh : (α : ℝ) ^ h ≠ 0 := (pow_pos hα h).ne'
      have hbh : (b : ℝ) ^ h ≠ 0 := by positivity
      unfold restartCost
      rw [div_pow, one_pow, mul_pow]
      field_simp
    linarith [hstep, heq.le, heq.ge]

/-- **DFS dominates below `1/b`.** -/
theorem dfsB_dominates_restart {b w α : ℝ} (hb : 2 ≤ b) (hw : 0 < w) (hwb : w ≤ b - 1)
    (hα : 0 < α) (hcross : α < 1 / b) :
    Tendsto (fun h : ℕ => dfsCostB b w h / restartCost α h) atTop (𝓝 0) := by
  have hb0 : (0 : ℝ) < b := by linarith
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hprod : α * b < 1 := by
    rw [lt_div_iff₀ hb0] at hcross; linarith
  have hα1 : α < 1 := by nlinarith
  have hCpos : (0 : ℝ) < w * b / (2 * (b - 1) ^ 2) :=
    div_pos (mul_pos hw hb0) (mul_pos (by norm_num) (pow_pos hb1 2))
  have hg : Tendsto (fun h : ℕ => α ^ h + b / (b - 1) * (α * b) ^ h) atTop (𝓝 0) := by
    have t1 : Tendsto (fun h : ℕ => α ^ h) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one hα.le hα1
    have t2 : Tendsto (fun h : ℕ => (α * b) ^ h) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by positivity) hprod
    simpa using t1.add (t2.const_mul (b / (b - 1)))
  refine squeeze_zero' ?_ ?_ hg
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hd : 0 ≤ dfsCostB b w h :=
      le_trans (mul_pos hCpos (pow_pos hb0 h)).le (dfsCostB_ge hb hw hwb hh)
    exact div_nonneg hd (restartCost_pos hα hh).le
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hhr : (1 : ℝ) ≤ (h : ℝ) := by exact_mod_cast hh
    have hup := dfsCostB_le hb hw hwb h
    have hr : 0 < restartCost α h := restartCost_pos hα hh
    rw [div_le_iff₀ hr]
    have hRHS : (α ^ h + b / (b - 1) * (α * b) ^ h) * restartCost α h
        = (h : ℝ) + b / (b - 1) * (h : ℝ) * b ^ h := by
      have hαh : (α : ℝ) ^ h ≠ 0 := (pow_pos hα h).ne'
      unfold restartCost
      rw [mul_pow]
      field_simp
    rw [hRHS]
    have hbh : (0 : ℝ) < b ^ h := by positivity
    have hfrac : (0 : ℝ) < b / (b - 1) := by positivity
    nlinarith [mul_nonneg (mul_nonneg hfrac.le (by linarith : (0:ℝ) ≤ (h : ℝ) - 1)) hbh.le]

/-! ### The general exponent law -/

/-- The general DFS schedule has exponential rate exactly `b`. -/
theorem dfsB_log_rate {b w : ℝ} (hb : 2 ≤ b) (hw : 0 < w) (hwb : w ≤ b - 1) :
    Tendsto (fun h : ℕ => Real.log (dfsCostB b w h) / h) atTop (𝓝 (Real.log b)) := by
  have hb0 : (0 : ℝ) < b := by linarith
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hCpos : (0 : ℝ) < w * b / (2 * (b - 1) ^ 2) :=
    div_pos (mul_pos hw hb0) (mul_pos (by norm_num) (pow_pos hb1 2))
  have hL : (0 : ℝ) < w * b / (b - 1) ^ 2 := div_pos (mul_pos hw hb0) (pow_pos hb1 2)
  have hg : Tendsto (fun h : ℕ => dfsCostB b w h / b ^ h) atTop (𝓝 (w * b / (b - 1) ^ 2)) :=
    dfsCostB_div_pow_tendsto (by linarith) w
  have hlog : Tendsto (fun h : ℕ => Real.log (dfsCostB b w h / b ^ h)) atTop
      (𝓝 (Real.log (w * b / (b - 1) ^ 2))) :=
    (Real.continuousAt_log (ne_of_gt hL)).tendsto.comp hg
  have hquot : Tendsto (fun h : ℕ => Real.log (dfsCostB b w h / b ^ h) / h) atTop (𝓝 0) :=
    hlog.div_atTop tendsto_natCast_atTop_atTop
  have hlim : Tendsto (fun h : ℕ => Real.log b + Real.log (dfsCostB b w h / b ^ h) / h) atTop
      (𝓝 (Real.log b)) := by
    simpa using hquot.const_add (Real.log b)
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hbh : (0 : ℝ) < b ^ h := by positivity
  have hd : 0 < dfsCostB b w h :=
    lt_of_lt_of_le (mul_pos hCpos (pow_pos hb0 h)) (dfsCostB_ge hb hw hwb hh)
  have hsplit : dfsCostB b w h = b ^ h * (dfsCostB b w h / b ^ h) := by field_simp
  rw [hsplit, Real.log_mul (ne_of_gt hbh) (ne_of_gt (div_pos hd hbh)), Real.log_pow, ← hsplit]
  field_simp

/-- The optimal general schedule. -/
noncomputable def minCostB (b w α : ℝ) (h : ℕ) : ℝ := min (dfsCostB b w h) (restartCost α h)

/-- **General ascent exponent law.**  For branching factor `b ≥ 2` the optimal exponent of an
end-verification ascent guided by an accuracy-`α` oracle is exactly `min (b, 1/α)`: the kink of
cycle 2 sits at `α = 1/b` for every `b`. -/
theorem ascent_exponent_law_general {b w α : ℝ} (hb : 2 ≤ b) (hw : 0 < w) (hwb : w ≤ b - 1)
    (hα : 0 < α) :
    Tendsto (fun h : ℕ => Real.log (minCostB b w α h) / h) atTop
      (𝓝 (Real.log (min b (1 / α)))) := by
  have hb0 : (0 : ℝ) < b := by linarith
  have hb1 : (0 : ℝ) < b - 1 := by linarith
  have hCpos : (0 : ℝ) < w * b / (2 * (b - 1) ^ 2) :=
    div_pos (mul_pos hw hb0) (mul_pos (by norm_num) (pow_pos hb1 2))
  have hlim := (dfsB_log_rate hb hw hwb).min (restart_log_rate hα)
  rw [← log_min_eq hb0 (by positivity)] at hlim
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  have hh0 : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hd : 0 < dfsCostB b w h :=
    lt_of_lt_of_le (mul_pos hCpos (pow_pos hb0 h)) (dfsCostB_ge hb hw hwb hh)
  have hr : 0 < restartCost α h := restartCost_pos hα hh
  unfold minCostB
  rw [log_min_eq hd hr, min_div_div_right hh0.le]

/-- The kink of the general exponent law is exactly at `α = 1/b`. -/
theorem ascent_rate_kink_general {b α : ℝ} (hb : 2 ≤ b) (hα : 0 < α) :
    (α ≤ 1 / b → min b (1 / α) = b) ∧ (1 / b ≤ α → min b (1 / α) = 1 / α) := by
  have hb0 : (0 : ℝ) < b := by linarith
  constructor
  · intro hle
    refine min_eq_left ?_
    rw [le_div_iff₀ hα]
    rw [le_div_iff₀ hb0] at hle
    linarith
  · intro hge
    refine min_eq_right ?_
    rw [div_le_iff₀ hα]
    rw [div_le_iff₀ hb0] at hge
    linarith

end AscentCostLaw