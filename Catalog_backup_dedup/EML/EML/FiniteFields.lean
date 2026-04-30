import Mathlib

/-! # CatalogBuild.EML.FiniteFields

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

/-- SPB operation over ZMod p (for prime p with field structure). -/
def spbZMod (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)

/-- SPB is commutative over ZMod p. -/
theorem spbZMod_comm (x y : ZMod p) : spbZMod x y = spbZMod y x := by
  simp [spbZMod, add_comm, mul_comm]

/-- 0 is the identity for SPB over ZMod p. -/
theorem spbZMod_zero_right (x : ZMod p) : spbZMod x 0 = x := by
  simp [spbZMod]

/-- Negation is the inverse for SPB over ZMod p. -/
theorem spbZMod_neg (x : ZMod p) : spbZMod x (-x) = 0 := by
  simp [spbZMod]

/-- n-fold SPB iteration over ZMod p. -/
def spbIterZMod (x : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbZMod x (spbIterZMod x n)

/-- [Section: # CatalogBuild.EML.FiniteFields
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6] -/
theorem spbIterZMod_one (x : ZMod p) : spbIterZMod x 1 = x := by
  simp [spbIterZMod, spbZMod]

