import Mathlib

/-! # CatalogBuild.EML.FiniteFieldStructure

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5
-/

/-- 0 is the identity. -/
theorem spbF_zero (x : ZMod p) : spbF x 0 = x := by simp [spbF]

/-- -x is the inverse. -/
theorem spbF_neg (x : ZMod p) : spbF x (-x) = 0 := by simp [spbF]

/-- SPB iteration. -/
def spbIterF (x : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbF x (spbIterF x n)

/-- [Section: # CatalogBuild.EML.FiniteFieldStructure
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem spbIterF_zero (x : ZMod p) : spbIterF x 0 = 0 := rfl

/-- [Section: # CatalogBuild.EML.FiniteFieldStructure
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem spbIterF_one (x : ZMod p) : spbIterF x 1 = x := by simp [spbIterF, spbF]