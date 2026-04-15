/-! # CatalogBuild.ShefferAI.IteratedSoftplus

Auto-generated from theorem catalog database.
Domain: ShefferAI
Declarations: 3
-/

import Mathlib
import ShefferAI.Lean.AdvancedTheorems
import ShefferAI.Lean.SoftplusBasic

noncomputable section

theorem softplus_log_nat (n : ℕ) :
    softplus (Real.log (n + 1)) = Real.log (n + 2) := by
  unfold softplus; rw [ Real.exp_log ( by positivity ) ] ; ring;

/-
The exact identity: σⁿ(0) = log(n+1) for all n.
    This answers Q24: the growth rate is exactly logarithmic.
-/

theorem softplus_iter_zero_eq (n : ℕ) :
    softplus_iter n 0 = Real.log (n + 1) := by
  induction' n with n ih;
  · norm_num [ softplus_iter ];
  · convert congr_arg softplus ih using 1;
    exact_mod_cast Eq.symm ( softplus_log_nat n )

/-
Corollary: σⁿ(0) → ∞ as n → ∞, but only logarithmically
-/

theorem softplus_iter_zero_tendsto :
    Filter.Tendsto (fun n => softplus_iter n 0) Filter.atTop Filter.atTop := by
  -- By definition of softplus_iter, we have that softplus_iter n 0 = log(n + 1).
  have h_iter_zero_eq : ∀ n : ℕ, softplus_iter n 0 = Real.log (n + 1) := by
    exact?;
  simpa only [ h_iter_zero_eq ] using Real.tendsto_log_atTop.comp ( Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop )


end
