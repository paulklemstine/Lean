import Mathlib

/-!
# Berggren–Stern-Brocot Correspondence (Direction #51)

The Stern-Brocot tree generates all positive rationals, while the Berggren
tree generates all primitive Pythagorean triples. We establish a connection
through the Euclid parametrization and the theta group Γ_θ ⊂ SL(2,ℤ).

## Main Results

1. Euclid triples are always Pythagorean
2. The 2×2 Berggren matrices have determinant ±1
3. M₃ = R² (square of Stern-Brocot right step)
4. M₃⁻¹·M₁ = S (the modular group generator)
5. Connection to the theta group
-/

open Matrix

/-! ## §1. Euclid Parametrization -/

def euclidTriple (m n : ℤ) : ℤ × ℤ × ℤ := (m^2 - n^2, 2*m*n, m^2 + n^2)

theorem euclid_is_pyth (m n : ℤ) :
    let t := euclidTriple m n
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [euclidTriple]; ring

theorem euclid_345 : euclidTriple 2 1 = (3, 4, 5) := by
  simp [euclidTriple]

theorem euclid_5_12_13 : euclidTriple 3 2 = (5, 12, 13) := by
  simp [euclidTriple]

/-! ## §2. 2×2 Berggren Matrices -/

def BM2x2_1 : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]
def BM2x2_2 : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]
def BM2x2_3 : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

theorem det_BM2x2_1 : BM2x2_1.det = 1 := by native_decide
theorem det_BM2x2_2 : BM2x2_2.det = -1 := by native_decide
theorem det_BM2x2_3 : BM2x2_3.det = 1 := by native_decide

theorem M1_M3_in_SL2Z : BM2x2_1.det = 1 ∧ BM2x2_3.det = 1 :=
  ⟨det_BM2x2_1, det_BM2x2_3⟩

/-! ## §3. Stern-Brocot Connection -/

def T_mat : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]
def SB_R : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

theorem M3_is_T_sq : BM2x2_3 = T_mat * T_mat := by native_decide
theorem M3_is_R_sq : BM2x2_3 = SB_R * SB_R := by native_decide

/-! ## §4. Theta Group Connection -/

def S_2x2 : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]
def M3_inv : Matrix (Fin 2) (Fin 2) ℤ := !![1, -2; 0, 1]

theorem M3_inv_correct : M3_inv * BM2x2_3 = 1 := by native_decide
theorem M3_inv_correct' : BM2x2_3 * M3_inv = 1 := by native_decide
theorem S_2x2_sq : S_2x2 * S_2x2 = -1 := by native_decide
theorem M3inv_M1_is_S : M3_inv * BM2x2_1 = S_2x2 := by native_decide

/-! ## §5. Parameter Verification -/

theorem M1_root_params :
    BM2x2_1 * !![( 2 : ℤ); 1] = !![(3 : ℤ); 2] := by native_decide

theorem M2_root_params :
    BM2x2_2 * !![(2 : ℤ); 1] = !![(5 : ℤ); 2] := by native_decide

theorem M3_root_params :
    BM2x2_3 * !![(2 : ℤ); 1] = !![(4 : ℤ); 1] := by native_decide
