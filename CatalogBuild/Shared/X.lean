/-! # CatalogBuild.Shared.X

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 1
-/

import Mathlib

noncomputable section

/-- [Section: # Comprehensive Divisor Function Identity Library (E11)
A formally verified library of divisor function identities and their interrelations.
Addresses research direction E11 from the Gravitational Factoring research agenda v5.] -/
noncomputable def σ₁ (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

end
