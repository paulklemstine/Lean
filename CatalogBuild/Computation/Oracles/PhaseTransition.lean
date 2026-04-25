/-! # CatalogBuild.Computation.Oracles.PhaseTransition

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.PhaseTransition
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9] -/
theorem geometric_divergence (c : ℝ) (hc : 1 < |c|) :
    ¬ Tendsto (fun n => c ^ n) atTop (nhds 0) := by
      rw [ Metric.tendsto_nhds ];
      norm_num;
      exact ⟨ 1, by norm_num, fun n => ⟨ n, le_rfl, one_le_pow₀ hc.le ⟩ ⟩





/-- A Lyapunov function for an oracle iteration. -/
structure LyapunovFn where
  State : Type*
  V : State → ℝ
  f : State → State
  eq : State
  V_nonneg : ∀ s, 0 ≤ V s
  V_zero_iff : ∀ s, V s = 0 ↔ s = eq
  V_decreasing : ∀ s, s ≠ eq → V (f s) < V s





/-- **Lyapunov Stability**: If a Lyapunov function exists, V decreases along orbits. -/
theorem lyapunov_V_iterate_decreasing (L : LyapunovFn)
    (s : L.State) (hs : s ≠ L.eq) :
    L.V (L.f s) < L.V s := L.V_decreasing s hs





/-- [Section: # CatalogBuild.Computation.Oracles.PhaseTransition
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9] -/
theorem lyapunov_sequence_antitone (L : LyapunovFn) (s0 : L.State)
    (h : ∀ k, L.f^[k] s0 ≠ L.eq) :
    StrictAnti (fun k => L.V (L.f^[k] s0)) := by
      refine' strictAnti_nat_of_succ_lt fun k => _;
      simpa only [ Function.iterate_succ_apply' ] using L.V_decreasing _ ( h k )





/-- Steps needed to reach accuracy eps with contraction factor c. -/
def stepsToAccuracy (c eps : ℝ) : ℕ :=
  if hc : 0 < c ∧ c < 1 ∧ 0 < eps ∧ eps < 1
  then ⌈- Real.log eps / Real.log c⌉₊
  else 0





/-- [Section: # CatalogBuild.Computation.Oracles.PhaseTransition
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9] -/
theorem steps_grow_near_critical (eps : ℝ) (heps : 0 < eps) (heps1 : eps < 1) :
    Tendsto (fun c => (Real.log eps / Real.log c : ℝ))
      (nhdsWithin 1 (Set.Iio 1)) atTop := by
        refine' Filter.Tendsto.const_mul_atBot_of_neg ( Real.log_neg heps heps1 ) _;
        refine' Filter.Tendsto.comp ( tendsto_inv_nhdsLT_zero ) _;
        refine' tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ _ _;
        · simpa using tendsto_nhdsWithin_of_tendsto_nhds ( Real.continuousAt_log one_ne_zero );
        · filter_upwards [ Ioo_mem_nhdsLT zero_lt_one ] with x hx using Real.log_neg hx.1 hx.2





/-- Binary entropy is zero at 0. -/
theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by simp [binaryEntropy]





/-- Binary entropy is zero at 1. -/
theorem binaryEntropy_one : binaryEntropy 1 = 0 := by simp [binaryEntropy]





theorem binaryEntropy_symm (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    binaryEntropy p = binaryEntropy (1 - p) := by
      unfold binaryEntropy;
      grind





end
