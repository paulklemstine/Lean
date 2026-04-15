/-! # CatalogBuild.Shared.SpbCirc

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 4
-/

import Mathlib

noncomputable section

/-- The circular SPB. -/
def spbCirc (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition). -/

theorem spbCirc_neg (x : ℝ) : spbCirc x (-x) = 0 := by
  simp [spbCirc]

/-- Hyperbolic SPB inverse. -/

theorem spbCirc_comm (x y : ℝ) : spbCirc x y = spbCirc y x := by
  simp [spbCirc, add_comm, mul_comm]

/-- Hyperbolic SPB is commutative. -/

theorem spbCirc_zero (x : ℝ) : spbCirc x 0 = x := by
  simp [spbCirc]

/-- Hyperbolic SPB identity. -/

end
