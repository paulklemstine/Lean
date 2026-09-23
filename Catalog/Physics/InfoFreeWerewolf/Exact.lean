/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.Defs

/-!
# Exact closed forms for small wolf counts

We identify the wolf-win probability of the information-free game exactly for
`k = 1, 2, 3` wolves, in terms of the single sequence `surv`.

* `failProb_one_wolf`  : `failProb v 1 = surv (v + 1)` — for one wolf the wolves win
  precisely when that wolf is never lynched, so the answer *is* the survival product.
* `surv_mul_succ`      : `surv (2m) * surv (2m+1) = 1 / (2m+1)` — an exact
  "parity coupling" identity between the two parity subsequences.
* `failProb_two_wolves_even` : `failProb (2m) 2 = 2 * surv (2m+2)`.  With two wolves and
  an **even** population the naive union bound is *exactly* attained.
* `failProb_three_wolves_even` : `failProb (2m+1) 3 = (6m+8)/(2m+3) * surv (2m+4)`; the
  prefactor is a rational function of the population increasing to `3`, so the union
  bound is approached but never attained.

Note the parity asymmetry already visible here: the two-wolf identity holds for even
populations and *fails* for odd ones (`failProb_two_wolves_odd_ne`).
-/

namespace InfoFreeWerewolf

/-! ### One wolf: an exact product formula -/

/-- With a single wolf, the wolves win exactly when that wolf is never lynched, so the
wolf-win probability equals the survival product `surv` of the initial population. -/
theorem failProb_one_wolf : ∀ v : ℕ, failProb v 1 = surv (v + 1)
  | 0 => by simp
  | 1 => by
      rw [failProb_step 0 0]
      norm_num [surv_succ_succ]
  | (v + 2) => by
      rw [failProb_step' v 0, failProb_one_wolf v, failProb_wolfless]
      rw [show v + 2 + 1 = (v + 1) + 2 from rfl, surv_succ_succ]
      push_cast
      field_simp
      ring
termination_by v => v

/-- Village win probability against one wolf. -/
theorem villageWin_one_wolf (v : ℕ) : villageWin v 1 = 1 - surv (v + 1) := by
  rw [villageWin, failProb_one_wolf]

/-! ### The parity coupling identity -/

/-- Consecutive values of `surv` multiply to `1/(n+1)`.  Equivalently, the two parity
subsequences are exact reciprocals up to the factor `n+1`; together with the Wallis
product this identity pins down *both* parity constants. -/
theorem surv_mul_succ_gen : ∀ n : ℕ, surv n * surv (n + 1) = 1 / ((n : ℚ) + 1)
  | 0 => by norm_num
  | (n + 1) => by
      have h := surv_mul_succ_gen n
      rw [show n + 1 + 1 = n + 2 from rfl, surv_succ_succ]
      have hp : (0 : ℚ) < surv n := surv_pos _
      have hq : (0 : ℚ) < surv (n + 1) := surv_pos _
      push_cast
      field_simp at h ⊢
      linear_combination ((n : ℚ) + 2) * h

/-- The even/odd specialisation of `surv_mul_succ_gen`. -/
theorem surv_mul_succ (m : ℕ) : surv (2 * m) * surv (2 * m + 1) = 1 / (2 * (m : ℚ) + 1) := by
  have h := surv_mul_succ_gen (2 * m)
  push_cast at h
  exact h

/-! ### Two wolves -/

/-- **Exact two-wolf formula for even populations.**  When the population `2m+2` is even,
the wolf-win probability with two wolves is exactly twice the single-wolf survival
product: the union bound over the two wolves is tight. -/
theorem failProb_two_wolves_even : ∀ m : ℕ, failProb (2 * m) 2 = 2 * surv (2 * m + 2)
  | 0 => by norm_num [surv_succ_succ]
  | (m + 1) => by
      have h := failProb_two_wolves_even m
      have e2 : 2 * (m + 1) + 2 = (2 * m + 2) + 2 := by omega
      have e1 : 2 * (m + 1) = 2 * m + 2 := by omega
      rw [e2, e1, failProb_step' (2 * m) 1, failProb_one_wolf, h,
        show 2 * m + 1 + 1 = 2 * m + 2 from rfl, surv_succ_succ (2 * m + 2)]
      have hp : (0 : ℚ) < surv (2 * m + 2) := surv_pos _
      push_cast
      field_simp
      ring

/-- The two-wolf identity genuinely fails for odd populations: with `3` villagers and
`2` wolves (population `5`) the wolf-win probability is `13/15`, strictly below the
union bound `2 * surv 5 = 16/15`.  An explicit witness of the parity asymmetry. -/
theorem failProb_two_wolves_odd_ne : failProb 3 2 ≠ 2 * surv 5 := by
  norm_num [failProb, surv]

/-! ### Three wolves -/

/-- **Exact three-wolf formula for even populations.**  The prefactor
`(6m+8)/(2m+3)` is a rational function of the population increasing to `3`. -/
theorem failProb_three_wolves_even : ∀ m : ℕ,
    failProb (2 * m + 1) 3 = (6 * (m : ℚ) + 8) / (2 * (m : ℚ) + 3) * surv (2 * m + 4)
  | 0 => by norm_num [failProb_step, surv_succ_succ]
  | (m + 1) => by
      have h := failProb_three_wolves_even m
      have e1 : 2 * (m + 1) + 1 = (2 * m + 1) + 2 := by omega
      have e2 : 2 * (m + 1) + 4 = (2 * m + 4) + 2 := by omega
      rw [e2, e1, failProb_step' (2 * m + 1) 2, h, surv_succ_succ (2 * m + 4),
        show 2 * m + 1 + 1 = 2 * (m + 1) from by omega, failProb_two_wolves_even (m + 1)]
      have hp : (0 : ℚ) < surv (2 * m + 4) := surv_pos _
      rw [show 2 * (m + 1) + 2 = 2 * m + 4 from by omega]
      push_cast
      field_simp
      ring

end InfoFreeWerewolf