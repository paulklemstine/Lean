import Mathlib

/-! # CatalogBuild.Shared.Root_is_pyth

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

noncomputable section

/-- Pythagorean triple predicate -/
def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The root triple (3, 4, 5). -/
theorem root_is_pyth : IsPythTriple 3 4 5 := by norm_num [IsPythTriple]

end