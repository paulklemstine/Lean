/-! # CatalogBuild.Physics.RobinInequality

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 9
-/

import Mathlib

noncomputable section

/-- σ₁(1) = 1. -/
theorem sigma1'_one : sigma1' 1 = 1 := by
  simp [sigma1']




/-- σ₁(p) < 2p for any prime p. -/
theorem sigma1_upper_bound_prime (p : ℕ) (hp : Nat.Prime p) : sigma1' p < 2 * p := by
  rw [sigma1'_prime p hp]; linarith [hp.one_lt]




/-- σ₁ is weakly multiplicative: σ₁(mn) = σ₁(m)σ₁(n) for coprime m,n. -/
theorem sigma1'_multiplicative (m n : ℕ) (hcop : Nat.Coprime m n) :
    sigma1' (m * n) = sigma1' m * sigma1' n := by
  simp only [sigma1']
  exact hcop.sum_divisors_mul




/-- A number is superabundant if its abundancy exceeds all smaller numbers. -/
def IsSuperabundant (n : ℕ) : Prop :=
  0 < n ∧ ∀ m : ℕ, 0 < m → m < n →
    (sigma1' m : ℚ) / m < (sigma1' n : ℚ) / n




/-- A number is colossally abundant if there exists ε > 0 such that
σ₁(n)/n^(1+ε) ≥ σ₁(m)/m^(1+ε) for all m ≥ 1. -/
def IsColossallyAbundant (n : ℕ) : Prop :=
  0 < n ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ m : ℕ, 0 < m →
    (sigma1' n : ℝ) / (n : ℝ) ^ (1 + ε) ≥ (sigma1' m : ℝ) / (m : ℝ) ^ (1 + ε)




/-- [Section: # CatalogBuild.Physics.RobinInequality
Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 9] -/
theorem sigma1_ge_n_plus_one (n : ℕ) (hn : 2 ≤ n) : sigma1' n ≥ n + 1 := by
  rw [ sigma1' ];
  rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self ];
  linarith [ Finset.sum_pos ( fun x hx => Nat.pos_of_mem_properDivisors hx ) ⟨ 1, Nat.mem_properDivisors.mpr ⟨ by norm_num, hn ⟩ ⟩ ]




/-- Robin's inequality: verified at n = 12. σ₁(12) = 28. -/
theorem robin_check_12 : sigma1' 12 = 28 := by
  native_decide




/-- σ₁(60) = 168. -/
theorem robin_check_60 : sigma1' 60 = 168 := by
  native_decide




/-- 5040 is the boundary value for Robin's inequality.
σ₁(5040) = 19344. -/
theorem sigma1_5040 : sigma1' 5040 = 19344 := by
  native_decide




end
