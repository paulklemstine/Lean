/-! # CatalogBuild.Logic.ComputabilityTheory

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3
-/

import Mathlib

/-- [Section: # CatalogBuild.Logic.ComputabilityTheory
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3] -/
theorem cantor_diag {α : Type*} (f : α → Set α) : ¬ Function.Surjective f :=
  Function.cantor_surjective f

-- Incompressible strings


/-- [Section: # CatalogBuild.Logic.ComputabilityTheory
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3] -/
theorem incompressible (n : ℕ) : 2 ^ n ≥ 1 := Nat.one_le_two_pow

-- IOF step


/-- [Section: # CatalogBuild.Logic.ComputabilityTheory
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3] -/
theorem iof_step (p : ℕ) (hp : 3 ≤ p) : (p - 1) / 2 < p := by omega


