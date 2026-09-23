/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.ParityExpansion

/-!
# The second-order parity correction: the exact `1/n` term

`Asymptotics.lean` and `ParityExpansion.lean` establish the *first*-order parity
dichotomy: the rescaled wolf-win probability `√n · failProb (n-k) k` converges to
`k·√(2/π)` along even populations and to `k·√(π/2)` along odd populations.

This file goes one order further.  Write

`defect v k = k · surv (v+k) - failProb v k`

for the gap between the union bound `k · surv n` (`failProb_le_union`) and the true
wolf-win probability.  `Bounds.lean` shows `0 ≤ defect v k = O(1/n)`.  Here we compute the
`1/n` coefficient **exactly**, for two and three wolves, and find that it too is
parity-split — in the sharpest possible way, since for two wolves it is a *rational
constant*:

| wolves | even population `n` | odd population `n` |
|---|---|---|
| `k = 2` | `n · defect = 0` | `n · defect = 1` |
| `k = 3` | `n · defect = surv (n-2) → 0` | `n · defect = 3` |
| `k = 4` | `n · defect = 4 · surv (n-2) → 0` | (not computed here) |

In particular, for **two wolves the game is solved exactly**:
`failProb (n-2) 2 = 2·surv n` if `n` is even, and `= 2·surv n - 1/n` if `n` is odd.

## Main results

* `failProb_two_wolves_odd`, `failProb_three_wolves_odd` : new exact closed forms on the
  odd-population ladder (the even ladder was done in `Exact.lean`/`FiniteParity.lean`).
* `defect_two_wolves_even/odd`, `defect_three_wolves_even/odd`, `defect_four_wolves_even` :
  the exact `1/n` coefficients.
* `two_wolves_exact_solution` : the complete exact solution of the two-wolf game.
* `second_order_parity_dichotomy_two_wolves`,
  `second_order_parity_dichotomy_three_wolves` : the packaged second-order statements.
* `tendsto_surv_even_pop_zero` : the survival product tends to `0`.
-/

namespace InfoFreeWerewolf

open Filter Topology Real

/-! ### New exact closed forms on the odd-population ladder -/

/-- **Two wolves, odd population.**  With `n = 2m+3` players the wolf-win probability is
the union bound `2·surv n` minus *exactly* `1/n`. -/
theorem failProb_two_wolves_odd : ∀ m : ℕ,
    failProb (2 * m + 1) 2 = 2 * surv (2 * m + 3) - 1 / (2 * (m : ℚ) + 3)
  | 0 => by norm_num [failProb, surv]
  | (m + 1) => by
      have h := failProb_two_wolves_odd m
      have h1 : failProb (2 * m + 1 + 1) 1 = surv (2 * m + 3) := by
        rw [failProb_one_wolf]
      have hp : (0 : ℚ) < surv (2 * m + 3) := surv_pos _
      rw [show 2 * (m + 1) + 1 = (2 * m + 1) + 2 from by omega, failProb_step' (2 * m + 1) 1,
        h1, h, show 2 * (m + 1) + 3 = (2 * m + 3) + 2 from by omega, surv_succ_succ (2 * m + 3)]
      push_cast
      field_simp
      ring

/-- **Three wolves, odd population.**  With `n = 2m+3` players the wolf-win probability is
the union bound `3·surv n` minus *exactly* `3/n`. -/
theorem failProb_three_wolves_odd : ∀ m : ℕ,
    failProb (2 * m) 3 = 3 * surv (2 * m + 3) - 3 / (2 * (m : ℚ) + 3)
  | 0 => by norm_num [failProb, surv]
  | (m + 1) => by
      have h := failProb_three_wolves_odd m
      have h2 := failProb_two_wolves_odd m
      have hp : (0 : ℚ) < surv (2 * m + 3) := surv_pos _
      rw [show 2 * (m + 1) = (2 * m) + 2 from by omega, failProb_step' (2 * m) 2, h2, h,
        show 2 * m + 2 + 3 = (2 * m + 3) + 2 from by omega, surv_succ_succ (2 * m + 3)]
      push_cast
      field_simp
      ring

/-! ### The defect and its exact `1/n` coefficient -/

/-- The gap between the union bound `k · surv n` and the true wolf-win probability. -/
def defect (v k : ℕ) : ℚ := (k : ℚ) * surv (v + k) - failProb v k

theorem defect_nonneg (v k : ℕ) : 0 ≤ defect v k := by
  have := failProb_le_union v k
  simpa [defect] using this

/-- Two wolves at an **even** population: the union bound is exactly attained. -/
theorem defect_two_wolves_even (m : ℕ) : defect (2 * m) 2 = 0 := by
  have h := failProb_two_wolves_even m
  simp only [defect]
  rw [show 2 * m + 2 = 2 * m + 2 from rfl, h]
  push_cast
  ring

/-- Two wolves at an **odd** population `n = 2m+3`: the defect is exactly `1/n`. -/
theorem defect_two_wolves_odd (m : ℕ) :
    (2 * (m : ℚ) + 3) * defect (2 * m + 1) 2 = 1 := by
  have h := failProb_two_wolves_odd m
  have hne : (2 * (m : ℚ) + 3) ≠ 0 := by positivity
  simp only [defect]
  rw [show 2 * m + 1 + 2 = 2 * m + 3 from by omega, h]
  push_cast
  field_simp
  ring

/-- Three wolves at an **odd** population `n = 2m+3`: the defect is exactly `3/n`. -/
theorem defect_three_wolves_odd (m : ℕ) :
    (2 * (m : ℚ) + 3) * defect (2 * m) 3 = 3 := by
  have h := failProb_three_wolves_odd m
  have hne : (2 * (m : ℚ) + 3) ≠ 0 := by positivity
  simp only [defect]
  rw [show 2 * m + 3 = 2 * m + 3 from rfl, h]
  push_cast
  field_simp
  ring

/-- Three wolves at an **even** population `n = 2m+4`: the defect coefficient is
`surv (n-2)`, which is *not* constant — it tends to `0`. -/
theorem defect_three_wolves_even (m : ℕ) :
    (2 * (m : ℚ) + 4) * defect (2 * m + 1) 3 = surv (2 * m + 2) := by
  have h := failProb_three_wolves_even m
  have hs : surv (2 * m + 4) = surv (2 * m + 2) * (2 * (m : ℚ) + 3) / (2 * (m : ℚ) + 4) := by
    rw [show 2 * m + 4 = (2 * m + 2) + 2 from by omega, surv_succ_succ (2 * m + 2)]
    push_cast
    ring
  simp only [defect]
  rw [show 2 * m + 1 + 3 = 2 * m + 4 from by omega, h, hs]
  push_cast
  field_simp
  ring

/-- Four wolves at an **even** population `n = 2M+4`: the defect coefficient is
`4 · surv (n-2)`, again tending to `0`. -/
theorem defect_four_wolves_even (M : ℕ) :
    (2 * (M : ℚ) + 4) * defect (2 * M) 4 = 4 * surv (2 * M + 2) := by
  have h := failProb_four_wolves_even M
  have hs : surv (2 * M + 4) = surv (2 * M + 2) * (2 * (M : ℚ) + 3) / (2 * (M : ℚ) + 4) := by
    rw [show 2 * M + 4 = (2 * M + 2) + 2 from by omega, surv_succ_succ (2 * M + 2)]
    push_cast
    ring
  simp only [defect]
  rw [show 2 * M + 4 = 2 * M + 4 from rfl, h, hs]
  push_cast
  field_simp
  ring

/-! ### The two-wolf game, solved exactly -/

/-- **Complete exact solution of the two-wolf information-free game.**  For every
population the wolf-win probability equals the union bound `2·surv n` corrected by a term
that is `0` at even populations and exactly `-1/n` at odd populations.  The parity trace is
therefore visible in closed form, with no asymptotics at all. -/
theorem two_wolves_exact_solution (m : ℕ) :
    failProb (2 * m) 2 = 2 * surv (2 * m + 2) ∧
      failProb (2 * m + 1) 2 = 2 * surv (2 * m + 3) - 1 / (2 * (m : ℚ) + 3) :=
  ⟨failProb_two_wolves_even m, failProb_two_wolves_odd m⟩

/-! ### The survival product vanishes, and the three-wolf even coefficient with it -/

/-- The survival product along even populations tends to `0`. -/
theorem tendsto_surv_even_pop_zero :
    Tendsto (fun m : ℕ => ((surv (2 * m) : ℚ) : ℝ)) atTop (𝓝 0) := by
  have hsq : Tendsto (fun m : ℕ => ((surv (2 * m) : ℚ) : ℝ) ^ 2) atTop (𝓝 0) := by
    have h1 : Tendsto (fun m : ℕ => (2 * (m : ℝ) + 1) * ((surv (2 * m) : ℚ) : ℝ) ^ 2) atTop
        (𝓝 (2 / π)) := tendsto_scaled_sq_even
    have h2 := h1.mul tendsto_inv_2m1
    simp only [mul_zero] at h2
    refine h2.congr fun m => ?_
    have hne : (2 * (m : ℝ) + 1) ≠ 0 := by positivity
    field_simp
  have := hsq.sqrt
  simp only [Real.sqrt_zero] at this
  refine this.congr fun m => ?_
  exact Real.sqrt_sq (surv_nonneg_real _)

/-- The survival product along odd populations tends to `0`. -/
theorem tendsto_surv_odd_pop_zero :
    Tendsto (fun m : ℕ => ((surv (2 * m + 1) : ℚ) : ℝ)) atTop (𝓝 0) := by
  have h := tendsto_scaled_surv_odd_pop.mul
    ((Real.tendsto_sqrt_atTop.comp tendsto_2m1_atTop).inv_tendsto_atTop)
  simp only [mul_zero] at h
  refine h.congr fun m => ?_
  have hpos : (0 : ℝ) < Real.sqrt (2 * (m : ℝ) + 1) := Real.sqrt_pos.2 (by positivity)
  simp only [Pi.inv_apply, Function.comp_apply]
  field_simp

/-- Three wolves at even populations: the `1/n` coefficient tends to `0`, in contrast with
the constant value `3` on odd populations. -/
theorem tendsto_defect_three_wolves_even :
    Tendsto (fun m : ℕ => ((2 * (m : ℚ) + 4) * defect (2 * m + 1) 3 : ℚ) : ℕ → ℝ) atTop
      (𝓝 0) := by
  have h : Tendsto (fun m : ℕ => ((surv (2 * m + 2) : ℚ) : ℝ)) atTop (𝓝 0) := by
    have := tendsto_surv_even_pop_zero.comp (tendsto_add_atTop_nat 1)
    refine this.congr fun m => ?_
    have e : 2 * (m + 1) = 2 * m + 2 := by omega
    simp only [Function.comp_apply, e]
  refine h.congr fun m => ?_
  rw [defect_three_wolves_even m]

/-! ### The packaged second-order dichotomies -/

/-- **Second-order parity dichotomy, two wolves.**  The coefficient of `1/n` in
`failProb (n-2) 2 = 2·surv n - c(n)/n` is exactly `0` at even populations and exactly `1`
at odd populations: a sharp, non-asymptotic, purely rational separation. -/
theorem second_order_parity_dichotomy_two_wolves (m : ℕ) :
    (2 * (m : ℚ) + 2) * defect (2 * m) 2 = 0 ∧
      (2 * (m : ℚ) + 3) * defect (2 * m + 1) 2 = 1 :=
  ⟨by rw [defect_two_wolves_even m, mul_zero], defect_two_wolves_odd m⟩

/-- **Second-order parity dichotomy, three wolves.**  The coefficient of `1/n` is the
constant `3` at odd populations, while at even populations it is `surv (n-2)`, a positive
quantity tending to `0`.  So the two parity classes have genuinely different `1/n` terms,
the odd one being of order `1` and the even one of order `n^{-1/2}`. -/
theorem second_order_parity_dichotomy_three_wolves :
    (∀ m : ℕ, (2 * (m : ℚ) + 3) * defect (2 * m) 3 = 3) ∧
      (∀ m : ℕ, 0 < (2 * (m : ℚ) + 4) * defect (2 * m + 1) 3) ∧
      Tendsto (fun m : ℕ => ((2 * (m : ℚ) + 4) * defect (2 * m + 1) 3 : ℚ) : ℕ → ℝ) atTop
        (𝓝 0) :=
  ⟨defect_three_wolves_odd,
    fun m => by rw [defect_three_wolves_even m]; exact surv_pos _,
    tendsto_defect_three_wolves_even⟩

end InfoFreeWerewolf