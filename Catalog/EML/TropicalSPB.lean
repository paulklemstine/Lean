import Mathlib

/-! # CatalogBuild.EML.TropicalSPB

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

noncomputable section

/-- The tropical SPB: replaces + with min and × with +.
tspb(x, y) = min(x, y) - max(0, x + y)
Motivation: In standard SPB, spb(x,y) = (x+y)/(1-xy).
Tropicalizing: numerator x+y → min(x,y), denominator 1-xy → min(0, -(x+y)) = -max(0, x+y).
Division → subtraction, so tspb(x,y) = min(x,y) - max(0, x+y). -/
def tropSPB (x y : ℝ) : ℝ := min x y - max 0 (x + y)

/-- Tropical SPB is commutative. -/
theorem tropSPB_comm (x y : ℝ) : tropSPB x y = tropSPB y x := by
  simp [tropSPB, min_comm, add_comm]

/-- For negative x, tropSPB(x, 0) = x. -/
theorem tropSPB_zero_neg (x : ℝ) (hx : x < 0) :
    tropSPB x 0 = x := by
  unfold tropSPB
  simp [min_eq_left (le_of_lt hx), max_eq_left (le_of_lt hx)]

/-- Alternative tropical SPB using max instead of min:
tspb_max(x, y) = max(x, y) - max(0, x + y). -/
def tropSPBMax (x y : ℝ) : ℝ := max x y - max 0 (x + y)

/-- The max-tropical SPB is also commutative. -/
theorem tropSPBMax_comm (x y : ℝ) : tropSPBMax x y = tropSPBMax y x := by
  simp [tropSPBMax, max_comm, add_comm]

/-- For negative inputs, tropical SPB has a clean form. -/
theorem tropSPB_neg_neg (x y : ℝ) (hx : x < 0) (hy : y < 0) :
    tropSPB x y = min x y := by
  unfold tropSPB
  have hxy : x + y < 0 := by linarith
  simp [max_eq_left (le_of_lt hxy)]

end
