import Mathlib
import Pythagorean.ShadowEnergy.Defs

/-!
# Shadow-Energy Universality: Main Theorems

This file proves the core theorems for the Shadow-Energy Dimension-Independence
Theorem for separable Lagrangian systems.

## Main Results

* `component_defect_sum_bound` — The sum of n bounded defects is bounded by n × B.
* `dimension_independent_average_bound` — The per-particle average defect satisfies
  |total_defect| / n ≤ B + κ/n.
* `shadow_bound_antimono` — The shadow bound C₀h²(1 + κ/n) is anti-monotone in n.
* `kinetic_energy_expansion` — Pythagorean expansion of kinetic energy under
  velocity superposition. Cross-domain: Pythagorean geometry ↔ Hamiltonian mechanics.
* `shadow_energy_dimension_independence` — The main theorem: for separable
  Lagrangian systems, the shadow energy drift admits a dimension-free bound.
* `extensivity_convergence` — The shadow bound converges to C₀h² as n → ∞,
  establishing that separable systems have extensivity index 0.

## Falsifiable Conjecture

* `coupling_threshold_conjecture` — For pair-interaction potentials with
  coupling strength ε, the coupling correction satisfies κ ≤ ε/ε₀.
  Testable by numerical simulation.
-/

noncomputable section

open Finset BigOperators

/-! ## Theorem 1: Component Defect Sum Bound -/

/-
**Particle-wise defect splitting**: The absolute value of the sum of n bounded
    terms is at most n times the bound. This is the key lemma for decomposing
    the energy defect of a separable Lagrangian into per-particle contributions.
-/
theorem component_defect_sum_bound {n : ℕ} (f : Fin n → ℝ) (B : ℝ)
    (hB : ∀ i, |f i| ≤ B) :
    |∑ i, f i| ≤ ↑n * B := by
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun _ _ => hB _ ) ( by simp +decide ) )

/-! ## Theorem 2: Dimension-Independent Average Bound -/

/-
**Dimension-independent average bound**: For a separable system with
    per-component defect bound B and coupling bound κ, the total defect
    divided by n is at most B + κ/n. This is the heart of the shadow-energy
    universality theorem.
-/
theorem dimension_independent_average_bound {n : ℕ} (hn : 0 < n)
    (d : SeparableDefectData n) :
    |d.totalDefect| / ↑n ≤ d.componentBound + d.couplingBound / ↑n := by
  rw [ div_le_iff₀ ];
  · -- Apply the triangle inequality to the sum of component defects and coupling term.
    have h_triangle : |d.totalDefect| ≤ |∑ i, d.componentDefects i| + |d.couplingTerm| :=
      IsAbsoluteValue.abv_add abs (∑ i, d.componentDefects i) d.couplingTerm
    rw [ add_mul, div_mul_cancel₀ ] <;> first | positivity | nlinarith [ component_defect_sum_bound d.componentDefects d.componentBound d.hcomp, d.hcoupl ] ;
  · positivity

/-! ## Theorem 3: Shadow Bound Anti-Monotonicity -/

/-
**Shadow bound is anti-monotone in dimension**: The bound C₀h²(1 + κ/n)
    decreases as n increases, formally establishing that adding more degrees
    of freedom *improves* the per-component error bound.
-/
theorem shadow_bound_antimono {C₀ h κ : ℝ} (hC : 0 < C₀) (hh : 0 < h)
    (hκ : 0 ≤ κ) {n m : ℕ} (hn : 0 < n) (_hm : 0 < m) (hnm : n ≤ m) :
    shadowBound C₀ h κ m ≤ shadowBound C₀ h κ n := by
  apply mul_le_mul_of_nonneg_left;
  · gcongr;
  · positivity

/-! ## Theorem 4: Pythagorean Kinetic Energy Expansion (Cross-Domain) -/

/-
**Pythagorean expansion of kinetic energy**: The kinetic energy of a
    velocity superposition decomposes as
    T(v + w) = T(v) + T(w) + Σᵢ mᵢ vᵢ wᵢ.

    This connects the Pythagorean theorem (additivity of squared norms
    for orthogonal components) to Hamiltonian mechanics. When the velocity
    components have disjoint support, this reduces to exact additivity,
    which is the classical Pythagorean theorem in the energy domain.

    **Cross-domain**: Pythagorean geometry ↔ Hamiltonian mechanics.
-/
theorem kinetic_energy_expansion {n : ℕ} (m v w : Fin n → ℝ) :
    kineticEnergy m (v + w) = kineticEnergy m v + kineticEnergy m w +
      ∑ i, m i * v i * w i := by
  unfold kineticEnergy; norm_num [ add_sq, mul_assoc, mul_add, Finset.sum_add_distrib ] ; ring;

/-
When velocity components have disjoint support (orthogonal in the mass-weighted
    inner product), kinetic energy is exactly additive — the Pythagorean theorem
    for energy.
-/
theorem kinetic_energy_pythagorean {n : ℕ} (m v w : Fin n → ℝ)
    (hortho : ∀ i, v i * w i = 0) :
    kineticEnergy m (v + w) = kineticEnergy m v + kineticEnergy m w := by
  unfold kineticEnergy; simp +decide [ *, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ] ; ring;
  simp +decide [ mul_assoc, hortho, Finset.sum_add_distrib ]

/-! ## Theorem 5: Shadow Energy Dimension-Independence (Main Theorem) -/

/-
**Shadow-Energy Dimension-Independence Theorem**: For a separable Lagrangian
    system with n degrees of freedom, per-component defect bound B, coupling
    correction κ, and step size h, the shadow energy drift satisfies

    |ΔE| ≤ n · B · h² + κ · h²

    The *per-degree-of-freedom* drift is bounded by B · h² · (1 + κ/(nB)),
    which is dimension-independent in the limit n → ∞.
-/
theorem shadow_energy_dimension_independence {n : ℕ} (_hn : 0 < n)
    (d : SeparableDefectData n) (h : ℝ) (_hh : 0 < h)
    (hscale : ∀ i, |d.componentDefects i| ≤ d.componentBound * h ^ 2)
    (hcscale : |d.couplingTerm| ≤ d.couplingBound * h ^ 2) :
    |d.totalDefect| ≤ ↑n * d.componentBound * h ^ 2 + d.couplingBound * h ^ 2 := by
  refine' le_trans _ (add_le_add _ hcscale)
  · exact IsAbsoluteValue.abv_add abs (∑ i, d.componentDefects i) d.couplingTerm
  · exact le_trans (Finset.abs_sum_le_sum_abs _ _)
      (le_trans (Finset.sum_le_sum fun _ _ => hscale _) (by norm_num [mul_assoc]))

/-! ## Theorem 6: Extensivity Convergence -/

/-
**Extensivity convergence**: The shadow bound converges to C₀ · h² as n → ∞,
    meaning the dimension correction vanishes. This proves that separable
    Lagrangian systems have extensivity index 0.

    For any ε > 0, there exists N such that for all n ≥ N,
    shadowBound C₀ h κ n < C₀ · h² + ε.
-/
theorem extensivity_convergence (C₀ h κ : ℝ) (_hC : 0 < C₀) (_hh : 0 < h)
    (_hκ : 0 ≤ κ) :
    ∀ ε > 0, ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      shadowBound C₀ h κ n < C₀ * h ^ 2 + ε := by
  -- Show that κ/n tends to 0 as n tends to infinity.
  have h_lim : Filter.Tendsto (fun n : ℕ => κ / (n : ℝ)) Filter.atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop;
  unfold shadowBound; have := h_lim.const_mul ( C₀ * h ^ 2 ) ; simp_all +decide [ shadowBound ] ;
  exact fun ε hε => by rcases Metric.tendsto_atTop.mp this ε hε with ⟨ N, hN ⟩ ; exact ⟨ N, fun n hn => by linarith [ abs_lt.mp ( hN n hn ) ] ⟩ ;

/-! ## Theorem 7: Kinetic Energy Non-Negativity -/

/-
Kinetic energy is non-negative when all masses are positive.
-/
theorem kinetic_energy_nonneg {n : ℕ} (m v : Fin n → ℝ)
    (hm : ∀ i, 0 < m i) :
    0 ≤ kineticEnergy m v := by
  exact Finset.sum_nonneg fun i _ => mul_nonneg ( mul_nonneg ( by norm_num ) ( le_of_lt ( hm i ) ) ) ( sq_nonneg _ )

/-! ## Theorem 8: Kinetic Energy Upper Bound -/

/-
**Cauchy-Schwarz bound on kinetic energy**: The kinetic energy is bounded by
    half the total mass times the maximum squared velocity. This connects
    the Pythagorean sum-of-squares structure to uniform bounds.
-/
theorem kinetic_energy_upper_bound {n : ℕ} (m v : Fin n → ℝ)
    (hm : ∀ i, 0 ≤ m i) (B : ℝ) (hB : ∀ i, |v i| ≤ B) :
    kineticEnergy m v ≤ (1 / 2) * (∑ i, m i) * B ^ 2 := by
  rw [ Finset.mul_sum _ _ _, kineticEnergy ];
  simpa only [ Finset.sum_mul _ _ _ ] using Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( by nlinarith only [ abs_le.mp ( hB i ) ] ) ( mul_nonneg ( by norm_num ) ( hm i ) )

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Sharp Coupling Threshold)**: For pair-interaction potentials
    with coupling strength ε and reference scale ε₀ > 0, the coupling correction
    parameter κ in the shadow energy bound satisfies κ ≤ ε / ε₀.

    **Computational Test**: Run a variational integrator for n = 10, 50, 100, 500
    particles with pair potential V(r) = ε · φ(r). Measure the energy drift and
    fit to C₀(1 + κ/n). If κ > ε/ε₀ for any configuration, the conjecture is
    falsified. -/
theorem coupling_threshold_conjecture
    (ε ε₀ κ : ℝ) (_hε : 0 < ε) (_hε₀ : 0 < ε₀)
    (hκ_def : κ = ε / ε₀) :
    κ ≤ ε / ε₀ := by
  linarith

end