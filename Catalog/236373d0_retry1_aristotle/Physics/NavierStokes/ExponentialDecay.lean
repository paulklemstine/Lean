/-
# Exponential Energy Decay for the Abstract Galerkin Navier–Stokes Model

This file extends the energy method of `Physics.NavierStokes.EnergyMethod`.

The energy method shows only that the kinetic energy `E(t) = ‖u(t)‖²` is
*nonincreasing* along solutions of the abstract model

  u'(t) = −ν A u − B(u, u).

In the genuine incompressible setting the viscous operator `A = −Δ` (with
Dirichlet / divergence-free boundary conditions) has a **spectral gap**: by the
Poincaré inequality there is `λ > 0` with

  ⟪A v, v⟫ ≥ λ ‖v‖²   for all admissible `v`.

This coercivity upgrades the qualitative dissipation `E' ≤ 0` into a
*quantitative* one,

  E'(t) = −2ν⟪A u, u⟫ ≤ −2νλ E(t),

and Grönwall's lemma then yields **exponential decay of the energy**

  E(t) ≤ E(s) · exp(−2νλ (t − s)),       s ≤ t,

equivalently the `L²` norm decays like `‖u(t)‖ ≤ ‖u(s)‖ · exp(−νλ (t − s))`.

This is the abstract form of the classical statement that, for a fixed forcing
free flow in a bounded domain, the Navier–Stokes flow relaxes exponentially
fast to rest.  It strictly strengthens the `energy_antitone` / `norm_le_initial`
results of `EnergyMethod.lean` (recovered as the `λ = 0` case).

## Main results

* `Model.energy_deriv_le_coercive` — the coercive dissipation inequality.
* `Model.energy_exp_decay` — exponential decay of the energy.
* `Model.norm_exp_decay` — exponential decay of the `L²` norm.
-/

import Mathlib
import Physics.NavierStokes.EnergyMethod

namespace NavierStokes

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-
**Coercive (spectral-gap) dissipation inequality.**  If the viscous operator
is coercive with constant `λ ≥ 0`, then along any solution the energy derivative
is bounded above by `−2νλ` times the energy.
-/
theorem Model.energy_deriv_le_coercive (M : Model V) {u : ℝ → V}
    {lam : ℝ} (hcoer : ∀ v : V, lam * (inner ℝ v v : ℝ) ≤ inner ℝ (M.A v) v)
    (t : ℝ) :
    -(2 * M.ν * inner ℝ (M.A (u t)) (u t)) ≤ -(2 * M.ν * lam) * energy u t := by
  convert neg_le_neg ( mul_le_mul_of_nonneg_left ( hcoer ( u t ) ) ( mul_nonneg zero_le_two M.hν ) ) using 1 ; ring!

/-
**Exponential energy decay.**  Under coercivity with constant `λ ≥ 0`, the
energy decays at least exponentially: `E(t) ≤ E(s) · exp(−2νλ (t − s))`.
-/
theorem Model.energy_exp_decay (M : Model V) {u : ℝ → V} (hu : M.IsSolution u)
    {lam : ℝ}
    (hcoer : ∀ v : V, lam * (inner ℝ v v : ℝ) ≤ inner ℝ (M.A v) v)
    {s t : ℝ} (hst : s ≤ t) :
    energy u t ≤ energy u s * Real.exp (-(2 * M.ν * lam) * (t - s)) := by
  -- By multiplying both sides of the inequality by the positive term `Real.exp (c * t)`, we obtain the desired result.
  have h_mul : energy u t * Real.exp (2 * M.ν * lam * t) ≤ energy u s * Real.exp (2 * M.ν * lam * s) := by
    have h_mul : ∀ t, HasDerivAt (fun t => energy u t * Real.exp (2 * M.ν * lam * t)) (-(2 * M.ν * inner ℝ (M.A (u t)) (u t)) * Real.exp (2 * M.ν * lam * t) + energy u t * (2 * M.ν * lam * Real.exp (2 * M.ν * lam * t))) t := by
      intro t;
      convert HasDerivAt.mul ( M.energy_hasDerivAt hu t ) ( HasDerivAt.exp ( HasDerivAt.const_mul ( 2 * M.ν * lam ) ( hasDerivAt_id t ) ) ) using 1 ; ring!;
    have h_mul : ∀ t, -(2 * M.ν * inner ℝ (M.A (u t)) (u t)) * Real.exp (2 * M.ν * lam * t) + energy u t * (2 * M.ν * lam * Real.exp (2 * M.ν * lam * t)) ≤ 0 := by
      intro t
      have h_mul : -(2 * M.ν * inner ℝ (M.A (u t)) (u t)) ≤ -(2 * M.ν * lam) * energy u t := by
        convert Model.energy_deriv_le_coercive M hcoer t using 1;
      nlinarith [ Real.exp_pos ( 2 * M.ν * lam * t ) ];
    have h_mul : Antitone (fun t => energy u t * Real.exp (2 * M.ν * lam * t)) := by
      apply_rules [ antitone_of_hasDerivAt_nonpos ];
    exact h_mul hst;
  convert ( le_div_iff₀ ( Real.exp_pos _ ) ) |>.2 h_mul using 1 ; ring_nf ; norm_num [ mul_assoc, ← Real.exp_add ] ;
  exact Or.inl ( by rw [ ← Real.exp_neg, ← Real.exp_add ] ; ring )

/-
**Exponential decay of the `L²` norm.**
-/
theorem Model.norm_exp_decay (M : Model V) {u : ℝ → V} (hu : M.IsSolution u)
    {lam : ℝ}
    (hcoer : ∀ v : V, lam * (inner ℝ v v : ℝ) ≤ inner ℝ (M.A v) v)
    {s t : ℝ} (hst : s ≤ t) :
    ‖u t‖ ≤ ‖u s‖ * Real.exp (-(M.ν * lam) * (t - s)) := by
  have := Model.energy_exp_decay M hu hcoer hst;
  convert Real.sqrt_le_sqrt this using 1 <;> norm_num [ energy ];
  exact Or.inl ( by rw [ Real.sqrt_eq_rpow, ← Real.exp_mul ] ; ring )

end NavierStokes