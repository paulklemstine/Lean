/-! # CatalogBuild.Shared.Softplus

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 2
-/

import Mathlib

noncomputable section

def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-- Softplus is always positive. -/

theorem softplus_pos (x : ℝ) : 0 < softplus x := by
  unfold softplus
  exact Real.log_pos (by linarith [Real.exp_pos x])

/-- Sigmoid function: σ(x) = 1/(1 + exp(-x)). -/

end
