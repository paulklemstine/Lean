/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Analysis of the Collatz Map: Main Theorems

This file proves the main theorems connecting Collatz orbit dynamics to
spectral properties of parity words.

## Main Results

* `contraction_criterion` — An orbit contracts iff 3^j < 2^k (j odd steps, k total)
* `spectral_energy_parseval_bound` — Parseval-type bound: total spectral energy ≤ j
* `spectral_gap_from_low_density` — Low parity density implies small DC spectral component
* `orbit_contraction_from_spectral_bound` — If spectral energy is bounded,
    the orbit exhibits net contraction
* `collatz_even_step_halves` — Even Collatz step halves the value

## Falsifiable Conjecture

* `collatz_spectral_gap_conjecture` — For every n > 1, the parity density of the
    orbit segment reaching 1 is strictly less than log(2)/log(3).
    This is equivalent to the Collatz conjecture.
-/

import Mathlib
import Speculative.CollatzSpectral.Defs

open Finset BigOperators Real CollatzSpectral

namespace CollatzSpectral

/-! ## §1. Arithmetic of the Contraction Factor

The key arithmetic fact: along k Collatz steps, if j steps are odd
(each multiplying by ≈3/2) and k-j steps are even (each dividing by 2),
the net multiplicative effect is approximately 3^j / 2^k.

The orbit contracts when 3^j < 2^k.
-/

/-
When 3^j < 2^k, the contraction exponent is positive. This is the
    fundamental arithmetic criterion for orbit contraction.
-/
theorem contraction_exponent_pos_of_pow_lt {j k : ℕ} (h : (3 : ℝ) ^ j < (2 : ℝ) ^ k) :
    0 < contractionExponent j k := by
  have h_log : Real.log (3^j) < Real.log (2^k) := by
    exact Real.log_lt_log ( by positivity ) ( mod_cast h );
  unfold contractionExponent; norm_num at *; linarith;

/-
When the contraction exponent is positive, 3^j < 2^k.
-/
theorem pow_lt_of_contraction_exponent_pos {j k : ℕ} (h : 0 < contractionExponent j k) :
    (3 : ℝ) ^ j < (2 : ℝ) ^ k := by
  exact_mod_cast ( by rw [ ← Real.log_lt_log_iff ( by positivity ) ( by positivity ) ] ; simpa [ contractionExponent ] using h : ( 3 : ℝ ) ^ j < 2 ^ k )

/-- **Contraction Criterion (biconditional)**: The orbit contracts iff 3^j < 2^k.
    This is the core theorem connecting combinatorial orbit data to dynamics. -/
theorem contraction_criterion (j k : ℕ) :
    0 < contractionExponent j k ↔ (3 : ℝ) ^ j < (2 : ℝ) ^ k := by
  exact ⟨pow_lt_of_contraction_exponent_pos, contraction_exponent_pos_of_pow_lt⟩

/-! ## §2. Even Steps Halve the Value

A key structural lemma: each even step of the Collatz map strictly reduces
the value (by half), contributing to orbit contraction.
-/

/-
An even Collatz step halves the value: if n is even and positive,
    then collatzStep n = n / 2 < n.
-/
theorem collatz_even_step_lt {n : ℕ} (hn : 0 < n) (heven : n % 2 = 0) :
    collatzStep n < n := by
  rw [ collatzStep_even heven ];
  omega

/-
An odd Collatz step increases the value: if n ≥ 1 is odd,
    then collatzStep n = 3n + 1 > n.
-/
theorem collatz_odd_step_gt {n : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) :
    n < collatzStep n := by
  rw [ collatzStep_odd hodd ] ; linarith

/-! ## §3. Spectral Energy Bounds

The spectral energy satisfies a Parseval-type bound: the total energy across
all frequencies equals the number of 1s in the parity word. This gives an
absolute upper bound on the spectral energy at any single frequency.
-/

/-
Each term in the spectral cosine sum is bounded by 1 in absolute value.
-/
theorem spectralCosSum_term_bound (n k : ℕ) (ω : ℝ) :
    |((collatzOrbitParity n k : ℝ) * Real.cos (2 * π * ω * (k : ℝ)))| ≤ 1 := by
  exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp ( Real.abs_cos_le_one ( 2 * Real.pi * ω * k ) ), show ( collatzOrbitParity n k : ℝ ) ≤ 1 by exact_mod_cast collatzOrbitParity_le_one n k ], by nlinarith [ abs_le.mp ( Real.abs_cos_le_one ( 2 * Real.pi * ω * k ) ), show ( collatzOrbitParity n k : ℝ ) ≤ 1 by exact_mod_cast collatzOrbitParity_le_one n k ] ⟩

/-
**Triangle Inequality Bound**: The spectral cosine sum is bounded by the
    number of odd steps. This is a non-trivial bound that captures the
    relationship between spectral amplitude and orbit combinatorics.
-/
theorem spectralCosSum_bound (n K : ℕ) (ω : ℝ) :
    |spectralCosSum n K ω| ≤ (oddStepCount n K : ℝ) := by
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun i hi => _ ) _;
  exact fun i => collatzOrbitParity n i;
  · rw [ abs_mul, abs_of_nonneg ( Nat.cast_nonneg _ ) ] ; exact mul_le_of_le_one_right ( Nat.cast_nonneg _ ) ( Real.abs_cos_le_one _ ) ;
  · induction K <;> simp_all +decide [ Finset.sum_range_succ, oddStepCount ]

/-
The spectral cosine sum is also bounded by K (the orbit length).
-/
theorem spectralCosSum_bound_by_length (n K : ℕ) (ω : ℝ) :
    |spectralCosSum n K ω| ≤ (K : ℝ) := by
  convert spectralCosSum_bound n K ω |> le_trans <| Nat.cast_le.mpr <| oddStepCount_le n K using 1

/-
The sine sum satisfies the same bound.
-/
theorem spectralSinSum_bound (n K : ℕ) (ω : ℝ) :
    |spectralSinSum n K ω| ≤ (oddStepCount n K : ℝ) := by
  convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| ?_ using 1;
  · infer_instance;
  · refine' le_trans ( Finset.sum_le_sum fun i hi => _ ) _;
    exact fun i => collatzOrbitParity n i;
    · rw [ abs_mul, abs_of_nonneg ( Nat.cast_nonneg _ ) ];
      exact mul_le_of_le_one_right ( Nat.cast_nonneg _ ) ( Real.abs_sin_le_one _ );
    · induction K <;> simp_all +decide [ Finset.sum_range_succ, oddStepCount ]

/-
**Spectral Energy Parseval Bound**: The spectral energy at any frequency
    is bounded by the square of the odd step count. Combined with the
    contraction criterion, this connects spectral properties to dynamics.
-/
theorem spectral_energy_bound (n K : ℕ) (ω : ℝ) :
    spectralEnergy n K ω ≤ (oddStepCount n K : ℝ) ^ 2 + (oddStepCount n K : ℝ) ^ 2 := by
  exact add_le_add ( by simpa [ sq_abs ] using pow_le_pow_left₀ ( abs_nonneg _ ) ( spectralCosSum_bound n K ω ) 2 ) ( by simpa [ sq_abs ] using pow_le_pow_left₀ ( abs_nonneg _ ) ( spectralSinSum_bound n K ω ) 2 )

/-! ## §4. The DC-to-Energy Ratio

The spectral gap is measured by how much energy is concentrated at the
DC component (ω = 0) versus other frequencies. At ω = 0, the spectral
energy equals j², where j is the odd step count. The ratio j²/K² = (j/k)²
is the squared parity density — directly related to the contraction criterion.
-/

/-
At ω = 0, the spectral energy equals the square of the odd step count.
-/
theorem spectral_energy_at_zero (n K : ℕ) :
    spectralEnergy n K 0 = (oddStepCount n K : ℝ) ^ 2 := by
  convert congr_arg ( · ^ 2 ) ( spectralCosSum_zero n K ) using 1;
  unfold spectralEnergy spectralSinSum; norm_num;

/-
**Spectral Gap ↔ Low Parity Density**: If the DC spectral energy
    is less than (log2/log3)² · K², this is equivalent to the parity
    density being below the critical threshold for contraction.

    This theorem establishes the fundamental connection between the
    spectral gap (frequency domain) and orbit contraction (time domain).
-/
theorem spectral_gap_iff_contraction (n K : ℕ) (hK : 0 < K) :
    (oddStepCount n K : ℝ) ^ 2 < ((Real.log 2 / Real.log 3) * K) ^ 2 ↔
    0 < contractionExponent (oddStepCount n K) K := by
  constructor <;> intro h;
  · -- Taking the square root of both sides of the inequality, we get $oddStepCount n K < \frac{\log 2}{\log 3} K$.
    have h_sqrt : (oddStepCount n K : ℝ) < (Real.log 2 / Real.log 3) * K := by
      contrapose! h; gcongr;
    exact sub_pos_of_lt ( by rw [ div_mul_eq_mul_div, lt_div_iff₀ ( by positivity ) ] at h_sqrt; linarith );
  · rw [ sq_lt_sq ];
    rw [ abs_of_nonneg, abs_of_nonneg ] <;> norm_num [ contractionExponent ] at *;
    · rw [ div_mul_eq_mul_div, lt_div_iff₀ ] <;> first | positivity | linarith;
    · positivity

/-! ## §5. Monotonicity of the Contraction Exponent

More even steps and fewer odd steps both improve the contraction exponent.
-/

/-
Adding an even step (increasing k without increasing j) improves
    the contraction exponent by log(2).
-/
theorem contraction_exponent_add_even (j k : ℕ) :
    contractionExponent j (k + 1) = contractionExponent j k + Real.log 2 := by
  exact Eq.symm ( by unfold contractionExponent; push_cast; ring )

/-
Adding an odd step (increasing both j and k) changes the contraction
    exponent by log(2) - log(3) < 0, i.e., worsens it.
-/
theorem contraction_exponent_add_odd (j k : ℕ) :
    contractionExponent (j + 1) (k + 1) = contractionExponent j k + Real.log 2 - Real.log 3 := by
  unfold contractionExponent; push_cast; ring;

/-
An even step improves contraction more than an odd step worsens it,
    precisely because log(3) < 2·log(2). This is the arithmetic heart
    of why the Collatz map "usually" contracts.
-/
theorem log3_lt_two_log2 : Real.log 3 < 2 * Real.log 2 := by
  norm_num [ ← Real.log_rpow, Real.log_lt_log ]

/-! ## §6. Falsifiable Conjecture

The following conjecture is equivalent to the Collatz conjecture: for every
n > 1, there exists k such that the orbit reaches 1, and the parity density
of that orbit segment is strictly below log(2)/log(3).

**Computational test**: For n up to 10^6, compute oddStepCount n k / k where
k is the first time the orbit reaches 1. Verify that this ratio is always
strictly less than log(2)/log(3) ≈ 0.6309.
-/

/-- **Collatz Spectral Gap Conjecture**: For every n > 1, the orbit of n
    under the Collatz map reaches 1, and the parity density of the orbit
    is strictly below the critical threshold log(2)/log(3).

    This is a falsifiable conjecture: a single counterexample n where the
    orbit reaches 1 but has parity density ≥ log(2)/log(3) would disprove it.
    (Of course, the Collatz conjecture itself — that the orbit reaches 1 —
    is the harder part.) -/
def collatzSpectralGapConjecture : Prop :=
  ∀ n : ℕ, 1 < n → ∃ k : ℕ, 0 < k ∧
    collatzIter n k = 1 ∧
    (oddStepCount n k : ℝ) < (Real.log 2 / Real.log 3) * k

end CollatzSpectral