import Mathlib

/-! # CatalogBuild.Shared.Root_is_pyth

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

noncomputable section

/-- A Pythagorean triple.  (Supplied here: referenced but missing.) -/
def IsPythTriple (a b c : ℕ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The root triple (3, 4, 5). -/
theorem root_is_pyth : IsPythTriple 3 4 5 := by norm_num [IsPythTriple]

end