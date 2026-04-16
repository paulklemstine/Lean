import Mathlib

/-! # Advanced Tropical SPB Theory

The tropical SPB: tspb(x, y) = min(x, y) - max(0, x + y)

Key discoveries:
- tspb(x, 0) = -|x| (there is no identity element)
- tspb(x, -x) = -|x|
- tspb(x, x) = -|x|
- For x,y ≥ 0: tspb(x,y) = -max(x,y)
- For x,y ≤ 0: tspb(x,y) = min(x,y)
- Associativity and commutativity hold
-/

noncomputable section

/-- The tropical SPB: tspb(x, y) = min(x, y) - max(0, x + y) -/
def tspb (x y : ℝ) : ℝ := min x y - max 0 (x + y)

/-- tspb is commutative -/
theorem tspb_comm (x y : ℝ) : tspb x y = tspb y x := by
  simp [tspb, min_comm, add_comm]

/-- tspb(x, 0) = -|x| (there is no identity element for tropical SPB) -/
theorem tspb_zero_right (x : ℝ) : tspb x 0 = -|x| := by
  simp only [tspb, add_zero]
  rcases le_or_gt x 0 with hx | hx
  · simp [min_eq_left hx, max_eq_left hx, abs_of_nonpos hx]
  · simp [min_eq_right (le_of_lt hx), max_eq_right (le_of_lt hx), abs_of_pos hx]

/-- tspb(0, x) = -|x| -/
theorem tspb_zero_left (x : ℝ) : tspb 0 x = -|x| := by
  rw [tspb_comm]; exact tspb_zero_right x

/-- tspb(x, -x) = -|x| -/
theorem tspb_neg_self (x : ℝ) : tspb x (-x) = -|x| := by
  simp only [tspb, add_neg_cancel, max_self]
  rcases le_or_gt x 0 with hx | hx
  · simp [min_eq_left (by linarith : x ≤ -x), abs_of_nonpos hx]
  · simp [min_eq_right (by linarith : -x ≤ x), abs_of_pos hx]

/-- tspb(x, x) = -|x| -/
theorem tspb_self (x : ℝ) : tspb x x = -|x| := by
  simp only [tspb, min_self]
  rcases le_or_gt x 0 with hx | hx
  · simp [max_eq_left (by linarith : 2 * x ≤ 0), abs_of_nonpos hx]; linarith
  · simp [max_eq_right (by linarith : 0 ≤ x + x), abs_of_pos hx]

/-- tspb(-x, -y) = tspb(x, y) -/
theorem tspb_neg_neg (x y : ℝ) : tspb (-x) (-y) = tspb x y := by
  simp only [tspb, min_def, max_def]
  split_ifs <;> linarith

/-- Concrete: tspb(2, 3) = -3 -/
theorem tspb_2_3 : tspb 2 3 = -3 := by norm_num [tspb]

/-- tspb(-1, -2) = -2 -/
theorem tspb_neg1_neg2 : tspb (-1) (-2) = -2 := by norm_num [tspb]

/-- tspb(1, -1) = -1 -/
theorem tspb_1_neg1 : tspb 1 (-1) = -1 := by norm_num [tspb]

/-- For x, y both non-negative: tspb(x,y) = -max(x,y) -/
theorem tspb_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tspb x y = -max x y := by
  simp only [tspb, min_def, max_def]
  split_ifs <;> linarith

/-- For x, y both non-positive: tspb(x,y) = min(x,y) -/
theorem tspb_nonpos (x y : ℝ) (hx : x ≤ 0) (hy : y ≤ 0) :
    tspb x y = min x y := by
  simp only [tspb, max_def]
  split_ifs <;> linarith

/-- tspb is associative -/
theorem tspb_assoc (x y z : ℝ) : tspb (tspb x y) z = tspb x (tspb y z) := by
  simp only [tspb, min_def, max_def]
  split_ifs <;> linarith

/-- The tropical quadruple: tspb(tspb(x,x), tspb(x,x)) = -|x| -/
theorem tspb_quadruple (x : ℝ) : tspb (tspb x x) (tspb x x) = -|x| := by
  rw [tspb_self, tspb_self, abs_neg, abs_abs]

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
