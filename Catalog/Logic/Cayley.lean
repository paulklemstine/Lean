import Mathlib

/-! # CatalogBuild.Shared.Cayley

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 2
-/

noncomputable section

/-- The Cayley transform maps a real number to a point on the unit circle
in the complex plane: `cayley(x) = (1 + ix)/(1 - ix)`. -/
def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)

/-- [Section: # CatalogBuild.Shared.Cayley
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 2] -/
theorem cayley_normSq (x : ℝ) : Complex.normSq (cayley x) = 1 := by
  unfold cayley;
  norm_num [ Complex.normSq ];
  nlinarith

end