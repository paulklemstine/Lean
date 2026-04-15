/-! # CatalogBuild.SPBBridge.TropicalAssociativity

Auto-generated from theorem catalog database.
Domain: SPBBridge
Declarations: 3
-/

import Mathlib
import SPBBridge.Core

noncomputable section

/-- The stated counterexample (1,1,-1) is actually an equality. -/
theorem tspb_counterexample_wrong :
    tspb (tspb 1 1) (-1) = tspb 1 (tspb 1 (-1)) := by
  unfold tspb; simp


/-- [Section: # Tropical SPB Associativity: Resolution of Open Question
The original SPB paper conjectured that tspb might NOT be associative, citing the
counterexample tspb(tspb(1,1),-1) ≠ tspb(1,tspb(1,-1)). However, that counterexample
is wrong: both sides equal -1. We PROVE that tspb IS associative.
## Key Insight
The tropical SPB has the clean representation:
tspb(x,y) = (|x - y| - |x + y|) / 2
Associativity follows from an identity on absolute values, provable by case analysis.
## Main Results
- `tspb_abs_formula`: tspb(x,y) = (|x-y| - |x+y|)/2
- `tspb_assoc`: tspb(tspb(x,y),z) = tspb(x,tspb(y,z))
- `tspb_counterexample_wrong`: The stated counterexample is actually an equality] -/
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
