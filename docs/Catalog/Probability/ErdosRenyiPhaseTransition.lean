/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The mean-field giant-component phase transition at `p = 1/n`

The exploration process for `G(n, λ/n)` has Poisson mean `λ` in the limit.  Its
survival probability, which is the limiting giant-component density, is the
nonnegative fixed point `ρ = 1 - exp (-λρ)`.  This file reuses the catalog's
existing fixed-point development and packages the sharp transition at `λ = 1`.
-/
import Novelty.PercolationGiantComponent

namespace ErdosRenyiPhaseTransition

open PercolationGiantComponent

/-- The order parameter at the critical mean `λ = 1` is zero. -/
theorem critical_order_parameter_zero {ρ : ℝ} (hρ : 0 ≤ ρ)
    (h : IsSurvivalProb 1 ρ) : ρ = 0 := by
  exact survivalProb_eq_zero_of_subcritical (by norm_num) (by norm_num) hρ h

/-- **Sharp phase transition at `p = 1/n`.** Below and at mean degree one the
only nonnegative fixed point is zero, while above one a positive fixed point
strictly below one exists.  These two clauses identify `λ = 1` as the transition
in the Poisson exploration limit of `G(n, λ/n)`. -/
theorem giant_component_phase_transition :
    (∀ (lam ρ : ℝ), 0 < lam → lam ≤ 1 → 0 ≤ ρ →
      IsSurvivalProb lam ρ → ρ = 0) ∧
    (∀ lam : ℝ, 1 < lam →
      ∃ ρ : ℝ, 0 < ρ ∧ ρ < 1 ∧ IsSurvivalProb lam ρ) := by
  constructor
  · intro lam ρ hlam hlam1 hρ hfix
    exact survivalProb_eq_zero_of_subcritical hlam hlam1 hρ hfix
  · intro lam hlam
    exact exists_pos_survivalProb_of_supercritical hlam

/-- The positive supercritical order parameter has an explicit linear lower
bound, making the onset at the transition quantitatively nondegenerate. -/
theorem supercritical_order_parameter_lower_bound {lam : ℝ} (hlam : 1 < lam) :
    ∃ ρ : ℝ, 0 < ρ ∧ ρ < 1 ∧ IsSurvivalProb lam ρ ∧
      2 * (lam - 1) / lam ^ 2 ≤ ρ := by
  obtain ⟨ρ, hρ, hρ1, hfix⟩ := exists_pos_survivalProb_of_supercritical hlam
  exact ⟨ρ, hρ, hρ1, hfix,
    survivalProb_ge_of_supercritical hlam hρ hfix⟩

end ErdosRenyiPhaseTransition