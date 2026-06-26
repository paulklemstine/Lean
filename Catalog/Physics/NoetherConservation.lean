/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Continuous Noether Theorem: Symmetries and Conservation Laws

This file formalizes the **continuous** Noether theorem of classical mechanics,
the analytic complement to the discrete version in
`Catalog.Physics.DiscreteNoetherConverse`.

The physical content: along a solution of the Euler–Lagrange equations, a
one-parameter symmetry of the Lagrangian produces a conserved Noether charge.
We work *along a trajectory*, i.e. with the time-parametrized quantities

* `p t i`  — the conjugate momentum `∂L/∂q̇ᵢ` evaluated on the trajectory,
* `g t i`  — the symmetry generator `Xᵢ(q(t))` evaluated on the trajectory,
* `F t i`  — the generalized force `∂L/∂qᵢ` evaluated on the trajectory.

The **Euler–Lagrange equation** is `p'(t) = F(t)` and the **infinitesimal
invariance** of the Lagrangian along the flow is
`∑ᵢ (Fᵢ gᵢ + pᵢ gᵢ') = 0`.

## Main results

* `noether_charge_conserved` — the abstract Noether theorem: the charge
  `Q = ⟨p, g⟩` has zero time-derivative on shell.
* `momentum_conserved_of_translation_invariance` — momentum conservation from
  translational invariance (Noether with a constant generator).
* `energy_conserved_of_autonomous` — energy conservation from time-translation
  invariance (autonomy of the Lagrangian).

## References

* Noether, *Invariante Variationsprobleme* (1918).
* Marsden, West, *Discrete mechanics and variational integrators* (2001) — the
  discrete counterpart formalized in `DiscreteNoetherConverse.lean`.
-/

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the operational content of Noether's theorem along a
-- fixed trajectory is a one-line product rule. Conjecture: the forward theorem
-- (symmetry implies conservation) collapses to "derivative of an inner product is
-- zero" once Euler-Lagrange `p' = F` and infinitesimal invariance are taken as
-- hypotheses on the time-parametrized quantities.
-- Experiment (Experimenter): formalize the charge `Q = inner p g` and differentiate
-- via `HasDerivAt.mul` + `HasDerivAt.sum`; momentum is the constant-generator case,
-- energy is the `E = inner p v - l` case with autonomy hypothesis
-- `l' = sum (p' v + p v')`. All four laws fell to `convert ... using 1` then
-- `simp`/`ring` against the invariance hypothesis.
-- Analysis (Analyst): the only nontrivial calculus is the product/sum rule; the
-- physics lives in the algebraic hypotheses `hEL` and `hinv`. "True and easy once
-- stated correctly" - the work was choosing the along-trajectory formulation that
-- avoids jet bundles while staying faithful.
-- Critique (Critic): `energy_conserved_of_autonomous` is not vacuous - `hchain` is a
-- genuine constraint; dropping it makes the theorem false (energy of a
-- time-dependent Lagrangian is not conserved). The `*_const` versions upgrade
-- pointwise stationarity to global constancy via `is_const_of_deriv_eq_zero`.
-- Synthesis: a reusable, axiom-clean continuous Noether kernel reused by the Kepler
-- file and the discrete/continuous bridge.
-- !-- end Lab Notes -- !--

noncomputable section

open scoped BigOperators

namespace NoetherContinuous

variable {n : ℕ}

/-! ### Abstract continuous Noether theorem -/

/-
**Continuous Noether theorem (charge form).**
Along a solution of the Euler–Lagrange equation `p' = F`, if the Lagrangian is
infinitesimally invariant under the generator `g`, i.e.
`∑ᵢ (Fᵢ(t) gᵢ(t) + pᵢ(t) gᵢ'(t)) = 0`, then the Noether charge
`Q(t) = ∑ᵢ pᵢ(t) gᵢ(t)` is conserved: its time derivative vanishes.
-/
theorem noether_charge_conserved
    (p g F p' g' : ℝ → Fin n → ℝ)
    (hp : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => p s i) (p' t i) t)
    (hg : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => g s i) (g' t i) t)
    (hEL : ∀ t i, p' t i = F t i)
    (hinv : ∀ t, ∑ i, (F t i * g t i + p t i * g' t i) = 0)
    (t : ℝ) :
    HasDerivAt (fun s => ∑ i, p s i * g s i) 0 t := by
  convert HasDerivAt.sum fun i _ => ( HasDerivAt.mul ( hp i t ) ( hg i t ) ) using 1 ; aesop;
  aesop

/-
The Noether charge is *constant* (not merely stationary) on all of `ℝ`.
-/
theorem noether_charge_const
    (p g F p' g' : ℝ → Fin n → ℝ)
    (hp : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => p s i) (p' t i) t)
    (hg : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => g s i) (g' t i) t)
    (hEL : ∀ t i, p' t i = F t i)
    (hinv : ∀ t, ∑ i, (F t i * g t i + p t i * g' t i) = 0)
    (t₀ t₁ : ℝ) :
    (∑ i, p t₁ i * g t₁ i) = ∑ i, p t₀ i * g t₀ i := by
  -- By `noether_charge_conserved` applied with the same hypotheses, for every s we have `HasDerivAt (fun u => ∑ i, p u i * g u i) 0 s`.
  have hcnst : ∀ s, HasDerivAt (fun u => ∑ i, p u i * g u i) 0 s := by
    intro s; convert noether_charge_conserved p g F p' g' hp hg hEL hinv s using 1;
  exact is_const_of_deriv_eq_zero ( fun s => ( hcnst s |> HasDerivAt.differentiableAt ) ) ( fun s => ( hcnst s |> HasDerivAt.deriv ) ) t₁ t₀

/-! ### Momentum conservation from translational invariance -/

/-
**Momentum from space-translation symmetry.**
If the Lagrangian does not depend on the coordinate `j` (translational
invariance: the `j`-th generalized force vanishes), then the conjugate
momentum `p_j` is conserved. This is Noether's theorem with the constant
generator `g = e_j`.
-/
theorem momentum_conserved_of_translation_invariance
    (p F p' : ℝ → Fin n → ℝ) (j : Fin n)
    (hp : ∀ (t : ℝ), HasDerivAt (fun s => p s j) (p' t j) t)
    (hEL : ∀ t, p' t j = F t j)
    (hinv : ∀ t, F t j = 0)
    (t : ℝ) :
    HasDerivAt (fun s => p s j) 0 t := by
  simpa only [ hEL, hinv ] using hp t

theorem momentum_const_of_translation_invariance
    (p F p' : ℝ → Fin n → ℝ) (j : Fin n)
    (hp : ∀ (t : ℝ), HasDerivAt (fun s => p s j) (p' t j) t)
    (hEL : ∀ t, p' t j = F t j)
    (hinv : ∀ t, F t j = 0)
    (t₀ t₁ : ℝ) :
    p t₁ j = p t₀ j := by
  exact is_const_of_deriv_eq_zero ( fun t => ( hp t |> HasDerivAt.differentiableAt ) ) ( fun t => by simpa [ hEL, hinv ] using HasDerivAt.deriv ( hp t ) ) t₁ t₀

/-! ### Energy conservation from time-translation invariance -/

/-
**Energy from time-translation symmetry.**
Let `v` be the velocity, `p` the conjugate momentum, and `ℓ` the Lagrangian
evaluated along the trajectory. Suppose the Lagrangian is *autonomous* (no
explicit time dependence): combined with the Euler–Lagrange equation and the
definition of momentum, this is exactly the statement that

  `ℓ'(t) = ∑ᵢ (p'ᵢ(t) vᵢ(t) + pᵢ(t) v'ᵢ(t))`.

Then the energy `E(t) = ⟨p(t), v(t)⟩ − ℓ(t)` is conserved.
-/
theorem energy_conserved_of_autonomous
    (p v p' v' : ℝ → Fin n → ℝ) (ℓ ℓ' : ℝ → ℝ)
    (hp : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => p s i) (p' t i) t)
    (hv : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => v s i) (v' t i) t)
    (hℓ : ∀ t, HasDerivAt ℓ (ℓ' t) t)
    (hchain : ∀ t, ℓ' t = ∑ i, (p' t i * v t i + p t i * v' t i))
    (t : ℝ) :
    HasDerivAt (fun s => (∑ i, p s i * v s i) - ℓ s) 0 t := by
  convert HasDerivAt.sub ( HasDerivAt.sum fun i _ ↦ HasDerivAt.mul ( hp i t ) ( hv i t ) ) ( hℓ t ) using 1 ; aesop;
  rw [ hchain, sub_self ]

theorem energy_const_of_autonomous
    (p v p' v' : ℝ → Fin n → ℝ) (ℓ ℓ' : ℝ → ℝ)
    (hp : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => p s i) (p' t i) t)
    (hv : ∀ (i : Fin n) (t : ℝ), HasDerivAt (fun s => v s i) (v' t i) t)
    (hℓ : ∀ t, HasDerivAt ℓ (ℓ' t) t)
    (hchain : ∀ t, ℓ' t = ∑ i, (p' t i * v t i + p t i * v' t i))
    (t₀ t₁ : ℝ) :
    ((∑ i, p t₁ i * v t₁ i) - ℓ t₁) = (∑ i, p t₀ i * v t₀ i) - ℓ t₀ := by
  have hQ_deriv_zero : ∀ t, HasDerivAt (fun s => (∑ i, p s i * v s i) - ℓ s) 0 t :=
    fun t => energy_conserved_of_autonomous p v p' v' ℓ ℓ' hp hv hℓ hchain t
  exact is_const_of_deriv_eq_zero (fun t => (hQ_deriv_zero t).differentiableAt)
    (fun t => (hQ_deriv_zero t).deriv) t₁ t₀

end NoetherContinuous