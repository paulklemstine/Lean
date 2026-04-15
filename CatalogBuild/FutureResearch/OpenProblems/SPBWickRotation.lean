/-! # CatalogBuild.FutureResearch.OpenProblems.SPBWickRotation

Auto-generated from theorem catalog database.
Domain: FutureResearch/OpenProblems
Declarations: 4
-/

import Mathlib

noncomputable section

theorem spb_sum_identity (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spbW x y + spbHW x y = 2 * (x + y) / ((1 - x * y) * (1 + x * y)) := by
  unfold spbW spbHW; field_simp; ring


theorem spb_diff_identity (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spbW x y - spbHW x y = 2 * x * y * (x + y) / ((1 - x * y) * (1 + x * y)) := by
  unfold spbW spbHW; field_simp [hc, hh]; ring


theorem denom_product (x y : ℝ) :
    (1 - x * y) * (1 + x * y) = 1 - (x * y) ^ 2 := by ring


theorem wick_norm_exchange (x : ℝ) : (1 + x ^ 2) + (1 - x ^ 2) = 2 := by ring


end
