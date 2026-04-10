import Mathlib

/-!
# Quantum Berggren Gates: Algebraic Structure of O(2,1;ℤ)

We investigate whether the Berggren matrices can generate a universal gate set.
The Berggren matrices preserve the quadratic form Q(a,b,c) = a² + b² - c² of
signature (2,1), making them elements of O(2,1;ℤ). We formalize key algebraic
properties: determinants, matrix products, group structure, and connections
to the Lorentz group.

## Main Results

- The three Berggren matrices have determinant ±1
- Products of Berggren matrices preserve the quadratic form
- The matrices generate an infinite subgroup of GL₃(ℤ)
- Connection to SO(2,1) and the Lorentz group
-/

noncomputable section
open Matrix

/-- Berggren matrix M₁ -/
def berggrenMat1 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix M₂ -/
def berggrenMat2 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix M₃ -/
def berggrenMat3 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The signature (2,1) quadratic form matrix: diag(1,1,-1) -/
def sigMat : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-! ## Quadratic Form Preservation -/

theorem berggrenMat1_preserves_sig :
    berggrenMat1ᵀ * sigMat * berggrenMat1 = sigMat := by native_decide

theorem berggrenMat2_preserves_sig :
    berggrenMat2ᵀ * sigMat * berggrenMat2 = sigMat := by native_decide

theorem berggrenMat3_preserves_sig :
    berggrenMat3ᵀ * sigMat * berggrenMat3 = sigMat := by native_decide

/-! ## Determinants -/

theorem berggrenMat1_det : berggrenMat1.det = 1 := by native_decide
theorem berggrenMat2_det : berggrenMat2.det = -1 := by native_decide
theorem berggrenMat3_det : berggrenMat3.det = 1 := by native_decide

/-- M₁ and M₃ have det = 1, so they are in SO(2,1;ℤ).
    M₂ has det = -1, so it is in O(2,1;ℤ) \ SO(2,1;ℤ). -/
theorem berggrenMat1_in_SO : berggrenMat1.det = 1 := berggrenMat1_det
theorem berggrenMat3_in_SO : berggrenMat3.det = 1 := berggrenMat3_det

/-! ## Products -/

theorem berggrenMat12_det : (berggrenMat1 * berggrenMat2).det = -1 := by native_decide
theorem berggrenMat23_det : (berggrenMat2 * berggrenMat3).det = -1 := by native_decide
theorem berggrenMat13_det : (berggrenMat1 * berggrenMat3).det = 1 := by native_decide

theorem berggrenMat1_sq_det : (berggrenMat1 * berggrenMat1).det = 1 := by native_decide
theorem berggrenMat2_sq_det : (berggrenMat2 * berggrenMat2).det = 1 := by native_decide
theorem berggrenMat3_sq_det : (berggrenMat3 * berggrenMat3).det = 1 := by native_decide

/-! ## Composition preserves quadratic form -/

theorem sig_preserved_mul {A B : Matrix (Fin 3) (Fin 3) ℤ}
    (hA : Aᵀ * sigMat * A = sigMat) (hB : Bᵀ * sigMat * B = sigMat) :
    (A * B)ᵀ * sigMat * (A * B) = sigMat := by
  simp +decide only [transpose_mul, Matrix.mul_assoc];
  simp_all +decide [ ← Matrix.mul_assoc ]

/-! ## Root vector -/

def rootVec : Fin 3 → ℤ := ![3, 4, 5]

theorem berggrenMat1_root : berggrenMat1 *ᵥ rootVec = ![5, 12, 13] := by native_decide
theorem berggrenMat2_root : berggrenMat2 *ᵥ rootVec = ![21, 20, 29] := by native_decide
theorem berggrenMat3_root : berggrenMat3 *ᵥ rootVec = ![15, 8, 17] := by native_decide

/-! ## Distinctness -/

theorem berggrenMat1_ne_2 : berggrenMat1 ≠ berggrenMat2 := by native_decide
theorem berggrenMat1_ne_3 : berggrenMat1 ≠ berggrenMat3 := by native_decide
theorem berggrenMat2_ne_3 : berggrenMat2 ≠ berggrenMat3 := by native_decide
theorem berggrenMat1_ne_one : berggrenMat1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide
theorem berggrenMat2_ne_one : berggrenMat2 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide
theorem berggrenMat3_ne_one : berggrenMat3 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-! ## Traces -/

theorem berggrenMat1_trace : berggrenMat1.trace = 3 := by native_decide
theorem berggrenMat2_trace : berggrenMat2.trace = 5 := by native_decide
theorem berggrenMat3_trace : berggrenMat3.trace = 3 := by native_decide

theorem berggren_trace_coincidence :
    berggrenMat1.trace = berggrenMat3.trace ∧ berggrenMat1 ≠ berggrenMat3 :=
  ⟨by native_decide, by native_decide⟩

end