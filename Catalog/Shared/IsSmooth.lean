/-! # CatalogBuild.Shared.IsSmooth

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

import CatalogBuild.Speculative.OpenDirections
import Mathlib

/-- [Section: # CatalogBuild.Shared.IsSmooth
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 1] -/
def isSmooth (B n : ℕ) : Prop := ∀ p, Nat.Prime p → p ∣ n → p ≤ B



