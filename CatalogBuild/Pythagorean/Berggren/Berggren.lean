/-! # CatalogBuild.Pythagorean.Berggren.Berggren

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 10
-/

import Mathlib

theorem det_M₁ : Matrix.det M₁ = 1 := by
  simp [M₁, Matrix.det_fin_two]

/-- M₂ has determinant -1 -/

theorem det_M₂ : Matrix.det M₂ = -1 := by
  simp [M₂, Matrix.det_fin_two]

/-- M₃ has determinant 1 (it's in SL(2,ℤ)) -/

theorem det_M₃ : Matrix.det M₃ = 1 := by
  simp [M₃, Matrix.det_fin_two]

/-! ## Lorentz Form Preservation

The 3×3 Berggren matrices preserve Q = x² + y² - z². -/

/-- The Lorentz form matrix: diag(1, 1, -1) -/

def Q_lorentz : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- B₁ preserves the Lorentz form: B₁ᵀ Q B₁ = Q -/

theorem B₁_preserves_lorentz : B₁ᵀ * Q_lorentz * B₁ = Q_lorentz := by
  native_decide

/-- B₂ preserves the Lorentz form: B₂ᵀ Q B₂ = Q -/

theorem B₂_preserves_lorentz : B₂ᵀ * Q_lorentz * B₂ = Q_lorentz := by
  native_decide

/-- B₃ preserves the Lorentz form: B₃ᵀ Q B₃ = Q -/

theorem B₃_preserves_lorentz : B₃ᵀ * Q_lorentz * B₃ = Q_lorentz := by
  native_decide

/-! ## Pythagorean Preservation

The key property: if (a,b,c) is a Pythagorean triple, then B_i · (a,b,c) is too. -/

/-
PROBLEM
Applying B₁ to a Pythagorean triple preserves the Pythagorean property.

PROVIDED SOLUTION
Expand LHS and RHS, substitute c² = a²+b² from h, and verify by nlinarith or ring after substitution. The key: nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg (a-b), sq_nonneg (a+b)].
-/

def S_mat : Matrix (Fin 2) (Fin 2) ℤ :=
  !![0, -1; 1, 0]

/-- det(B₁) = 1 -/

def M₃_inv : Matrix (Fin 2) (Fin 2) ℤ :=
  !![1, -2; 0, 1]

/-- M₃_inv is indeed the inverse of M₃ -/

theorem M₃_inv_M₁_eq_S : M₃_inv * M₁ = S_mat := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [M₃_inv, M₁, S_mat, Matrix.mul_apply, Fin.sum_univ_two]

