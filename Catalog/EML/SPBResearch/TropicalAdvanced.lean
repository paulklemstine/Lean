/-! # CatalogBuild.EML.SPBResearch.TropicalAdvanced

Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 5
-/

import Mathlib

noncomputable section

/-- tspb(x, 0) = -|x| (there is no identity element for tropical SPB) -/
theorem tspb_zero_right (x : ℝ) : tspb x 0 = -|x| := by
  simp only [tspb, add_zero]
  rcases le_or_gt x 0 with hx | hx
  · simp [min_eq_left hx, max_eq_left hx, abs_of_nonpos hx]
  · simp [min_eq_right (le_of_lt hx), max_eq_right (le_of_lt hx), abs_of_pos hx]



/-- tspb(0, x) = -|x| -/
theorem tspb_zero_left (x : ℝ) : tspb 0 x = -|x| := by
  rw [tspb_comm]; exact tspb_zero_right x



/-- tspb(x, y) ≤ min(x, y) -/
theorem tspb_le_min (x y : ℝ) : tspb x y ≤ min x y := by
  unfold tspb; linarith [le_max_left 0 (x + y)]



/-- tspb is always ≤ 0 when both arguments are non-negative -/
theorem tspb_nonpos_of_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tspb x y ≤ 0 := by
  rw [tspb_nonneg x y hx hy]; linarith [le_max_left x y]



/-- tspb is idempotent: tspb(tspb(x,y), tspb(x,y)) = -|tspb(x,y)| -/
theorem tspb_idem (x y : ℝ) :
    tspb (tspb x y) (tspb x y) = -|tspb x y| :=
  tspb_self (tspb x y)



end
