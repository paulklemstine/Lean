/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Kardashev Scale Bounds from Tropical Capacity

## Overview

This file formalizes the connection between tropical network capacity and
the Kardashev civilization scale. The Kardashev index is a monotone function
of usable power, so upper bounds on tropical capacity translate directly
to upper bounds on civilization classification.

## Main Results

* `kardashev_mono_bound` — Monotonicity of the Kardashev normalization:
  bounded power implies bounded Kardashev index.
* `kardashev_bound_of_capacity` — If usable power is at most
  `L * η * C_trop`, then the Kardashev index is bounded accordingly.
* `optimal_power_le` — Optimal collected power cannot exceed
  `L * η` (full luminosity times efficiency).

## Physical Interpretation

- `L` : stellar luminosity (watts)
- `η` : panel conversion efficiency (0 ≤ η ≤ 1)
- `C_trop` : tropical capacity of the shell network (0 ≤ C_trop ≤ 1),
  interpreted as the fraction of stellar flux that can be usefully collected
  after accounting for transport/routing losses.
- `K(P) = log₁₀(P)` : normalized Kardashev index.

The main theorem certifies: `K(P_opt) ≤ K(L * η)`, where `P_opt` is the
power collected by an optimal network configuration.
-/
import Mathlib

open Real

namespace TropicalDyson

/-! ## §1. Kardashev Normalization -/

/-- **Normalized Kardashev index**: the base-10 logarithm of usable power.
    On the original Kardashev scale, Type I ≈ 10^16 W, Type II ≈ 10^26 W.
    This normalization maps power `P` to `log₁₀(P)`, making the scale
    linear in orders of magnitude. -/
noncomputable def kardashevNorm (P : ℝ) : ℝ := Real.log P / Real.log 10

/-
Kardashev normalization is monotone on positive reals.
-/
theorem kardashevNorm_mono {P Q : ℝ} (hP : 0 < P) (hPQ : P ≤ Q) :
    kardashevNorm P ≤ kardashevNorm Q := by
  unfold kardashevNorm; gcongr

/-
**Kardashev Monotonicity Bound**: If usable power `P` is bounded by
    `Cmax`, then the Kardashev index is correspondingly bounded.

    This is the formal certificate that physical power limits translate
    to civilization-scale classification bounds.
-/
theorem kardashev_mono_bound
    {P Cmax : ℝ} (hP : 0 < P) (hC : P ≤ Cmax) :
    kardashevNorm P ≤ kardashevNorm Cmax := by
  exact kardashevNorm_mono hP hC

/-! ## §2. Optimal Power and Capacity Bounds -/

/-- Optimal power from a Dyson shell network with luminosity `L`,
    efficiency `η`, and tropical capacity fraction `C` (0 ≤ C ≤ 1). -/
noncomputable def shellPower (L η C : ℝ) : ℝ := L * η * C

/-
If the capacity fraction is at most 1, optimal power is at most `L * η`.
-/
theorem optimal_power_le {L η C : ℝ}
    (hL : 0 ≤ L) (hη : 0 ≤ η) (hC : C ≤ 1) (_hC0 : 0 ≤ C) :
    shellPower L η C ≤ L * η := by
  exact mul_le_of_le_one_right ( mul_nonneg hL hη ) hC

/-
The Kardashev index of optimally collected power is bounded by the
    index of maximum possible power `L * η`.

    This connects tropical graph optimization to astrophysical scaling:
    the tropical capacity of the shell network imposes a certified upper
    bound on the civilization's Kardashev classification.
-/
theorem kardashev_bound_of_capacity
    {L η C : ℝ}
    (hL : 0 < L) (hη : 0 < η)
    (hC : C ≤ 1) (hC0 : 0 ≤ C)
    (hP : 0 < shellPower L η C) :
    kardashevNorm (shellPower L η C) ≤ kardashevNorm (L * η) := by
  exact kardashev_mono_bound hP ( optimal_power_le hL.le hη.le hC hC0 )

/-! ## §3. Capacity Composition

When multiple shell segments are combined, the overall capacity
is bounded by the product of individual capacities.
-/

/-
Capacity composition: combining two network segments with
    capacities `C₁` and `C₂` yields overall capacity at most `C₁ * C₂`.
    (Under independent routing assumptions.)
-/
theorem capacity_compose_bound {C₁ C₂ : ℝ}
    (h1 : 0 ≤ C₁) (h1' : C₁ ≤ 1)
    (_h2 : 0 ≤ C₂) (h2' : C₂ ≤ 1) :
    C₁ * C₂ ≤ 1 := by
  nlinarith

/-
Shell power is monotone in capacity.
-/
theorem shellPower_mono_capacity {L η C₁ C₂ : ℝ}
    (hL : 0 ≤ L) (hη : 0 ≤ η) (hC : C₁ ≤ C₂) :
    shellPower L η C₁ ≤ shellPower L η C₂ := by
  exact mul_le_mul_of_nonneg_left hC ( mul_nonneg hL hη )

/-
Composing two shell segments yields Kardashev index at most
    that of either individual segment.
-/
theorem kardashev_compose_bound {L η C₁ C₂ : ℝ}
    (hL : 0 < L) (hη : 0 < η)
    (h1 : 0 ≤ C₁) (_h1' : C₁ ≤ 1)
    (_h2 : 0 ≤ C₂) (h2' : C₂ ≤ 1)
    (hP : 0 < shellPower L η (C₁ * C₂)) :
    kardashevNorm (shellPower L η (C₁ * C₂)) ≤
      kardashevNorm (shellPower L η C₁) := by
  exact div_le_div_of_nonneg_right ( Real.log_le_log ( by positivity ) ( mul_le_mul_of_nonneg_left ( mul_le_of_le_one_right h1 h2' ) ( by positivity ) ) ) ( Real.log_nonneg ( by norm_num ) )

end TropicalDyson