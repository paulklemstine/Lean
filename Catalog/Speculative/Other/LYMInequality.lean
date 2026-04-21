/-! # CatalogBuild.Speculative.Other.LYMInequality

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 1
-/

import Mathlib

/-- An antichain in the power set lattice: no element contains another. -/
def IsAntichain (𝒜 : Finset (Finset (Fin n))) : Prop :=
  ∀ A ∈ 𝒜, ∀ B ∈ 𝒜, A ⊆ B → A = B



