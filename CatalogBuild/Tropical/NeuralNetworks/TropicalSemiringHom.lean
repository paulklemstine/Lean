/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalSemiringHom

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 1
-/

import Mathlib
import Tropical.NeuralNetworks.NDimLogSumExp
import Tropical.NeuralNetworks.SoftMaxConvergence

noncomputable section

/-- SoftMax is translation-equivariant: softMax c (x₁+d) (x₂+d) = softMax c x₁ x₂ + d -/
theorem softMax_shift (c x₁ x₂ d : ℝ) (hc : 0 < c) :
    SoftMaxConvergence.softMax c (x₁ + d) (x₂ + d) =
    SoftMaxConvergence.softMax c x₁ x₂ + d := by
  unfold SoftMaxConvergence.softMax
  rw [mul_add c x₁ d, mul_add c x₂ d]
  have h := logsumexp_shift (c * x₁) (c * x₂) (c * d)
  rw [h]
  field_simp


end
