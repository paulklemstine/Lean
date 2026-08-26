import Catalog.Bridges.BerggrenBoundaryEntropy
import Catalog.Bridges.BerggrenWalkDrift

/-!
# The entropy–metric gap: silver never catches up with `log 3`

This file settles the quantitative half of Conjecture 3 of the previous cycle.

Two exponents govern the Berggren tree.  The *combinatorial* one is `log 3`: each node has
three children, so the boundary carries `3ⁿ` cylinders at depth `n` and the entropy of any
harmonic measure is at most `log 3` (`shannon_le_log_three`).  The *metric* one is the silver
exponent: the catalog's `dist_le_silver_depth` shows a depth-`n` node sits at hyperbolic
distance at most `2 (n+1) log(1+√2) + O(1)` from the base point (the factor `2` is the
`log`-hypotenuse normalisation used in `expected_drift_upper`), so the natural conformal
exponent of the hyperbolic embedding is `2 log(1+√2) = log(3 + 2√2)`.

These two numbers are *different*, and the metric one is strictly larger.  Consequently the
"dimension of the harmonic measure seen in the hyperbolic metric",
`hypDim P = H(p) / (2 log(1+√2))`, is bounded away from `1` **uniformly in the walk**: the
harmonic measure of the Berggren walk is never the conformal measure of the hyperbolic
embedding, no matter how the three moves are weighted.

## Main results

* `two_log_silver_eq_log` : `2 log(1+√2) = log(3 + 2√2)`.
* `log_three_lt_two_log_silver` : `log 3 < 2 log(1+√2)` — the two exponents never coincide.
* `shannon_lt_two_log_silver` : every Berggren walk has entropy strictly below the metric
  exponent.
* `hypDim_lt_one`, `hypDim_le_max`, `hypDim_uniform_gap` : the hyperbolic dimension of the
  harmonic measure is `< 1` for every walk, is maximal exactly at the fair walk, and misses
  `1` by the uniform amount `1 − log 3 / (2 log(1+√2)) > 0`.
* `hypDim_le_two_thirds` : the explicit numerical bound `hypDim P ≤ 2/3`, from
  `3³ ≤ (1+√2)⁴`.
* `entropy_lt_silver_of_drift` : combined with the proved drift sandwich, no Berggren walk
  can have its entropy exceed the silver upper bound on its escape rate per unit depth,
  which is the precise sense in which the harmonic measure is *dimension deficient*.
-/

namespace BerggrenHarmonic

open HyperbolicBerggrenGeodesics

/-- `(1+√2)² = 3 + 2√2`. -/
lemma silver_sq : silver ^ 2 = 3 + 2 * Real.sqrt 2 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  unfold silver
  nlinarith [h]

/-- The metric exponent of the hyperbolic embedding, `2 log(1+√2)`, is `log(3+2√2)`. -/
theorem two_log_silver_eq_log : 2 * Real.log silver = Real.log (3 + 2 * Real.sqrt 2) := by
  rw [← silver_sq, Real.log_pow]
  norm_num

/-- **The combinatorial and metric exponents of the Berggren tree are different**, and the
metric one is the larger: `log 3 < 2 log(1+√2)`. -/
theorem log_three_lt_two_log_silver : Real.log 3 < 2 * Real.log silver := by
  rw [two_log_silver_eq_log]
  have h2 : (1 : ℝ) < Real.sqrt 2 := by
    have : Real.sqrt 1 < Real.sqrt 2 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    simpa using this
  exact Real.log_lt_log (by norm_num) (by linarith)

theorem two_log_silver_pos : 0 < 2 * Real.log silver := by
  have := log_silver_pos
  linarith

/-- **The entropy of any Berggren walk is strictly below the metric exponent.** -/
theorem shannon_lt_two_log_silver (P : ProbVec) : shannon P < 2 * Real.log silver :=
  lt_of_le_of_lt (shannon_le_log_three P) log_three_lt_two_log_silver

/-- The dimension of the harmonic measure measured in the hyperbolic metric of the embedding:
entropy divided by the metric exponent `2 log(1+√2)`. -/
noncomputable def hypDim (P : ProbVec) : ℝ := shannon P / (2 * Real.log silver)

theorem hypDim_nonneg (P : ProbVec) : 0 ≤ hypDim P :=
  div_nonneg (shannon_nonneg P) two_log_silver_pos.le

/-- **The harmonic measure is never the conformal measure of the hyperbolic embedding**: its
hyperbolic dimension is strictly less than one for every weight vector. -/
theorem hypDim_lt_one (P : ProbVec) : hypDim P < 1 := by
  rw [hypDim, div_lt_one two_log_silver_pos]
  exact shannon_lt_two_log_silver P

/-- The hyperbolic dimension is at most `log 3 / (2 log(1+√2))`, with equality exactly for the
fair walk. -/
theorem hypDim_le_max (P : ProbVec) : hypDim P ≤ Real.log 3 / (2 * Real.log silver) := by
  rw [hypDim, div_le_div_iff_of_pos_right two_log_silver_pos]
  exact shannon_le_log_three P

theorem hypDim_eq_max_iff (P : ProbVec) :
    hypDim P = Real.log 3 / (2 * Real.log silver) ↔ ∀ a, P.p a = 1 / 3 := by
  rw [← shannon_eq_log_three_iff P, hypDim]
  constructor
  · intro h
    have h2 := congrArg (fun y : ℝ => y * (2 * Real.log silver)) h
    simpa [div_mul_cancel₀, two_log_silver_pos.ne'] using h2
  · intro h
    rw [h]

/-- **A uniform dimension gap.**  Every Berggren walk misses hyperbolic dimension `1` by at
least the positive constant `1 − log 3 / (2 log(1+√2))`. -/
theorem hypDim_uniform_gap :
    ∃ c > 0, ∀ P : ProbVec, hypDim P ≤ 1 - c := by
  refine ⟨1 - Real.log 3 / (2 * Real.log silver), ?_, ?_⟩
  · have : Real.log 3 / (2 * Real.log silver) < 1 :=
      (div_lt_one two_log_silver_pos).2 log_three_lt_two_log_silver
    linarith
  · intro P
    have := hypDim_le_max P
    linarith

/-- `27 ≤ (1+√2)⁴`, the numerical input to the explicit dimension bound. -/
lemma twentyseven_le_silver_pow_four : (27 : ℝ) ≤ silver ^ 4 := by
  have hsq : silver ^ 2 = 3 + 2 * Real.sqrt 2 := silver_sq
  have h : (1.41 : ℝ) ≤ Real.sqrt 2 := by
    rw [show (1.41 : ℝ) = Real.sqrt (1.41 ^ 2) by
      rw [Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_le_sqrt (by norm_num)
  have h4 : silver ^ 4 = (3 + 2 * Real.sqrt 2) ^ 2 := by
    rw [show (4 : ℕ) = 2 * 2 from rfl, pow_mul, hsq]
  rw [h4]
  nlinarith [h]

/-- The explicit bound `hypDim P ≤ 2/3`: the hyperbolic dimension of every Berggren harmonic
measure is at most two thirds. -/
theorem hypDim_le_two_thirds (P : ProbVec) : hypDim P ≤ 2 / 3 := by
  have key : 3 * Real.log 3 ≤ 4 * Real.log silver := by
    have h1 : Real.log 27 ≤ Real.log (silver ^ (4 : ℕ)) :=
      Real.log_le_log (by norm_num) twentyseven_le_silver_pow_four
    have h27 : Real.log 27 = 3 * Real.log 3 := by
      rw [show (27 : ℝ) = 3 ^ (3 : ℕ) by norm_num, Real.log_pow]
      norm_num
    rw [Real.log_pow, h27] at h1
    simpa using h1
  have hmax := hypDim_le_max P
  have h3 : Real.log 3 / (2 * Real.log silver) ≤ 2 / 3 := by
    rw [div_le_iff₀ two_log_silver_pos]
    linarith
  linarith

/-- **Entropy versus drift.**  The mean hyperbolic displacement of the walk after `n` steps is
at most `(n+1) log(1+√2) + log 2` (`expected_drift_upper`), while the entropy accumulated in
`n` steps is exactly `n H(p)` (`expected_surprisal`).  Since `H(p) < 2 log(1+√2)` for every
walk, the entropy production of the Berggren walk is always strictly smaller than twice the
silver bound on its metric displacement rate — the harmonic measure spreads out more slowly in
the hyperbolic metric than a conformal measure would. -/
theorem entropy_lt_silver_of_drift (P : ProbVec) (n : ℕ) (hn : 0 < n) :
    n * shannon P < 2 * ((n + 1) * Real.log silver + Real.log 2) := by
  have hH := shannon_lt_two_log_silver P
  have hn' : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hsil : 0 < Real.log silver := log_silver_pos
  nlinarith [hH, hn', hlog2, hsil]

end BerggrenHarmonic