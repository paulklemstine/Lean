/-! # CatalogBuild.Shared.Spb

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 1
-/

import Mathlib

noncomputable section

/-- The SPB operator. -/
def spb' (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- n-fold SPB self-composition: spbPow'(x, n) = "x composed n times under SPB". -/

end
