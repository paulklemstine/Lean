/-! # CatalogBuild.EML.SPBExtended.TangentIteration

Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 17
-/

import Mathlib

noncomputable section

/-- The SPB operator -/
def spbT (x y : ℝ) : ℝ := (x + y) / (1 - x * y)


/-- SPB quintuple formula: verified by concrete computation.
The general proof requires handling nested fractions with 5 levels of SPB composition. -/
theorem spb_quintuple_check : spbT (spbT (spbT (1/10) (1/10)) (spbT (1/10) (1/10))) (1/10) =
    (5 * (1/10) - 10 * (1/10) ^ 3 + (1/10) ^ 5) / (1 - 10 * (1/10) ^ 2 + 5 * (1/10) ^ 4) := by
  norm_num [spbT]


/-- Machin's formula as SPB -/
theorem machin_spb :
    spbT (spbT (spbT (1/5) (1/5)) (spbT (1/5) (1/5))) (-1/239) = 1 := by
  norm_num [spbT]


/-- Gregory-Leibniz: spb(1/2, 1/3) = 1 -/
theorem gregory_leibniz_spb : spbT (1/2) (1/3) = 1 := by norm_num [spbT]


/-- spb(1/8, 1/8) = 16/63 -/
theorem spb_eighth : spbT (1/8) (1/8) = 16/63 := by norm_num [spbT]


/-- The Weierstrass substitution identity -/
theorem weierstrass_sin' (t : ℝ) :
    (2 * t) ^ 2 + (1 - t ^ 2) ^ 2 = (1 + t ^ 2) ^ 2 := by ring


/-- orbit_2(1/5) = 5/12 -/
theorem orbit_2_fifth : spbT (1/5) (1/5) = 5/12 := by norm_num [spbT]


/-- orbit_4(1/5) = 120/119 -/
theorem orbit_4_fifth : spbT (5/12) (5/12) = 120/119 := by norm_num [spbT]


/-- Period-4 orbit: spb⁴(0, 1) = 0 -/
theorem spb_period_4_check :
    spbT (spbT (spbT (spbT 0 1) 1) 1) 1 = 0 := by norm_num [spbT]


/-- Ramanujan-Machin equivalence -/
theorem ramanujan_machin_equiv :
    spbT (1/2) (1/3) =
    spbT (spbT (spbT (1/5) (1/5)) (spbT (1/5) (1/5))) (-1/239) := by
  norm_num [spbT]


/-- Hermann step 1: spb(1/2, 1/2) = 4/3 -/
theorem hermann_step1 : spbT (1/2) (1/2) = 4/3 := by norm_num [spbT]


/-- Hermann step 2: spb(4/3, -1/7) = 1 -/
theorem hermann_step2 : spbT (4/3) (-1/7) = 1 := by norm_num [spbT]


/-- Hutton step 1: spb(1/3, 1/3) = 3/4 -/
theorem hutton_step1' : spbT (1/3) (1/3) = 3/4 := by norm_num [spbT]


/-- Strassnitzky step 1: spb(1/2, 1/5) = 7/9 -/
theorem strassnitzky_step1 : spbT (1/2) (1/5) = 7/9 := by norm_num [spbT]


/-- Strassnitzky step 2: spb(7/9, 1/8) = 1 -/
theorem strassnitzky_step2 : spbT (7/9) (1/8) = 1 := by norm_num [spbT]


/-- The SPB power series -/
theorem spb_power_series (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spbT x y = (x + y) * (1 / (1 - x * y)) := by
  unfold spbT; field_simp


/-- spb(x, 0) = x -/
theorem spb_period_1_zero (x : ℝ) : spbT x 0 = x := by simp [spbT]


end
