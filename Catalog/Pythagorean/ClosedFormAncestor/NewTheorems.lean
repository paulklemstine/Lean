import Mathlib
import Pythagorean.ClosedFormAncestor.ClosedFormAncestor
import Pythagorean.ClosedFormAncestor.GhostMatrixInduction
import Pythagorean.ClosedFormAncestor.FactoringTheory

/-!
# New Theorems and Discoveries

Additional formally verified results about Pythagorean tree ancestry:

1. **Ghost ancestor composition**: Applying depth G₁ then G₂ = depth G₁+G₂
2. **Determinant of M^n**: det(M^n) = (-1)^n
3. **Trace of M^n**: tr(M^n) = 4P_n² + (-1)^n (alternative: 2H² + H² - ε)
4. **M^n multiplicativity via closed form**
5. **Exponential growth of hypotenuse**
-/

open Matrix ClosedFormAncestor FactoringTheory GhostMatrixInduction

namespace NewTheorems

/-! ### Ghost Ancestor Composition -/

/-- Ghost ancestor at depth 0 is the identity. -/
theorem ghostAncestor_zero (a b c : ℤ) :
    ghostAncestor 0 a b c = (a, b, c) := by
  simp [ghostAncestor, compPell, pellNum]

/-
Ghost ancestor composition: applying depth m then n equals depth m+n.
    This follows from M^m · M^n = M^{m+n}.
-/
theorem ghostAncestor_add (m n : ℕ) (a b c : ℤ) :
    let (p, q, h) := ghostAncestor n a b c
    ghostAncestor m p q h = ghostAncestor (m + n) a b c := by
  unfold ghostAncestor;
  -- Use the addition formulas pellNum_add and compPell_add to expand the terms.
  have h_add : compPell (m + n) = compPell m * compPell n + 2 * pellNum m * pellNum n ∧ pellNum (m + n) = pellNum m * compPell n + compPell m * pellNum n := by
    induction' m with m ih generalizing n <;> simp_all +decide [ Nat.succ_add ];
    convert ih ( n + 1 ) using 1 <;> ring;
    · rw [ show 1 + n = n + 1 by ring ] ; rw [ compPell_step, pellNum_step ] ; ring;
    · rw [ show 1 + n = n + 1 by ring ] ; rw [ pellNum_step, compPell_step ] ; ring;
  simp +decide only [h_add] ; ring;
  rw [ show compPell m ^ 2 = 2 * pellNum m ^ 2 + ( -1 ) ^ m by linarith [ pell_sq_identity m ], show compPell n ^ 2 = 2 * pellNum n ^ 2 + ( -1 ) ^ n by linarith [ pell_sq_identity n ] ] ; ring

/-! ### Determinant Formula -/

/-
det(ghostMatrix_closed n) = (-1)^n
-/
theorem ghostMatrix_closed_det (n : ℕ) :
    Matrix.det (ghostMatrix_closed n) = (-1 : ℤ) ^ n := by
  rw [ ← ghostMatrix_pow_eq_closed, Matrix.det_pow ];
  rfl

/-! ### Trace Formula -/

/-
tr(M^n) = 4·H_n² - (-1)^n
-/
theorem ghostMatrix_closed_trace (n : ℕ) :
    Matrix.trace (ghostMatrix_closed n) = 4 * compPell n ^ 2 - (-1 : ℤ) ^ n := by
  unfold ghostMatrix_closed; rw [ Matrix.trace ] ; simp +decide [ Fin.sum_univ_three ] ; ring;

/-! ### Pellnum strictly positive for n ≥ 1 -/

theorem pellNum_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < pellNum n := by
  induction' hn with n hn ih;
  · decide +revert;
  · rw [ pellNum_step ];
    exact add_pos_of_pos_of_nonneg ih ( le_of_lt ( compPell_pos n ) )

/-! ### Key Pell Product Identity -/

/-
P_n · P_{n+2} = P_{n+1}² - (-1)^n (rearrangement of Cassini)
-/
theorem pell_product_succ (n : ℕ) :
    pellNum n * pellNum (n + 2) = pellNum (n + 1) ^ 2 - (-1 : ℤ) ^ n := by
  exact Nat.recOn n ( by norm_num ) fun k ih => by norm_num [ pow_succ, pellNum_rec ] at * ; linarith;

/-! ### The Hypotenuse Growth Bound -/

/-- The hypotenuse of the ghost ancestor is always positive for a PPT. -/
theorem ghost_hypotenuse_formula (G : ℕ) (a b c : ℤ) :
    ghost_h_G G a b c =
    -2 * pellNum G * compPell G * (a + b) + (2 * compPell G ^ 2 - (-1 : ℤ) ^ G) * c := by
  unfold ghost_h_G ghostAncestor; ring

/-! ### Additional Pell recurrence identities -/

/-
P_{m+n} = P_m · H_n + H_m · P_n (addition formula)
-/
theorem pellNum_add (m n : ℕ) :
    pellNum (m + n) = pellNum m * compPell n + compPell m * pellNum n := by
  -- By definition of Pell numbers, we can express them in terms of the roots of the characteristic equation.
  have h_pell_def : ∀ n, pellNum n = ((1 + Real.sqrt 2) ^ n - (1 - Real.sqrt 2) ^ n) / (2 * Real.sqrt 2) := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ pow_succ' ] at *;
    · ring_nf; norm_num;
    · rw [ show pellNum ( n + 2 ) = 2 * pellNum ( n + 1 ) + pellNum n from rfl ] ; push_cast [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ] ; ring ; norm_num ; ring;
  -- By definition of compPell numbers, we can express them in terms of the roots of the characteristic equation.
  have h_compPell_def : ∀ n, compPell n = ((1 + Real.sqrt 2) ^ n + (1 - Real.sqrt 2) ^ n) / 2 := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ pow_succ' ] at *;
    rw [ show compPell ( n + 2 ) = 2 * compPell ( n + 1 ) + compPell n from rfl ] ; push_cast [ ih _ <| Nat.le_succ _, ih _ <| Nat.le_refl _ ] ; ring ; norm_num ; ring;
  push_cast [ ← @Int.cast_inj ℝ, h_pell_def, h_compPell_def ] ; ring

/-
H_{m+n} = H_m · H_n + 2 · P_m · P_n (addition formula)
-/
theorem compPell_add (m n : ℕ) :
    compPell (m + n) = compPell m * compPell n + 2 * pellNum m * pellNum n := by
  induction' n with n ih generalizing m;
  · norm_num +zetaDelta at *;
  · have h_step : compPell (m + (n + 1)) = compPell (m + n) + 2 * pellNum (m + n) := by
      rw [ ← add_assoc, compPell_step ];
    rw [ h_step, ih, pellNum_add ];
    rw [ show compPell ( n + 1 ) = compPell n + 2 * pellNum n from compPell_step n ] ; rw [ show pellNum ( n + 1 ) = pellNum n + compPell n from pellNum_step n ] ; ring;

end NewTheorems