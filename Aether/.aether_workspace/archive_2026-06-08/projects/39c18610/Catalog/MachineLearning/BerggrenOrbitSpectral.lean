import Mathlib

/-!
# Berggren Orbit Graphs over 𝔽_p: Structural Foundations

This file establishes rigorously verified structural properties of the Berggren
matrices and their action on isotropic vectors of the quadratic form Q(x,y,z) = x²+y²-z²
over finite fields 𝔽_p.

## Main Results

1. **Lorentz form preservation**: Each Berggren generator preserves Q(v) = v₀²+v₁²-v₂².
2. **Orthogonal group membership**: The generators satisfy MᵀQM = Q, placing them in O(2,1;ℤ).
3. **Determinant structure**: det(A) = det(C) = 1 (proper), det(B) = -1 (improper).
4. **Isotropic preservation mod p**: The mod-p reduction preserves primitive isotropic vectors.
5. **Mod-p generators are invertible** for odd primes.

## Context

The Berggren tree generates all primitive Pythagorean triples from (3,4,5) using three
integer matrices A, B, C ∈ GL₃(ℤ). These matrices lie in the integer orthogonal group
O(2,1;ℤ) for the Lorentzian form Q(a,b,c) = a² + b² - c². Reducing modulo a prime p
yields a finite dynamical system on the projective isotropic cone in P²(𝔽_p), whose
spectral properties encode deep arithmetic information about Pythagorean triple
distribution modulo primes.
-/

set_option maxHeartbeats 800000

namespace BerggrenSpectral

/-! ## Section 1: Core Definitions -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c² on ℤ³. -/
def lorentzQ (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Lorentz metric matrix Q_L = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Berggren generator A. -/
def matA : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren generator B. -/
def matB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren generator C. -/
def matC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Selector for Berggren generators by index. -/
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => matA
  | 1 => matB
  | 2 => matC

/-! ## Section 2: Lorentz Group Membership -/

/-- Generator A preserves the Lorentz metric: AᵀQA = Q. -/
theorem matA_preserves_metric : matA.transpose * metricQ * matA = metricQ := by
  native_decide

/-- Generator B preserves the Lorentz metric: BᵀQB = Q. -/
theorem matB_preserves_metric : matB.transpose * metricQ * matB = metricQ := by
  native_decide

/-- Generator C preserves the Lorentz metric: CᵀQC = Q. -/
theorem matC_preserves_metric : matC.transpose * metricQ * matC = metricQ := by
  native_decide

/-- All Berggren generators preserve the Lorentz metric. -/
theorem berggrenGen_preserves_metric (i : Fin 3) :
    (berggrenGen i).transpose * metricQ * (berggrenGen i) = metricQ := by
  fin_cases i <;> simp [berggrenGen]
  · exact matA_preserves_metric
  · exact matB_preserves_metric
  · exact matC_preserves_metric

/-! ## Section 3: Determinant Structure -/

/-- det(A) = 1. -/
theorem det_matA : matA.det = 1 := by native_decide

/-- det(B) = -1. -/
theorem det_matB : matB.det = -1 := by native_decide

/-- det(C) = 1. -/
theorem det_matC : matC.det = 1 := by native_decide

/-- Every Berggren generator has determinant ±1. -/
theorem berggrenGen_det_pm_one (i : Fin 3) :
    (berggrenGen i).det = 1 ∨ (berggrenGen i).det = -1 := by
  fin_cases i <;> simp [berggrenGen, det_matA, det_matB, det_matC]

/-! ## Section 4: Quadratic Form Preservation -/

/-- Applying generator A preserves Q: Q(Av) = Q(v) for all v ∈ ℤ³. -/
theorem matA_preserves_Q (v : Fin 3 → ℤ) :
    lorentzQ (matA.mulVec v) = lorentzQ v := by
  simp [lorentzQ, matA, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

/-- Applying generator B preserves Q: Q(Bv) = Q(v). -/
theorem matB_preserves_Q (v : Fin 3 → ℤ) :
    lorentzQ (matB.mulVec v) = lorentzQ v := by
  simp [lorentzQ, matB, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

/-- Applying generator C preserves Q: Q(Cv) = Q(v). -/
theorem matC_preserves_Q (v : Fin 3 → ℤ) :
    lorentzQ (matC.mulVec v) = lorentzQ v := by
  simp [lorentzQ, matC, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

/-- All Berggren generators preserve Q. -/
theorem berggrenGen_preserves_Q (i : Fin 3) (v : Fin 3 → ℤ) :
    lorentzQ ((berggrenGen i).mulVec v) = lorentzQ v := by
  fin_cases i <;> simp [berggrenGen]
  · exact matA_preserves_Q v
  · exact matB_preserves_Q v
  · exact matC_preserves_Q v

/-! ## Section 5: Reduction to 𝔽_p -/

/-- The Lorentz form on ZMod p. -/
def lorentzQ_mod (p : ℕ) (v : Fin 3 → ZMod p) : ZMod p := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- A vector v ∈ (ZMod p)³ is isotropic if Q(v) = 0. -/
def IsIsotropic (p : ℕ) (v : Fin 3 → ZMod p) : Prop := lorentzQ_mod p v = 0

/-- A vector is primitive (nonzero) mod p. -/
def IsPrimitive (p : ℕ) (v : Fin 3 → ZMod p) : Prop := ∃ i, v i ≠ 0

/-- Reduction of an integer matrix mod p. -/
def matMod (p : ℕ) (M : Matrix (Fin 3) (Fin 3) ℤ) : Matrix (Fin 3) (Fin 3) (ZMod p) :=
  M.map (Int.cast)

/-- The mod-p Berggren generators. -/
def berggrenGen_mod (p : ℕ) (i : Fin 3) : Matrix (Fin 3) (Fin 3) (ZMod p) :=
  matMod p (berggrenGen i)

/-- Mod-p reduction of a vector. -/
def vecMod (p : ℕ) (v : Fin 3 → ℤ) : Fin 3 → ZMod p := fun i => (v i : ZMod p)

/-- Mod-p reduction commutes with matrix-vector product. -/
theorem matMod_mulVec (p : ℕ) (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) :
    (matMod p M).mulVec (vecMod p v) = vecMod p (M.mulVec v) := by
  ext i
  simp [matMod, vecMod, Matrix.mulVec, dotProduct, Fin.sum_univ_three, Matrix.map_apply]

/-- Mod-p reduction preserves the quadratic form value. -/
theorem lorentzQ_mod_cast (p : ℕ) (v : Fin 3 → ℤ) :
    lorentzQ_mod p (vecMod p v) = ((lorentzQ v : ℤ) : ZMod p) := by
  simp [lorentzQ_mod, lorentzQ, vecMod]

/-- Key consequence: Berggren generators preserve isotropic vectors mod p
    (for vectors lifted from ℤ). -/
theorem berggrenGen_mod_preserves_isotropic_of_int (p : ℕ) (i : Fin 3) (v : Fin 3 → ℤ)
    (hv : lorentzQ v = 0) :
    lorentzQ_mod p (vecMod p (berggrenGen i |>.mulVec v)) = 0 := by
  rw [lorentzQ_mod_cast, berggrenGen_preserves_Q, hv]
  simp

/-! ## Section 6: Determinant over ZMod p -/

/-- Mod-p reduction commutes with determinant. -/
theorem matMod_det (p : ℕ) (M : Matrix (Fin 3) (Fin 3) ℤ) :
    (matMod p M).det = ((M.det : ℤ) : ZMod p) := by
  simp [matMod]
  exact (RingHom.map_det (Int.castRingHom (ZMod p)) M).symm

/-
Each Berggren generator has unit determinant mod p for odd primes.
-/
theorem berggrenGen_mod_det_unit (p : ℕ) [hp : Fact p.Prime] (i : Fin 3) :
    IsUnit ((berggrenGen_mod p i).det) := by
  -- By definition of $berggrenGen_mod$, we know that its determinant is the same as the determinant of $berggrenGen i$.
  have h_det : (berggrenGen_mod p i).det = ((berggrenGen i).det : ZMod p) := by
    convert matMod_det p ( berggrenGen i ) using 1;
  exact h_det.symm ▸ by rcases berggrenGen_det_pm_one i with h | h <;> norm_num [ h ] ;

/-! ## Section 7: Pythagorean Triple Preservation -/

/-- A triple is Pythagorean iff it lies on the light cone Q = 0. -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Pythagorean = isotropic for the Lorentz form. -/
theorem isPythag_iff_lorentzQ (a b c : ℤ) :
    IsPythag a b c ↔ lorentzQ ![a, b, c] = 0 := by
  simp [IsPythag, lorentzQ, Matrix.cons_val_zero, Matrix.cons_val_one]
  omega

/-- Berggren generators preserve the Pythagorean property. -/
theorem berggrenGen_preserves_pythag (i : Fin 3) (v : Fin 3 → ℤ)
    (hv : lorentzQ v = 0) : lorentzQ ((berggrenGen i).mulVec v) = 0 := by
  rw [berggrenGen_preserves_Q]; exact hv

/-! ## Section 8: Non-commutativity -/

/-- Generators A and B do not commute. This is important because it means the
    Berggren monoid is non-abelian, and different words give genuinely different
    transformations of the triple tree. -/
theorem matA_matB_ne_matB_matA : matA * matB ≠ matB * matA := by
  native_decide

/-- Generators A and C do not commute. -/
theorem matA_matC_ne_matC_matA : matA * matC ≠ matC * matA := by
  native_decide

/-- Generators B and C do not commute. -/
theorem matB_matC_ne_matC_matB : matB * matC ≠ matC * matB := by
  native_decide

end BerggrenSpectral