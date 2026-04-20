import Mathlib
import Pythagorean.ClosedFormAncestor.ClosedFormAncestor

/-!
# Inductive Proof of the Ghost Matrix Closed Form

We prove M^n = ghostMatrix_closed n for all n ∈ ℕ by induction.

## Strategy
We show ghostMatrix_closed(n) * ghostMatrix = ghostMatrix_closed(n+1)
using two key Pell-number identities derived from:
  - H_{n+1} = H_n + 2·P_n
  - P_{n+1} = P_n + H_n
  - H_n² - 2·P_n² = (-1)^n
-/

open Matrix ClosedFormAncestor

namespace GhostMatrixInduction

/-! ### Step relations for Pell sequences -/

/-
H_{n+1} = H_n + 2·P_n (companion Pell in terms of Pell pair)
-/
theorem compPell_step (n : ℕ) :
    compPell (n + 1) = compPell n + 2 * pellNum n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
  linarith! [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), pellNum_rec n, pellNum_rec ( n + 1 ), compPell_rec n, compPell_rec ( n + 1 ) ]

/-
P_{n+1} = P_n + H_n (Pell in terms of Pell pair)
-/
theorem pellNum_step (n : ℕ) :
    pellNum (n + 1) = pellNum n + compPell n := by
  induction' n with n ih;
  · rfl;
  · rw [ pellNum_rec, compPell_step ] ; linarith

/-! ### Quadratic step identities -/

/-
H_{n+1}² = 3·H_n² + 4·P_n·H_n - 2·(-1)^n
-/
theorem compPell_sq_step (n : ℕ) :
    compPell (n + 1) ^ 2 = 3 * compPell n ^ 2 + 4 * pellNum n * compPell n - 2 * (-1 : ℤ) ^ n := by
  rw [ ← pell_sq_identity ] ; rw [ compPell_step ] ; ring;

/-
P_{n+1}·H_{n+1} = 3·P_n·H_n + 2·H_n² - (-1)^n
-/
theorem pellNum_compPell_step (n : ℕ) :
    pellNum (n + 1) * compPell (n + 1) =
    3 * pellNum n * compPell n + 2 * compPell n ^ 2 - (-1 : ℤ) ^ n := by
  rw [ pellNum_step, compPell_step ];
  linarith [ pell_sq_identity n ]

/-! ### The matrix recurrence -/

/-
The closed-form satisfies the recurrence for right-multiplication by M.
-/
theorem ghostMatrix_closed_mul_step (n : ℕ) :
    ghostMatrix_closed n * ghostMatrix = ghostMatrix_closed (n + 1) := by
  unfold ghostMatrix_closed;
  unfold ghostMatrix;
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Fin.sum_univ_succ ] <;> ring;
  all_goals rw [ Nat.add_comm 1 n ] ; simp +decide [ compPell_sq_step, pellNum_compPell_step ] ; ring;

/-! ### Main theorem -/

/-- **Main theorem**: M^n = ghostMatrix_closed n for all n ∈ ℕ. -/
theorem ghostMatrix_pow_eq_closed (n : ℕ) :
    ghostMatrix ^ n = ghostMatrix_closed n := by
  induction n with
  | zero =>
    exact ghostMatrix_closed_verified.1
  | succ n ih =>
    rw [pow_succ, ih, ghostMatrix_closed_mul_step]

end GhostMatrixInduction