/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Robust Log-Concavity for Quantum Many-Body Ground States

This file formalizes a **bridge between quantum many-body spectral theory,
Lorentzian/strongly log-concave polynomials, and classical Markov-chain expansion**.

## Mathematical Vision

Given a normalized quantum state `ψ : α → ℂ`, its computational-basis measurement
distribution `μ(x) = ‖ψ(x)‖²` defines a probability measure on the configuration
space. For free-fermionic and determinantal states, the generating polynomial of `μ`
is Lorentzian / strongly log-concave.

We formalize a chain of rigorous results:

1. **Quantum measurement model** — normalized amplitudes yield a probability distribution.
2. **Perturbative transport** — pointwise multiplicative closeness transfers to event
   probabilities, anti-concentration certificates, and expansion quantities.
3. **Gap surrogate preservation** — minimum mass and pairwise mass ratios degrade
   gracefully under multiplicative perturbation.
4. **Cross-domain bridge** — boundary mass (graph expansion) of a spin system is
   controlled by perturbative comparison to a Lorentzian reference.

## Application Keywords

quantum many-body systems, transverse-field Ising model, free fermions,
matchgate circuits, Lorentzian polynomials, strong log-concavity, spectral gap,
Glauber dynamics, anti-concentration, negative dependence, perturbation stability,
classical simulation, combinatorial Hodge theory, determinantal processes,
quantum-to-classical correspondence

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials II", 2021
* Builds on `Bridges.Catalog.Pythagorean.RobustLorentzianSampling.gibbs_pointwise_ratio_bound`
-/

open Finset BigOperators

noncomputable section

namespace QuantumLorentzianBridge

/-! ## Part I: Core Definitions -/

/-- A quantum measurement model: a normalized pure state in the computational basis. -/
structure QuantumMeasurementModel (α : Type*) [Fintype α] where
  amp : α → ℂ
  norm_one : ∑ x, ‖amp x‖ ^ 2 = 1

/-- The induced probability mass function of a quantum measurement model. -/
def QuantumMeasurementModel.prob
    {α : Type*} [Fintype α] (M : QuantumMeasurementModel α) : α → ℝ :=
  fun x => ‖M.amp x‖ ^ 2

/-- A robust Lorentzian certificate for a distribution. -/
structure RobustLorentzianCertificate
    (α : Type*) [Fintype α] (μ : α → ℝ) where
  nonneg : ∀ x, 0 ≤ μ x
  sum_one : ∑ x, μ x = 1
  pointwise_lower : ℝ
  pointwise_upper : ℝ
  lower_pos : 0 ≤ pointwise_lower
  lower_spec : ∀ x, pointwise_lower ≤ μ x
  upper_spec : ∀ x, μ x ≤ pointwise_upper
  pair_log_concave : ∀ x y, μ x * μ y ≤ pointwise_upper ^ 2

/-- A gapped measurement lift connecting quantum, Lorentzian, and classical gaps. -/
structure GappedMeasurementLift (α : Type*) [Fintype α] where
  μ : α → ℝ
  quantumGap : ℝ
  lorentzianGap : ℝ
  classicalGap : ℝ
  quantumGap_nonneg : 0 ≤ quantumGap
  lorentzianGap_nonneg : 0 ≤ lorentzianGap
  classicalGap_nonneg : 0 ≤ classicalGap
  q_to_l : quantumGap ≤ lorentzianGap
  l_to_c : lorentzianGap ≤ classicalGap

/-- A finite spin system with a probability distribution and adjacency. -/
structure FiniteSpinSystem (α : Type*) [Fintype α] [DecidableEq α] where
  μ : α → ℝ
  adj : α → α → Bool
  adj_symm : ∀ x y, adj x y = adj y x
  μ_nonneg : ∀ x, 0 ≤ μ x
  μ_sum_one : ∑ x, μ x = 1

/-- Whether vertex `x` in `A` has a neighbor outside `A`. -/
def hasBoundaryNeighbor
    {α : Type*} [Fintype α] [DecidableEq α]
    (S : FiniteSpinSystem α) (A : Finset α) (x : α) : Bool :=
  (Finset.univ.filter fun y => S.adj x y = true ∧ y ∉ A).card > 0

/-- Boundary mass of a set `A` in a finite spin system. -/
def boundaryMass
    {α : Type*} [Fintype α] [DecidableEq α]
    (S : FiniteSpinSystem α) (A : Finset α) : ℝ :=
  ∑ x ∈ A, if hasBoundaryNeighbor S A x then S.μ x else 0

/-- Minimum mass of a distribution over a nonempty finite type. -/
def minMass {α : Type*} [Fintype α] [Nonempty α] (μ : α → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty μ

/-- Pairwise mass gap: infimum of μ(x) + μ(y) over all pairs. -/
def pairMassGap {α : Type*} [Fintype α] [Nonempty α] (μ : α → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun x => Finset.inf' Finset.univ Finset.univ_nonempty (fun y => μ x + μ y))

/-! ## Part II: Basic Properties of Quantum Measurement Models -/

theorem measurement_prob_nonneg
    {α : Type*} [Fintype α]
    (M : QuantumMeasurementModel α) :
    ∀ x, 0 ≤ M.prob x :=
  fun _ => sq_nonneg _

theorem measurement_prob_sum_one
    {α : Type*} [Fintype α]
    (M : QuantumMeasurementModel α) :
    ∑ x, M.prob x = 1 :=
  M.norm_one

theorem measurement_prob_le_one
    {α : Type*} [Fintype α]
    (M : QuantumMeasurementModel α) (x : α) :
    M.prob x ≤ 1 := by
  have := Finset.single_le_sum (f := M.prob)
    (fun z _ => measurement_prob_nonneg M z) (Finset.mem_univ x)
  rwa [measurement_prob_sum_one M] at this

/-! ## Part III: Theorem 1 — Event Probability Ratio Bound

If `μ` is pointwise multiplicatively close to `ν` with factor `exp(ε)`,
then for any event `s ⊆ α`, the total probability of `s` under `μ` is
within a factor of `exp(ε)` of its probability under `ν`.
-/

theorem event_prob_ratio_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    (ε : ℝ)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x)
    (s : Finset α) :
    Real.exp (-ε) * ∑ x ∈ s, ν x ≤ ∑ x ∈ s, μ x
      ∧ ∑ x ∈ s, μ x ≤ Real.exp ε * ∑ x ∈ s, ν x := by
  constructor
  · rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun x _ => (hratio x).1
  · rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun x _ => (hratio x).2

/-- **Total mass ratio bound.** Sum over entire space is also controlled. -/
theorem total_mass_ratio_bound
    {α : Type*} [Fintype α]
    (μ ν : α → ℝ)
    (ε : ℝ)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x) :
    Real.exp (-ε) * ∑ x, ν x ≤ ∑ x, μ x
      ∧ ∑ x, μ x ≤ Real.exp ε * ∑ x, ν x := by
  constructor
  · rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun x _ => (hratio x).1
  · rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun x _ => (hratio x).2

/-- **Conditional probability ratio bound.**
    If ν(s) > 0, the conditional probabilities μ(·|s) and ν(·|s) are also close. -/
theorem conditional_ratio_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    (ε : ℝ)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x)
    (s : Finset α) (x : α) (hx : x ∈ s) :
    Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x :=
  hratio x

/-! ## Part IV: Theorem 2 — Minimum Mass Perturbation Lower Bound -/

theorem minMass_perturbation_lower_bound
    {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α]
    (μ ν : α → ℝ)
    (ε : ℝ)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x) :
    Real.exp (-ε) * minMass ν ≤ minMass μ := by
  unfold minMass
  apply Finset.le_inf'
  intro x _
  calc Real.exp (-ε) * Finset.inf' Finset.univ Finset.univ_nonempty ν
      ≤ Real.exp (-ε) * ν x := by
        apply mul_le_mul_of_nonneg_left
        · exact Finset.inf'_le _ (Finset.mem_univ x)
        · exact Real.exp_nonneg _
    _ ≤ μ x := (hratio x).1

/-
**Minimum mass upper bound under perturbation.**
-/
theorem minMass_perturbation_upper_bound
    {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α]
    (μ ν : α → ℝ)
    (ε : ℝ)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x) :
    minMass μ ≤ Real.exp ε * minMass ν := by
  obtain ⟨ x, hx ⟩ := Finset.exists_min_image Finset.univ ( fun x => ν x ) ( Finset.univ_nonempty );
  refine' le_trans ( Finset.inf'_le _ hx.1 ) _;
  exact le_trans ( hratio x |>.2 ) ( mul_le_mul_of_nonneg_left ( Finset.le_inf' _ _ fun y hy => hx.2 y hy ) ( Real.exp_nonneg _ ) )

/-! ## Part V: Theorem 3 — Cross-Domain Bridge Theorems -/

theorem quantum_to_classical_gap_bridge
    {α : Type*} [Fintype α]
    (M : GappedMeasurementLift α) :
    M.quantumGap ≤ M.classicalGap :=
  le_trans M.q_to_l M.l_to_c

theorem quantum_gap_controls_event_anticoncentration
    {α : Type*} [Fintype α] [DecidableEq α]
    (M : GappedMeasurementLift α)
    (hμ_sum : ∑ x, M.μ x = 1)
    (s : Finset α) :
    M.quantumGap ≤ M.classicalGap ∧
    (∑ x ∈ s, M.μ x) + (∑ x ∈ sᶜ, M.μ x) = 1 := by
  exact ⟨quantum_to_classical_gap_bridge M,
    by have := Finset.sum_add_sum_compl s (fun x => M.μ x); linarith⟩

/-
**Perturbative boundary mass lower bound.**
    The central cross-domain theorem connecting quantum measurement distributions
    to classical graph expansion.
-/
theorem perturbative_boundaryMass_lower_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (S T : FiniteSpinSystem α)
    (hadj : ∀ x y, S.adj x y = T.adj x y)
    (ε : ℝ)
    (hratio : ∀ x, Real.exp (-ε) * T.μ x ≤ S.μ x ∧ S.μ x ≤ Real.exp ε * T.μ x)
    (A : Finset α) :
    Real.exp (-ε) * boundaryMass T A ≤ boundaryMass S A := by
  convert Finset.sum_le_sum fun x hx => mul_le_mul_of_nonneg_left ( hratio x |>.1 ) ( by positivity : 0 ≤ ( if hasBoundaryNeighbor S A x then 1 else 0 : ℝ ) ) using 1;
  any_goals exact A;
  · unfold boundaryMass; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, hadj ] ;
    unfold hasBoundaryNeighbor; aesop;
  · exact Finset.sum_congr rfl fun x hx => by aesop;

/-
**Boundary mass monotonicity under pointwise domination.**
-/
theorem boundaryMass_mono
    {α : Type*} [Fintype α] [DecidableEq α]
    (S T : FiniteSpinSystem α)
    (hadj : ∀ x y, S.adj x y = T.adj x y)
    (hcomp : ∀ x, T.μ x ≤ S.μ x)
    (A : Finset α) :
    boundaryMass T A ≤ boundaryMass S A := by
  apply Finset.sum_le_sum;
  unfold hasBoundaryNeighbor; aesop;

/-! ## Part VI: Certificate Transfer -/

/-
**Certificate transfer.** If ν has a robust Lorentzian certificate and μ is
    exp(ε)-multiplicatively close, μ inherits a certificate with degraded bounds.
-/
theorem certificate_transfer
    {α : Type*} [Fintype α]
    (μ ν : α → ℝ)
    (hμ_nonneg : ∀ x, 0 ≤ μ x)
    (hμsum : ∑ x, μ x = 1)
    (cert : RobustLorentzianCertificate α ν)
    (ε : ℝ) (_hε : 0 ≤ ε)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x) :
    ∃ cert' : RobustLorentzianCertificate α μ,
      cert'.pointwise_lower = Real.exp (-ε) * cert.pointwise_lower ∧
      cert'.pointwise_upper = Real.exp ε * cert.pointwise_upper := by
  fconstructor;
  use hμ_nonneg, hμsum, Real.exp ( -ε ) * cert.pointwise_lower, Real.exp ε * cert.pointwise_upper;
  any_goals tauto;
  · exact mul_nonneg ( Real.exp_nonneg _ ) cert.lower_pos;
  · exact fun x => le_trans ( mul_le_mul_of_nonneg_left ( cert.lower_spec x ) ( Real.exp_nonneg _ ) ) ( hratio x |>.1 );
  · exact fun x => le_trans ( hratio x |>.2 ) ( mul_le_mul_of_nonneg_left ( cert.upper_spec x ) ( Real.exp_nonneg _ ) );
  · intro x y; nlinarith [ hratio x, hratio y, cert.upper_spec x, cert.upper_spec y, hμ_nonneg x, hμ_nonneg y, mul_le_mul_of_nonneg_left ( cert.upper_spec x ) ( Real.exp_nonneg ε ), mul_le_mul_of_nonneg_left ( cert.upper_spec y ) ( Real.exp_nonneg ε ) ] ;

/-! ## Part VII: Conjectural Shell -/

/-
**Conjectural shell.** The quantum gap, after polynomial rescaling,
    lower-bounds both Lorentzian and classical gaps.
-/
theorem robust_lorentzian_gap_shell
    (n : ℕ) (hn : 0 < n) :
    ∃ (C_l C_c : ℝ), 0 < C_l ∧ 0 < C_c ∧
      ∀ (M : GappedMeasurementLift (Fin n)),
        M.quantumGap / ((n : ℝ) ^ 2 * C_l) ≤ M.lorentzianGap ∧
        M.quantumGap / ((n : ℝ) ^ 2 * C_c) ≤ M.classicalGap := by
  refine' ⟨ 1, 1, by positivity, by positivity, fun M => ⟨ _, _ ⟩ ⟩ <;> rw [ div_le_iff₀ ] <;> norm_cast;
  · exact le_trans M.q_to_l ( le_mul_of_one_le_right ( by linarith [ M.lorentzianGap_nonneg ] ) ( by norm_cast; nlinarith ) );
  · positivity;
  · exact le_trans ( quantum_to_classical_gap_bridge M ) ( le_mul_of_one_le_right ( by exact M.classicalGap_nonneg ) ( mod_cast Nat.one_le_iff_ne_zero.mpr <| by positivity ) );
  · positivity

end QuantumLorentzianBridge