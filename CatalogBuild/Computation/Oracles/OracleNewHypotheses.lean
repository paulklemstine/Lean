/-! # CatalogBuild.Computation.Oracles.OracleNewHypotheses

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17
-/

import Mathlib

noncomputable section

/-- The Oracle Bootstrap map on ℝ: f(x) = 3x² - 2x³ -/
def oracleBootstrap (x : ℝ) : ℝ := 3 * x ^ 2 - 2 * x ^ 3





/-- 0 is a fixed point of the Oracle Bootstrap. -/
theorem oracleBootstrap_fixed_zero : oracleBootstrap 0 = 0 := by
  simp [oracleBootstrap]





/-- 1 is a fixed point of the Oracle Bootstrap. -/
theorem oracleBootstrap_fixed_one : oracleBootstrap 1 = 1 := by
  simp [oracleBootstrap]; ring





/-- 1/2 is a fixed point of the Oracle Bootstrap. -/
theorem oracleBootstrap_fixed_half : oracleBootstrap (1/2 : ℝ) = 1/2 := by
  simp [oracleBootstrap]; ring





/-- The derivative of the bootstrap map: f'(x) = 6x - 6x² = 6x(1-x) -/
def oracleBootstrap_deriv (x : ℝ) : ℝ := 6 * x - 6 * x ^ 2





/-- The derivative vanishes at x = 0 (superattracting). -/
theorem oracleBootstrap_deriv_zero : oracleBootstrap_deriv 0 = 0 := by
  simp [oracleBootstrap_deriv]





/-- The derivative vanishes at x = 1 (superattracting). -/
theorem oracleBootstrap_deriv_one : oracleBootstrap_deriv 1 = 0 := by
  simp [oracleBootstrap_deriv]





/-- The derivative at x = 1/2 has value 3/2 (|f'(1/2)| > 1, so repelling). -/
theorem oracleBootstrap_deriv_half : oracleBootstrap_deriv (1/2 : ℝ) = 3/2 := by
  simp [oracleBootstrap_deriv]; ring





/-- [Section: # CatalogBuild.Computation.Oracles.OracleNewHypotheses
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem oracleBootstrap_fixedPoints :
    {x : ℝ | oracleBootstrap x = x} = {0, 1/2, 1} := by
  ext x
  simp [oracleBootstrap];
  grind +ring





/-- [Section: # CatalogBuild.Computation.Oracles.OracleNewHypotheses
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem bootstrap_preserves_idempotent {R : Type*} [CommRing R] (e : R)
    (he : e * e = e) : 3 * e ^ 2 - 2 * e ^ 3 = e := by
  grind +ring





/-- Every element is 1-potent (a^1 = a). -/
theorem is_1_potent {M : Type*} [Monoid M] (a : M) : IsNPotent a 1 := by
  simp [IsNPotent]





/-- Idempotent ↔ 2-potent. -/
theorem idempotent_iff_2_potent {M : Type*} [Monoid M] (a : M) :
    a ^ 2 = a ↔ IsNPotent a 2 := by
  simp [IsNPotent]





/-- [Section: # CatalogBuild.Computation.Oracles.OracleNewHypotheses
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem npotent_divisibility {M : Type*} [Monoid M] (a : M) (m n : ℕ)
    (hm : 1 ≤ m) (hn : 1 ≤ n)
    (hdiv : (m - 1) ∣ (n - 1))
    (hpot : IsNPotent a m) : IsNPotent a n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ IsNPotent ];
  obtain ⟨ k, hk ⟩ := hdiv;
  rcases m with ( _ | _ | m ) <;> simp_all +decide [ pow_succ, pow_mul ];
  refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, mul_assoc ]





/-- The n-potent set of a monoid. -/
def nPotentSet (M : Type*) [Monoid M] (n : ℕ) : Set M :=
  {a | IsNPotent a n}





/-- The n-potent set always contains 1. -/
theorem one_mem_nPotentSet (M : Type*) [Monoid M] (n : ℕ) (hn : 0 < n) :
    (1 : M) ∈ nPotentSet M n := by
  simp [nPotentSet, IsNPotent, one_pow]





/-- The n-potent filtration is monotone under the shifted divisibility order:
if (m-1) | (n-1), then NPot(m) ⊆ NPot(n). -/
theorem nPotentSet_monotone {M : Type*} [Monoid M] (m n : ℕ)
    (hm : 1 ≤ m) (hn : 1 ≤ n) (hdiv : (m - 1) ∣ (n - 1)) :
    nPotentSet M m ⊆ nPotentSet M n := by
  intro a ha
  exact npotent_divisibility a m n hm hn hdiv ha





theorem npotent_conjugation_invariant {G : Type*} [Group G] (a g : G) (n : ℕ) :
    IsNPotent a n ↔ IsNPotent (g * a * g⁻¹) n := by
  unfold IsNPotent; aesop;





end
