/-! # CatalogBuild.SPBBridge.Core

Auto-generated from theorem catalog database.
Domain: SPBBridge
Declarations: 1
-/

import Mathlib

noncomputable section

/-- Tropical SPB. -/
def tspb (x y : ℝ) : ℝ := max x y - max 0 (x + y)

-- Basic properties

end
