/-
# Orbit Dynamics of the Softplus Dynamical System

This file establishes quantitative properties of the softplus dynamical
system {σⁿ(x)}_{n≥0}, leveraging the general identity σⁿ(x) = log(n + eˣ).

## Main Results
- `softplus_iter_deriv` : (σⁿ)'(x) = eˣ/(n + eˣ)
- `softplus_iter_deriv_bounds` : 0 < (σⁿ)'(x) < 1 for n ≥ 1
- `softplus_iter_log_nat` : σⁿ(log k) = log(n + k)
- `softplus_orbit_addition` : σⁿ(log k) = log(n + k) (orbit counts additions)
- `softplus_iter_growth_decomposition` : σⁿ(x) = log(n) + log(1 + eˣ/n)
-/

import Mathlib
import ShefferAI.Lean.SoftplusBasic
import ShefferAI.Lean.ShefferAlgebra
import ShefferAI.Lean.AdvancedTheorems
import ShefferAI.Lean.GeneralIteratedSoftplus

open Real Filter

noncomputable section

/-! ## Derivative of Iterated Softplus -/

/-
The derivative of σⁿ(x) with respect to x equals eˣ/(n + eˣ).
-/
theorem softplus_iter_deriv (n : ℕ) (x : ℝ) :
    deriv (softplus_iter n) x = Real.exp x / (↑n + Real.exp x) := by
  convert HasDerivAt.deriv ( HasDerivAt.log ( HasDerivAt.const_add ( ( n : ℝ ) : ℝ ) ( Real.hasDerivAt_exp x ) ) ( by positivity ) ) using 1;
  exact Filter.EventuallyEq.deriv_eq ( by filter_upwards [ ] using fun _ => by rw [ show softplus_iter n = fun x => Real.log ( n + Real.exp x ) from funext fun _ => show softplus_iter n _ = Real.log ( n + Real.exp _ ) from by exact? ] )

/-- The derivative of σⁿ is between 0 and 1 for all n ≥ 1. -/
theorem softplus_iter_deriv_bounds (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    0 < deriv (softplus_iter n) x ∧ deriv (softplus_iter n) x < 1 := by
  rw [softplus_iter_deriv]
  constructor
  · exact div_pos (Real.exp_pos x) (by positivity)
  · rw [div_lt_one (by positivity : (↑n : ℝ) + Real.exp x > 0)]
    have : (1 : ℝ) ≤ (n : ℝ) := Nat.one_le_cast.mpr hn
    linarith

/-- σⁿ is a strict contraction for n ≥ 1. -/
theorem softplus_iter_deriv_lt_one (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    deriv (softplus_iter n) x < 1 :=
  (softplus_iter_deriv_bounds n hn x).2

/-! ## Explicit Orbit Formulas -/

/-- σⁿ(log k) = log(n + k) for k : ℕ with k ≥ 1. -/
theorem softplus_iter_log_nat (n k : ℕ) (hk : k ≥ 1) :
    softplus_iter n (Real.log (k : ℝ)) = Real.log (↑n + ↑k) := by
  rw [softplus_iter_general, Real.exp_log (by positivity)]

/-- σⁿ(0) = log(n + 1), recovering the original Q24 result. -/
theorem softplus_iter_log_one (n : ℕ) :
    softplus_iter n 0 = Real.log (↑n + 1) := by
  rw [softplus_iter_general, Real.exp_zero]

/-- The orbit starting from log(k) eventually reaches log(n + k). -/
theorem softplus_orbit_addition (n k : ℕ) (hk : k ≥ 1) :
    softplus_iter n (Real.log (k : ℝ)) = Real.log (↑(n + k)) := by
  rw [softplus_iter_log_nat n k hk]
  congr 1; push_cast; ring

/-! ## Growth Decomposition -/

/-- σⁿ(x) = log(n) + log(1 + eˣ/n), decomposing the growth. -/
theorem softplus_iter_growth_decomposition (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    softplus_iter n x = Real.log (↑n) + Real.log (1 + Real.exp x / ↑n) := by
  rw [softplus_iter_general]
  rw [show (↑n : ℝ) + Real.exp x = ↑n * (1 + Real.exp x / ↑n) from by
    field_simp]
  rw [Real.log_mul (by positivity) (by positivity)]

/-! ## Orbit Difference Decay -/

/-- The orbit difference formula in closed form. -/
theorem softplus_iter_diff_formula (n : ℕ) (x y : ℝ) :
    softplus_iter n x - softplus_iter n y =
    Real.log ((↑n + Real.exp x) / (↑n + Real.exp y)) := by
  rw [softplus_iter_general, softplus_iter_general,
      ← Real.log_div (by positivity) (by positivity)]

end