import Mathlib

/-! # CatalogBuild.EML.v8.BerggrenPellRecurrence

Auto-generated from theorem catalog database.
Domain: EML/v8
Declarations: 18
-/

/-- Berggren matrix B₂ -/
def BM2_pell : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Apply B₂ to a triple -/
def applyB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Iteratively apply B₂ starting from (3,4,5) -/
def B2_iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyB2 (B2_iter n).1 (B2_iter n).2.1 (B2_iter n).2.2

/-- Extract the hypotenuse sequence -/
def B2_hyp_seq (n : ℕ) : ℤ := (B2_iter n).2.2

/-- [Section: # CatalogBuild.EML.v8.BerggrenPellRecurrence
Auto-generated from theorem catalog database.
Domain: EML/v8
Declarations: 18] -/
theorem B2_iter_0 : B2_iter 0 = (3, 4, 5) := rfl

/-- [Section: # CatalogBuild.EML.v8.BerggrenPellRecurrence
Auto-generated from theorem catalog database.
Domain: EML/v8
Declarations: 18] -/
theorem B2_iter_1 : B2_iter 1 = (21, 20, 29) := by native_decide

theorem B2_iter_2 : B2_iter 2 = (119, 120, 169) := by native_decide

theorem B2_iter_3 : B2_iter 3 = (697, 696, 985) := by native_decide

theorem B2_iter_4 : B2_iter 4 = (4059, 4060, 5741) := by native_decide

/-- Verify Pell recurrence: c₂ = 6·c₁ - c₀ -/
theorem pell_recurrence_check_1 : (169 : ℤ) = 6 * 29 - 5 := by norm_num

theorem pell_recurrence_check_2 : (985 : ℤ) = 6 * 169 - 29 := by norm_num

theorem pell_recurrence_check_3 : (5741 : ℤ) = 6 * 985 - 169 := by norm_num

/-- B₂³ - 5B₂² - 5B₂ + I = 0 -/
theorem BM2_pell_cayley_hamilton :
    BM2_pell * BM2_pell * BM2_pell - 5 • (BM2_pell * BM2_pell) - 5 • BM2_pell + 1
    = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-- B₂-branch triples have legs differing by exactly 1 -/
theorem B2_leg_diff_0 : (B2_iter 0).2.1 - (B2_iter 0).1 = 1 := by native_decide

theorem B2_leg_diff_1 : (B2_iter 1).1 - (B2_iter 1).2.1 = 1 := by native_decide

theorem B2_leg_diff_2 : (B2_iter 2).2.1 - (B2_iter 2).1 = 1 := by native_decide

theorem B2_leg_diff_3 : (B2_iter 3).1 - (B2_iter 3).2.1 = 1 := by native_decide

/-- (1, -1, 0) is an eigenvector of B₂ with eigenvalue -1 -/
theorem B2_eigenvector_neg1 :
    BM2_pell * !![1; -1; 0] = !![(-1 : ℤ); 1; 0] := by native_decide

