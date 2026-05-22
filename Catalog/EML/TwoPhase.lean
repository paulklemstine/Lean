/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Two-Phase Limit and Phase Transitions

This file proves the key asymptotic theorem for arithmetic thermodynamics:
when a partition function decomposes as `Z_N = A_N + B_N` with two competing
exponential sectors, the limiting free energy is `max(a, b)`.

## Main results

* `log_sum_two_exp_limit` : `(1/N) log(A_N + B_N) → max(a, b)` pointwise
* `log_add_le_max_add_log2_div` : `(1/N) log(A + B) ≤ max((1/N) log A, (1/N) log B) + log 2 / N`
* `max_le_log_add` : `max((1/N) log A, (1/N) log B) ≤ (1/N) log(A + B)`
* `two_level_partition_zero_classification` : zeros of two-level complex partition function
-/

import Mathlib

open Real BigOperators Filter Topology

noncomputable section

namespace ArithThermo

/-! ### Sandwich bounds for log of sum of two positive reals -/

/-
For positive reals A, B: max(log A, log B) ≤ log(A + B).
-/
lemma max_log_le_log_add {A B : ℝ} (hA : 0 < A) (hB : 0 < B) :
    max (Real.log A) (Real.log B) ≤ Real.log (A + B) := by
  exact max_le ( Real.log_le_log ( by positivity ) ( by linarith ) ) ( Real.log_le_log ( by positivity ) ( by linarith ) )

/-
For positive reals A, B: log(A + B) ≤ max(log A, log B) + log 2.
-/
lemma log_add_le_max_log_add_log2 {A B : ℝ} (hA : 0 < A) (hB : 0 < B) :
    Real.log (A + B) ≤ max (Real.log A) (Real.log B) + Real.log 2 := by
  -- We'll use that $A + B \leq 2 \max(A, B)$ and apply the logarithm to both sides.
  have h_le : A + B ≤ 2 * max A B := by
    linarith [ le_max_left A B, le_max_right A B ];
  convert Real.log_le_log ( by positivity ) h_le using 1 ; ring;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), max_def_lt ] ; split_ifs <;> simp_all +decide [ Real.log_le_log_iff ] ;
  rw [ max_eq_right ( le_of_not_gt fun h => by linarith [ Real.log_le_log ( by positivity ) h.le ] ) ]

/-
Scaled sandwich: `max(a_N, b_N) ≤ (1/N) log(A + B) ≤ max(a_N, b_N) + log 2 / N`
    where `a_N = (1/N) log A` and `b_N = (1/N) log B`.
-/
lemma log_add_sandwich {A B : ℝ} {N : ℝ} (hA : 0 < A) (hB : 0 < B) (hN : 0 < N) :
    max ((1 / N) * Real.log A) ((1 / N) * Real.log B) ≤
      (1 / N) * Real.log (A + B) ∧
    (1 / N) * Real.log (A + B) ≤
      max ((1 / N) * Real.log A) ((1 / N) * Real.log B) + Real.log 2 / N := by
  constructor;
  · rw [ ← mul_max_of_nonneg _ _ ( by positivity ) ];
    exact mul_le_mul_of_nonneg_left ( max_log_le_log_add hA hB ) ( by positivity );
  · convert mul_le_mul_of_nonneg_left ( log_add_le_max_log_add_log2 hA hB ) ( by positivity : ( 0 : ℝ ) ≤ 1 / N ) using 1 ; ring;
    rw [ ← mul_max_of_nonneg _ _ ( by positivity ) ]

/-! ### Pointwise convergence theorem -/

/-
**Two-phase pointwise limit**: If `(1/N) log A_N(θ) → a(θ)` and `(1/N) log B_N(θ) → b(θ)`,
    then `(1/N) log(A_N(θ) + B_N(θ)) → max(a(θ), b(θ))`.
-/
theorem log_sum_two_phase_pointwise
    (A B : ℕ → ℝ)
    (a b : ℝ)
    (hposA : ∀ N, 0 < A N)
    (hposB : ∀ N, 0 < B N)
    (ha : Filter.Tendsto (fun (N : ℕ) => (1 / (↑N : ℝ)) * Real.log (A N)) atTop (nhds a))
    (hb : Filter.Tendsto (fun (N : ℕ) => (1 / (↑N : ℝ)) * Real.log (B N)) atTop (nhds b)) :
    Filter.Tendsto (fun (N : ℕ) => (1 / (↑N : ℝ)) * Real.log (A N + B N)) atTop (nhds (max a b)) := by
  -- Use the squeeze theorem. We have:
  -- max(a_N, b_N) ≤ (1/N) log(A_N + B_N) ≤ max(a_N, b_N) + log 2 / N
  have h_squeeze : ∀ N > 0, max ((1 / N) * Real.log (A N)) ((1 / N) * Real.log (B N)) ≤ (1 / N) * Real.log (A N + B N) ∧ (1 / N) * Real.log (A N + B N) ≤ max ((1 / N) * Real.log (A N)) ((1 / N) * Real.log (B N)) + Real.log 2 / N := by
    exact fun N hN => log_add_sandwich ( hposA N ) ( hposB N ) ( Nat.cast_pos.mpr hN );
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' ( by simpa using Filter.Tendsto.max ha hb ) ( by simpa using Filter.Tendsto.add ( Filter.Tendsto.max ha hb ) ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ) ) ( Filter.eventually_atTop.mpr ⟨ 1, fun N hN => h_squeeze N ( by positivity ) |>.1 ⟩ ) ( Filter.eventually_atTop.mpr ⟨ 1, fun N hN => h_squeeze N ( by positivity ) |>.2 ⟩ )

/-! ### Complex partition zero classification -/

/-
**Two-level partition zero classification**: The zeros of `a * exp(-α * z) + b * exp(-β * z) = 0`
    are characterized by `exp((β - α) * z) = -b / a`.
-/
theorem two_level_partition_zero_classification
    {a b α β : ℂ} (ha : a ≠ 0) :
    {z : ℂ | a * Complex.exp (-α * z) + b * Complex.exp (-β * z) = 0} =
    {z : ℂ | Complex.exp ((β - α) * z) = -b / a} := by
  -- To prove equality of sets, we show each set is a subset of the other.
  apply Set.ext
  intro z
  simp [Set.mem_setOf_eq];
  rw [ eq_div_iff ha, mul_comm ];
  rw [ show ( β - α ) * z = - ( α * z ) - ( - ( β * z ) ) by ring, Complex.exp_sub ];
  rw [ div_mul_eq_mul_div, div_eq_iff ( Complex.exp_ne_zero _ ) ] ; constructor <;> intro h <;> linear_combination h;

end ArithThermo

end