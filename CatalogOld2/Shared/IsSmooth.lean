/-! # CatalogBuild.Shared.IsSmooth

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 1
-/

import CatalogBuild.Speculative.OpenDirections
import Mathlib

def isSmooth (B n : ℕ) : Prop := ∀ p, Nat.Prime p → p ∣ n → p ≤ B

