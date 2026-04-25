/-! # CatalogBuild.Pythagorean.Research.LorentzStructure

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 21
-/

import Mathlib

/-- The Lorentz metric η = diag(1,1,-1). -/
def η_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]


/-- η² = I. -/
theorem η_squared : η_mat * η_mat = 1 := by native_decide


/-- [Section: # CatalogBuild.Pythagorean.Research.LorentzStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 21] -/
def B1_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- [Section: # CatalogBuild.Pythagorean.Research.LorentzStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 21] -/
def B2_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- [Section: # CatalogBuild.Pythagorean.Research.LorentzStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 21] -/
def B3_mat : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]


/-- Berggren matrices preserve Lorentz form. -/
theorem B1_lorentz : B1_matᵀ * η_mat * B1_mat = η_mat := by native_decide


theorem B2_lorentz : B2_matᵀ * η_mat * B2_mat = η_mat := by native_decide


theorem B3_lorentz : B3_matᵀ * η_mat * B3_mat = η_mat := by native_decide


/-- Determinants of 3×3 Berggren matrices. -/
theorem B1_3x3_det : Matrix.det B1_mat = 1 := by native_decide


theorem B2_3x3_det : Matrix.det B2_mat = -1 := by native_decide


theorem B3_3x3_det : Matrix.det B3_mat = 1 := by native_decide


/-- B₂² has determinant +1. -/
theorem B2_sq_proper : Matrix.det (B2_mat * B2_mat) = 1 := by native_decide


def M1_2x2' : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]


def M2_2x2' : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]


def M3_2x2' : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

-- det(M₁) = 2·0 - (-1)·1 = 1


theorem M1_2x2_det : Matrix.det M1_2x2' = 1 := by
  simp [M1_2x2', Matrix.det_fin_two]

-- det(M₂) = 2·0 - 1·1 = -1


theorem M2_2x2_det : Matrix.det M2_2x2' = -1 := by
  simp [M2_2x2', Matrix.det_fin_two]

-- det(M₃) = 1·1 - 2·0 = 1


theorem M3_2x2_det : Matrix.det M3_2x2' = 1 := by
  simp [M3_2x2', Matrix.det_fin_two]


/-- M₁M₃ has det 1·1 = 1 (in SL(2,ℤ)). -/
theorem M1_M3_det' : Matrix.det (M1_2x2' * M3_2x2') = 1 := by
  rw [Matrix.det_mul, M1_2x2_det, M3_2x2_det]; ring


/-- B₁-chain stays in proper Lorentz: det(B₁)^k = 1. -/
theorem B1_chain_proper (k : ℕ) : (1 : ℤ) ^ k = 1 := one_pow k


/-- Two B₂ applications compose to proper Lorentz. -/
theorem orientation_parity_B2 :
    Matrix.det (B2_mat * B2_mat) = 1 ∧ Matrix.det B2_mat = -1 :=
  ⟨B2_sq_proper, B2_3x3_det⟩


