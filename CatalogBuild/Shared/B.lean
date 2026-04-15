/-! # CatalogBuild.Shared.B

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 9
-/

import Mathlib

/-- Berggren matrix B₃ (right branch). -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]


/-- B₃ preserves the Pythagorean property. -/
theorem B₃_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith


/-- B₃_inv is the left inverse of B₃. -/
theorem B₃_inv_mul : B₃_inv * B₃ = 1 := by native_decide


/-- The hypotenuse strictly increases under B₃ when a² + b² = c², b > 0, c > 0. -/
theorem B₃_hyp_increases (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < -2*a + 2*b + 3*c := by nlinarith [sq_nonneg (c - a)]


theorem B₃_inv_formula : B₃_inv = Q * B₃ᵀ * Q := by native_decide


/-- B₃ preserves the Lorentz form for any vector. -/
theorem B₃_preserves_lorentzQ (a b c : ℤ) :
    lorentzQ ![-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c] = lorentzQ ![a, b, c] := by
  simp [lorentzQ, Matrix.cons_val_zero, Matrix.cons_val_one]; ring


/-- B₃ preserves the Lorentz form. -/
theorem B₃_lorentz : B₃ᵀ * Q * B₃ = Q := by native_decide


/-- B₃_inv is the right inverse of B₃. -/
theorem B₃_mul_inv : B₃ * B₃_inv = 1 := by native_decide


/-- Inverse of B₃: computed as Q · B₃ᵀ · Q. -/
def B₃_inv : Matrix (Fin 3) (Fin 3) ℤ := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

