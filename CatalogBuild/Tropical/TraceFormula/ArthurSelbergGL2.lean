/-! # CatalogBuild.Tropical.TraceFormula.ArthurSelbergGL2

Auto-generated from theorem catalog database.
Domain: Tropical/TraceFormula
Declarations: 1
-/

import Mathlib
import Tropical.Core.TropicalFactoring

/-- The S₂-invariance of the GL₂ tropical Schur polynomial. -/
theorem tropical_schur_GL2_invariant
    {a b : ℤ} (x₁ x₂ : ℤ) :
    min (a * x₁ + b * x₂) (b * x₁ + a * x₂) =
    min (a * x₂ + b * x₁) (b * x₂ + a * x₁) := by ring_nf; exact min_comm _ _
