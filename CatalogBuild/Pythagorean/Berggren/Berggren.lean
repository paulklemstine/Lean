/-! # CatalogBuild.Pythagorean.Berggren.Berggren

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 10
-/

import Mathlib

/-- M₁ has determinant 1 (it's in SL(2,ℤ)). -/
theorem det_M₁ : Matrix.det M₁ = 1 := by
  simp [M₁, Matrix.det_fin_two]


/-- M₂ has determinant -1 -/
theorem det_M₂ : Matrix.det M₂ = -1 := by
  simp [M₂, Matrix.det_fin_two]


/-- M₃ has determinant 1 (it's in SL(2,ℤ)) -/
theorem det_M₃ : Matrix.det M₃ = 1 := by
  simp [M₃, Matrix.det_fin_two]


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


/-- S matrix (the standard generator of SL(2,ℤ)) -/
def S_mat : Matrix (Fin 2) (Fin 2) ℤ :=
  !![0, -1; 1, 0]


/-- M₃⁻¹ as an integer matrix (since det M₃ = 1): [[1,-2],[0,1]] -/
def M₃_inv : Matrix (Fin 2) (Fin 2) ℤ :=
  !![1, -2; 0, 1]


/-- The product M₃⁻¹ · M₁ = S (the fundamental theta group identity) -/
theorem M₃_inv_M₁_eq_S : M₃_inv * M₁ = S_mat := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [M₃_inv, M₁, S_mat, Matrix.mul_apply, Fin.sum_univ_two]

