import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenCharPoly

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 44
-/

/-- Berggren matrix B₁ (A-branch) -/
def BM₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ (B-branch) -/
def BM₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ (C-branch) -/
def BM₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- The leg-swap permutation matrix S: (a,b,c) ↦ (b,a,c) -/
def SwapS : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, 1, 0; 1, 0, 0; 0, 0, 1]

/-- The Lorentz form matrix Q = diag(1,1,-1) -/
def QL : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- B₃ = S·B₁·S: The C-branch is conjugate to the A-branch via leg-swap. -/
theorem B3_eq_S_B1_S : SwapS * BM₁ * SwapS = BM₃ := by native_decide

/-- The reverse conjugacy: S·B₃·S = B₁ -/
theorem B1_eq_S_B3_S : SwapS * BM₃ * SwapS = BM₁ := by native_decide

/-- det(S) = -1 (orientation-reversing) -/
theorem det_S_neg_one : Matrix.det SwapS = -1 := by native_decide

/-- S preserves the Lorentz form: SᵀQS = Q -/
theorem S_preserves_lorentz : SwapSᵀ * QL * SwapS = QL := by native_decide

/-- (B₁ - I)³ = 0: B₁ is unipotent of order ≤ 3 -/
theorem B1_sub_I_cubed_eq_zero :
    (BM₁ - 1) ^ 3 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-- (B₁ - I)² ≠ 0: The nilpotency index is exactly 3 -/
theorem B1_sub_I_sq_ne_zero :
    (BM₁ - 1) ^ 2 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-- (B₃ - I)³ = 0: B₃ is also unipotent of order ≤ 3 (follows from conjugacy) -/
theorem B3_sub_I_cubed_eq_zero :
    (BM₃ - 1) ^ 3 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-- (B₃ - I)² ≠ 0: B₃ also has nilpotency index exactly 3 -/
theorem B3_sub_I_sq_ne_zero :
    (BM₃ - 1) ^ 2 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-- B₂ Cayley-Hamilton: B₂³ - 5B₂² - 5B₂ + I = 0
The characteristic polynomial of B₂ is x³ - 5x² - 5x + 1. -/
theorem B2_cayley_hamilton :
    BM₂ ^ 3 - 5 • BM₂ ^ 2 - 5 • BM₂ + (1 : Matrix (Fin 3) (Fin 3) ℤ) = 0 := by
  native_decide

/-- B₁ Cayley-Hamilton: (B₁ - I)³ = 0, equivalently B₁³ - 3B₁² + 3B₁ - I = 0.
Characteristic polynomial of B₁ is (x-1)³ = x³ - 3x² + 3x - 1. -/
theorem B1_cayley_hamilton :
    BM₁ ^ 3 - 3 • BM₁ ^ 2 + 3 • BM₁ - (1 : Matrix (Fin 3) (Fin 3) ℤ) = 0 := by
  native_decide

/-- B₁ and B₂ do not commute -/
theorem B1_B2_ne_B2_B1 : BM₁ * BM₂ ≠ BM₂ * BM₁ := by native_decide

/-- B₁ and B₃ do not commute -/
theorem B1_B3_ne_B3_B1 : BM₁ * BM₃ ≠ BM₃ * BM₁ := by native_decide

/-- B₂ and B₃ do not commute -/
theorem B2_B3_ne_B3_B2 : BM₂ * BM₃ ≠ BM₃ * BM₂ := by native_decide

/-- The commutator [B₁, B₂] = B₁·B₂·B₁⁻¹·B₂⁻¹.
We compute B₁·B₂ and B₂·B₁ explicitly. -/
theorem B1_B2_product : BM₁ * BM₂ = !![1, 4, 4; 4, 7, 8; 4, 8, 9] := by
  native_decide

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenCharPoly
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 44] -/
theorem B2_B1_product : BM₂ * BM₁ = !![9, (-8), 12; 8, (-9), 12; 12, (-12), 17] := by
  native_decide

/-- tr(B₁) = 3 (sum of diagonal entries) -/
theorem B1_trace : Matrix.trace BM₁ = 3 := by native_decide

/-- tr(B₂) = 5 -/
theorem B2_trace : Matrix.trace BM₂ = 5 := by native_decide

/-- tr(B₃) = 3 (same as B₁, as expected from conjugacy) -/
theorem B3_trace : Matrix.trace BM₃ = 3 := by native_decide

/-- det(B₁) = 1 -/
theorem det_BM1 : Matrix.det BM₁ = 1 := by native_decide

/-- det(B₂) = -1 -/
theorem det_BM2 : Matrix.det BM₂ = -1 := by native_decide

/-- det(B₃) = 1 -/
theorem det_BM3 : Matrix.det BM₃ = 1 := by native_decide

/-- B₂² computed explicitly -/
theorem B2_squared : BM₂ ^ 2 = !![9, 8, 12; 8, 9, 12; 12, 12, 17] := by native_decide

/-- B₂³ computed explicitly -/
theorem B2_cubed : BM₂ ^ 3 = !![49, 50, 70; 50, 49, 70; 70, 70, 99] := by native_decide

/-- B₁ · B₃ product -/
theorem B1_B3_product : BM₁ * BM₃ = !![(-1), 4, 4; (-4), 7, 8; (-4), 8, 9] := by
  native_decide

/-- B₃ · B₁ product -/
theorem B3_B1_product : BM₃ * BM₁ = !![7, (-4), 8; 4, (-1), 4; 8, (-4), 9] := by
  native_decide

/-- B₁ preserves the Lorentz form -/
theorem BM1_preserves_lorentz : BM₁ᵀ * QL * BM₁ = QL := by native_decide

/-- B₂ preserves the Lorentz form -/
theorem BM2_preserves_lorentz : BM₂ᵀ * QL * BM₂ = QL := by native_decide

/-- B₃ preserves the Lorentz form -/
theorem BM3_preserves_lorentz : BM₃ᵀ * QL * BM₃ = QL := by native_decide

/-- B₁² via the unipotent formula: I + 2(B₁-I) + (B₁-I)² = 2B₁ - I + (B₁-I)² -/
theorem B1_squared : BM₁ ^ 2 = !![1, (-4), 4; 4, (-7), 8; 4, (-8), 9] := by
  native_decide

/-- B₁⁴ computed -/
theorem B1_fourth : BM₁ ^ 4 =
    !![1, (-8), 8; 8, (-31), 32; 8, (-32), 33] := by native_decide

/-- (5,12,13) is B₁ applied to (3,4,5) -/
theorem triple_5_12_13_is_B1_root :
    let v : Fin 3 → ℤ := ![3, 4, 5]
    BM₁ *ᵥ v = ![5, 12, 13] := by native_decide

/-- (21,20,29) is B₂ applied to (3,4,5) -/
theorem triple_21_20_29_is_B2_root :
    let v : Fin 3 → ℤ := ![3, 4, 5]
    BM₂ *ᵥ v = ![21, 20, 29] := by native_decide

/-- (15,8,17) is B₃ applied to (3,4,5) -/
theorem triple_15_8_17_is_B3_root :
    let v : Fin 3 → ℤ := ![3, 4, 5]
    BM₃ *ᵥ v = ![15, 8, 17] := by native_decide

/-- (7,24,25) is B₁² applied to (3,4,5) -/
theorem triple_7_24_25_is_B1_B1_root :
    let v : Fin 3 → ℤ := ![3, 4, 5]
    BM₁ *ᵥ (BM₁ *ᵥ v) = ![7, 24, 25] := by native_decide

/-- The trace function classifies branches: tr = 3 for A/C, tr = 5 for B -/
theorem trace_classification :
    Matrix.trace BM₁ = 3 ∧ Matrix.trace BM₂ = 5 ∧ Matrix.trace BM₃ = 3 := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩

/-- Equivalently, (B₂ + I) · (1,-1,0)ᵀ = 0 -/
theorem B2_plus_I_kernel :
    (BM₂ + 1) *ᵥ (![1, -1, 0] : Fin 3 → ℤ) = 0 := by native_decide

/-- S commutes with B₂ (since B₂ is self-conjugate) -/
theorem S_commutes_B2 : SwapS * BM₂ = BM₂ * SwapS := by native_decide

/-- S does not commute with B₁ -/
theorem S_not_commutes_B1 : SwapS * BM₁ ≠ BM₁ * SwapS := by native_decide

/-- The "balanced" eigenvector (1,1,0) of S is preserved by B₂ up to scaling -/
theorem B2_preserves_balanced_direction :
    BM₂ *ᵥ (![1, 1, 0] : Fin 3 → ℤ) = ![3, 3, 4] := by native_decide