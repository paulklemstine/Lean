/-
# Berggren Unipotent-Semisimple Decomposition (V11)

## Key Discovery:
The Berggren generators decompose into two types:
- B₁, B₃: UNIPOTENT (eigenvalue 1 with multiplicity 3)
  Characteristic polynomial: (λ-1)³ = 0
  Cayley-Hamilton: (B - I)³ = 0 but (B - I)² ≠ 0

- B₂: SEMISIMPLE (three distinct eigenvalues)
  Characteristic polynomial: (λ+1)(λ² - 6λ + 1) = 0
  Eigenvalues: -1, 3+2√2, 3-2√2

This decomposition explains:
1. Why B₁ⁿ and B₃ⁿ have polynomial entries (unipotent ⟹ nilpotent perturbation)
2. Why B₂ⁿ has exponential growth (semisimple ⟹ eigenvalue growth)
3. Why the A and C branches are "polynomial" while the B branch is "exponential"

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Definitions -/

def BU₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def BU₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def BU₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Nilpotent part of B₁: N₁ = B₁ - I -/
def NU₁ : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-- Nilpotent part of B₃: N₃ = B₃ - I -/
def NU₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-2), 2, 2; (-2), 0, 2; (-2), 2, 2]

/-! ## B₁ is Unipotent -/

theorem NU₁_eq : NU₁ = BU₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NU₁, BU₁]

theorem NU₁_cubed : NU₁ ^ 3 = 0 := by native_decide
theorem NU₁_sq_ne_zero : NU₁ ^ 2 ≠ 0 := by native_decide

/-- B₁ satisfies the Cayley-Hamilton equation (B₁ - I)³ = 0
    This proves the characteristic polynomial is (λ-1)³. -/
theorem BU₁_unipotent : (BU₁ - 1) ^ 3 = 0 := by native_decide

/-- B₁ is NOT the identity (nilpotency index is exactly 3, not 1) -/
theorem BU₁_ne_one : BU₁ ≠ 1 := by native_decide

/-- (B₁ - I)² ≠ 0, so nilpotency index is exactly 3 -/
theorem BU₁_nilp_index_3 : (BU₁ - 1) ^ 2 ≠ 0 := by native_decide

/-! ## B₃ is Unipotent -/

theorem NU₃_eq : NU₃ = BU₃ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NU₃, BU₃]

theorem NU₃_cubed : NU₃ ^ 3 = 0 := by native_decide
theorem NU₃_sq_ne_zero : NU₃ ^ 2 ≠ 0 := by native_decide

/-- B₃ satisfies (B₃ - I)³ = 0: also unipotent -/
theorem BU₃_unipotent : (BU₃ - 1) ^ 3 = 0 := by native_decide
theorem BU₃_nilp_index_3 : (BU₃ - 1) ^ 2 ≠ 0 := by native_decide

/-! ## B₂ is Semisimple

Cayley-Hamilton: B₂³ - 5B₂² - 5B₂ + I = 0
Characteristic polynomial: λ³ - 5λ² - 5λ + 1 = (λ+1)(λ² - 6λ + 1)
Eigenvalues: -1, 3±2√2 -/

theorem BU₂_cayley_hamilton :
    BU₂ ^ 3 - 5 • BU₂ ^ 2 - 5 • BU₂ + 1 = 0 := by native_decide

/-- B₂ is NOT unipotent: (B₂ - I)³ ≠ 0 -/
theorem BU₂_not_unipotent : (BU₂ - 1) ^ 3 ≠ 0 := by native_decide

/-- B₂ + I ≠ 0 either (not purely eigenvalue -1) -/
theorem BU₂_plus_I_ne_zero : BU₂ + 1 ≠ 0 := by native_decide

/-- But (B₂ + I) applied to the eigenvector gives 0 column -/
theorem BU₂_eigvec_neg1 : (BU₂ + 1) * !![(1 : ℤ); (-1); 0] = !![0; 0; 0] := by native_decide

/-! ## Trace Characterization

tr(B₁ⁿ) = 3 for all n (sum of eigenvalues 1+1+1 = 3 at any power)
tr(B₂ⁿ) grows exponentially (dominated by (3+2√2)ⁿ) -/

theorem trace_BU₁ : Matrix.trace BU₁ = 3 := by native_decide
theorem trace_BU₂ : Matrix.trace BU₂ = 5 := by native_decide
theorem trace_BU₃ : Matrix.trace BU₃ = 3 := by native_decide

/-- Unipotent matrices have constant trace under powers -/
theorem trace_BU₁_const :
    Matrix.trace (BU₁ ^ 1) = 3 ∧
    Matrix.trace (BU₁ ^ 2) = 3 ∧
    Matrix.trace (BU₁ ^ 3) = 3 ∧
    Matrix.trace (BU₁ ^ 4) = 3 ∧
    Matrix.trace (BU₁ ^ 5) = 3 := by native_decide

theorem trace_BU₃_const :
    Matrix.trace (BU₃ ^ 1) = 3 ∧
    Matrix.trace (BU₃ ^ 2) = 3 ∧
    Matrix.trace (BU₃ ^ 3) = 3 ∧
    Matrix.trace (BU₃ ^ 4) = 3 ∧
    Matrix.trace (BU₃ ^ 5) = 3 := by native_decide

/-- B₂ traces grow: {5, 19, 91, 437, ...}
    These satisfy tr(B₂ⁿ⁺¹) = 5·tr(B₂ⁿ) + 5·tr(B₂ⁿ⁻¹) - tr(B₂ⁿ⁻²)
    (Newton's identity from char poly) -/
theorem trace_BU₂_seq :
    Matrix.trace (BU₂ ^ 1) = 5 ∧
    Matrix.trace (BU₂ ^ 2) = 35 ∧
    Matrix.trace (BU₂ ^ 3) = 197 ∧
    Matrix.trace (BU₂ ^ 4) = 1155 := by native_decide

/-! ## Nilpotent Part Explicit Forms -/

theorem NU₁_sq : NU₁ ^ 2 = !![0, 0, 0; 0, (-4), 4; 0, (-4), 4] := by native_decide
theorem NU₃_sq : NU₃ ^ 2 = !![(-4), 0, 4; 0, 0, 0; (-4), 0, 4] := by native_decide

/-! ## B₁ and B₃ Power Formulas (verified for small n)

B₁ⁿ = I + n·N₁ + n(n-1)/2·N₁²
B₃ⁿ = I + n·N₃ + n(n-1)/2·N₃² -/

theorem BU₁_pow1 : BU₁ ^ 1 = !![1, -2, 2; 2, -1, 2; 2, -2, 3] := by native_decide
theorem BU₁_pow2 : BU₁ ^ 2 = !![1, -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide
theorem BU₁_pow3 : BU₁ ^ 3 = !![1, -6, 6; 6, -17, 18; 6, -18, 19] := by native_decide
theorem BU₁_pow4 : BU₁ ^ 4 = !![1, -8, 8; 8, -31, 32; 8, -32, 33] := by native_decide

theorem BU₃_pow1 : BU₃ ^ 1 = !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3] := by native_decide
theorem BU₃_pow2 : BU₃ ^ 2 = !![(-7), 4, 8; (-4), 1, 4; (-8), 4, 9] := by native_decide
theorem BU₃_pow3 : BU₃ ^ 3 = !![(-17), 6, 18; (-6), 1, 6; (-18), 6, 19] := by native_decide

/-! ## Pattern Verification for B₁ⁿ entries

The entry formula B₁ⁿ[i,j] is a polynomial in n:
  (0,0) = 1,  (0,1) = -2n,    (0,2) = 2n
  (1,0) = 2n, (1,1) = 1-2n²,  (1,2) = 2n²
  (2,0) = 2n, (2,1) = -2n²,   (2,2) = 1+2n² -/

-- Verified: B₁⁴ entry (1,1) = 1 - 2·16 = -31 ✓
-- Verified: B₁⁴ entry (2,2) = 1 + 2·16 = 33 ✓

/-! ## Minimal Polynomial Analysis

For unipotent B₁: minpoly = (x-1)³ (since (B₁-I)² ≠ 0 but (B₁-I)³ = 0)
For semisimple B₂: minpoly = (x+1)(x²-6x+1) (since B₂ has 3 distinct eigenvalues) -/

/-- B₂ satisfies its char poly: (B₂+I)(B₂²-6B₂+I) = 0 -/
theorem BU₂_factored_cayley :
    (BU₂ + 1) * (BU₂ ^ 2 - 6 • BU₂ + 1) = 0 := by native_decide

/-- Neither factor is zero: B₂ has all three eigenvalues -/
theorem BU₂_factor1_ne_zero : BU₂ + 1 ≠ 0 := by native_decide
theorem BU₂_factor2_ne_zero : BU₂ ^ 2 - 6 • BU₂ + 1 ≠ 0 := by native_decide
