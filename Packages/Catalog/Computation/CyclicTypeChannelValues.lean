import Computation.CyclicTypeChannel

/-!
# Exact values of the cyclic splitting-type channel

Closed forms, obtained by exact finite enumeration over the cyclic group `ℤ/n`, for
the semiprime type-pair capacity `I_pair(n)`, the type entropy `H(T)`, and the binary
root-count entropy `H(nr)`, for the cyclic orders
`n = 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20`.

All values are exact elements of `ℚ + ℚ·log₂3 + ℚ·log₂5 + ℚ·log₂7 + ℚ·log₂11 + ℚ·log₂13`.
-/

set_option maxRecDepth 40000
set_option maxHeartbeats 1000000

namespace CyclicType

/-! ## Exact channel values -/

/-- `C₂ = ℚ(√5)`: the binary symmetric fork sits exactly at the 1-bit cap. -/
theorem Ipair_two : Ipair 2 = 1 := by
  rw [Ipair_eval (n := 2) (by norm_num) [1, 2, 1] [[1, 0, 1], [0, 2, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4]

/-- `C₄ = ℚ(ζ₅)`: the type-pair channel carries exactly `5/4` bits, above the 1-bit cap. -/
theorem Ipair_four : Ipair 4 = 5 / 4 := by
  rw [Ipair_eval (n := 4) (by norm_num) [1, 2, 1, 4, 4, 4]
    [[1, 0, 1, 0, 0, 2], [0, 0, 0, 2, 2, 0], [0, 2, 0, 0, 0, 2], [0, 0, 0, 2, 2, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_16]

/-- `C₆ = ℚ(ζ₇)`: the type-pair channel carries exactly `log₂ 3 - 1/9` bits. -/
theorem Ipair_six : Ipair 6 = -(1 / 9) + Real.logb 2 3 := by
  rw [Ipair_eval (n := 6) (by norm_num) [1, 2, 1, 4, 4, 4, 4, 4, 8, 4]
    [[1, 0, 1, 0, 0, 2, 0, 0, 0, 2], [0, 0, 0, 0, 2, 0, 2, 0, 2, 0],
     [0, 0, 0, 2, 0, 1, 0, 2, 0, 1], [0, 2, 0, 0, 0, 0, 0, 0, 4, 0],
     [0, 0, 0, 2, 0, 1, 0, 2, 0, 1], [0, 0, 0, 0, 2, 0, 2, 0, 2, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_6, lb_36]
  ring


/-- Exact type-pair channel capacity for the cyclic order 3. -/
theorem Ipair_three : Ipair 3 = (-(10 / 9)) + 1 * Real.logb 2 3 := by
  rw [Ipair_eval (n := 3) (by norm_num) [1, 4, 4]
    [[1, 0, 2],
     [0, 2, 1],
     [0, 2, 1]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_9]
  ring

/-- Exact type-pair channel capacity for the cyclic order 5. -/
theorem Ipair_five : Ipair 5 = (-(72 / 25)) + (12 / 25) * Real.logb 2 3 + 1 * Real.logb 2 5 := by
  rw [Ipair_eval (n := 5) (by norm_num) [1, 8, 16]
    [[1, 0, 4],
     [0, 2, 3],
     [0, 2, 3],
     [0, 2, 3],
     [0, 2, 3]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_16, lb_25]
  ring

/-- Exact type-pair channel capacity for the cyclic order 8. -/
theorem Ipair_eight : Ipair 8 = (21 / 16) := by
  rw [Ipair_eval (n := 8) (by norm_num) [1, 2, 1, 4, 4, 4, 8, 8, 16, 16]
    [[1, 0, 1, 0, 0, 2, 0, 0, 0, 4],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0],
     [0, 0, 0, 2, 2, 0, 0, 0, 0, 4],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0],
     [0, 2, 0, 0, 0, 2, 0, 0, 0, 4],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0],
     [0, 0, 0, 2, 2, 0, 0, 0, 0, 4],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_16, lb_64]

/-- Exact type-pair channel capacity for the cyclic order 10. -/
theorem Ipair_ten : Ipair 10 = (-(47 / 25)) + (12 / 25) * Real.logb 2 3 + 1 * Real.logb 2 5 := by
  rw [Ipair_eval (n := 10) (by norm_num) [1, 2, 1, 8, 8, 16, 8, 8, 32, 16]
    [[1, 0, 1, 0, 0, 4, 0, 0, 0, 4],
     [0, 0, 0, 0, 2, 0, 2, 0, 6, 0],
     [0, 0, 0, 2, 0, 3, 0, 2, 0, 3],
     [0, 0, 0, 0, 2, 0, 2, 0, 6, 0],
     [0, 0, 0, 2, 0, 3, 0, 2, 0, 3],
     [0, 2, 0, 0, 0, 0, 0, 0, 8, 0],
     [0, 0, 0, 2, 0, 3, 0, 2, 0, 3],
     [0, 0, 0, 0, 2, 0, 2, 0, 6, 0],
     [0, 0, 0, 2, 0, 3, 0, 2, 0, 3],
     [0, 0, 0, 0, 2, 0, 2, 0, 6, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_6, lb_8, lb_10, lb_16, lb_32, lb_100]
  ring

/-- Exact type-pair channel capacity for the cyclic order 12. -/
theorem Ipair_twelve : Ipair 12 = (5 / 36) + 1 * Real.logb 2 3 := by
  rw [Ipair_eval (n := 12) (by norm_num) [1, 2, 1, 4, 4, 4, 4, 4, 8, 4, 4, 4, 8, 8, 4, 8, 8, 16, 16, 16, 16]
    [[1, 0, 1, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 4],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 2, 2, 2, 0, 2, 0],
     [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 4, 0, 2],
     [0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 4, 0],
     [0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 4, 0, 2],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 2, 2, 2, 0, 2, 0],
     [0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 4],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 2, 2, 2, 0, 2, 0],
     [0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 4, 0, 2],
     [0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 4, 0],
     [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 4, 0, 2],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 2, 2, 2, 0, 2, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_12, lb_16, lb_144]
  ring

/-- Exact type-pair channel capacity for the cyclic order 14. -/
theorem Ipair_fourteen : Ipair 14 = (-(29 / 49)) + (-(78 / 49)) * Real.logb 2 3 + (30 / 49) * Real.logb 2 5 + 1 * Real.logb 2 7 := by
  rw [Ipair_eval (n := 14) (by norm_num) [1, 2, 1, 12, 12, 36, 12, 12, 72, 36]
    [[1, 0, 1, 0, 0, 6, 0, 0, 0, 6],
     [0, 0, 0, 0, 2, 0, 2, 0, 10, 0],
     [0, 0, 0, 2, 0, 5, 0, 2, 0, 5],
     [0, 0, 0, 0, 2, 0, 2, 0, 10, 0],
     [0, 0, 0, 2, 0, 5, 0, 2, 0, 5],
     [0, 0, 0, 0, 2, 0, 2, 0, 10, 0],
     [0, 0, 0, 2, 0, 5, 0, 2, 0, 5],
     [0, 2, 0, 0, 0, 0, 0, 0, 12, 0],
     [0, 0, 0, 2, 0, 5, 0, 2, 0, 5],
     [0, 0, 0, 0, 2, 0, 2, 0, 10, 0],
     [0, 0, 0, 2, 0, 5, 0, 2, 0, 5],
     [0, 0, 0, 0, 2, 0, 2, 0, 10, 0],
     [0, 0, 0, 2, 0, 5, 0, 2, 0, 5],
     [0, 0, 0, 0, 2, 0, 2, 0, 10, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_6, lb_10, lb_12, lb_14, lb_36, lb_72, lb_196]
  ring

/-- Exact type-pair channel capacity for the cyclic order 15. -/
theorem Ipair_fifteen : Ipair 15 = (-(898 / 225)) + (37 / 25) * Real.logb 2 3 + 1 * Real.logb 2 5 := by
  rw [Ipair_eval (n := 15) (by norm_num) [1, 4, 4, 8, 16, 16, 16, 32, 64, 64]
    [[1, 0, 2, 0, 0, 4, 0, 0, 0, 8],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 0, 0, 2, 0, 3, 0, 4, 0, 6],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 2, 1, 0, 0, 0, 0, 0, 8, 4],
     [0, 0, 0, 2, 0, 3, 0, 4, 0, 6],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 0, 0, 2, 0, 3, 0, 4, 0, 6],
     [0, 2, 1, 0, 0, 0, 0, 0, 8, 4],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 0, 0, 2, 0, 3, 0, 4, 0, 6],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3],
     [0, 0, 0, 0, 2, 0, 2, 2, 6, 3]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_6, lb_8, lb_15, lb_16, lb_32, lb_64, lb_225]
  ring

/-- Exact type-pair channel capacity for the cyclic order 16. -/
theorem Ipair_sixteen : Ipair 16 = (85 / 64) := by
  rw [Ipair_eval (n := 16) (by norm_num) [1, 2, 1, 4, 4, 4, 8, 8, 16, 16, 16, 16, 32, 64, 64]
    [[1, 0, 1, 0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 0, 0, 2, 2, 0, 0, 0, 0, 4, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 2, 0, 0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 0, 0, 2, 2, 0, 0, 0, 0, 4, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0],
     [0, 0, 0, 0, 0, 0, 2, 2, 4, 0, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 8, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_16, lb_32, lb_64, lb_256]

theorem HT_three : HT 3 = (-(2 / 3)) + 1 * Real.logb 2 3 := by
  rw [HT_eval (n := 3) (by norm_num) [1, 2] (by decide) (by decide)]
  norm_num [SL, lb_2]
  ring

theorem HT_four : HT 4 = (3 / 2) := by
  rw [HT_eval (n := 4) (by norm_num) [1, 1, 2] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4]

theorem HT_five : HT 5 = (-(8 / 5)) + 1 * Real.logb 2 5 := by
  rw [HT_eval (n := 5) (by norm_num) [1, 4] (by decide) (by decide)]
  norm_num [SL, lb_4]
  ring

theorem HT_six : HT 6 = (1 / 3) + 1 * Real.logb 2 3 := by
  rw [HT_eval (n := 6) (by norm_num) [1, 1, 2, 2] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_6]
  ring

theorem HT_eight : HT 8 = (7 / 4) := by
  rw [HT_eval (n := 8) (by norm_num) [1, 1, 2, 4] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8]

theorem HT_ten : HT 10 = (-(3 / 5)) + 1 * Real.logb 2 5 := by
  rw [HT_eval (n := 10) (by norm_num) [1, 1, 4, 4] (by decide) (by decide)]
  norm_num [SL, lb_4, lb_10]
  ring

theorem HT_twelve : HT 12 = (5 / 6) + 1 * Real.logb 2 3 := by
  rw [HT_eval (n := 12) (by norm_num) [1, 1, 2, 2, 2, 4] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_12]
  ring

theorem HT_fourteen : HT 14 = (1 / 7) + (-(6 / 7)) * Real.logb 2 3 + 1 * Real.logb 2 7 := by
  rw [HT_eval (n := 14) (by norm_num) [1, 1, 6, 6] (by decide) (by decide)]
  norm_num [SL, lb_6, lb_14]
  ring

theorem HT_fifteen : HT 15 = (-(34 / 15)) + 1 * Real.logb 2 3 + 1 * Real.logb 2 5 := by
  rw [HT_eval (n := 15) (by norm_num) [1, 2, 4, 8] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_15]
  ring

theorem HT_sixteen : HT 16 = (15 / 8) := by
  rw [HT_eval (n := 16) (by norm_num) [1, 1, 2, 4, 8] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_16]

theorem Hnr_four : Hnr 4 = 2 + (-(3 / 4)) * Real.logb 2 3 := by
  rw [Hnr_eval (n := 4) (by norm_num) [1, 3] (by decide) (by decide)]
  norm_num [SL, lb_4]
  ring

theorem Hnr_six : Hnr 6 = 1 + 1 * Real.logb 2 3 + (-(5 / 6)) * Real.logb 2 5 := by
  rw [Hnr_eval (n := 6) (by norm_num) [1, 5] (by decide) (by decide)]
  norm_num [SL, lb_6]
  ring


/-- Exact type-pair channel capacity for the cyclic order 7. -/
theorem Ipair_seven : Ipair 7 = (-(78 / 49)) + (-(78 / 49)) * Real.logb 2 3 + (30 / 49) * Real.logb 2 5 + 1 * Real.logb 2 7 := by
  rw [Ipair_eval (n := 7) (by norm_num) [1, 12, 36]
    [[1, 0, 6],
     [0, 2, 5],
     [0, 2, 5],
     [0, 2, 5],
     [0, 2, 5],
     [0, 2, 5],
     [0, 2, 5]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_6, lb_12, lb_36, lb_49]
  ring

theorem HT_seven : HT 7 = (-(6 / 7)) + (-(6 / 7)) * Real.logb 2 3 + 1 * Real.logb 2 7 := by
  rw [HT_eval (n := 7) (by norm_num) [1, 6] (by decide) (by decide)]
  norm_num [SL, lb_6]
  ring

/-- Exact type-pair channel capacity for the cyclic order 9. -/
theorem Ipair_nine : Ipair 9 = (-(100 / 81)) + (10 / 9) * Real.logb 2 3 := by
  rw [Ipair_eval (n := 9) (by norm_num) [1, 4, 4, 12, 24, 36]
    [[1, 0, 2, 0, 0, 6],
     [0, 0, 0, 2, 4, 3],
     [0, 0, 0, 2, 4, 3],
     [0, 2, 1, 0, 0, 6],
     [0, 0, 0, 2, 4, 3],
     [0, 0, 0, 2, 4, 3],
     [0, 2, 1, 0, 0, 6],
     [0, 0, 0, 2, 4, 3],
     [0, 0, 0, 2, 4, 3]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_6, lb_9, lb_12, lb_24, lb_36, lb_81]
  ring

/-- Exact type-pair channel capacity for the cyclic order 18. -/
theorem Ipair_eighteen : Ipair 18 = (-(19 / 81)) + (10 / 9) * Real.logb 2 3 := by
  rw [Ipair_eval (n := 18) (by norm_num) [1, 2, 1, 4, 4, 4, 4, 4, 8, 4, 12, 12, 24, 24, 36, 12, 12, 24, 24, 72, 36]
    [[1, 0, 1, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 2, 0, 4, 0, 6, 0],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 3, 0, 2, 0, 4, 0, 3],
     [0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 0],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 3, 0, 2, 0, 4, 0, 3],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 2, 0, 4, 0, 6, 0],
     [0, 0, 0, 2, 0, 1, 0, 2, 0, 1, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 2, 0, 4, 0, 6, 0],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 3, 0, 2, 0, 4, 0, 3],
     [0, 2, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 0],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 3, 0, 2, 0, 4, 0, 3],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 2, 0, 4, 0, 6, 0],
     [0, 0, 0, 2, 0, 1, 0, 2, 0, 1, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 2, 0, 4, 0, 6, 0],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 3, 0, 2, 0, 4, 0, 3],
     [0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 0],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 3, 0, 2, 0, 4, 0, 3],
     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 4, 0, 2, 0, 4, 0, 6, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_6, lb_8, lb_12, lb_18, lb_24, lb_36, lb_72, lb_324]
  ring

/-- Exact type-pair channel capacity for the cyclic order 20. -/
theorem Ipair_twenty : Ipair 20 = (-(163 / 100)) + (12 / 25) * Real.logb 2 3 + 1 * Real.logb 2 5 := by
  rw [Ipair_eval (n := 20) (by norm_num) [1, 2, 1, 4, 4, 4, 8, 8, 16, 16, 8, 8, 16, 32, 16, 16, 16, 32, 64, 64, 64]
    [[1, 0, 1, 0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 6, 0, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0],
     [0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 6, 0, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 8],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 6, 0, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0],
     [0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0],
     [0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 6, 0, 0, 0, 4, 0, 0, 6],
     [0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 2, 2, 0, 6, 6, 0]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_6, lb_8, lb_16, lb_20, lb_32, lb_64, lb_400]
  ring

theorem HT_nine : HT 9 = (-(8 / 9)) + (4 / 3) * Real.logb 2 3 := by
  rw [HT_eval (n := 9) (by norm_num) [1, 2, 6] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_6, lb_9]
  ring

theorem HT_eighteen : HT 18 = (1 / 9) + (4 / 3) * Real.logb 2 3 := by
  rw [HT_eval (n := 18) (by norm_num) [1, 1, 2, 2, 6, 6] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_6, lb_18]
  ring

theorem HT_twenty : HT 20 = (-(1 / 10)) + 1 * Real.logb 2 5 := by
  rw [HT_eval (n := 20) (by norm_num) [1, 1, 2, 4, 4, 8] (by decide) (by decide)]
  norm_num [SL, lb_2, lb_4, lb_8, lb_20]
  ring

/-- Exact type-pair channel capacity for the cyclic order 11. -/
theorem Ipair_eleven : Ipair 11 = (-(210 / 121)) + (180 / 121) * Real.logb 2 3 + (-(210 / 121)) * Real.logb 2 5 + 1 * Real.logb 2 11 := by
  rw [Ipair_eval (n := 11) (by norm_num) [1, 20, 100]
    [[1, 0, 10],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9],
     [0, 2, 9]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_9, lb_10, lb_20, lb_100, lb_121]
  ring

/-- Exact type-pair channel capacity for the cyclic order 13. -/
theorem Ipair_thirteen : Ipair 13 = (-(600 / 169)) + (-(300 / 169)) * Real.logb 2 3 + (132 / 169) * Real.logb 2 11 + 1 * Real.logb 2 13 := by
  rw [Ipair_eval (n := 13) (by norm_num) [1, 24, 144]
    [[1, 0, 12],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11],
     [0, 2, 11]]
    (by decide) (by decide) (by decide) (by decide)]
  norm_num [SL, lb_2, lb_12, lb_24, lb_144, lb_169]
  ring

theorem HT_eleven : HT 11 = (-(10 / 11)) + (-(10 / 11)) * Real.logb 2 5 + 1 * Real.logb 2 11 := by
  rw [HT_eval (n := 11) (by norm_num) [1, 10] (by decide) (by decide)]
  norm_num [SL, lb_10]
  ring

theorem HT_thirteen : HT 13 = (-(24 / 13)) + (-(12 / 13)) * Real.logb 2 3 + 1 * Real.logb 2 13 := by
  rw [HT_eval (n := 13) (by norm_num) [1, 12] (by decide) (by decide)]
  norm_num [SL, lb_12]
  ring

end CyclicType