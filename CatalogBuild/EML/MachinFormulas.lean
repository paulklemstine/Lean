/-! # CatalogBuild.EML.MachinFormulas

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.MachinFormulas
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16] -/
def spbM (x y : ℝ) : ℝ := (x + y) / (1 - x * y)



/-- Euler's π formula via SPB: spb(1/2, 1/3) = 1. -/
theorem euler_spb_pi : spbM (1/2) (1/3) = 1 := by
  unfold spbM; norm_num



/-- spb(1/3, 1/3) = 3/4. -/
theorem hutton_double : spbM (1/3) (1/3) = 3/4 := by
  unfold spbM; norm_num



/-- spb(3/4, 1/7) = 1. -/
theorem hutton_spb_pi : spbM (3/4) (1/7) = 1 := by
  unfold spbM; norm_num



/-- Full Hutton verification: spb(spb(1/3, 1/3), 1/7) = 1. -/
theorem hutton_full : spbM (spbM (1/3) (1/3)) (1/7) = 1 := by
  unfold spbM; norm_num



/-- Step 1 of Machin: spb(1/5, 1/5) = 5/12. -/
theorem machin_step1 : spbM (1/5) (1/5) = 5/12 := by
  unfold spbM; norm_num



/-- Step 2: spb(5/12, 5/12) = 120/119. -/
theorem machin_step2 : spbM (5/12) (5/12) = 120/119 := by
  unfold spbM; norm_num



/-- Step 3: spb(120/119, -1/239) = 1. -/
theorem machin_step3 : spbM (120/119) (-1/239) = 1 := by
  unfold spbM; norm_num



/-- Machin's formula assembled: spb(spb(spb(1/5, 1/5), spb(1/5, 1/5)), -1/239) = 1.
This encodes: 4·arctan(1/5) - arctan(1/239) = π/4. -/
theorem machin_full :
    spbM (spbM (spbM (1/5) (1/5)) (spbM (1/5) (1/5))) (-1/239) = 1 := by
  unfold spbM; norm_num



/-- Størmer step: spb(1/8, 1/8) = 16/63. -/
theorem stormer_step1 : spbM (1/8) (1/8) = 16/63 := by
  unfold spbM; norm_num



theorem arctan_sum_spb (a b : ℝ) (hab : a * b < 1) :
    Real.arctan a + Real.arctan b = Real.arctan (spbM a b) := by
  unfold spbM;
  exact?



/-- If t = p/q is rational, the x-coordinate on S¹ is (q²-p²)/(q²+p²). -/
theorem rational_circle_x (p q : ℤ) (hq : (q : ℝ) ≠ 0)
    (hab : (q : ℝ) ^ 2 + (p : ℝ) ^ 2 ≠ 0) :
    (1 - ((p : ℝ) / q) ^ 2) / (1 + ((p : ℝ) / q) ^ 2) =
    ((q : ℝ) ^ 2 - (p : ℝ) ^ 2) / ((q : ℝ) ^ 2 + (p : ℝ) ^ 2) := by
  field_simp



/-- The y-coordinate on S¹ is 2pq/(q²+p²). -/
theorem rational_circle_y (p q : ℤ) (hq : (q : ℝ) ≠ 0)
    (hab : (q : ℝ) ^ 2 + (p : ℝ) ^ 2 ≠ 0) :
    2 * ((p : ℝ) / q) / (1 + ((p : ℝ) / q) ^ 2) =
    (2 * (p : ℝ) * q) / ((q : ℝ) ^ 2 + (p : ℝ) ^ 2) := by
  field_simp



/-- Gauss's formula building block: spb(1/18, 1/18) = 36/323. -/
theorem gauss_step1 : spbM (1/18) (1/18) = 36/323 := by
  unfold spbM; norm_num



/-- spb(1/2, 1/5) = 7/9. -/
theorem spb_half_fifth : spbM (1/2) (1/5) = 7/9 := by
  unfold spbM; norm_num



/-- spb(1/4, 1/5) = 9/19. -/
theorem spb_quarter_fifth : spbM (1/4) (1/5) = 9/19 := by
  unfold spbM; norm_num



end
