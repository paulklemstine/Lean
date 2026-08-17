/-
# The exact certified seed count at the measured frequency: 47 seeds, machine-checked

`Probability.SeedCondorcetConvergence` certified the NET-48 centre to within `1 %` at `73`
seeds using the crude rate, and `Probability.SeedSharpRate` cut that to `49` with the
middle-binomial bound.  This file computes the **exact** low tail of the binomial at the
measured per-seed frequency `p = 2/3` and settles the certified count:

* `SeedExactCrossing.miss_47_le_one_percent` — a `47`-seed ensemble read at its median rung
  misses certainty with probability `< 1 %`;
* `SeedExactCrossing.miss_45_gt_one_percent` — a `45`-seed ensemble does not;
* `SeedExactCrossing.certified_iff_at_least_47` — hence, by the Condorcet ladder, `47` is the
  least odd ensemble whose median rung is `1 %`-certified, and every larger odd ensemble is.

Consequently the sharpened bound of `Probability.SeedSharpRate` (`49`) is tight to within a
single ladder step — two seeds — where the crude bound (`73`) was thirteen steps away.  The
binomial coefficients are evaluated through `Nat.choose_eq_descFactorial_div_factorial`, which
computes in linearly many steps, rather than by unfolding Pascal's recursion.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence

namespace SeedExactCrossing

open Finset SeedQuota SeedCondorcet SeedCondorcetRate

/-! ## 1.  The binomial coefficients of the two rows, computed efficiently -/

private theorem c47_0 : Nat.choose 47 0 = 1 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_1 : Nat.choose 47 1 = 47 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_2 : Nat.choose 47 2 = 1081 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_3 : Nat.choose 47 3 = 16215 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_4 : Nat.choose 47 4 = 178365 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_5 : Nat.choose 47 5 = 1533939 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_6 : Nat.choose 47 6 = 10737573 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_7 : Nat.choose 47 7 = 62891499 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_8 : Nat.choose 47 8 = 314457495 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_9 : Nat.choose 47 9 = 1362649145 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_10 : Nat.choose 47 10 = 5178066751 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_11 : Nat.choose 47 11 = 17417133617 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_12 : Nat.choose 47 12 = 52251400851 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_13 : Nat.choose 47 13 = 140676848445 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_14 : Nat.choose 47 14 = 341643774795 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_15 : Nat.choose 47 15 = 751616304549 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_16 : Nat.choose 47 16 = 1503232609098 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_17 : Nat.choose 47 17 = 2741188875414 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_18 : Nat.choose 47 18 = 4568648125690 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_19 : Nat.choose 47 19 = 6973199770790 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_20 : Nat.choose 47 20 = 9762479679106 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_21 : Nat.choose 47 21 = 12551759587422 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_22 : Nat.choose 47 22 = 14833897694226 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c47_23 : Nat.choose 47 23 = 16123801841550 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_0 : Nat.choose 45 0 = 1 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_1 : Nat.choose 45 1 = 45 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_2 : Nat.choose 45 2 = 990 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_3 : Nat.choose 45 3 = 14190 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_4 : Nat.choose 45 4 = 148995 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_5 : Nat.choose 45 5 = 1221759 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_6 : Nat.choose 45 6 = 8145060 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_7 : Nat.choose 45 7 = 45379620 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_8 : Nat.choose 45 8 = 215553195 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_9 : Nat.choose 45 9 = 886163135 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_10 : Nat.choose 45 10 = 3190187286 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_11 : Nat.choose 45 11 = 10150595910 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_12 : Nat.choose 45 12 = 28760021745 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_13 : Nat.choose 45 13 = 73006209045 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_14 : Nat.choose 45 14 = 166871334960 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_15 : Nat.choose 45 15 = 344867425584 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_16 : Nat.choose 45 16 = 646626422970 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_17 : Nat.choose 45 17 = 1103068603890 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_18 : Nat.choose 45 18 = 1715884494940 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_19 : Nat.choose 45 19 = 2438362177020 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_20 : Nat.choose 45 20 = 3169870830126 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_21 : Nat.choose 45 21 = 3773655750150 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem c45_22 : Nat.choose 45 22 = 4116715363800 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

/-! ## 2.  The exact low tails -/

/-- **A 47-seed ensemble is certified.**  At the measured per-seed frequency `p = 2/3` the
median rung of `47` seeds misses certainty with probability below `1 %`. -/
theorem miss_47_le_one_percent : 1 - rungProb 47 24 (2/3 : ℝ) ≤ 1/100 := by
  rw [one_sub_rungProb 47 24 (2/3 : ℝ) (by norm_num)]
  norm_num [Finset.sum_range_succ, c47_0, c47_1, c47_2, c47_3, c47_4, c47_5, c47_6, c47_7, c47_8, c47_9, c47_10, c47_11, c47_12, c47_13, c47_14, c47_15, c47_16, c47_17, c47_18, c47_19, c47_20, c47_21, c47_22, c47_23]

/-- **A 45-seed ensemble is not.**  The exact miss probability of `45` seeds exceeds `1 %`, so
no smaller odd ensemble is certified either. -/
theorem miss_45_gt_one_percent : (1/100 : ℝ) < 1 - rungProb 45 23 (2/3 : ℝ) := by
  rw [one_sub_rungProb 45 23 (2/3 : ℝ) (by norm_num)]
  norm_num [Finset.sum_range_succ, c45_0, c45_1, c45_2, c45_3, c45_4, c45_5, c45_6, c45_7, c45_8, c45_9, c45_10, c45_11, c45_12, c45_13, c45_14, c45_15, c45_16, c45_17, c45_18, c45_19, c45_20, c45_21, c45_22]

/-! ## 3.  The crossing -/

/-- **47 is exactly the certified seed count.**  Every odd ensemble of `47` or more seeds is
`1 %`-certified at the measured frequency (by the Condorcet ladder), and `45` seeds are not.
The sharpened bound of `Probability.SeedSharpRate` names `49`: one ladder step of slack, where
the crude bound of `Probability.SeedCondorcetConvergence` had thirteen. -/
theorem certified_iff_at_least_47 :
    (∀ s : ℕ, 23 ≤ s → 1 - rungProb (2 * s + 1) (s + 1) (2/3 : ℝ) ≤ 1/100) ∧
      ¬ (1 - rungProb (2 * 22 + 1) (22 + 1) (2/3 : ℝ) ≤ 1/100) := by
  constructor
  · intro s hs
    have hlad := condorcet_ladder (p := (2/3 : ℝ)) (by norm_num) (by norm_num) hs
    have h47 : rungProb (2 * 23 + 1) (23 + 1) (2/3 : ℝ) = rungProb 47 24 (2/3 : ℝ) := by
      norm_num
    have hbase := miss_47_le_one_percent
    rw [h47] at hlad
    linarith
  · have h45 : rungProb (2 * 22 + 1) (22 + 1) (2/3 : ℝ) = rungProb 45 23 (2/3 : ℝ) := by
      norm_num
    rw [h45]
    have := miss_45_gt_one_percent
    linarith

end SeedExactCrossing