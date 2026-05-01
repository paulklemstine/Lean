import Mathlib
import EML.Basic

/-! # CatalogBuild.EML.OrbitDynamics

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 7
-/

noncomputable section

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
