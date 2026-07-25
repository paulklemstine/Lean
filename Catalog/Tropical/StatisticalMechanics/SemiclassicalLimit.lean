import Mathlib

/-!
# Tropical Statistical Mechanics: Semiclassical Limit

This file establishes the **zero-temperature semiclassical limit**: the classical
free energy F(β) = (-1/β) log Z(β) converges to the tropical partition function
(ground state energy) as β → ∞, with explicit convergence rate O(log|Ω|/β).

## Bridge: Classical Thermodynamics ↔ Tropical Algebra ↔ Quantum Mechanics

The semiclassical limit provides the physical justification for tropical statistical
mechanics: it shows that tropical mechanics is NOT an abstract algebraic curiosity,
but rather the exact zero-temperature limit of classical thermodynamics.

## Main Results

1. `TSM.partitionFn_pos` — Positivity of the classical partition function
2. `TSM.partitionFn_lower_bound` — Lower bound via ground state
3. `TSM.partitionFn_upper_bound` — Upper bound via system size
4. `TSM.freeEnergy_le_ground` — Free energy ≤ ground state energy
5. `TSM.freeEnergy_ge_ground_sub_log` — Free energy ≥ E₀ - log|Ω|/β
6. `TSM.freeEnergy_approximation_rate` — |F(β) - E₀| ≤ log|Ω|/β
7. `TSM.zeroTemperature_limit` — F(β) → E₀ as β → ∞

## Applications

- **quantum_ground_state_certified_computation**: The convergence rate gives
  explicit β needed to approximate the ground state energy to precision ε.
- **post_quantum_security**: Bounds on lattice problem approximation hardness.
- **idempotent_dequantization**: Maslov's dequantization program realized via limits.
-/

noncomputable section

open scoped Topology
open Real Set Finset Filter

namespace TSM

/-- The classical partition function Z(β) = Σ_{σ∈Ω} exp(-β · H(σ)). -/
def partitionFn {Ω : Type*} [Fintype Ω] (H : Ω → ℝ) (β : ℝ) : ℝ :=
  ∑ σ : Ω, Real.exp (-β * H σ)

/-- The classical free energy F(β) = (-1/β) · log Z(β).
    Bridge: idempotent_dequantization. -/
def freeEnergy {Ω : Type*} [Fintype Ω] (H : Ω → ℝ) (β : ℝ) : ℝ :=
  (-1 / β) * Real.log (∑ σ : Ω, Real.exp (-β * H σ))

/-! ## Partition Function Bounds -/

/-
The classical partition function is always positive.
    Bridge: fundamental positivity for thermodynamic quantities.
-/
theorem partitionFn_pos {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) (β : ℝ) : 0 < partitionFn H β := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty

/-
Lower bound on Z(β): Z(β) ≥ exp(-β · E₀).
    Bridge: quantum_ground_state_certified_computation.
-/
theorem partitionFn_lower_bound {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) (β : ℝ) :
    Real.exp (-β * (⨅ σ, H σ)) ≤ partitionFn H β := by
  obtain ⟨ σ₀, hσ₀ ⟩ := ( show ∃ σ₀, H σ₀ = ⨅ σ, H σ from by simpa using ( IsCompact.sInf_mem ( Set.finite_range H |> Set.Finite.isCompact ) ( Set.nonempty_of_mem ( Set.mem_range_self ( Classical.arbitrary Ω ) ) ) ) );
  exact hσ₀ ▸ Finset.single_le_sum ( fun σ _ => Real.exp_nonneg ( -β * H σ ) ) ( Finset.mem_univ σ₀ )

/-
Upper bound on Z(β): Z(β) ≤ |Ω| · exp(-β · E₀).
    Bridge: post_quantum_security.
-/
theorem partitionFn_upper_bound {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) (β : ℝ) (hβ : 0 ≤ β) :
    partitionFn H β ≤ Fintype.card Ω * Real.exp (-β * (⨅ σ, H σ)) := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr <| mul_le_mul_of_nonpos_left (ciInf_le ( Finite.bddBelow_range H ) _ ) <| neg_nonpos.mpr hβ ) <| by simp +decide [ mul_comm ] ;

/-! ## Free Energy Bounds

The classical free energy satisfies: E₀ - log|Ω|/β ≤ F(β) ≤ E₀.
Note: F(β) ≤ E₀ because Z(β) ≥ exp(-β·E₀), so log Z ≥ -β·E₀,
giving (-1/β)·log Z ≤ E₀. The lower bound uses Z ≤ |Ω|·exp(-β·E₀).
-/

/-
**Upper bound: F(β) ≤ E₀.**
    The free energy never exceeds the ground state energy.
    In physics: F = E - TS ≤ E₀ because -TS ≤ 0.

    Bridge: quantum_ground_state_certified_computation.
-/
theorem freeEnergy_le_ground {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) (β : ℝ) (hβ : 0 < β) :
    freeEnergy H β ≤ ⨅ σ, H σ := by
  -- By definition of freeEnergy, we have:
  unfold freeEnergy;
  rw [ div_mul_eq_mul_div, div_le_iff₀' hβ ];
  have := partitionFn_lower_bound H β;
  linarith! [ Real.log_exp ( -β * ⨅ σ, H σ ), Real.log_le_log ( by positivity ) this ]

/-
**Lower bound: F(β) ≥ E₀ - log|Ω|/β.**
    The free energy deviates from the ground state energy by at most log|Ω|/β.

    Bridge: idempotent_dequantization — rate of Maslov's dequantization.
-/
theorem freeEnergy_ge_ground_sub_log {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) (β : ℝ) (hβ : 0 < β) :
    (⨅ σ, H σ) - Real.log (Fintype.card Ω) / β ≤ freeEnergy H β := by
  unfold freeEnergy;
  rw [ div_mul_eq_mul_div, le_div_iff₀' hβ ];
  have := partitionFn_upper_bound H β hβ.le;
  rw [ mul_sub, mul_div_cancel₀ _ hβ.ne' ];
  have := Real.log_le_log ( partitionFn_pos H β ) this;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at this ; linarith!

/-
**Convergence rate: |F(β) - E₀| ≤ log|Ω|/β.**
    Bridge: quantum_ground_state_certified_computation —
    to approximate E₀ within ε, set β ≥ log(|Ω|)/ε.
-/
theorem freeEnergy_approximation_rate {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) (β : ℝ) (hβ : 0 < β) :
    |freeEnergy H β - (⨅ σ, H σ)| ≤ Real.log (Fintype.card Ω) / β := by
  rw [ abs_of_nonpos ];
  · linarith [ freeEnergy_ge_ground_sub_log H β hβ ];
  · exact sub_nonpos_of_le ( freeEnergy_le_ground H β hβ )

/-! ## The Zero-Temperature Limit -/

/-
**Zero-Temperature Semiclassical Limit.**
    F(β) → E₀ as β → ∞.
    The tropical partition function IS the zero-temperature limit
    of the classical free energy.

    Bridge: idempotent_dequantization and
    quantum_ground_state_certified_computation.
-/
theorem zeroTemperature_limit {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (H : Ω → ℝ) :
    Tendsto (freeEnergy H) atTop (nhds (⨅ σ, H σ)) := by
  refine' ( tendsto_iff_norm_sub_tendsto_zero.mpr _ );
  refine' squeeze_zero_norm' _ _;
  exact fun n => Real.log ( Fintype.card Ω ) / n;
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using by simpa using freeEnergy_approximation_rate H n hn;
  · exact tendsto_const_nhds.div_atTop Filter.tendsto_id

end TSM

end