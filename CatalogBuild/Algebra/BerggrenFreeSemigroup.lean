/-! # CatalogBuild.Algebra.BerggrenFreeSemigroup

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 37
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.BerggrenFreeSemigroup
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 37] -/
def BF1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- [Section: # CatalogBuild.Speculative.BerggrenFreeSemigroup
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 37] -/
def BF2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- [Section: # CatalogBuild.Speculative.BerggrenFreeSemigroup
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 37] -/
def BF3 : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


theorem B12_noncomm : BF1 * BF2 ≠ BF2 * BF1 := by native_decide


theorem B13_noncomm : BF1 * BF3 ≠ BF3 * BF1 := by native_decide


theorem B23_noncomm : BF2 * BF3 ≠ BF3 * BF2 := by native_decide


theorem BF1_ne_id : BF1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem BF2_ne_id : BF2 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem BF3_ne_id : BF3 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B11_ne_id : BF1 * BF1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B12_ne_id : BF1 * BF2 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B13_ne_id : BF1 * BF3 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B21_ne_id : BF2 * BF1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B22_ne_id : BF2 * BF2 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B23_ne_id : BF2 * BF3 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B31_ne_id : BF3 * BF1 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B32_ne_id : BF3 * BF2 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem B33_ne_id : BF3 * BF3 ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


theorem depth2_all_distinct :
    BF1*BF1 ≠ BF1*BF2 ∧ BF1*BF1 ≠ BF1*BF3 ∧ BF1*BF1 ≠ BF2*BF1 ∧
    BF1*BF1 ≠ BF2*BF2 ∧ BF1*BF1 ≠ BF2*BF3 ∧ BF1*BF1 ≠ BF3*BF1 ∧
    BF1*BF1 ≠ BF3*BF2 ∧ BF1*BF1 ≠ BF3*BF3 ∧
    BF1*BF2 ≠ BF1*BF3 ∧ BF1*BF2 ≠ BF2*BF1 ∧ BF1*BF2 ≠ BF2*BF2 ∧
    BF1*BF2 ≠ BF2*BF3 ∧ BF1*BF2 ≠ BF3*BF1 ∧ BF1*BF2 ≠ BF3*BF2 ∧
    BF1*BF2 ≠ BF3*BF3 ∧
    BF1*BF3 ≠ BF2*BF1 ∧ BF1*BF3 ≠ BF2*BF2 ∧ BF1*BF3 ≠ BF2*BF3 ∧
    BF1*BF3 ≠ BF3*BF1 ∧ BF1*BF3 ≠ BF3*BF2 ∧ BF1*BF3 ≠ BF3*BF3 ∧
    BF2*BF1 ≠ BF2*BF2 ∧ BF2*BF1 ≠ BF2*BF3 ∧ BF2*BF1 ≠ BF3*BF1 ∧
    BF2*BF1 ≠ BF3*BF2 ∧ BF2*BF1 ≠ BF3*BF3 ∧
    BF2*BF2 ≠ BF2*BF3 ∧ BF2*BF2 ≠ BF3*BF1 ∧ BF2*BF2 ≠ BF3*BF2 ∧
    BF2*BF2 ≠ BF3*BF3 ∧
    BF2*BF3 ≠ BF3*BF1 ∧ BF2*BF3 ≠ BF3*BF2 ∧ BF2*BF3 ≠ BF3*BF3 ∧
    BF3*BF1 ≠ BF3*BF2 ∧ BF3*BF1 ≠ BF3*BF3 ∧
    BF3*BF2 ≠ BF3*BF3 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide


theorem det_BF1 : BF1.det = 1 := by native_decide


theorem det_BF2 : BF2.det = -1 := by native_decide


theorem det_BF3 : BF3.det = 1 := by native_decide


/-- The determinant map separates B₂ from B₁, B₃ -/
theorem det_separates_B2 : BF2.det ≠ BF1.det ∧ BF2.det ≠ BF3.det := by
  constructor <;> native_decide


theorem trace_BF1 : BF1.trace = 3 := by native_decide


theorem trace_BF2 : BF2.trace = 5 := by native_decide


theorem trace_BF3 : BF3.trace = 3 := by native_decide


/-- Trace separates B₂ (hyperbolic) from B₁, B₃ (parabolic) -/
theorem trace_separates : BF2.trace ≠ BF1.trace := by native_decide


def root345 : Matrix (Fin 3) (Fin 1) ℤ := !![(3 : ℤ); 4; 5]


theorem B1_root : BF1 * root345 = !![(5 : ℤ); 12; 13] := by native_decide


theorem B2_root : BF2 * root345 = !![(21 : ℤ); 20; 29] := by native_decide


theorem B3_root : BF3 * root345 = !![(15 : ℤ); 8; 17] := by native_decide


theorem roots_all_distinct :
    BF1 * root345 ≠ BF2 * root345 ∧
    BF1 * root345 ≠ BF3 * root345 ∧
    BF2 * root345 ≠ BF3 * root345 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide


theorem depth2_outputs_distinct :
    (BF1 * BF1) * root345 ≠ (BF1 * BF2) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF1 * BF3) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF2 * BF1) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF2 * BF2) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF2 * BF3) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF3 * BF1) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF3 * BF2) * root345 ∧
    (BF1 * BF1) * root345 ≠ (BF3 * BF3) * root345 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide


def Sswap : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]


theorem B3_conjugate_B1 : Sswap * BF1 * Sswap = BF3 := by native_decide


theorem S_involution : Sswap * Sswap = (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


/-- B₂ is self-conjugate under S (the leg-swap symmetry) -/
theorem B2_self_conjugate : Sswap * BF2 * Sswap = BF2 := by native_decide


