/-! # CatalogBuild.Algebra.IntegerEnergy.QuantumBerggren

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 59
-/

import Mathlib

/-- Berggren gate B₁ -/
def BG₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- Berggren gate B₂ -/
def BG₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- Berggren gate B₃ -/
def BG₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


/-- Inverse gate B₁⁻¹ -/
def BG₁_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, (-2); (-2), (-1), 2; (-2), (-2), 3]


/-- Inverse gate B₂⁻¹ -/
def BG₂_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, (-2); 2, 1, (-2); (-2), (-2), 3]


/-- Inverse gate B₃⁻¹ -/
def BG₃_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), (-2), 2; 2, 1, (-2); (-2), (-2), 3]


/-- [Section: # CatalogBuild.Physics.Quantum.QuantumBerggren
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 59] -/
theorem BG₁_mul_inv : BG₁ * BG₁_inv = 1 := by native_decide


/-- [Section: # CatalogBuild.Physics.Quantum.QuantumBerggren
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 59] -/
theorem BG₂_mul_inv : BG₂ * BG₂_inv = 1 := by native_decide


/-- [Section: # CatalogBuild.Physics.Quantum.QuantumBerggren
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 59] -/
theorem BG₃_mul_inv : BG₃ * BG₃_inv = 1 := by native_decide


theorem BG₁_inv_mul : BG₁_inv * BG₁ = 1 := by native_decide


theorem BG₂_inv_mul : BG₂_inv * BG₂ = 1 := by native_decide


theorem BG₃_inv_mul : BG₃_inv * BG₃ = 1 := by native_decide


/-- B₁ preserves the Lorentz form (unitarity analogue) -/
theorem BG₁_unitary : BG₁ᵀ * QLor * BG₁ = QLor := by native_decide


/-- B₂ preserves the Lorentz form -/
theorem BG₂_unitary : BG₂ᵀ * QLor * BG₂ = QLor := by native_decide


/-- B₃ preserves the Lorentz form -/
theorem BG₃_unitary : BG₃ᵀ * QLor * BG₃ = QLor := by native_decide


/-- B₁⁻¹ preserves the Lorentz form -/
theorem BG₁_inv_unitary : BG₁_invᵀ * QLor * BG₁_inv = QLor := by native_decide


/-- B₂⁻¹ preserves the Lorentz form -/
theorem BG₂_inv_unitary : BG₂_invᵀ * QLor * BG₂_inv = QLor := by native_decide


/-- B₃⁻¹ preserves the Lorentz form -/
theorem BG₃_inv_unitary : BG₃_invᵀ * QLor * BG₃_inv = QLor := by native_decide


/-- Reflection R₁₂ = B₁ · B₂⁻¹ -/
def R₁₂ : Matrix (Fin 3) (Fin 3) ℤ := BG₁ * BG₂_inv


/-- Reflection R₁₃ = B₁ · B₃⁻¹ -/
def R₁₃ : Matrix (Fin 3) (Fin 3) ℤ := BG₁ * BG₃_inv


/-- Reflection R₂₃ = B₂ · B₃⁻¹ -/
def R₂₃ : Matrix (Fin 3) (Fin 3) ℤ := BG₂ * BG₃_inv


/-- **Main Theorem 1**: B₁ · B₂⁻¹ · B₁ = B₂ (gate swap identity) -/
theorem gate_swap_12 : BG₁ * BG₂_inv * BG₁ = BG₂ := by native_decide


/-- **Main Theorem 2**: B₁ · B₃⁻¹ · B₁ = B₃ (gate swap identity) -/
theorem gate_swap_13 : BG₁ * BG₃_inv * BG₁ = BG₃ := by native_decide


/-- **Main Theorem 3**: B₂ · B₃⁻¹ · B₂ = B₃ (gate swap identity) -/
theorem gate_swap_23 : BG₂ * BG₃_inv * BG₂ = BG₃ := by native_decide


/-- R₁₂ is an involution: R₁₂² = I -/
theorem R₁₂_involution : R₁₂ * R₁₂ = 1 := by native_decide


/-- R₁₃ is an involution: R₁₃² = I -/
theorem R₁₃_involution : R₁₃ * R₁₃ = 1 := by native_decide


/-- R₂₃ is an involution: R₂₃² = I -/
theorem R₂₃_involution : R₂₃ * R₂₃ = 1 := by native_decide


/-- Reflections preserve the Lorentz form -/
theorem R₁₂_unitary : R₁₂ᵀ * QLor * R₁₂ = QLor := by native_decide


theorem R₁₃_unitary : R₁₃ᵀ * QLor * R₁₃ = QLor := by native_decide


theorem R₂₃_unitary : R₂₃ᵀ * QLor * R₂₃ = QLor := by native_decide


/-- det(R₁₂) = -1 (true reflection, orientation-reversing) -/
theorem det_R₁₂ : Matrix.det R₁₂ = -1 := by native_decide


/-- det(R₁₃) = 1 (orientation-preserving "rotation-reflection") -/
theorem det_R₁₃ : Matrix.det R₁₃ = 1 := by native_decide


/-- det(R₂₃) = -1 -/
theorem det_R₂₃ : Matrix.det R₂₃ = -1 := by native_decide


/-- Simplification: B₁ · B₂⁻¹ · B₁ · B₃ = B₂ · B₃ (saves 2 gates) -/
theorem simplify_121_to_2 :
    BG₁ * BG₂_inv * BG₁ * BG₃ = BG₂ * BG₃ := by
  rw [show BG₁ * BG₂_inv * BG₁ = BG₂ from gate_swap_12]


/-- Simplification: B₃ · B₁ · B₂⁻¹ · B₁ = B₃ · B₂ (saves 2 gates) -/
theorem simplify_pre_121_to_2 :
    BG₃ * (BG₁ * BG₂_inv * BG₁) = BG₃ * BG₂ := by
  rw [gate_swap_12]


/-- Double application: (B₁ · B₂⁻¹)² = I means circuit cancellation -/
theorem circuit_cancel_12 :
    BG₁ * BG₂_inv * BG₁ * BG₂_inv = 1 := by native_decide


/-- Double application: (B₁ · B₃⁻¹)² = I -/
theorem circuit_cancel_13 :
    BG₁ * BG₃_inv * BG₁ * BG₃_inv = 1 := by native_decide


/-- Double application: (B₂ · B₃⁻¹)² = I -/
theorem circuit_cancel_23 :
    BG₂ * BG₃_inv * BG₂ * BG₃_inv = 1 := by native_decide


theorem inv_gate_swap_12 : BG₁_inv * BG₂ * BG₁_inv = BG₂_inv := by native_decide


theorem inv_gate_swap_13 : BG₁_inv * BG₃ * BG₁_inv = BG₃_inv := by native_decide


theorem inv_gate_swap_23 : BG₂_inv * BG₃ * BG₂_inv = BG₃_inv := by native_decide


theorem BG₁_BG₂_ne_BG₂_BG₁ : BG₁ * BG₂ ≠ BG₂ * BG₁ := by native_decide


theorem BG₁_BG₃_ne_BG₃_BG₁ : BG₁ * BG₃ ≠ BG₃ * BG₁ := by native_decide


theorem BG₂_BG₃_ne_BG₃_BG₂ : BG₂ * BG₃ ≠ BG₃ * BG₂ := by native_decide


/-- The commutator [B₁, B₃] = B₁ · B₃ · B₁⁻¹ · B₃⁻¹ ≠ I -/
theorem commutator_13_nontrivial : BG₁ * BG₃ * BG₁_inv * BG₃_inv ≠ 1 := by native_decide


theorem det_BG₁ : Matrix.det BG₁ = 1 := by native_decide


theorem det_BG₂ : Matrix.det BG₂ = -1 := by native_decide


theorem det_BG₃ : Matrix.det BG₃ = 1 := by native_decide


/-- Parity rule: det(B₁ · B₂) = det(B₁) · det(B₂) = -1 -/
theorem det_BG₁_BG₂ : Matrix.det (BG₁ * BG₂) = -1 := by native_decide


/-- Even circuits (even number of B₂'s) have det = 1 -/
theorem det_BG₁_BG₂_BG₁_BG₂ : Matrix.det (BG₁ * BG₂ * BG₁ * BG₂) = 1 := by native_decide


/-- 2×2 Berggren matrix M₁ -/
def MG₁ : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]


/-- 2×2 Berggren matrix M₂ -/
def MG₂ : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]


/-- 2×2 Berggren matrix M₃ -/
def MG₃ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]


/-- det(M₁) = 1 (M₁ ∈ SL(2,ℤ)) -/
theorem det_MG₁ : Matrix.det MG₁ = 1 := by native_decide


/-- M₃ ∈ SL(2,ℤ) -/
theorem det_MG₃ : Matrix.det MG₃ = 1 := by
  simp [MG₃, Matrix.det_fin_two]


/-- The B₂ child's hypotenuse is at least 3× the parent's (when a,b > 0) -/
theorem hyp_growth_B2 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    2 * a + 2 * b + 3 * c ≥ 3 * c + 4 := by linarith

-- Gate count (depth) grows logarithmically: depth ≤ log₃(c/5).
-- This is a consequence of hypotenuse growth ≥ 3× per step.
-- Formal statement: at depth d, hypotenuse c ≥ 3^d · 5.
-- Therefore: d ≤ log₃(c/5).


/-- The Berggren group is a subgroup of O(2,1;ℤ). Every element
preserves the Pythagorean property. -/
theorem berggren_preserves_pyth_form (a b c : ℤ) :
    let (a₁, b₁, c₁) := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    a₁^2 + b₁^2 - c₁^2 = a^2 + b^2 - c^2 := by ring


theorem berggren_B2_preserves_form (a b c : ℤ) :
    let (a₂, b₂, c₂) := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    a₂^2 + b₂^2 - c₂^2 = a^2 + b^2 - c^2 := by ring


theorem berggren_B3_preserves_form (a b c : ℤ) :
    let (a₃, b₃, c₃) := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    a₃^2 + b₃^2 - c₃^2 = a^2 + b^2 - c^2 := by ring


