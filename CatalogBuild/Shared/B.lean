/-! # CatalogBuild.Shared.B

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 9
-/

import Mathlib

def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric Q = diag(1, 1, -1). -/

theorem B₃_inv_formula : B₃_inv = Q * B₃ᵀ * Q := by native_decide

/-! ## §9. Factoring Connection -/

/-- **Core factoring theorem**: a Pythagorean triple with composite leg yields
    a factorization via difference of squares. -/

theorem B₃_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith

/-! ## §5. Hyperbolic Shortcut Composition -/

/-- Path concatenation corresponds to matrix multiplication. -/

theorem B₃_inv_mul : B₃_inv * B₃ = 1 := by native_decide

/-- B₃_inv is the right inverse of B₃. -/

theorem B₃_lorentz : B₃ᵀ * Q * B₃ = Q := by native_decide

/-- det(B₁) = 1: B₁ is in SO⁺(2,1;ℤ). -/

theorem B₃_preserves_lorentzQ (a b c : ℤ) :
    lorentzQ ![-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c] = lorentzQ ![a, b, c] := by
  simp [lorentzQ, Matrix.cons_val_zero, Matrix.cons_val_one]; ring


def B₃_inv : Matrix (Fin 3) (Fin 3) ℤ := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- B₁_inv is the left inverse of B₁. -/

theorem B₃_mul_inv : B₃ * B₃_inv = 1 := by native_decide

/-- The inverses are computed via Q · Bᵀ · Q (Lorentz adjoint). -/

theorem B₃_hyp_increases (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < -2*a + 2*b + 3*c := by nlinarith [sq_nonneg (c - a)]

/-- B₂-branch hypotenuse is at least 3c (geometric growth). -/
