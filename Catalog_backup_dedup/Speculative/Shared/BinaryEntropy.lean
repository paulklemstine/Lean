import Mathlib

/-! # CatalogBuild.Shared.BinaryEntropy

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

noncomputable section

/-- The binary entropy function H(p) = -p log p - (1-p) log (1-p) is maximized at p = 1/2.
We prove a simpler property: symmetry H(p) = H(1-p). -/
noncomputable def binaryEntropy (p : ℝ) : ℝ :=
  -(p * Real.log p + (1 - p) * Real.log (1 - p))

end
