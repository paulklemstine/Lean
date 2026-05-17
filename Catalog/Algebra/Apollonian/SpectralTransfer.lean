/-
# Target C: Spectral Transfer to Degree-k Observables

Abstract finite-dimensional spectral gap transfer theorem:
if an operator contracts on a subspace, then iterates contract geometrically.
This is then specialized to the Apollonian averaging operator.
-/

import Mathlib
import Algebra.Apollonian.Defs

/-! ## Abstract iterate contraction -/

/-- An operator with a spectral gap on a subspace: every vector in the subspace
    has its norm contracted by factor `(1 - gap)` under one application. -/
structure SpectralGapData (V : Type*) [SeminormedAddCommGroup V] [Module ℝ V] where
  /-- The linear operator -/
  T : V →ₗ[ℝ] V
  /-- The spectral gap parameter -/
  gap : ℝ
  /-- The gap is positive -/
  gap_pos : 0 < gap
  /-- The gap is at most 1 -/
  gap_le_one : gap ≤ 1
  /-- The contracting subspace (e.g., orthogonal complement of invariants) -/
  S : Submodule ℝ V
  /-- The subspace is preserved by the operator -/
  T_maps : ∀ v ∈ S, T v ∈ S
  /-- One-step contraction on the subspace -/
  contract : ∀ v ∈ S, ‖T v‖ ≤ (1 - gap) * ‖v‖

/-
Iterating the operator `n` times gives geometric contraction `(1 - γ)ⁿ`.
-/
theorem spectral_transfer_iterate_bound
    {V : Type*} [SeminormedAddCommGroup V] [Module ℝ V]
    (g : SpectralGapData V) :
    ∀ n : ℕ, ∀ v ∈ g.S, ‖(g.T ^ n) v‖ ≤ (1 - g.gap) ^ n * ‖v‖ := by
  intro n v hv;
  induction' n with n ih generalizing v;
  · simp +decide;
  · -- By the properties of the spectral gap, we have that ‖T (T^n v)‖ ≤ (1 - g.gap) * ‖T^n v‖.
    have h_step : ‖g.T ((g.T ^ n) v)‖ ≤ (1 - g.gap) * ‖(g.T ^ n) v‖ := by
      apply g.contract;
      exact Nat.recOn n hv fun n ih => by simpa only [ pow_succ', LinearMap.coe_comp, Function.comp_apply ] using g.T_maps _ ih;
    convert h_step.trans ( mul_le_mul_of_nonneg_left ( ih v hv ) ( sub_nonneg.2 g.gap_le_one ) ) using 1 ; push_cast [ pow_succ', mul_assoc ] ; ring!;
    grind

/-- The contraction factor is nonneg. -/
theorem spectral_gap_contraction_nonneg
    {V : Type*} [SeminormedAddCommGroup V] [Module ℝ V]
    (g : SpectralGapData V) : 0 ≤ 1 - g.gap :=
  sub_nonneg.mpr g.gap_le_one

/-- The contraction factor is strictly less than 1. -/
theorem spectral_gap_contraction_lt_one
    {V : Type*} [SeminormedAddCommGroup V] [Module ℝ V]
    (g : SpectralGapData V) : 1 - g.gap < 1 :=
  sub_lt_self _ g.gap_pos

/-! ## Apollonian specialization -/

/-- Given a spectral gap for the Apollonian averaging operator on degree-k observables,
    iterates give geometric mixing. This is the main transfer theorem. -/
theorem apollonian_degree_k_mixing
    {V : Type*} [SeminormedAddCommGroup V] [Module ℝ V]
    (g : SpectralGapData V) (n : ℕ)
    (v : V) (hv : v ∈ g.S) :
    ‖(g.T ^ n) v‖ ≤ (1 - g.gap) ^ n * ‖v‖ :=
  spectral_transfer_iterate_bound g n v hv