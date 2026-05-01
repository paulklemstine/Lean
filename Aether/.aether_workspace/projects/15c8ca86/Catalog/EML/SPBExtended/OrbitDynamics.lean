import EML.Basic
import EML.Lean.AdvancedTheorems
import EML.Lean.GeneralIteratedSoftplus
import EML.Lean.ShefferAlgebra
import EML.Lean.SoftplusBasic
import Mathlib

/-! # CatalogBuild.MachineLearning.ShefferFunction.OrbitDynamics

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5
-/


noncomputable section

/-- [Section: ## Derivative of Iterated Softplus] -/
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



/-- The orbit starting from log(k) eventually reaches log(n + k). -/
theorem softplus_orbit_addition (n k : ℕ) (hk : k ≥ 1) :
    softplus_iter n (Real.log (k : ℝ)) = Real.log (↑(n + k)) := by
  rw [softplus_iter_log_nat n k hk]
  congr 1; push_cast; ring



/-- σⁿ(x) = log(n) + log(1 + eˣ/n), decomposing the growth. -/
theorem softplus_iter_growth_decomposition (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    softplus_iter n x = Real.log (↑n) + Real.log (1 + Real.exp x / ↑n) := by
  rw [softplus_iter_general]
  rw [show (↑n : ℝ) + Real.exp x = ↑n * (1 + Real.exp x / ↑n) from by
    field_simp]
  rw [Real.log_mul (by positivity) (by positivity)]



/-- The orbit difference formula in closed form. -/
theorem softplus_iter_diff_formula (n : ℕ) (x y : ℝ) :
    softplus_iter n x - softplus_iter n y =
    Real.log ((↑n + Real.exp x) / (↑n + Real.exp y)) := by
  rw [softplus_iter_general, softplus_iter_general,
      ← Real.log_div (by positivity) (by positivity)]



end