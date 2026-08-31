/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Ascent-cost laws: exact economics of a branch oracle under end-verification semantics

A search agent must climb a ternary decision tree of height `h`.  At every level it consults a
*branch oracle* which names the correct child with probability `α`.  Verification happens only at
the leaf (end-verification-only semantics): a wrong turn is discovered only after the whole wrong
subtree has been exhausted.  Two schedules are priced exactly here.

* **DFS with backtracking.**  Entering level `j` costs one visit; with the level failure weight
  `K = (1 - α)(2 - α)` the agent additionally burns a complete wrong ternary subtree of
  `(3 ^ j - 1) / 2` nodes.  Summing the levels gives the closed law
  `E_dfs(h) = h (1 - K/2) + K (3 ^ (h+1) - 3) / 4` (`dfsCost_eq_dfsCostRec`).
* **Restart from root.**  A full descent succeeds with probability `α ^ h`; failures are detected
  only at the leaf, so each attempt costs `h` visits and the number of attempts is geometric.  Its
  mean is exactly `E_restart(h) = h α ^ (-h)` (`restartCost_eq_expected_work`).

The formal findings, each a theorem below.

* **Effective branching is refuted.**  For *every* `α < 1` the DFS law has growth ratio exactly
  `3` in the limit (`dfs_growth_ratio_tendsto_three`); oracle accuracy enters only through the
  prefactor `3K/4` (`dfsCost_div_pow_tendsto`).  There is no "effective branching factor" below
  `3`.
* **The α = 1/3 dominance boundary.**  Restart beats DFS by an unbounded factor exactly when
  `α > 1/3` (`restart_dominates_dfs`), and loses by an unbounded factor when `α < 1/3`
  (`dfs_dominates_restart`).  This is the exact form of the empirical "restart dominates in 99%
  of cells".
* **Beam (exhaustive level sweep) never wins** — `dfsCost_le_beamCost`, for every `α ∈ [0,1]`.
* **The master hint law is refuted.**  The class-hint law of the earlier ledger saturates at a
  cap `1/θ = 3`; the branch-hint speedup `(3α) ^ h` is unbounded for every `α > 1/3`
  (`hintSpeedup_unbounded`), so no constant cap can hold.  Sequential hints compound
  geometrically (`restartCost_add`, `successProb_add`).
* **Exponential → polynomial phase transition at α = 1**: `restartCost 1 h = h` while for `α < 1`
  the cost per unit depth diverges (`restartCost_div_depth_atTop`).
* **Breakeven against a fixed exact-solver budget** is a genuine threshold: cost is strictly
  decreasing in `α` (`restartCost_strictAnti`), and an explicit critical accuracy
  `α* = ((1+c) h / F) ^ (1/h)` separates win from loss (`breakeven_threshold`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): oracle accuracy buys a smaller *base*, i.e. an effective branching
factor `b(α) < 3`, so that a modest `α` already converts exponential ascent into a cheap climb.

Experiment (Experimenter): the closed law was evaluated numerically (see
`ComputationalEvidence.md`).  With `K = (1-α)(2-α)`: at `α = 0.9`, `K = 0.11`,
`E_dfs(10) = 10·0.945 + 0.11·(3^11-3)/4 = 4880.91`, while the predicted leading term
`3^10 · 3K/4 = 4871.54` — the ratio `E(h+1)/E(h)` is `2.99636` at `h = 10` and `2.99994` at
`h = 14`, i.e. pinned at `3`.  At `α = 0.99` the same ratio is `2.99434` at `h = 12`.  Restart:
`E_restart(10) = 10·0.9^{-10} = 28.68`, more than two orders below DFS; at `α = 0.3 < 1/3`,
`E_restart(10) = 1.69·10^6` against `E_dfs(10) = 5.27·10^4`, so DFS wins — the boundary is at
`3α = 1` exactly, as the two dominance theorems below assert.

Analysis (Analyst): the DFS law is a geometric sum whose top term `K 3^{h+1}/4` dwarfs the linear
term; accuracy scales that prefactor to `0` continuously as `α → 1` but never touches the base.
The restart law is the one that changes base, from `3` to `1/α`, which is why the crossover sits
at `α = 1/3` and why the empirical speedup diverges instead of saturating at the class-hint cap.

Critique (Critic): `restartCost` is only meaningful for `α > 0`, so every comparison theorem
carries `0 < α`; `dfsCost` bounds require `α ∈ [0,1]` to keep `K ∈ [0,2]` and `1 - K/2 ≥ 0`,
which is stated as `failWeight_nonneg` / `failWeight_le_two` rather than assumed silently.  The
`α = 1` case of the geometric expectation is degenerate (`1 - α ^ h = 0`) and is proved
separately inside `tsum_geometric_trials`.
-/

namespace AscentCostLaw

open Filter Topology

/-! ### The two cost laws -/

/-- Level failure weight `K = (1 - α)(2 - α)` of a ternary branch oracle of accuracy `α`:
the expected number of *wrong* children fully expanded before the right one is taken, doubled;
equivalently `K/2 = (1-α)(2-α)/2` is the mean count of wasted siblings. -/
noncomputable def failWeight (α : ℝ) : ℝ := (1 - α) * (2 - α)

/-- Cost of the `j`-th level of a DFS ascent: one visit, plus (weighted by `K`) a complete wrong
ternary subtree of `(3 ^ j - 1)/2` nodes, which end-verification forces the agent to exhaust. -/
noncomputable def dfsLevelCost (α : ℝ) (j : ℕ) : ℝ := 1 + failWeight α * ((3 : ℝ) ^ j - 1) / 2

/-- The DFS ascent cost, defined by accumulating level costs. -/
noncomputable def dfsCostRec (α : ℝ) : ℕ → ℝ
  | 0 => 0
  | h + 1 => dfsCostRec α h + dfsLevelCost α (h + 1)

/-- The closed-form DFS ascent law `E = h (1 - K/2) + K (3 ^ (h+1) - 3)/4`. -/
noncomputable def dfsCost (α : ℝ) (h : ℕ) : ℝ :=
  h * (1 - failWeight α / 2) + failWeight α * ((3 : ℝ) ^ (h + 1) - 3) / 4

/-- Probability that a full depth-`h` descent guided by an accuracy-`α` oracle is correct. -/
noncomputable def successProb (α : ℝ) (h : ℕ) : ℝ := α ^ h

/-- The restart-from-root ascent law `E = h α ^ (-h)`. -/
noncomputable def restartCost (α : ℝ) (h : ℕ) : ℝ := (h : ℝ) / α ^ h

/-- Exhaustive level sweep (beam of full width `3`): all `(3 ^ (h+1) - 3)/2` internal nodes. -/
noncomputable def beamCost (h : ℕ) : ℝ := ((3 : ℝ) ^ (h + 1) - 3) / 2

/-! ### Elementary properties of the failure weight -/

theorem failWeight_nonneg {α : ℝ} (h1 : α ≤ 1) : 0 ≤ failWeight α := by
  have : (0:ℝ) ≤ 1 - α := by linarith
  have : (0:ℝ) ≤ 2 - α := by linarith
  unfold failWeight; positivity

theorem failWeight_pos {α : ℝ} (h1 : α < 1) : 0 < failWeight α := by
  unfold failWeight; nlinarith

theorem failWeight_le_two {α : ℝ} (h0 : 0 ≤ α) (h1 : α ≤ 1) : failWeight α ≤ 2 := by
  unfold failWeight; nlinarith

/-! ### Law 1: the exact DFS backtracking cost -/

/-- **Exact DFS ascent law.**  Accumulating the per-level costs gives the closed form
`h (1 - K/2) + K (3 ^ (h+1) - 3)/4`. -/
theorem dfsCost_eq_dfsCostRec (α : ℝ) (h : ℕ) : dfsCostRec α h = dfsCost α h := by
  induction h with
  | zero => simp [dfsCostRec, dfsCost]
  | succ n ih =>
      rw [dfsCostRec, ih]
      simp only [dfsCost, dfsLevelCost]
      push_cast
      ring

/-! ### Law 2: the exact restart-from-root cost -/

/-- Mean number of independent Bernoulli(`p`) trials until the first success is `1/p`. -/
theorem tsum_geometric_trials {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    ∑' n : ℕ, ((n : ℝ) + 1) * (p * (1 - p) ^ n) = 1 / p := by
  rcases eq_or_lt_of_le hp1 with rfl | hlt
  · have hz : ∀ n : ℕ, n ≠ 0 → ((n : ℝ) + 1) * (1 * (1 - 1) ^ n) = 0 := by
      intro n hn
      rw [sub_self, zero_pow hn]
      ring
    rw [tsum_eq_single 0 hz]
    norm_num
  · set r : ℝ := 1 - p with hr
    have hr0 : 0 ≤ r := by simp [hr]; linarith
    have hr1 : r < 1 := by simp [hr]; linarith
    have h1 : HasSum (fun n : ℕ => (n : ℝ) * r ^ n) (r / (1 - r) ^ 2) := by
      apply hasSum_coe_mul_geometric_of_norm_lt_one
      rw [Real.norm_eq_abs, abs_of_nonneg hr0]; exact hr1
    have h2 : HasSum (fun n : ℕ => r ^ n) (1 - r)⁻¹ := hasSum_geometric_of_lt_one hr0 hr1
    have h3 := (h1.add h2).mul_left p
    have h4 : (fun n : ℕ => p * ((n : ℝ) * r ^ n + r ^ n))
        = fun n : ℕ => ((n : ℝ) + 1) * (p * (1 - p) ^ n) := by
      funext n; rw [← hr]; ring
    rw [h4] at h3
    rw [h3.tsum_eq]
    have hrp : 1 - r = p := by simp [hr]
    rw [hrp]
    field_simp
    ring

/-- **Exact restart-from-root ascent law.**  Under end-verification-only semantics each attempt
costs `h` visits and succeeds with probability `α ^ h`, so the expected work is exactly
`h α ^ (-h)`. -/
theorem restartCost_eq_expected_work {α : ℝ} (hα : 0 < α) (hα1 : α ≤ 1) (h : ℕ) :
    (∑' n : ℕ, ((n : ℝ) + 1) * (successProb α h * (1 - successProb α h) ^ n)) * h
      = restartCost α h := by
  have hp : 0 < successProb α h := by unfold successProb; positivity
  have hp1 : successProb α h ≤ 1 := pow_le_one₀ hα.le hα1
  rw [tsum_geometric_trials hp hp1]
  unfold restartCost successProb
  field_simp

/-- Sequential branch hints compound geometrically: a chain of `h₁ + h₂` hinted branchings
succeeds with the product of the two stage probabilities. -/
theorem successProb_add (α : ℝ) (h₁ h₂ : ℕ) :
    successProb α (h₁ + h₂) = successProb α h₁ * successProb α h₂ := pow_add α h₁ h₂

/-- The restart price of a sequential hint chain is set by the *product* of the stage success
probabilities — the geometric compounding that puts branch hints in a new taxonomy class. -/
theorem restartCost_add (α : ℝ) (h₁ h₂ : ℕ) :
    restartCost α (h₁ + h₂)
      = ((h₁ : ℝ) + h₂) / (successProb α h₁ * successProb α h₂) := by
  unfold restartCost successProb
  rw [← pow_add]
  push_cast
  ring

/-! ### Effective branching is refuted: the base stays pinned at 3 -/

/-- The DFS law is exactly `3 ^ h` times the prefactor `3K/4`, up to vanishing corrections. -/
theorem dfsCost_div_pow_tendsto (α : ℝ) :
    Tendsto (fun h : ℕ => dfsCost α h / (3 : ℝ) ^ h) atTop (𝓝 (3 * failWeight α / 4)) := by
  have key : ∀ h : ℕ, dfsCost α h / (3 : ℝ) ^ h
      = (1 - failWeight α / 2) * ((h : ℝ) * (1/3 : ℝ) ^ h)
        + 3 * failWeight α / 4 - (3 * failWeight α / 4) * ((1/3 : ℝ) ^ h) := by
    intro h
    have h3 : ((3:ℝ) ^ h) ≠ 0 := by positivity
    unfold dfsCost
    rw [div_eq_iff h3]
    have : ((1:ℝ)/3) ^ h = 1 / (3:ℝ) ^ h := by rw [div_pow]; norm_num
    rw [this, pow_succ]
    field_simp
    ring
  simp only [key]
  have t1 : Tendsto (fun h : ℕ => (h : ℝ) * (1/3 : ℝ) ^ h) atTop (𝓝 0) :=
    tendsto_self_mul_const_pow_of_lt_one (by norm_num) (by norm_num)
  have t2 : Tendsto (fun h : ℕ => ((1/3 : ℝ)) ^ h) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have := ((t1.const_mul (1 - failWeight α / 2)).add_const (3 * failWeight α / 4)).sub
    (t2.const_mul (3 * failWeight α / 4))
  simpa using this

/-- **Effective branching refuted.**  For every accuracy `α < 1` the DFS ascent cost grows with
ratio exactly `3` — the branching base is untouched by the oracle; accuracy only rescales the
prefactor. -/
theorem dfs_growth_ratio_tendsto_three {α : ℝ} (h1 : α < 1) :
    Tendsto (fun h : ℕ => dfsCost α (h + 1) / dfsCost α h) atTop (𝓝 3) := by
  have hK : 0 < failWeight α := failWeight_pos h1
  have hL : 3 * failWeight α / 4 ≠ 0 := by positivity
  have hf : Tendsto (fun h : ℕ => dfsCost α h / (3 : ℝ) ^ h) atTop
      (𝓝 (3 * failWeight α / 4)) := dfsCost_div_pow_tendsto α
  have hf' := hf.comp (tendsto_add_atTop_nat 1)
  simp only [Function.comp_def] at hf'
  have hq := (hf'.div hf hL).const_mul (3 : ℝ)
  rw [div_self hL, mul_one] at hq
  simp only [Pi.div_apply] at hq
  refine hq.congr (fun h => ?_)
  by_cases hB : dfsCost α h = 0
  · simp [hB]
  · have h3 : ((3 : ℝ) ^ h) ≠ 0 := by positivity
    field_simp
    ring

/-! ### The α = 1/3 dominance boundary -/

/-- Lower bound: the DFS law is at least the leading exponential term. -/
theorem dfsCost_ge {α : ℝ} (h0 : 0 ≤ α) (h1 : α ≤ 1) {h : ℕ} (hh : 1 ≤ h) :
    failWeight α / 4 * (3 : ℝ) ^ h ≤ dfsCost α h := by
  have hK : 0 ≤ failWeight α := failWeight_nonneg h1
  have hK2 : failWeight α ≤ 2 := failWeight_le_two h0 h1
  have hcast : (0 : ℝ) ≤ (h : ℝ) := Nat.cast_nonneg h
  have hlin : 0 ≤ (h : ℝ) * (1 - failWeight α / 2) := by nlinarith
  have h3 : (3 : ℝ) ≤ (3 : ℝ) ^ h := by
    calc (3 : ℝ) = 3 ^ 1 := by norm_num
      _ ≤ 3 ^ h := pow_le_pow_right₀ (by norm_num) hh
  unfold dfsCost
  rw [pow_succ]
  nlinarith [mul_nonneg hK (by linarith : (0:ℝ) ≤ (3:ℝ) ^ h - 3)]

/-- Upper bound: the DFS law never exceeds depth plus a full level sweep. -/
theorem dfsCost_le {α : ℝ} (h0 : 0 ≤ α) (h1 : α ≤ 1) (h : ℕ) :
    dfsCost α h ≤ (h : ℝ) + (3 : ℝ) ^ (h + 1) / 2 := by
  have hK : 0 ≤ failWeight α := failWeight_nonneg h1
  have hK2 : failWeight α ≤ 2 := failWeight_le_two h0 h1
  have h3 : (0 : ℝ) < (3 : ℝ) ^ (h + 1) := by positivity
  have hh : (0 : ℝ) ≤ (h : ℝ) := Nat.cast_nonneg h
  unfold dfsCost
  nlinarith [mul_nonneg hh hK]

theorem restartCost_pos {α : ℝ} (h0 : 0 < α) {h : ℕ} (hh : 1 ≤ h) : 0 < restartCost α h := by
  have hpos : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  unfold restartCost
  exact div_pos hpos (pow_pos h0 h)

/-- **Restart dominates DFS above the 1/3 boundary**: for every accuracy `α > 1/3` the
restart-from-root schedule is cheaper than DFS backtracking by an unbounded factor. -/
theorem restart_dominates_dfs {α : ℝ} (hlow : 1/3 < α) (h1 : α < 1) :
    Tendsto (fun h : ℕ => restartCost α h / dfsCost α h) atTop (𝓝 0) := by
  have hα0 : 0 < α := by linarith
  have hK : 0 < failWeight α := failWeight_pos h1
  have hr1 : 1 / (3 * α) < 1 := by
    rw [div_lt_one (by linarith)]; linarith
  have hr0 : (0 : ℝ) ≤ 1 / (3 * α) := by positivity
  have hg : Tendsto (fun h : ℕ => (4 / failWeight α) * ((h : ℝ) * (1 / (3 * α)) ^ h)) atTop
      (𝓝 0) := by
    simpa using (tendsto_self_mul_const_pow_of_lt_one hr0 hr1).const_mul (4 / failWeight α)
  refine squeeze_zero' ?_ ?_ hg
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hd : 0 < dfsCost α h :=
      lt_of_lt_of_le (by positivity) (dfsCost_ge hα0.le h1.le hh)
    exact div_nonneg (restartCost_pos hα0 hh).le hd.le
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hdge : failWeight α / 4 * (3 : ℝ) ^ h ≤ dfsCost α h := dfsCost_ge hα0.le h1.le hh
    have hpos : (0 : ℝ) < failWeight α / 4 * (3 : ℝ) ^ h := by positivity
    have hstep : restartCost α h / dfsCost α h
        ≤ restartCost α h / (failWeight α / 4 * (3 : ℝ) ^ h) :=
      div_le_div_of_nonneg_left (restartCost_pos hα0 hh).le hpos hdge
    have heq : restartCost α h / (failWeight α / 4 * (3 : ℝ) ^ h)
        = (4 / failWeight α) * ((h : ℝ) * (1 / (3 * α)) ^ h) := by
      have hαh : (α : ℝ) ^ h ≠ 0 := (pow_pos hα0 h).ne'
      have h3 : ((3 : ℝ) ^ h) ≠ 0 := by positivity
      unfold restartCost
      rw [div_pow, one_pow, mul_pow]
      field_simp
    linarith [hstep, heq.le, heq.ge]

/-- **Below the boundary DFS wins**: for `α < 1/3` restart-from-root is unboundedly worse. -/
theorem dfs_dominates_restart {α : ℝ} (h0 : 0 < α) (hhigh : α < 1/3) :
    Tendsto (fun h : ℕ => dfsCost α h / restartCost α h) atTop (𝓝 0) := by
  have h1 : α < 1 := by linarith
  have hK : 0 ≤ failWeight α := failWeight_nonneg h1.le
  have hg : Tendsto (fun h : ℕ => α ^ h + (3 / 2) * (3 * α) ^ h) atTop (𝓝 0) := by
    have t1 : Tendsto (fun h : ℕ => α ^ h) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one h0.le h1
    have t2 : Tendsto (fun h : ℕ => (3 * α) ^ h) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by positivity) (by linarith)
    simpa using t1.add (t2.const_mul (3 / 2 : ℝ))
  refine squeeze_zero' ?_ ?_ hg
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hd : 0 ≤ dfsCost α h := le_trans (by positivity) (dfsCost_ge h0.le h1.le hh)
    exact div_nonneg hd (restartCost_pos h0 hh).le
  · filter_upwards [eventually_ge_atTop 1] with h hh
    have hhr : (1 : ℝ) ≤ (h : ℝ) := by exact_mod_cast hh
    have hup : dfsCost α h ≤ (h : ℝ) + (3 : ℝ) ^ (h + 1) / 2 := dfsCost_le h0.le h1.le h
    have hr : 0 < restartCost α h := restartCost_pos h0 hh
    rw [div_le_iff₀ hr]
    have hRHS : (α ^ h + (3 / 2) * (3 * α) ^ h) * restartCost α h
        = (h : ℝ) + (3 / 2) * (h : ℝ) * 3 ^ h := by
      have hαh : (α : ℝ) ^ h ≠ 0 := (pow_pos h0 h).ne'
      unfold restartCost
      rw [mul_pow]
      field_simp
    rw [hRHS]
    have h3 : (0 : ℝ) < (3 : ℝ) ^ h := by positivity
    have hsucc : (3 : ℝ) ^ (h + 1) / 2 = (3 / 2) * 3 ^ h := by rw [pow_succ]; ring
    nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ (h : ℝ) - 1) h3.le]

/-! ### Beam never wins -/

/-- `3 ^ (h+1) ≥ 2h + 3`: a full level sweep always dominates the linear descent term. -/
theorem three_pow_ge_linear (h : ℕ) : 2 * (h : ℝ) + 3 ≤ (3 : ℝ) ^ (h + 1) := by
  induction h with
  | zero => norm_num
  | succ n ih =>
      have hexp : (3 : ℝ) ^ (n + 1 + 1) = 3 ^ (n + 1) * 3 := by ring
      have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      rw [hexp]
      push_cast
      linarith

/-- **Beam never wins.**  An exhaustive width-3 level sweep costs at least as much as the DFS
ascent, for every oracle accuracy in `[0,1]` and every height. -/
theorem dfsCost_le_beamCost {α : ℝ} (h0 : 0 ≤ α) (h1 : α ≤ 1) (h : ℕ) :
    dfsCost α h ≤ beamCost h := by
  have hK2 : failWeight α ≤ 2 := failWeight_le_two h0 h1
  have hpow := three_pow_ge_linear h
  unfold dfsCost beamCost
  nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ 2 - failWeight α)
    (by linarith : (0:ℝ) ≤ (3:ℝ) ^ (h + 1) - 3 - 2 * (h : ℝ))]

/-! ### Boundary calibration of the DFS law -/

/-- A blind agent (`α = 0`) pays exactly the exhaustive level sweep: the DFS law degenerates to
the beam cost, so the beam bound above is sharp. -/
theorem dfsCost_zero (h : ℕ) : dfsCost 0 h = beamCost h := by
  unfold dfsCost beamCost failWeight
  ring

/-- A perfect oracle (`α = 1`) pays exactly the depth: the DFS law degenerates to `h`. -/
theorem dfsCost_one (h : ℕ) : dfsCost 1 h = h := by
  unfold dfsCost failWeight
  ring

/-! ### The master hint law is refuted -/

/-- Speedup of an accuracy-`α` branch oracle over the uninformed ternary baseline `α = 1/3`,
measured with the restart law. -/
noncomputable def hintSpeedup (α : ℝ) (h : ℕ) : ℝ := restartCost (1/3) h / restartCost α h

/-- The branch-hint speedup is exactly `(3α) ^ h`: sequential hints compound geometrically. -/
theorem hintSpeedup_eq {α : ℝ} (hα : 0 < α) {h : ℕ} (hh : 1 ≤ h) :
    hintSpeedup α h = (3 * α) ^ h := by
  have hh0 : (h : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  have hαh : (α : ℝ) ^ h ≠ 0 := (pow_pos hα h).ne'
  have e1 : restartCost (1/3 : ℝ) h = (h : ℝ) * 3 ^ h := by
    unfold restartCost
    rw [div_pow, one_pow]
    field_simp
  unfold hintSpeedup
  rw [e1, mul_pow]
  unfold restartCost
  field_simp

/-- **Master-law mapping refuted.**  The class-hint master law caps speedup at `1/θ = 3`; the
sequential branch-hint speedup exceeds every constant cap as soon as `α > 1/3`. -/
theorem hintSpeedup_unbounded {α : ℝ} (hlow : 1/3 < α) :
    Tendsto (fun h : ℕ => hintSpeedup α h) atTop atTop := by
  have hα : 0 < α := by linarith
  have hbase : (1 : ℝ) < 3 * α := by linarith
  have hp : Tendsto (fun h : ℕ => (3 * α) ^ h) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt hbase
  refine hp.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  exact (hintSpeedup_eq hα hh).symm

/-- Concretely: no cap — in particular not the class-hint cap `3` — bounds the branch-hint
speedup. -/
theorem hintSpeedup_exceeds_cap {α : ℝ} (hlow : 1/3 < α) (C : ℝ) :
    ∃ h : ℕ, C < hintSpeedup α h :=
  ((hintSpeedup_unbounded hlow).eventually_gt_atTop C).exists

/-! ### Exponential → polynomial phase transition at α = 1 -/

theorem restartCost_one (h : ℕ) : restartCost 1 h = h := by simp [restartCost]

/-- For any accuracy below `1` the restart cost per unit depth diverges: the transition to the
polynomial regime happens only in the limit `α → 1`. -/
theorem restartCost_div_depth_atTop {α : ℝ} (h0 : 0 < α) (h1 : α < 1) :
    Tendsto (fun h : ℕ => restartCost α h / h) atTop atTop := by
  have hbase : (1 : ℝ) < 1 / α := by rw [lt_div_iff₀ h0]; linarith
  have hp : Tendsto (fun h : ℕ => (1 / α) ^ h) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt hbase
  refine hp.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with h hh
  have hh0 : (h : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  have hαh : (α : ℝ) ^ h ≠ 0 := (pow_pos h0 h).ne'
  unfold restartCost
  rw [div_pow, one_pow]
  field_simp

/-! ### Breakeven against a fixed exact-solver budget -/

/-- Restart cost is strictly decreasing in the oracle accuracy: the breakeven set of accuracies
is a genuine upper interval, so a critical accuracy `α*` exists. -/
theorem restartCost_strictAnti {α β : ℝ} (h0 : 0 < α) (hab : α < β) {h : ℕ} (hh : 1 ≤ h) :
    restartCost β h < restartCost α h := by
  have hpos : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hαh : (0 : ℝ) < α ^ h := pow_pos h0 h
  have hlt : α ^ h < β ^ h := by
    have := pow_lt_pow_left₀ hab h0.le (n := h) (by omega)
    exact this
  unfold restartCost
  exact div_lt_div_of_pos_left hpos hαh hlt

/-- **Breakeven threshold.**  With a per-step overhead `c ≥ 0` and an exact-solver budget `F`
that even the perfect oracle would have to beat, there is an explicit critical accuracy
`α* = ((1+c) h / F) ^ (1/h)` in `(0,1)` above which the guided ascent wins. -/
theorem breakeven_threshold {c F : ℝ} (hc : 0 ≤ c) {h : ℕ} (hh : 1 ≤ h)
    (hwin : (1 + c) * h < F) :
    ∃ αstar : ℝ, 0 < αstar ∧ αstar < 1 ∧
      ∀ α : ℝ, αstar < α → α ≤ 1 → (1 + c) * restartCost α h < F := by
  have hhpos : (0 : ℝ) < (h : ℝ) := by exact_mod_cast hh
  have hcpos : (0 : ℝ) < 1 + c := by linarith
  have hnum : (0 : ℝ) < (1 + c) * h := by positivity
  have hF : 0 < F := lt_trans hnum hwin
  set t : ℝ := (1 + c) * h / F with ht
  have ht0 : 0 < t := div_pos hnum hF
  have ht1 : t < 1 := by rw [ht, div_lt_one hF]; exact hwin
  refine ⟨t ^ ((h : ℝ)⁻¹), Real.rpow_pos_of_pos ht0 _,
    Real.rpow_lt_one ht0.le ht1 (by positivity), ?_⟩
  intro α hα _
  have hαpos : 0 < α := lt_trans (Real.rpow_pos_of_pos ht0 _) hα
  have hpow : t < α ^ h := by
    have hstep : (t ^ ((h : ℝ)⁻¹)) ^ h < α ^ h :=
      pow_lt_pow_left₀ hα (Real.rpow_nonneg ht0.le _) (by omega)
    have hid : (t ^ ((h : ℝ)⁻¹)) ^ h = t := by
      rw [← Real.rpow_natCast (t ^ ((h : ℝ)⁻¹)) h, ← Real.rpow_mul ht0.le,
        inv_mul_cancel₀ (ne_of_gt hhpos), Real.rpow_one]
    rwa [hid] at hstep
  have hlt : (1 + c) * restartCost α h < (1 + c) * ((h : ℝ) / t) := by
    refine mul_lt_mul_of_pos_left ?_ hcpos
    unfold restartCost
    exact div_lt_div_of_pos_left hhpos ht0 hpow
  have heq : (1 + c) * ((h : ℝ) / t) = F := by
    rw [ht]
    field_simp
  rwa [heq] at hlt

end AscentCostLaw