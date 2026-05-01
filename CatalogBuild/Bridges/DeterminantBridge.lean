/-! # CatalogBuild.Bridges.DeterminantBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

import Mathlib

/-- det(AB) = det(A) * det(B). THE most important property. -/
theorem det_mul_eq {n : Type*} [DecidableEq n] [Fintype n]
    {R : Type*} [CommRing R] (A B : Matrix n n R) :
    (A * B).det = A.det * B.det :=
  Matrix.det_mul A B


/-- det(I) = 1. Together with multiplicativity, det is a monoid homomorphism. -/
theorem det_one_eq {n : Type*} [DecidableEq n] [Fintype n]
    {R : Type*} [CommRing R] :
    (1 : Matrix n n R).det = 1 :=
  Matrix.det_one


/-- det(A^T) = det(A). A deep symmetry of the determinant. -/
theorem det_transpose_eq {n : Type*} [DecidableEq n] [Fintype n]
    {R : Type*} [CommRing R] (A : Matrix n n R) :
    A.transpose.det = A.det :=
  Matrix.det_transpose A


/-- det(-A) = (-1)^n * det(A). -/
theorem det_neg_eq {n : Type*} [DecidableEq n] [Fintype n]
    {R : Type*} [CommRing R] (A : Matrix n n R) :
    (-A).det = (-1) ^ Fintype.card n * A.det :=
  Matrix.det_neg A


/-- det(c · A) = c^n * det(A). -/
theorem det_smul_eq {n : Type*} [DecidableEq n] [Fintype n]
    {R : Type*} [CommRing R] (A : Matrix n n R) (c : R) :
    (c • A).det = c ^ Fintype.card n * A.det :=
  Matrix.det_smul A c

