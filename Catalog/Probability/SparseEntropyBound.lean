/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Entropy bound for energy-constrained (sparse) neural codes

`Catalog/Novelty/SparseEnergyTradeoff.lean` counts the codes of weight at most
`k` on `N` neurons exactly, as `∑_{j ≤ k} N.choose j`, and bounds this crudely.
This file supplies the sharp *asymptotic* estimate that the neural-coding
literature actually uses:

> for a sparsity level `p = k / N ≤ 1/2`,
> `∑_{j ≤ k} N.choose j ≤ exp (N * binEntropy (k / N))`.

Because a cortical population fires at roughly one percent sparsity, the
specialisation `k = N / 100` is the relevant one, and it is recorded here:
a one-percent-sparse population has at most `exp (0.06 * N)` usable patterns,
i.e. it carries at most `0.09 * N` bits rather than the `N` bits of a dense
binary population.

## Results

1. `sub_sum_binomial_le_one` — a partial binomial sum is at most `1`.
2. `pow_mul_pow_le_of_le` — monotonicity of `p^j (1-p)^(N-j)` in `j` below the
   mean, the key inequality for the Chernoff-style argument.
3. `sum_choose_le_exp_binEntropy` — **the entropy bound.**
4. `binEntropy_one_percent_lt` — `binEntropy (1/100) < 0.06`.
5. `sum_choose_one_percent_le` — the one-percent sparsity corollary,
   and `sparse_bits_le` : the code carries at most `0.09 * N` bits.
-/

namespace Catalog.Probability.NeuralCoding.SparseEntropy

open Finset Real

/-- A partial binomial sum with weights `p^j (1-p)^(N-j)` is at most `1`. -/
theorem sub_sum_binomial_le_one {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (N k : ℕ)
    (hkN : k ≤ N) :
    ∑ j ∈ range (k + 1), (N.choose j : ℝ) * (p ^ j * (1 - p) ^ (N - j)) ≤ 1 := by
  have hq0 : (0 : ℝ) ≤ 1 - p := by linarith
  have hbin : (p + (1 - p)) ^ N =
      ∑ j ∈ range (N + 1), p ^ j * (1 - p) ^ (N - j) * (N.choose j : ℝ) :=
    add_pow p (1 - p) N
  have hsub : range (k + 1) ⊆ range (N + 1) := by
    intro x hx
    simp only [mem_range] at hx ⊢
    omega
  have hle : ∑ j ∈ range (k + 1), p ^ j * (1 - p) ^ (N - j) * (N.choose j : ℝ) ≤
      ∑ j ∈ range (N + 1), p ^ j * (1 - p) ^ (N - j) * (N.choose j : ℝ) := by
    apply Finset.sum_le_sum_of_subset_of_nonneg hsub
    intro i _ _
    positivity
  rw [← hbin] at hle
  simp only [add_sub_cancel, one_pow] at hle
  calc ∑ j ∈ range (k + 1), (N.choose j : ℝ) * (p ^ j * (1 - p) ^ (N - j))
      = ∑ j ∈ range (k + 1), p ^ j * (1 - p) ^ (N - j) * (N.choose j : ℝ) := by
        apply Finset.sum_congr rfl; intro j _; ring
    _ ≤ 1 := hle

/-- Below the mean the binomial weight is increasing in `j`: for `j ≤ k ≤ N` and
`p ≤ 1/2`, the weight at `k` is at most the weight at `j`. -/
theorem pow_mul_pow_le_of_le {p : ℝ} (hp0 : 0 ≤ p) (hp2 : p ≤ 1 - p) {N j k : ℕ}
    (hjk : j ≤ k) (hkN : k ≤ N) :
    p ^ k * (1 - p) ^ (N - k) ≤ p ^ j * (1 - p) ^ (N - j) := by
  have hq0 : (0 : ℝ) ≤ 1 - p := le_trans hp0 hp2
  have e1 : p ^ k = p ^ j * p ^ (k - j) := by
    rw [← pow_add]; congr 1; omega
  have e2 : (1 - p) ^ (N - j) = (1 - p) ^ (N - k) * (1 - p) ^ (k - j) := by
    rw [← pow_add]; congr 1; omega
  rw [e1, e2]
  have hstep : p ^ (k - j) ≤ (1 - p) ^ (k - j) := pow_le_pow_left₀ hp0 hp2 _
  have h := mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left hstep (pow_nonneg hp0 j)) (pow_nonneg hq0 (N - k))
  ring_nf at h ⊢
  linarith [h]

/-- **Entropy bound for energy-constrained codes.**  If a neural population of
`N` neurons may fire at most `k ≤ N/2` spikes, the number of admissible activity
patterns is at most `exp (N * binEntropy (k / N))`. -/
theorem sum_choose_le_exp_binEntropy (N k : ℕ) (hk : 0 < k) (h2k : 2 * k ≤ N) :
    ∑ j ∈ range (k + 1), (N.choose j : ℝ) ≤
      Real.exp (N * Real.binEntropy ((k : ℝ) / N)) := by
  have hN : 0 < N := by omega
  have hkN : k ≤ N := by omega
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  set p : ℝ := (k : ℝ) / N with hpdef
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hp0 : 0 < p := div_pos hkR hNR
  have hp2 : p ≤ 1 - p := by
    have h2 : (2 : ℝ) * k ≤ N := by exact_mod_cast h2k
    have hsum : (k : ℝ) / N + (k : ℝ) / N = (2 * k) / N := by ring
    rw [hpdef, le_sub_iff_add_le, hsum, div_le_one hNR]
    linarith
  have hq0 : (0 : ℝ) < 1 - p := lt_of_lt_of_le hp0 hp2
  have hp1 : p ≤ 1 := by linarith
  -- the weight at `k` is the smallest among `j ≤ k`
  have hkey : (∑ j ∈ range (k + 1), (N.choose j : ℝ)) * (p ^ k * (1 - p) ^ (N - k)) ≤ 1 := by
    rw [Finset.sum_mul]
    refine le_trans (Finset.sum_le_sum ?_) (sub_sum_binomial_le_one hp0.le hp1 N k hkN)
    intro j hj
    have hjk : j ≤ k := by simpa [Nat.lt_succ_iff] using mem_range.mp hj
    exact mul_le_mul_of_nonneg_left (pow_mul_pow_le_of_le hp0.le hp2 hjk hkN)
      (Nat.cast_nonneg _)
  have hposw : (0 : ℝ) < p ^ k * (1 - p) ^ (N - k) := by positivity
  have hS : (∑ j ∈ range (k + 1), (N.choose j : ℝ)) ≤ (p ^ k * (1 - p) ^ (N - k))⁻¹ := by
    rw [← one_div]
    exact (le_div_iff₀ hposw).mpr hkey
  refine le_trans hS (le_of_eq ?_)
  -- identify the reciprocal weight with the entropy exponential
  have hNk : ((N - k : ℕ) : ℝ) = (N : ℝ) - k := Nat.cast_sub hkN
  have hexp : (N : ℝ) * Real.binEntropy p
      = (k : ℝ) * Real.log p⁻¹ + ((N : ℝ) - k) * Real.log (1 - p)⁻¹ := by
    have h1 : (N : ℝ) * p = k := by
      rw [hpdef]; field_simp
    have h2 : (N : ℝ) * (1 - p) = (N : ℝ) - k := by
      rw [mul_sub, mul_one, h1]
    simp only [Real.binEntropy]
    rw [mul_add, ← mul_assoc, ← mul_assoc, h1, h2]
  rw [hexp, Real.exp_add, ← hNk]
  have e1 : Real.exp ((k : ℝ) * Real.log p⁻¹) = (p⁻¹) ^ k := by
    rw [Real.exp_nat_mul, Real.exp_log (by positivity)]
  have e2 : Real.exp (((N - k : ℕ) : ℝ) * Real.log (1 - p)⁻¹) = ((1 - p)⁻¹) ^ (N - k) := by
    rw [Real.exp_nat_mul, Real.exp_log (by positivity)]
  rw [e1, e2, mul_inv, inv_pow, inv_pow]

/-- `log 100 < 5`. -/
theorem log_hundred_lt_five : Real.log 100 < 5 := by
  have h : (100 : ℝ) < Real.exp 5 := by
    have he : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
    have h5 : Real.exp 5 = (Real.exp 1) ^ (5 : ℕ) := by
      rw [← Real.exp_nat_mul]; norm_num
    rw [h5]
    calc (100 : ℝ) < (2.7182818283 : ℝ) ^ (5 : ℕ) := by norm_num
      _ ≤ (Real.exp 1) ^ (5 : ℕ) := by
        apply pow_le_pow_left₀ (by norm_num) he.le
  have := (Real.log_lt_iff_lt_exp (by norm_num : (0:ℝ) < 100)).mpr h
  exact this

/-- The binary entropy at one-percent sparsity is less than `0.06` (in nats). -/
theorem binEntropy_one_percent_lt : Real.binEntropy (1 / 100) < 0.06 := by
  simp only [Real.binEntropy]
  have h1 : ((1 : ℝ) / 100)⁻¹ = 100 := by norm_num
  have h2 : (1 - (1 : ℝ) / 100)⁻¹ = 100 / 99 := by norm_num
  rw [h1, h2]
  have hlog2 : Real.log (100 / 99) ≤ 100 / 99 - 1 :=
    Real.log_le_sub_one_of_pos (by norm_num)
  have := log_hundred_lt_five
  nlinarith [hlog2, this]

/-- **One-percent sparsity.**  A population of `N ≥ 200` neurons firing at most
`N / 100` spikes has at most `exp (0.06 * N)` admissible patterns. -/
theorem sum_choose_one_percent_le (N : ℕ) (hN : 200 ≤ N) :
    ∑ j ∈ range (N / 100 + 1), (N.choose j : ℝ) ≤ Real.exp (0.06 * N) := by
  set k := N / 100 with hk
  have hk0 : 0 < k := Nat.div_pos (by omega) (by norm_num)
  have h100 : k * 100 ≤ N := Nat.div_mul_le_self N 100
  have h2k : 2 * k ≤ N := by omega
  refine le_trans (sum_choose_le_exp_binEntropy N k hk0 h2k) ?_
  apply Real.exp_le_exp.mpr
  have hN0 : (0 : ℝ) < N := by positivity
  have hkle : (k : ℝ) / N ≤ 1 / 100 := by
    rw [div_le_div_iff₀ hN0 (by norm_num : (0:ℝ) < 100)]
    have h100R : (k : ℝ) * 100 ≤ N := by exact_mod_cast h100
    linarith
  have hk0R : (0 : ℝ) < (k : ℝ) / N := by
    apply div_pos (by exact_mod_cast hk0) hN0
  have hmono : Real.binEntropy ((k : ℝ) / N) ≤ Real.binEntropy (1 / 100) := by
    apply Real.binEntropy_strictMonoOn.monotoneOn
    · exact ⟨hk0R.le, by linarith⟩
    · exact ⟨by norm_num, by norm_num⟩
    · exact hkle
  have hlt : Real.binEntropy ((k : ℝ) / N) < 0.06 :=
    lt_of_le_of_lt hmono binEntropy_one_percent_lt
  nlinarith [hlt, hN0]

/-- **Bits carried by a one-percent-sparse population.**  Such a population
carries at most `0.09 * N` bits, versus `N` bits for the unconstrained
population. -/
theorem sparse_bits_le (N : ℕ) (hN : 200 ≤ N) :
    Real.logb 2 (∑ j ∈ range (N / 100 + 1), (N.choose j : ℝ)) ≤ 0.09 * N := by
  have hpos : (0 : ℝ) < ∑ j ∈ range (N / 100 + 1), (N.choose j : ℝ) := by
    apply Finset.sum_pos
    · intro j hj
      have : j ≤ N / 100 := by simpa [Nat.lt_succ_iff] using mem_range.mp hj
      have hjN : j ≤ N := le_trans this (Nat.div_le_self _ _)
      exact_mod_cast Nat.choose_pos hjN
    · exact ⟨0, by simp⟩
  have hb := sum_choose_one_percent_le N hN
  have hlog : Real.log (∑ j ∈ range (N / 100 + 1), (N.choose j : ℝ)) ≤ 0.06 * N := by
    calc Real.log (∑ j ∈ range (N / 100 + 1), (N.choose j : ℝ))
        ≤ Real.log (Real.exp (0.06 * N)) := Real.log_le_log hpos hb
      _ = 0.06 * N := Real.log_exp _
  have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hN0 : (0 : ℝ) ≤ N := by positivity
  rw [Real.logb, div_le_iff₀ (by linarith)]
  nlinarith [hlog, hlog2, hN0]

end Catalog.Probability.NeuralCoding.SparseEntropy