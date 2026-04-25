/-! # CatalogBuild.Speculative.SciFi.Hyperspace_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SciFi.Hyperspace_2
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4] -/
theorem chord_distance_le_two {n : ℕ} (x y : EuclideanSpace ℝ (Fin n))
    (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) : dist x y ≤ 2 := by
  linarith [ dist_le_norm_add_norm x y ]


/-- The triangle inequality: a fundamental constraint of metric spaces.
In a fixed metric space, you cannot "cheat" distance. -/
theorem triangle_inequality_metric {X : Type*} [PseudoMetricSpace X]
    (x y z : X) : dist x z ≤ dist x y + dist y z :=
  dist_triangle x y z


/-- Distance is non-negative. -/
theorem dist_nonneg' {X : Type*} [PseudoMetricSpace X] (x y : X) : 0 ≤ dist x y :=
  dist_nonneg


/-- Distance is symmetric. -/
theorem dist_symm' {X : Type*} [PseudoMetricSpace X] (x y : X) : dist x y = dist y x :=
  dist_comm x y


end
