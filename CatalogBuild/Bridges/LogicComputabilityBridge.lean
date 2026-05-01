/-! # CatalogBuild.Bridges.LogicComputabilityBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

import Mathlib

/-- Multiplicativity: exp(a+a') = exp(a) * exp(a') -/
theorem truth_multiplicativity (a a' : ℝ) : 
    Real.exp (a + a') = Real.exp a * Real.exp a' := by
  exact Real.exp_add a a'


/-- F(n+2) = F(n) + F(n+1): the standard recurrence -/
theorem fib_recurrence (n : ℕ) : 
    Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := by
  exact Nat.fib_add_two


/-- F(1) = 1 -/
theorem fib_one_eq : Nat.fib 1 = 1 := by decide


/-- F(2) = 1 -/
theorem fib_two_eq : Nat.fib 2 = 1 := by decide


/-- Sum of nonneg reals is nonneg -/
theorem sum_nonneg_domain {D : Type*} [Fintype D] (f : D → ℝ) (hf : ∀ d, 0 ≤ f d) :
    0 ≤ ∑ d : D, f d := by
  apply Finset.sum_nonneg; intro d _; exact hf d

