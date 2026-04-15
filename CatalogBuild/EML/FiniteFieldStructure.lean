/-! # CatalogBuild.EML.FiniteFieldStructure

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5
-/

import Mathlib

/-- 0 is the identity. -/
theorem spbF_zero (x : ZMod p) : spbF x 0 = x := by simp [spbF]


/-- -x is the inverse. -/
theorem spbF_neg (x : ZMod p) : spbF x (-x) = 0 := by simp [spbF]


/-- SPB iteration. -/
def spbIterF (x : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbF x (spbIterF x n)


/-- [Section: # Deep Structure of SPB over Finite Fields
The SPB group over 𝔽_p has a beautiful dichotomy:
- p ≡ 1 (mod 4): group order divides p-1
- p ≡ 3 (mod 4): group order divides p+1
This file provides extensive computational verification of this structure.] -/
theorem spbIterF_zero (x : ZMod p) : spbIterF x 0 = 0 := rfl

theorem spbIterF_one (x : ZMod p) : spbIterF x 1 = x := by simp [spbIterF, spbF]

