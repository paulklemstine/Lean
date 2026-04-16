/-! # CatalogBuild.MachineLearning.ShefferFunction.OrbitDynamics

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 12
-/

import Mathlib
import EML.Basic
import EML.Lean.AdvancedTheorems
import EML.Lean.GeneralIteratedSoftplus
import EML.Lean.ShefferAlgebra
import EML.Lean.SoftplusBasic

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


theorem softplus_iter_eq (n : ℕ) (x : ℝ) :
    softplus_iter n x = Real.log (↑n + Real.exp x) := by
  induction' n with n ih generalizing x <;> simp_all +decide [ softplus_iter ];
  unfold softplus; rw [ Real.exp_log ( by positivity ) ] ; ring;


/-- σⁿ(log k) = log(n + k) for natural numbers. -/
theorem softplus_iter_log_nat (n k : ℕ) (hk : 0 < k) :
    softplus_iter n (Real.log ↑k) = Real.log (↑n + ↑k) := by
  rw [softplus_iter_eq]
  congr 1
  rw [Real.exp_log (Nat.cast_pos.mpr hk)]


/-- σⁿ(0) = log(n + 1). -/
theorem softplus_iter_log_one (n : ℕ) :
    softplus_iter n 0 = Real.log (↑n + 1) := by
  rw [softplus_iter_eq, Real.exp_zero]


theorem softplus_iter_hasDerivAt (n : ℕ) (hn : 0 < n) (x : ℝ) :
    HasDerivAt (softplus_iter n) (Real.exp x / (↑n + Real.exp x)) x := by
  convert HasDerivAt.log ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( Real.hasDerivAt_exp _ ) ) _ using 1 <;> norm_num;
  convert softplus_iter_eq n;
  exacts [ funext_iff, rfl, by positivity ]


/-- The derivative of σⁿ is strictly positive for n ≥ 1. -/
theorem softplus_iter_deriv_pos (n : ℕ) (hn : 0 < n) (x : ℝ) :
    0 < Real.exp x / (↑n + Real.exp x) := by
  apply div_pos (Real.exp_pos x)
  have : (0:ℝ) < ↑n := Nat.cast_pos.mpr hn
  linarith [Real.exp_pos x]


/-- The derivative of σⁿ is strictly less than 1 for n ≥ 1. -/
theorem softplus_iter_deriv_lt_one (n : ℕ) (hn : 0 < n) (x : ℝ) :
    Real.exp x / (↑n + Real.exp x) < 1 := by
  have hd : (0:ℝ) < ↑n + Real.exp x := by
    have : (0:ℝ) < ↑n := Nat.cast_pos.mpr hn
    linarith [Real.exp_pos x]
  rw [div_lt_one hd]
  have : (0:ℝ) < ↑n := Nat.cast_pos.mpr hn
  linarith


theorem softplus_iter_growth_decomp (n : ℕ) (hn : 0 < n) (x : ℝ) :
    softplus_iter n x = Real.log ↑n + Real.log (1 + Real.exp x / ↑n) := by
  rw [ softplus_iter_eq, ← Real.log_mul, mul_add, mul_div_cancel₀ ] <;> ring <;> positivity


end
