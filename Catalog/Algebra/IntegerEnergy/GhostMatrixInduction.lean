import Mathlib
import Pythagorean.ClosedFormAncestor.ClosedFormAncestor

/-! # CatalogBuild.Pythagorean.ClosedFormAncestor.GhostMatrixInduction

Auto-generated from theorem catalog database.
Domain: Pythagorean/ClosedFormAncestor
Declarations: 6
-/

/-- [Section: ### Step relations for Pell sequences] -/
theorem compPell_step (n : ℕ) :
    compPell (n + 1) = compPell n + 2 * pellNum n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
  linarith! [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), pellNum_rec n, pellNum_rec ( n + 1 ), compPell_rec n, compPell_rec ( n + 1 ) ]

theorem pellNum_step (n : ℕ) :
    pellNum (n + 1) = pellNum n + compPell n := by
  induction' n with n ih;
  · rfl;
  · rw [ pellNum_rec, compPell_step ] ; linarith

/-- [Section: ### Quadratic step identities] -/
theorem compPell_sq_step (n : ℕ) :
    compPell (n + 1) ^ 2 = 3 * compPell n ^ 2 + 4 * pellNum n * compPell n - 2 * (-1 : ℤ) ^ n := by
  rw [ ← pell_sq_identity ] ; rw [ compPell_step ] ; ring;

theorem pellNum_compPell_step (n : ℕ) :
    pellNum (n + 1) * compPell (n + 1) =
    3 * pellNum n * compPell n + 2 * compPell n ^ 2 - (-1 : ℤ) ^ n := by
  rw [ pellNum_step, compPell_step ];
  linarith [ pell_sq_identity n ]

/-- [Section: ### The matrix recurrence] -/
theorem ghostMatrix_closed_mul_step (n : ℕ) :
    ghostMatrix_closed n * ghostMatrix = ghostMatrix_closed (n + 1) := by
  unfold ghostMatrix_closed;
  unfold ghostMatrix;
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Fin.sum_univ_succ ] <;> ring;
  all_goals rw [ Nat.add_comm 1 n ] ; simp +decide [ compPell_sq_step, pellNum_compPell_step ] ; ring;

/-- **Main theorem**: M^n = ghostMatrix_closed n for all n ∈ ℕ. -/
theorem ghostMatrix_pow_eq_closed (n : ℕ) :
    ghostMatrix ^ n = ghostMatrix_closed n := by
  induction n with
  | zero =>
    exact ghostMatrix_closed_verified.1
  | succ n ih =>
    rw [pow_succ, ih, ghostMatrix_closed_mul_step]