/-! # CatalogBuild.Pythagorean.Berggren.BerggrenB2TraceRecurrence

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 7
-/

import Mathlib

/-- [Section: ## Definitions] -/
def BTR₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- The trace sequence tr(B₂ⁿ) defined by the recurrence -/
def trB2 : ℕ → ℤ
  | 0 => 3
  | 1 => 5
  | 2 => 35
  | n + 3 => 5 * trB2 (n + 2) + 5 * trB2 (n + 1) - trB2 n


/-- B₂³ = 5B₂² + 5B₂ - I (rearranged Cayley-Hamilton) -/
theorem BTR₂_cayley : BTR₂ ^ 3 = 5 • BTR₂ ^ 2 + 5 • BTR₂ - 1 := by native_decide


/-- [Section: ## Trace recurrence follows from Cayley-Hamilton] -/
theorem trace_BTR₂_recurrence (n : ℕ) :
    Matrix.trace (BTR₂ ^ (n + 3)) =
    5 * Matrix.trace (BTR₂ ^ (n + 2)) + 5 * Matrix.trace (BTR₂ ^ (n + 1)) -
    Matrix.trace (BTR₂ ^ n) := by
  -- Rewrite the matrix expression using the Cayley-Hamilton equation.
  have h_matrix : BTR₂ ^ (n + 3) = 5 • BTR₂ ^ (n + 2) + 5 • BTR₂ ^ (n + 1) - BTR₂ ^ n := by
    convert congr_arg ( fun x : Matrix ( Fin 3 ) ( Fin 3 ) ℤ => x * BTR₂ ^ n ) BTR₂_cayley using 1 ; norm_num [ pow_add, Matrix.mul_assoc ];
    · rw [ ← pow_add, add_comm, pow_add ];
    · norm_num [ add_mul, sub_mul, mul_assoc, pow_succ' ];
  rw [ h_matrix, Matrix.trace_sub, Matrix.trace_add, Matrix.trace_smul, Matrix.trace_smul ] ; norm_num


theorem trB2_eq_trace (n : ℕ) : trB2 n = Matrix.trace (BTR₂ ^ n) := by
  -- We'll use induction on $n$ to prove that the recurrence-defined sequence matches the actual trace.
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n );
  · native_decide;
  · native_decide;
  · native_decide;
  · rw [ show trB2 ( n + 1 + 1 + 1 ) = 5 * trB2 ( n + 2 ) + 5 * trB2 ( n + 1 ) - trB2 n from rfl ];
    rw [ ih _ <| by linarith, ih _ <| by linarith, ih _ <| by linarith ];
    exact?


/-- [Section: ## Verification of specific values] -/
theorem trB2_vals :
    trB2 0 = 3 ∧ trB2 1 = 5 ∧ trB2 2 = 35 ∧
    trB2 3 = 197 ∧ trB2 4 = 1155 ∧ trB2 5 = 6725 := by native_decide


theorem trace_BTR₂_base :
    Matrix.trace (BTR₂ ^ 0) = 3 ∧
    Matrix.trace (BTR₂ ^ 1) = 5 ∧
    Matrix.trace (BTR₂ ^ 2) = 35 := by native_decide
