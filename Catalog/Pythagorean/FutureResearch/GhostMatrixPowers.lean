import Mathlib

/-! # Ghost Matrix Powers and Berggren Tree Structure

This file formalizes additional properties of ghost matrix powers,
the Berggren tree structure, and connections to factoring.
-/

open Matrix

namespace GhostMatPow

/-! ## Matrix Definitions -/

/-- Berggren B₁ matrix (Branch A) -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, (-2), 2; 2, (-1), 2; 2, (-2), 3]

/-- Berggren B₂ matrix (Branch B) -/
def B₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren B₃ matrix (Branch C) -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Ghost matrix M = B₂⁻¹ -/
def M : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, (-2); 2, 1, (-2); (-2), (-2), 3]

/-! ## All Three Matrices Preserve the Pythagorean Property -/

/-- The Lorentz metric -/
def Q : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

theorem B₂_lorentz : B₂ᵀ * Q * B₂ = Q := by native_decide
theorem M_lorentz : Mᵀ * Q * M = Q := by native_decide

/-! ## Determinants: B₁ and B₃ have determinant 1, B₂ has determinant -1 -/

theorem B₁_det : det B₁ = 1 := by native_decide
theorem B₂_det : det B₂ = -1 := by native_decide
theorem B₃_det : det B₃ = 1 := by native_decide
theorem M_det : det M = -1 := by native_decide

/-! ## Inverse Relations -/

theorem M_B₂_inv : M * B₂ = 1 := by native_decide
theorem B₂_M_inv : B₂ * M = 1 := by native_decide

/-! ## Branch Inverses (B₁ and B₃ have det=1, so inv = adjugate) -/

def B₁_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, (-2); (-2), (-1), 2; (-2), (-2), 3]

def B₃_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), (-2), 2; 2, 1, (-2); (-2), (-2), 3]

theorem B₁_inv_left : B₁_inv * B₁ = 1 := by native_decide
theorem B₁_inv_right : B₁ * B₁_inv = 1 := by native_decide
theorem B₃_inv_left : B₃_inv * B₃ = 1 := by native_decide
theorem B₃_inv_right : B₃ * B₃_inv = 1 := by native_decide

/-! ## Ghost Matrix Powers -/

/-- M² explicit form -/
theorem M_sq : M ^ 2 = !![9, 8, (-12); 8, 9, (-12); (-12), (-12), 17] := by
  native_decide

/-- M³ explicit form -/
theorem M_cube : M ^ 3 = !![49, 50, (-70); 50, 49, (-70); (-70), (-70), 99] := by
  native_decide

/-- M⁴ explicit form -/
theorem M_pow4 : M ^ 4 = !![289, 288, (-408); 288, 289, (-408); (-408), (-408), 577] := by
  native_decide

/-- M⁵ explicit form -/
theorem M_pow5 : M ^ 5 =
    !![1681, 1682, (-2378); 1682, 1681, (-2378); (-2378), (-2378), 3363] := by
  native_decide

/-! ## Trace of Powers -/

theorem trace_M1 : trace M = 5 := by native_decide
theorem trace_M2 : trace (M ^ 2) = 35 := by native_decide
theorem trace_M3 : trace (M ^ 3) = 197 := by native_decide
theorem trace_M4 : trace (M ^ 4) = 1155 := by native_decide
theorem trace_M5 : trace (M ^ 5) = 6725 := by native_decide

/-- From Cayley-Hamilton: tr(M^{n+3}) = 5·tr(M^{n+2}) + 5·tr(M^{n+1}) - tr(M^n) -/
theorem trace_recurrence :
    trace (M ^ 3) = 5 * trace (M ^ 2) + 5 * trace M - trace (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

theorem trace_recurrence_4 :
    trace (M ^ 4) = 5 * trace (M ^ 3) + 5 * trace (M ^ 2) - trace M := by
  native_decide

theorem trace_recurrence_5 :
    trace (M ^ 5) = 5 * trace (M ^ 4) + 5 * trace (M ^ 3) - trace (M ^ 2) := by
  native_decide

/-! ## Cayley-Hamilton and Characteristic Polynomial -/

theorem M_cayley_hamilton : M ^ 3 = 5 • M ^ 2 + 5 • M - 1 := by native_decide

theorem char_poly_factor (x : ℤ) :
    x ^ 3 - 5 * x ^ 2 - 5 * x + 1 = (x + 1) * (x ^ 2 - 6 * x + 1) := by ring

/-- Product of eigenvalues of x²-6x+1: (3+2√2)(3-2√2) = 9-8 = 1 -/
theorem eigenvalue_product : (3 : ℤ) ^ 2 - (2 : ℤ) ^ 2 * 2 = 1 := by norm_num

/-- Sum of eigenvalues: 6 -/
theorem eigenvalue_sum : (3 : ℤ) + 3 = 6 := by norm_num

/-! ## Berggren Tree Properties -/

/-- The root triple (3,4,5) is Pythagorean -/
theorem root_pyth : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

/-- Children of (3,4,5) under B₁, B₂, B₃ -/
theorem child_B1 : B₁.mulVec ![3, 4, 5] = ![5, 12, 13] := by native_decide
theorem child_B2 : B₂.mulVec ![3, 4, 5] = ![21, 20, 29] := by native_decide
theorem child_B3 : B₃.mulVec ![3, 4, 5] = ![15, 8, 17] := by native_decide

/-- All children are Pythagorean -/
theorem child_B1_pyth : (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num
theorem child_B2_pyth : (21 : ℤ) ^ 2 + 20 ^ 2 = 29 ^ 2 := by norm_num
theorem child_B3_pyth : (15 : ℤ) ^ 2 + 8 ^ 2 = 17 ^ 2 := by norm_num

/-- Ghost map sends (3,4,5) to (1,0,1) -/
theorem ghost_345 : M.mulVec ![3, 4, 5] = ![1, 0, 1] := by native_decide

/-- Second ghost ancestor of (3,4,5) -/
theorem ghost2_345 : (M ^ 2).mulVec ![3, 4, 5] = ![-1, 0, 1] := by native_decide

/-- Third ghost ancestor: M³(3,4,5) = (-3,-4,5) (legs negated, hypotenuse same) -/
theorem ghost3_345 : (M ^ 3).mulVec ![3, 4, 5] = ![-3, -4, 5] := by native_decide

/-! ## Well-Foundedness of Descent -/

/-- For PPT (a,b,c) with positive legs and c≥5, ghost hypotenuse < c -/
theorem ghost_hyp_descent (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hbig : 5 ≤ c) :
    -2 * a - 2 * b + 3 * c < c := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (a + b - c)]

/-! ## Semigroup Structure -/

/-- Non-commutativity of Berggren matrices -/
theorem B₁B₂_ne_B₂B₁ : B₁ * B₂ ≠ B₂ * B₁ := by native_decide
theorem B₁B₃_ne_B₃B₁ : B₁ * B₃ ≠ B₃ * B₁ := by native_decide
theorem B₂B₃_ne_B₃B₂ : B₂ * B₃ ≠ B₃ * B₂ := by native_decide

/-- The three child triples of (3,4,5) are all distinct -/
theorem children_distinct :
    B₁.mulVec ![3, 4, 5] ≠ B₂.mulVec ![3, 4, 5] ∧
    B₁.mulVec ![3, 4, 5] ≠ B₃.mulVec ![3, 4, 5] ∧
    B₂.mulVec ![3, 4, 5] ≠ B₃.mulVec ![3, 4, 5] := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩

/-! ## Lorentz Group Structure

The Berggren matrices generate a subgroup of O(2,1;ℤ).
The ghost matrix M has eigenvalues {-1, 3+2√2, 3-2√2}.
-/

/-- M has -1 as an eigenvalue: (M+I) is singular -/
theorem M_eigenvalue_neg1 : det (M + 1) = 0 := by native_decide

/-- The eigenvalue -1 eigenvector is (1,-1,0) -/
theorem M_eigenvec_neg1 : M.mulVec ![1, -1, 0] = ![-1, 1, 0] := by native_decide

/-- (1,-1,0) is indeed a -1 eigenvector -/
theorem M_eigenvec_neg1' : M.mulVec ![1, -1, 0] = (-1 : ℤ) • ![1, -1, 0] := by native_decide

end GhostMatPow
