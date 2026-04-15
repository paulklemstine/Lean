/-! # CatalogBuild.Computation.Factoring.QuaternionNorm

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 4
-/

import Mathlib

theorem quadruple_hypotenuse_nonneg (m n p q : ℤ) :
    0 ≤ m^2 + n^2 + p^2 + q^2 := by
  positivity

/-! ## Section 3: The Pell Obstacle -/

/-
**The Pell Obstacle**: The equation λ² - μ² = 1 has no nontrivial integer solutions.
    The only solutions are (λ, μ) = (±1, 0).
    This is the key obstruction preventing a direct generalization of
    Berggren matrices from 2D to 3D.
-/

def inQuadLattice (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)

/-
The zero vector is always in L₄(N).
-/

theorem zero_in_quadLattice (N : ℤ) : inQuadLattice N 0 0 0 := by
  exact ⟨ 0, by simp +decide ⟩

/-
L₄(N) is closed under negation.
-/

theorem neg_in_quadLattice (N : ℤ) (x y z : ℤ) (h : inQuadLattice N x y z) :
    inQuadLattice N (-x) (-y) (-z) := by
  simp_all +decide [ inQuadLattice ]

/-
**Factor Extraction**: If p | N and x² + y² + z² = k·N with
    gcd(x² + y², N) nontrivial, then we extract a factor.
-/
