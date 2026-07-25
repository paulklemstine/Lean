import Mathlib

/-!
# Quantum-walk periodicity versus topological mixing

The mission's proposed universal convergence claim conflicts with finite-dimensional unitary
recurrence.  This file isolates a precise bridge between two areas:

* **algebraic dynamics:** a finite-order evolution operator `U`, satisfying `U^[k] = id`;
* **general topology / probability:** convergence of the Born probability at each state.

The connector theorem says that a periodic sequence in a Hausdorff space can converge only to
its initial value.  Applied coordinatewise to Born probabilities, this shows that a periodic
quantum walk can converge to the uniform distribution only if its initial Born distribution was
already uniform.  In particular, a walk started at a basis state on a nontrivial finite group
cannot mix in the pointwise-convergence sense used in the prompt.

This does not rule out time-averaged mixing, measurement-induced walks, or convergence after
adding decoherence; those are genuinely different notions.
-/

open Filter Topology

namespace QuantumWalkPeriodicityMixing

/-- A complex amplitude on a finite state space. -/
abbrev State (G : Type*) := G → ℂ

/-- The amplitude after `n` applications of an evolution operator. -/
noncomputable def amplitude {G : Type*} (U : State G → State G)
    (ψ : State G) (n : ℕ) (x : G) : ℂ :=
  (U^[n]) ψ x

/-- The Born probability at state `x` after `n` applications of `U`. -/
noncomputable def bornProbability {G : Type*} (U : State G → State G)
    (ψ : State G) (n : ℕ) (x : G) : ℝ :=
  ‖amplitude U ψ n x‖ ^ 2

/-- The point mass (computational basis state) at `origin`. -/
noncomputable def basisState {G : Type*} [DecidableEq G] (origin : G) : State G :=
  fun x => if x = origin then 1 else 0

/-- The uniform probability assigned to each point of a nonempty finite type. -/
noncomputable def uniformProbability (G : Type*) [Fintype G] : ℝ :=
  (Fintype.card G : ℝ)⁻¹

/-- **Topology–dynamics connector.** A positive-period periodic sequence in a Hausdorff
space can converge only to its initial value.

The proof samples the convergent sequence along the cofinal subsequence `n ↦ k • n`.
Periodicity makes that subsequence constant, while Hausdorff uniqueness identifies its value
with the alleged limit. -/
theorem periodic_tendsto_eq_initial
    {X : Type*} [TopologicalSpace X] [T2Space X]
    (f : ℕ → X) (k : ℕ) (hk : 0 < k)
    (hperiodic : Function.Periodic f k) {limit : X}
    (hlimit : Tendsto f atTop (𝓝 limit)) :
    f 0 = limit := by
  have hsubsequence : Tendsto (fun n : ℕ => f (k • n)) atTop (𝓝 limit) :=
    hlimit.comp (tendsto_id.nsmul_atTop hk)
  have hconstant : (fun n : ℕ => f (k • n)) = fun _ => f 0 := by
    funext n
    simpa [Nat.mul_comm] using hperiodic.nsmul_eq n
  rw [hconstant] at hsubsequence
  exact tendsto_nhds_unique tendsto_const_nhds hsubsequence

/-- Finite order of the evolution operator makes every coordinate Born-probability sequence
periodic with the same period. -/
theorem bornProbability_periodic {G : Type*}
    (U : State G → State G) (ψ : State G) (k : ℕ)
    (hU : U^[k] = id) (x : G) :
    Function.Periodic (fun n => bornProbability U ψ n x) k := by
  intro n
  simp only [bornProbability, amplitude]
  rw [Function.iterate_add_apply]
  simp [hU]

/-- **Quantum-probability connector.** If a finite-order evolution has pointwise convergent
Born probabilities, every limiting probability equals its time-zero value. -/
theorem periodic_quantum_limit_eq_initial {G : Type*}
    (U : State G → State G) (ψ : State G) (k : ℕ) (hk : 0 < k)
    (hU : U^[k] = id) (p : G → ℝ)
    (hmix : ∀ x, Tendsto (fun n => bornProbability U ψ n x) atTop (𝓝 (p x))) :
    ∀ x, bornProbability U ψ 0 x = p x := by
  intro x
  exact periodic_tendsto_eq_initial
    (fun n => bornProbability U ψ n x) k hk
    (bornProbability_periodic U ψ k hU x) (hmix x)

/-- Consequently, a periodic quantum walk can converge pointwise to uniform only when the
initial Born distribution is already uniform. -/
theorem periodic_uniform_mixing_forces_initial_uniform
    {G : Type*} [Fintype G]
    (U : State G → State G) (ψ : State G) (k : ℕ) (hk : 0 < k)
    (hU : U^[k] = id)
    (hmix : ∀ x, Tendsto (fun n => bornProbability U ψ n x) atTop
      (𝓝 (uniformProbability G))) :
    ∀ x, ‖ψ x‖ ^ 2 = uniformProbability G := by
  intro x
  have h := periodic_quantum_limit_eq_initial U ψ k hk hU
    (fun _ => uniformProbability G) hmix x
  simpa [bornProbability, amplitude] using h

/-- **No-go theorem for localized starts.** On a finite state space with more than one point,
a finite-order quantum evolution started at a basis state cannot have Born probabilities that
converge pointwise to the uniform distribution. -/
theorem periodic_basisState_not_uniformly_mixing
    {G : Type*} [Fintype G] [DecidableEq G]
    (origin : G) (hcard : 1 < Fintype.card G)
    (U : State G → State G) (k : ℕ) (hk : 0 < k)
    (hU : U^[k] = id) :
    ¬ (∀ x, Tendsto (fun n => bornProbability U (basisState origin) n x) atTop
      (𝓝 (uniformProbability G))) := by
  intro hmix
  have horigin := periodic_uniform_mixing_forces_initial_uniform
    U (basisState origin) k hk hU hmix origin
  simp only [basisState, if_pos, norm_one, one_pow] at horigin
  unfold uniformProbability at horigin
  have hcardReal : (1 : ℝ) < Fintype.card G := by exact_mod_cast hcard
  have hne : (Fintype.card G : ℝ) ≠ 1 := ne_of_gt hcardReal
  have : (Fintype.card G : ℝ) = 1 := by
    apply inv_eq_one.mp
    exact horigin.symm
  exact hne this

end QuantumWalkPeriodicityMixing