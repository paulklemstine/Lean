/-! # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicMagnetism

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 9
-/

import Mathlib

/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicMagnetism
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 9] -/
theorem multipole_decomposition_dim (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), (2 * k + 1) = (n + 1) ^ 2 := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicMagnetism
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 9] -/
theorem multipole_channels (n : ℕ) :
    (Finset.range (n + 1) \ {0}).card = n := by
  rw [ Finset.card_sdiff ] ; norm_num [ Finset.card_range ]


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicMagnetism
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 9] -/
theorem exchange_tensor_decomposition : 1 + 3 + 5 = 3 * 3 := by
  norm_num +zetaDelta at *


theorem antisymmetric_dim : 3 * (3 - 1) / 2 = 3 := by
  grind


theorem clebsch_gordan_equal (n : ℕ) :
    (n + 1) * (n + 1) = ∑ k ∈ Finset.range (n + 1), (2 * n - 2 * k + 1) := by
  exact Nat.recOn n ( by norm_num ) fun m ih => by simp_all +decide [ Nat.mul_succ, Finset.sum_range_succ', add_mul ] ; linarith [ Nat.sub_add_cancel <| show 2 * m ≤ 2 * m + 2 by linarith ] ;


theorem casimir_monotone (n₁ n₂ : ℕ) (h : n₁ < n₂) :
    n₁ * (n₁ + 2) < n₂ * (n₂ + 2) := by
  nlinarith


theorem operator_space_grows (n : ℕ) :
    (n + 1) ^ 2 / (n + 1) = n + 1 := by
  norm_num [ sq ]


theorem commutant_bounds (N : ℕ) (hN : N ≥ 1) :
    N ≤ N ^ 2 := by
  nlinarith


theorem sum_naturals (n : ℕ) :
    2 * ∑ k ∈ Finset.range n, k = n * (n - 1) := by
  exact Eq.symm ( Nat.recOn n ( by norm_num ) fun n ih => by cases n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith )


