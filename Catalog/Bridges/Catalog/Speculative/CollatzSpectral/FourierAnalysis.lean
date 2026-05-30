/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Fourier Analysis of the Collatz Map: Spectral Gaps and Orbit Dynamics

This file develops a spectral-theoretic framework for analyzing the Collatz
conjecture through Fourier analysis and parity dynamics.

## Novel Definitions

* `descentExponent` — The logarithmic exponent j·log(3) - (k-j)·log(2)
* `spectralWeight` — The growth factor 3^j / 2^(k-j)
* `exponentialSum` — The discrete Fourier sum for spectral analysis
* `driftFunction` — The random walk drift connecting to probability theory

## Main Results

* `odd_even_partition` — Parity counting identity (induction)
* `contraction_of_neg_descent` — Negative descent implies orbit contraction (calc)
* `spectral_energy_triangle_bound` — Triangle inequality for spectral energy
* `drift_unique_zero_in_unit` — Cross-domain bridge to random walks
-/

import Mathlib

open Finset BigOperators Real

namespace CollatzFourier

/-! ## §1. Collatz Step Function -/

/-- The standard Collatz step function. -/
def cStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

@[simp] theorem cStep_zero : cStep 0 = 0 := by simp [cStep]

theorem cStep_even {n : ℕ} (h : n % 2 = 0) : cStep n = n / 2 := by
  simp [cStep, h]

theorem cStep_odd {n : ℕ} (h : n % 2 = 1) : cStep n = 3 * n + 1 := by
  simp [cStep, h]

theorem cStep_lt_of_even {n : ℕ} (hn : 0 < n) (he : n % 2 = 0) :
    cStep n < n := by
  rw [cStep_even he]; exact Nat.div_lt_self hn (by norm_num)

/-! ## §2. Parity Tracking Along Orbits -/

/-- Parity of the k-th iterate: 1 if odd, 0 if even. -/
def parityAt (n k : ℕ) : ℕ := (cStep^[k] n) % 2

theorem parityAt_le_one (n k : ℕ) : parityAt n k ≤ 1 := by
  simp [parityAt]; omega

/-- Count of odd-parity iterates in first k steps. -/
def oddCount (n : ℕ) : ℕ → ℕ
  | 0 => 0
  | k + 1 => oddCount n k + parityAt n k

/-- Count of even-parity iterates in first k steps. -/
def evenCount (n k : ℕ) : ℕ := k - oddCount n k

theorem oddCount_mono (n : ℕ) : ∀ k, oddCount n k ≤ oddCount n (k + 1) := by
  intro k; simp [oddCount]

/-- oddCount never exceeds total steps (by induction). -/
theorem oddCount_le (n k : ℕ) : oddCount n k ≤ k := by
  induction k with
  | zero => simp [oddCount]
  | succ k ih =>
    simp only [oddCount]
    have h := parityAt_le_one n k
    omega

/-- **Parity Partition Identity**: odd steps + even steps = total steps. -/
theorem odd_even_partition (n k : ℕ) :
    oddCount n k + evenCount n k = k := by
  simp [evenCount]
  exact Nat.add_sub_cancel' (oddCount_le n k)

/-! ## §3. The Descent Exponent and Contraction -/

/-- The Collatz descent exponent: j·log(3) - (k-j)·log(2).
    Negative values mean orbit contraction. -/
noncomputable def descentExponent (j k : ℕ) : ℝ :=
  (j : ℝ) * Real.log 3 - ((k : ℝ) - (j : ℝ)) * Real.log 2

theorem descentExponent_zero : descentExponent 0 0 = 0 := by
  simp [descentExponent]

/-- The spectral weight 3^j / 2^(k-j): multiplicative growth factor. -/
noncomputable def spectralWeight (j k : ℕ) : ℝ :=
  (3 : ℝ) ^ j / (2 : ℝ) ^ (k - j)

theorem spectralWeight_pos (j k : ℕ) : 0 < spectralWeight j k := by
  unfold spectralWeight; positivity

/-
**Contraction Criterion**: negative descent exponent implies
    spectral weight < 1, meaning orbit contraction.
-/
theorem contraction_of_neg_descent (j k : ℕ) (hjk : j ≤ k)
    (h : descentExponent j k < 0) :
    spectralWeight j k < 1 := by
  convert Real.exp_lt_one_iff.mpr h using 1;
  unfold descentExponent spectralWeight; norm_num [ Real.exp_sub, Real.exp_nat_mul, Real.exp_log ] ;
  rw [ ← Real.rpow_natCast, ← Real.rpow_natCast, Real.rpow_def_of_pos, Real.rpow_def_of_pos ] <;> norm_num ; ring;
  rw [ Nat.cast_sub hjk ] ; ring

/-
**Expansion Criterion**: positive descent exponent means
    spectral weight > 1.
-/
theorem expansion_of_pos_descent (j k : ℕ) (hjk : j ≤ k)
    (h : 0 < descentExponent j k) :
    1 < spectralWeight j k := by
  unfold descentExponent spectralWeight at *;
  rw [ ← Real.log_lt_log_iff ( by positivity ) ( by positivity ), Real.log_div ( by positivity ) ( by positivity ), Real.log_pow, Real.log_pow ];
  rw [ Nat.cast_sub hjk ] ; norm_num ; linarith

/-! ## §4. Exponential Sum Bounds -/

/-- Collatz exponential sum over first N terms. -/
noncomputable def exponentialSum (f : ℕ → ℂ) (N : ℕ) : ℂ :=
  (Finset.range N).sum f

/-- Spectral energy: norm of the exponential sum. -/
noncomputable def spectralEnergy (f : ℕ → ℂ) (N : ℕ) : ℝ :=
  ‖exponentialSum f N‖

theorem spectralEnergy_nonneg (f : ℕ → ℂ) (N : ℕ) :
    0 ≤ spectralEnergy f N := norm_nonneg _

/-
**Triangle Inequality Bound**: if each term has modulus ≤ 1,
    spectral energy is at most N.
-/
theorem spectral_energy_triangle_bound (f : ℕ → ℂ) (N : ℕ)
    (hf : ∀ n, n ∈ Finset.range N → ‖f n‖ ≤ 1) :
    spectralEnergy f N ≤ (N : ℝ) := by
  exact le_trans ( norm_sum_le _ _ ) ( by simpa using Finset.sum_le_sum hf )

/-
**Cauchy-Schwarz bound**: |∑ f(n)|² ≤ N · ∑ |f(n)|².
-/
theorem spectral_cauchy_schwarz (f : ℕ → ℂ) (N : ℕ) :
    spectralEnergy f N ^ 2 ≤
      (N : ℝ) * (Finset.range N).sum (fun n => ‖f n‖ ^ 2) := by
  unfold spectralEnergy
  simp [exponentialSum];
  -- Apply the Cauchy-Schwarz inequality to the sum.
  have h_cauchy_schwarz : ∀ (u v : Fin N → ℂ), ‖∑ i, u i * v i‖ ^ 2 ≤ (∑ i, ‖u i‖ ^ 2) * (∑ i, ‖v i‖ ^ 2) := by
    intros u v
    have h_cauchy_schwarz : ‖∑ i, u i * v i‖ ^ 2 ≤ (∑ i, ‖u i‖ * ‖v i‖) ^ 2 := by
      exact pow_le_pow_left₀ ( norm_nonneg _ ) ( norm_sum_le _ _ |> le_trans <| by simp +decide [ norm_mul ] ) _;
    exact h_cauchy_schwarz.trans ( by exact? );
  convert h_cauchy_schwarz ( fun _ => 1 ) ( fun i => f i ) using 1 <;> simp +decide [ Finset.sum_range ]

/-! ## §5. Random Walk Bridge (Cross-Domain) -/

/-- The drift function of a biased random walk modeling Collatz parity.
    μ(p) = p·log(3) - (1-p)·log(2). -/
noncomputable def driftFunction (p : ℝ) : ℝ :=
  p * Real.log 3 - (1 - p) * Real.log 2

/-
Drift at p=0 is -log(2) < 0.
-/
theorem drift_at_zero_neg : driftFunction 0 < 0 := by
  unfold driftFunction; norm_num [ Real.log_pos ] ;

/-
Drift at p=1 is log(3) > 0.
-/
theorem drift_at_one_pos : 0 < driftFunction 1 := by
  exact sub_pos_of_lt ( by norm_num [ Real.log_pos ] )

/-
The drift function is linear, hence strictly increasing
    (since log(2) + log(3) > 0).
-/
theorem drift_strictMono : StrictMono driftFunction := by
  exact fun x y hxy => by unfold driftFunction; nlinarith [ Real.log_pos ( by norm_num : ( 2 : ℝ ) > 1 ), Real.log_lt_log ( by norm_num ) ( by norm_num : ( 3 : ℝ ) > 2 ) ] ;

/-
**Cross-Domain Theorem**: unique zero of drift in (0,1).
    Connects number theory to probability and harmonic analysis.
-/
theorem drift_unique_zero_in_unit :
    ∃! p : ℝ, 0 < p ∧ p < 1 ∧ driftFunction p = 0 := by
  apply_rules [ existsUnique_of_exists_of_unique ];
  · exact ⟨ Real.log 2 / ( Real.log 2 + Real.log 3 ), div_pos ( Real.log_pos ( by norm_num ) ) ( by positivity ), by rw [ div_lt_iff₀ ( by positivity ) ] ; norm_num [ ← Real.log_mul, Real.log_lt_log ], by unfold driftFunction; nlinarith [ Real.log_pos ( show 2 > 1 by norm_num ), Real.log_pos ( show 3 > 1 by norm_num ), mul_div_cancel₀ ( Real.log 2 ) ( by positivity : ( Real.log 2 + Real.log 3 ) ≠ 0 ) ] ⟩;
  · exact fun y₁ y₂ h₁ h₂ => StrictMono.injective ( show StrictMono driftFunction from drift_strictMono ) ( h₁.2.2.trans h₂.2.2.symm )

/-! ## §6. Orbit Length Bounds -/

/-
For n ≥ 2, if the orbit reaches 1, it takes at least one step.
-/
theorem orbit_length_pos {n : ℕ} (hn : 2 ≤ n)
    (hreach : ∃ k, cStep^[k] n = 1) :
    ∃ k, 0 < k ∧ cStep^[k] n = 1 := by
  grind +suggestions

/-! ## §7. Spectral Gap Conjecture (Falsifiable) -/

/-- **Collatz Spectral Gap Conjecture**: there exists C such that
    for all unit-bounded f, the spectral energy grows as O(√N).

    **Test**: Compute F_T for N up to 10^6 and verify max|F_T(ω)|/√N
    stays bounded. -/
def SpectralGapConjecture : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ (N : ℕ) (f : ℕ → ℂ),
    (∀ n, n ∈ Finset.range N → ‖f n‖ ≤ 1) →
    spectralEnergy f N ≤ C * Real.sqrt N

/-! ## §8. Spectral Weight Algebra -/

/-
Spectral weight is multiplicative across orbit segments.
-/
theorem spectralWeight_mul (j₁ k₁ j₂ k₂ : ℕ)
    (h₁ : j₁ ≤ k₁) (h₂ : j₂ ≤ k₂) :
    spectralWeight (j₁ + j₂) (k₁ + k₂) =
      spectralWeight j₁ k₁ * spectralWeight j₂ k₂ := by
  unfold spectralWeight; ring;
  rw [ ← pow_add, tsub_add_tsub_comm h₁ h₂ ]

/-
If spectral weight ≤ r^m with r < 1, the weight is < 1.
-/
theorem spectralWeight_lt_one_of_pow_bound {r : ℝ} (hr : 0 < r) (hr1 : r < 1)
    (j k m : ℕ) (hm : 0 < m)
    (hbound : spectralWeight j k ≤ r ^ m) :
    spectralWeight j k < 1 := by
  exact lt_of_le_of_lt hbound ( pow_lt_one₀ hr.le hr1 ( by positivity ) )

end CollatzFourier