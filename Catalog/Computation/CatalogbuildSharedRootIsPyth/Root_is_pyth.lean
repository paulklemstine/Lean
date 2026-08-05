import Mathlib
import Shared.CatalogbuildSharedIspythtriple.IsPythTriple

/-! # CatalogBuild.Shared.Root_is_pyth

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1

The import of `Shared.CatalogbuildSharedIspythtriple.IsPythTriple` (supplying
`IsPythTriple`) was added; the statement and proof are unchanged.
-/

noncomputable section

/-- The root triple (3, 4, 5). -/
theorem root_is_pyth : IsPythTriple 3 4 5 := by norm_num [IsPythTriple]

end