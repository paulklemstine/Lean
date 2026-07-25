import Mathlib

/-! # CatalogBuild.Shared.Softplus

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 2
-/

noncomputable section

/-- ReLU is not directly an EML neuron, but can be approximated.
Softplus(x) = ln(1 + exp(x)) ≈ ReLU(x) is expressible via EML components. -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-- Softplus is always positive. -/
theorem softplus_pos (x : ℝ) : 0 < softplus x := by
  unfold softplus
  exact Real.log_pos (by linarith [Real.exp_pos x])

end
