import Shared.FractalTruthMetric
import Novelty.TruthFractalDimension

/-!
# The metric and fractal dimension of truth

This file joins the existing first-disagreement metric on Boolean truth streams
with the existing box-counting theory of accepted finite prefixes.  It does not
introduce a second encoding: `FractalTruthMetric.Cantor` supplies the metric,
and `TruthFractalDimension.truthSet` supplies the prefix family.

The main theorem records the exact dimension `1 / 2`, hence in particular that
this model of truth is sparse (dimension below the ambient value `1`) but not
negligible (positive dimension).
-/

open FractalTruthMetric TruthFractalDimension

namespace FractalTruthDimension

/-- In the first-disagreement metric, a closed ball of radius `2⁻ⁿ` is exactly
an equivalence class of streams having the same first `n` truth values. -/
theorem closedBall_scale_iff_prefix (x y : ℕ → Bool) (n : ℕ) :
    cantorDist x y ≤ (2 : ℝ) ^ (-(n : ℤ)) ↔ AgreeTo n x y := by
  exact cantorDist_le_iff_agreeTo x y n

/-- The first-disagreement distance obeys the strong triangle inequality. -/
theorem truth_distance_ultrametric (x y z : ℕ → Bool) :
    cantorDist x z ≤ max (cantorDist x y) (cantorDist y z) := by
  exact cantorDist_ultra x y z

/-- The chosen truth-prefix family has exact box dimension `1/2`; consequently
its dimension is strictly between the zero-dimensional and full-dimensional
extremes. -/
theorem truth_has_nontrivial_fractal_dimension :
    boxDim truthSet = (1 / 2 : ℝ) ∧
      0 < boxDim truthSet ∧ boxDim truthSet < 1 := by
  refine ⟨boxDim_truthSet, ?_⟩
  exact truthSet_dimension_strictly_between

/-- Combined metric/dimension statement: prefix cylinders are the natural
metric balls, and the accepted truth-prefix family has dimension strictly
between `0` and `1`. -/
theorem metric_truth_fractal_dimension (x y : ℕ → Bool) (n : ℕ) :
    (cantorDist x y ≤ (2 : ℝ) ^ (-(n : ℤ)) ↔ AgreeTo n x y) ∧
      0 < boxDim truthSet ∧ boxDim truthSet < 1 := by
  refine ⟨closedBall_scale_iff_prefix x y n, ?_⟩
  exact truthSet_dimension_strictly_between

end FractalTruthDimension