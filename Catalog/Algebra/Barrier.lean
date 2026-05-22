/-
# Logarithmic Barrier Lemmas

This module proves foundational properties of the logarithmic barrier function
  b_c(y) = 1 - c / log(y + 2)
which defines the boundary of zero-free regions for zeta-like functions.

Key results:
- `log_pos_of_nonneg_add_two`: log(y + 2) > 0 for y ≥ 0
- `barrier_lt_one`: b_c(y) < 1
- `log_barrier_mono`: monotonicity of the barrier
- `barrier_tendsto_one`: the barrier tends to 1 as y → ∞
-/

import Mathlib

open Real Filter Topology

/-! ## Positivity of log(y + 2) -/

/-
For y ≥ 0, we have log(y + 2) > 0, since y + 2 ≥ 2 > 1.
-/
theorem log_pos_of_nonneg_add_two {y : ℝ} (hy : 0 ≤ y) :
    0 < Real.log (y + 2) := by
  exact Real.log_pos ( by linarith )

/-! ## The barrier is strictly less than 1 -/

/-
For c > 0 and y ≥ 0, the barrier value 1 - c/log(y+2) is strictly less than 1.
-/
theorem barrier_lt_one {c y : ℝ} (hc : 0 < c) (hy : 0 ≤ y) :
    1 - c / Real.log (y + 2) < 1 := by
  exact sub_lt_self _ ( div_pos hc ( Real.log_pos ( by linarith ) ) )

/-! ## Monotonicity of the logarithmic barrier -/

/-
**Barrier Monotonicity.** If 0 < c and 0 ≤ y₁ ≤ y₂, then
  1 - c/log(y₁+2) ≤ 1 - c/log(y₂+2).

This is the certified geometric fact that the zero-free boundary moves
rightward (toward Re(s) = 1) as height increases. It underlies every
strip/region inclusion argument in zero-free region theory.
-/
theorem log_barrier_mono
    {c y₁ y₂ : ℝ}
    (hc : 0 < c)
    (hy₁ : 0 ≤ y₁)
    (h12 : y₁ ≤ y₂) :
    1 - c / Real.log (y₁ + 2) ≤ 1 - c / Real.log (y₂ + 2) := by
  gcongr;
  exact Real.log_pos <| by linarith

/-! ## The barrier tends to 1 -/

/-
**Barrier Limit.** As y → ∞, the barrier 1 - c/log(y+2) → 1.
This means the zero-free region approaches (but never reaches) the critical line Re(s) = 1.

Interpretation: the admissible nonvanishing region approaches the critical line
as frequency grows. This is conceptually parallel to high-frequency stability
barriers in PDE and statistical mechanics.
-/
theorem barrier_tendsto_one {c : ℝ} (_hc : 0 < c) :
    Tendsto (fun y : ℝ => 1 - c / Real.log (y + 2)) atTop (𝓝 1) := by
  exact le_trans ( tendsto_const_nhds.sub ( tendsto_const_nhds.div_atTop ( Real.tendsto_log_atTop.comp <| tendsto_id.atTop_add tendsto_const_nhds ) ) ) ( by norm_num )

/-! ## Exponential decay lemma -/

/-
The function exp(-B · √(log x)) tends to 0 as x → ∞, for any B > 0.
This is the key decay rate appearing in the prime number theorem error term.
-/
theorem exp_neg_sqrt_log_decay
    {B : ℝ} (hB : 0 < B) :
    Tendsto (fun x : ℝ => Real.exp (-B * Real.sqrt (Real.log x))) atTop (𝓝 0) := by
  norm_num [ Real.sqrt_eq_rpow ];
  exact Filter.Tendsto.const_mul_atTop hB ( tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| Real.tendsto_log_atTop )