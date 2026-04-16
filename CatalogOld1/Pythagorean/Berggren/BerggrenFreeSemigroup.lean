/-
# Berggren Free Semigroup Evidence

## Results:
1. All 3 generators are distinct and non-identity
2. No two generators commute
3. All 9 depth-2 products are distinct (36 pairwise comparisons)
4. B₃ = S·B₁·S conjugacy (where S swaps first two rows/cols)
5. det(B₂) = -1, det(B₁) = det(B₃) = 1

These provide strong computational evidence for the freeness conjecture.

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Generator Definitions -/

def BF1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def BF2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def BF3 : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-! ## Generators are distinct and non-identity -/

theorem BF1_ne_BF2 : BF1 ≠ BF2 := by native_decide
theorem BF1_ne_BF3 : BF1 ≠ BF3 := by native_decide
theorem BF2_ne_BF3 : BF2 ≠ BF3 := by native_decide
theorem BF1_ne_one : BF1 ≠ 1 := by native_decide
theorem BF2_ne_one : BF2 ≠ 1 := by native_decide
theorem BF3_ne_one : BF3 ≠ 1 := by native_decide

/-! ## Non-Commutativity -/

theorem BF12_ne_BF21 : BF1 * BF2 ≠ BF2 * BF1 := by native_decide
theorem BF13_ne_BF31 : BF1 * BF3 ≠ BF3 * BF1 := by native_decide
theorem BF23_ne_BF32 : BF2 * BF3 ≠ BF3 * BF2 := by native_decide

/-! ## No two-letter relation equals identity -/

theorem BF11_ne_one : BF1 * BF1 ≠ 1 := by native_decide
theorem BF12_ne_one : BF1 * BF2 ≠ 1 := by native_decide
theorem BF13_ne_one : BF1 * BF3 ≠ 1 := by native_decide
theorem BF21_ne_one : BF2 * BF1 ≠ 1 := by native_decide
theorem BF22_ne_one : BF2 * BF2 ≠ 1 := by native_decide
theorem BF23_ne_one : BF2 * BF3 ≠ 1 := by native_decide
theorem BF31_ne_one : BF3 * BF1 ≠ 1 := by native_decide
theorem BF32_ne_one : BF3 * BF2 ≠ 1 := by native_decide
theorem BF33_ne_one : BF3 * BF3 ≠ 1 := by native_decide

/-! ## All 9 depth-2 products are pairwise distinct

Products: BF1*BF1, BF1*BF2, BF1*BF3, BF2*BF1, BF2*BF2, BF2*BF3,
          BF3*BF1, BF3*BF2, BF3*BF3

We verify all 36 = C(9,2) pairwise inequalities. -/

-- Row 1 vs Row 2
theorem d2_11_21 : BF1*BF1 ≠ BF2*BF1 := by native_decide
theorem d2_11_22 : BF1*BF1 ≠ BF2*BF2 := by native_decide
theorem d2_11_23 : BF1*BF1 ≠ BF2*BF3 := by native_decide
theorem d2_12_21 : BF1*BF2 ≠ BF2*BF1 := by native_decide
theorem d2_12_22 : BF1*BF2 ≠ BF2*BF2 := by native_decide
theorem d2_12_23 : BF1*BF2 ≠ BF2*BF3 := by native_decide
theorem d2_13_21 : BF1*BF3 ≠ BF2*BF1 := by native_decide
theorem d2_13_22 : BF1*BF3 ≠ BF2*BF2 := by native_decide
theorem d2_13_23 : BF1*BF3 ≠ BF2*BF3 := by native_decide

-- Row 1 vs Row 3
theorem d2_11_31 : BF1*BF1 ≠ BF3*BF1 := by native_decide
theorem d2_11_32 : BF1*BF1 ≠ BF3*BF2 := by native_decide
theorem d2_11_33 : BF1*BF1 ≠ BF3*BF3 := by native_decide
theorem d2_12_31 : BF1*BF2 ≠ BF3*BF1 := by native_decide
theorem d2_12_32 : BF1*BF2 ≠ BF3*BF2 := by native_decide
theorem d2_12_33 : BF1*BF2 ≠ BF3*BF3 := by native_decide
theorem d2_13_31 : BF1*BF3 ≠ BF3*BF1 := by native_decide
theorem d2_13_32 : BF1*BF3 ≠ BF3*BF2 := by native_decide
theorem d2_13_33 : BF1*BF3 ≠ BF3*BF3 := by native_decide

-- Row 2 vs Row 3
theorem d2_21_31 : BF2*BF1 ≠ BF3*BF1 := by native_decide
theorem d2_21_32 : BF2*BF1 ≠ BF3*BF2 := by native_decide
theorem d2_21_33 : BF2*BF1 ≠ BF3*BF3 := by native_decide
theorem d2_22_31 : BF2*BF2 ≠ BF3*BF1 := by native_decide
theorem d2_22_32 : BF2*BF2 ≠ BF3*BF2 := by native_decide
theorem d2_22_33 : BF2*BF2 ≠ BF3*BF3 := by native_decide
theorem d2_23_31 : BF2*BF3 ≠ BF3*BF1 := by native_decide
theorem d2_23_32 : BF2*BF3 ≠ BF3*BF2 := by native_decide
theorem d2_23_33 : BF2*BF3 ≠ BF3*BF3 := by native_decide

-- Within Row 1
theorem d2_11_12 : BF1*BF1 ≠ BF1*BF2 := by native_decide
theorem d2_11_13 : BF1*BF1 ≠ BF1*BF3 := by native_decide
theorem d2_12_13 : BF1*BF2 ≠ BF1*BF3 := by native_decide

-- Within Row 2
theorem d2_21_22 : BF2*BF1 ≠ BF2*BF2 := by native_decide
theorem d2_21_23 : BF2*BF1 ≠ BF2*BF3 := by native_decide
theorem d2_22_23 : BF2*BF2 ≠ BF2*BF3 := by native_decide

-- Within Row 3
theorem d2_31_32 : BF3*BF1 ≠ BF3*BF2 := by native_decide
theorem d2_31_33 : BF3*BF1 ≠ BF3*BF3 := by native_decide
theorem d2_32_33 : BF3*BF2 ≠ BF3*BF3 := by native_decide

/-! ## Determinant Separation -/

theorem det_BF1 : Matrix.det BF1 = 1 := by native_decide
theorem det_BF2 : Matrix.det BF2 = -1 := by native_decide
theorem det_BF3 : Matrix.det BF3 = 1 := by native_decide

/-! ## Conjugacy: B₃ = S·B₁·S where S swaps legs -/

/-- The swap matrix S = diag(0,1,0; 1,0,0; 0,0,1) that swaps a,b -/
def SwapS : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]

theorem SwapS_invol : SwapS * SwapS = 1 := by native_decide

theorem BF3_conjugate : SwapS * BF1 * SwapS = BF3 := by native_decide

theorem BF2_self_conjugate : SwapS * BF2 * SwapS = BF2 := by native_decide

/-! ## Summary theorem: all 9 depth-2 products are distinct -/

theorem depth2_all_distinct :
    BF1*BF1 ≠ BF1*BF2 ∧ BF1*BF1 ≠ BF1*BF3 ∧ BF1*BF1 ≠ BF2*BF1 ∧
    BF1*BF1 ≠ BF2*BF2 ∧ BF1*BF1 ≠ BF2*BF3 ∧ BF1*BF1 ≠ BF3*BF1 ∧
    BF1*BF1 ≠ BF3*BF2 ∧ BF1*BF1 ≠ BF3*BF3 ∧
    BF1*BF2 ≠ BF1*BF3 ∧ BF1*BF2 ≠ BF2*BF1 ∧
    BF1*BF2 ≠ BF2*BF2 ∧ BF1*BF2 ≠ BF2*BF3 ∧ BF1*BF2 ≠ BF3*BF1 ∧
    BF1*BF2 ≠ BF3*BF2 ∧ BF1*BF2 ≠ BF3*BF3 ∧
    BF1*BF3 ≠ BF2*BF1 ∧
    BF1*BF3 ≠ BF2*BF2 ∧ BF1*BF3 ≠ BF2*BF3 ∧ BF1*BF3 ≠ BF3*BF1 ∧
    BF1*BF3 ≠ BF3*BF2 ∧ BF1*BF3 ≠ BF3*BF3 ∧
    BF2*BF1 ≠ BF2*BF2 ∧ BF2*BF1 ≠ BF2*BF3 ∧ BF2*BF1 ≠ BF3*BF1 ∧
    BF2*BF1 ≠ BF3*BF2 ∧ BF2*BF1 ≠ BF3*BF3 ∧
    BF2*BF2 ≠ BF2*BF3 ∧ BF2*BF2 ≠ BF3*BF1 ∧
    BF2*BF2 ≠ BF3*BF2 ∧ BF2*BF2 ≠ BF3*BF3 ∧
    BF2*BF3 ≠ BF3*BF1 ∧
    BF2*BF3 ≠ BF3*BF2 ∧ BF2*BF3 ≠ BF3*BF3 ∧
    BF3*BF1 ≠ BF3*BF2 ∧ BF3*BF1 ≠ BF3*BF3 ∧
    BF3*BF2 ≠ BF3*BF3 := by
  exact ⟨d2_11_12, d2_11_13, d2_11_21, d2_11_22, d2_11_23, d2_11_31, d2_11_32, d2_11_33,
         d2_12_13, d2_12_21, d2_12_22, d2_12_23, d2_12_31, d2_12_32, d2_12_33,
         d2_13_21, d2_13_22, d2_13_23, d2_13_31, d2_13_32, d2_13_33,
         d2_21_22, d2_21_23, d2_21_31, d2_21_32, d2_21_33,
         d2_22_23, d2_22_31, d2_22_32, d2_22_33,
         d2_23_31, d2_23_32, d2_23_33,
         d2_31_32, d2_31_33, d2_32_33⟩
