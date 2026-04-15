/-! # CatalogBuild.Shared.IsSmooth

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 1
-/

import CatalogBuild.Speculative.OpenDirections
import Mathlib

/-- [Section: ## 10. Smooth Number Theory] -/
def isSmooth (B n : ℕ) : Prop := ∀ p, Nat.Prime p → p ∣ n → p ≤ B

