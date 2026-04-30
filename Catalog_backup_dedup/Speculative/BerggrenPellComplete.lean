import Mathlib

/-! # CatalogBuild.Speculative.BerggrenPellComplete

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 40
-/

/-- Berggren matrix B₂ -/
def B2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Iteratively apply B₂ starting from (3,4,5) -/
def B2iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let prev := B2iter n
    (prev.1 + 2 * prev.2.1 + 2 * prev.2.2,
     2 * prev.1 + prev.2.1 + 2 * prev.2.2,
     2 * prev.1 + 2 * prev.2.1 + 3 * prev.2.2)

/-- Extract hypotenuse -/
def B2hyp (n : ℕ) : ℤ := (B2iter n).2.2

/-- [Section: # CatalogBuild.Speculative.BerggrenPellComplete
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 40] -/
theorem B2iter_0 : B2iter 0 = (3, 4, 5) := rfl

/-- [Section: # CatalogBuild.Speculative.BerggrenPellComplete
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 40] -/
theorem B2iter_1 : B2iter 1 = (21, 20, 29) := by native_decide

theorem B2iter_2 : B2iter 2 = (119, 120, 169) := by native_decide

theorem B2iter_3 : B2iter 3 = (697, 696, 985) := by native_decide

theorem B2iter_4 : B2iter 4 = (4059, 4060, 5741) := by native_decide

theorem B2hyp_0 : B2hyp 0 = 5 := by native_decide

theorem B2hyp_1 : B2hyp 1 = 29 := by native_decide

theorem B2hyp_2 : B2hyp 2 = 169 := by native_decide

theorem B2hyp_3 : B2hyp 3 = 985 := by native_decide

theorem B2hyp_4 : B2hyp 4 = 5741 := by native_decide

theorem pell_rec_0 : B2hyp 2 = 6 * B2hyp 1 - B2hyp 0 := by native_decide

theorem pell_rec_1 : B2hyp 3 = 6 * B2hyp 2 - B2hyp 1 := by native_decide

theorem pell_rec_2 : B2hyp 4 = 6 * B2hyp 3 - B2hyp 2 := by native_decide

theorem B2hyp_mod4_0 : B2hyp 0 % 4 = 1 := by native_decide

theorem B2hyp_mod4_1 : B2hyp 1 % 4 = 1 := by native_decide

theorem B2hyp_mod4_2 : B2hyp 2 % 4 = 1 := by native_decide

theorem B2hyp_mod4_3 : B2hyp 3 % 4 = 1 := by native_decide

theorem B2hyp_mod4_4 : B2hyp 4 % 4 = 1 := by native_decide

/-- B₂-branch triples have legs differing by exactly 1, alternating sign -/
theorem B2_leg_diff_even (n : ℕ) (hn : n % 2 = 0) (hn_lt : n < 5) :
    (B2iter n).2.1 - (B2iter n).1 = 1 := by
  interval_cases n <;> simp_all <;> native_decide

theorem B2_leg_diff_odd (n : ℕ) (hn : n % 2 = 1) (hn_lt : n < 5) :
    (B2iter n).1 - (B2iter n).2.1 = 1 := by
  interval_cases n <;> simp_all <;> native_decide

theorem B2iter_pyth_0 : (B2iter 0).1^2 + (B2iter 0).2.1^2 = (B2iter 0).2.2^2 := by native_decide

theorem B2iter_pyth_1 : (B2iter 1).1^2 + (B2iter 1).2.1^2 = (B2iter 1).2.2^2 := by native_decide

theorem B2iter_pyth_2 : (B2iter 2).1^2 + (B2iter 2).2.1^2 = (B2iter 2).2.2^2 := by native_decide

theorem B2iter_pyth_3 : (B2iter 3).1^2 + (B2iter 3).2.1^2 = (B2iter 3).2.2^2 := by native_decide

theorem B2iter_pyth_4 : (B2iter 4).1^2 + (B2iter 4).2.1^2 = (B2iter 4).2.2^2 := by native_decide

/-- (1, -1, 0) is an eigenvector of B₂ with eigenvalue -1 -/
theorem B2_eigenvec_neg1 :
    B2 * !![( 1 : ℤ); -1; 0] = !![-1; 1; 0] := by native_decide

/-- (1, 1, √2) would be the eigenvector for eigenvalue 3+2√2,
but since √2 is irrational, we verify the characteristic polynomial instead -/
theorem B2_char_poly_roots :
    ∀ x : ℤ, x^3 - 5*x^2 - 5*x + 1 = (x + 1) * (x^2 - 6*x + 1) := by
  intro x; ring

/-- The Pell numbers P_n satisfy x² - 2y² = 1 -/
def pellSeq : ℕ → ℤ × ℤ
  | 0 => (1, 0)
  | n + 1 => (3 * (pellSeq n).1 + 4 * (pellSeq n).2,
              2 * (pellSeq n).1 + 3 * (pellSeq n).2)

theorem pell_0 : pellSeq 0 = (1, 0) := rfl

theorem pell_1 : pellSeq 1 = (3, 2) := by native_decide

theorem pell_2 : pellSeq 2 = (17, 12) := by native_decide

theorem pell_3 : pellSeq 3 = (99, 70) := by native_decide

-- Verify Pell equation x² - 2y² = 1

theorem pell_eq_0 : (pellSeq 0).1^2 - 2 * (pellSeq 0).2^2 = 1 := by native_decide

theorem pell_eq_1 : (pellSeq 1).1^2 - 2 * (pellSeq 1).2^2 = 1 := by native_decide

theorem pell_eq_2 : (pellSeq 2).1^2 - 2 * (pellSeq 2).2^2 = 1 := by native_decide

theorem pell_eq_3 : (pellSeq 3).1^2 - 2 * (pellSeq 3).2^2 = 1 := by native_decide

/-- The Pell equation is preserved by the recurrence -/
theorem pell_preserved (x y : ℤ) (h : x^2 - 2 * y^2 = 1) :
    (3 * x + 4 * y)^2 - 2 * (2 * x + 3 * y)^2 = 1 := by nlinarith [h]

