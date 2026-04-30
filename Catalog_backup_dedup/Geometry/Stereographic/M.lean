import Mathlib

/-! # CatalogBuild.Shared.M

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 8
-/

/-- The ghost matrix M = B₂⁻¹ (in ℤ since det B₂ = -1) -/
def M : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, (-2); 2, 1, (-2); (-2), (-2), 3]

/-- Cayley-Hamilton: M³ = 5M² + 5M - I -/
theorem M_cayley_hamilton : M ^ 3 = 5 • M ^ 2 + 5 • M - 1 := by native_decide

/-- tr(M) = 5 -/
theorem M_trace : trace M = 5 := by native_decide

theorem M_cube : M ^ 3 = !![49, 50, (-70); 50, 49, (-70); (-70), (-70), 99] := by native_decide

/-- det(M) = -1 -/
theorem M_det : det M = -1 := by native_decide

/-- [Section: ## M² and M³ Explicit Forms] -/
theorem M_sq : M ^ 2 = !![9, 8, (-12); 8, 9, (-12); (-12), (-12), 17] := by native_decide

/-- M preserves the Lorentz metric: Mᵀ Q M = Q -/
theorem M_lorentz : Mᵀ * Q * M = Q := by native_decide

/-- M is the left inverse of B₂ -/
theorem M_mul_B₂ : M * B₂ = 1 := by native_decide

