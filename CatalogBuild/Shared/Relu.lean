/-! # CatalogBuild.Shared.Relu

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5
-/

import Mathlib

noncomputable section

/-- ReLU function: the bridge between neural networks and tropical algebra. -/
def relu (x : ℝ) : ℝ := max x 0


/-- [Section: # CatalogBuild.Shared.Relu
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5] -/
theorem relu_lipschitz (x y : ℝ) : |relu x - relu y| ≤ |x - y| := by
  unfold relu;
  grind


/-- ReLU is idempotent: applying it twice equals applying it once. -/
theorem relu_idempotent (x : ℝ) : relu (relu x) = relu x := by
  simp [relu]


/-- ReLU is non-negative. -/
theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_right x 0


/-- ReLU fixed-point characterization: fixed iff non-negative. -/
theorem relu_fixed_iff (x : ℝ) : relu x = x ↔ 0 ≤ x := by
  constructor
  · intro h; have := relu_nonneg x; linarith
  · intro h; simp [relu, max_eq_left h]


end
