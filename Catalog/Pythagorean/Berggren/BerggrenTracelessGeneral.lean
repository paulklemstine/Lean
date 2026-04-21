/-! # CatalogBuild.Pythagorean.Berggren.BerggrenTracelessGeneral

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 37
-/

import Mathlib

/-- For 3×3 integer matrices, tr(AB) = tr(BA). This is the key identity
that makes ALL commutators traceless. -/
theorem trace_mul_comm_3x3 (A B : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix.trace (A * B) = Matrix.trace (B * A) := by
  simp [Matrix.trace, Matrix.mul_apply, Fin.sum_univ_three]
  ring



/-- Universal: the trace of ANY commutator [A,B] = AB - BA is zero.
This subsumes the V10 "discovery" as a special case. -/
theorem commutator_traceless_3x3 (A B : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix.trace (A * B - B * A) = 0 := by
  simp [trace_mul_comm_3x3]



/-- [Section: ## Berggren Matrix Definitions] -/
def BT₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenTracelessGeneral
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 37] -/
def BT₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


def BT₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


def QT : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]



/-- V10 Discovery 1 is a corollary -/
theorem BD₁₂_traceless_corollary :
    Matrix.trace (BT₁ * BT₂ - BT₂ * BT₁) = 0 :=
  commutator_traceless_3x3 BT₁ BT₂



/-- [Section: ## V10 Results as Corollaries of the Universal Theorem] -/
theorem BD₁₃_traceless_corollary :
    Matrix.trace (BT₁ * BT₃ - BT₃ * BT₁) = 0 :=
  commutator_traceless_3x3 BT₁ BT₃



theorem BD₂₃_traceless_corollary :
    Matrix.trace (BT₂ * BT₃ - BT₃ * BT₂) = 0 :=
  commutator_traceless_3x3 BT₂ BT₃



/-- All generators preserve the Lorentz form -/
theorem BT₁_Lorentz : BT₁ᵀ * QT * BT₁ = QT := by native_decide


/-- [Section: ## Genuinely Berggren-Specific Properties
The REAL structural properties are about the Lorentz form preservation
and determinant structure.] -/
theorem BT₂_Lorentz : BT₂ᵀ * QT * BT₂ = QT := by native_decide


theorem BT₃_Lorentz : BT₃ᵀ * QT * BT₃ = QT := by native_decide



/-- Products of generators preserve the Lorentz form -/
theorem BT₁₂_Lorentz : (BT₁ * BT₂)ᵀ * QT * (BT₁ * BT₂) = QT := by native_decide


theorem BT₂₁_Lorentz : (BT₂ * BT₁)ᵀ * QT * (BT₂ * BT₁) = QT := by native_decide


theorem BT₁₃_Lorentz : (BT₁ * BT₃)ᵀ * QT * (BT₁ * BT₃) = QT := by native_decide


theorem BT₂₃_Lorentz : (BT₂ * BT₃)ᵀ * QT * (BT₂ * BT₃) = QT := by native_decide



/-- [Section: ## Determinant Structure] -/
theorem det_BT₁ : Matrix.det BT₁ = 1 := by native_decide


theorem det_BT₂ : Matrix.det BT₂ = -1 := by native_decide


theorem det_BT₃ : Matrix.det BT₃ = 1 := by native_decide



/-- B₁ · B₂ has det = -1 -/
theorem det_BT₁₂ : Matrix.det (BT₁ * BT₂) = -1 := by native_decide


/-- B₁ · B₃ has det = 1 -/
theorem det_BT₁₃ : Matrix.det (BT₁ * BT₃) = 1 := by native_decide


/-- B₂ · B₂ has det = 1 -/
theorem det_BT₂₂ : Matrix.det (BT₂ * BT₂) = 1 := by native_decide


/-- B₁ · B₂ · B₃ has det = -1 -/
theorem det_BT₁₂₃ : Matrix.det (BT₁ * BT₂ * BT₃) = -1 := by native_decide



/-- Unipotent trace: tr(B₁ⁿ) = 3 for all n (eigenvalue 1 with mult 3) -/
theorem trace_BT₁_pow1 : Matrix.trace (BT₁ ^ 1) = 3 := by native_decide


/-- [Section: ## Trace Structure of Products] -/
theorem trace_BT₁_pow2 : Matrix.trace (BT₁ ^ 2) = 3 := by native_decide


theorem trace_BT₁_pow3 : Matrix.trace (BT₁ ^ 3) = 3 := by native_decide


theorem trace_BT₁_pow4 : Matrix.trace (BT₁ ^ 4) = 3 := by native_decide


theorem trace_BT₁_pow5 : Matrix.trace (BT₁ ^ 5) = 3 := by native_decide



/-- Semisimple trace: tr(B₂ⁿ) grows exponentially
tr(B₂ⁿ) = (-1)ⁿ + (3+2√2)ⁿ + (3-2√2)ⁿ -/
theorem trace_BT₂_pow1 : Matrix.trace (BT₂ ^ 1) = 5 := by native_decide


theorem trace_BT₂_pow2 : Matrix.trace (BT₂ ^ 2) = 35 := by native_decide


theorem trace_BT₂_pow3 : Matrix.trace (BT₂ ^ 3) = 197 := by native_decide


theorem trace_BT₂_pow4 : Matrix.trace (BT₂ ^ 4) = 1155 := by native_decide



/-- [Section: ## Swap Matrix Properties] -/
def SwapT : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]



theorem SwapT_invol : SwapT * SwapT = 1 := by native_decide


theorem BT₃_conj : BT₃ = SwapT * BT₁ * SwapT := by native_decide


theorem BT₂_self_conj : BT₂ = SwapT * BT₂ * SwapT := by native_decide



/-- The swap matrix preserves the Lorentz form -/
theorem SwapT_Lorentz : SwapTᵀ * QT * SwapT = QT := by native_decide


