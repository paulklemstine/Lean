import Mathlib

/-!
# Sharp Phase Transitions in Oracle Convergence

## Threshold Phenomena in Oracle Systems

We formalize the sharp phase transition in oracle convergence: below a critical
threshold, oracle iterations diverge; above it, they converge exponentially.

### Main Results

* `geometric_convergence` — Geometric rate of convergence
* `geometric_divergence` — Divergence below threshold
* `lyapunov_V_iterate_decreasing` — Lyapunov stability characterization
* `lyapunov_sequence_antitone` — Lyapunov value decreases along trajectories
* `binaryEntropy_zero` / `binaryEntropy_one` — Boundary entropy values
* `binaryEntropy_symm` — Symmetry of binary entropy
-/

open Filter Topology

noncomputable section

/-! ## §1: Contraction Phase Transition -/

/-
Geometric convergence rate.
-/
theorem geometric_convergence (c : ℝ) (hc : |c| < 1) :
    Tendsto (fun n => c ^ n) atTop (nhds 0) := by
      exact tendsto_pow_atTop_nhds_zero_of_abs_lt_one hc

/-
Divergence for |c| > 1: the power sequence does not converge to 0.
-/
theorem geometric_divergence (c : ℝ) (hc : 1 < |c|) :
    ¬ Tendsto (fun n => c ^ n) atTop (nhds 0) := by
      rw [ Metric.tendsto_nhds ];
      norm_num;
      exact ⟨ 1, by norm_num, fun n => ⟨ n, le_rfl, one_le_pow₀ hc.le ⟩ ⟩

/-! ## §2: Lyapunov Stability for Oracle Systems -/

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

/-
The Lyapunov value sequence is strictly decreasing until equilibrium.
-/
theorem lyapunov_sequence_antitone (L : LyapunovFn) (s0 : L.State)
    (h : ∀ k, L.f^[k] s0 ≠ L.eq) :
    StrictAnti (fun k => L.V (L.f^[k] s0)) := by
      refine' strictAnti_nat_of_succ_lt fun k => _;
      simpa only [ Function.iterate_succ_apply' ] using L.V_decreasing _ ( h k )

/-! ## §3: Critical Exponent -/

/-- Steps needed to reach accuracy eps with contraction factor c. -/
def stepsToAccuracy (c eps : ℝ) : ℕ :=
  if hc : 0 < c ∧ c < 1 ∧ 0 < eps ∧ eps < 1
  then ⌈- Real.log eps / Real.log c⌉₊
  else 0

/-
The convergence time diverges as c → 1⁻: for 0 < eps < 1,
    log(eps)/log(c) → +∞ as c → 1⁻.
-/
theorem steps_grow_near_critical (eps : ℝ) (heps : 0 < eps) (heps1 : eps < 1) :
    Tendsto (fun c => (Real.log eps / Real.log c : ℝ))
      (nhdsWithin 1 (Set.Iio 1)) atTop := by
        refine' Filter.Tendsto.const_mul_atBot_of_neg ( Real.log_neg heps heps1 ) _;
        refine' Filter.Tendsto.comp ( tendsto_inv_nhdsLT_zero ) _;
        refine' tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ _ _;
        · simpa using tendsto_nhdsWithin_of_tendsto_nhds ( Real.continuousAt_log one_ne_zero );
        · filter_upwards [ Ioo_mem_nhdsLT zero_lt_one ] with x hx using Real.log_neg hx.1 hx.2

/-! ## §4: Oracle Entropy Phase Transition -/

/-- Binary entropy function. -/
def binaryEntropy (p : ℝ) : ℝ :=
  if p = 0 ∨ p = 1 then 0
  else -p * Real.log p - (1 - p) * Real.log (1 - p)

/-- Binary entropy is zero at 0. -/
theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by simp [binaryEntropy]

/-- Binary entropy is zero at 1. -/
theorem binaryEntropy_one : binaryEntropy 1 = 0 := by simp [binaryEntropy]

/-
Binary entropy is symmetric around 1/2.
-/
theorem binaryEntropy_symm (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    binaryEntropy p = binaryEntropy (1 - p) := by
      unfold binaryEntropy;
      grind

end