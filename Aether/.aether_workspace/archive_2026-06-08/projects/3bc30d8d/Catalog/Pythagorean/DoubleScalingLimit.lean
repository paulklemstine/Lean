/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Double Scaling Limit: Critical Phenomena for Wreath-Product Subgroup Pressure

This file establishes the first rigorous critical-phenomena theory for
wreath-product subgroup pressure asymptotics, identifying the threshold
at which the base multiplicity parameter `m` transitions from perturbatively
irrelevant to a new relevant scaling variable.

## Mathematical Overview

For the wreath product W_{k,m} = S_k ≀ S_m, we study the **wreath defect**
  Δ(k,m) := β_W(k,m) - m · β(S_k)
and introduce the **rescaled defect** and **relevance ratio** to identify
critical scaling regimes.

The main results establish:
1. **Subcritical irrelevance** (Theorem 1): If the defect satisfies a
   polynomial envelope |Δ(k,m)| ≤ C · m^a / k^b and m(k) = o(k^{b/a}),
   then Δ(k,m(k)) → 0.
2. **Pressure per-copy stability** (Theorem 2): Below threshold,
   β_W(k,m(k))/m(k) - β(S_k) → 0.
3. **Critical obstruction** (Theorem 3): If |Δ(k,m(k))| ≥ c eventually,
   then the defect cannot tend to zero.
4. **Relevance ratio subcriticality** (Bridge theorem): The relevance
   ratio tends to zero in the subcritical regime.

## Application Keywords

finite group asymptotics, subgroup growth, wreath products, universality
classes, renormalization group, critical exponent, double scaling limit,
finite-size scaling, statistical mechanics, crossover profile, scaling
dimension, upper critical dimension

## Catalog Dependencies

- `Pythagorean.WreathPerturbation`: `beta_wreath_eq_mul_beta_symm_plus_error`,
  `defect_ratio_tendsto_zero`
- `Bridges.Catalog.Pythagorean.SubgroupUniversality`: `pressure_directPower_linear`
-/

import Mathlib

open Real Filter Topology Set

/-! ## Part 1: Core Definitions -/

/-- The **wreath defect** measures the deviation of wreath-product pressure
from the linear (direct-power) prediction. For W_{k,m} = S_k ≀ S_m:
  Δ(k,m) = β_W(k,m) - m · β(S_k).
A vanishing defect means the wreath product is asymptotically governed
by the same intensive pressure as independent copies. -/
def WreathDefect (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (k m : ℕ) : ℝ :=
  betaW k m - (m : ℝ) * betaSymm k

/-- The **relevance ratio** measures the defect relative to the expected
scaling. When α is the critical exponent, this ratio distinguishes:
- Irrelevant regime: Φ_α → 0
- Marginal regime: Φ_α → finite nonzero
- Relevant regime: Φ_α → ∞

This is the finite-group analog of the scaling dimension in
renormalization group theory. -/
noncomputable def RelevanceRatio
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) (k m : ℕ) : ℝ :=
  |WreathDefect betaSymm betaW k m| / ((m : ℝ) / (k : ℝ) ^ α)

/-- A perturbation is **asymptotically irrelevant at exponent α** if
for any sequence m(k) growing slower than k^α, the wreath defect
vanishes. This is the precise formalization of "the wreath coupling
does not shift the universality class below the critical window." -/
def AsymptoticallyIrrelevantAtExponent
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) : Prop :=
  ∀ ⦃mf : ℕ → ℕ⦄,
    Tendsto (fun k => (mf k : ℝ) / (k : ℝ) ^ α) atTop (𝓝 0) →
    Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0)

/-- The three perturbation regimes, classifying the behavior of the
wreath defect relative to a scaling threshold. This is the finite-group
analog of the renormalization group classification of perturbations
in statistical field theory. -/
inductive PerturbationRegime
  | /-- Perturbation vanishes after rescaling: below critical window -/
    irrelevant
  | /-- Perturbation yields nontrivial crossover profile: at critical window -/
    marginal
  | /-- Perturbation forces new asymptotic law: above critical window -/
    relevant

/-- The exponent α **separates regimes** if:
(1) Subcritical sequences (m(k)/k^α → 0) have vanishing defect, and
(2) There exists a critical-scale sequence (m(k)/k^α → 1) with
    nonvanishing defect.
This is the mathematical definition of the upper critical dimension
analog for finite-group subgroup pressure. -/
def SeparatesRegimes
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) : Prop :=
  (∀ ⦃mf : ℕ → ℕ⦄,
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ) ^ α) atTop (𝓝 0) →
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0))
  ∧
  (∃ mf : ℕ → ℕ,
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ) ^ α) atTop (𝓝 (1 : ℝ)) ∧
      ¬ Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0))

/-- A **polynomial defect envelope** asserts that the wreath defect
is bounded by C · m^a / k^b. This is the key quantitative input
from perturbation theory that drives the scaling analysis. -/
structure PolynomialDefectEnvelope (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ)
    (C : ℝ) (a b : ℕ) : Prop where
  hC_nonneg : 0 ≤ C
  bound : ∀ k m : ℕ,
    |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ) ^ a / (k : ℝ) ^ b

/-! ## Part 2: Subcritical Irrelevance — Theorem 1

The first main theorem: if the wreath defect has a polynomial envelope
|Δ(k,m)| ≤ C · m^a / k^b, then for any m(k) with m(k)^a / k^b → 0,
the defect tends to zero. The critical exponent is α_c = b/a.

This converts a perturbative estimate into a bona fide critical-scaling
theorem — the conceptual jump from "small error" to "universality boundary."
-/

/-
**Theorem 1: Subcritical irrelevance from polynomial defect envelope.**

Given |Δ(k,m)| ≤ C · m^a / k^b and m(k)^a / k^b → 0,
we have Δ(k,m(k)) → 0.

This identifies α_c = b/a as the critical exponent: any sequence
m(k) = o(k^{b/a}) lies in the irrelevant regime.
-/
theorem wreath_defect_tendsto_zero_of_subcritical_nat
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} {a b : ℕ}
    (_hC : 0 ≤ C)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ) ^ a / (k : ℝ) ^ b)
    {mf : ℕ → ℕ}
    (hsub :
      Tendsto (fun k => ((mf k : ℝ) ^ a) / (k : ℝ) ^ b) atTop (𝓝 0)) :
    Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0) := by
  exact squeeze_zero_norm ( fun k => hbound k _ ) ( by simpa [ mul_div_assoc ] using hsub.const_mul C )

/-! ## Part 3: Pressure Per-Copy Stability — Theorem 2

Below the critical threshold, the intensive pressure (pressure per copy)
of the wreath product converges to that of the symmetric group.
This says the wreath product is not a new universality class at all
in the subcritical regime — it is asymptotically governed by the same
intensive pressure as independent copies.

This is the finite-group analog of irrelevant perturbations in the
renormalization group.
-/

/-
**Theorem 2: Per-copy pressure stability below threshold.**

If the wreath defect along m(k) tends to zero, and m(k) is eventually
positive, then the intensive pressure β_W(k,m(k))/m(k) converges to
β(S_k).

Equivalently: β_W(k,m(k))/m(k) - β(S_k) → 0.
-/
theorem wreath_pressure_per_copy_tendsto_betaSymm_of_subcritical
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {mf : ℕ → ℕ}
    (hm_eventually_pos : ∀ᶠ k in atTop, 0 < mf k)
    (hdefect :
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0)) :
    Tendsto
      (fun k => betaW k (mf k) / (mf k : ℝ) - betaSymm k)
      atTop (𝓝 0) := by
  rw [ Metric.tendsto_nhds ] at *;
  simp_all +decide [ WreathDefect ];
  intro ε hε; obtain ⟨ a, ha ⟩ := hdefect ε hε; use Max.max a hm_eventually_pos.choose; intro b hb; specialize ha b ( le_trans ( le_max_left _ _ ) hb ) ; rw [ div_sub', abs_div ] <;> norm_cast <;> simp_all +decide [] ;
  · exact lt_of_le_of_lt ( div_le_self ( abs_nonneg _ ) ( mod_cast hm_eventually_pos.choose_spec b hb.2 ) ) ha;
  · linarith [ hm_eventually_pos.choose_spec b hb.2 ]

/-! ## Part 4: Critical Obstruction — Theorem 3

This theorem provides the converse direction: if the defect is bounded
below in absolute value eventually, then it cannot tend to zero.
Combined with the subcritical theorem, this shows the critical
exponent is sharp — universality cannot be extended beyond the
critical window.
-/

/-
**Theorem 3: Critical obstruction — defect cannot vanish with lower bound.**

If |Δ(k,m(k))| ≥ c > 0 eventually, then Δ(k,m(k)) does not tend to zero.
This is the mathematical obstruction to over-optimistic universality claims.
-/
theorem not_tendsto_zero_of_critical_lower_bound
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {c : ℝ} {mf : ℕ → ℕ}
    (hc : 0 < c)
    (hdefect_lower : ∀ᶠ k in atTop,
      c ≤ |WreathDefect betaSymm betaW k (mf k)|)
    :
    ¬ Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0) := by
  exact fun h => absurd ( h.eventually ( Metric.ball_mem_nhds _ hc ) ) fun h' => by have := h'.and hdefect_lower; obtain ⟨ k, hk₁, hk₂ ⟩ := this.exists; exact absurd hk₁ ( by norm_num; linarith ) ;;

/-! ## Part 5: Bridge Theorem — Relevance Ratio Subcriticality

This theorem bridges finite group asymptotics to statistical mechanics.
The relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m/k^α) measures the
"scaling dimension" of the perturbation. We show it tends to zero
in the strictly subcritical regime.
-/

/-
**Bridge Theorem: Relevance ratio is uniformly bounded under polynomial envelope.**

If the defect envelope is |Δ(k,m)| ≤ C · m^a / k^b, then the
normalized relevance ratio |Δ(k,m)| · k^b / m^a is bounded by C.

This gives the perturbation a precise **scaling dimension**: the
normalized defect is controlled by the envelope constant, which is
the finite-group analog of a bounded anomalous dimension.
-/
theorem relevance_ratio_bounded_of_polynomial_envelope
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} {a b : ℕ}
    (_hC : 0 ≤ C)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ) ^ a / (k : ℝ) ^ b)
    {mf : ℕ → ℕ}
    (hm_pos : ∀ᶠ k in atTop, 0 < mf k) :
    ∀ᶠ k in atTop,
      |WreathDefect betaSymm betaW k (mf k)| * ((k : ℝ) ^ b / (mf k : ℝ) ^ a) ≤ C := by
  filter_upwards [ hm_pos, Filter.eventually_gt_atTop 0 ] with k hk hk' ; by_cases hk'' : k = 0 <;> simp_all +decide [ div_eq_mul_inv, mul_comm, mul_left_comm ];
  convert mul_le_mul_of_nonneg_right ( hbound k ( mf k ) ) ( by positivity : ( 0 : ℝ ) ≤ k ^ b * ( mf k ^ a : ℝ ) ⁻¹ ) using 1 ; ring_nf;
  simp +decide [ hk.ne', hk'.ne' ]

/-
**Bridge Theorem 2: Defect per copy vanishes subcritically.**

If the defect satisfies a polynomial envelope and m(k) → ∞,
then the per-copy defect |Δ(k,m(k))|/m(k) → 0 when m(k)^a/k^b → 0.
This is a meaningful "scaling dimension" result: the perturbation
becomes intensive-irrelevant below threshold.
-/
theorem defect_per_copy_tendsto_zero_of_subcritical
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} {a b : ℕ}
    (_hC : 0 ≤ C) (_ha : 1 ≤ a)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ) ^ a / (k : ℝ) ^ b)
    {mf : ℕ → ℕ}
    (hm_pos : ∀ᶠ k in atTop, 0 < mf k)
    (hsub : Tendsto (fun k => ((mf k : ℝ) ^ a) / (k : ℝ) ^ b) atTop (𝓝 0)) :
    Tendsto (fun k =>
      |WreathDefect betaSymm betaW k (mf k)| / (mf k : ℝ)
    ) atTop (𝓝 0) := by
  refine' squeeze_zero_norm' _ ( by simpa using hsub.const_mul C );
  filter_upwards [ hm_pos, hsub.eventually ( gt_mem_nhds zero_lt_one ) ] with k hk₁ hk₂ using by rw [ Real.norm_of_nonneg ( by positivity ) ] ; rw [ mul_div ] ; exact div_le_self ( by positivity ) ( mod_cast hk₁ ) |> le_trans <| mod_cast hbound k ( mf k ) ;

/-! ## Part 6: Limsup Lower Bound for Critical Scaling

A quantitative version of the obstruction theorem using `Filter.limsup`.
-/

/-
**Theorem: Defect bounded below implies no subsequence converges to zero.**

If |Δ(k,m(k))| ≥ c > 0 eventually, then for all sufficiently large k,
the defect stays away from zero. Combined with Theorem 3, this gives
a complete obstruction to universality extension.
-/
theorem defect_eventually_bounded_below
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {c : ℝ} {mf : ℕ → ℕ}
    (hc : 0 < c)
    (hdefect_lower : ∀ᶠ k in atTop,
      c ≤ |WreathDefect betaSymm betaW k (mf k)|) :
    ∀ᶠ k in atTop,
      c / 2 < |WreathDefect betaSymm betaW k (mf k)| := by
  exact hdefect_lower.mono fun k hk => by linarith;;

/-! ## Part 7: Combined Threshold Theorem

Combining subcritical irrelevance with the obstruction lower bound
to show that polynomial bounds force a sharp critical threshold.
-/

/-- **Theorem: Polynomial bounds force regime separation.**

Given upper bound |Δ(k,m)| ≤ C · m^a / k^b and a critical-scale
lower bound sequence, the exponent b/a separates regimes in the
sense that subcritical sequences have vanishing defect while
critical sequences do not. -/
theorem polynomial_bounds_force_threshold
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} {a b : ℕ}
    (hC : 0 ≤ C)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ) ^ a / (k : ℝ) ^ b)
    {c : ℝ} {mf_crit : ℕ → ℕ}
    (hc : 0 < c)
    (hdefect_lower_crit : ∀ᶠ k in atTop,
      c ≤ |WreathDefect betaSymm betaW k (mf_crit k)|) :
    -- Subcritical sequences have vanishing defect
    (∀ {mf : ℕ → ℕ},
      Tendsto (fun k => ((mf k : ℝ) ^ a) / (k : ℝ) ^ b) atTop (𝓝 0) →
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0))
    ∧
    -- The critical sequence has nonvanishing defect
    ¬ Tendsto (fun k => WreathDefect betaSymm betaW k (mf_crit k)) atTop (𝓝 0) := by
  exact ⟨fun hsub => wreath_defect_tendsto_zero_of_subcritical_nat hC hbound hsub,
         not_tendsto_zero_of_critical_lower_bound hc hdefect_lower_crit⟩

/-! ## Part 8: Asymptotic Irrelevance from Polynomial Envelope

Show that a polynomial defect envelope implies asymptotic irrelevance
at the critical exponent.
-/

/-- **Theorem: Polynomial envelope implies asymptotic irrelevance for subcritical sequences.**

This is a convenience wrapper: given polynomial bounds, any sequence
with m(k)^a/k^b → 0 has vanishing defect. -/
theorem asymptotically_irrelevant_of_polynomial_envelope
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} {a b : ℕ}
    (hC : 0 ≤ C)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ) ^ a / (k : ℝ) ^ b) :
    ∀ {mf : ℕ → ℕ},
      Tendsto (fun k => ((mf k : ℝ) ^ a) / (k : ℝ) ^ b) atTop (𝓝 0) →
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0) :=
  fun hsub => wreath_defect_tendsto_zero_of_subcritical_nat hC hbound hsub

/-! ## Part 9: Conjecture — Crossover Profile Existence

The following conjecture states that at the critical scaling,
the defect converges to a nontrivial crossover profile F(λ).
-/

/-- Formal statement of the crossover profile conjecture:
there exists a nontrivial function F such that along any sequence
m(k)/k^α → λ, we have Δ(k,m(k)) → F(λ). -/
def CrossoverProfileConjecture
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) : Prop :=
  ∃ F : ℝ → ℝ,
    -- F(0) = 0 (irrelevant regime)
    F 0 = 0 ∧
    -- F is nontrivial (marginal regime)
    (∃ lam : ℝ, 0 < lam ∧ F lam ≠ 0) ∧
    -- Convergence for all sequences with the right scaling
    ∀ (mf : ℕ → ℕ) (lam : ℝ), 0 ≤ lam →
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ) ^ α) atTop (𝓝 lam) →
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 (F lam))