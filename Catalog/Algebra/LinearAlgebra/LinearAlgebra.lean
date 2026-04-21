/-! # CatalogBuild.Algebra.LinearAlgebra.LinearAlgebra

Auto-generated from theorem catalog database.
Domain: Algebra/LinearAlgebra
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.LinearAlgebra.LinearAlgebra
Auto-generated from theorem catalog database.
Domain: Algebra/LinearAlgebra
Declarations: 5] -/
theorem det_mul_eq {n : Type*} [DecidableEq n] [Fintype n]
    (A B : Matrix n n ℝ) :
    (A * B).det = A.det * B.det := by
      exact Matrix.det_mul A B




/-- [Section: # CatalogBuild.Algebra.LinearAlgebra.LinearAlgebra
Auto-generated from theorem catalog database.
Domain: Algebra/LinearAlgebra
Declarations: 5] -/
theorem det_one_pf {n : Type*} [DecidableEq n] [Fintype n] :
    (1 : Matrix n n ℝ).det = 1 := by
      convert Matrix.det_one




theorem det_transpose_pf {n : Type*} [DecidableEq n] [Fintype n]
    (A : Matrix n n ℝ) :
    A.transpose.det = A.det := by
      exact?




theorem skew_symmetric_trace_zero {n : Type*} [DecidableEq n] [Fintype n]
    (A : Matrix n n ℝ) (hA : A.transpose = -A) :
    A.trace = 0 := by
      rw [ ← Matrix.ext_iff ] at hA;
      exact Finset.sum_eq_zero fun i _ => by have := hA i i; norm_num at *; linarith;




theorem orthogonal_det {n : Type*} [DecidableEq n] [Fintype n]
    (A : Matrix n n ℝ) (hA : A * A.transpose = 1) :
    A.det = 1 ∨ A.det = -1 := by
      exact mul_self_eq_one_iff.mp ( by simpa [ Matrix.det_transpose ] using congr_arg Matrix.det hA )


