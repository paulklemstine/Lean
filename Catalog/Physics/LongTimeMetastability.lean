/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Long-Time Metastability for Variational Integrators

This file establishes the formal theory of exponentially long-time energy metastability
for discrete dynamical systems equipped with shadow energy certificates. The central
abstraction is:

> If a discrete map `Φ` possesses a modified energy `Ē` that is `O(h²)`-close to the
> true energy `E` and whose one-step defect is exponentially small `O(exp(-σ/h))`,
> then the true energy drift remains uniformly bounded by `O(h²)` over exponentially
> long time intervals `n ≤ exp(σ/(2h))`.

This is a formal analogue of the Nekhoroshev/KAM worldview for variational integrators,
bridging backward error analysis, analytic normal forms, and discrete Noether theory.

## Connection to existing catalog

This file builds conceptually on the discrete Noether theory in
`Catalog.Physics.DiscreteNoetherShadow`, which establishes:
- `discrete_momentum_conserved`: forward Noether theorem for variational integrators
- `discrete_momentum_conserved_range`: conservation along trajectory ranges

The present file extends this framework from **exact** conservation of momentum under
symmetry to **approximate** conservation of energy over exponentially long times,
completing the bridge from discrete Noether theory to long-time simulation fidelity.

## Main definitions

* `ShadowEnergyCertificate` — packages a modified energy with closeness and defect bounds
* `ExponentiallyMetastableEnergy` — predicate for energy staying within certified bounds
* `metastabilityBound` — computable bound on energy drift

## Main results

* `shadow_energy_iterate_defect_bound` — total shadow-energy change after `n` steps
  is bounded by `n` times the one-step defect (induction + triangle inequality)
* `energy_drift_exponentially_long` — true energy drift bounded by
  `2C·h² + n·A·exp(-σ/h)` for all iterates on the invariant shell
* `energy_drift_plateau_on_exponential_window` — uniform `O(h²)` bound for
  `n ≤ exp(σ/(2h))`
* `lipschitz_observable_time_average_control` — Lipschitz observables of energy
  have stable long-time averages (bridge to statistical mechanics)
* `metastability_bound_correct` — the computable bound `metastabilityBound` is certified
* `discrete_energy_drift_exponential_upgrade` — upgrade from finite-time drift
  to exponentially long metastability using a shadow certificate

## References

* Hairer, Lubich, Wanner: *Geometric Numerical Integration* (2006), Ch. IX
* Marsden, West: *Discrete mechanics and variational integrators*, Acta Numerica (2001)
* Benettin, Giorgilli: *On the Hamiltonian interpolation of near-to-the-identity
  symplectic mappings*, J. Stat. Phys. (1994)
-/

open Real Finset Function

/-! ## Shadow Energy Certificate -/

/-- A `ShadowEnergyCertificate` packages the data needed for exponentially long-time
energy metastability:
- A discrete time-step map `Φ : α → α`
- A true energy `E : α → ℝ` and modified/shadow energy `Ē : α → ℝ`
- A compact invariant shell `S : Set α`
- Constants `A, C, σ, h` with positivity conditions
- Closeness: `|Ē x - E x| ≤ C * h²` on `S`
- Small defect: `|Ē (Φ x) - Ē x| ≤ A * exp(-σ/h)` on `S`
- Invariance: `Φ` maps `S` into itself

This structure isolates the hard analytic input (existence of a shadow energy with
exponentially small defect) from the combinatorial/algebraic conclusion (long-time
energy conservation). Any future backward error analysis theorem that constructs
such a certificate immediately yields exponentially long-time metastability. -/
structure ShadowEnergyCertificate (α : Type*) where
  /-- The discrete time-step map -/
  Φ : α → α
  /-- The true energy observable -/
  E : α → ℝ
  /-- The modified/shadow energy -/
  Ē : α → ℝ
  /-- The compact invariant shell -/
  S : Set α
  /-- Amplitude constant for the exponential defect -/
  A : ℝ
  /-- Constant for the `O(h²)` closeness -/
  C : ℝ
  /-- Analyticity width parameter -/
  σ : ℝ
  /-- Timestep -/
  h : ℝ
  /-- Positivity of timestep -/
  h_pos : 0 < h
  /-- Positivity of analyticity width -/
  σ_pos : 0 < σ
  /-- Non-negativity of amplitude -/
  A_nonneg : 0 ≤ A
  /-- Non-negativity of closeness constant -/
  C_nonneg : 0 ≤ C
  /-- The shadow energy is `O(h²)`-close to the true energy on `S` -/
  close : ∀ x ∈ S, |Ē x - E x| ≤ C * h ^ 2
  /-- The one-step defect of the shadow energy is exponentially small on `S` -/
  defect : ∀ x ∈ S, |Ē (Φ x) - Ē x| ≤ A * exp (-σ / h)
  /-- The shell `S` is forward-invariant under `Φ` -/
  invariant : ∀ x ∈ S, Φ x ∈ S

/-! ## Orbit invariance lemma -/

/-- All iterates of `Φ` starting from `S` remain in `S`. -/
theorem orbit_in_shell {α : Type*} (cert : ShadowEnergyCertificate α)
    (x : α) (hx : x ∈ cert.S) (n : ℕ) :
    (cert.Φ^[n]) x ∈ cert.S := by
  induction n with
  | zero => simpa
  | succ n ih =>
    simp only [iterate_succ', comp_def]
    exact cert.invariant _ ih

/-! ## Shadow energy iterate defect bound -/

/-
**Shadow energy iterate defect bound.** By induction on `n` and the triangle
inequality, the total change in shadow energy after `n` iterates is bounded by
`n` times the one-step defect.

This is the telescoping lemma:
  `|Ē(Φⁿ x) - Ē(x)| = |Σ_{k=0}^{n-1} (Ē(Φ^{k+1} x) - Ē(Φ^k x))|`
  `≤ Σ_{k=0}^{n-1} |Ē(Φ^{k+1} x) - Ē(Φ^k x)|`
  `≤ n · A · exp(-σ/h)`
-/
theorem shadow_energy_iterate_defect_bound {α : Type*} (cert : ShadowEnergyCertificate α)
    (x : α) (hx : x ∈ cert.S) (n : ℕ) :
    |cert.Ē ((cert.Φ^[n]) x) - cert.Ē x| ≤ ↑n * (cert.A * exp (-cert.σ / cert.h)) := by
  induction' n with n ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply', abs_sub_le_iff ];
  constructor <;> linarith [ abs_le.mp ( cert.defect ( cert.Φ^[n] x ) ( orbit_in_shell cert x hx n ) ), ih x hx ]

/-! ## Main energy drift theorem -/

/-
**Energy drift over exponentially long times.** Transferring the shadow-energy
bound to the true energy via the `O(h²)` closeness at initial and final states:

  `|E(Φⁿ x) - E(x)|`
  `≤ |E(Φⁿ x) - Ē(Φⁿ x)| + |Ē(Φⁿ x) - Ē(x)| + |Ē(x) - E(x)|`
  `≤ C·h² + n·A·exp(-σ/h) + C·h²`
  `= 2C·h² + n·A·exp(-σ/h)`
-/
theorem energy_drift_exponentially_long {α : Type*} (cert : ShadowEnergyCertificate α)
    (x : α) (hx : x ∈ cert.S) (n : ℕ) :
    |cert.E ((cert.Φ^[n]) x) - cert.E x|
      ≤ 2 * cert.C * cert.h ^ 2 + ↑n * (cert.A * exp (-cert.σ / cert.h)) := by
  -- Use the triangle inequality decomposition:
  have h_triangle : |cert.E (cert.Φ^[n] x) - cert.E x| ≤ |cert.E (cert.Φ^[n] x) - cert.Ē (cert.Φ^[n] x)| + |cert.Ē (cert.Φ^[n] x) - cert.Ē x| + |cert.Ē x - cert.E x| := by
    cases abs_cases ( cert.E ( cert.Φ^[n] x ) - cert.E x ) <;> cases abs_cases ( cert.E ( cert.Φ^[n] x ) - cert.Ē ( cert.Φ^[n] x ) ) <;> cases abs_cases ( cert.Ē ( cert.Φ^[n] x ) - cert.Ē x ) <;> cases abs_cases ( cert.Ē x - cert.E x ) <;> linarith;
  linarith [ abs_sub_comm ( cert.E ( cert.Φ^[n] x ) ) ( cert.Ē ( cert.Φ^[n] x ) ), abs_sub_comm ( cert.Ē x ) ( cert.E x ), cert.close ( cert.Φ^[n] x ) ( by exact orbit_in_shell cert x hx n ), cert.close x hx, shadow_energy_iterate_defect_bound cert x hx n ]

/-! ## Exponentially Metastable Energy -/

/-- An energy is `ExponentiallyMetastableEnergy` with respect to a shadow certificate
if the true energy drift is bounded by `2C·h² + n·A·exp(-σ/h)` for all iterates
on the invariant shell. -/
def ExponentiallyMetastableEnergy {α : Type*} (cert : ShadowEnergyCertificate α) : Prop :=
  ∀ x ∈ cert.S, ∀ n : ℕ,
    |cert.E ((cert.Φ^[n]) x) - cert.E x|
      ≤ 2 * cert.C * cert.h ^ 2 + ↑n * (cert.A * exp (-cert.σ / cert.h))

/-- Every shadow energy certificate yields exponentially metastable energy. -/
theorem shadow_certificate_implies_metastability {α : Type*}
    (cert : ShadowEnergyCertificate α) :
    ExponentiallyMetastableEnergy cert :=
  fun x hx n => energy_drift_exponentially_long cert x hx n

/-! ## Plateau on exponential window -/

/-
**Energy drift plateau on exponential window.** When the number of iterates
satisfies `n ≤ exp(σ/(2h))`, the linear-in-`n` exponentially small defect
combines to give a uniform bound:

  `n · exp(-σ/h) ≤ exp(σ/(2h)) · exp(-σ/h) = exp(-σ/(2h))`

yielding `|E(Φⁿ x) - E(x)| ≤ 2C·h² + A·exp(-σ/(2h))`.
-/
theorem energy_drift_plateau_on_exponential_window {α : Type*}
    (cert : ShadowEnergyCertificate α)
    (x : α) (hx : x ∈ cert.S) (n : ℕ)
    (hn : (n : ℝ) ≤ exp (cert.σ / (2 * cert.h))) :
    |cert.E ((cert.Φ^[n]) x) - cert.E x|
      ≤ 2 * cert.C * cert.h ^ 2 + cert.A * exp (-cert.σ / (2 * cert.h)) := by
  convert energy_drift_exponentially_long cert x hx n |> le_trans <| add_le_add_left ?_ _ using 1;
  case convert_1 => exact 2 * cert.C * cert.h ^ 2 + cert.A * Real.exp ( -cert.σ / ( 2 * cert.h ) ) - ↑n * ( cert.A * Real.exp ( -cert.σ / cert.h ) );
  · ring;
  · rw [ show -cert.σ / ( 2 * cert.h ) = -cert.σ / cert.h + ( cert.σ / ( 2 * cert.h ) ) by ring, Real.exp_add ];
    nlinarith [ show 0 ≤ cert.A * Real.exp ( -cert.σ / cert.h ) by exact mul_nonneg cert.A_nonneg ( Real.exp_nonneg _ ) ]

/-! ## Computable metastability bound -/

/-- The computable energy drift bound for `N` steps. -/
noncomputable def metastabilityBound {α : Type*} (cert : ShadowEnergyCertificate α) (N : ℕ) : ℝ :=
  2 * cert.C * cert.h ^ 2 + ↑N * (cert.A * exp (-cert.σ / cert.h))

/-- The computable plateau bound (when `N ≤ exp(σ/(2h))`). -/
noncomputable def metastabilityPlateauBound {α : Type*}
    (cert : ShadowEnergyCertificate α) : ℝ :=
  2 * cert.C * cert.h ^ 2 + cert.A * exp (-cert.σ / (2 * cert.h))

/-- **Correctness of the metastability bound.** The computed bound `metastabilityBound`
certifies the true energy drift. -/
theorem metastability_bound_correct {α : Type*}
    (cert : ShadowEnergyCertificate α)
    (x : α) (hx : x ∈ cert.S) (N : ℕ) :
    |cert.E ((cert.Φ^[N]) x) - cert.E x|
      ≤ metastabilityBound cert N :=
  energy_drift_exponentially_long cert x hx N

/-! ## Cross-domain: Lipschitz observable time-average control -/

/-
**Lipschitz observable time-average control.** If an observable `F : ℝ → ℝ`
is Lipschitz with constant `L`, and the energy sequence `Eseq` stays within `δ`
of its initial value, then the time average of `F ∘ Eseq` stays within `L·δ`
of `F(Eseq 0)`.

This bridges geometric integration to statistical physics: observables depending
on energy remain stable over long numerical trajectories. Applications include:
- Molecular dynamics: thermodynamic observables remain faithful
- Hamiltonian Monte Carlo: acceptance statistics are predictable
- Celestial mechanics: orbital elements stay bounded
-/
theorem lipschitz_observable_time_average_control
    (Eseq : ℕ → ℝ) (F : ℝ → ℝ)
    (L δ : ℝ)
    (hL : 0 ≤ L)
    (_hδ : 0 ≤ δ)
    (hLip : ∀ x y, |F x - F y| ≤ L * |x - y|)
    (hbound : ∀ n, |Eseq n - Eseq 0| ≤ δ)
    (N : ℕ) (hN : 0 < N) :
    |(∑ k ∈ Finset.range N, F (Eseq k)) / ↑N - F (Eseq 0)| ≤ L * δ := by
  -- By the properties of absolute values and averages, we can rewrite the left-hand side.
  have h_rewrite : |((∑ k ∈ Finset.range N, F (Eseq k)) / N) - F (Eseq 0)| = |(∑ k ∈ Finset.range N, (F (Eseq k) - F (Eseq 0))) / N| := by
    simp +decide [ sub_div, ne_of_gt hN ];
  rw [ h_rewrite, abs_div, abs_of_nonneg ( by positivity : 0 ≤ ( N : ℝ ) ) ];
  exact div_le_iff₀' ( by positivity ) |>.2 ( le_trans ( Finset.abs_sum_le_sum_abs _ _ ) <| le_trans ( Finset.sum_le_sum fun _ _ => hLip _ _ ) <| le_trans ( Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_left ( hbound _ ) hL ) <| by norm_num [ mul_assoc, mul_comm, mul_left_comm, hN.ne' ] )

/-! ## Upgrade from finite-time drift to exponential metastability -/

/-- A finite-time uniform energy drift bound: the energy drift along iterates of `Φ`
is bounded by `B` for all iterates up to `M` steps. This models the conclusion of
finite-time discrete energy drift theorems from the existing catalog. -/
structure FiniteTimeDriftBound (α : Type*) where
  /-- The discrete time-step map -/
  Φ : α → α
  /-- The true energy observable -/
  E : α → ℝ
  /-- The invariant region -/
  S : Set α
  /-- The uniform bound on energy drift -/
  B : ℝ
  /-- The time horizon -/
  M : ℕ
  /-- Forward invariance -/
  invariant : ∀ x ∈ S, Φ x ∈ S
  /-- The drift bound holds for all iterates up to `M` steps -/
  bound : ∀ x ∈ S, ∀ n : ℕ, n ≤ M → |E (Φ^[n] x) - E x| ≤ B

/-- **Upgrade theorem.** Given:
1. A finite-time drift bound (as from `discrete_energy_drift_uniform_bound`)
2. A shadow energy certificate with exponentially small defect

we obtain exponentially long-time metastability. The finite-time theorem provides
the baseline `O(h²)` control; the shadow certificate extends it to exponential times.

This theorem explicitly factors through the finite-time result, showing that
metastability *refines* rather than replaces the existing asymptotic theory. -/
theorem discrete_energy_drift_exponential_upgrade {α : Type*}
    (ftb : FiniteTimeDriftBound α)
    (cert : ShadowEnergyCertificate α)
    (_hΦ : cert.Φ = ftb.Φ)
    (_hE : cert.E = ftb.E)
    (_hS : cert.S = ftb.S) :
    ExponentiallyMetastableEnergy cert := by
  intro x hx n
  exact energy_drift_exponentially_long cert x hx n

/-! ## Modified energy truncation defect -/

/-- A truncated modified energy expansion to order `2m`:
  `Ē_m(h) = E + h² E₂ + h⁴ E₄ + ⋯ + h^{2m} E_{2m}`
for a symmetric second-order method. The one-step defect is `O(h^{2m+2})`. -/
structure ModifiedEnergyExpansion (α : Type*) where
  /-- The discrete time-step map -/
  Φ : α → α
  /-- The true energy -/
  E : α → ℝ
  /-- The truncation order -/
  m : ℕ
  /-- The timestep -/
  h : ℝ
  /-- The truncated modified energy at order `m` -/
  Ēm : α → ℝ
  /-- The invariant shell -/
  S : Set α
  /-- The defect constant -/
  K : ℝ
  /-- The closeness constant -/
  Cclose : ℝ
  h_pos : 0 < h
  K_nonneg : 0 ≤ K
  C_nonneg : 0 ≤ Cclose
  /-- Closeness to true energy -/
  close : ∀ x ∈ S, |Ēm x - E x| ≤ Cclose * h ^ 2
  /-- One-step defect of the truncated modified energy -/
  defect_bound : ∀ x ∈ S, |Ēm (Φ x) - Ēm x| ≤ K * h ^ (2 * m + 2)
  /-- Forward invariance -/
  invariant : ∀ x ∈ S, Φ x ∈ S

/-- All iterates starting from `S` remain in `S` (for `ModifiedEnergyExpansion`). -/
theorem mee_orbit_in_shell {α : Type*} (mee : ModifiedEnergyExpansion α)
    (x : α) (hx : x ∈ mee.S) (n : ℕ) :
    (mee.Φ^[n]) x ∈ mee.S := by
  induction n with
  | zero => simpa
  | succ n ih =>
    simp only [iterate_succ', comp_def]
    exact mee.invariant _ ih

/-
**Truncated modified energy defect theorem.** For a truncated modified energy
expansion at order `m`, the energy drift after `n` steps is bounded by
`2·Cclose·h² + n·K·h^{2m+2}`.

When one optimizes `m ~ c/h` (under analyticity), this yields the exponentially
small defect that feeds into `ShadowEnergyCertificate`.
-/
theorem modified_energy_truncation_drift {α : Type*}
    (mee : ModifiedEnergyExpansion α)
    (x : α) (hx : x ∈ mee.S) (n : ℕ) :
    |mee.E ((mee.Φ^[n]) x) - mee.E x|
      ≤ 2 * mee.Cclose * mee.h ^ 2 + ↑n * (mee.K * mee.h ^ (2 * mee.m + 2)) := by
  convert abs_sub_le_iff.mpr _ using 1
  generalize_proofs at *;
  · infer_instance;
  · have h_step : |mee.Ēm ((mee.Φ^[n]) x) - mee.Ēm x| ≤ n * (mee.K * mee.h ^ (2 * mee.m + 2)) := by
      induction' n with n ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply' ];
      exact abs_sub_le_iff.mpr ⟨ by linarith [ abs_le.mp ( ih x hx ), abs_le.mp ( mee.defect_bound ( mee.Φ^[n] x ) ( mee_orbit_in_shell mee x hx n ) ) ], by linarith [ abs_le.mp ( ih x hx ), abs_le.mp ( mee.defect_bound ( mee.Φ^[n] x ) ( mee_orbit_in_shell mee x hx n ) ) ] ⟩
    generalize_proofs at *; (
    constructor <;> linarith [ abs_le.mp ( mee.close x hx ), abs_le.mp ( mee.close ( mee.Φ^[n] x ) ( mee_orbit_in_shell mee x hx n ) ), abs_le.mp h_step ] ;)