import Mathlib

/-! # Generalized cycle-decomposition thresholds -/

namespace C5Decomp

/-- The generalized Nash--Williams threshold for a cycle of length `l`. -/
noncomputable def nwThreshold (l : ℕ) : ℝ := (l : ℝ) / (2 * (l : ℝ) - 2)

/-- Every cycle threshold of length at least two is strictly above one half. -/
theorem nwThreshold_gt_half (l : ℕ) (hl : 2 ≤ l) :
    (1 : ℝ) / 2 < nwThreshold l := by
  rw [nwThreshold]
  have hlr : (2 : ℝ) ≤ l := by exact_mod_cast hl
  have hpos : (0 : ℝ) < 2 * (l : ℝ) - 2 := by linarith
  rw [div_lt_div_iff₀ (by norm_num : (0 : ℝ) < 2) hpos]
  linarith

/-- The threshold at cycle length five is `5/8`. -/
theorem nwThreshold_five : nwThreshold 5 = (5 : ℝ) / 8 := by
  norm_num [nwThreshold]

end C5Decomp