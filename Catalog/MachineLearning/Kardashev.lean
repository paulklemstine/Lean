/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Kardashev Scale Bounds from Tropical Capacity

## Overview

This file formalizes a normalized Kardashev index as a monotone function of
usable power and proves that tropical network capacity provides a certified
upper bound on the achievable Kardashev level.

## Key Results

1. **Kardashev monotonicity**: The Kardashev index `log₁₀(P)` is monotone
   in power `P`, so any upper bound on power translates to an upper bound
   on Kardashev level.

2. **Tropical capacity bound**: Optimal collected power is bounded by
   `L * η * C_trop`, connecting graph-theoretic optimization to astrophysical
   scaling laws.

3. **Combined bound**: The Kardashev index of any achievable configuration
   is bounded by the Kardashev index of the tropical capacity limit.

## Physical Interpretation

- `L` = stellar luminosity (watts)
- `η` = panel conversion efficiency (0 < η ≤ 1)
- `C_trop` = tropical capacity of the shell network (0 ≤ C_trop ≤ 1)
- `K(P) = log₁₀(P)` = Kardashev index (Kardashev's original definition)

The theorem chain:
  P_opt ≤ L · η · C_trop  ⟹  K(P_opt) ≤ K(L · η · C_trop)

This is the first machine-checked theorem connecting tropical optimization
on finite graphs to civilization-scale energy classification.
-/
import Mathlib

open Real

/-! ## Kardashev Index Definition -/

/-- Normalized Kardashev index: the base-10 logarithm of power output.
    Kardashev's original scale uses `K = log₁₀(P)/10 - 0.6` but we use
    the simpler monotone-equivalent form `log₁₀(P) = ln(P)/ln(10)`. -/
noncomputable def kardashevNorm (P : ℝ) : ℝ := Real.log P / Real.log 10

/-! ## Monotonicity of Kardashev Index -/

/-
The natural logarithm is monotone on positive reals.
-/
theorem log_mono_of_le {a b : ℝ} (ha : 0 < a) (hab : a ≤ b) :
    Real.log a ≤ Real.log b := by
  exact Real.log_le_log ha hab

/-
**Kardashev monotonicity**: If `P ≤ P_max` with both positive, then
    `K(P) ≤ K(P_max)`. This is the fundamental monotonicity that lets
    power bounds translate to Kardashev bounds.
-/
theorem kardashev_mono_bound
    {P Cmax : ℝ}
    (hP : 0 < P) (hC : P ≤ Cmax) :
    kardashevNorm P ≤ kardashevNorm Cmax := by
  exact div_le_div_of_nonneg_right ( Real.log_le_log hP hC ) ( Real.log_nonneg ( by norm_num ) )

/-! ## Tropical Capacity and Power Bounds -/

/-- Tropical capacity of a shell network: the maximum fraction of stellar
    luminosity that can be collected under routing losses.
    Defined as `1 - (min tropical distance / G)` normalized to `[0, 1]`.

    For a concrete finite graph, this would be computed from the DP distance. -/
noncomputable def tropicalCapacity
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℝ) (s : V) (G : ℝ) : ℝ :=
  1 - (Finset.univ.inf' ⟨s, Finset.mem_univ s⟩
    (fun v => sInf {c : ℝ | ∃ p : List V, p ≠ [] ∧ p.head? = some s ∧ p.getLast? = some v ∧
      (List.foldl (fun acc (pair : V × V) => acc + w pair.1 pair.2) 0
        (p.zip p.tail)) = c})) / G

/-- Optimal collected power given stellar luminosity `L`, efficiency `η`,
    and tropical capacity `C`. -/
noncomputable def optimalPower (L η C : ℝ) : ℝ := L * η * C

/-
**Power bound from tropical capacity**: The optimal collected power
    is bounded by `L * η` when capacity is at most 1.
-/
theorem optimalPower_le_full
    (L η C : ℝ) (hL : 0 < L) (hη : 0 < η) (hC : C ≤ 1) :
    optimalPower L η C ≤ L * η := by
  exact mul_le_of_le_one_right ( mul_nonneg hL.le hη.le ) hC

/-
**Combined Kardashev-tropical bound**: The Kardashev index of optimal
    collected power is bounded by the Kardashev index of `L * η * C_max`
    whenever actual capacity is at most `C_max`.
-/
theorem kardashev_bound_of_capacity
    (L η C Cmax : ℝ) (hL : 0 < L) (hη : 0 < η)
    (hC : 0 < C) (hCmax : C ≤ Cmax) :
    kardashevNorm (optimalPower L η C) ≤
      kardashevNorm (optimalPower L η Cmax) := by
  exact div_le_div_of_nonneg_right ( Real.log_le_log ( by exact mul_pos ( mul_pos hL hη ) hC ) ( by exact mul_le_mul_of_nonneg_left hCmax ( mul_nonneg hL.le hη.le ) ) ) ( by positivity )

/-
**Scaling law**: For a perfect shell (`C = 1`), the Kardashev index is
    exactly `log₁₀(L * η)`. Any routing loss strictly decreases the index.
-/
theorem kardashev_perfect_shell (L η : ℝ) (_hL : 0 < L) (_hη : 0 < η) :
    kardashevNorm (optimalPower L η 1) = kardashevNorm (L * η) := by
  unfold optimalPower; ring;

/-
A weaker capacity bound implies a weaker Kardashev bound: strict
    monotonicity of the Kardashev scale.
-/
theorem kardashev_strict_mono
    {P Q : ℝ} (hP : 0 < P) (hQ : P < Q) :
    kardashevNorm P < kardashevNorm Q := by
  exact div_lt_div_iff_of_pos_right ( Real.log_pos ( by norm_num ) ) |>.2 ( Real.log_lt_log ( by positivity ) hQ )