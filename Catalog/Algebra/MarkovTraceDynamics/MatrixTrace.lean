import Mathlib

/-!
# Matrix Trace Recurrence for SL₂

This file proves that traces of powers of 2×2 matrices with determinant 1
follow the Chebyshev trace recurrence.

## Main results

* `cayley_hamilton_det1` — A² = tr(A)·A - I for det(A) = 1
* `trace_pow_recurrence` — tr(A^(n+2)) = tr(A)·tr(A^(n+1)) - tr(A^n) for det(A) = 1
* `trace_pow_eq_chebTrace` — tr(Aⁿ) = chebTrace(tr(A), n)
-/

open Matrix

namespace MarkovTrace

/-- The Chebyshev trace sequence (local copy for self-containment). -/
def chebTrace' (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | (n + 2) => t * chebTrace' t (n + 1) - chebTrace' t n

/-- Abbreviation for 2×2 integer matrices. -/
abbrev Mat2 := Matrix (Fin 2) (Fin 2) ℤ

/-
**Cayley-Hamilton for 2×2 matrices with determinant 1**:
A² = tr(A) · A - I.
-/
theorem cayley_hamilton_det1 (A : Mat2)
    (hdet : A.det = 1) :
    A * A = (Matrix.trace A) • A - 1 := by
      ext i j; fin_cases i <;> fin_cases j <;> simp_all +decide [ Matrix.mul_apply, Matrix.trace_fin_two ] <;> ring;
      · erw [ show ( A 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => A 0 0 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl, show ( A 1 1 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => A 1 1 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide ; ring!;
        rw [ Matrix.det_fin_two ] at hdet ; linarith!;
      · erw [ show ( A 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => A 0 0 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl, show ( A 1 1 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => A 1 1 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide ; ring!;
      · erw [ show ( A 0 0 : ℤ ) = A 0 0 from rfl, show ( A 1 1 : ℤ ) = A 1 1 from rfl ] ; ring!;
        aesop;
      · simp_all +decide [ Matrix.det_fin_two, Matrix.trace_fin_two ] ; ring!;
        erw [ show ( A 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.of ![![A 0 0, 0], ![0, A 0 0]] by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; norm_num ; linarith!

/-
Determinant of a power of a det-1 matrix is 1.
-/
theorem det_pow_one (A : Mat2) (hdet : A.det = 1) (n : ℕ) :
    (A ^ n).det = 1 := by
      induction n <;> simp_all +decide [ pow_succ, Matrix.mul_apply ]

/-
The power recurrence: A^(n+2) = tr(A) · A^(n+1) - A^n for det(A) = 1.
-/
theorem pow_recurrence_det1 (A : Mat2)
    (hdet : A.det = 1) (n : ℕ) :
    A ^ (n + 2) = (Matrix.trace A) • (A ^ (n + 1)) - A ^ n := by
      have h_pow_recurrence : A * A = (Matrix.trace A) • A - 1 := by
        convert cayley_hamilton_det1 A hdet using 1;
      induction n <;> simp_all +decide [ pow_succ, mul_assoc ];
      simp_all +decide [ sub_mul, mul_assoc, mul_sub ]

/-
**Trace-Power Chebyshev Correspondence**: For any 2×2 integer matrix A
with det(A) = 1, tr(Aⁿ) = chebTrace'(tr(A), n).
-/
theorem trace_pow_eq_chebTrace (A : Mat2)
    (hdet : A.det = 1) (n : ℕ) :
    Matrix.trace (A ^ n) = chebTrace' (Matrix.trace A) n := by
      induction' n using Nat.strong_induction_on with n ih;
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ chebTrace' ];
      rw [ pow_recurrence_det1 A hdet, Matrix.trace_sub, Matrix.trace_smul ] ; aesop

end MarkovTrace