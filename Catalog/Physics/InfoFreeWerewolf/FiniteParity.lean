/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.Asymptotics

/-!
# Non-asymptotic parity separation, and the exact ladder up to four wolves

The asymptotic results of `Asymptotics.lean` show that the scaled wolf-win probability
oscillates between two limits differing by the factor `π/2`.  Here we prove that the
separation is already visible **at every finite population size**, with a completely
elementary, rational-arithmetic certificate, and we extend the exact closed-form ladder
to four wolves.

## Main results

* `surv_even_le_odd` : `surv (2m) ≤ surv (2m+1)`, the elementary comparison
  `(2j-1)/(2j) < (2j)/(2j+1)` propagated along the ladder.
* `surv_sq_even_lt` / `one_le_surv_sq_odd` : the *separator* `1`.  For every `m`,
  `n · surv n ^ 2 < 1` when `n = 2m` and `n · surv n ^ 2 ≥ 1` when `n = 2m+1`.
  This is a finite-`n` proof of the parity dichotomy: the quantity
  `n · (wolf-win probability)^2` sits on opposite sides of `1` according to parity,
  for *every* population, not merely in the limit.
* `failProb_sq_parity_even` / `failProb_sq_parity_odd` : the same dichotomy stated
  directly for the one-wolf game.
* `failProb_four_wolves_even` : `failProb (2M) 4 = (8M+8)/(2M+3) · surv (2M+4)`,
  the fourth rung of the exact ladder (after `k = 1, 2, 3` in `Exact.lean`).

## Lab notes

The section `LabNotes` records exact machine-checked values of the game for
populations `7 … 20`, the data that motivated the conjecture.
-/

namespace InfoFreeWerewolf

/-! ### The elementary parity comparison -/

/-- The even survival product never exceeds the odd one:
`∏_{j≤m} (2j-1)/(2j) ≤ ∏_{j≤m} (2j)/(2j+1)`. -/
theorem surv_even_le_odd : ∀ m : ℕ, surv (2 * m) ≤ surv (2 * m + 1)
  | 0 => by norm_num
  | (m + 1) => by
      have h := surv_even_le_odd m
      have hp : (0 : ℚ) < surv (2 * m) := surv_pos _
      have hq : (0 : ℚ) < surv (2 * m + 1) := surv_pos _
      rw [show 2 * (m + 1) + 1 = (2 * m + 1) + 2 from by omega,
        show 2 * (m + 1) = (2 * m) + 2 from by omega, surv_succ_succ, surv_succ_succ]
      push_cast
      rw [div_le_div_iff₀ (by positivity) (by positivity)]
      nlinarith [mul_le_mul_of_nonneg_right h
        (show (0 : ℚ) ≤ (2 * (m : ℚ) + 1) * (2 * (m : ℚ) + 3) by positivity), hq.le]

/-- Even populations sit **below** the separator: `(2m+1) · surv(2m)^2 ≤ 1`. -/
theorem surv_sq_even_le (m : ℕ) : (2 * (m : ℚ) + 1) * surv (2 * m) ^ 2 ≤ 1 := by
  have h := surv_even_le_odd m
  have hm := surv_mul_succ m
  have hp : (0 : ℚ) < surv (2 * m) := surv_pos _
  have hkey : surv (2 * m) ^ 2 ≤ surv (2 * m) * surv (2 * m + 1) := by nlinarith
  rw [hm] at hkey
  have hne : (0 : ℚ) < 2 * (m : ℚ) + 1 := by positivity
  calc (2 * (m : ℚ) + 1) * surv (2 * m) ^ 2 ≤ (2 * (m : ℚ) + 1) * (1 / (2 * (m : ℚ) + 1)) := by
        nlinarith
    _ = 1 := by field_simp

/-- Odd populations sit **above** the separator: `(2m+1) · surv(2m+1)^2 ≥ 1`. -/
theorem one_le_surv_sq_odd (m : ℕ) : 1 ≤ (2 * (m : ℚ) + 1) * surv (2 * m + 1) ^ 2 := by
  have h := surv_even_le_odd m
  have hm := surv_mul_succ m
  have hq : (0 : ℚ) < surv (2 * m + 1) := surv_pos _
  have hkey : surv (2 * m) * surv (2 * m + 1) ≤ surv (2 * m + 1) ^ 2 := by nlinarith
  rw [hm] at hkey
  have hne : (0 : ℚ) < 2 * (m : ℚ) + 1 := by positivity
  calc (1 : ℚ) = (2 * (m : ℚ) + 1) * (1 / (2 * (m : ℚ) + 1)) := by field_simp
    _ ≤ (2 * (m : ℚ) + 1) * surv (2 * m + 1) ^ 2 := by nlinarith

/-- Sharper even-population form, with the population itself as the scaling factor. -/
theorem surv_sq_even_lt (m : ℕ) : 2 * (m : ℚ) * surv (2 * m) ^ 2 < 1 := by
  have h := surv_sq_even_le m
  have hp : (0 : ℚ) < surv (2 * m) := surv_pos _
  nlinarith

/-! ### The dichotomy for the one-wolf game -/

/-- **Finite-population parity separation, even case.**  For a population `2m` with one
wolf, `population · (wolf-win probability)^2 < 1`. -/
theorem failProb_sq_parity_even (m : ℕ) :
    2 * (m : ℚ) * failProb (2 * m - 1) 1 ^ 2 < 1 := by
  rcases Nat.eq_zero_or_pos m with hm | hm
  · subst hm; norm_num
  · have hidx : (2 * m - 1) + 1 = 2 * m := by omega
    have h : failProb (2 * m - 1) 1 = surv (2 * m) := by
      rw [failProb_one_wolf, hidx]
    rw [h]
    exact surv_sq_even_lt m

/-- **Finite-population parity separation, odd case.**  For a population `2m+1` with one
wolf, `population · (wolf-win probability)^2 ≥ 1`. -/
theorem failProb_sq_parity_odd (m : ℕ) :
    1 ≤ (2 * (m : ℚ) + 1) * failProb (2 * m) 1 ^ 2 := by
  rw [failProb_one_wolf]
  exact one_le_surv_sq_odd m

/-! ### The fourth rung of the exact ladder -/

/-- **Exact four-wolf formula for even populations.**  The prefactor `(8M+8)/(2M+3)`
is again a rational function of the population, increasing to `4`. -/
theorem failProb_four_wolves_even : ∀ M : ℕ,
    failProb (2 * M) 4 = (8 * (M : ℚ) + 8) / (2 * (M : ℚ) + 3) * surv (2 * M + 4)
  | 0 => by norm_num [failProb, surv]
  | (M + 1) => by
      have h := failProb_four_wolves_even M
      have h3 := failProb_three_wolves_even M
      rw [show 2 * (M + 1) + 4 = (2 * M + 4) + 2 from by omega,
        show 2 * (M + 1) = (2 * M) + 2 from by omega, failProb_step' (2 * M) 3, h, h3,
        surv_succ_succ (2 * M + 4)]
      have hp : (0 : ℚ) < surv (2 * M + 4) := surv_pos _
      push_cast
      field_simp
      ring

/-! ### Lab notes: exact values for populations 7 to 20

These are the machine-checked exact rational values that motivated the conjecture.
Writing `n` for the population and `k` for the wolf count, the entries are
`failProb (n - k) k`, the wolf-win probability.  The even/odd oscillation of
`n · failProb^2` around `1` is visible immediately.
-/

section LabNotes

/-- One wolf, populations 7 through 12 (`v = n - 1` villagers). -/
theorem lab_one_wolf_7_to_12 :
    failProb 6 1 = 16 / 35 ∧ failProb 7 1 = 35 / 128 ∧ failProb 8 1 = 128 / 315 ∧
      failProb 9 1 = 63 / 256 ∧ failProb 10 1 = 256 / 693 ∧ failProb 11 1 = 231 / 1024 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [failProb]

/-- Two wolves, populations 7 through 10. -/
theorem lab_two_wolves :
    failProb 5 2 = 27 / 35 ∧ failProb 6 2 = 35 / 64 ∧ failProb 7 2 = 221 / 315 ∧
      failProb 8 2 = 63 / 128 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [failProb]

/-- Three wolves, populations 7 through 10. -/
theorem lab_three_wolves :
    failProb 4 3 = 33 / 35 ∧ failProb 5 3 = 25 / 32 ∧ failProb 6 3 = 31 / 35 ∧
      failProb 7 3 = 91 / 128 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [failProb]

/-- The oscillation, exhibited on the one-wolf data for populations 7 through 12:
`n · failProb^2` is `> 1` for odd `n` and `< 1` for even `n`. -/
theorem lab_oscillation_one_wolf :
    1 < (7 : ℚ) * failProb 6 1 ^ 2 ∧ (8 : ℚ) * failProb 7 1 ^ 2 < 1 ∧
      1 < (9 : ℚ) * failProb 8 1 ^ 2 ∧ (10 : ℚ) * failProb 9 1 ^ 2 < 1 ∧
      1 < (11 : ℚ) * failProb 10 1 ^ 2 ∧ (12 : ℚ) * failProb 11 1 ^ 2 < 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [failProb]

/-- Populations 19 and 20 with two wolves: the union bound `2 · surv` is *exactly*
attained at the even population `20` and strictly missed at the odd population `19`. -/
theorem lab_union_bound_sharpness :
    failProb 18 2 = 2 * surv 20 ∧ failProb 17 2 < 2 * surv 19 := by
  constructor
  · norm_num [failProb, surv]
  · norm_num [failProb, surv]

end LabNotes

end InfoFreeWerewolf