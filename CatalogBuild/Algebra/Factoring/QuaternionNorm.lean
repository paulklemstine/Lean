/-! # CatalogBuild.Algebra.Factoring.QuaternionNorm

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 4
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionNorm
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 4] -/
theorem quadruple_hypotenuse_nonneg (m n p q : ℤ) :
    0 ≤ m^2 + n^2 + p^2 + q^2 := by
  positivity


/-- The lattice L₄(N) consists of all integer triples (x, y, z) such that
x² + y² + z² ≡ 0 (mod N). A short vector in this lattice can reveal
factors of N. -/
def inQuadLattice (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)


/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionNorm
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 4] -/
theorem zero_in_quadLattice (N : ℤ) : inQuadLattice N 0 0 0 := by
  exact ⟨ 0, by simp +decide ⟩


/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionNorm
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 4] -/
theorem neg_in_quadLattice (N : ℤ) (x y z : ℤ) (h : inQuadLattice N x y z) :
    inQuadLattice N (-x) (-y) (-z) := by
  simp_all +decide [ inQuadLattice ]


