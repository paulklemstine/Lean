/-! # CatalogBuild.EML.v8.BerggrenUnipotentPowers

Auto-generated from theorem catalog database.
Domain: EML/v8
Declarations: 17
-/

import Mathlib

def BM1_u : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

def BM3_u : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

def Sswap_u : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]


/-- (B₁ - I)³ = 0 -/
theorem B1_minus_I_cubed_zero :
    (BM1_u - 1) * (BM1_u - 1) * (BM1_u - 1) = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide


/-- (B₁ - I)² ≠ 0, so nilpotency index is exactly 3 -/
theorem B1_minus_I_sq_ne_zero :
    (BM1_u - 1) * (BM1_u - 1) ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide


/-- (B₃ - I)³ = 0 -/
theorem B3_minus_I_cubed_zero :
    (BM3_u - 1) * (BM3_u - 1) * (BM3_u - 1) = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide


/-- (B₃ - I)² ≠ 0 -/
theorem B3_minus_I_sq_ne_zero :
    (BM3_u - 1) * (BM3_u - 1) ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide


theorem B1_sq : BM1_u * BM1_u = !![1, (-4 : ℤ), 4; 4, -7, 8; 4, -8, 9] := by native_decide


theorem B1_cubed : BM1_u * BM1_u * BM1_u =
    !![1, (-6 : ℤ), 6; 6, -17, 18; 6, -18, 19] := by native_decide


theorem B1_sq_root : (BM1_u * BM1_u) * !![(3:ℤ); 4; 5] = !![(7:ℤ); 24; 25] := by native_decide

theorem B1_cubed_root :
    (BM1_u * BM1_u * BM1_u) * !![(3:ℤ); 4; 5] = !![(9:ℤ); 40; 41] := by native_decide

-- Pattern: B₁ⁿ·(3,4,5) = (2n+3, ..., 2n²+6n+5) for the A-branch
-- n=0: (3, 4, 5)   ← 2·0+3=3, 2·0+6·0+5=5 ✓
-- n=1: (5, 12, 13)  ← 2·1+3=5, 2+6+5=13 ✓
-- n=2: (7, 24, 25)  ← 2·2+3=7, 8+12+5=25 ✓
-- n=3: (9, 40, 41)  ← 2·3+3=9, 18+18+5=41 ✓


theorem ppt_5_12_13 : (5:ℤ)^2 + 12^2 = 13^2 := by norm_num

theorem ppt_7_24_25 : (7:ℤ)^2 + 24^2 = 25^2 := by norm_num

theorem ppt_9_40_41 : (9:ℤ)^2 + 40^2 = 41^2 := by norm_num


theorem B3_conj_u : Sswap_u * BM1_u * Sswap_u = BM3_u := by native_decide

theorem S_involution_u : Sswap_u * Sswap_u = (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


/-- B₁ satisfies (x-1)³ = 0, i.e., B₁³ - 3B₁² + 3B₁ - I = 0 -/
theorem B1_cayley :
    BM1_u * BM1_u * BM1_u - 3 • (BM1_u * BM1_u) + 3 • BM1_u - 1
    = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

