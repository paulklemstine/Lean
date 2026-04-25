/-! # CatalogBuild.Speculative.SPBFiniteFieldOrder

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SPBFiniteFieldOrder
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3] -/
def spbMod (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)


/-- [Section: # CatalogBuild.Speculative.SPBFiniteFieldOrder
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3] -/
def spbModIter (g : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbMod g (spbModIter g n)


/-- [Section: # CatalogBuild.Speculative.SPBFiniteFieldOrder
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3] -/
theorem spbModIter_one (g : ZMod p) : spbModIter g 1 = g := by
  simp [spbModIter, spbMod]


