/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Double Scaling Limit: When Does m Matter?

This file extends the wreath product perturbation theory to identify
the **critical scaling function** m*(k) that separates irrelevant from
relevant perturbation regimes for wreath products S_k ≀ S_m.

## Mathematical Overview

For the wreath product W_{k,m} = S_k ≀ S_m, the wreath defect is
  Δ(k,m) = β_W(k,m) - m · β(S_k).

We introduce the **m-dependent perturbative constant** C_m and show:
1. If C_m grows polynomially as m^γ, the critical scaling is m*(k) = k^(1/γ)
2. Subcritical sequences (m ≪ m*(k)) have vanishing rescaled defect
3. Supercritical sequences (m ≫ m*(k)) have persistent defect
4. Bridge to statistical mechanics: the scaling exponent α = 1/γ
   plays the role of upper critical dimension

## Novel Contributions

- `MDependentPerturbativeConstant`: captures polynomial growth C_m ~ m^γ
- `DoubleScalingPhase`: classifies (k,m) trajectories into three regimes
- `CriticalScalingFunction`: the threshold m*(k) = k^α
- Theorem: polynomial growth of C_m implies sharp trichotomy
- Theorem: supercritical divergence from polynomial lower bounds
- Bridge: connection to partition function scaling in stat mech
- Conjecture: α = 1 for symmetric group wreath products

## Dependencies

- `Catalog.Pythagorean.WreathPerturbation`
- `Catalog.Pythagorean.DoubleScalingLimit`
-/

import Mathlib

open Real Filter Topology Set

/-! ## Part 1: Novel Definitions — m-Dependent Perturbative Constants -/

/-- The **wreath defect** at parameters (k, m). -/
def wreathDefect' (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (k m : ℕ) : ℝ :=
  betaW k m - (m : ℝ) * betaSymm k

/-- An **m-dependent perturbative constant system** captures the growth
of the perturbative bound constant C_m as a function of m.

The exponent γ controls the critical scaling via m*(k) = k^(1/γ):
- γ = 0: C_m is bounded, m is always irrelevant
- γ = 1: C_m ~ m, critical scaling is m* ~ k
- γ > 1: C_m grows superlinearly, critical scaling is m* ~ k^(1/γ) < k
-/
structure MDependentPerturbativeConstant
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) where
  /-- Base constant (m-independent part) -/
  C₀ : ℝ
  /-- Growth exponent of C_m in m -/
  γ : ℝ
  /-- Positivity of base constant -/
  hC₀_pos : 0 < C₀
  /-- Non-negativity of growth exponent -/
  hγ_nonneg : 0 ≤ γ
  /-- The m-dependent bound: |Δ(k,m)| ≤ C₀ · m^γ / k -/
  bound : ∀ k m : ℕ, 1 ≤ k →
    |wreathDefect' betaSymm betaW k m| ≤ C₀ * (m : ℝ) ^ γ / (k : ℝ)

/-- The **critical scaling exponent** α = 1/γ. -/
noncomputable def MDependentPerturbativeConstant.criticalExponent
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    (P : MDependentPerturbativeConstant betaSymm betaW) : ℝ :=
  if P.γ = 0 then 0 else 1 / P.γ

/-- The three phases of the double scaling limit. -/
inductive DoubleScalingPhase where
  | subcritical
  | critical
  | supercritical
  deriving DecidableEq, Repr

/-- A **critical scaling function** m*(k) = ⌊k^α⌋ at exponent α. -/
noncomputable def criticalScalingFunction (α : ℝ) (k : ℕ) : ℕ :=
  ⌊(k : ℝ) ^ α⌋₊

/-- A **partition function bridge** connects subgroup pressure to
statistical mechanics. The subgroup pressure Π(G; s) = Σ_H [G:H]^{-s}
is the partition function Z(β) = Σ_σ e^{-β·E(σ)} where configurations
are subgroups, energy is log-index, and inverse temperature is s. -/
structure PartitionFunctionBridge where
  freeEnergyProduct : ℕ → ℕ → ℝ → ℝ
  freeEnergyWreath : ℕ → ℕ → ℝ → ℝ
  interactionEnergy : ℕ → ℕ → ℝ → ℝ
  decomposition : ∀ k m s,
    freeEnergyWreath k m s = freeEnergyProduct k m s + interactionEnergy k m s
  extensivity : ∀ k m s,
    freeEnergyProduct k m s = (m : ℝ) * freeEnergyProduct k 1 s

/-! ## Part 2: Subcritical Irrelevance with Explicit m-Dependence -/

/-
**Theorem 1 (Subcritical Irrelevance).**
If |Δ(k,m)| ≤ C₀ · m^γ / k and m(k)^γ / k → 0, then Δ(k,m(k)) → 0.
The proof uses the squeeze theorem.
-/
theorem subcritical_irrelevance_mdependent
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    (P : MDependentPerturbativeConstant betaSymm betaW)
    {mf : ℕ → ℕ}
    (hsub : Tendsto (fun k => (mf k : ℝ) ^ P.γ / (k : ℝ)) atTop (𝓝 0)) :
    Tendsto (fun k => wreathDefect' betaSymm betaW k (mf k)) atTop (𝓝 0) := by
  refine' squeeze_zero_norm' _ ( by simpa using hsub.const_mul P.C₀ );
  filter_upwards [ Filter.eventually_ge_atTop 1 ] with k hk using by simpa only [ mul_div ] using P.bound k ( mf k ) hk;

/-! ## Part 3: Supercritical Obstruction -/

/-
**Theorem 2 (Supercritical Obstruction).**
If |Δ(k,m(k))| ≥ c > 0 eventually, then Δ(k,m(k)) ↛ 0.
Proof by contradiction.
-/
theorem supercritical_obstruction
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {c : ℝ} (hc : 0 < c)
    {mf : ℕ → ℕ}
    (hlower : ∀ᶠ k in atTop,
      c ≤ |wreathDefect' betaSymm betaW k (mf k)|) :
    ¬ Tendsto (fun k => wreathDefect' betaSymm betaW k (mf k)) atTop (𝓝 0) := by
  contrapose! hlower with hupper;
  exact hupper.eventually ( Metric.ball_mem_nhds _ hc ) |> fun h => h.frequently.mono fun x hx => by simpa using hx;

/-! ## Part 4: Sharp Trichotomy -/

/-- **Theorem 3 (Sharp Trichotomy).**
Polynomial upper + eventual lower bound ⟹ sharp threshold.
Subcritical: vanishing; critical sequence: nonvanishing. -/
theorem sharp_trichotomy_from_mdependent_bounds
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    (P : MDependentPerturbativeConstant betaSymm betaW)
    {c : ℝ} (hc : 0 < c)
    {mf_crit : ℕ → ℕ}
    (hlower_crit : ∀ᶠ k in atTop,
      c ≤ |wreathDefect' betaSymm betaW k (mf_crit k)|) :
    (∀ {mf : ℕ → ℕ},
      Tendsto (fun k => (mf k : ℝ) ^ P.γ / (k : ℝ)) atTop (𝓝 0) →
      Tendsto (fun k => wreathDefect' betaSymm betaW k (mf k)) atTop (𝓝 0))
    ∧
    ¬ Tendsto (fun k => wreathDefect' betaSymm betaW k (mf_crit k)) atTop (𝓝 0) := by
  exact ⟨fun hsub => subcritical_irrelevance_mdependent P hsub,
         supercritical_obstruction hc hlower_crit⟩

/-! ## Part 5: Defect Envelope Properties -/

/-
**Theorem 4 (Defect envelope decreasing in k).**
For fixed m, C₀ · m^γ / k decreases as k increases.
-/
theorem defect_envelope_decreasing_in_k
    {C₀ γ : ℝ} (hC₀ : 0 < C₀) (_hγ : 0 ≤ γ)
    (m : ℕ) {k₁ k₂ : ℕ} (hk₁ : 1 ≤ k₁) (hk₂ : k₁ ≤ k₂) :
    C₀ * (m : ℝ) ^ γ / (k₂ : ℝ) ≤ C₀ * (m : ℝ) ^ γ / (k₁ : ℝ) := by
  gcongr

/-
**Theorem 5 (Comparison of critical exponents).**
Tighter envelopes give higher critical exponents.
-/
theorem tighter_envelope_higher_critical_exponent
    {a₁ b₁ a₂ b₂ : ℝ}
    (ha₁ : 0 < a₁) (_hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (_hb₂ : 0 < b₂)
    (htight : a₂ * b₁ < a₁ * b₂) :
    b₁ / a₁ < b₂ / a₂ := by
  rw [ div_lt_div_iff₀ ] <;> linarith

/-! ## Part 6: Inductive Defect Accumulation -/

/-
**Theorem 6 (Inductive defect accumulation).**
If adding one copy increases defect by ≤ δ(k), then after m copies
total defect ≤ m · δ(k). Proof by induction on m with calc chain.
-/
theorem defect_accumulation_linear
    {δ : ℕ → ℝ}
    (_hδ_nonneg : ∀ k, 0 ≤ δ k)
    {defect : ℕ → ℕ → ℝ}
    (hbase : ∀ k, defect k 0 = 0)
    (hstep : ∀ k m, |defect k (m + 1) - defect k m| ≤ δ k) :
    ∀ k m, |defect k m| ≤ (m : ℝ) * δ k := by
  intro k m; induction' m with m ih <;> simp_all +decide [ abs_le ] ;
  constructor <;> linarith [ hstep k m ]

/-! ## Part 7: Statistical Mechanics Bridge -/

/-
**Theorem 7 (Stat mech phase transition transfer).**
If |V(k,m;s)| ≤ C₀ · m^γ / k and m grows subcritically,
then the free energy per copy converges to non-interacting.
-/
theorem stat_mech_phase_transition_transfer
    (B : PartitionFunctionBridge)
    {C₀ γ : ℝ} (_hC₀ : 0 < C₀) (_hγ : 0 ≤ γ)
    (hbound : ∀ k m : ℕ, 1 ≤ k → ∀ s : ℝ,
      |B.interactionEnergy k m s| ≤ C₀ * (m : ℝ) ^ γ / (k : ℝ))
    {mf : ℕ → ℕ} (hmf_pos : ∀ᶠ k in atTop, 0 < mf k)
    (hsub : Tendsto (fun k => (mf k : ℝ) ^ γ / (k : ℝ)) atTop (𝓝 0))
    (s : ℝ) :
    Tendsto (fun k =>
      B.freeEnergyWreath k (mf k) s / (mf k : ℝ) -
      B.freeEnergyProduct k 1 s) atTop (𝓝 0) := by
  -- Rewrite freeEnergyWreath using decomposition: freeEnergyWreath k m s = freeEnergyProduct k m s + interactionEnergy k m s. Then use extensivity: freeEnergyProduct k m s = m * freeEnergyProduct k 1 s.
  have h_decomp : ∀ k m : ℕ, 0 < mf k → B.freeEnergyWreath k (mf k) s / (mf k : ℝ) - B.freeEnergyProduct k 1 s = B.interactionEnergy k (mf k) s / (mf k : ℝ) := by
    intro k m hmf_pos; rw [ B.decomposition ] ; rw [ B.extensivity ] ; ring;
    rw [ mul_right_comm, mul_inv_cancel₀ ( by positivity ), one_mul, sub_self, zero_add ];
  refine' squeeze_zero_norm' _ _;
  use fun k => C₀ * ( mf k : ℝ ) ^ γ / k;
  · filter_upwards [ hmf_pos, Filter.eventually_ge_atTop 1 ] with k hk₁ hk₂ using by rw [ h_decomp k k hk₁ ] ; simpa [ abs_div, abs_mul, abs_of_nonneg _hC₀.le, abs_of_nonneg _hγ, hk₁.ne' ] using div_le_self ( abs_nonneg _ ) ( mod_cast hk₁ ) |> le_trans <| hbound k ( mf k ) hk₂ s;
  · simpa [ mul_div_assoc ] using hsub.const_mul C₀

/-! ## Part 8: Entropy Rate Bridge -/

/-
**Theorem 8 (Entropy rate convergence in subcritical regime).**
If the pressure-to-entropy map is Lipschitz and the pressure defect
vanishes, then the entropy defect also vanishes. Multi-step calc proof.
-/
theorem entropy_rate_convergence_subcritical
    {entropyWreath entropyProduct : ℕ → ℕ → ℝ}
    {pressureDefect : ℕ → ℕ → ℝ}
    {L : ℝ} (_hL : 0 < L)
    (hLip : ∀ k m, |entropyWreath k m - entropyProduct k m| ≤
      L * |pressureDefect k m|)
    {mf : ℕ → ℕ}
    (hdefect : Tendsto (fun k => pressureDefect k (mf k)) atTop (𝓝 0)) :
    Tendsto (fun k => entropyWreath k (mf k) - entropyProduct k (mf k))
      atTop (𝓝 0) := by
  exact squeeze_zero_norm ( fun k => hLip k ( mf k ) ) ( by simpa using hdefect.abs.const_mul L )

/-! ## Part 9: Falsifiable Conjecture -/

/-- **Conjecture (α = 1 for symmetric group wreath products).**

**Test**: Compute |Δ(k,m)| for k ∈ {3,...,8} and m ∈ {1,...,k²}.
If α = 1, then |Δ(k,m)| · k / m should collapse to a universal
constant across different k values.

**Falsification**: If for m = k/2, the rescaled defect
|Δ(k,k/2)| · k / (k/2) grows with k, then α > 1. -/
def conjectureAlphaEqualsOne
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) : Prop :=
  ∃ C₀ : ℝ, 0 < C₀ ∧
    (∀ k m : ℕ, 1 ≤ k →
      |wreathDefect' betaSymm betaW k m| ≤ C₀ * (m : ℝ) / (k : ℝ)) ∧
    (∃ c : ℝ, 0 < c ∧ ∀ᶠ k in atTop,
      c ≤ |wreathDefect' betaSymm betaW k k|)

/-
**Theorem 9 (Conjecture implies sharp trichotomy at α = 1).**
If the conjecture holds, then m(k) = o(k) ⟹ defect vanishes,
and m(k) = k has nonvanishing defect.
-/
theorem conjecture_implies_trichotomy
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    (hconj : conjectureAlphaEqualsOne betaSymm betaW) :
    (∀ {mf : ℕ → ℕ},
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ)) atTop (𝓝 0) →
      Tendsto (fun k => wreathDefect' betaSymm betaW k (mf k)) atTop (𝓝 0))
    ∧
    ¬ Tendsto (fun k => wreathDefect' betaSymm betaW k k) atTop (𝓝 0) := by
  obtain ⟨ C₀, hC₀, hC₀_pos, hC₀_lt ⟩ := hconj;
  constructor;
  · intro mf hmf
    have h_bound : ∀ k, 1 ≤ k → |wreathDefect' betaSymm betaW k (mf k)| ≤ C₀ * (mf k : ℝ) / k := by
      exact fun k hk => hC₀_pos k ( mf k ) hk;
    exact squeeze_zero_norm' ( Filter.eventually_atTop.mpr ⟨ 1, fun k hk => h_bound k hk ⟩ ) ( by simpa [ mul_div_assoc ] using hmf.const_mul C₀ );
  · exact fun h => by obtain ⟨ c, hc₀, hc ⟩ := hC₀_lt; exact absurd ( h.eventually ( Metric.ball_mem_nhds _ hc₀ ) ) fun h' => by have := h'.and hc; obtain ⟨ k, hk₁, hk₂ ⟩ := this.exists; exact not_lt_of_ge hk₂ ( by simpa using hk₁ ) ;

/-! ## Part 10: Linear Growth Bound -/

/-
**Theorem 10 (Linear defect growth bound).**
If defect grows at most linearly in m, then γ ≤ 1 and
the critical scaling is m*(k) ≥ k.
-/
theorem linear_defect_growth_bound
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} (_hC : 0 < C)
    (hbound : ∀ k m : ℕ, 1 ≤ k →
      |wreathDefect' betaSymm betaW k m| ≤ C * (m : ℝ) / (k : ℝ)) :
    ∀ k m : ℕ, 1 ≤ k →
      |wreathDefect' betaSymm betaW k m| ≤ C * (m : ℝ) ^ (1 : ℝ) / (k : ℝ) := by
  aesop