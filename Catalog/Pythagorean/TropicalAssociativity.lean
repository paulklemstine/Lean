/-! # CatalogBuild.Pythagorean.TropicalAssociativity

Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 3
-/

import Mathlib
import Pythagorean.Core

noncomputable section

/-- The stated counterexample (1,1,-1) is actually an equality. -/
theorem tspb_counterexample_wrong :
    tspb (tspb 1 1) (-1) = tspb 1 (tspb 1 (-1)) := by
  unfold tspb; simp



/-- [Section: # CatalogBuild.Pythagorean.TropicalAssociativity
Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 3] -/
theorem tspb_abs_formula (x y : ℝ) :
    tspb x y = (|x - y| - |x + y|) / 2 := by
  unfold tspb; cases abs_cases ( x - y ) <;> cases abs_cases ( x + y ) <;> cases max_cases x y <;> cases max_cases 0 ( x + y ) <;> linarith;



theorem tspb_assoc (x y z : ℝ) :
    tspb (tspb x y) z = tspb x (tspb y z) := by
  -- Unfold the definition of tspb using the provided formula.
  have h_tspb_def : ∀ x y : ℝ, tspb x y = (|x - y| - |x + y|) / 2 := by
    exact?;
  grind



end
