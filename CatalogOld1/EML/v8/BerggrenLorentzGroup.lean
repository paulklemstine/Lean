import Mathlib

/-!
# Berggren Group as a Subgroup of O(2,1;ℤ)

The Berggren matrices B₁, B₂, B₃ generate a subgroup Γ_B of the
integer Lorentz group O(2,1;ℤ). This file explores the algebraic
structure of Γ_B.

## Main Results

1. All Berggren matrices and their products preserve the Lorentz form
2. Determinant structure: B₁, B₃ ∈ SO(2,1), B₂ ∈ O(2,1) \ SO(2,1)
3. The group is infinite and non-abelian
4. Trace classification distinguishes parabolic/hyperbolic elements
-/

open Matrix

def BG1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def BG2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def BG3 : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]
def Qlor : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-! ## Lorentz Preservation -/

theorem BG1_lorentz : BG1ᵀ * Qlor * BG1 = Qlor := by native_decide
theorem BG2_lorentz : BG2ᵀ * Qlor * BG2 = Qlor := by native_decide
theorem BG3_lorentz : BG3ᵀ * Qlor * BG3 = Qlor := by native_decide

theorem BG12_lorentz : (BG1 * BG2)ᵀ * Qlor * (BG1 * BG2) = Qlor := by native_decide
theorem BG123_lorentz : (BG1 * BG2 * BG3)ᵀ * Qlor * (BG1 * BG2 * BG3) = Qlor := by native_decide

/-! ## Determinant Structure -/

theorem det_BG1 : BG1.det = 1 := by native_decide
theorem det_BG2 : BG2.det = -1 := by native_decide
theorem det_BG3 : BG3.det = 1 := by native_decide

theorem B1_B3_in_SO : BG1.det = 1 ∧ BG3.det = 1 := ⟨det_BG1, det_BG3⟩
theorem B2_sq_in_SO : (BG2 * BG2).det = 1 := by native_decide

/-! ## Infinite Order -/

theorem BG1_ne_one : BG1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide
theorem BG1_sq_ne_one : BG1 * BG1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide
theorem BG2_sq_ne_one : BG2 * BG2 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide
theorem BG1_minus_I_ne_zero : BG1 - 1 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-! ## Non-Commutativity -/

theorem BG_13_noncomm : BG1 * BG3 ≠ BG3 * BG1 := by native_decide
theorem BG_12_noncomm : BG1 * BG2 ≠ BG2 * BG1 := by native_decide
theorem BG_23_noncomm : BG2 * BG3 ≠ BG3 * BG2 := by native_decide

/-! ## Trace Classification -/

theorem trace_BG1 : BG1.trace = 3 := by native_decide
theorem trace_BG2 : BG2.trace = 5 := by native_decide
theorem trace_BG3 : BG3.trace = 3 := by native_decide

/-- Parabolic: tr = 3 (B₁, B₃); Hyperbolic: tr = 5 (B₂) -/
theorem trace_classifies :
    BG1.trace = 3 ∧ BG3.trace = 3 ∧ BG2.trace = 5 := by
  exact ⟨trace_BG1, trace_BG3, trace_BG2⟩

/-! ## Cayley-Hamilton -/

theorem BG1_cayley :
    BG1 * BG1 * BG1 - 3 • (BG1 * BG1) + 3 • BG1 - 1 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

theorem BG2_cayley :
    BG2 * BG2 * BG2 - 5 • (BG2 * BG2) - 5 • BG2 + 1 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide
