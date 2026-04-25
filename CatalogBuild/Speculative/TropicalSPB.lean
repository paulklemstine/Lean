/-! # CatalogBuild.Speculative.TropicalSPB

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8
-/

import Mathlib

noncomputable section

/-- Tropical SPB of non-negative values: when x, y ≥ 0, tropSPB(x,y) = min(x,y). -/
theorem tropSPB_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tropSPB x y = min x y := by
  simp [tropSPB, min_eq_left (by linarith : (0 : ℝ) ≤ x + y)]


/-- Tropical SPB with 0 on the right, for x ≥ 0: tropSPB(x, 0) = 0. -/
theorem tropSPB_zero_right_nonneg (x : ℝ) (hx : 0 ≤ x) :
    tropSPB x 0 = 0 := by
  simp [tropSPB, min_eq_right hx, min_eq_left (by linarith : (0 : ℝ) ≤ x)]


/-- Tropical SPB with 0 on the left, for y ≥ 0: tropSPB(0, y) = 0. -/
theorem tropSPB_zero_left_nonneg (y : ℝ) (hy : 0 ≤ y) :
    tropSPB 0 y = 0 := by
  rw [tropSPB_comm]; exact tropSPB_zero_right_nonneg y hy


/-- Tropical SPB is always non-negative when both inputs are non-negative. -/
theorem tropSPB_nonneg_result (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    0 ≤ tropSPB x y := by
  rw [tropSPB_nonneg x y hx hy]; exact le_min hx hy


/-- tropSPB(x, x) = x - min(0, 2x) for any x. -/
theorem tropSPB_self (x : ℝ) : tropSPB x x = x - min 0 (2 * x) := by
  simp [tropSPB, ← two_mul]


/-- For x ≥ 0: tropSPB(x, x) = x (idempotent). -/
theorem tropSPB_self_nonneg (x : ℝ) (hx : 0 ≤ x) : tropSPB x x = x := by
  rw [tropSPB_nonneg x x hx hx, min_self]


/-- [Section: # CatalogBuild.Speculative.TropicalSPB
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8] -/
theorem tropSPB_alt (x y : ℝ) :
    tropSPB x y = min x y + max 0 (-(x + y)) := by
  simp [tropSPB]
  cases max_cases ( 0 : ℝ ) ( -y + -x ) <;> cases min_cases ( 0 : ℝ ) ( x + y ) <;> linarith


/-- When x + y ≤ 0: tropSPB(x,y) = min(x,y) - (x+y) = max(-x, -y) -/
theorem tropSPB_neg_sum (x y : ℝ) (h : x + y ≤ 0) :
    tropSPB x y = min x y - (x + y) := by
  simp [tropSPB, min_eq_right h]


end
