/-! # CatalogBuild.Shared.BinaryEntropy

Auto-generated from theorem catalog database.
Domain: Probability
Declarations: 1
-/

import Mathlib

noncomputable section

noncomputable def binaryEntropy (p : ℝ) : ℝ :=
  -(p * Real.log p + (1 - p) * Real.log (1 - p))

/-
PROVIDED SOLUTION
Unfold binaryEntropy. binaryEntropy p = -(p log p + (1-p) log(1-p)). binaryEntropy (1-p) = -((1-p) log(1-p) + (1-(1-p)) log(1-(1-p))) = -((1-p)log(1-p) + p log p). These are equal by commutativity of addition. Use ring or simp.
-/

end
